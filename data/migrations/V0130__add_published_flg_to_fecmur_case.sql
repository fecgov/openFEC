/*
This is for issue #3573 Add filter to only show published cases on /legal/
*/

ALTER TABLE fecmur.case add column if not exists published_flg bool default true;


CREATE OR REPLACE VIEW fecmur.cases_with_parsed_case_serial_numbers_vw AS 
 SELECT "case".case_id,
    "case".case_no,
    regexp_replace("case".case_no::text, '(\d+).*'::text, '\1'::text)::integer AS case_serial,
    "case".name,
    "case".case_type,
    "case".pg_date,
    "case".published_flg 
   FROM fecmur."case"
  WHERE "case".case_type::text = ANY (ARRAY['MUR'::character varying, 'AF'::character varying, 'ADR'::character varying]::text[]);

ALTER TABLE fecmur.cases_with_parsed_case_serial_numbers_vw
  OWNER TO fec;
GRANT ALL ON TABLE fecmur.cases_with_parsed_case_serial_numbers_vw TO fec;
GRANT SELECT ON TABLE fecmur.cases_with_parsed_case_serial_numbers_vw TO fec_read;
GRANT SELECT ON TABLE fecmur.cases_with_parsed_case_serial_numbers_vw TO openfec_read;
