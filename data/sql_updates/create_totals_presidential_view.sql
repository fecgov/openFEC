drop materialized view if exists ofec_totals_presidential_mv;
create materialized view ofec_totals_presidential_mv as
select
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    cmte_tp as committee_type,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(cand_contb_per) as candidate_contribution,
    sum(ttl_contb_ref_per) as contribution_refunds,
    sum(ttl_contb_per) as contributions,
    sum(ttl_disb_per) as disbursements,
    sum(exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
    sum(fed_funds_per) as federal_funds,
    sum(fndrsg_disb_per) as fundraising_disbursements,
    sum(indv_contb_per) as individual_contributions,
    sum(ttl_loans_received_per) as loans_received,
    sum(loans_received_from_cand_per) as loans_received_from_candidate,
    sum(ttl_loan_repymts_made_per) as loan_repayments_made,
    sum(offsets_to_fndrsg_exp_per) as offsets_to_fundraising_expenses,
    sum(offsets_to_legal_acctg_per) as offsets_to_legal_accounting,
    sum(offsets_to_op_exp_per) as offsets_to_operating_expenditures,
    sum(op_exp_per) as operating_expenditures,
    sum(other_disb_per) as other_disbursements,
    sum(other_loans_received_per) as other_loans_received,
    sum(other_pol_cmte_contb_per) as other_political_committee_contributions,
    sum(other_receipts_per) as other_receipts,
    sum(pol_pty_cmte_contb_per) as political_party_committee_contributions,
    sum(ttl_receipts_per) as receipts,
    sum(ref_indv_contb_per) as refunded_individual_contributions, -- renamed from "refunds_"
    sum(ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
    sum(ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
    sum(repymts_loans_made_by_cand_per) as repayments_loans_made_by_candidate,
    sum(repymts_other_loans_per) as repayments_other_loans,
    sum(tranf_from_affilated_cmte_per) as transfer_from_affiliated_committee,
    sum(tranf_to_other_auth_cmte_per) as transfer_to_other_authorized_committee
from
    dimcmte c
    inner join dimcmtetpdsgn ctd using (cmte_sk)
    inner join factpresidential_f3p p using (cmte_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
group by committee_id, cycle, committee_type
;
