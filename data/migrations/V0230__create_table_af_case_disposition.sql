-- -----------------------------------------------------
-- Add civil_penalty_due_date, civil_penalty_pymt_status_flg
-- columns on table: fecmur.af_case
-- -----------------------------------------------------

ALTER TABLE fecmur.af_case add column if not exists civil_penalty_due_date
        timestamp without time zone ;
ALTER TABLE fecmur.af_case add column if not exists civil_penalty_pymt_status_flg
        character varying(250) ;


-- -----------------------------------------------------
-- create table fecmur.af_case_disposition
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fecmur.af_case_disposition
(
    id numeric,
    af_case_number character varying(100),
    case_id numeric,
    description character varying(250),
    amount numeric,
    dates date,
    created_date timestamp without time zone,
    created_by character varying(100),
    updated_date timestamp without time zone,
    updated_by character varying(100)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE fecmur.af_case_disposition
    OWNER to fec;

GRANT UPDATE, DELETE, INSERT, SELECT, TRUNCATE ON TABLE fecmur.af_case_disposition TO aomur_usr;

GRANT ALL ON TABLE fecmur.af_case_disposition TO fec;

GRANT SELECT ON TABLE fecmur.af_case_disposition TO fec_read;

GRANT SELECT ON TABLE fecmur.af_case_disposition TO openfec_read;
