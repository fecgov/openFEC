-- vsum is as amended and has fewer columns
-- this takes the name from sum_and_det_sum_report to vsum
select
vs.cmte_id,
vs.rpt_tp as rpt_tp,
vs.cvg_start_dt as cvg_start_dt,
vs.cvg_end_dt as cvg_end_dt,
vs.rpt_yr as rpt_yr,
vs.receipt_dt as receipt_dt,
vs.rpt_yr + vs.rpt_yr % 2::numeric as election_cycle,
vs.coh_bop as coh_bop, --cash on hand at the beginning of the period
vs.ttl_receipts as ttl_receipts, -- total receipts
vs.net_contb, --net contributions
vs.ttl_disb as ttl_disb_sum_page_per, --total disbursements
vs.coh_cop as coh_cop, -- cash on hand at the close of the period
vs.debts_owed_to_cmte as debts_owed_to_cmte,
vs.debts_owed_by_cmte as debts_owed_by_cmte,
vs.indv_unitem_contb as indv_unitem_contb_per, --unitemized individual contributions
vs.indv_item_contb as indv_item_contb_per, --itemized individual contributions
vs.indv_contb as ttl_indv_contb, -- total individual contributions
vs.pty_cmte_contb as pol_pty_cmte_contb_per_i, --party committee contributions
vs.oth_cmte_contb as other_pol_cmte_contb_per_i, --other committee contributions
vs.ttl_contb as ttl_contb_col_ttl_per, --total contributions
vs.tranf_from_other_auth_cmte as tranf_from_affiliated_pty_per, --transfers from affiliated committees
vs.all_loans_received_per as all_loans_received_per, -- loans received
vs.loan_repymts_received_per as loan_repymts_received_per, -- loan repayments received
vs.offsets_to_op_exp as offsets_to_op_exp_per_i, -- offsets to operating expenditures
vs.fed_cand_contb_ref_per as fed_cand_contb_ref_per, -- candidate refunds
vs.other_receipts as other_fed_receipts_per,  --other receipts
vs.tranf_from_nonfed_acct_per as tranf_from_nonfed_acct_per,
vs.tranf_from_nonfed_levin_per as tranf_from_nonfed_levin_per, --levin funds
vs.ttl_nonfed_tranf_per as ttl_nonfed_tranf_per, --non-federal transfers
vs.ttl_fed_receipts_per, --total federal receipts
vs.shared_fed_op_exp_per as shared_fed_op_exp_per, --allocated operating expenditures - federal
vs.shared_nonfed_op_exp_per as shared_nonfed_op_exp_per, --allocated operating expenditures - non-federal
vs.other_fed_op_exp_per as other_fed_op_exp_per, --other federal operating expenditures
vs.ttl_op_exp_per as ttl_op_exp_per, --operating expenditures (F3, F3P)
vs.op_exp_per as op_exp_per, --operating expenditures (F3)
vs.tranf_to_other_auth_cmte as tranf_to_affliliated_cmte_per, --transfers to affiliated committees
vs.fed_cand_cmte_contb_per as fed_cand_cmte_contb_per, --contributions to other committees
vs.indt_exp_per as indt_exp_per, --independent expenditures
vs.coord_exp_by_pty_cmte_per as coord_exp_by_pty_cmte_per, --coordinated party expenditures
vs.loans_made_per as loans_made_per, --loans made
-- vs.oth_loan_repymts as
vs.ttl_loan_repymts as loan_repymts_made_per, --total loan repayments made
vs.indv_ref as indv_contb_ref_per, --individual refunds
vs.pol_pty_cmte_contb as pol_pty_cmte_refund, --political party refunds
vs.oth_cmte_ref as other_pol_cmte_refund, --other committee refunds
vs.ttl_contb_ref as ttl_contb_refund, --total contribution refunds
vs.other_disb_per as other_disb_per, --other disbursements
vs.shared_fed_actvy_fed_shr_per as shared_fed_actvy_fed_shr_per, --allocated federal election activity - federal share
vs.shared_fed_actvy_nonfed_per as shared_fed_actvy_nonfed_per, --allocated federal election activity - levin share
vs.non_alloc_fed_elect_actvy_per as non_alloc_fed_elect_actvy_per, --federal election activity - federal only
vs.ttl_fed_elect_actvy_per as ttl_fed_elect_actvy_per, --total federal election activity
vs.rpt_yr as calendar_yr,
vs.orig_sub_id as sub_id
from disclosure.v_sum_and_det_sum_report vs
;
