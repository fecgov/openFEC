/*
This is for issue #6213 Add published_flg to ao table and its view. 
This column will be used as filter to only show published aos on /legal/
*/

ALTER TABLE aouser.ao add column if not exists published_flg bool default true;

CREATE OR REPLACE VIEW aouser.aos_with_parsed_numbers AS 
 SELECT ao.ao_id,
    ao.ao_no,
    regexp_replace(ao.ao_no::text, '(\d+)-(\d+)'::text, '\1'::text)::integer AS ao_year,
    regexp_replace(ao.ao_no::text, '(\d+)-(\d+)'::text, '\2'::text)::integer AS ao_serial,
    ao.name,
    ao.summary,
    ao.req_date,
    ao.issue_date,
    ao.pg_date,
    ao.published_flg
 FROM aouser.ao;

ALTER TABLE aouser.aos_with_parsed_numbers OWNER TO fec;

GRANT ALL ON TABLE aouser.aos_with_parsed_numbers TO fec;
GRANT SELECT ON TABLE aouser.aos_with_parsed_numbers TO fec_read;
GRANT SELECT ON TABLE aouser.aos_with_parsed_numbers TO aomur_usr;
