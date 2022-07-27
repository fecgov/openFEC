/*
This is migration is for issue #5160
Add one tsvector fulltext column : filer_name_text
Add idx_ofec_reports_pac_party_mv_filer_name_text in public.ofec_reports_pac_party_mv

-- Previous mv is V0148
*/
-- -----------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_reports_pac_party_mv_tmp AS
    SELECT row_number() OVER () AS idx,
        rpt.committee_id,
        rpt.cycle,
        rpt.coverage_start_date,
        rpt.coverage_end_date,
        rpt.all_loans_received_period,
        rpt.all_loans_received_ytd,
        rpt.allocated_federal_election_levin_share_period,
        rpt.beginning_image_number,
        rpt.calendar_ytd,
        rpt.cash_on_hand_beginning_calendar_ytd,
        rpt.cash_on_hand_beginning_period,
        rpt.cash_on_hand_close_ytd,
        rpt.cash_on_hand_end_period,
        rpt.coordinated_expenditures_by_party_committee_period,
        rpt.coordinated_expenditures_by_party_committee_ytd,
        rpt.debts_owed_by_committee,
        rpt.debts_owed_to_committee,
        rpt.end_image_number,
        rpt.fed_candidate_committee_contribution_refunds_ytd,
        rpt.fed_candidate_committee_contributions_period,
        rpt.fed_candidate_committee_contributions_ytd,
        rpt.fed_candidate_contribution_refunds_period,
        rpt.independent_expenditures_period,
        rpt.independent_expenditures_ytd,
        rpt.refunded_individual_contributions_period,
        rpt.refunded_individual_contributions_ytd,
        rpt.individual_itemized_contributions_period,
        rpt.individual_itemized_contributions_ytd,
        rpt.individual_unitemized_contributions_period,
        rpt.individual_unitemized_contributions_ytd,
        rpt.loan_repayments_made_period,
        rpt.loan_repayments_made_ytd,
        rpt.loan_repayments_received_period,
        rpt.loan_repayments_received_ytd,
        rpt.loans_made_period,
        rpt.loans_made_ytd,
        rpt.net_contributions_period,
        rpt.net_contributions_ytd,
        rpt.net_operating_expenditures_period,
        rpt.net_operating_expenditures_ytd,
        rpt.non_allocated_fed_election_activity_period,
        rpt.non_allocated_fed_election_activity_ytd,
        rpt.nonfed_share_allocated_disbursements_period,
        rpt.offsets_to_operating_expenditures_period,
        rpt.offsets_to_operating_expenditures_ytd,
        rpt.other_disbursements_period,
        rpt.other_disbursements_ytd,
        rpt.other_fed_operating_expenditures_period,
        rpt.other_fed_operating_expenditures_ytd,
        rpt.other_fed_receipts_period,
        rpt.other_fed_receipts_ytd,
        rpt.refunded_other_political_committee_contributions_period,
        rpt.refunded_other_political_committee_contributions_ytd,
        rpt.other_political_committee_contributions_period,
        rpt.other_political_committee_contributions_ytd,
        rpt.refunded_political_party_committee_contributions_period,
        rpt.refunded_political_party_committee_contributions_ytd,
        rpt.political_party_committee_contributions_period,
        rpt.political_party_committee_contributions_ytd,
        rpt.report_year,
        rpt.shared_fed_activity_nonfed_ytd,
        rpt.shared_fed_activity_period,
        rpt.shared_fed_activity_ytd,
        rpt.shared_fed_operating_expenditures_period,
        rpt.shared_fed_operating_expenditures_ytd,
        rpt.shared_nonfed_operating_expenditures_period,
        rpt.shared_nonfed_operating_expenditures_ytd,
        rpt.subtotal_summary_page_period,
        rpt.subtotal_summary_ytd,
        rpt.total_contribution_refunds_period,
        rpt.total_contribution_refunds_ytd,
        rpt.total_contributions_period,
        rpt.total_contributions_ytd,
        rpt.total_disbursements_period,
        rpt.total_disbursements_ytd,
        rpt.total_fed_disbursements_period,
        rpt.total_fed_disbursements_ytd,
        rpt.total_fed_election_activity_period,
        rpt.total_fed_election_activity_ytd,
        rpt.total_fed_operating_expenditures_period,
        rpt.total_fed_operating_expenditures_ytd,
        rpt.total_fed_receipts_period,
        rpt.total_fed_receipts_ytd,
        rpt.total_individual_contributions_period,
        rpt.total_individual_contributions_ytd,
        rpt.total_nonfed_transfers_period,
        rpt.total_nonfed_transfers_ytd,
        rpt.total_operating_expenditures_period,
        rpt.total_operating_expenditures_ytd,
        rpt.total_receipts_period,
        rpt.total_receipts_ytd,
        rpt.transfers_from_affiliated_party_period,
        rpt.transfers_from_affiliated_party_ytd,
        rpt.transfers_from_nonfed_account_period,
        rpt.transfers_from_nonfed_account_ytd,
        rpt.transfers_from_nonfed_levin_period,
        rpt.transfers_from_nonfed_levin_ytd,
        rpt.transfers_to_affiliated_committee_period,
        rpt.transfers_to_affilitated_committees_ytd,
        rpt.form_tp,
        rpt.report_type,
        rpt.report_type_full,
        rpt.is_amended,
        rpt.receipt_date,
        rpt.file_number,
        rpt.amendment_indicator,
        rpt.amendment_indicator_full,
        rpt.means_filed,
        rpt.html_url,
        rpt.fec_url,
        amendments.amendment_chain,
        amendments.prev_file_num AS previous_file_number,
        amendments.mst_rct_file_num AS most_recent_file_number,
        is_most_recent(rpt.file_number::integer, amendments.mst_rct_file_num::integer) AS most_recent,
        rpt.committee_name,
        to_tsvector(parse_fulltext(rpt.committee_name)) as filer_name_text
    FROM ofec_pac_party_report_vw rpt
    LEFT JOIN ofec_filings_amendments_all_vw amendments ON rpt.file_number = amendments.file_num
