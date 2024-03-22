
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

select base_final.*, ejecuciones.checklist_id, concat(tipo_checklist,venue_name,to_join) identificador
from base_final
left join ejecuciones using (to_join,checklist_type_id,venue_id) ;;
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
              <p><img src="https://www.svgrepo.com/show/356371/tick.svg" class="green-icon" height="20" width="20"></p>
              {% else %}
              <p><img src="https://www.svgrepo.com/show/509072/cross.svg" class="red-icon" height="20" width="20"></p>
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
