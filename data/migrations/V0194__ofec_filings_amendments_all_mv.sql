/*
This migration file is for #4276
delete ofec_amendments_mv and ofec_amendments_vw
refactor public.ofec_filings_amendments_all_mv

In line 87, operator / is added to make sure the type of mst_rct_file_num is numeric,
Otherwise, public.ofec_filings_amendments_all_vw has to be dropped first.
But there is a dependency on this view from ofec_filings_all_mv
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_amendments_all_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_filings_amendments_all_mv_tmp AS
 WITH combined AS (
        SELECT 
            row_number() OVER () AS idx,
            ofec_processed_financial_amendment_chain_vw.cand_cmte_id,
            ofec_processed_financial_amendment_chain_vw.rpt_yr,
            ofec_processed_financial_amendment_chain_vw.rpt_tp,
            ofec_processed_financial_amendment_chain_vw.amndt_ind,
            ofec_processed_financial_amendment_chain_vw.receipt_date,
            ofec_processed_financial_amendment_chain_vw.file_num,
            ofec_processed_financial_amendment_chain_vw.prev_file_num,
            ofec_processed_financial_amendment_chain_vw.mst_rct_file_num,
            ofec_processed_financial_amendment_chain_vw.amendment_chain
           FROM public.ofec_processed_financial_amendment_chain_vw
        UNION ALL
        SELECT
            row_number() OVER () AS idx,
            ofec_non_financial_amendment_chain_vw.cand_cmte_id,
            ofec_non_financial_amendment_chain_vw.rpt_yr,
            ofec_non_financial_amendment_chain_vw.rpt_tp,
            ofec_non_financial_amendment_chain_vw.amndt_ind,
            ofec_non_financial_amendment_chain_vw.receipt_date,
            ofec_non_financial_amendment_chain_vw.file_num,
            ofec_non_financial_amendment_chain_vw.prev_file_num,
            ofec_non_financial_amendment_chain_vw.mst_rct_file_num,
            ofec_non_financial_amendment_chain_vw.amendment_chain
           FROM public.ofec_non_financial_amendment_chain_vw
        UNION ALL
        SELECT 
            ofec_presidential_paper_amendments_vw.idx,
            ofec_presidential_paper_amendments_vw.cmte_id,
            ofec_presidential_paper_amendments_vw.rpt_yr,
            ofec_presidential_paper_amendments_vw.rpt_tp,
            ofec_presidential_paper_amendments_vw.amndt_ind,
            ofec_presidential_paper_amendments_vw.receipt_dt,
            ofec_presidential_paper_amendments_vw.file_num,
            ofec_presidential_paper_amendments_vw.prev_file_num,
            ofec_presidential_paper_amendments_vw.mst_rct_file_num,
            ofec_presidential_paper_amendments_vw.amendment_chain
           FROM public.ofec_presidential_paper_amendments_vw
        UNION ALL
         SELECT 
            ofec_house_senate_paper_amendments_vw.idx,
            ofec_house_senate_paper_amendments_vw.cmte_id,
            ofec_house_senate_paper_amendments_vw.rpt_yr,
            ofec_house_senate_paper_amendments_vw.rpt_tp,
            ofec_house_senate_paper_amendments_vw.amndt_ind,
            ofec_house_senate_paper_amendments_vw.receipt_dt,
            ofec_house_senate_paper_amendments_vw.file_num,
            ofec_house_senate_paper_amendments_vw.prev_file_num,
            ofec_house_senate_paper_amendments_vw.mst_rct_file_num,
            ofec_house_senate_paper_amendments_vw.amendment_chain
           FROM public.ofec_house_senate_paper_amendments_vw
        UNION ALL
         SELECT 
            ofec_pac_party_paper_amendments_vw.idx,
            ofec_pac_party_paper_amendments_vw.cmte_id,
            ofec_pac_party_paper_amendments_vw.rpt_yr,
            ofec_pac_party_paper_amendments_vw.rpt_tp,
            ofec_pac_party_paper_amendments_vw.amndt_ind,
            ofec_pac_party_paper_amendments_vw.receipt_dt,
            ofec_pac_party_paper_amendments_vw.file_num,
            ofec_pac_party_paper_amendments_vw.prev_file_num,
            ofec_pac_party_paper_amendments_vw.mst_rct_file_num,
            ofec_pac_party_paper_amendments_vw.amendment_chain
           FROM public.ofec_pac_party_paper_amendments_vw
        )
 SELECT row_number() OVER () AS idx2,
    combined.idx,
    combined.cand_cmte_id,
    combined.rpt_yr,
    combined.rpt_tp,
    combined.amndt_ind,
    combined.receipt_date,
    combined.file_num,
    combined.prev_file_num,
    combined.mst_rct_file_num/1 AS mst_rct_file_num,
    combined.amendment_chain
   FROM combined
  WITH DATA;

ALTER TABLE public.ofec_filings_amendments_all_mv_tmp OWNER TO fec;

GRANT SELECT ON public.ofec_filings_amendments_all_mv_tmp TO fec_read;

--indices--
CREATE INDEX idx_ofec_filings_amendments_all_mv_tmp_file_num
    ON public.ofec_filings_amendments_all_mv_tmp USING btree (file_num);

CREATE UNIQUE INDEX idx_ofec_filings_amendments_all_mv_tmp_idx 
    ON public.ofec_filings_amendments_all_mv_tmp USING btree (idx2);

--view--
CREATE OR REPLACE VIEW public.ofec_filings_amendments_all_vw AS
    SELECT * FROM public.ofec_filings_amendments_all_mv_tmp;

ALTER VIEW public.ofec_filings_amendments_all_vw OWNER TO fec;

GRANT SELECT ON public.ofec_filings_amendments_all_vw TO fec_read;

-- drop the original mv
-- rename the ofec_xxxxxxx_mv_tmp to ofec_xxxxxxx_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_amendments_all_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_filings_amendments_all_mv_tmp RENAME TO ofec_filings_amendments_all_mv;


-- rename index
ALTER INDEX IF EXISTS idx_ofec_filings_amendments_all_mv_tmp_file_num
    RENAME TO idx_ofec_filings_amendments_all_mv_file_num;
ALTER INDEX IF EXISTS idx_ofec_filings_amendments_all_mv_tmp_idx
    RENAME TO idx_ofec_filings_amendments_all_mv_idx;

-- drop unused mv and view
DROP VIEW IF EXISTS public.ofec_amendments_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_amendments_mv;

DROP VIEW IF EXISTS public.ofec_processed_non_financial_amendment_chain_vw;
