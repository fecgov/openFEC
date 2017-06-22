drop materialized view if exists ofec_reports_pacs_parties_mv_tmp;
create materialized view ofec_reports_pacs_parties_mv_tmp as
select
    row_number() over () as idx,
    f3x.cmte_id as committee_id,
    election_cycle as cycle,
    cvg_start_dt as coverage_start_date,
    cvg_end_dt as coverage_end_date,
    all_loans_received_per as all_loans_received_period,
    all_loans_received_ytd as all_loans_received_ytd,
    shared_fed_actvy_nonfed_per as allocated_federal_election_levin_share_period,
    begin_image_num as beginning_image_number,
    calendar_yr as calendar_ytd,
    coh_begin_calendar_yr as cash_on_hand_beginning_calendar_ytd,
    coh_bop as cash_on_hand_beginning_period,
    coh_coy as cash_on_hand_close_ytd,
    coh_cop as cash_on_hand_end_period,
    coord_exp_by_pty_cmte_per as coordinated_expenditures_by_party_committee_period,
    coord_exp_by_pty_cmte_ytd as coordinated_expenditures_by_party_committee_ytd,
    debts_owed_by_cmte as debts_owed_by_committee,
    debts_owed_to_cmte as debts_owed_to_committee,
    end_image_num as end_image_number,
    fed_cand_cmte_contb_ref_ytd as fed_candidate_committee_contribution_refunds_ytd,
    fed_cand_cmte_contb_per as fed_candidate_committee_contributions_period,
    fed_cand_cmte_contb_ytd as fed_candidate_committee_contributions_ytd,
    fed_cand_contb_ref_per as fed_candidate_contribution_refunds_period,
    indt_exp_per as independent_expenditures_period,
    indt_exp_ytd as independent_expenditures_ytd,
    indv_contb_ref_per as refunded_individual_contributions_period,
    indv_contb_ref_ytd as refunded_individual_contributions_ytd,
    indv_item_contb_per as individual_itemized_contributions_period,
    indv_item_contb_ytd as individual_itemized_contributions_ytd,
    indv_unitem_contb_per as individual_unitemized_contributions_period,
    indv_unitem_contb_ytd as individual_unitemized_contributions_ytd,
    loan_repymts_made_per as loan_repayments_made_period,
    loan_repymts_made_ytd as loan_repayments_made_ytd,
    loan_repymts_received_per as loan_repayments_received_period,
    loan_repymts_received_ytd as loan_repayments_received_ytd,
    loans_made_per as loans_made_period,
    loans_made_ytd as loans_made_ytd,
    net_contb_per as net_contributions_period,
    net_contb_ytd as net_contributions_ytd,
    net_op_exp_per as net_operating_expenditures_period,
    net_op_exp_ytd as net_operating_expenditures_ytd,
    non_alloc_fed_elect_actvy_per as non_allocated_fed_election_activity_period,
    non_alloc_fed_elect_actvy_ytd as non_allocated_fed_election_activity_ytd,
    shared_nonfed_op_exp_per as nonfed_share_allocated_disbursements_period,
    offests_to_op_exp as offsets_to_operating_expenditures_period,
    offsets_to_op_exp_ytd_i as offsets_to_operating_expenditures_ytd,
    other_disb_per as other_disbursements_period,
    other_disb_ytd as other_disbursements_ytd,
    other_fed_op_exp_per as other_fed_operating_expenditures_period,
    other_fed_op_exp_ytd as other_fed_operating_expenditures_ytd,
    other_fed_receipts_per as other_fed_receipts_period,
    other_fed_receipts_ytd as other_fed_receipts_ytd,
    other_pol_cmte_refund as refunded_other_political_committee_contributions_period,
    other_pol_cmte_refund_ytd as refunded_other_political_committee_contributions_ytd,
    other_pol_cmte_contb_per_i as other_political_committee_contributions_period,
    other_pol_cmte_contb_ytd_i as other_political_committee_contributions_ytd,
    pol_pty_cmte_refund as refunded_political_party_committee_contributions_period,
    pol_pty_cmte_refund_ytd as refunded_political_party_committee_contributions_ytd,
    pol_pty_cmte_contb_per_i as political_party_committee_contributions_period,
    pol_pty_cmte_contb_ytd_i as political_party_committee_contributions_ytd,
    f3x.rpt_yr as report_year,
    shared_fed_actvy_nonfed_ytd as shared_fed_activity_nonfed_ytd,
    shared_fed_actvy_fed_shr_per as shared_fed_activity_period,
    shared_fed_actvy_fed_shr_ytd as shared_fed_activity_ytd,
    shared_fed_op_exp_per as shared_fed_operating_expenditures_period,
    shared_fed_op_exp_ytd as shared_fed_operating_expenditures_ytd,
    shared_nonfed_op_exp_per as shared_nonfed_operating_expenditures_period,
    shared_nonfed_op_exp_ytd as shared_nonfed_operating_expenditures_ytd,
    subttl_sum_page_per as subtotal_summary_page_period,
    subttl_sum_ytd as subtotal_summary_ytd,
    ttl_contb_refund as total_contribution_refunds_period,
    ttl_contb_refund_ytd as total_contribution_refunds_ytd,
    ttl_contb_per as total_contributions_period,
    ttl_contb_ytd as total_contributions_ytd,
    ttl_disb as total_disbursements_period,
    ttl_disb_ytd as total_disbursements_ytd,
    ttl_fed_disb_per as total_fed_disbursements_period,
    ttl_fed_disb_ytd as total_fed_disbursements_ytd,
    ttl_fed_elect_actvy_per as total_fed_election_activity_period,
    ttl_fed_elect_actvy_ytd as total_fed_election_activity_ytd,
    ttl_fed_op_exp_per as total_fed_operating_expenditures_period,
    ttl_fed_op_exp_ytd as total_fed_operating_expenditures_ytd,
    ttl_fed_receipts_per as total_fed_receipts_period,
    ttl_fed_receipts_ytd as total_fed_receipts_ytd,
    ttl_indv_contb as total_individual_contributions_period,
    ttl_indv_contb_ytd as total_individual_contributions_ytd,
    ttl_nonfed_tranf_per as total_nonfed_transfers_period,
    ttl_nonfed_tranf_ytd as total_nonfed_transfers_ytd,
    ttl_op_exp_per as total_operating_expenditures_period,
    ttl_op_exp_ytd as total_operating_expenditures_ytd,
    ttl_receipts as total_receipts_period,
    ttl_receipts_ytd as total_receipts_ytd,
    tranf_from_affiliated_pty_per as transfers_from_affiliated_party_period,
    tranf_from_affiliated_pty_ytd as transfers_from_affiliated_party_ytd,
    tranf_from_nonfed_acct_per as transfers_from_nonfed_account_period,
    tranf_from_nonfed_acct_ytd as transfers_from_nonfed_account_ytd,
    tranf_from_nonfed_levin_per as transfers_from_nonfed_levin_period,
    tranf_from_nonfed_levin_ytd as transfers_from_nonfed_levin_ytd,
    tranf_to_affliliated_cmte_per as transfers_to_affiliated_committee_period,
    tranf_to_affilitated_cmte_ytd as transfers_to_affilitated_committees_ytd,
    f3x.rpt_tp as report_type,
    rpt_tp_desc as report_type_full,
    most_recent_filing_flag like 'N' as is_amended,
    f3x.receipt_dt as receipt_date,
    f3x.file_num as file_number,
    f3x.amndt_ind as amendment_indicator,
    f3x.amndt_ind_desc as amendment_indicator_full,
    means_filed(begin_image_num) as means_filed,
    report_html_url(means_filed(begin_image_num), f3x.cmte_id::text, f3x.file_num::text) as html_url,
    report_fec_url(begin_image_num::text, f3x.file_num::integer) as fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num as previous_file_number,
    amendments.mst_rct_file_num as most_recent_file_number,
    is_most_recent(f3x.file_num::integer, amendments.mst_rct_file_num::integer) as most_recent

