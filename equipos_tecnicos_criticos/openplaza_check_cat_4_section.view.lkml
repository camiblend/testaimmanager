
view: openplaza_check_cat_4_section {
  derived_table: {
    sql: select checklist_id, grade nota_section, s.*,
                row_number() over () as prim_key
      from openplaza_pe.tenant_checklist_section_fact
      join openplaza_pe.section_type s using (section_type_id)
      where checklist_category_id = 4 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: prim_key {
    type: number
    primary_key: yes
    sql: ${TABLE}.prim_key ;;
  }

  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  dimension: nota_section {
    type: number
    sql: ${TABLE}."nota_section" ;;
  }

  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }

  dimension: section_type_name {
    type: string
    label: "Sección"
    sql: ${TABLE}."section_type_name" ;;
  }

  set: detail {
    fields: [
        checklist_id,
  nota_section,
  section_type_id,
  section_type_name
    ]
  }
}
