-- House/Senate totals are same process as presidential but in separate file to handle columns that are
-- unique to a congressional candidate.  Otherwise aggregation and relations are the same.

-- Note Beginning cash on hand, ending cash on hand debts and loans are all numbers that
-- represent a the total amount of something at point in time and should not be added.

drop materialized view if exists ofec_totals_candidates_committees_house_senate_mv_tmp;
create materialized view ofec_totals_candidate_committees_house_senate_mv_tmp as
-- most recent report of the cycle
with last as (
    select distinct on (f3.cmte_id, link.cand_election_yr)
        f3.rpt_yr,
        f3.orig_sub_id as sub_id,
        f3.coh_cop,
        f3.cvg_end_dt,
        f3.debts_owed_by_cmte,
        f3.debts_owed_to_cmte,
        of.report_type_full as last_report_type_full,
        of.beginning_image_number as last_beginning_image_number,
        link.cand_id as candidate_id,
        link.cand_election_yr as election_cycle
    from disclosure.v_sum_and_det_sum_report f3
        inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3.cmte_id
        -- TO DO add to flow
        left join ofec_filings_mv of using (sub_id)
    where
        f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and election_cycle >= :START_YEAR
    order by
        f3.cmte_id,
        link.cand_election_yr,
        f3.cvg_end_dt desc
    ),
    -- oldest report of the cycle to see how much cash the committee started with
    first as (
    select distinct on (f3.cmte_id, link.cand_election_yr) link.cand_id as candidate_id,
          f3.cmte_id as committee_id,
          link.cand_id as candidate_id,
          link.cand_election_yr as cycle,
          f3.cvg_start_dt as cvg_start_dt,
          f3.coh_bop as cash_on_hand_beginning_of_period
    from
        disclosure.v_sum_and_det_sum_report f3
            inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3.cmte_id
    where
        rpt_yr >= :START_YEAR
        and f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    order by
        f3.cmte_id,
        link.cand_election_yr,
        f3.cvg_end_dt asc
),
    -- totals per candidate, per two-year cycle, with firsts and lasts
    cycle_totals as(
    select
    -- check vars
        link.cand_id as candidate_id,
        hs.election_cycle as cycle,
        hs.election_cycle as election_year,
        min(hs.cvg_start_dt) as coverage_start_date,
        max(last.cvg_end_dt) as coverage_end_date,
        sum(hs.all_other_loans_per) as all_other_loans,
        sum(hs.cand_contb_per) as candidate_contribution,
        sum(hs.ttl_contb_ref_per) as contribution_refunds,
        sum(hs.ttl_contb_per) as contributions,
        sum(hs.ttl_disb_per) as disbursements,
        sum(hs.ttl_indv_contb_per) as individual_contributions,
        sum(hs.indv_item_contb_per) as individual_itemized_contributions,
        sum(hs.indv_unitem_contb_per) as individual_unitemized_contributions,
        sum(hs.ttl_loan_repymts_per) as loan_repayments,
        sum(hs.loan_repymts_cand_loans_per) as loan_repayments_candidate_loans,
        sum(hs.loan_repymts_other_loans_per) as loan_repayments_other_loans,
        sum(hs.ttl_loans_per) as loans,
        sum(hs.loans_made_by_cand_per) as loans_made_by_candidate,
        sum(hs.net_contb_per) as net_contributions,
        sum(hs.net_op_exp_per) as net_operating_expenditures,
        sum(hs.offsets_to_op_exp_per) as offsets_to_operating_expenditures,
        sum(hs.ttl_op_exp_per) as operating_expenditures,
        sum(hs.other_disb_per) as other_disbursements,
        sum(hs.other_pol_cmte_contb_per) as other_political_committee_contributions,
        sum(hs.other_receipts_per) as other_receipts,
        sum(hs.pol_pty_cmte_contb_per) as political_party_committee_contributions,
        sum(hs.ttl_receipts_per) as receipts,
        sum(hs.ref_indv_contb_per) as refunded_individual_contributions,
        sum(hs.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
        sum(hs.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
        sum(hs.tranf_from_other_auth_cmte_per) as transfers_from_other_authorized_committee,
        sum(hs.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
        max(last.last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
        max(last.last_report_type_full) as last_report_type_full,
        max(last.last_debts_owed_to_committee) as last_debts_owed_to_committee,
        max(last.last_debts_owed_by_committee) as last_debts_owed_by_committee,
        max(last.last_beginning_image_number) as last_beginning_image_number,
        max(last.last_report_year) as last_report_year,
        min(cbp.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period,
        false as full_election
    from
        ofec_cand_cmte_linkage_mv_tmp link
        left join disclosure.v_sum_and_det_sum_report hs on link.cmte_id = hs.cmte_id and link.fec_election_yr = hs.election_cycle
        left join last on link.cmte_id = hs.cmte_id and link.fec_election_yr = hs.election_cycle
        left join cash_beginning_period cbp on link.cmte_id = hs.cmte_id and link.fec_election_yr = hs.election_cycle
    where
        hs.election_cycle >= :START_YEAR
        and f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    group by
        hs.election_cycle,
        link.cand_id
    ),
    -- this creates totals by election period, 2 yrs for House, 6 yrs for Senate
    election_totals as (
        select
            totals.candidate_id as candidate_id,
            max(totals.cycle) as cycle,
            max(totals.election_year) as election_year,
            min(totals.coverage_start_date) as coverage_start_date,
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
            max(last.last_cash_on_hand_end_period) as last_cash_on_hand_end_period,
            max(last.last_report_type_full) as last_report_type_full,
            max(last.last_debts_owed_to_committee) as last_debts_owed_to_committee,
            max(last.last_debts_owed_by_committee) as last_debts_owed_by_committee,
            max(last.last_beginning_image_number) as last_beginning_image_number,
            max(last.last_report_year) as last_report_year,
            min(cbp.cash_on_hand_beginning_of_period) as cash_on_hand_beginning_of_period
            true as full_election
        from cycle_totals totals
        inner join ofec_candidate_election_mv_tmp election on
            totals.candidate_id = election.candidate_id and
            totals.cycle <= election.cand_election_year and
            totals.cycle > election.prev_election_year
        group by
            totals.candidate_id,
            -- this is where the senate records are combined into 6 year election periods
            election.cand_election_year
        where totals.cycle > :START_YEAR

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