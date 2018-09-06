/*
Issue #3359
Remove case_type = 'MUR' so we can include ADR and AF
*/

--TODO: Does schema fecmur still make sense here?

SET search_path = fecmur, pg_catalog;

CREATE OR REPLACE VIEW cases_with_parsed_case_serial_numbers AS
    SELECT "case".case_id,
        "case".case_no,
        (regexp_replace(("case".case_no)::text, '(\d+).*'::text, '\1'::text))::integer AS case_serial,
        "case".name,
        "case".case_type,
        "case".pg_date
    FROM "case"
    WHERE case_type IN ('MUR', 'AF', 'ADR');

ALTER TABLE cases_with_parsed_case_serial_numbers OWNER TO fec;
GRANT ALL ON TABLE cases_with_parsed_case_serial_numbers TO fec;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers TO fec_read;
GRANT SELECT ON TABLE cases_with_parsed_case_serial_numbers TO openfec_read;