from
    fec_vsum_f3x_vw f3x
    left join ( select * from ofec_amendments_mv_tmp
                union all select * from ofec_pac_party_paper_amendments_mv_tmp) amendments
    on f3x.file_num = amendments.file_num
where
    election_cycle >= :START_YEAR
;

create unique index on ofec_reports_pacs_parties_mv_tmp(idx);

create index on ofec_reports_pacs_parties_mv_tmp(cycle, idx);
create index on ofec_reports_pacs_parties_mv_tmp(report_type, idx);
create index on ofec_reports_pacs_parties_mv_tmp(report_year, idx);
create index on ofec_reports_pacs_parties_mv_tmp(committee_id, idx);
create index on ofec_reports_pacs_parties_mv_tmp(coverage_end_date, idx);
create index on ofec_reports_pacs_parties_mv_tmp(coverage_start_date, idx);
create index on ofec_reports_pacs_parties_mv_tmp(beginning_image_number, idx);
create index on ofec_reports_pacs_parties_mv_tmp(is_amended, idx);
create index on ofec_reports_pacs_parties_mv_tmp(total_receipts_period, idx);
create index on ofec_reports_pacs_parties_mv_tmp(total_disbursements_period, idx);
create index on ofec_reports_pacs_parties_mv_tmp(receipt_date, idx);
create index on ofec_reports_pacs_parties_mv_tmp(independent_expenditures_period, idx);
create index on ofec_reports_pacs_parties_mv_tmp(cycle, idx);
create index on ofec_reports_pacs_parties_mv_tmp(cycle, committee_id);
