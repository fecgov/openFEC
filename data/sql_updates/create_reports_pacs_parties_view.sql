drop view if exists ofec_reports_pacs_parties_vw;
drop materialized view if exists ofec_reports_pacs_parties_mv_tmp;
create materialized view ofec_reports_pacs_parties_mv_tmp as
select
    row_number() over () as idx,
    factpacsandparties_f3x_sk as report_key,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    start_date.dw_date as coverage_start_date,
    end_date.dw_date as coverage_end_date,
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
    coalesce(offsets_to_op_exp_per_i, offsets_to_op_exp_per_ii
    ) as offsets_to_operating_expenditures_period,
    coalesce(offsets_to_op_exp_ytd_i, offsets_to_op_exp_ytd_ii) as offsets_to_operating_expenditures_ytd,
    other_disb_per as other_disbursements_period,
    other_disb_ytd as other_disbursements_ytd,
    other_fed_op_exp_per as other_fed_operating_expenditures_period,
    other_fed_op_exp_ytd as other_fed_operating_expenditures_ytd,
    other_fed_receipts_per as other_fed_receipts_period,
    other_fed_receipts_ytd as other_fed_receipts_ytd,
    -- in this case, i and ii are not the same thing
    -- if they have ii they are refunds and i are contributions
    other_pol_cmte_contb_per_ii as refunded_other_political_committee_contributions_period,
    other_pol_cmte_contb_ytd_ii as refunded_other_political_committee_contributions_ytd,
    other_pol_cmte_contb_per_i as other_political_committee_contributions_period,
    other_pol_cmte_contb_ytd_i as other_political_committee_contributions_ytd,
    pol_pty_cmte_contb_per_ii as refunded_political_party_committee_contributions_period,
    pol_pty_cmte_contb_ytd_ii as refunded_political_party_committee_contributions_ytd,
    pol_pty_cmte_contb_per_i as political_party_committee_contributions_period,
    pol_pty_cmte_contb_ytd_i as political_party_committee_contributions_ytd,
    rpt_yr as report_year,
    shared_fed_actvy_nonfed_ytd as shared_fed_activity_nonfed_ytd,
    shared_fed_actvy_fed_shr_per as shared_fed_activity_period,
    shared_fed_actvy_fed_shr_ytd as shared_fed_activity_ytd,
    shared_fed_op_exp_per as shared_fed_operating_expenditures_period,
    shared_fed_op_exp_ytd as shared_fed_operating_expenditures_ytd,
    shared_nonfed_op_exp_per as shared_nonfed_operating_expenditures_period,
    shared_nonfed_op_exp_ytd as shared_nonfed_operating_expenditures_ytd,
    subttl_sum_page_per as subtotal_summary_page_period,
    subttl_sum_ytd as subtotal_summary_ytd,
    coalesce(ttl_contb_ref_per_i, ttl_contb_ref_per_ii) as total_contribution_refunds_period,
    coalesce(ttl_contb_ref_ytd_i, ttl_contb_ref_ytd_ii) as total_contribution_refunds_ytd,
    ttl_contb_per as total_contributions_period,
    ttl_contb_ytd as total_contributions_ytd,
    coalesce(ttl_disb_sum_page_per, ttl_disb_per) as total_disbursements_period,
    coalesce(ttl_disb_sum_page_ytd, ttl_disb_ytd) as total_disbursements_ytd,
    ttl_fed_disb_per as total_fed_disbursements_period,
    ttl_fed_disb_ytd as total_fed_disbursements_ytd,
    ttl_fed_elect_actvy_per as total_fed_election_activity_period,
    ttl_fed_elect_actvy_ytd as total_fed_election_activity_ytd,
    ttl_fed_op_exp_per as total_fed_operating_expenditures_period,
    ttl_fed_op_exp_ytd as total_fed_operating_expenditures_ytd,
    ttl_fed_receipts_per as total_fed_receipts_period,
    ttl_fed_receipts_ytd as total_fed_receipts_ytd,
    ttl_indv_contb as total_individual_contributions,
    ttl_indv_contb_ytd as total_individual_contributions_ytd,
    ttl_nonfed_tranf_per as total_nonfed_transfers_period,
    ttl_nonfed_tranf_ytd as total_nonfed_transfers_ytd,
    ttl_op_exp_per as total_operating_expenditures_period,
    ttl_op_exp_ytd as total_operating_expenditures_ytd,
    coalesce(ttl_receipts_sum_page_per, ttl_receipts_per) as total_receipts_period,
    coalesce(ttl_receipts_sum_page_ytd, ttl_receipts_ytd) as total_receipts_ytd,
    tranf_from_affiliated_pty_per as transfers_from_affiliated_party_period,
    tranf_from_affiliated_pty_ytd as transfers_from_affiliated_party_ytd,
    tranf_from_nonfed_acct_per as transfers_from_nonfed_account_period,
    tranf_from_nonfed_acct_ytd as transfers_from_nonfed_account_ytd,
    tranf_from_nonfed_levin_per as transfers_from_nonfed_levin_period,
    tranf_from_nonfed_levin_ytd as transfers_from_nonfed_levin_ytd,
    tranf_to_affliliated_cmte_per as transfers_to_affiliated_committee_period,
    tranf_to_affilitated_cmte_ytd as transfers_to_affilitated_committees_ytd,
    rpt_tp as report_type,
    rpt_tp_desc as report_type_full,
    f3x.expire_date as expire_date,
    f3x.load_date as load_date
from
    dimcmte c
    inner join factpacsandparties_f3x f3x using (cmte_sk)
    inner join dimreporttype rt using (reporttype_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    two_yr_period_sk >= :START_YEAR
    and f3x.expire_date is null
;

create unique index on ofec_reports_pacs_parties_mv_tmp(idx);

create index on ofec_reports_pacs_parties_mv_tmp(cycle);
create index on ofec_reports_pacs_parties_mv_tmp(report_type);
create index on ofec_reports_pacs_parties_mv_tmp(report_year);
create index on ofec_reports_pacs_parties_mv_tmp(committee_id);
create index on ofec_reports_pacs_parties_mv_tmp(coverage_end_date);
create index on ofec_reports_pacs_parties_mv_tmp(coverage_start_date);
create index on ofec_reports_pacs_parties_mv_tmp(beginning_image_number);
