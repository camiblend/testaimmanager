view: venue {
  sql_table_name: public.venue ;;
  drill_fields: [venue_id]

  dimension: venue_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."venue_id" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  dimension: venue_alias {
    type: string
    sql: ${TABLE}."venue_alias" ;;
  }
  dimension: venue_name {
    type: string
    sql: ${TABLE}."venue_name" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
	venue_id,
	venue_name,
	checklist_types_venues.count,
	store.count,
	tenant_checklist_step_tag_fac.count,
	tenant_checklist_tags_fact.count
	]
  }

}
