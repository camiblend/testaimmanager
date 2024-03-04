view: checklist_tag {
  sql_table_name: public.checklist_tag ;;

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
  measure: count {
    type: count
    drill_fields: [tag_name]
  }
}
