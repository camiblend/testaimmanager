view: tenant_checklist_fact {
  sql_table_name: public.tenant_checklist_fact ;;

  dimension: checklist_category_id {
    type: number
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }
  dimension: checklist_type_id {
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: commercial_id {
    type: number
    sql: ${TABLE}."commercial_id" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."created_date" ;;
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
  dimension: event_id {
    type: number
    sql: ${TABLE}."event_id" ;;
  }
  dimension_group: finished_at {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."finished_at" ;;
  }
  dimension_group: finished_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."finished_date" ;;
  }
  dimension: general_id {
    type: number
    sql: ${TABLE}."general_id" ;;
  }
  dimension: grade {
    type: number
    sql: ${TABLE}."grade" ;;
  }
  dimension: infrastructure_id {
    type: number
    sql: ${TABLE}."infrastructure_id" ;;
  }
  dimension: product_id {
    type: string
    sql: ${TABLE}."product_id" ;;
  }
  dimension: regional_id {
    type: number
    sql: ${TABLE}."regional_id" ;;
  }
  dimension: service_id {
    type: number
    sql: ${TABLE}."service_id" ;;
  }
  dimension_group: started_at {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."started_at" ;;
  }
  dimension_group: started_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."started_date" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."store_id" ;;
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
  dimension: zonal_id {
    type: number
    sql: ${TABLE}."zonal_id" ;;
  }
  measure: count {
    type: count
  }
}
