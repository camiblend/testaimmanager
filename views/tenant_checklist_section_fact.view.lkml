view: tenant_checklist_section_fact {
  sql_table_name: public.tenant_checklist_section_fact ;;

  dimension: checklist_category_id {
    type: number
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }
  dimension: checklist_section_id {
    type: number
    sql: ${TABLE}."checklist_section_id" ;;
  }
  dimension: checklist_type_id {
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: commercial_id {
    type: number
    sql: ${TABLE}."commercial_id" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."date" ;;
  }
  dimension: evaluator_id {
    type: number
    sql: ${TABLE}."evaluator_id" ;;
  }
  dimension: general_id {
    type: number
    sql: ${TABLE}."general_id" ;;
  }
  dimension: grade {
    type: number
    sql: ${TABLE}."grade" ;;
  }
  dimension: last_execution {
    type: yesno
    sql: ${TABLE}."last_execution" ;;
  }
  dimension: regional_id {
    type: number
    sql: ${TABLE}."regional_id" ;;
  }
  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  dimension: venue_id {
    type: number
    sql: ${TABLE}."venue_id" ;;
  }
  dimension: venue_type_id {
    type: number
    sql: ${TABLE}."venue_type_id" ;;
  }
  dimension: venue_zone_id {
    type: number
    sql: ${TABLE}."venue_zone_id" ;;
  }
  dimension: weight {
    type: number
    sql: ${TABLE}."weight" ;;
  }
  dimension: zonal_id {
    type: number
    sql: ${TABLE}."zonal_id" ;;
  }
  measure: count {
    type: count
  }
}
