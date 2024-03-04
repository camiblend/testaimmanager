connection: "test_bi"

datagroup: v1_warehouse_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: v1_warehouse_default_datagroup

# include all the views
include: "/views/**/*.view"

explore: tenant_checklist_fact {
  join: tenant_checklist_section_fact {
    type:  left_outer
    sql_on:  ${tenant_checklist_fact.checklist_id} = ${tenant_checklist_section_fact.checklist_id};;
    relationship: one_to_many
  }
}

explore: tenant_checklist_section_fact {}

explore: tenant_checklist_step_fact {}
