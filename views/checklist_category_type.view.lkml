view: checklist_category_type {
  sql_table_name: public.checklist_category_type ;;

  dimension: checklist_category_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_category_id" ;;
  }
  dimension: checklist_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_type_id" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  measure: count {
    type: count
    drill_fields: [checklist_category.checklist_category_name, checklist_category.checklist_category_id, checklist_type.checklist_type_name, checklist_type.checklist_type_id]
  }
}
