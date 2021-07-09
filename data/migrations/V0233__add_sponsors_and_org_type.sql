/*
This migration file is for #4879

New fields/columns need to be at the end

1 - Modify `ofec_totals_combined_mv` and `ofec_totals_combined_vw` to add:
    `sponsor_candidate_ids`
    `organization_type`

    Replaces V0233

2 - Modify `ofec_totals_pac_party_vw` to add:
    `sponsor_candidate_ids`
    `organization_type`

    Replaces V0233

3 - Modify `ofec_committee_totals_per_cycle_vw` to add:
    `organization_type`

    Replaces V0233

4 - Modify `ofec_totals_house_senate_mv` and `ofec_totals_house_senate_vw` to add:
    `organization_type`

    Replaces V0233

5 - Modify `ofec_totals_ie_only_mv` and `ofec_totals_ie_only_vw` to add:
    `organization_type`

    Replaces V0233

*/

-- 1 - Re-create `ofec_totals_combined_mv` with new field

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_combined_mv_tmp;

CREATE MATERIALIZED VIEW ofec_totals_combined_mv_tmp AS
    WITH last_subset AS (
     SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.orig_sub_id,
        v_sum_and_det_sum_report.cmte_id,
        v_sum_and_det_sum_report.coh_cop,
        v_sum_and_det_sum_report.debts_owed_by_cmte,
        v_sum_and_det_sum_report.debts_owed_to_cmte,
        v_sum_and_det_sum_report.net_op_exp,
        v_sum_and_det_sum_report.net_contb,
        v_sum_and_det_sum_report.rpt_yr,
        get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
       FROM disclosure.v_sum_and_det_sum_report
      WHERE get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979 AND (v_sum_and_det_sum_report.form_tp_cd::text <> 'F5'::text OR v_sum_and_det_sum_report.form_tp_cd::text = 'F5'::text AND (v_sum_and_det_sum_report.rpt_tp::text <> ALL (ARRAY['24'::character varying::text, '48'::character varying::text]))) AND v_sum_and_det_sum_report.form_tp_cd::text NOT IN ('F6','SL')
      ORDER BY v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp(v_sum_and_det_sum_report.cvg_end_dt::double precision)) DESC NULLS LAST
    ), last AS (
     SELECT ls.cmte_id,
        ls.orig_sub_id,
        ls.coh_cop,
        ls.cycle,
        ls.debts_owed_by_cmte,
        ls.debts_owed_to_cmte,
        ls.net_op_exp,
        ls.net_contb,
        ls.rpt_yr,
        of.candidate_id,
        of.beginning_image_number,
        of.coverage_end_date,
        of.form_type,
        of.report_type_full,
        of.report_type,
        of.candidate_name,
        of.committee_name
       FROM last_subset ls
         LEFT JOIN ofec_filings_all_vw of ON ls.orig_sub_id = of.sub_id
    ), first AS (
     SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.coh_bop AS cash_on_hand,
        v_sum_and_det_sum_report.cmte_id AS committee_id,
        CASE
            WHEN v_sum_and_det_sum_report.cvg_start_dt = 99999999::numeric THEN NULL::timestamp without time zone
            ELSE v_sum_and_det_sum_report.cvg_start_dt::text::date::timestamp without time zone
        END AS coverage_start_date,
        get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
       FROM disclosure.v_sum_and_det_sum_report
      WHERE get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979 AND (v_sum_and_det_sum_report.form_tp_cd::text <> 'F5'::text OR v_sum_and_det_sum_report.form_tp_cd::text = 'F5'::text AND (v_sum_and_det_sum_report.rpt_tp::text <> ALL (ARRAY['24'::character varying::text, '48'::character varying::text]))) AND v_sum_and_det_sum_report.form_tp_cd::text NOT IN ('F6','SL')
      ORDER BY v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp(v_sum_and_det_sum_report.cvg_end_dt::double precision))
    ), committee_info AS (
     SELECT DISTINCT ON (cmte_valid_fec_yr.cmte_id, cmte_valid_fec_yr.fec_election_yr) cmte_valid_fec_yr.cmte_id,
        cmte_valid_fec_yr.fec_election_yr,
        cmte_valid_fec_yr.cmte_nm,
        cmte_valid_fec_yr.cmte_tp,
        cmte_valid_fec_yr.cmte_dsgn,
        cmte_valid_fec_yr.cmte_pty_affiliation_desc,
        cmte_valid_fec_yr.cmte_st,
        cmte_valid_fec_yr.tres_nm,
        cmte_valid_fec_yr.cmte_filing_freq,
        cmte_valid_fec_yr.cmte_filing_freq_desc,
        -- Added w/V0233
        cmte_valid_fec_yr.org_tp
       FROM disclosure.cmte_valid_fec_yr
    ), dates AS (
     SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
        min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
        max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
        max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F1'::text)) AS last_f1_date
        FROM disclosure.f_rpt_or_form_sub
        GROUP BY f_rpt_or_form_sub.cand_cmte_id
    ), leadership_pac_linkage AS ( -- Added w/ V0233
     SELECT cand_cmte_linkage_alternate.cmte_id,
        cand_cmte_linkage_alternate.fec_election_yr,
        COALESCE(array_agg(DISTINCT cand_cmte_linkage_alternate.cand_id)::text[], ARRAY[]::text[]) AS sponsor_candidate_ids
       FROM disclosure.cand_cmte_linkage_alternate
       WHERE linkage_type = 'D'
       GROUP BY cand_cmte_linkage_alternate.cmte_id, cand_cmte_linkage_alternate.fec_election_yr
    )
 SELECT get_cycle(vsd.rpt_yr) AS cycle,
    max(last.candidate_id::text) AS candidate_id,
    max(last.candidate_name::text) AS candidate_name,
    max(last.committee_name::text) AS committee_name,
    max(last.beginning_image_number) AS last_beginning_image_number,
    max(last.coh_cop) AS last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) AS last_debts_owed_by_committee,
    max(last.debts_owed_to_cmte) AS last_debts_owed_to_committee,
    max(last.net_contb) AS last_net_contributions,
    max(last.net_op_exp) AS last_net_operating_expenditures,
    max(last.report_type::text) AS last_report_type,
    max(last.report_type_full::text) AS last_report_type_full,
    max(last.rpt_yr) AS last_report_year,
    max(last.coverage_end_date) AS coverage_end_date,
    max(vsd.orig_sub_id) AS sub_id,
    min(first.cash_on_hand) AS cash_on_hand_beginning_period,
    min(first.coverage_start_date) AS coverage_start_date,
    sum(vsd.all_loans_received_per) AS all_loans_received,
    sum(vsd.cand_cntb) AS candidate_contribution,
    sum(vsd.cand_loan_repymnt + vsd.oth_loan_repymts) AS loan_repayments_made,
    sum(vsd.cand_loan_repymnt) AS loan_repayments_candidate_loans,
    sum(vsd.cand_loan) AS loans_made_by_candidate,
    sum(vsd.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
    sum(vsd.cand_loan) AS loans_received_from_candidate,
    sum(vsd.coord_exp_by_pty_cmte_per) AS coordinated_expenditures_by_party_committee,
    sum(vsd.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
    sum(vsd.fed_cand_cmte_contb_per) AS fed_candidate_committee_contributions,
    sum(vsd.fed_cand_contb_ref_per) AS fed_candidate_contribution_refunds,
    sum(vsd.fed_funds_per) > 0::numeric AS federal_funds_flag,
    sum(vsd.ttl_fed_disb_per) AS fed_disbursements,
    sum(vsd.fed_funds_per) AS federal_funds,
    sum(vsd.fndrsg_disb) AS fundraising_disbursements,
    sum(vsd.indv_contb) AS individual_contributions,
    sum(vsd.indv_item_contb) AS individual_itemized_contributions,
    sum(vsd.indv_ref) AS refunded_individual_contributions,
    sum(vsd.indv_unitem_contb) AS individual_unitemized_contributions,
    sum(vsd.loan_repymts_received_per) AS loan_repayments_received,
    sum(vsd.loans_made_per) AS loans_made,
    sum(vsd.net_contb) AS net_contributions,
    sum(vsd.net_op_exp) AS net_operating_expenditures,
    sum(vsd.non_alloc_fed_elect_actvy_per) AS non_allocated_fed_election_activity,
    sum(vsd.offsets_to_fndrsg) AS offsets_to_fundraising_expenditures,
    sum(vsd.offsets_to_legal_acctg) AS offsets_to_legal_accounting,
    sum(vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg + vsd.offsets_to_legal_acctg) AS total_offsets_to_operating_expenditures,
    sum(vsd.offsets_to_op_exp) AS offsets_to_operating_expenditures,
    sum(
    CASE
        WHEN vsd.form_tp_cd::text = 'F3X'::text THEN vsd.ttl_op_exp_per
        ELSE vsd.op_exp_per
    END) AS operating_expenditures,
    sum(vsd.oth_cmte_contb) AS other_political_committee_contributions,
    sum(vsd.oth_cmte_ref) AS refunded_other_political_committee_contributions,
    sum(vsd.oth_loan_repymts) AS loan_repayments_other_loans,
    sum(vsd.oth_loan_repymts) AS repayments_other_loans,
    sum(vsd.oth_loans) AS all_other_loans,
    sum(vsd.oth_loans) AS other_loans_received,
    sum(vsd.other_disb_per) AS other_disbursements,
    sum(vsd.other_fed_op_exp_per) AS other_fed_operating_expenditures,
    sum(vsd.other_receipts) AS other_fed_receipts,
    sum(vsd.other_receipts) AS other_receipts,
    sum(vsd.pol_pty_cmte_contb) AS refunded_political_party_committee_contributions,
    sum(vsd.pty_cmte_contb) AS political_party_committee_contributions,
    sum(vsd.shared_fed_actvy_fed_shr_per) AS shared_fed_activity,
    sum(vsd.shared_fed_actvy_nonfed_per) AS allocated_federal_election_levin_share,
    sum(vsd.shared_fed_actvy_nonfed_per) AS shared_fed_activity_nonfed,
    sum(vsd.shared_fed_op_exp_per) AS shared_fed_operating_expenditures,
    sum(vsd.shared_nonfed_op_exp_per) AS shared_nonfed_operating_expenditures,
    sum(vsd.tranf_from_nonfed_acct_per) AS transfers_from_nonfed_account,
    sum(vsd.tranf_from_nonfed_levin_per) AS transfers_from_nonfed_levin,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_committee,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_party,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_other_authorized_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_affiliated_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_other_authorized_committee,
    sum(vsd.ttl_contb_ref) AS contribution_refunds,
    sum(vsd.ttl_contb) AS contributions,
    sum(vsd.ttl_disb) AS disbursements,
    sum(vsd.ttl_fed_elect_actvy_per) AS fed_election_activity,
    sum(vsd.ttl_fed_receipts_per) AS fed_receipts,
    sum(vsd.ttl_loan_repymts) AS loan_repayments,
    sum(vsd.ttl_loans) AS loans_received,
    sum(vsd.ttl_loans) AS loans,
    sum(vsd.ttl_nonfed_tranf_per) AS total_transfers,
    sum(vsd.ttl_receipts) AS receipts,
    max(committee_info.cmte_tp::text) AS committee_type,
    max(expand_committee_type(committee_info.cmte_tp::text)) AS committee_type_full,
    max(committee_info.cmte_dsgn::text) AS committee_designation,
    max(expand_committee_designation(committee_info.cmte_dsgn::text)) AS committee_designation_full,
    max(committee_info.cmte_pty_affiliation_desc::text) AS party_full,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
    CASE
        WHEN max(last.form_type::text) = ANY (ARRAY['F3'::text, 'F3P'::text]) THEN NULL::numeric
        ELSE sum(vsd.indt_exp_per)
    END AS independent_expenditures,
    sum(vsd.exp_subject_limits_per) AS exp_subject_limits,
    sum(vsd.exp_prior_yrs_subject_lim_per) AS exp_prior_years_subject_limits,
    sum(vsd.ttl_exp_subject_limits) AS total_exp_subject_limits,
    sum(vsd.subttl_ref_reb_ret_per) AS refunds_relating_convention_exp,
    sum(vsd.item_ref_reb_ret_per) AS itemized_refunds_relating_convention_exp,
    sum(vsd.unitem_ref_reb_ret_per) AS unitemized_refunds_relating_convention_exp,
    sum(vsd.subttl_other_ref_reb_ret_per) AS other_refunds,
    sum(vsd.item_other_ref_reb_ret_per) AS itemized_other_refunds,
    sum(vsd.unitem_other_ref_reb_ret_per) AS unitemized_other_refunds,
    sum(vsd.item_other_income_per) AS itemized_other_income,
    sum(vsd.unitem_other_income_per) AS unitemized_other_income,
    sum(vsd.subttl_convn_exp_disb_per) AS convention_exp,
    sum(vsd.item_convn_exp_disb_per) AS itemized_convention_exp,
    sum(vsd.unitem_convn_exp_disb_per) AS unitemized_convention_exp,
    sum(vsd.item_other_disb_per) AS itemized_other_disb,
    sum(vsd.unitem_other_disb_per) AS unitemized_other_disb,
    max(committee_info.cmte_st::text) AS committee_state,
    max(committee_info.tres_nm::text) AS treasurer_name,
    max(committee_info.cmte_filing_freq::text) AS filing_frequency,
    max(expand_filing_frequency(committee_info.cmte_filing_freq::text)) AS filing_frequency_full,
    min(dates.first_file_date::text::date) AS first_file_date,
    -- Added w/ V0232
    max(to_tsvector(parse_fulltext(committee_info.tres_nm::text)::text)::text) AS treasurer_text,
    -- Added w/ V0233
    -- Can't use array_agg with empty arrays, so adding to group by
    l.sponsor_candidate_ids,
    max(committee_info.org_tp) AS organization_type
   FROM disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN dates on vsd.cmte_id::text = dates.cmte_id::text
     LEFT JOIN last ON vsd.cmte_id::text = last.cmte_id::text AND get_cycle(vsd.rpt_yr) = last.cycle
     LEFT JOIN first ON vsd.cmte_id::text = first.committee_id::text AND get_cycle(vsd.rpt_yr) = first.cycle
     LEFT JOIN committee_info ON vsd.cmte_id::text = committee_info.cmte_id::text AND get_cycle(vsd.rpt_yr)::numeric = committee_info.fec_election_yr
     -- Added w/V0233
     LEFT JOIN leadership_pac_linkage l ON vsd.cmte_id::text = l.cmte_id::text AND get_cycle(vsd.rpt_yr) = l.fec_election_yr
  WHERE get_cycle(vsd.rpt_yr) >= 1979
    AND (
        vsd.form_tp_cd::text <> 'F5'::text
        OR vsd.form_tp_cd::text = 'F5'::text
        AND (
            vsd.rpt_tp::text <> ALL (ARRAY['24'::character varying::text, '48'::character varying::text])
            )
        )
    AND vsd.form_tp_cd::text NOT IN ('F6','SL')
  GROUP BY vsd.cmte_id, vsd.form_tp_cd, (get_cycle(vsd.rpt_yr)), sponsor_candidate_ids
  WITH DATA;

-- Permissions
ALTER TABLE public.ofec_totals_combined_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_totals_combined_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_combined_mv_tmp TO fec_read;

-- Indexes
CREATE UNIQUE INDEX idx_ofec_totals_combined_mv_tmp_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_cmte_dsgn_full_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (committee_designation_full COLLATE pg_catalog."default", sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_cmte_id_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (committee_id , sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_cmte_tp_full_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (committee_type_full, sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_cycle_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (cycle, sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_disb_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (disbursements, sub_id);
CREATE INDEX idx_ofec_totals_combined_mv_tmp_receipts_sub_id
    ON public.ofec_totals_combined_mv_tmp USING btree
    (receipts, sub_id);

-- Added w/ V0232
CREATE INDEX idx_ofec_totals_combined_mv_tmp_treasurer_text
ON public.ofec_totals_combined_mv_tmp USING gin (treasurer_text);


-- Recreate vw -> select all from new _tmp MV

CREATE OR REPLACE VIEW ofec_totals_combined_vw
AS SELECT * FROM ofec_totals_combined_mv_tmp;

ALTER VIEW ofec_totals_combined_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_combined_vw TO fec_read;

-- Drop old `MV`
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_combined_mv;

-- Rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_combined_mv_tmp RENAME TO ofec_totals_combined_mv;

-- Rename indexes
ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_cmte_dsgn_full_sub_id
RENAME TO idx_ofec_totals_combined_mv_cmte_dsgn_full_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_cmte_id_sub_id
RENAME TO idx_ofec_totals_combined_mv_cmte_id_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_cmte_tp_full_sub_id
RENAME TO idx_ofec_totals_combined_mv_cmte_tp_full_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_cycle_sub_id
RENAME TO idx_ofec_totals_combined_mv_cycle_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_disb_sub_id
RENAME TO idx_ofec_totals_combined_mv_disb_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_receipts_sub_id
RENAME TO idx_ofec_totals_combined_mv_receipts_sub_id;

ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_sub_id
RENAME TO idx_ofec_totals_combined_mv_sub_id;

-- Added w/ V0232
ALTER INDEX IF EXISTS idx_ofec_totals_combined_mv_tmp_treasurer_text
RENAME TO idx_ofec_totals_combined_mv_treasurer_text;


-- 2 - Modify `ofec_totals_pac_party_vw` to bring in new field

CREATE OR REPLACE VIEW public.ofec_totals_pac_party_vw
AS
SELECT max(ofec_totals_combined_vw.sub_id) AS idx,
    max(ofec_totals_combined_vw.committee_id::text) AS committee_id,
    max(ofec_totals_combined_vw.committee_name) AS committee_name,
    max(ofec_totals_combined_vw.committee_type) AS committee_type,
    max(ofec_totals_combined_vw.committee_type_full) AS committee_type_full,
    max(ofec_totals_combined_vw.committee_designation) AS committee_designation,
    max(ofec_totals_combined_vw.committee_designation_full) AS committee_designation_full,
    max(ofec_totals_combined_vw.coverage_start_date) AS coverage_start_date,
    max(ofec_totals_combined_vw.coverage_end_date) AS coverage_end_date,
    max(ofec_totals_combined_vw.cycle) AS cycle,
    sum(COALESCE(ofec_totals_combined_vw.all_loans_received, 0.0)) AS all_loans_received,
    sum(COALESCE(ofec_totals_combined_vw.allocated_federal_election_levin_share, 0.0)) AS allocated_federal_election_levin_share,
    max(ofec_totals_combined_vw.cash_on_hand_beginning_period) AS cash_on_hand_beginning_period,
    sum(COALESCE(ofec_totals_combined_vw.contribution_refunds, 0.0)) AS contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.contributions, 0.0)) AS contributions,
    sum(COALESCE(ofec_totals_combined_vw.coordinated_expenditures_by_party_committee, 0.0)) AS coordinated_expenditures_by_party_committee,
    sum(COALESCE(ofec_totals_combined_vw.convention_exp, 0.0)) AS convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.disbursements, 0.0)) AS disbursements,
    sum(COALESCE(ofec_totals_combined_vw.exp_subject_limits, 0.0)) AS exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.exp_prior_years_subject_limits, 0.0)) AS exp_prior_years_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_committee_contributions, 0.0)) AS fed_candidate_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_contribution_refunds, 0.0)) AS fed_candidate_contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.fed_disbursements, 0.0)) AS fed_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.fed_election_activity, 0.0)) AS fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.operating_expenditures, 0.0)) AS fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.fed_receipts, 0.0)) AS fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.federal_funds, 0.0)) AS federal_funds,
    sum(COALESCE(ofec_totals_combined_vw.independent_expenditures, 0.0)) AS independent_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.refunded_individual_contributions, 0.0)) AS refunded_individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_itemized_contributions, 0.0)) AS individual_itemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_unitemized_contributions, 0.0)) AS individual_unitemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_contributions, 0.0)) AS individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.itemized_convention_exp, 0.0)) AS itemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_disb, 0.0)) AS itemized_other_disb,
    sum(COALESCE(ofec_totals_combined_vw.itemized_refunds_relating_convention_exp, 0.0)) AS itemized_refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_income, 0.0)) AS itemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_refunds, 0.0)) AS itemized_other_refunds,
    max(ofec_totals_combined_vw.last_beginning_image_number) AS last_beginning_image_number,
    max(ofec_totals_combined_vw.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
    max(ofec_totals_combined_vw.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
    max(ofec_totals_combined_vw.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
    max(ofec_totals_combined_vw.last_report_type_full) AS last_report_type_full,
    max(ofec_totals_combined_vw.last_report_year) AS last_report_year,
    sum(COALESCE(ofec_totals_combined_vw.loans, 0.0)) AS loans_and_loan_repayments_received,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments, 0.0)) AS loans_and_loan_repayments_made,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_other_loans, 0.0)) AS loan_repayments_made,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_received, 0.0)) AS loan_repayments_received,
    sum(COALESCE(ofec_totals_combined_vw.loans_made, 0.0)) AS loans_made,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_other_authorized_committee, 0.0)) AS transfers_to_other_authorized_committee,
    sum(COALESCE(ofec_totals_combined_vw.net_operating_expenditures, 0.0)) AS net_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.non_allocated_fed_election_activity, 0.0)) AS non_allocated_fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.total_transfers, 0.0)) AS total_transfers,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_operating_expenditures, 0.0)) AS offsets_to_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.operating_expenditures, 0.0)) AS operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_disbursements, 0.0)) AS other_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_operating_expenditures, 0.0)) AS other_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_receipts, 0.0)) AS other_fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.other_refunds, 0.0)) AS other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.other_political_committee_contributions, 0.0)) AS other_political_committee_contributions,
    max(ofec_totals_combined_vw.party_full) AS party_full,
    sum(COALESCE(ofec_totals_combined_vw.political_party_committee_contributions, 0.0)) AS political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.receipts, 0.0)) AS receipts,
    sum(COALESCE(ofec_totals_combined_vw.refunded_other_political_committee_contributions, 0.0)) AS refunded_other_political_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunded_political_party_committee_contributions, 0.0)) AS refunded_political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunds_relating_convention_exp, 0.0)) AS refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity, 0.0)) AS shared_fed_activity,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity_nonfed, 0.0)) AS shared_fed_activity_nonfed,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_operating_expenditures, 0.0)) AS shared_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.shared_nonfed_operating_expenditures, 0.0)) AS shared_nonfed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.total_exp_subject_limits, 0.0)) AS total_exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_affiliated_party, 0.0)) AS transfers_from_affiliated_party,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_account, 0.0)) AS transfers_from_nonfed_account,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_levin, 0.0)) AS transfers_from_nonfed_levin,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_affiliated_committee, 0.0)) AS transfers_to_affiliated_committee,
    sum(COALESCE(ofec_totals_combined_vw.net_contributions, 0.0)) AS net_contributions,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_convention_exp, 0.0)) AS unitemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_disb, 0.0)) AS unitemized_other_disb,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_income, 0.0)) AS unitemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_refunds, 0.0)) AS unitemized_other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_refunds_relating_convention_exp, 0.0)) AS unitemized_refunds_relating_convention_exp,
    max(ofec_totals_combined_vw.committee_state) AS committee_state,
    max(ofec_totals_combined_vw.treasurer_name) AS treasurer_name,
    max(ofec_totals_combined_vw.filing_frequency) AS filing_frequency,
    max(ofec_totals_combined_vw.filing_frequency_full) AS filing_frequency_full,
    min(ofec_totals_combined_vw.first_file_date) AS first_file_date,
    -- Added w/ V0232
    max(ofec_totals_combined_vw.treasurer_text) AS treasurer_text,
    -- Added w/ V0233
    -- Can't use array_agg with empty arrays, so adding to group by
    ofec_totals_combined_vw.sponsor_candidate_ids,
    max(ofec_totals_combined_vw.organization_type) AS organization_type
