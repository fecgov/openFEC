
/*
column election_cycle and two_year_transaction_period in public.ofec_sched_b_master tables has exactly the same data
So disclosure.fec_fitem_sched_b does not add the extra column two_year_transaction_period
However, since existing API referencing column two_year_transaction_period a lot, rename election_cycle to two_year_transaction_period
  to mitigate impact to API when switching from using public.ofec_sched_b_master tables to disclosure.fec_fitem_sched_b table
*/

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
