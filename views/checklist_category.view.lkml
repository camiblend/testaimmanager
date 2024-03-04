view: checklist_category {
  sql_table_name: public.checklist_category ;;
  drill_fields: [checklist_category_id]

  dimension: checklist_category_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_category_name {
    type: string
    sql: ${TABLE}."checklist_category_name" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  measure: count {
    type: count
    drill_fields: [checklist_category_id, checklist_category_name, checklist_category_type.count, tenant_checklist_step_tag_fac.count, tenant_checklist_tags_fact.count]
  }
}
