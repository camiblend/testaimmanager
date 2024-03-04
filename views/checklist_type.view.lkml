view: checklist_type {
  sql_table_name: public.checklist_type ;;
  drill_fields: [checklist_type_id]

  dimension: checklist_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: checklist_type_name {
    type: string
    sql: ${TABLE}."checklist_type_name" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	checklist_type_id,
	checklist_type_name,
	checklist_category_type.count,
	checklist_types_venues.count,
	tenant_checklist_step_tag_fac.count,
	tenant_checklist_tags_fact.count
	]
  }

}
