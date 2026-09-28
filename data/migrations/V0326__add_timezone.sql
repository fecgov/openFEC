/*
This is for issue #6726. Add time zone specification to now() function in both views
*/

-- Add time zone to documents_vw --
CREATE OR REPLACE VIEW fosers.documents_vw
 AS
 SELECT doc.id AS doc_id,
    doc.rm_id,
    doc.category AS doc_category_id,
    doc.description AS doc_description,
    doc.admin_close_date,
    doc.comment_close_date,
    (COALESCE(doc.admin_close_date, doc.comment_close_date) >= (now() AT TIME ZONE 'America/New_York'::text)) IS TRUE AS is_open_for_comment,
    COALESCE(doc.admin_close_date, doc.comment_close_date) AS calculated_comment_close_date,
        CASE
            WHEN doc.category = 4 AND COALESCE(doc.admin_close_date, doc.comment_close_date) IS NOT NULL AND COALESCE(doc.admin_close_date, doc.comment_close_date) >= (now() AT TIME ZONE 'America/New_York'::text) AND (EXISTS ( SELECT 1
               FROM fosers.calendar c
              WHERE c.rm_id = doc.rm_id AND (c.event_key = ANY (ARRAY[106881, 107212, 112434, 108851, 107093, 106993, 107034, 112451, 108818])))) THEN true
            ELSE false
        END AS is_comment_eligible,
    doc.date1 AS doc_date,
    doc.type_id AS doc_type_id,
    t.description AS doc_type_label,
    doc.filename,
    doc.is_key_document = 1 AS is_key_document,
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


--- Add time zone to rulemaking_vw
CREATE OR REPLACE VIEW fosers.rulemaking_vw AS
SELECT rm.id AS rm_id,
    rm.rm_number,
    substr(rm.rm_number::text, 5) AS rm_no,
    substr(rm.rm_number::text, 5, 4)::integer AS rm_year,
    substr(rm.rm_number::text, 10)::integer AS rm_serial,
    rm.title,
    substr(rm.title::text, 13) AS rm_name,
    rm.description,
    (COALESCE(rm.admin_close_date, rm.comment_close_date) >= (now() AT TIME ZONE 'America/New_York'::text)) IS TRUE AS is_open_for_comment,
    COALESCE(rm.admin_close_date, rm.comment_close_date) AS calculated_comment_close_date,
    rm.admin_close_date,
    rm.comment_close_date,
    rm.sync_status,
    rm.last_updated,
    rm.published_flg,
    rm.testify_flg,
    rm.pg_date
   FROM fosers.rulemaster rm
  WHERE rm.id > 0;

--Add index--
CREATE INDEX IF NOT EXISTS idx_calendar_rm_id_event_key
    ON fosers.calendar USING btree
    (rm_id, event_key)
;