FROM ofec_totals_combined_vw
WHERE ofec_totals_combined_vw.committee_type IN ('N', 'O', 'Q', 'V', 'W', 'X', 'Y')
    AND ofec_totals_combined_vw.form_type IN ('F3X', 'F13', 'F4', 'F3','F3P')
GROUP BY ofec_totals_combined_vw.committee_id, ofec_totals_combined_vw.cycle, ofec_totals_combined_vw.sponsor_candidate_ids;

-- Permissions

ALTER TABLE public.ofec_totals_pac_party_vw OWNER TO fec;

GRANT ALL ON TABLE public.ofec_totals_pac_party_vw TO fec;

GRANT SELECT ON TABLE public.ofec_totals_pac_party_vw TO fec_read;

-- 3 - Modify `ofec_committee_totals_per_cycle_vw`

CREATE OR REPLACE VIEW public.ofec_committee_totals_per_cycle_vw AS
SELECT
    max(ofec_totals_combined_vw.committee_id::text) AS committee_id,
    max(ofec_totals_combined_vw.committee_name) AS committee_name,
    max(ofec_totals_combined_vw.committee_type) AS committee_type,
    max(ofec_totals_combined_vw.committee_type_full) AS committee_type_full,
    max(ofec_totals_combined_vw.committee_designation) AS committee_designation,
    max(ofec_totals_combined_vw.committee_designation_full) AS committee_designation_full,
    max(ofec_totals_combined_vw.cycle) AS cycle,
    max(ofec_totals_combined_vw.party_full) AS party_full,
    max(ofec_totals_combined_vw.candidate_id) AS candidate_id,
    max(ofec_totals_combined_vw.candidate_name) AS candidate_name,
    max(ofec_totals_combined_vw.last_beginning_image_number) AS last_beginning_image_number,
    max(ofec_totals_combined_vw.last_cash_on_hand_end_period) AS last_cash_on_hand_end_period,
    max(ofec_totals_combined_vw.last_debts_owed_by_committee) AS last_debts_owed_by_committee,
    max(ofec_totals_combined_vw.last_debts_owed_to_committee) AS last_debts_owed_to_committee,
    max(ofec_totals_combined_vw.last_net_contributions) AS last_net_contributions,
    max(ofec_totals_combined_vw.last_net_operating_expenditures) AS last_net_operating_expenditures,
    max(ofec_totals_combined_vw.cash_on_hand_beginning_period) AS cash_on_hand_beginning_period,
    max(ofec_totals_combined_vw.last_report_year) AS last_report_year,
    max(ofec_totals_combined_vw.coverage_start_date) AS coverage_start_date,
    max(ofec_totals_combined_vw.coverage_end_date) AS coverage_end_date,
    max(ofec_totals_combined_vw.sub_id) AS sub_id,
    max(ofec_totals_combined_vw.last_report_type) AS last_report_type,
    max(ofec_totals_combined_vw.last_report_type_full) AS last_report_type_full,
    sum(COALESCE(ofec_totals_combined_vw.all_loans_received, 0.0)) AS all_loans_received,
    sum(COALESCE(ofec_totals_combined_vw.all_other_loans, 0.0)) AS all_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.allocated_federal_election_levin_share, 0.0)) AS allocated_federal_election_levin_share,
    sum(COALESCE(ofec_totals_combined_vw.candidate_contribution, 0.0)) AS candidate_contribution,
    sum(COALESCE(ofec_totals_combined_vw.contribution_refunds, 0.0)) AS contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.contributions, 0.0)) AS contributions,
    sum(COALESCE(ofec_totals_combined_vw.coordinated_expenditures_by_party_committee, 0.0)) AS coordinated_expenditures_by_party_committee,
    sum(COALESCE(ofec_totals_combined_vw.disbursements, 0.0)) AS disbursements,
    sum(COALESCE(ofec_totals_combined_vw.exempt_legal_accounting_disbursement, 0.0)) AS exempt_legal_accounting_disbursement,
    sum(COALESCE(ofec_totals_combined_vw.exp_subject_limits, 0.0)) AS exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.exp_prior_years_subject_limits, 0.0)) AS exp_prior_years_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_committee_contributions, 0.0)) AS fed_candidate_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.fed_candidate_contribution_refunds, 0.0)) AS fed_candidate_contribution_refunds,
    sum(COALESCE(ofec_totals_combined_vw.fed_disbursements, 0.0)) AS fed_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.fed_election_activity, 0.0)) AS fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.fed_receipts, 0.0)) AS fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.federal_funds, 0.0)) AS federal_funds,
    sum(COALESCE(ofec_totals_combined_vw.federal_funds, 0.0)) > 0 AS federal_funds_flag,
    sum(COALESCE(ofec_totals_combined_vw.fundraising_disbursements, 0.0)) AS fundraising_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.independent_expenditures, 0.0)) AS independent_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.individual_contributions, 0.0)) AS individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_itemized_contributions, 0.0)) AS individual_itemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.individual_unitemized_contributions, 0.0)) AS individual_unitemized_contributions,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_candidate_loans, 0.0)) AS loan_repayments_candidate_loans,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments, 0.0)) AS loan_repayments,
    sum(COALESCE(ofec_totals_combined_vw.loans_received, 0.0)) AS loans_received,
    sum(COALESCE(ofec_totals_combined_vw.loans, 0.0)) AS loans,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_made, 0.0)) AS loan_repayments_made,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_received, 0.0)) AS loan_repayments_received,
    sum(COALESCE(ofec_totals_combined_vw.loan_repayments_other_loans, 0.0)) AS loan_repayments_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.loans_received_from_candidate, 0.0)) AS loans_received_from_candidate,
    sum(COALESCE(ofec_totals_combined_vw.loans_made, 0.0)) AS loans_made,
    sum(COALESCE(ofec_totals_combined_vw.loans_made_by_candidate, 0.0)) AS loans_made_by_candidate,
    sum(COALESCE(ofec_totals_combined_vw.net_contributions, 0.0)) AS net_contributions,
    sum(COALESCE(ofec_totals_combined_vw.net_operating_expenditures, 0.0)) AS net_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.non_allocated_fed_election_activity, 0.0)) AS non_allocated_fed_election_activity,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_fundraising_expenditures, 0.0)) AS offsets_to_fundraising_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_legal_accounting, 0.0)) AS offsets_to_legal_accounting,
    sum(COALESCE(ofec_totals_combined_vw.offsets_to_operating_expenditures, 0.0)) AS offsets_to_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.operating_expenditures, 0.0)) AS operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_loans_received, 0.0)) AS other_loans_received,
    sum(COALESCE(ofec_totals_combined_vw.other_disbursements, 0.0)) AS other_disbursements,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_operating_expenditures, 0.0)) AS other_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.other_fed_receipts, 0.0)) AS other_fed_receipts,
    sum(COALESCE(ofec_totals_combined_vw.other_receipts, 0.0)) AS other_receipts,
    sum(COALESCE(ofec_totals_combined_vw.other_political_committee_contributions, 0.0)) AS other_political_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.political_party_committee_contributions, 0.0)) AS political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.receipts, 0.0)) AS receipts,
    sum(COALESCE(ofec_totals_combined_vw.refunded_individual_contributions, 0.0)) AS refunded_individual_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunded_other_political_committee_contributions, 0.0)) AS refunded_other_political_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunded_political_party_committee_contributions, 0.0)) AS refunded_political_party_committee_contributions,
    sum(COALESCE(ofec_totals_combined_vw.refunds_relating_convention_exp, 0.0)) AS refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.repayments_loans_made_by_candidate, 0.0)) AS repayments_loans_made_by_candidate,
    sum(COALESCE(ofec_totals_combined_vw.repayments_other_loans, 0.0)) AS repayments_other_loans,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity, 0.0)) AS shared_fed_activity,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_activity_nonfed, 0.0)) AS shared_fed_activity_nonfed,
    sum(COALESCE(ofec_totals_combined_vw.shared_fed_operating_expenditures, 0.0)) AS shared_fed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.shared_nonfed_operating_expenditures, 0.0)) AS shared_nonfed_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.total_exp_subject_limits, 0.0)) AS total_exp_subject_limits,
    sum(COALESCE(ofec_totals_combined_vw.total_offsets_to_operating_expenditures, 0.0)) AS total_offsets_to_operating_expenditures,
    sum(COALESCE(ofec_totals_combined_vw.total_transfers, 0.0)) AS total_transfers,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_account, 0.0)) AS transfers_from_nonfed_account,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_nonfed_levin, 0.0)) AS transfers_from_nonfed_levin,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_affiliated_committee, 0.0)) AS transfers_from_affiliated_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_affiliated_party, 0.0)) AS transfers_from_affiliated_party,
    sum(COALESCE(ofec_totals_combined_vw.transfers_from_other_authorized_committee, 0.0)) AS transfers_from_other_authorized_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_affiliated_committee, 0.0)) AS transfers_to_affiliated_committee,
    sum(COALESCE(ofec_totals_combined_vw.transfers_to_other_authorized_committee, 0.0)) AS transfers_to_other_authorized_committee,
    sum(COALESCE(ofec_totals_combined_vw.itemized_refunds_relating_convention_exp, 0.0)) AS itemized_refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_refunds_relating_convention_exp, 0.0)) AS unitemized_refunds_relating_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.other_refunds, 0.0)) AS other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_refunds, 0.0)) AS itemized_other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_refunds, 0.0)) AS unitemized_other_refunds,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_income, 0.0)) AS itemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_income, 0.0)) AS unitemized_other_income,
    sum(COALESCE(ofec_totals_combined_vw.convention_exp, 0.0)) AS convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_convention_exp, 0.0)) AS itemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_convention_exp, 0.0)) AS unitemized_convention_exp,
    sum(COALESCE(ofec_totals_combined_vw.itemized_other_disb, 0.0)) AS itemized_other_disb,
    sum(COALESCE(ofec_totals_combined_vw.unitemized_other_disb, 0.0)) AS unitemized_other_disb,
    -- Added w/ V0232
    max(ofec_totals_combined_vw.committee_state) AS committee_state,
    max(ofec_totals_combined_vw.treasurer_name) AS treasurer_name,
    max(ofec_totals_combined_vw.treasurer_text) AS treasurer_text,
    max(ofec_totals_combined_vw.filing_frequency) AS filing_frequency,
    max(ofec_totals_combined_vw.filing_frequency_full) AS filing_frequency_full,
    min(ofec_totals_combined_vw.first_file_date) AS first_file_date,
    -- Added w/ V0233
    max(ofec_totals_combined_vw.organization_type) AS organization_type
