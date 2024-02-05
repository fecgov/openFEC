/*
This is to resolve issue #4322: Update is_individual function to include the new transaction codes 30E, 31E, 32E

Request from EFO to add new transaction code 30E, 31E, 32E:
insert into STAGING.REF_TRAN_CODE (tran_code, tran_code_desc) VALUES ('30E', 'EARMARK – CONVENTION');
insert into STAGING.REF_TRAN_CODE (tran_code, tran_code_desc) VALUES ('31E', 'EARMARKED – HEADQUARTERS');
insert into STAGING.REF_TRAN_CODE (tran_code, tran_code_desc) VALUES ('32E', 'EARMARKED – RECOUNT');

According to @PaulClark2 we need to add the new transaction codes to is_individual . They are considered individual contributions.

There is no data using this three code yet so there is no need to reload fec_fitem_sched_a tables (resource intensive).  
*/
/*
public.is_individual is calling function is_coded_individual(receipt_type) to to filter the coded individual.  Adds these 3 new codes in the list to be included.
*/

CREATE OR REPLACE FUNCTION public.is_coded_individual(receipt_type text)
  RETURNS boolean AS
$BODY$

begin

    return coalesce(receipt_type, '') in ('10', '15', '15E', '15J', '30', '30T', '31', '31T', '32', '10J', '11', '11J', '30J', '31J', '32T', '32J', '30E', '31E', '32E');

end

$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;

ALTER FUNCTION public.is_coded_individual(text)
  OWNER TO fec;
