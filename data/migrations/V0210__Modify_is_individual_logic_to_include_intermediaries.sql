/*
This is to resolve issue #4453: Update is_individual function to include the new transaction codes 30E, 31E, 32E

According to @PaulClark2 we need to include transaction codes 24I/24T with entity_tp = 'IND'
to is_individual. They are considered individual contributions.

*/


CREATE OR REPLACE FUNCTION public.is_individual(amount numeric, receipt_type text, line_number text, memo_code text, memo_text text, entity_tp text)
 RETURNS boolean
AS 
$BODY$

begin

    return (

        is_coded_individual(receipt_type) or

        (entity_tp = 'IND' and coalesce(receipt_type, '') in ('24I', '24T')) or

        is_inferred_individual(amount, line_number, memo_code, memo_text)

    );

end

$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;

ALTER FUNCTION public.is_individual(numeric, text, text, text, text)
  OWNER TO fec; 




-- ------------------
-- trigger disclosure.fec_fitem_sched_a_insert()
-- ------------------

CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_a_insert()
  RETURNS trigger AS
$BODY$
begin

	new.pdf_url := image_pdf_url(new.image_num);
	new.contributor_name_text := to_tsvector(concat(parse_fulltext(new.contbr_nm), ' ', new.clean_contbr_id));
	new.contributor_employer_text := to_tsvector(parse_fulltext(new.contbr_employer));
	new.contributor_occupation_text := to_tsvector(parse_fulltext(new.contbr_occupation));
	new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text, new.entity_tp);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);

  return new;
  
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_a_insert()
  OWNER TO fec;