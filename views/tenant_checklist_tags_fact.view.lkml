view: tenant_checklist_tags_fact {
  sql_table_name: public.tenant_checklist_tags_fact ;;

  dimension: checklist_category_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }
  dimension: checklist_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: commercial_id {
    type: number
    sql: ${TABLE}."commercial_id" ;;
  }
  dimension: concept_id {
    type: number
    sql: ${TABLE}."concept_id" ;;
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
  dimension: regional_id {
    type: number
    sql: ${TABLE}."regional_id" ;;
  }
  dimension: tag_id {
    type: number
    sql: ${TABLE}."tag_id" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	checklist_category.checklist_category_name,
	checklist_category.checklist_category_id,
	checklist_type.checklist_type_name,
	checklist_type.checklist_type_id,
	venue.venue_name,
	venue.venue_id
	]
  }

}
