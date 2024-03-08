
view: openplaza_check_cat_4_incident {
  derived_table: {
    sql: select date, finished_date, is_finished, incident_id, u.*, tag_id, incident_description, ist.*, ic.*, ii.*,
             checklist_step_id, sla
      from openplaza_pe.tenant_incident_fact
      join openplaza_pe.users u on u.user_id = last_user_id
      join openplaza_pe.incident_state_type ist using (incident_state_type_id)
      join openplaza_pe.incident_category ic using (incident_category_id)
      join openplaza_pe.incident_interface ii using (incident_interface_id)
      where checklist_category_id = 4 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."date" ;;
  }

  dimension_group: finished_date {
    type: time
    sql: ${TABLE}."finished_date" ;;
  }

  dimension: is_finished {
    type: string
    sql: ${TABLE}."is_finished" ;;
  }

  dimension: incident_id {
    type: number
    sql: ${TABLE}."incident_id" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."user_id" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."user_name" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."user_email" ;;
  }

  dimension: tag_id {
    type: number
    sql: ${TABLE}."tag_id" ;;
  }

  dimension: incident_description {
    type: string
    sql: ${TABLE}."incident_description" ;;
  }

  dimension: incident_state_type_id {
    type: number
    sql: ${TABLE}."incident_state_type_id" ;;
  }

  dimension: incident_state_type_name {
    type: string
    sql: ${TABLE}."incident_state_type_name" ;;
  }

  dimension: incident_category_id {
    type: number
    sql: ${TABLE}."incident_category_id" ;;
  }

  dimension: incident_category_name {
    type: string
    sql: ${TABLE}."incident_category_name" ;;
  }

  dimension: incident_interface_id {
    type: number
    sql: ${TABLE}."incident_interface_id" ;;
  }

  dimension: incident_interface_name {
    type: string
    sql: ${TABLE}."incident_interface_name" ;;
  }

  dimension: checklist_step_id {
    type: number
    sql: ${TABLE}."checklist_step_id" ;;
  }

  dimension: sla {
    type: number
    sql: ${TABLE}."sla" ;;
  }

  measure: incidentes {
    type:  count_distinct
    sql: ${incident_id} ;;
  }

  set: detail {
    fields: [
        date_time,
  finished_date_time,
  is_finished,
  incident_id,
  user_id,
  user_name,
  user_email,
  tag_id,
  incident_description,
  incident_state_type_id,
  incident_state_type_name,
  incident_category_id,
  incident_category_name,
  incident_interface_id,
  incident_interface_name,
  checklist_step_id,
  sla,
  incidentes
    ]
  }
}
