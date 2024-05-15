
view: principal {
  derived_table: {
    sql: WITH
          venues as (
              select *
              from mallplaza.venue
              where venue_id < 18),
      
          periods as (
              SELECT Fecha, left(Fecha::text,7) mes_anio
              FROM (SELECT  sub1.Fecha, row_number() over (partition by extract('year' from fecha), extract('month' from fecha) order by fecha desc) rn
                    FROM (SELECT DATE(generate_series('2022-01-01'::date, hoy.today::date, '1 Month')) AS Fecha
                          FROM (SELECT current_date today) AS hoy ORDER BY Fecha ) AS sub1
                    ORDER BY Fecha) AS period_all
              WHERE rn = 1),
      
          period_venues as (
              select *
              from venues v
              join periods p on 1=1
          ),
          --------------------------------------------------------------------------------------------------------------------
          c_types as (
              select distinct case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                                   when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                                   else checklist_type_name
                              end tipo,
                              case when checklist_type_id = 2 then 'Aramark'
                                   else 'BV'
                              end auditor
              from mallplaza.checklist_type
              where checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2
          ),
      
          seccion as (
              select distinct section_type_name, case when section_type_name = 'Servicios' then 'BV' else 'Aramark' end auditor
              from mallplaza.section_type
              where section_type_name ilike '%(Servicios)' or section_type_name = 'Servicios'
          ),
      
          checklist_type_section as (
              select *, 1 uno
              from c_types
              join seccion using (auditor)
          ),
          --------------------------------------------------------------------------------------------------------------------
          general as (
              select checklist_id, grade, venue_id, venue_alias, date::date, left(date::text,7) mes_anio, section_type_name, checklist_type_name,
              case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
              when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
              else checklist_type_name
              end tipo
              from mallplaza.tenant_checklist_section_fact
              join mallplaza.venue using (venue_id)
              join mallplaza.section_type st using (section_type_id)
              join mallplaza.checklist_type using (checklist_type_id)
              where venue_id < 18 and date > '2022-01-01' and grade < 100 and section_type_name ilike '%Servicios%' and
              (checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2)
          ),
      
          casos as (
              select distinct checklist_id, date, mes_anio, venue_id, tipo, --distinct es para quitar las secciones
                      case when section_type_name = 'Servicios' then 'BV' else 'Aramark' end auditor,
                      case when (section_type_name ilike 'Food Court%' and ((venue_alias in ('PLD','PEG','PNO','PVE') and grade < 90) or
                                (venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA') and grade < 85) or
                                (venue_alias in ('PAL','PSU') and grade < 80))) or
                                (section_type_name ilike 'Servicios' and ((venue_alias in ('PLD','PEG','PNO','PVE','POE','PTR','PAN','PLS') and grade < 90) or
                                (venue_alias in ('PAL','PSU','PTO','PIQ','PCA','PCO','PAR','PBB','PLA') and grade < 85))) then 'multada'
                          when --section_type_id in (18,19,20,22) and
                                ((venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA','PVE','PLD','PEG','PNO') and grade < 85) or
                                (venue_alias in ('PAL','PSU') and grade < 80)) then 'multada'
                          else 'no aplica'
                      end estado
              from general
              ),
      
          multadas as (
              select *
              from casos
              where estado = 'multada'
          ),
      
          version_bv as (
          select *, row_number() over (partition by mes_anio, extract(week from date), tipo, venue_id order by venue_id, tipo, date desc) n_version
          from multadas
          where auditor = 'BV'
          ),
      
          --Aramark debe hacer un checklist por quincena
          version_ar as (
          select *, row_number() over (partition by mes_anio, case when extract(day from date) < 16 then 'q1' else 'q2' end, venue_id order by venue_id, date desc) n_version
          from multadas
          where auditor = 'Aramark'
          ),
      
          checklist_multados as (
              select checklist_id, date, mes_anio, venue_id, auditor, tipo, row_number() over (partition by mes_anio, tipo, venue_id order by venue_id, tipo, date) n_show --testeando
              from version_ar where n_version = 1
              union
              select checklist_id, date, mes_anio, venue_id, auditor, tipo, row_number() over (partition by mes_anio, tipo, venue_id order by venue_id, tipo, date) n_show --testeando
              from version_bv where n_version = 1
          ),
          --------------------------------------------------------------------------------------------------------------------
          period as (
              SELECT fecha, case when extract(day from fecha) < 16 then 'q1' else 'q2' end quincena,
              row_number() over (partition by left(fecha::text,7), extract(week from fecha) order by fecha) semana
              FROM (SELECT DATE(generate_series('2022-01-01'::date, hoy.today::date, '1 Day')) AS fecha --Modificar aqui para fechas deseadas
              FROM (SELECT current_date today) AS hoy ORDER BY fecha ) AS sub1
          ),
      
          version_quincena_mes as (
              select fecha, lead(fecha,1) over (partition by semana order by fecha) semana_siguiente, quincena version_quincena,
                     row_number() over (partition by left(fecha::text,7) order by fecha) version_semana_mes, coalesce(fecha, current_date)
              from period
              where semana = 1 and concat(extract(day from fecha),date_part('dow', fecha)) != '10'
          ),
          --------------------------------------------------------------------------------------------------------------------
          general2 as (
              select checklist_id, grade, venue_id, venue_alias, checklist_section_id, section_type_id, date::date, left(date::text,7) mes_anio, section_type_name,
                      case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                           when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                           else checklist_type_name
                      end tipo
              from mallplaza.tenant_checklist_section_fact
              join mallplaza.venue using (venue_id)
              join mallplaza.section_type st using (section_type_id)
              join mallplaza.checklist_type using (checklist_type_id)
              where venue_id < 18 and date > '2022-01-01' and grade < 100 and section_type_name ilike '%Servicios%' and
              (checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2)
          ),
      
          casos2 as (
              select *,
                      case when (section_type_name ilike 'Food Court%' and ((venue_alias in ('PLD','PEG','PNO','PVE') and grade < 90) or
                                (venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA') and grade < 85) or
                                (venue_alias in ('PAL','PSU') and grade < 80))) or
                                (section_type_name ilike 'Servicios' and ((venue_alias in ('PLD','PEG','PNO','PVE','POE','PTR','PAN','PLS') and grade < 90) or
                                (venue_alias in ('PAL','PSU','PTO','PIQ','PCA','PCO','PAR','PBB','PLA') and grade < 85))) then 'multada'
                           when --section_type_id in (18,19,20,22) and
                                ((venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA','PVE','PLD','PEG','PNO') and grade < 85) or
                                (venue_alias in ('PAL','PSU') and grade < 80)) then 'multada'
                           else 'no aplica'
                      end estado
              from general2
          ),
      
          sections as (
              select checklist_id, round(grade::numeric,2) grade_section, section_type_name, tipo, checklist_section_id, section_type_id
              from casos2
              where estado = 'multada'
          )
      
      select pv.*, cts.*, cm.checklist_id, cm.date, cm.n_show, vqm.semana_siguiente, vqm.version_quincena, vqm.version_semana_mes, s.grade_section, s.checklist_section_id, s.section_type_id
      from period_venues pv
      join checklist_type_section cts     on 1=1
      left join checklist_multados cm     using (mes_anio, venue_id, tipo)
      left join version_quincena_mes vqm  on cm.date >= vqm.fecha and cm.date < coalesce(vqm.semana_siguiente, current_date)
      left join sections s                on cm.checklist_id = s.checklist_id and cts.section_type_name = s.section_type_name and cts.tipo = s.tipo ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: venue_id {
    type: number
    sql: ${TABLE}."venue_id" ;;
  }

  dimension: venue_name {
    type: string
    sql: ${TABLE}."venue_name" ;;
  }

  dimension: venue_alias {
    type: string
    sql: ${TABLE}."venue_alias" ;;
  }

  dimension: fecha {
    type: date
    sql: ${TABLE}."fecha" ;;
  }

  dimension: mes_anio {
    type: string
    sql: ${TABLE}."mes_anio" ;;
  }

  dimension: auditor {
    type: string
    sql: ${TABLE}."auditor" ;;
  }

  dimension: tipo {
    type: string
    sql: ${TABLE}."tipo" ;;
  }

  dimension: section_type_name {
    type: string
    sql: ${TABLE}."section_type_name" ;;
  }

  dimension: uno {
    type: number
    sql: ${TABLE}."uno" ;;
  }

  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."date" ;;
  }

  dimension: n_show {
    type: number
    sql: ${TABLE}."n_show" ;;
  }

  dimension: semana_siguiente {
    type: date
    sql: ${TABLE}."semana_siguiente" ;;
  }

  dimension: version_quincena {
    type: string
    sql: ${TABLE}."version_quincena" ;;
  }

  dimension: version_semana_mes {
    type: number
    sql: ${TABLE}."version_semana_mes" ;;
  }

  dimension: grade_section {
    type: number
    sql: ${TABLE}."grade_section" ;;
  }

  dimension: checklist_section_id {
    type: number
    sql: ${TABLE}."checklist_section_id" ;;
  }

  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }

  set: detail {
    fields: [
        venue_id,
	venue_name,
	venue_alias,
	fecha,
	mes_anio,
	auditor,
	tipo,
	section_type_name,
	uno,
	checklist_id,
	date,
	n_show,
	semana_siguiente,
	version_quincena,
	version_semana_mes,
	grade_section,
	checklist_section_id,
	section_type_id
    ]
  }
}
