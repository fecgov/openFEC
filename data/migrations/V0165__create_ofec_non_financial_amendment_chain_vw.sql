/*
This migration file is for #3946
Create amendment chain view for all F1, F1M and F2 
*/

DROP VIEW IF EXISTS public.ofec_non_financial_amendment_chain_vw;

CREATE OR REPLACE VIEW public.ofec_non_financial_amendment_chain_vw AS
  SELECT f_rpt_or_form_sub.cand_cmte_id,
         f_rpt_or_form_sub.rpt_yr,
         f_rpt_or_form_sub.rpt_tp,
         f_rpt_or_form_sub.amndt_ind,
         f_rpt_or_form_sub.receipt_dt::text::date AS receipt_date,
         f_rpt_or_form_sub.file_num,
         f_rpt_or_form_sub.prev_file_num,
         f_rpt_or_form_sub.form_tp AS form,
         last_value(f_rpt_or_form_sub.file_num) OVER candidate_committee_group_entire AS mst_rct_file_num,
         array_agg(f_rpt_or_form_sub.file_num) OVER candidate_committee_group_up_to_current AS amendment_chain,
         f_rpt_or_form_sub.sub_id
  FROM disclosure.f_rpt_or_form_sub
  WHERE f_rpt_or_form_sub.form_tp::text IN ('F1', 'F1M', 'F2') 
    AND f_rpt_or_form_sub.file_num IS NOT NULL
  WINDOW candidate_committee_group_entire AS (PARTITION BY f_rpt_or_form_sub.cand_cmte_id, f_rpt_or_form_sub.form_tp ORDER BY (ROW(f_rpt_or_form_sub.receipt_dt::text::date, f_rpt_or_form_sub.begin_image_num)) NULLS FIRST RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING), candidate_committee_group_up_to_current AS (PARTITION BY f_rpt_or_form_sub.cand_cmte_id, f_rpt_or_form_sub.form_tp ORDER BY (ROW(f_rpt_or_form_sub.receipt_dt::text::date, f_rpt_or_form_sub.begin_image_num)) NULLS FIRST);

ALTER TABLE public.ofec_non_financial_amendment_chain_vw
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_non_financial_amendment_chain_vw TO fec;
GRANT SELECT ON TABLE public.ofec_non_financial_amendment_chain_vw TO fec_read;