FROM public.ofec_totals_combined_vw
GROUP BY ofec_totals_combined_vw.committee_id, ofec_totals_combined_vw.cycle;

ALTER TABLE public.ofec_committee_totals_per_cycle_vw OWNER TO fec;

GRANT SELECT ON public.ofec_committee_totals_per_cycle_vw TO fec_read;


-- 4 - Modify `ofec_totals_house_senate_mv`


CREATE MATERIALIZED VIEW public.ofec_totals_house_senate_mv_tmp AS
SELECT f3.candidate_id,
    f3.cycle,
    f3.sub_id AS idx,
    f3.committee_id,
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
    f3.party_full,
    -- Added w/ V0232
    f3.committee_state,
    f3.treasurer_name,
    f3.treasurer_text,
    f3.filing_frequency,
    f3.filing_frequency_full,
    f3.first_file_date,
    -- Added w/ V0233
    f3.organization_type
FROM ofec_totals_combined_vw f3
WHERE f3.form_type in ('F3', 'F3P', 'F3X')
AND f3.committee_type in ('H','S')
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
  (candidate_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_id, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_type_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_type_full, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, committee_id);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (cycle, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx
  ON public.ofec_totals_house_senate_mv_tmp
  USING btree
  (committee_designation_full, idx);

CREATE INDEX idx_ofec_totals_house_senate_mv_tmp_treasurer_text
  ON ofec_totals_house_senate_mv_tmp
  USING gin (treasurer_text);

-- ---------------
DROP VIEW IF EXISTS public.ofec_totals_house_senate_vw;

CREATE OR REPLACE VIEW public.ofec_totals_house_senate_vw AS
SELECT * FROM public.ofec_totals_house_senate_mv_tmp;
-- ---------------
ALTER TABLE public.ofec_totals_house_senate_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_house_senate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_totals_house_senate_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_house_senate_mv_tmp RENAME TO ofec_totals_house_senate_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx
  RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cand_id_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cand_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_id_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_id_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_type_full_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_tp_full_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_cmte_id
  RENAME TO idx_ofec_totals_house_senate_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cycle_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cycle_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_cmte_dsgn_full_idx
  RENAME TO idx_ofec_totals_house_senate_mv_cmte_dsgn_full_idx;

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_treasurer_text
  RENAME TO idx_ofec_totals_house_senate_mv_treasurer_text;


-- 5 - Modify `ofec_totals_ie_only_mv`

CREATE MATERIALIZED VIEW public.ofec_totals_ie_only_mv_tmp AS
 SELECT ofec_totals_combined_vw.sub_id AS idx,
    ofec_totals_combined_vw.committee_id,
    ofec_totals_combined_vw.cycle,
    ofec_totals_combined_vw.coverage_start_date,
    ofec_totals_combined_vw.coverage_end_date,
    ofec_totals_combined_vw.contributions AS total_independent_contributions,
    ofec_totals_combined_vw.independent_expenditures AS total_independent_expenditures,
    ofec_totals_combined_vw.last_beginning_image_number,
    ofec_totals_combined_vw.committee_name,
    ofec_totals_combined_vw.committee_type,
    ofec_totals_combined_vw.committee_designation,
    ofec_totals_combined_vw.committee_type_full,
    ofec_totals_combined_vw.committee_designation_full,
    ofec_totals_combined_vw.party_full,
    -- Added w/ V0232
    ofec_totals_combined_vw.committee_state,
    ofec_totals_combined_vw.filing_frequency,
    ofec_totals_combined_vw.filing_frequency_full,
    ofec_totals_combined_vw.first_file_date,
    -- Added w/ V0233
   ofec_totals_combined_vw.organization_type
   FROM public.ofec_totals_combined_vw
  WHERE ((ofec_totals_combined_vw.form_type)::text = 'F5'::text)
  WITH DATA;

-- Permissions

ALTER TABLE public.ofec_totals_ie_only_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_ie_only_mv_tmp TO fec_read;

-- Indexes

CREATE UNIQUE INDEX ofec_totals_ie_only_mv_tmp_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_id_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_id, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1
ON public.ofec_totals_ie_only_mv_tmp USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_idx_idx
ON public.ofec_totals_ie_only_mv_tmp USING btree (cycle, idx);


-- Recreate view

CREATE OR REPLACE VIEW public.ofec_totals_ie_only_vw AS
SELECT * FROM public.ofec_totals_ie_only_mv_tmp;

ALTER VIEW ofec_totals_ie_only_vw OWNER TO fec;
GRANT ALL ON TABLE ofec_totals_ie_only_vw TO fec;
GRANT SELECT ON ofec_totals_ie_only_vw TO fec_read;


-- Drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_ie_only_mv;

-- Rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_ie_only_mv_tmp
RENAME TO ofec_totals_ie_only_mv;

-- Rename indexes

ALTER INDEX IF EXISTS idx_ofec_totals_house_senate_mv_tmp_idx
RENAME TO idx_ofec_totals_house_senate_mv_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_idx_idx
RENAME TO ofec_totals_ie_only_mv_idx_idx ;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_designation_full_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_id_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_id_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx
RENAME TO ofec_totals_ie_only_mv_committee_type_full_idx_idx;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1
RENAME TO ofec_totals_ie_only_mv_cycle_committee_id_idx1;

ALTER INDEX IF EXISTS ofec_totals_ie_only_mv_tmp_cycle_idx_idx
RENAME TO ofec_totals_ie_only_mv_cycle_idx_idx;
