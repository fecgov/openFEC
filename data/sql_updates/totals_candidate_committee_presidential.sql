-- House/Senate totals are same process as presidential but in separate file to handle columns that are
-- unique to a congressional candidate.  Otherwise aggregation and relations are the same.

-- Note: Beginning cash on hand, ending cash on hand debts and loans are all numbers that
-- represent a the total amount of something at point in time and should not be added.
-- Adding cycle to the sort helps if there is a null date - this was a problem at some point.

drop materialized view if exists ofec_totals_candidate_committees_presidential_mv_tmp;
create materialized view ofec_totals_candidate_committees_presidential_mv_tmp as
-- get ending financials from most recent report of the cycle for all primary committees
with last_cycle as (
    select distinct on (f3p.cmte_id, link.fec_election_yr)
        f3p.cmte_id,
        f3p.rpt_yr as report_year,
        f3p.coh_cop as cash_on_hand_end_period,
        case when f3p.cvg_start_dt = 99999999 then null::timestamp
          else cast(cast(f3p.cvg_start_dt as text) as date) end
        as coverage_start_date,
        cast(cast(f3p.cvg_end_dt as text) as timestamp) as coverage_end_date,
        f3p.debts_owed_by_cmte as debts_owed_by_committee,
        f3p.debts_owed_to_cmte as debts_owed_to_committee,
        of.report_type_full as report_type_full,
        of.beginning_image_number,
        link.cand_id as candidate_id,
        link.fec_election_yr as cycle,
        link.cand_election_yr as election_year
    from disclosure.v_sum_and_det_sum_report f3p
        inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3p.cmte_id
        left join ofec_filings_mv_tmp of on of.sub_id = f3p.orig_sub_id
    where
        f3p.form_tp_cd = 'F3P'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and link.fec_election_yr >= :START_YEAR
    order by
        f3p.cmte_id,
        link.fec_election_yr,
        f3p.cvg_end_dt desc
    ),
    -- newest report of the 4-year Presidential cycle
    last_election as (
    select distinct on (cmte_id, election_year) *
    from last_cycle
    order by
        cmte_id,
        election_year,
        coverage_end_date desc
    ),
    -- oldest report of the cycle to see how much cash the committee started with and beginning coverage date
    first_cycle as (
    select distinct on (f3p.cmte_id, link.cand_election_yr)
        link.cand_id as candidate_id,
        f3p.cmte_id as committee_id,
        link.fec_election_yr as cycle,
        link.cand_election_yr as election_year,
        case when f3p.cvg_start_dt = 99999999 then null::timestamp
          else cast(cast(f3p.cvg_start_dt as text) as date)
        end
        as cvg_start_dt,
        f3p.coh_bop as cash_on_hand_beginning_of_period
    from disclosure.v_sum_and_det_sum_report f3p
        inner join disclosure.cand_cmte_linkage link on link.cmte_id = f3p.cmte_id
    where
        rpt_yr >= :START_YEAR
        and f3p.form_tp_cd = 'F3P'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    order by
        f3p.cmte_id,
        link.cand_election_yr,
        f3p.cvg_end_dt asc
    ),
    -- Oldest report of the 4-year Presidential cycle to see how much cash the committee started with
    first_election as (
    select distinct on (committee_id, election_year) *
    from first_cycle
    order by
        committee_id,
        election_year,
        cvg_start_dt asc
    ),
    -- totals per candidate, per two-year cycle, with firsts and lasts
    cycle_totals as(
    select
        link.cand_id as candidate_id,
        max(link.fec_election_yr) as cycle,
        max(link.fec_election_yr) as election_year,
        max(last.coverage_end_date) as coverage_end_date,
        sum(p.cand_cntb) as candidate_contribution,
        sum(p.pol_pty_cmte_contb + p.oth_cmte_ref) as contribution_refunds,
        sum(p.ttl_contb) as contributions,
        sum(p.ttl_disb) as disbursements,
        sum(p.exempt_legal_acctg_disb) as exempt_legal_accounting_disbursement,
        sum(p.fed_funds_per) as federal_funds,
        sum(p.fed_funds_per) > 0 as federal_funds_flag,
        sum(p.fndrsg_disb) as fundraising_disbursements,
        sum(p.indv_ref) as individual_contributions,-- unfortunately, a wrong name in v_sum
        sum(p.indv_unitem_contb) as individual_unitemized_contributions,
        sum(p.indv_item_contb) as individual_itemized_contributions,
        sum(p.ttl_loans) as loans_received,
        sum(p.cand_loan) as loans_received_from_candidate,
        sum(p.cand_loan_repymnt + p.oth_loan_repymts) as loan_repayments_made,
        sum(p.offsets_to_fndrsg) as offsets_to_fundraising_expenditures,
        sum(p.offsets_to_legal_acctg) as offsets_to_legal_accounting,
        sum(p.offsets_to_op_exp) as offsets_to_operating_expenditures,
        sum(p.offsets_to_op_exp + p.offsets_to_fndrsg + p.offsets_to_legal_acctg) as total_offsets_to_operating_expenditures,
        sum(p.op_exp_per) as operating_expenditures,
        sum(p.other_disb_per) as other_disbursements,
        sum(p.oth_loans) as other_loans_received,
        sum(p.oth_cmte_contb) as other_political_committee_contributions,
        sum(p.other_receipts) as other_receipts,
        sum(p.pty_cmte_contb) as political_party_committee_contributions,
        sum(p.ttl_receipts) as receipts,
        sum(p.indv_ref) as refunded_individual_contributions, -- renamed from "refunds_"
        sum(p.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(p.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(p.cand_loan_repymnt) as repayments_loans_made_by_candidate,
        sum(p.oth_loan_repymts) as repayments_other_loans,
        sum(p.tranf_from_other_auth_cmte) as transfers_from_affiliated_committee,
        sum(p.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        sum(p.net_op_exp) as net_operating_expenditures,
        sum(p.net_contb) as net_contributions,
        -- these are added in the event that a candidate has multiple committees
        false as full_election,
        coalesce(min(first.cvg_start_dt), min(last.coverage_start_date)) as coverage_start_date,
        sum(last.cash_on_hand_end_period) as last_cash_on_hand_end_period,
        max(last.report_type_full) as last_report_type_full,
        sum(last.debts_owed_to_committee) as last_debts_owed_to_committee,
        sum(last.debts_owed_by_committee) as last_debts_owed_by_committee,
        max(last.beginning_image_number) as last_beginning_image_number,
        max(last.report_year) as last_report_year,
        min(first.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period
    from
        -- starting with candidate will consolidate record in the event that a candidate has multiple committees
        ofec_cand_cmte_linkage_mv_tmp link
        left join disclosure.v_sum_and_det_sum_report p on link.cmte_id = p.cmte_id and link.fec_election_yr = get_cycle(p.rpt_yr)
        left join last_cycle last on link.cmte_id = last.cmte_id and link.fec_election_yr = last.cycle
        left join first_cycle first on link.cmte_id = first.committee_id and link.fec_election_yr = first.cycle
    where
        link.fec_election_yr >= :START_YEAR
        and p.form_tp_cd = 'F3P'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    group by
        link.fec_election_yr,
        link.cand_id
    ),
    election_totals as (
        select
            totals.candidate_id as candidate_id,
            max(totals.cycle) as cycle,
            max(totals.election_year) as election_year,
            max(totals.coverage_end_date) as coverage_end_date,
            sum(totals.candidate_contribution) as candidate_contribution,
            sum(totals.contribution_refunds) as contribution_refunds,
            sum(totals.contributions) as contributions,
            sum(totals.disbursements) as disbursements,
            sum(totals.exempt_legal_accounting_disbursement) as exempt_legal_accounting_disbursement,
            sum(totals.federal_funds) as federal_funds,
            sum(totals.federal_funds) > 0 as federal_funds_flag,
            sum(totals.fundraising_disbursements) as fundraising_disbursements,
            sum(totals.individual_contributions) as individual_contributions,
            sum(totals.individual_unitemized_contributions) as individual_unitemized_contributions,
            sum(totals.individual_itemized_contributions) as individual_itemized_contributions,
            sum(totals.loans_received) as loans_received,
            sum(totals.loans_received_from_candidate) as loans_received_from_candidate,
            sum(totals.loan_repayments_made) as loan_repayments_made,
            sum(totals.offsets_to_fundraising_expenditures) as offsets_to_fundraising_expenditures,
            sum(totals.offsets_to_legal_accounting) as offsets_to_legal_accounting,
            sum(totals.offsets_to_operating_expenditures) as offsets_to_operating_expenditures,
            sum(totals.total_offsets_to_operating_expenditures) as total_offsets_to_operating_expenditures,
            sum(totals.operating_expenditures) as operating_expenditures,
            sum(totals.other_disbursements) as other_disbursements,
            sum(totals.other_loans_received) as other_loans_received,
            sum(totals.other_political_committee_contributions) as other_political_committee_contributions,
            sum(totals.other_receipts) as other_receipts,
            sum(totals.political_party_committee_contributions) as political_party_committee_contributions,
            sum(totals.receipts) as receipts,
            sum(totals.refunded_individual_contributions) as refunded_individual_contributions,
            sum(totals.refunded_other_political_committee_contributions) as refunded_other_political_committee_contributions,
            sum(totals.refunded_political_party_committee_contributions) as refunded_political_party_committee_contributions,
            sum(totals.repayments_loans_made_by_candidate) as repayments_loans_made_by_candidate,
            sum(totals.repayments_other_loans ) as repayments_other_loans,
            sum(totals.transfers_from_affiliated_committee) as transfers_from_affiliated_committee,
            sum(totals.transfers_to_other_authorized_committee) as transfers_to_other_authorized_committee,
            sum(totals.net_operating_expenditures) as net_operating_expenditures,
            sum(totals.net_contributions) as net_contributions,
            -- these are added in the event that a candidate has multiple committees
            true as full_election,
            min(totals.coverage_start_date) as coverage_start_date
        from
            cycle_totals totals
            left join ofec_candidate_election_mv_tmp election on
                totals.candidate_id = election.candidate_id and
                totals.cycle <= election.cand_election_year and
                totals.cycle > election.prev_election_year
        group by
            totals.candidate_id,
            -- this is where the senate records are combined into 6 year election periods
            election.cand_election_year
        ),
        begginning_and_ending_totals as(
            select
                first.candidate_id,
                first.election_year,
                --min(first.cvg_start_dt) as coverage_start_date,
                sum(last.cash_on_hand_end_period) as last_cash_on_hand_end_period,
                max(last.report_type_full) as last_report_type_full,
                sum(last.debts_owed_to_committee) as last_debts_owed_to_committee,
                sum(last.debts_owed_by_committee) as last_debts_owed_by_committee,
                sum(first.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period,
                max(last.report_year) as last_report_year,
                max(last.beginning_image_number) as last_beginning_image_number
            from
                first_election first
                left join last_election last on last.candidate_id = first.candidate_id and first.election_year = last.election_year
            group by
                first.candidate_id,
                first.election_year
        ), election_totals_with_begginning_and_ending_totals as(
            select
                election_totals.*,
                --begginning_and_ending_totals.coverage_start_date,
                begginning_and_ending_totals.last_cash_on_hand_end_period,
                begginning_and_ending_totals.last_report_type_full,
                begginning_and_ending_totals.last_debts_owed_to_committee,
                begginning_and_ending_totals.last_debts_owed_by_committee,
                begginning_and_ending_totals.last_beginning_image_number,
                begginning_and_ending_totals.last_report_year,
                begginning_and_ending_totals.cash_on_hand_beginning_of_period
            from election_totals left join begginning_and_ending_totals using(candidate_id, election_year)
        )

        -- combining cycle totals and election totals into a single table that can be filtered with the full_election boolean downstream
        select * from cycle_totals
        union all
        select * from election_totals_with_begginning_and_ending_totals
;
--these columns should be a unique primary key when considered together
create unique index on ofec_totals_candidate_committees_presidential_mv_tmp (candidate_id, cycle, full_election);

create index on ofec_totals_candidate_committees_presidential_mv_tmp (candidate_id);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (election_year);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (cycle);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (receipts);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (disbursements);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (federal_funds_flag);