WITH DATA;

ALTER TABLE public.ofec_reports_pac_party_mv_tmp
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_reports_pac_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_reports_pac_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_reports_pac_party_mv_tmp_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_beg_image_num_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (beginning_image_number COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cmte_id_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (committee_id COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cvg_end_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (coverage_end_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cvg_start_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (coverage_start_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cyc_cmte_id
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (cycle, committee_id COLLATE pg_catalog."default");
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_cyc_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (cycle, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_ie_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (independent_expenditures_period, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_is_amen_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (is_amended, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rcpt_date_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (receipt_date, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rpt_type_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (report_type COLLATE pg_catalog."default", idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_rpt_year_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (report_year, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_tot_disb_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (total_disbursements_period, idx);
    
CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_tot_rcpt_period_idx
    ON public.ofec_reports_pac_party_mv_tmp
    USING btree
    (total_receipts_period, idx);

CREATE INDEX idx_ofec_reports_pac_party_mv_tmp_filer_name_text
    ON public.ofec_reports_pac_party_mv_tmp
    USING gin
    (filer_name_text);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_reports_pac_party_vw AS 
  SELECT * FROM public.ofec_reports_pac_party_mv_tmp;
-- ---------------


-- drop old MV:ofec_reports_pac_party_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv;


-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_reports_pac_party_mv_tmp 
  RENAME TO ofec_reports_pac_party_mv;


-- rename all indexes
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_idx RENAME TO idx_ofec_reports_pac_party_mv_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_beg_image_num_idx RENAME TO idx_ofec_reports_pac_party_mv_beg_image_num_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cmte_id_idx RENAME TO idx_ofec_reports_pac_party_mv_cmte_id_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cvg_end_date_idx RENAME TO idx_ofec_reports_pac_party_mv_cvg_end_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cvg_start_date_idx RENAME TO idx_ofec_reports_pac_party_mv_cvg_start_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cyc_cmte_id RENAME TO idx_ofec_reports_pac_party_mv_cyc_cmte_id;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_cyc_idx RENAME TO idx_ofec_reports_pac_party_mv_cyc_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_ie_period_idx RENAME TO idx_ofec_reports_pac_party_mv_ie_period_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_is_amen_idx RENAME TO idx_ofec_reports_pac_party_mv_is_amen_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rcpt_date_idx RENAME TO idx_ofec_reports_pac_party_mv_rcpt_date_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rpt_type_idx RENAME TO idx_ofec_reports_pac_party_mv_rpt_type_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_rpt_year_idx RENAME TO idx_ofec_reports_pac_party_mv_rpt_year_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_tot_disb_period_idx RENAME TO idx_ofec_reports_pac_party_mv_tot_disb_period_idx;
    
ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_tot_rcpt_period_idx RENAME TO idx_ofec_reports_pac_party_mv_tot_rcpt_period_idx;

ALTER INDEX public.idx_ofec_reports_pac_party_mv_tmp_filer_name_text RENAME TO idx_ofec_reports_pac_party_mv_filer_name_text;
