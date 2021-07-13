/*
This is for issue #4896 Add table: af_number_rad_civil_pnlty_updt
Thia table is manually created in database in advance, and a copy of script is kept in migration
*/

CREATE TABLE IF NOT EXISTS fecmur.af_number_rad_civil_pnlty_updt
 (
    af_number_rad character varying(10),
    civil_penalty_date date,
    civil_penalty_status character varying(100) 
);

ALTER TABLE fecmur.af_number_rad_civil_pnlty_updt
    OWNER to fec;

GRANT UPDATE, DELETE, INSERT, SELECT, TRUNCATE ON TABLE fecmur.af_number_rad_civil_pnlty_updt TO aomur_usr;

GRANT ALL ON TABLE fecmur.af_number_rad_civil_pnlty_updt TO fec;

GRANT SELECT ON TABLE fecmur.af_number_rad_civil_pnlty_updt TO fec_read;

GRANT SELECT ON TABLE fecmur.af_number_rad_civil_pnlty_updt TO openfec_read;
