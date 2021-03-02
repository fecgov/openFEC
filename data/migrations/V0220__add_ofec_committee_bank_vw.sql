-- create public.ofec_committee_bank_vw to store 
-- committees and their primary bank data
-- and additional bank names

DROP VIEW IF EXISTS public.ofec_committee_bank_vw;

CREATE OR REPLACE VIEW public.ofec_committee_bank_vw
AS
WITH bank AS
(
    SELECT sub_id, cmte_id, sec_bank_depository_nm
      FROM disclosure.nml_form_1
     WHERE sec_bank_depository_nm IS NOT NULL 
	   AND delete_ind IS NULL
    UNION
    SELECT link_id, cmte_id, bank_depository_nm
      FROM disclosure.nml_form_1s 
     WHERE bank_depository_nm IS NOT NULL
       AND delete_ind IS NULL
), bank_name_array AS 
(
    SELECT bank.sub_id, bank.cmte_id, array_agg(DISTINCT bank.sec_bank_depository_nm) AS additional_bank_names
      FROM bank
  GROUP BY bank.sub_id, bank.cmte_id
)
SELECT f1.sub_id,
       f1.cmte_id,
       f1.bank_depository_nm,
       f1.bank_depository_st1,
       f1.bank_depository_st2,
       f1.bank_depository_city,
       f1.bank_depository_st,
       f1.bank_depository_zip,
       b.additional_bank_names
  FROM disclosure.nml_form_1 f1
  LEFT JOIN bank_name_array b ON (f1.sub_id = b.sub_id)
  WHERE f1.delete_ind IS NULL;

ALTER TABLE public.ofec_committee_bank_vw OWNER TO fec;

GRANT ALL ON TABLE public.ofec_committee_bank_vw TO fec;
GRANT SELECT ON TABLE public.ofec_committee_bank_vw TO fec_read;
