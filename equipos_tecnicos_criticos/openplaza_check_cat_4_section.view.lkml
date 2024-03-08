
view: openplaza_check_cat_4_section {
  derived_table: {
    sql: select checklist_id, grade nota_section, s.*
      from openplaza_pe.tenant_checklist_section_fact
      join openplaza_pe.section_type s using (section_type_id)
      where checklist_category_id = 4 ;;
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

  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }

  dimension: section_type_name {
    type: string
    sql: ${TABLE}."section_type_name" ;;
  }

  set: detail {
    fields: [
        checklist_id,
  round,
  section_type_id,
  section_type_name
    ]
  }
}
