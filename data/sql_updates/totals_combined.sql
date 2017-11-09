-- Creates materialized view of the most recent report per committee, per cycle
drop materialized view if exists ofec_totals_combined_mv_tmp;
create materialized view ofec_totals_combined_mv_tmp as
-- done in two steps to reduce the scope of the join
with last_subset as (
    select distinct on (cmte_id, cycle)
        orig_sub_id,
        cmte_id,
        coh_cop,
        debts_owed_by_cmte,
        debts_owed_to_cmte,
        net_op_exp,
        net_contb,
        rpt_yr,
        -- check if report end date is better
        get_cycle(rpt_yr) as cycle
    from disclosure.v_sum_and_det_sum_report
    where
        get_cycle(rpt_yr) >= :START_YEAR
        -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
        and (form_tp_cd != 'F5' or (form_tp_cd = 'F5' and rpt_tp not in ('24','48')))
        and form_tp_cd != 'F6'
        order by
        cmte_id,
        cycle,
        to_timestamp(cvg_end_dt) desc nulls last
),
last as (
    select
        ls.cmte_id,
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
        of.coverage_end_date::timestamp,
        of.form_type,
        of.report_type_full,
        of.report_type,
        of.candidate_name,
        of.committee_name
    from last_subset ls
    left join ofec_filings_mv_tmp of on ls.orig_sub_id = of.sub_id
),
first as (
    select distinct on (cmte_id, get_cycle(rpt_yr))
        coh_bop as cash_on_hand,
        cmte_id as committee_id,
        case when cvg_start_dt = 99999999 then null::timestamp
          else cast(cast(cvg_start_dt as text) as date)
        end
        as coverage_start_date,
        get_cycle(rpt_yr) as cycle
    from disclosure.v_sum_and_det_sum_report
    where
        get_cycle(rpt_yr) >= :START_YEAR
        -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
        and (form_tp_cd != 'F5' or (form_tp_cd = 'F5' and rpt_tp not in ('24','48')))
        and form_tp_cd != 'F6'
    order by
        cmte_id,
        get_cycle(rpt_yr),
        to_timestamp(cvg_end_dt) asc
),
-- issue #2631:Add additional fields and filters to /totals/{committee-type} endpoint
committee_info as (
    select distinct on (cmte_id, fec_election_yr)
        cmte_id, 
        fec_election_yr,
        cmte_nm,
        cmte_tp, 
        cmte_dsgn,
        cmte_pty_affiliation_desc
    from disclosure.cmte_valid_fec_yr
)
    select
        get_cycle(vsd.rpt_yr) as cycle,
        max(last.candidate_id) as candidate_id,
        max(last.candidate_name) as candidate_name,
        max(last.committee_name) as committee_name,
        max(last.beginning_image_number) as last_beginning_image_number,
        max(last.coh_cop) as last_cash_on_hand_end_period,
        max(last.debts_owed_by_cmte) as last_debts_owed_by_committee, -- confirm this is outstanding debt and not a total taken out this period
        max(last.debts_owed_to_cmte) as last_debts_owed_to_committee, -- confirm this is outstanding debt and not a total taken out this period
        max(last.net_contb) as last_net_contributions,
        max(last.net_op_exp) as last_net_operating_expenditures,
        max(last.report_type) as last_report_type,
        max(last.report_type_full) as last_report_type_full,
        max(last.rpt_yr) as last_report_year,
        max(last.coverage_end_date) as coverage_end_date,
        max(vsd.orig_sub_id) as sub_id,
        min(first.cash_on_hand) as cash_on_hand_beginning_period,
        min(first.coverage_start_date) as coverage_start_date,
        sum(vsd.all_loans_received_per) as all_loans_received,
        sum(vsd.cand_cntb) as candidate_contribution,
        sum(vsd.cand_loan_repymnt + vsd.oth_loan_repymts) as loan_repayments_made,
        sum(vsd.cand_loan_repymnt) as loan_repayments_candidate_loans,
        sum(vsd.cand_loan) as loans_made_by_candidate, -- f3
        sum(vsd.cand_loan_repymnt) as repayments_loans_made_by_candidate, -- f3p
        sum(vsd.cand_loan) as loans_received_from_candidate,
        sum(vsd.coord_exp_by_pty_cmte_per) as coordinated_expenditures_by_party_committee,
        sum(vsd.exempt_legal_acctg_disb) as exempt_legal_accounting_disbursement,
        sum(vsd.fed_cand_cmte_contb_per) as fed_candidate_committee_contributions,
        sum(vsd.fed_cand_contb_ref_per) as fed_candidate_contribution_refunds,
        sum(vsd.fed_funds_per) > 0 as federal_funds_flag,
        sum(vsd.fed_funds_per) as fed_disbursements, -- f3x -- not sure
        sum(vsd.fed_funds_per) as federal_funds, -- f3
        sum(vsd.fndrsg_disb) as fundraising_disbursements,
        sum(vsd.indv_contb) as individual_contributions,
        sum(vsd.indv_item_contb) as individual_itemized_contributions,
        sum(vsd.indv_ref) as refunded_individual_contributions,
        sum(vsd.indv_unitem_contb) as individual_unitemized_contributions,
        sum(vsd.loan_repymts_received_per) as loan_repayments_received,
        sum(vsd.loans_made_per) as loans_made,
        sum(vsd.net_contb) as net_contributions,
        sum(vsd.net_op_exp) as net_operating_expenditures,
        sum(vsd.non_alloc_fed_elect_actvy_per) as non_allocated_fed_election_activity,
        sum(vsd.offsets_to_fndrsg) as offsets_to_fundraising_expenditures,
        sum(vsd.offsets_to_legal_acctg) as offsets_to_legal_accounting,
        sum(vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg + vsd.offsets_to_legal_acctg) as total_offsets_to_operating_expenditures, -- f3p
        sum(vsd.offsets_to_op_exp) as offsets_to_operating_expenditures,
        sum(vsd.op_exp_per) as operating_expenditures,
        sum(vsd.oth_cmte_contb) as other_political_committee_contributions,
        sum(vsd.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(vsd.oth_loan_repymts) as loan_repayments_other_loans, -- f3, f3x
        sum(vsd.oth_loan_repymts) as repayments_other_loans, -- f3p
        sum(vsd.oth_loans) as all_other_loans, -- f3
        sum(vsd.oth_loans) as other_loans_received, -- f3p
        sum(vsd.other_disb_per) as other_disbursements,
        sum(vsd.other_fed_op_exp_per) as other_fed_operating_expenditures,
        sum(vsd.other_receipts) as other_fed_receipts, -- f3x
        sum(vsd.other_receipts) as other_receipts, --f3p
        sum(vsd.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(vsd.pty_cmte_contb) as political_party_committee_contributions,
        sum(vsd.shared_fed_actvy_fed_shr_per) as shared_fed_activity,
        sum(vsd.shared_fed_actvy_nonfed_per) as allocated_federal_election_levin_share, --f3x
        sum(vsd.shared_fed_actvy_nonfed_per) as shared_fed_activity_nonfed, --f3x
        sum(vsd.shared_fed_op_exp_per) as shared_fed_operating_expenditures,
        sum(vsd.shared_nonfed_op_exp_per) as shared_nonfed_operating_expenditures,
        sum(vsd.tranf_from_nonfed_acct_per) as transfers_from_nonfed_account,
        sum(vsd.tranf_from_nonfed_levin_per) as transfers_from_nonfed_levin,
        sum(vsd.tranf_from_other_auth_cmte) as transfers_from_affiliated_committee, -- f3p
        sum(vsd.tranf_from_other_auth_cmte) as transfers_from_affiliated_party, -- f3x
        sum(vsd.tranf_from_other_auth_cmte) as transfers_from_other_authorized_committee, -- f3
        sum(vsd.tranf_to_other_auth_cmte) as transfers_to_affiliated_committee, -- f3, f3p
        sum(vsd.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee, -- f3x
        sum(vsd.ttl_contb_ref) as contribution_refunds,
        sum(vsd.ttl_contb) as contributions,
        sum(vsd.ttl_disb) as disbursements,
        sum(vsd.ttl_fed_elect_actvy_per) as fed_election_activity,
        -- sum(vsd.ttl_fed_op_exp_per) as fed_operating_expenditures, -- not in debtsum
        sum(vsd.ttl_fed_receipts_per) as fed_receipts,
        sum(vsd.ttl_loan_repymts) as loan_repayments,
        sum(vsd.ttl_loans) as loans_received, -- f3p
        sum(vsd.ttl_loans) as loans, -- f3
        sum(vsd.ttl_nonfed_tranf_per) as total_transfers,
        sum(vsd.ttl_receipts) as receipts,
        max(committee_info.cmte_tp) as committee_type, 
        max(expand_committee_type(committee_info.cmte_tp)) as committee_type_full,
        max(committee_info.cmte_dsgn) as committee_designation,
        max(expand_committee_designation(committee_info.cmte_dsgn)) as committee_designation_full,
        max(committee_info.cmte_pty_affiliation_desc) as party_full,
        -- max(expand_committee_type(committee_info.cmte_pty_affiliation_desc)) as party_full,
        vsd.cmte_id as committee_id,

        -- double check this makes sense down stream
        -- form type can change if a committee changes this should create 2 records
        vsd.form_tp_cd as form_type,
        -- make it null by form type to be clear candidate's can't do independent expenditures
        case
            when max(last.form_type) in ('F3', 'F3P') then
                Null
            else
                sum(indt_exp_per)
        end as independent_expenditures
    from disclosure.v_sum_and_det_sum_report vsd
        --this was filtering results in the tests, do we really want this to be as restrictive as an inner join? -jcc
        left join last on vsd.cmte_id = last.cmte_id and get_cycle(vsd.rpt_yr) = last.cycle
        left join first on
            vsd.cmte_id = first.committee_id and
            get_cycle(vsd.rpt_yr) = first.cycle
        -- issue #2631:Add additional fields and filters to /totals/{committee-type} endpoint
        left join committee_info on vsd.cmte_id = committee_info.cmte_id and
            get_cycle(vsd.rpt_yr) = committee_info.fec_election_yr
    where
        get_cycle(vsd.rpt_yr) >= :START_YEAR
        -- issue #2601: F5 has both regular and 24/48 notices data included in disclosure.v_sum_and_det_sum_report, need to exclude the 24/48 hours notice data
        and (vsd.form_tp_cd != 'F5' or (vsd.form_tp_cd = 'F5' and vsd.rpt_tp not in ('24','48')))
        and vsd.form_tp_cd != 'F6'
    group by
        vsd.cmte_id,
        vsd.form_tp_cd,
        get_cycle(vsd.rpt_yr)
;

create unique index on ofec_totals_combined_mv_tmp (sub_id);

create index on ofec_totals_combined_mv_tmp (committee_id, sub_id);
create index on ofec_totals_combined_mv_tmp (cycle, sub_id);
create index on ofec_totals_combined_mv_tmp (receipts, sub_id);
create index on ofec_totals_combined_mv_tmp (disbursements, sub_id);
create index on ofec_totals_combined_mv_tmp (committee_type_full, sub_id);
create index on ofec_totals_combined_mv_tmp (committee_designation_full, sub_id);

