connection: "v1_warehouse"

datagroup: v1_warehouse_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: v1_warehouse_default_datagroup

# include all the views

#include: "/views/**/*.view"
include: "/equipos_tecnicos_criticos/**/*.view"
explore: openplaza_check_cat_4_adherencia {
  join: openplaza_check_cat_4_fact {
    type: left_outer
    sql_on: ${openplaza_check_cat_4_adherencia.fecha}             = ${openplaza_check_cat_4_fact.fecha} and
            ${openplaza_check_cat_4_adherencia.checklist_type_id} = ${openplaza_check_cat_4_fact.checklist_type_id} and
            ${openplaza_check_cat_4_adherencia.venue_id}          = ${openplaza_check_cat_4_fact.venue_id};;
    relationship: many_to_many
  }
  join: openplaza_check_cat_4_section {
    type:  left_outer
    sql_on:  ${openplaza_check_cat_4_section.checklist_id}        = ${openplaza_check_cat_4_fact.checklist_id};;
    relationship: one_to_many
  }
  join: openplaza_checks_cat_4_step {
    type: left_outer
    sql_on: ${openplaza_checks_cat_4_step.checklist_id}            = ${openplaza_check_cat_4_section.checklist_id} and
            ${openplaza_checks_cat_4_step.section_type_id}         = ${openplaza_check_cat_4_section.section_type_id};;
    relationship: one_to_many
  }
  join: openplaza_check_cat_4_incident {
    type: left_outer
    sql_on: ${openplaza_check_cat_4_incident.checklist_step_id}    = ${openplaza_checks_cat_4_step.checklist_step_id};;
    relationship: many_to_many
  }
}
