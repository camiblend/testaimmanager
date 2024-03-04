view: step_type {
  sql_table_name: public.step_type ;;
  drill_fields: [step_type_id]

  dimension: step_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."step_type_id" ;;
  }
  dimension: step_type_name {
    type: string
    sql: ${TABLE}."step_type_name" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  measure: count {
    type: count
    drill_fields: [step_type_id, step_type_name, tenant_checklist_step_tag_fac.count]
  }
}
