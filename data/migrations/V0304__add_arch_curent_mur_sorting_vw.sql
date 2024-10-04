/*
This is for issue #6005 Add a view that combine case_sserial of current murs and archived murs to faciliate sorting
*/


CREATE OR REPLACE VIEW fecmur.arch_current_mur_sorting_vw AS 
    SELECT cm.case_id,
           cm.case_no,
           cm.case_serial,
           'current' AS mur_type
    FROM fecmur.cases_with_parsed_case_serial_numbers_vw cm
   WHERE cm.case_type = 'MUR'
UNION
    SELECT DISTINCT am.mur_id AS case_id,
                    am.mur_number AS case_no,
                    am.mur_id AS case_serial,
                    'archived'::text AS mur_type
    FROM mur_arch.archived_murs am
;

-- grants
ALTER TABLE fecmur.arch_current_mur_sorting_vw OWNER TO fec;
GRANT ALL ON TABLE fecmur.arch_current_mur_sorting_vw TO fec;
GRANT SELECT ON TABLE fecmur.arch_current_mur_sorting_vw TO fec_read;
