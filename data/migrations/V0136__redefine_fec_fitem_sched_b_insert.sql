
/*
column election_cycle and two_year_transaction_period in public.ofec_sched_b_master tables has exactly the same data
So disclosure.fec_fitem_sched_b does not add the extra column two_year_transaction_period
However, since existing API referencing column two_year_transaction_period a lot, rename election_cycle to two_year_transaction_period
  to mitigate impact to API when switching from using public.ofec_sched_b_master tables to disclosure.fec_fitem_sched_b table

redefine *._text triggers to replace all non-word characters with ' ' for better search specificity.
*/

-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_b
-- ----------------------------
-- ----------------------------

DO $$
BEGIN
    EXECUTE format('alter table disclosure.fec_fitem_sched_b rename column election_cycle to two_year_transaction_period');
    EXCEPTION 
             WHEN undefined_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



/*
The calculation of value for recipient_name_text in both public.ofec_sched_b and disclosure.fec_fitem_sched_b are slightly incorrect.
It should use clean_recipient_cmte_id instead of recipient_cmte_id.
*/

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_b_insert()
  RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.disbursement_description_text := to_tsvector(regexp_replace(new.disb_desc, '[^a-zA-Z0-9]', ' ', 'g'));
	new.recipient_name_text := to_tsvector(concat(regexp_replace(new.recipient_nm, '[^a-zA-Z0-9]', ' ', 'g'), ' ', new.clean_recipient_cmte_id));
	new.disbursement_purpose_category := disbursement_purpose(new.disb_tp, new.disb_desc);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_b_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_b ON disclosure.fec_fitem_sched_b;

CREATE TRIGGER tri_fec_fitem_sched_b
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();


-- ----------------------------
-- ----------------------------
-- disclosure.fec_fitem_sched_f
-- ----------------------------
-- ----------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_f ADD COLUMN payee_name_text tsvector');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_f_insert()
  RETURNS trigger AS
$BODY$
begin
	new.payee_name_text := to_tsvector(regexp_replace(new.pye_nm::text, '[^a-zA-Z0-9]', ' ', 'g'));

    	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_f_insert()
  OWNER TO fec;

DROP TRIGGER IF EXISTS tri_fec_fitem_sched_f ON disclosure.fec_fitem_sched_f;

CREATE TRIGGER tri_fec_fitem_sched_f
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_f
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_f_insert();

/*

update to_tsvector to confirm to new search functionality (omit special characters, replace with whitespace, vectorize)
*/

SET search_path = public;

DROP MATERIALIZED VIEW ofec_rad_mv;

DROP FUNCTION IF EXISTS fix_party_spelling(branch text);

----

SET search_path = disclosure, pg_catalog;

DROP VIEW rad_cmte_analyst_search_vw;

---

SET search_path = public;

CREATE VIEW ofec_rad_analyst_vw AS
    SELECT row_number() OVER () AS idx,
        ra.cmte_id AS committee_id,
        cv.cmte_nm AS committee_name,
        an.anlyst_id AS analyst_id,
        (an.valid_id::numeric) AS analyst_short_id,
        CASE
            WHEN an.branch_id = 1 THEN 'Authorized'
            WHEN an.branch_id = 2 THEN 'Party/Non Party'
            ELSE NULL::text
        END AS rad_branch,
        an.firstname AS first_name,
        an.lastname AS last_name,
        to_tsvector(((regexp_replace(an.firstname, '[^a-zA-Z0-9]', ' ', 'g')::text || ' '::text) || regexp_replace(an.lastname, '[^a-zA-Z0-9]', ' ', 'g')::text)) AS name_txt,
        an.telephone_ext,
        t.anlyst_title_desc AS analyst_title,
        an.email AS analyst_email,
        ra.last_rp_change_dt AS assignment_update
    FROM rad_pri_user.rad_anlyst an
    JOIN rad_pri_user.rad_assgn ra
        ON an.anlyst_id = ra.anlyst_id
    JOIN disclosure.cmte_valid_fec_yr cv
        ON ra.cmte_id = cv.cmte_id
    JOIN rad_pri_user.rad_lkp_anlyst_title t
        ON an.anlyst_title_seq = t.anlyst_title_seq
    WHERE an.status_id = 1
        AND an.anlyst_id <> 999
        AND cv.fec_election_yr = get_cycle(date_part('year', current_date)::integer);

ALTER TABLE ofec_rad_analyst_vw OWNER TO fec;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO fec_read;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO openfec_read;
