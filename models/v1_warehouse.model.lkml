connection: "test_bi"

datagroup: v1_warehouse_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: v1_warehouse_default_datagroup

# include all the views
include: "/views/**/*.view"

explore: tenant_checklist_fact {}

explore: tenant_checklist_section_fact {}

explore: tenant_checklist_step_fact {}

#join: sql_runner_query_test {
    #type: left_outer
    #sql_on: ${fitbit_metrics.id} = ${fitbit_metrics.id} ;;
    #relationship: many_to_one
