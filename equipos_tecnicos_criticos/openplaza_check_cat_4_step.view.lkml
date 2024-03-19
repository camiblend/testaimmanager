
view: openplaza_checks_cat_4_step {
  derived_table: {
    sql: select checklist_id, grade as nota_step, comments, s.*, section_type_id, checklist_step_id
      from openplaza_pe.tenant_checklist_step_fact
      join openplaza_pe.step_type s using (step_type_id)
      where checklist_category_id = 4 and not (grade is null and comments is null) ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  dimension: round {
    type: number
    sql: ${TABLE}."round" ;;
  }

  dimension: comments {
    type: string
    sql: ${TABLE}."comments" ;;
  }

  dimension: step_type_id {
    type: number
    sql: ${TABLE}."step_type_id" ;;
  }

  dimension: step_type_name {
    type: string
    label: "Paso"
    sql: ${TABLE}."step_type_name" ;;
  }

  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }

  dimension: checklist_step_id {
    type: number
    sql: ${TABLE}."checklist_step_id" ;;
  }

  set: detail {
    fields: [
        checklist_id,
  round,
  comments,
  step_type_id,
  step_type_name,
  section_type_id,
  checklist_step_id
    ]
  }
}
