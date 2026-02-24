/*
This is for issue #6489, 6490. Add testify_flg to fosers.rulemaster table. 
Add comment_close_date, admin_close_date to documents tables
Modify the views
*/

ALTER TABLE fosers.rulemaster ADD column IF NOT EXISTS testify_flg bool;

ALTER TABLE fosers.documents ADD column IF NOT EXISTS  comment_close_date timestamp without time zone;

ALTER TABLE fosers.documents ADD column IF NOT EXISTS  admin_close_date timestamp without time zone;

--Drop fosers.documents_vw --
DROP VIEW fosers.documents_vw;

-- Add columns to documents_vw --
CREATE OR REPLACE VIEW fosers.documents_vw AS
SELECT doc.id AS doc_id,
       doc.rm_id,
       doc.category AS doc_category_id,
       doc.description AS doc_description,
	   doc.admin_close_date, 
	   doc.comment_close_date,
	   CASE
         WHEN COALESCE(doc.admin_close_date, doc.comment_close_date) IS NOT NULL AND (COALESCE(doc.admin_close_date, doc.comment_close_date) >= now() OR COALESCE(doc.admin_close_date, doc.comment_close_date)::date = CURRENT_DATE) THEN true
         ELSE false
       END AS is_open_for_comment,
	   COALESCE(doc.admin_close_date, doc.comment_close_date) AS calculated_comment_close_date,
       CASE
        WHEN doc.category = 4 
	     AND (COALESCE(doc.admin_close_date, doc.comment_close_date) IS NOT NULL AND (COALESCE(doc.admin_close_date, doc.comment_close_date) >= now() OR COALESCE(doc.admin_close_date, doc.comment_close_date)::date = CURRENT_DATE))
	     AND (EXISTS ( SELECT DISTINCT 1
                 FROM fosers.calendar c
                 WHERE doc.rm_id = c.rm_id AND (c.event_key = ANY (ARRAY[106881, 107212, 112434, 108851, 107093, 106993, 107034, 112451, 108818])))) 
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
       o.ocrtext,
       doc.contents,
       doc.pg_date
FROM fosers.documents doc
LEFT JOIN fosers.documents_ocrtext o ON doc.id = o.id
LEFT JOIN fosers.tiermapping t ON doc.type_id = t.type_id
WHERE doc.rm_id > 0;

-- grants 
ALTER TABLE fosers.documents_vw OWNER TO fec;
GRANT ALL ON TABLE fosers.documents_vw TO fec;
GRANT SELECT ON TABLE fosers.documents_vw TO fec_read;  

--Drop rulemaking_vw
DROP VIEW fosers.rulemaking_vw;

--- Add testify_flg to rulemaking_vw
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
            WHEN COALESCE(rm.admin_close_date, rm.comment_close_date) IS NOT NULL AND (COALESCE(rm.admin_close_date, rm.comment_close_date) >= now() OR COALESCE(rm.admin_close_date, rm.comment_close_date)::date = CURRENT_DATE) THEN true
            ELSE false
        END AS is_open_for_comment,
    COALESCE(rm.admin_close_date, rm.comment_close_date) AS calculated_comment_close_date,
    rm.admin_close_date,
    rm.comment_close_date,
    rm.sync_status,
    rm.last_updated,
    rm.published_flg,
	testify_flg,
    rm.pg_date
FROM fosers.rulemaster rm
WHERE rm.id > 0;

-- grants
ALTER TABLE fosers.rulemaking_vw OWNER TO fec;
GRANT ALL ON TABLE fosers.rulemaking_vw TO fec;
GRANT SELECT ON TABLE fosers.rulemaking_vw TO fec_read;