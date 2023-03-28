/*
This migration file is for issue #5208.

It creates a new view for the new inaugural committee donor totals endpoint

*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_inaugural_donations_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_totals_inaugural_donations_mv_tmp AS
 WITH inaugural_cmte_info AS (
    SELECT DISTINCT(cmte_id)
    FROM public.fec_form_13_vw
    )
SELECT
    contbr.cmte_id AS committee_id,
    contbr.contbr_nm AS contributor_name,
    contbr.two_year_transaction_period AS cycle,
    SUM(contb_receipt_amt) as total_donation
        FROM disclosure.fec_fitem_sched_a contbr
        WHERE cmte_id IN (SELECT cmte_id  FROM inaugural_cmte_info)
        GROUP by contbr.contbr_nm, contbr.cmte_id, contbr.two_year_transaction_period;

-- grant correct ownership/permission
ALTER TABLE public.ofec_totals_inaugural_donations_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_inaugural_donations_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_inaugural_donations_mv_tmp TO fec_read;

-- create index on the ofec_totals_inaugural_donations_mv_tmp MV
CREATE UNIQUE INDEX idx_ofec_totals_inaugural_donations_mv_tmp_cmte_id_contbr_nm_cycle ON public.ofec_totals_inaugural_donations_mv_tmp USING btree (committee_id, contributor_name, cycle);

CREATE INDEX idx_ofec_totals_inaugural_donations_mv_tmp_committee_id ON public.ofec_totals_inaugural_donations_mv_tmp USING btree (committee_id);

CREATE INDEX idx_ofec_totals_inaugural_donations_mv_tmp_contributor_name ON public.ofec_totals_inaugural_donations_mv_tmp USING btree (contributor_name);

CREATE INDEX idx_ofec_totals_inaugural_donations_mv_tmp_cycle ON public.ofec_totals_inaugural_donations_mv_tmp USING btree (cycle);

-- update the interface VW to point to the updated ofec_totals_inaugural_donations_mv_tmp MV
-- ---------------
CREATE OR REPLACE VIEW public.ofec_totals_inaugural_donations_vw AS
SELECT * FROM public.ofec_totals_inaugural_donations_mv_tmp;

-- grant correct ownership/permission
ALTER TABLE public.ofec_totals_inaugural_donations_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_inaugural_donations_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_inaugural_donations_vw TO fec_read;

-- DROP the original MV and rename the ofec_totals_inaugural_donations_mv_tmp to ofec_totals_inaugural_donations_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_inaugural_donations_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_inaugural_donations_mv_tmp RENAME TO ofec_totals_inaugural_donations_mv;

-- Alter index name to remove the _tmp
-- ---------------
ALTER INDEX public.idx_ofec_totals_inaugural_donations_mv_tmp_cmte_id_contbr_nm_cycle RENAME TO idx_ofec_totals_inaugural_donations_mv_cmte_id_contbr_nm_cycle;

ALTER INDEX public.idx_ofec_totals_inaugural_donations_mv_tmp_committee_id RENAME TO idx_ofec_totals_inaugural_donations_mv_committee_id;

ALTER INDEX public.idx_ofec_totals_inaugural_donations_mv_tmp_contributor_name RENAME TO idx_ofec_totals_inaugural_donations_mv_contributor_name;

ALTER INDEX public.idx_ofec_totals_inaugural_donations_mv_tmp_cycle  RENAME TO idx_ofec_totals_inaugural_donations_mv_cycle;
