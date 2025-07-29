/*
This is for issue #6290 Add views used by rulemaking endpoints
*/

-- rulemaking_vw 
CREATE OR REPLACE VIEW fosers.rulemaking_vw AS
    SELECT rm.id AS rm_id,
           rm.rm_number,
           substr(rm.rm_number::text, 5) AS rm_no,
           substr(rm.rm_number::text, 5, 4)::integer AS rm_year,
           substr(rm.rm_number::text, 10)::integer AS rm_serial,
           rm.title,
           substr(rm.title::text, 13) AS rm_name,
           rm.description,
           CASE
                WHEN COALESCE(rm.admin_close_date, rm.comment_close_date) IS NOT NULL 
                     AND (COALESCE(rm.admin_close_date, rm.comment_close_date) >= now() OR COALESCE(rm.admin_close_date, rm.comment_close_date)::date = CURRENT_DATE) 
                THEN true
                ELSE false
           END AS is_open_for_comment,
           COALESCE(rm.admin_close_date, rm.comment_close_date) AS calculated_comment_close_date,
           rm.admin_close_date,
           rm.comment_close_date,
           rm.sync_status,
           rm.last_updated
    FROM fosers.rulemaster rm
    WHERE rm.id > 0;

 -- grants   
ALTER TABLE fosers.rulemaking_vw OWNER TO fec;
GRANT ALL ON TABLE fosers.rulemaking_vw TO fec;
GRANT SELECT ON TABLE fosers.rulemaking_vw TO fec_read;


-- documents_vw
CREATE OR REPLACE VIEW fosers.documents_vw AS
    SELECT doc.id AS doc_id,
           doc.rm_id,
           doc.category AS doc_category_id,
           doc.description AS doc_description,
           rv.is_open_for_comment,
           CASE
               WHEN doc.category = 4 AND rv.is_open_for_comment = true AND (EXISTS ( SELECT DISTINCT 1
                                                                                       FROM fosers.calendar c
                                                                                      WHERE doc.rm_id = c.rm_id 
                                                                                       AND c.event_key IN (106881, 107212, 112434, 108851, 107093, 106993, 107034, 112451, 108818))) 
               THEN true
               ELSE false
           END AS is_comment_eligible,
           doc.date1 AS doc_date,
           doc.type_id AS doc_type_id,
           t.description AS doc_type_label,
           doc.filename,
           CASE
               WHEN doc.is_key_document = 1 THEN true
               ELSE false
            END AS is_key_document,
           t.level1 AS level_1,
           t.level2 AS level_2,
           doc.sort_order,
           o.ocrtext
    FROM fosers.documents doc
    JOIN fosers.rulemaking_vw rv ON doc.rm_id = rv.rm_id
    LEFT JOIN fosers.documents_ocrtext o ON doc.id = o.id
    LEFT JOIN fosers.tiermapping t ON doc.type_id = t.type_id
    WHERE doc.rm_id > 0;

-- grants
ALTER TABLE fosers.documents_vw OWNER TO fec;
GRANT ALL ON TABLE fosers.documents_vw TO fec;
GRANT SELECT ON TABLE fosers.documents_vw TO fec_read;