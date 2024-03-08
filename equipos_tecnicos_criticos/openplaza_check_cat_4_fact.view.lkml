
view: openplaza_check_cat_4_fact {
  derived_table: {
    sql: select checklist_id, checklist_type_id, venue_id, cast(finished_date as date) fecha, u.*, grade
      from openplaza_pe.tenant_checklist_fact
      join openplaza_pe.users u on user_id = evaluator_id
      where checklist_category_id = 4 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  dimension: checklist_type_id {
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
  }

  dimension: venue_id {
    type: number
    sql: ${TABLE}."venue_id" ;;
  }

  dimension: fecha {
    type: date
    sql: ${TABLE}."fecha" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."user_id" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."user_name" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."user_email" ;;
  }

  dimension: grade {
    type: number
    sql: ${TABLE}."grade" ;;
  }

  measure: ejecuciones_fact {
    type: count_distinct
    sql: ${checklist_id} ;;
  }

  measure: prom_nota_fact {
    type: average
    sql: ${grade} ;;
  }

  set: detail {
    fields: [
        checklist_id,
  checklist_type_id,
  venue_id,
  fecha,
  user_id,
  user_name,
  user_email,
  grade,
  ejecuciones_fact,
  prom_nota_fact
    ]
  }
}
