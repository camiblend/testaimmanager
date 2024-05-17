
view: step_multados {
  derived_table: {
    sql: with general   as (select checklist_id, grade, venue_id, venue_alias, section_type_id,
                                date::date, left(date::text,7) mes_anio, section_type_name,
                                case when checklist_type_name ilike 'Sector Com%'                then concat('SC - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                                     when checklist_type_name ilike 'Servicios - Operacional -%' then concat('S. Operacional - ', split_part(split_part(checklist_type_name,'- ',3),' V',1))
                                     else checklist_type_name end tipo
                         from mallplaza.tenant_checklist_section_fact
                         join mallplaza.venue using (venue_id)
                         join mallplaza.section_type st using (section_type_id)
                         join mallplaza.checklist_type using (checklist_type_id)
                         where venue_id < 18 and date > '2022-01-01' and grade < 100 and section_type_name ilike '%Servicios%' and
                               (checklist_type_name ilike 'Servicios - Operacional%' or checklist_type_name ilike 'Sector Com_n - Terreno -%' or checklist_type_id = 2)),
      
           -- en casos se define que secciones son multadas dada los criterios definidos por MP
           casos     as (select *,
                                case when (section_type_name ilike 'Food Court%' and
                                          ((venue_alias in ('PLD','PEG','PNO','PVE') and grade < 90) or
                                          (venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA') and grade < 85) or
                                          (venue_alias in ('PAL','PSU') and grade < 80))) or
                                          (section_type_name ilike 'Servicios' and
                                           ((venue_alias in ('PLD','PEG','PNO','PVE','POE','PTR','PAN','PLS') and grade < 90) or
                                           (venue_alias in ('PAL','PSU','PTO','PIQ','PCA','PCO','PAR','PBB','PLA') and grade < 85))) then 'multada'
                                     when --section_type_id in (18,19,20,22) and
                                          ((venue_alias in ('PAR','PAN','PBB','PLS','PCA','POE','PCO','PTO','PIQ','PTR','PLA','PVE','PLD','PEG','PNO') and grade < 85) or
                                          (venue_alias in ('PAL','PSU') and grade < 80)) then 'multada'
                                     else 'no aplica' end estado
                         from general)
      
      select s.checklist_id, round(s.grade::numeric,2) nota_step, weight, s.section_type_id, checklist_step_id, step_type_id, step_type_name, comments
      from casos c
      join mallplaza.tenant_checklist_step_tag_fac s on c.checklist_id = s.checklist_id and c.section_type_id = s.section_type_id
      join mallplaza.step_type using (step_type_id)
      where estado = 'multada' and s.grade < 100 and tag_name = 'Servicios' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: checklist_id {
    type: number
    sql: ${TABLE}."checklist_id" ;;
  }

  dimension: nota_step {
    type: number
    sql: ${TABLE}."nota_step" ;;
  }

  dimension: weight {
    type: number
    sql: ${TABLE}."weight" ;;
  }

  dimension: section_type_id {
    type: number
    sql: ${TABLE}."section_type_id" ;;
  }

  dimension: checklist_step_id {
    type: number
    sql: ${TABLE}."checklist_step_id" ;;
  }

  dimension: step_type_id {
    type: number
    sql: ${TABLE}."step_type_id" ;;
  }

  dimension: step_type_name {
    type: string
    sql: ${TABLE}."step_type_name" ;;
  }

  dimension: comments {
    type: string
    sql: ${TABLE}."comments" ;;
  }

  set: detail {
    fields: [
        checklist_id,
	nota_step,
	weight,
	section_type_id,
	checklist_step_id,
	step_type_id,
	step_type_name,
	comments
    ]
  }
}
