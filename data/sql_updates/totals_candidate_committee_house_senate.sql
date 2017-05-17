--House/Senate totals are same process as presidential but in separate file to handle columns that are
--unique to a congressional candidate.  Otherwise aggregation and relations are the same.
drop materialized view if exists ofec_totals_candidates_committees_house_senate_mv_tmp;
create materialized view ofec_totals_candidate_committees_house_senate_mv_tmp as
with last as (
    select distinct on (f3.cmte_id, link.cand_election_yr) f3.*,
        link.cand_id as candidate_id,
        link.cand_election_yr as election_cycle
    from disclosure.v_sum_and_det_sum_report f3
    inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3.cmte_id
    where
        f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and election_cycle >= :START_YEAR
    order by
        f3.cmte_id,
        election_cycle,
        f3.cvg_end_dt desc
), aggregate_last as(
    select last.election_cycle as cycle,
        last.candidate_id,
        max(last.rpt_tp_desc) as last_report_type_full,
        max(last.begin_image_num) as last_beginning_image_number,
        sum(last.coh_cop) as last_cash_on_hand_end_period,
        sum(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        sum(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from last
    group by
        last.election_cycle,
        last.candidate_id
), cash_beginning_period as (
    select distinct on (f3.cmte_id, f3.election_cycle) link.cand_id as candidate_id,
          f3.cmte_id as committee_id,
          f3.election_cycle as cycle,
          f3.coh_bop as cash_on_hand
      from
        fec_vsum_f3_vw f3
            inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3.cmte_id
    where
        f3.most_recent_filing_flag like 'Y'
        and f3.election_cycle >= :START_YEAR
        and f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
), cash_beginning_period_aggregate as (
      select sum(cash_beginning_period.cash_on_hand) as cash_on_hand_beginning_of_period,
        cash_beginning_period.cycle,
        cash_beginning_period.candidate_id
      from cash_beginning_period
      group by
        cash_beginning_period.cycle,
        cash_beginning_period.candidate_id

), cycle_totals as(
    select
        link.cand_id as candidate_id,
        hs.election_cycle as cycle,
        hs.election_cycle as election_year,
        min(hs.cvg_start_dt) as coverage_start_date,
        max(hs.cvg_end_dt) as coverage_end_date,
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
        sum(hs.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee
    from
        ofec_cand_cmte_linkage_mv_tmp link
        inner join fec_vsum_f3_vw hs on link.cmte_id = hs.cmte_id and link.fec_election_yr = hs.election_cycle
    where
        hs.most_recent_filing_flag like 'Y'
        and hs.election_cycle >= :START_YEAR
        and f3.form_tp_cd = 'F3'
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')

    group by
        hs.election_cycle,
        link.cand_id
    ), last_totals as (
        select
            c_totals.*,
            false as full_election,
            aggregate_last.last_cash_on_hand_end_period,
            aggregate_last.last_report_type_full,
            aggregate_last.last_debts_owed_to_committee,
            aggregate_last.last_debts_owed_by_committee,
            aggregate_last.last_beginning_image_number,
            aggregate_last.last_report_year,
            cash_beginning_period_aggregate.cash_on_hand_beginning_of_period
        from cycle_totals c_totals
        inner join aggregate_last on aggregate_last.cycle = c_totals.cycle and aggregate_last.candidate_id = c_totals.candidate_id
        inner join cash_beginning_period_aggregate on cash_beginning_period_aggregate.cycle = c_totals.cycle and cash_beginning_period_aggregate.candidate_id = c_totals.candidate_id
    ), intermediate_combined_totals as (
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
                true as full_election
        from last_totals totals
        inner join ofec_candidate_election_mv_tmp election on
            totals.candidate_id = election.candidate_id and
            totals.cycle <= election.cand_election_year and
            totals.cycle > election.prev_election_year
        group by
            totals.candidate_id,
            election.cand_election_year
        ), combined_totals as (
            select ict.*,
                totals.last_cash_on_hand_end_period,
                totals.last_report_type_full,
                totals.last_debts_owed_to_committee,
                totals.last_debts_owed_by_committee,
                totals.last_beginning_image_number,
                totals.last_report_year
                --0.0 as cash_on_hand_beginning_of_period
            from last_totals totals
            inner join ofec_candidate_election_mv_tmp election on
                totals.candidate_id = election.candidate_id and
                totals.cycle = election.cand_election_year
            inner join intermediate_combined_totals ict on totals.candidate_id = ict.candidate_id and totals.cycle = ict.cycle
            where totals.cycle > :START_YEAR

        ), cash_period_aggregate as(
            select
                p_totals.cash_on_hand_beginning_of_period,
                election.cand_election_year,
                p_totals.candidate_id
            from
                ofec_candidate_election_mv_tmp election
                inner join last_totals p_totals on election.candidate_id = p_totals.candidate_id
                and p_totals.cycle = election.prev_election_year + 2 and p_totals.cycle < election.cand_election_year
        ), final_combined_total as (
            select ct.*,
            cpa.cash_on_hand_beginning_of_period
            from combined_totals ct
            inner join cash_period_aggregate cpa on ct.candidate_id = cpa.candidate_id and ct.cycle = cpa.cand_election_year
        )

        select * from last_totals
        union all
        select * from final_combined_total
;

create unique index on ofec_totals_candidate_committees_house_senate_mv_tmp (candidate_id, cycle, full_election);

create index on ofec_totals_candidate_committees_house_senate_mv_tmp (candidate_id);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (election_year);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (cycle);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (receipts);
create index on ofec_totals_candidate_committees_house_senate_mv_tmp (disbursements);