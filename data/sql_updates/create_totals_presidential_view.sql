drop materialized view if exists ofec_totals_presidential_mv;
create materialized view ofec_totals_presidential_mv as
select
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    sum(cand_contb_per) as candidate_contribution,
    sum(ttl_contb_ref_per) as contribution_refunds,
    sum(ttl_contb_per) as contributions,
    sum(ttl_disb_per) as disbursements,
    sum(exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
    sum(indv_contb_per) as individual_contributions,
    sum(ttl_loan_repymts_made_per) as loan_repayments_made,
    sum(loans_received_from_cand_per) as loans_received_from_candidate,
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
    sum(tranf_from_affilated_cmte_per) as transfer_from_affiliated_committee,
    sum(tranf_to_other_auth_cmte_per) as transfer_to_other_authorized_committee
from
    dimcmte c
    inner join factpresidential_f3p p using (cmte_sk)
group by committee_id, cycle
;
