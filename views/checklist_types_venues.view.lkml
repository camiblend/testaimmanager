view: checklist_types_venues {
  sql_table_name: public.checklist_types_venues ;;

  dimension: checklist_type_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."checklist_type_id" ;;
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
  measure: count {
    type: count
    drill_fields: [venue.venue_name, venue.venue_id, checklist_type.checklist_type_name, checklist_type.checklist_type_id]
  }
}
