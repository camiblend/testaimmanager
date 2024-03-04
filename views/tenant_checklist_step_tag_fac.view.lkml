view: tenant_checklist_step_tag_fac {
  sql_table_name: public.tenant_checklist_step_tag_fac ;;

  dimension: checklist_category_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_grade_option_id {
    type: number
    sql: ${TABLE}."checklist_grade_option_id" ;;
  }
  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }
  dimension: checklist_step_id {
    type: number
    sql: ${TABLE}."checklist_step_id" ;;
  }
  dimension: checklist_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."comments" ;;
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
  dimension: last_execution {
    type: yesno
    sql: ${TABLE}."last_execution" ;;
  }
  dimension: option_name {
    type: string
    sql: ${TABLE}."option_name" ;;
  }
  dimension: regional_id {
    type: number
    sql: ${TABLE}."regional_id" ;;
  }
  dimension: section_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."section_type_id" ;;
  }
  dimension: step_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."step_type_id" ;;
  }
  dimension: store_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."store_id" ;;
  }
  dimension: tag_id {
    type: number
    sql: ${TABLE}."tag_id" ;;
  }
  dimension: tag_name {
    type: string
    sql: ${TABLE}."tag_name" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	option_name,
	tag_name,
	venue.venue_name,
	venue.venue_id,
	checklist_category.checklist_category_name,
	checklist_category.checklist_category_id,
	checklist_type.checklist_type_name,
	checklist_type.checklist_type_id,
	store.store_name,
	store.store_id,
	store.contract_business_name,
	section_type.section_type_name,
	section_type.section_type_id,
	step_type.step_type_id,
	step_type.step_type_name
	]
  }

}
