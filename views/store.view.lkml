view: store {
  sql_table_name: public.store ;;
  drill_fields: [store_id]

  dimension: store_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."store_id" ;;
  }
  dimension: contact_mail {
    type: string
    sql: ${TABLE}."contact_mail" ;;
  }
  dimension: contract_business_name {
    type: string
    sql: ${TABLE}."contract_business_name" ;;
  }
  dimension_group: contract_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."contract_end_date" ;;
  }
  dimension: contract_identification {
    type: string
    sql: ${TABLE}."contract_identification" ;;
  }
  dimension_group: contract_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."contract_start_date" ;;
  }
  dimension: location_area {
    type: number
    sql: ${TABLE}."location_area" ;;
  }
  dimension: location_rol {
    type: string
    sql: ${TABLE}."location_rol" ;;
  }
  dimension: phone {
    type: string
    sql: ${TABLE}."phone" ;;
  }
  dimension: store_name {
    type: string
    sql: ${TABLE}."store_name" ;;
  }
  dimension: suc {
    type: string
    sql: ${TABLE}."suc" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  dimension: venue_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."venue_id" ;;
  }
  dimension: x_axis {
    type: number
    sql: ${TABLE}."x_axis" ;;
  }
  dimension: y_axis {
    type: number
    sql: ${TABLE}."y_axis" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	store_id,
	store_name,
	contract_business_name,
	venue.venue_name,
	venue.venue_id,
	tenant_checklist_step_tag_fac.count
	]
  }

}
