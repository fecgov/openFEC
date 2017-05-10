drop materialized view if exists ofec_totals_candidate_committees_presidential_mv_tmp;
create materialized view ofec_totals_candidate_committees_presidential_mv_tmp as
--get ending financials for all primary committees
with last as (
    select distinct on (f3p.cmte_id, f3p.election_cycle) f3p.*, link.cand_id
    from fec_vsum_f3p_vw f3p
    inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3p.cmte_id
    where
        substr(link.cand_id, 1, 1) = link.cmte_tp
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
        and election_cycle >= :START_YEAR
    order by
        f3p.cmte_id,
        f3p.election_cycle,
        f3p.cvg_end_dt desc
) --sum the ending totals
  , aggregate_last as(
    select last.election_cycle as cycle,
        last.cand_id as candidate_id,
        sum(last.net_contb_sum_page_per) as net_contributions,
        sum(last.net_op_exp_sum_page_per) as net_operating_expenditures,
        max(last.rpt_tp_desc) as last_report_type_full,
        max(last.begin_image_num) as last_beginning_image_number,
        sum(last.coh_cop) as last_cash_on_hand_end_period,
        sum(last.debts_owed_by_cmte) as last_debts_owed_by_committee,
        sum(last.debts_owed_to_cmte) as last_debts_owed_to_committee,
        max(last.rpt_yr) as last_report_year
    from last
    group by
        last.election_cycle,
        last.cand_id
) --capture needed beginning financial column
  , cash_beginning_period as (
    select distinct on (f3p.cmte_id, f3p.election_cycle) link.cand_id as candidate_id,
          f3p.cmte_id as committee_id,
          f3p.election_cycle as cycle,
          f3p.coh_bop as cash_on_hand
      from
        fec_vsum_f3p_vw f3p
            inner join ofec_cand_cmte_linkage_mv_tmp link on link.cmte_id = f3p.cmte_id
    where
        f3p.most_recent_filing_flag like 'Y'
        and f3p.election_cycle >= :START_YEAR
        and substr(link.cand_id, 1, 1) = link.cmte_tp
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')
    order by
        f3p.cmte_id,
        f3p.election_cycle,
        f3p.cvg_end_dt asc
) --aggregate beggining finance column
  , cash_beginning_period_aggregate as (
      select sum(cash_beginning_period.cash_on_hand) as cash_on_hand_beginning_of_period,
        cash_beginning_period.cycle,
        cash_beginning_period.candidate_id
      from cash_beginning_period
      group by
        cash_beginning_period.cycle,
        cash_beginning_period.candidate_id

) --sum all a candidates totals for a cycle
  , cycle_totals as(
    select
        cand_id as candidate_id,
        p.election_cycle as cycle,
        p.election_cycle as election_year,
        min(p.cvg_start_dt) as coverage_start_date,
        max(p.cvg_end_dt) as coverage_end_date,
        sum(p.cand_contb_per) as candidate_contribution,
        sum(p.ttl_contb_ref_per) as contribution_refunds,
        sum(p.ttl_contb_per) as contributions,
        sum(p.ttl_disb_per) as disbursements,
        sum(p.exempt_legal_acctg_disb_per) as exempt_legal_accounting_disbursement,
        sum(p.fed_funds_per) as federal_funds,
        sum(p.fed_funds_per) > 0 as federal_funds_flag,
        sum(p.fndrsg_disb_per) as fundraising_disbursements,
        sum(p.ttl_indiv_contb_per) as individual_contributions,
        sum(p.indv_unitem_contb_per) as individual_unitemized_contributions,
        sum(p.indv_item_contb_per) as individual_itemized_contributions,
        sum(p.ttl_loans_received_per) as loans_received,
        sum(p.loans_received_from_cand_per) as loans_received_from_candidate,
        sum(p.ttl_loan_repymts_made_per) as loan_repayments_made,
        sum(p.offsets_to_fndrsg_exp_per) as offsets_to_fundraising_expenditures,
        sum(p.offsets_to_legal_acctg_per) as offsets_to_legal_accounting,
        sum(p.offsets_to_op_exp_per) as offsets_to_operating_expenditures,
        sum(p.ttl_offsets_to_op_exp_per) as total_offsets_to_operating_expenditures,
        sum(p.op_exp_per) as operating_expenditures,
        sum(p.other_disb_per) as other_disbursements,
        sum(p.other_loans_received_per) as other_loans_received,
        sum(p.other_pol_cmte_contb_per) as other_political_committee_contributions,
        sum(p.other_receipts_per) as other_receipts,
        sum(p.pol_pty_cmte_contb_per) as political_party_committee_contributions,
        sum(p.ttl_receipts_per) as receipts,
        sum(p.ref_indv_contb_per) as refunded_individual_contributions, -- renamed from "refunds_"
        sum(p.ref_other_pol_cmte_contb_per) as refunded_other_political_committee_contributions,
        sum(p.ref_pol_pty_cmte_contb_per) as refunded_political_party_committee_contributions,
        sum(p.repymts_loans_made_by_cand_per) as repayments_loans_made_by_candidate,
        sum(p.repymts_other_loans_per) as repayments_other_loans,
        sum(p.tranf_from_affilated_cmte_per) as transfers_from_affiliated_committee,
        sum(p.tranf_to_other_auth_cmte_per) as transfers_to_other_authorized_committee,
        sum(p.debts_owed_by_cmte) as debts_owed_by_cmte,
        sum(p.debts_owed_to_cmte) as debts_owed_to_cmte

    from
        ofec_candidate_detail_mv_tmp cand_detail
        inner join ofec_cand_cmte_linkage_mv_tmp link on link.cand_id = cand_detail.candidate_id
        inner join fec_vsum_f3p_vw p on link.cmte_id = p.cmte_id and link.fec_election_yr = p.election_cycle
    where
        p.most_recent_filing_flag like 'Y'
        and p.election_cycle >= :START_YEAR
        and substr(link.cand_id, 1, 1) = link.cmte_tp
        and (link.cmte_dsgn = 'A' or link.cmte_dsgn = 'P')

    group by
        p.election_cycle,
        cand_id
    ) --join cycle totals to last_totals and combine
    , last_totals as (
        select
            ct.*,
            false as full_election,
            aggregate_last.last_cash_on_hand_end_period,
            aggregate_last.net_contributions,
            aggregate_last.net_operating_expenditures,
            aggregate_last.last_report_type_full,
            aggregate_last.last_debts_owed_to_committee,
            aggregate_last.last_debts_owed_by_committee,
            aggregate_last.last_beginning_image_number,
            aggregate_last.last_report_year,
            cash_beginning_period_aggregate.cash_on_hand_beginning_of_period
        from cycle_totals ct
        inner join aggregate_last on aggregate_last.cycle = ct.cycle and aggregate_last.candidate_id = ct.candidate_id
        inner join cash_beginning_period_aggregate on cash_beginning_period_aggregate.cycle = ct.cycle and cash_beginning_period_aggregate.candidate_id = ct.candidate_id
    )-- sum all of a candidates totals (across all committees), for full election period
     , intermediate_combined_totals as (
        select
                totals.candidate_id as candidate_id,
                max(totals.cycle) as cycle,
                max(totals.election_year) as election_year,
                min(totals.coverage_start_date) as coverage_start_date,
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
                sum(totals.debts_owed_by_cmte) as debts_owed_by_cmte,
                sum(totals.debts_owed_to_cmte) as debts_owed_to_cmte,
                true as full_election
        from last_totals totals
        inner join ofec_candidate_election_mv_tmp election on
            totals.candidate_id = election.candidate_id and
            totals.cycle <= election.cand_election_year and
            totals.cycle > election.prev_election_year
        group by
            totals.candidate_id,
            election.cand_election_year
        )--apend with ending financials
         ,full_election_totals as (
            select ict.*,
                totals.last_cash_on_hand_end_period,
                totals.net_contributions,
                totals.net_operating_expenditures,
                totals.last_report_type_full,
                totals.last_debts_owed_to_committee,
                totals.last_debts_owed_by_committee,
                totals.last_beginning_image_number,
                totals.last_report_year
                --0.0 as cash_on_hand_beginning_of_period
                --totals.cash_on_hand_beginning_of_period get this from first cycle
            from last_totals totals
            left join ofec_candidate_election_mv_tmp election on
                totals.candidate_id = election.candidate_id and
                totals.cycle = election.cand_election_year
            left join intermediate_combined_totals ict on totals.candidate_id = ict.candidate_id and totals.cycle = ict.cycle
            where totals.cycle > :START_YEAR

        ), cash_period_aggregate as(
            select
                p_totals.cash_on_hand_beginning_of_period,
                election.cand_election_year,
                p_totals.candidate_id
            from
                ofec_candidate_election_mv_tmp election
                left join last_totals p_totals on election.candidate_id = p_totals.candidate_id
                and p_totals.cycle > election.prev_election_year and p_totals.cycle < election.cand_election_year
        )--join to add beginning totals for full_election totals
        , final_combined_total as (
            select full_totals.*,
            cpa.cash_on_hand_beginning_of_period
            from full_election_totals full_totals
            left join cash_period_aggregate cpa on full_totals.candidate_id = cpa.candidate_id and full_totals.cycle = cpa.cand_election_year
        )
        select * from last_totals
        union all
        select * from final_combined_total
;
--these columns should be a unique primary key when considered together
create unique index on ofec_totals_candidate_committees_presidential_mv_tmp (candidate_id, cycle, full_election);

create index on ofec_totals_candidate_committees_presidential_mv_tmp (candidate_id);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (election_year);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (cycle);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (receipts);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (disbursements);
create index on ofec_totals_candidate_committees_presidential_mv_tmp (federal_funds_flag);