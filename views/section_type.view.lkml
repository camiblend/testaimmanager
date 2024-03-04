view: section_type {
  sql_table_name: public.section_type ;;
  drill_fields: [section_type_id]

  dimension: section_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }
  dimension: section_type_name {
    type: string
    sql: ${TABLE}."section_type_name" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  measure: count {
    type: count
    drill_fields: [section_type_id, section_type_name, tenant_checklist_step_tag_fac.count]
  }
}
