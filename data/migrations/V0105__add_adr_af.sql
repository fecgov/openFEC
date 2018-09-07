/*
Issue #3359
Remove case_type = 'MUR' so we can include ADR and AF
*/

SET search_path = fecmur, pg_catalog;

CREATE OR REPLACE VIEW cases_with_parsed_case_serial_numbers_vw AS
    SELECT "case".case_id,
        "case".case_no,
        (regexp_replace(("case".case_no)::text, '(\d+).*'::text, '\1'::text))::integer AS case_serial,
        "case".name,
        "case".case_type,
        "case".pg_date
    FROM "case"
    WHERE case_type IN ('MUR', 'AF', 'ADR');

ALTER TABLE cases_with_parsed_case_serial_numbers_vw OWNER TO fec;
GRANT ALL ON TABLE cases_with_parsed_case_serial_numbers_vw TO fec;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers_vw TO fec_read;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers_vw TO openfec_read;

DROP VIEW cases_with_parsed_case_serial_numbers;
