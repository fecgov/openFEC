/*
This is part of migration files solving issues #3925
House and Senate candidate committees supposed to report their financial activity by
cmte_tp = H/S (filed F3)
However, sometimes candidate committees filed incorrect F3* forms.  

The source of this MV is ofec_totals_combined_vw, separated by Form_type F3.
This will miss F3P/F3X filed by house and Senate candidate committees.

This migration file update the definition to takes 
all F3* forms (candidate committees also files other forms such as F10, F11, F12, F5)
filed by cmte_dsgn P/A (exclude J, D, etc) house and Senate candidate committees ('H','S')
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_totals_house_senate_mv_tmp AS 
WITH hs_cycle AS 
(
        SELECT DISTINCT ON (cmte_id, fec_election_yr) cmte_id AS committee_id,
        election_yr_to_be_included as cand_election_yr,
        fec_election_yr AS cycle
        FROM ofec_cand_cmte_linkage_mv
        where cmte_tp in ('H','S')
        and cmte_dsgn in ('P','A')
        and election_yr_to_be_included is not null
        ORDER BY cmte_id, fec_election_yr, election_yr_to_be_included
)
SELECT f3.candidate_id,
    f3.cycle,
    f3.sub_id AS idx,
    f3.committee_id,
    hs_cycle.cand_election_yr AS election_cycle,
    f3.coverage_start_date,
    f3.coverage_end_date,
    f3.all_other_loans,
    f3.candidate_contribution,
    f3.contribution_refunds,
    f3.contributions,
    f3.disbursements,
    f3.individual_contributions,
    f3.individual_itemized_contributions,
    f3.individual_unitemized_contributions,
    f3.loan_repayments,
    f3.loan_repayments_candidate_loans,
    f3.loan_repayments_other_loans,
    f3.loans,
    f3.loans_made_by_candidate,
    f3.net_contributions,
    f3.net_operating_expenditures,
    f3.offsets_to_operating_expenditures,
    f3.operating_expenditures,
    f3.other_disbursements,
    f3.other_political_committee_contributions,
    f3.other_receipts,
    f3.political_party_committee_contributions,
    f3.receipts,
    f3.refunded_individual_contributions,
    f3.refunded_other_political_committee_contributions,
    f3.refunded_political_party_committee_contributions,
    f3.transfers_from_other_authorized_committee,
    f3.transfers_to_other_authorized_committee,
    f3.last_report_type_full,
    f3.last_beginning_image_number,
    f3.cash_on_hand_beginning_period,
    f3.last_cash_on_hand_end_period,
    f3.last_debts_owed_by_committee,
    f3.last_debts_owed_to_committee,
    f3.last_report_year,
    f3.committee_name,
    f3.committee_type,
    f3.committee_designation,
    f3.committee_type_full,
    f3.committee_designation_full,
    f3.party_full
FROM ofec_totals_combined_vw f3
    LEFT JOIN hs_cycle USING (committee_id, cycle)
WHERE f3.form_type in ('F3', 'F3P', 'F3X')
AND f3.committee_type in ('H','S')
AND f3.committee_designation in ('P','A')
WITH DATA;

--Permissions
ALTER TABLE public.ofec_totals_house_senate_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_mv_tmp TO fec_read;

--Indexes
CREATE UNIQUE INDEX idx_ofec_totals_house_senate_mv_tmp_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cand_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default", idx);


CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_id COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_tp_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_type_full COLLATE pg_catalog."default", idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, committee_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_designation_full COLLATE pg_catalog."default", idx);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_totals_house_senate_vw AS 
SELECT * FROM public.ofec_totals_house_senate_mv_tmp;
-- ---------------
ALTER TABLE public.ofec_totals_house_senate_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_totals_house_senate_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp RENAME TO ofec_totals_house_senate_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cand_id_idx RENAME TO idx_ofec_totals_house_senate_mv_cand_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx RENAME TO idx_ofec_totals_house_senate_mv_cmte_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id RENAME TO idx_ofec_totals_house_senate_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_idx RENAME TO idx_ofec_totals_house_senate_mv_cycle_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx RENAME TO idx_ofec_totals_house_senate_mv_cmte_dsgn_full_idx;
