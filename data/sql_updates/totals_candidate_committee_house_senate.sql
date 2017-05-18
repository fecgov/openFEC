-- House/Senate totals are same process as presidential but in separate file to handle columns that are
-- unique to a congressional candidate.  Otherwise aggregation and relations are the same.

-- Note: Beginning cash on hand, ending cash on hand debts and loans are all numbers that
-- represent a the total amount of something at point in time and should not be added.
-- Adding cycle to the sort helps if there is a null date - this was a problem at some point.

drop materialized view if exists ofec_totals_candidates_committees_house_senate_mv_tmp;
create materialized view ofec_totals_candidate_committees_house_senate_mv_tmp as
-- get ending financials from most recent report of the cycle for all primary committees
with last_cycle as (
    select distinct on (f3.cmte_id, link.fec_election_yr)
        f3.cmte_id,
        f3.rpt_yr,
        f3.coh_cop as last_cash_on_hand_end_period,
        f3.cvg_end_dt,
        f3.debts_owed_by_cmte as debts_owed_by_committee,
        f3.debts_owed_to_cmte as debts_owed_to_committee,
        of.report_type_full as last_report_type_full,
        of.beginning_image_number,
        f3.cmte_id as committee_id,
        link.fec_election_yr as cycle
    from disclosure.v_sum_and_det_sum_report f3
        inner join disclosure.cand_cmte_linkage link on link.cmte_id = f3.cmte_id
        left join ofec_filings_mv_tmp of on of.sub_id = f3.orig_sub_id
    where
        f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and link.fec_election_yr >= :START_YEAR
    order by
        f3.cmte_id,
        link.fec_election_yr,
        f3.cvg_end_dt desc
    ),
    -- oldest report of the 2-year cycle to see how much cash the committee started with
    first_cycle as (
    select distinct on (f3.cmte_id, link.fec_election_yr)
        link.cand_id as candidate_id,
        f3.cmte_id as committee_id,
        link.fec_election_yr as cycle,
        link.cand_election_yr as election_year,
        f3.cvg_start_dt as cvg_start_dt,
        f3.coh_bop as cash_on_hand_beginning_of_period
    from
        disclosure.v_sum_and_det_sum_report f3
            inner join disclosure.cand_cmte_linkage link on link.cmte_id = f3.cmte_id
    where
        f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and link.fec_election_yr >= :START_YEAR
    order by
        f3.cmte_id,
        link.fec_election_yr,
        f3.cvg_end_dt asc
    ),
    -- Oldest report of the 2-year House or 6-year Senate cycle to see how much cash the committee started with
    -- We don't need this for last, because the 6 year cycle is labeled with the last year so the join is the same.
    first_election as (
    select distinct on (committee_id, election_year) *
    from first_cycle
    order by
        committee_id,
        election_year,
        cvg_start_dt desc
    ),
    -- totals per candidate, per two-year cycle, with firsts and lasts
    cycle_totals as(
    select
        link.cand_id as candidate_id,
        link.fec_election_yr as cycle,
        -- double check this
        max(link.cand_election_yr) as election_year,
        min(first.cvg_start_dt) as coverage_start_date,
        max(last.cvg_end_dt) as coverage_end_date,
        sum(hs.oth_loans) as all_other_loans,
        sum(hs.cand_cntb) as candidate_contribution,
        sum(hs.ttl_contb_ref) as contribution_refunds,
        sum(hs.ttl_contb) as contributions,
        sum(hs.ttl_disb) as disbursements,
        sum(hs.indv_contb) as individual_contributions,
        sum(hs.indv_item_contb) as individual_itemized_contributions,
        sum(hs.indv_unitem_contb) as individual_unitemized_contributions,
        sum(hs.ttl_loan_repymts) as loan_repayments,
        sum(hs.cand_loan_repymnt) as loan_repayments_candidate_loans,
        sum(hs.oth_loan_repymts) as loan_repayments_other_loans,
        sum(hs.ttl_loans) as loans,
        sum(hs.cand_loan) as loans_made_by_candidate,
        sum(hs.net_contb) as net_contributions,
        sum(hs.net_op_exp) as net_operating_expenditures,
        sum(hs.offsets_to_op_exp) as offsets_to_operating_expenditures,
        sum(hs.op_exp_per) as operating_expenditures,
        sum(hs.other_disb_per) as other_disbursements,
        sum(hs.oth_cmte_contb) as other_political_committee_contributions,
        sum(hs.other_receipts) as other_receipts,
        sum(hs.pty_cmte_contb) as political_party_committee_contributions,
        sum(hs.ttl_receipts) as receipts,
        sum(hs.indv_ref) as refunded_individual_contributions,
        sum(hs.oth_cmte_ref) as refunded_other_political_committee_contributions,
        sum(hs.pol_pty_cmte_contb) as refunded_political_party_committee_contributions,
        sum(hs.tranf_from_other_auth_cmte) as transfers_from_other_authorized_committee,
        sum(hs.tranf_to_other_auth_cmte) as transfers_to_other_authorized_committee,
        -- these are added in the event that a candidate has multiple committees
        sum(last.last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
        max(last.last_report_type_full) as last_report_type_full,
        sum(last.debts_owed_to_committee) as last_debts_owed_to_committee,
        sum(last.debts_owed_by_committee) as last_debts_owed_by_committee,
        -- this should be an array
        min(last.beginning_image_number) as last_beginning_image_number,
        max(last.rpt_yr) as last_report_year,
        sum(first.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period,
        false as full_election
    from
        -- starting with candidate will consolidate record in the event that a candidate has multiple committees
        disclosure.cand_cmte_linkage link
        left join disclosure.v_sum_and_det_sum_report hs on link.cmte_id = hs.cmte_id and link.fec_election_yr = get_cycle(hs.rpt_yr)
        left join last_cycle last on link.cmte_id = last.cmte_id and link.fec_election_yr = last.cycle
        left join first_cycle first on link.cmte_id = first.committee_id and link.fec_election_yr = first.cycle
    where
        link.fec_election_yr >= :START_YEAR
        and hs.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    group by
        link.fec_election_yr,
        link.cand_id
    ),
    -- this creates totals by election period, 2 yrs for House, 6 yrs for Senate
    election_totals as (
        select
            totals.candidate_id as candidate_id,
            max(totals.cycle) as cycle,
            max(totals.election_year) as election_year,
            min(first.cvg_start_dt) as coverage_start_date,
            max(totals.coverage_end_date) as coverage_end_date,
            sum(totals.all_other_loans) as all_other_loans,
            sum(totals.candidate_contribution) as candidate_contribution,
            sum(totals.contribution_refunds) as contribution_refunds,
            sum(totals.contributions) as contributions,
            sum(totals.disbursements) as disbursements,
            sum(totals.individual_contributions) as individual_contributions,
            sum(totals.individual_itemized_contributions) as individual_itemized_contributions,
            sum(totals.individual_unitemized_contributions) as individual_unitemized_contributions,
            sum(totals.loan_repayments) as loan_repayments,
            sum(totals.loan_repayments_candidate_loans) as loan_repayments_candidate_loans,
            sum(totals.loan_repayments_other_loans) as loan_repayments_other_loans,
            sum(totals.loans) as loans,
            sum(totals.loans_made_by_candidate) as loans_made_by_candidate,
            sum(totals.net_contributions) as net_contributions,
            sum(totals.net_operating_expenditures) as net_operating_expenditures,
            sum(totals.offsets_to_operating_expenditures) as offsets_to_operating_expenditures,
            sum(totals.operating_expenditures) as operating_expenditures,
            sum(totals.other_disbursements) as other_disbursements,
            sum(totals.other_political_committee_contributions) as other_political_committee_contributions,
            sum(totals.other_receipts) as other_receipts,
            sum(totals.political_party_committee_contributions) as political_party_committee_contributions,
            sum(totals.receipts) as receipts,
            sum(totals.refunded_individual_contributions) as refunded_individual_contributions,
            sum(totals.refunded_other_political_committee_contributions) as refunded_other_political_committee_contributions,
            sum(totals.refunded_political_party_committee_contributions) as refunded_political_party_committee_contributions,
            sum(totals.transfers_from_other_authorized_committee) as transfers_from_other_authorized_committee,
            sum(totals.transfers_to_other_authorized_committee) as transfers_to_other_authorized_committee,
            -- these are added in the event that a candidate has multiple committees
            sum(totals.last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
            max(totals.last_report_type_full) as last_report_type_full,
            sum(totals.last_debts_owed_to_committee) as last_debts_owed_to_committee,
            sum(totals.last_debts_owed_by_committee) as last_debts_owed_by_committee,
            sum(first.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period,
            -- this could be an array if we wanted to be precise
            max(totals.last_beginning_image_number) as last_beginning_image_number,
            max(totals.last_report_year) as last_report_year,
            true as full_election
        from
            cycle_totals totals
            left join first_election first using (candidate_id, election_year)
            -- We don't need this for last, because the 6 year cycle is labeled with the last year so the join is the same.
        group by
            totals.candidate_id,
            -- this is where the senate records are combined into 6 year election periods
            totals.election_year
        )
        -- combining cycle totals and election totals into a single table that can be filtered with the full_election boolean downstream

        select * from cycle_totals
        union all
        select * from election_totals
;

create unique index on ofec_totals_candidate_committees_house_senate_mv_tmp (candidate_id, cycle, full_election);

create index on ofec_totals_candidate_committees_house_senate_mv_tmp (candidate_id);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (election_year);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (cycle);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (receipts);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (disbursements);