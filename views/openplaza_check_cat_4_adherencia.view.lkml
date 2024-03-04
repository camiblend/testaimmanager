
view: openplaza_check_cat_4_adherencia {
  derived_table: {
    sql: WITH
          frecuencias as (
              select distinct split_part(split_part(checklist_type_name,'Inspeccion ',2),' ',1) frecuencia
              from openplaza_pe.br_checklist_type_category
              join openplaza_pe.checklist_type using (checklist_type_id)
              where checklist_category_id = 4
          ),
          periodos as (
              select generate_series('2023-03-04',current_date - 1,'1 day')::date fecha, 1 q
          ),
          tipo_check as (
              select *, split_part(checklist_type_name,' v',1) tipo_checklist,
                     split_part(split_part(checklist_type_name,'Inspeccion ',2),' ',1) frecuencia
              from openplaza_pe.checklist_category
              join openplaza_pe.br_checklist_type_category using (checklist_category_id)
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
              select *, case when frecuencia = 'Diaria'  then fecha::text
                             when frecuencia = 'Semanal' then concat(extract(year from fecha),'-s',extract(week  from fecha))
                             when frecuencia = 'Mensual' then concat(extract(year from fecha),'-m',extract(month from fecha))
                             when frecuencia = 'Anual'   then extract(year from fecha)::text
                        end to_join
              from frecuencias
              join periodos on 1=1
              join tipo_check using (frecuencia)
              join venues using (checklist_type_id)
          ),
          facts as (
              select finished_date fecha, checklist_id, checklist_type_id, venue_id,
                     split_part(split_part(checklist_type_name,'Inspeccion ',2),' ',1) frecuencia
              from openplaza_pe.tenant_checklist_fact
              join openplaza_pe.checklist_type using (checklist_type_id)
              where checklist_category_id = 4
          ),
          rn as (
              select checklist_id, checklist_type_id, venue_id, fecha::date, frecuencia,
                     case when frecuencia = 'Diaria'  then row_number() over (partition by fecha::date,               venue_id, checklist_type_id order by fecha desc)
                          when frecuencia = 'Semanal' then row_number() over (partition by extract(week  from fecha), venue_id, checklist_type_id order by fecha desc)
                          when frecuencia = 'Mensual' then row_number() over (partition by extract(month from fecha), venue_id, checklist_type_id order by fecha desc)
                          when frecuencia = 'Anual'   then row_number() over (partition by extract(year  from fecha), venue_id, checklist_type_id order by fecha desc)
                      end rn
              from facts
          ),
          ejecuciones as (
              select *, case when frecuencia = 'Diaria'  then fecha::text
                             when frecuencia = 'Semanal' then concat(extract(year from fecha),'-s',extract(week  from fecha))
                             when frecuencia = 'Mensual' then concat(extract(year from fecha),'-m',extract(month from fecha))
                             when frecuencia = 'Anual'   then extract(year from fecha)::text
                        end to_join
              from rn where rn = 1
          )
      
      select bf.*, checklist_id
      from base_final bf
      left join ejecuciones e using (to_join,checklist_type_id,venue_id) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: checklist_type_id {
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
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
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  set: detail {
    fields: [
        checklist_type_id,
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
	checklist_id
    ]
  }
}