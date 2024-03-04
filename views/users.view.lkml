view: users {
  sql_table_name: public.users ;;
  drill_fields: [user_id]

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."user_id" ;;
  }
  dimension: tenant_id {
    type: number
    sql: ${TABLE}."tenant_id" ;;
  }
  dimension: user_email {
    type: string
    sql: ${TABLE}."user_email" ;;
  }
  dimension: user_name {
    type: string
    sql: ${TABLE}."user_name" ;;
  }
  measure: count {
    type: count
    drill_fields: [user_id, user_name]
  }
}
