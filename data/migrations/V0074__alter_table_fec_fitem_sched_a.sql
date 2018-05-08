
/*
column election_cycle and two_year_transaction_period in public.ofec_sched_a_master tables has exactly the same data
So disclosure.fec_fitem_sched_a does not add the extra column two_year_transaction_period
However, since existing API referencing column two_year_transaction_period a lot, rename election_cycle to two_year_transaction_period
  to mitigate impact to API when switching from using public.ofec_sched_a_master tables to disclosure.fec_fitem_sched_a table
*/

DO $$
BEGIN
    EXECUTE format('alter table disclosure.fec_fitem_sched_a rename column election_cycle to two_year_transaction_period');
    EXCEPTION 
             WHEN undefined_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;





/*
The calculation of value for recipient_name_text in both public.ofec_sched_a and disclosure.fec_fitem_sched_a are slightly incorrect.
It should use clean_recipient_cmte_id instead of recipient_cmte_id.
*/
CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_a_insert()
    RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.contributor_name_text := to_tsvector(concat(new.contbr_nm,' ', new.clean_contbr_id));
	new.contributor_employer_text := to_tsvector(new.contbr_employer);
	new.contributor_occupation_text := to_tsvector(new.contbr_occupation);
	new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);

    return new;
end
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

ALTER FUNCTION disclosure.fec_fitem_sched_a_insert()
OWNER TO fec;
  
  
