/*
Issue #2993
PR #3010
Filter existing view cases_with_parsed_case_serial_numbers
    by case_type = 'MUR'
*/

SET search_path = fecmur, pg_catalog;

DROP VIEW IF EXISTS cases_with_parsed_case_serial_numbers_tmp;

CREATE VIEW cases_with_parsed_case_serial_numbers_tmp AS

SELECT "case".case_id,
    "case".case_no,
    (regexp_replace(("case".case_no)::text, '(\d+).*'::text, '\1'::text))::integer AS case_serial,
    "case".name,
    "case".case_type,
    "case".pg_date
FROM "case"
WHERE case_type = 'MUR';

ALTER TABLE cases_with_parsed_case_serial_numbers_tmp OWNER TO fec;
GRANT ALL ON TABLE cases_with_parsed_case_serial_numbers_tmp TO fec;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers_tmp TO fec_read;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers_tmp TO openfec_read;

--------------------------------------------------------

DROP VIEW IF EXISTS cases_with_parsed_case_serial_numbers;

ALTER VIEW IF EXISTS cases_with_parsed_case_serial_numbers_tmp RENAME TO cases_with_parsed_case_serial_numbers;
