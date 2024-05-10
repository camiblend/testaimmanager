
view: openplaza_check_cat_4_adherencia {
  derived_table: {
    sql: WITH
      frecuencias as (
        select distinct split_part(checklist_type_name,' ',2) frecuencia
        from openplaza_pe.br_checklist_type_category
        join openplaza_pe.checklist_type using (checklist_type_id)
        where checklist_category_id = 4
      ),

      periodos as (
      select cast(generate_series('2023-03-04',current_date -1,'1 Day') as date) fecha, 1 q
      ),

      tipo_check as (
      select *, split_part(checklist_type_name,' v',1) tipo_checklist, split_part(checklist_type_name,' ',2) frecuencia
      from openplaza_pe.br_checklist_type_category
      join openplaza_pe.checklist_type using (checklist_type_id)
      where checklist_category_id = 4
      ),

      venues as (
      select checklist_type_id, v.*
      from openplaza_pe.checklist_types_venues
      join openplaza_pe.venue v using (venue_id)
      join openplaza_pe.br_checklist_type_category using (checklist_type_id)
      where checklist_category_id = 4 and venue_id != 1
      ),

      base_final as (
      select *, case when frecuencia = 'Diaria'  then cast(fecha as text)
      when frecuencia = 'Semanal' then concat(extract(year from fecha),'-s',extract(week  from fecha))
      when frecuencia = 'Mensual' then concat(extract(year from fecha),'-m',extract(month from fecha))
      when frecuencia = 'Anual'   then cast(extract(year from fecha) as text)
      end to_join
      from frecuencias
      join periodos on 1=1
      join tipo_check using (frecuencia)
      join venues using (checklist_type_id)
      ),

      facts as (
      select finished_date fecha, checklist_id, checklist_type_id, venue_id, split_part(checklist_type_name,' ',2) frecuencia
      from openplaza_pe.tenant_checklist_fact
      join openplaza_pe.checklist_type using (checklist_type_id)
      where checklist_category_id = 4
      ),

      rn as (
      select checklist_id, checklist_type_id, venue_id, cast(fecha as date), frecuencia,
      case when frecuencia = 'Diaria'  then row_number() over (partition by cast(fecha as date),       venue_id, checklist_type_id order by fecha desc)
      when frecuencia = 'Semanal' then row_number() over (partition by extract(week  from fecha), venue_id, checklist_type_id order by fecha desc)
      when frecuencia = 'Mensual' then row_number() over (partition by extract(month from fecha), venue_id, checklist_type_id order by fecha desc)
      when frecuencia = 'Anual'   then row_number() over (partition by extract(year  from fecha), venue_id, checklist_type_id order by fecha desc)
      end rn
      from facts
      ),

      ejecuciones as (
      select *, case when frecuencia = 'Diaria'  then cast(fecha as text)
      when frecuencia = 'Semanal' then concat(extract(year from fecha),'-s',extract(week  from fecha))
      when frecuencia = 'Mensual' then concat(extract(year from fecha),'-m',extract(month from fecha))
      when frecuencia = 'Anual'   then cast(extract(year from fecha) as text)
      end to_join
      from rn where rn = 1
      )

      period_all as (
      select base_final.*, ejecuciones.checklist_id, concat(tipo_checklist,venue_name,to_join) identificador
      from base_final
      left join ejecuciones using (to_join,checklist_type_id,venue_id)
      )

      general as (
      select checklist_id, grade, venue_id, venue_alias,
             date::date, left(date::text,7) mes_anio, section_type_name,
             case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                  when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
             else checklist_type_name end tipo
      from mallplaza.tenant_checklist_section_fact
      join mallplaza.venue using (venue_id)
      join mallplaza.section_type st using (section_type_id)
      join mallplaza.checklist_type using (checklist_type_id)
      where venue_id < 18 and date > '2022-01-01' and grade < 100 and section_type_name ilike '%Servicios%' and
            (checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2)),

     -- en casos se define que secciones son multadas dada los criterios definidos por MP
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
            else 'no aplica' end estado
            from general),

      multadas as (
      select * from casos where estado = 'multada'
      ),

      --BV debe hacer un checklist por semana dentro del mes, independiente de a que mes corresponda el primer lunes de la semana, es decir, si la semana la compartes 2 meses diferentes, deben hacerse 2 ejecuciones dicha semana.
      version_bv as (
      select *, row_number() over (partition by mes_anio, extract(week from date), tipo, venue_id order by venue_id, tipo, date desc) n_version
      from multadas where auditor = 'BV'
      ),

      --Aramark debe hacer un checklist por quincena
      version_ar as (
      select *, row_number() over (partition by mes_anio, case when extract(day from date) < 16 then 'q1' else 'q2' end, venue_id order by venue_id, date desc) n_version
      from multadas where auditor = 'Aramark'
      )

      checklist_multados as (
      select checklist_id, date, mes_anio, venue_id, auditor, tipo,
             row_number() over (partition by mes_anio, tipo, venue_id order by venue_id, tipo, date) n_show --testeando
      from version_ar where n_version = 1
      union
      select checklist_id, date, mes_anio, venue_id, auditor, tipo,
             row_number() over (partition by mes_anio, tipo, venue_id order by venue_id, tipo, date) n_show --testeando
      from version_bv where n_version = 1
      ),

      -- en todos los tipos de checklist de BV se debe considerar solo la sección servicios, por lo tanto, no es necesario enlistar la sección
      -- de las 3 secciones disponibles hasta el momento, la que se utilizará es "Servicios"

      -- De todos los tipos de checklists de la categoría, solo se utilizan las de sector comun y servicio operacional

      c_types as (
      select distinct case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                           when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                      else checklist_type_name end tipo,
                      case when checklist_type_id = 2 then 'Aramark'
                      else 'BV' end auditor
      from mallplaza.checklist_type
      where checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2
      ),

      seccion as (
      select distinct section_type_name, case when section_type_name = 'Servicios' then 'BV' else 'Aramark' end auditor
      from mallplaza.section_type
      where section_type_name ilike '%(Servicios)' or section_type_name = 'Servicios'
      )

      checklist_type_section as (
      select *, 1 uno
      from c_types
      join seccion using (auditor)
      ),

      period as (
      SELECT fecha,
             case when extract(day from fecha) < 16 then 'q1' else 'q2' end quincena,
             row_number() over (partition by left(fecha::text,7), extract(week from fecha) order by fecha) semana
      FROM (SELECT DATE(generate_series('2022-01-01'::date, hoy.today::date, '1 Day')) AS fecha --Modificar aqui para fechas deseadas
            FROM (SELECT current_date today) AS hoy ORDER BY Fecha ) AS sub1
      ),

      version_quincena_mes as (
      select fecha, lead(fecha,1) over (partition by semana order by fecha) semana_siguiente, quincena version_quincena,
             row_number() over (partition by left(fecha::text,7) order by fecha) version_semana_mes
      from period
      where semana = 1 and concat(extract(day from fecha),date_part('dow', fecha)) != '10'
      ),

      general2 as (
      select checklist_id, grade, venue_id, venue_alias, checklist_section_id, section_type_id,
             date::date, left(date::text,7) mes_anio, section_type_name,
             case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                  when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
             else checklist_type_name end tipo
      from mallplaza.tenant_checklist_section_fact
      join mallplaza.venue using (venue_id)
      join mallplaza.section_type st using (section_type_id)
      join mallplaza.checklist_type using (checklist_type_id)
      where venue_id < 18 and date > '2022-01-01' and grade < 100 and section_type_name ilike '%Servicios%' and
            (checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2)
      ),

     -- en casos se define que secciones son multadas dada los criterios definidos por MP
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
             else 'no aplica' end estado
      from general2
      ),

      sections as (
      select checklist_id, round(grade::numeric,2) grade_section, section_type_name, tipo, checklist_section_id, section_type_id
      from casos2 where estado = 'multada'
      )

      select *
      from period_all pa
      join checklist_type_section cts    on 1=1
      left join checklist_multados cm    on pa.mes_anio = cm.mes_anio and pa.venue_id = cm.venue_id and pa.tipo = cts.tipo
      left join version_quincena_mes vqm on vqm.fecha <= cm.date and coalesce(vqm.fecha, current_date) > cm.date
      left join sections s               on s.checklist_id = cm.checklist_id and s.section_type_name = cts.section_type_name and s.tipo = cts.tipo



      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: checklist_type_id {
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
  }

  dimension: identificador {
    type: string
    sql: ${TABLE}."identificador" ;;
  }

  dimension: frecuencia {
    type: string
    sql: ${TABLE}."frecuencia" ;;
  }

  dimension: fecha {
    type: date
    sql: ${TABLE}."fecha" ;;
  }

  dimension: q {
    type: number
    sql: ${TABLE}."q" ;;
  }

  dimension: checklist_category_id {
    type: number
    sql: ${TABLE}."checklist_category_id" ;;
  }

  dimension: checklist_category_name {
    type: string
    sql: ${TABLE}."checklist_category_name" ;;
  }

  dimension: checklist_type_name {
    type: string
    sql: ${TABLE}."checklist_type_name" ;;
  }

  dimension: tipo_checklist {
    type: string
    sql: ${TABLE}."tipo_checklist" ;;
  }

  dimension: venue_id {
    type: number
    sql: ${TABLE}."venue_id" ;;
  }

  dimension: venue_name {
    type: string
    label: "Recinto"
    sql: ${TABLE}."venue_name" ;;
  }

  dimension: venue_alias {
    type: string
    sql: ${TABLE}."venue_alias" ;;
  }

  dimension: to_join {
    type: string
    sql: ${TABLE}."to_join" ;;
  }

  dimension: checklist_id {
    type: string
    sql: ${TABLE}."checklist_id" ;;
  }

  measure: ejecuciones {
    type: count_distinct
    sql: ${checklist_id} ;;
  }

  measure: meta {
    type: count_distinct
    sql: ${identificador} ;;
  }

  dimension: image {
    type: string
    sql: ${venue_name} ;;
    html:
              <img src="https://aimmanager.com/wp-content/uploads/2019/07/mainlogo-300x138.png" height="90" width="200">
               ;;
  }

  measure: cumplimiento {
    type: string
    sql: ${ejecuciones} ;;
    html:
              {% if ejecuciones._value > 0 %}
              <p><img src="https://www.svgrepo.com/show/384403/accept-check-good-mark-ok-tick.svg"  height="20" width="20"></p>
              {% else %}
              <p><img src="https://www.svgrepo.com/show/401366/cross-mark-button.svg" height="20" width="20"></p>
              {% endif %}
               ;;
  }

  dimension: year {
    type: number
    label: "Año"
    sql: extract(year from ${TABLE}.fecha) ;;
  }

  dimension: n_month {
    type: number
    sql: extract(month from ${TABLE}.fecha) ;;
  }

  dimension: dashboard_2 {
    type: string
    sql: ${TABLE}.tipo_checklist ;;
    link: {
      label:"Ver cumplimiento"
      url: "https://aimmanagertest.cloud.looker.com/dashboards/8?Checklist={{ openplaza_check_cat_4_adherencia.tipo_checklist | url_encode}}&Recinto={{ openplaza_check_cat_4_adherencia.venue_name | url_encode}}"
      icon_url: "https://aimmanager.com/wp-content/uploads/2020/01/nuevo-AIM-logo-e1651708693619-300x116.png"
    }
  }

  dimension: nombre_mes {
    type: string
    label: "Mes"
    sql: CASE
         WHEN ${n_month} = 1 THEN 'Enero'
         WHEN ${n_month} = 2 THEN 'Febrero'
         WHEN ${n_month} = 3 THEN 'Marzo'
         WHEN ${n_month} = 4 THEN 'Abril'
         WHEN ${n_month} = 5 THEN 'Mayo'
         WHEN ${n_month} = 6 THEN 'Junio'
         WHEN ${n_month} = 7 THEN 'Julio'
         WHEN ${n_month} = 8 THEN 'Agosto'
         WHEN ${n_month} = 9 THEN 'Septiembre'
         WHEN ${n_month} = 10 THEN 'Octubre'
         WHEN ${n_month} = 11 THEN 'Noviembre'
         WHEN ${n_month} = 12 THEN 'Diciembre'
         ELSE NULL
       END ;;
  }

  dimension: week {
    type: number
    label: "Semana"
    sql: CONCAT('S', extract(week from ${TABLE}.fecha)::string) ;;
  }


  set: detail {
    fields: [
      checklist_type_id,
      identificador,
      frecuencia,
      fecha,
      q,
      checklist_category_id,
      checklist_category_name,
      checklist_type_name,
      tipo_checklist,
      venue_id,
      venue_name,
      venue_alias,
      to_join,
      checklist_id,
      ejecuciones,
      meta,
      image,
      year,
      n_month,
      nombre_mes,
      week
    ]
  }
}
