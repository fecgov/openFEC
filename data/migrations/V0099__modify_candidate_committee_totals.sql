/*
Addresses issue #3217

Add transaction_coverage_date, which comes from ofec_agg_coverage_date_mv,
to  ofec_totals_candidate_committees_mv

*/


SET search_path = public, pg_catalog;

DROP MATERIALIZED VIEW IF EXISTS ofec_totals_candidate_committees_mv_tmp;

CREATE MATERIALIZED VIEW ofec_totals_candidate_committees_mv_tmp AS
 WITH last_cycle AS (
         SELECT DISTINCT ON (v_sum.cmte_id, link.fec_election_yr) v_sum.cmte_id,
            v_sum.rpt_yr AS report_year,
            v_sum.coh_cop AS cash_on_hand_end_period,
            v_sum.net_op_exp AS net_operating_expenditures,
            v_sum.net_contb AS net_contributions,
                CASE
                    WHEN (v_sum.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            ((v_sum.cvg_end_dt)::text)::timestamp without time zone AS coverage_end_date,
            trans_date.transaction_coverage_date::timestamp without time zone AS transaction_coverage_date,
            v_sum.debts_owed_by_cmte AS debts_owed_by_committee,
            v_sum.debts_owed_to_cmte AS debts_owed_to_committee,
            of.report_type_full,
            of.beginning_image_number,
            link.cand_id AS candidate_id,
            link.fec_election_yr AS cycle,
            link.cand_election_yr AS election_year
           FROM ((disclosure.v_sum_and_det_sum_report v_sum
             LEFT JOIN ofec_cand_cmte_linkage_mv link USING (cmte_id))
             LEFT JOIN ofec_filings_mv of ON ((of.sub_id = v_sum.orig_sub_id)))
             LEFT JOIN ofec_agg_coverage_date_mv trans_date
                ON link.cmte_id = trans_date.committee_id
                AND link.fec_election_yr = trans_date.fec_election_yr
          WHERE ((((v_sum.form_tp_cd)::text = 'F3P'::text) OR ((v_sum.form_tp_cd)::text = 'F3'::text)) AND (((link.cmte_dsgn)::text = 'A'::text) OR ((link.cmte_dsgn)::text = 'P'::text)) AND (v_sum.cvg_end_dt <> (99999999)::numeric) AND (link.fec_election_yr = (get_cycle(((date_part('year'::text, ((v_sum.cvg_end_dt)::text)::timestamp without time zone))::integer)::numeric))::numeric) AND (link.fec_election_yr >= (1979)::numeric))
          ORDER BY v_sum.cmte_id, link.fec_election_yr, v_sum.cvg_end_dt DESC NULLS LAST
        ), ending_totals_per_cycle AS (
         SELECT last.cycle,
            last.candidate_id,
            max(last.coverage_end_date) AS coverage_end_date,
            max(last.transaction_coverage_date) AS transaction_coverage_date,
            min(last.coverage_start_date) AS coverage_start_date,
            max((last.report_type_full)::text) AS last_report_type_full,
            max(last.beginning_image_number) AS last_beginning_image_number,
            sum(last.cash_on_hand_end_period) AS last_cash_on_hand_end_period,
            sum(last.debts_owed_by_committee) AS last_debts_owed_by_committee,
            sum(last.debts_owed_to_committee) AS last_debts_owed_to_committee,
            max(last.report_year) AS last_report_year,
            sum(last.net_operating_expenditures) AS last_net_operating_expenditures,
            sum(last.net_contributions) AS last_net_contributions
           FROM last_cycle last
          GROUP BY last.cycle, last.candidate_id
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, link.fec_election_yr) link.cand_id AS candidate_id,
            link.fec_election_yr AS cycle,
            max(link.fec_election_yr) AS election_year,
            min(((p.cvg_start_dt)::text)::timestamp without time zone) AS coverage_start_date,
            sum(p.cand_cntb) AS candidate_contribution,
            sum(p.ttl_contb_ref) AS contribution_refunds,
            sum(p.ttl_contb) AS contributions,
            sum(p.ttl_disb) AS disbursements,
            sum(p.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
            sum(p.fed_funds_per) AS federal_funds,
            (sum(p.fed_funds_per) > (0)::numeric) AS federal_funds_flag,
            sum(p.fndrsg_disb) AS fundraising_disbursements,
            sum(p.indv_contb) AS individual_contributions,
            sum(p.indv_unitem_contb) AS individual_unitemized_contributions,
            sum(p.indv_item_contb) AS individual_itemized_contributions,
            sum(p.ttl_loans) AS loans_received,
            sum(p.cand_loan) AS loans_received_from_candidate,
            sum((p.cand_loan_repymnt + p.oth_loan_repymts)) AS loan_repayments_made,
            sum(p.offsets_to_fndrsg) AS offsets_to_fundraising_expenditures,
            sum(p.offsets_to_legal_acctg) AS offsets_to_legal_accounting,
            sum(p.offsets_to_op_exp) AS offsets_to_operating_expenditures,
            sum(((p.offsets_to_op_exp + p.offsets_to_fndrsg) + p.offsets_to_legal_acctg)) AS total_offsets_to_operating_expenditures,
            sum(p.op_exp_per) AS operating_expenditures,
            sum(p.other_disb_per) AS other_disbursements,
            sum(p.oth_loans) AS other_loans_received,
            sum(p.oth_cmte_contb) AS other_political_committee_contributions,
            sum(p.other_receipts) AS other_receipts,
            sum(p.pty_cmte_contb) AS political_party_committee_contributions,
            sum(p.ttl_receipts) AS receipts,
            sum(p.indv_ref) AS refunded_individual_contributions,
            sum(p.oth_cmte_ref) AS refunded_other_political_committee_contributions,
            sum(p.pol_pty_cmte_contb) AS refunded_political_party_committee_contributions,
            sum(p.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
            sum(p.oth_loan_repymts) AS repayments_other_loans,
            sum(p.tranf_from_other_auth_cmte) AS transfers_from_affiliated_committee,
            sum(p.tranf_to_other_auth_cmte) AS transfers_to_other_authorized_committee,
            sum(p.net_op_exp) AS net_operating_expenditures,
            sum(p.net_contb) AS net_contributions,
            false AS full_election
           FROM (ofec_cand_cmte_linkage_mv link
             LEFT JOIN disclosure.v_sum_and_det_sum_report p ON ((((link.cmte_id)::text = (p.cmte_id)::text) AND (link.fec_election_yr = (get_cycle(p.rpt_yr))::numeric))))
          WHERE ((link.fec_election_yr >= (1979)::numeric) AND (p.cvg_start_dt <> (99999999)::numeric) AND (((p.form_tp_cd)::text = 'F3P'::text) OR ((p.form_tp_cd)::text = 'F3'::text)) AND (((link.cmte_dsgn)::text = 'A'::text) OR ((link.cmte_dsgn)::text = 'P'::text)))
          GROUP BY link.fec_election_yr, link.cand_election_yr, link.cand_id
        ), cycle_totals_with_ending_aggregates AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.cycle,
            cycle_totals.election_year,
            cycle_totals.coverage_start_date,
            cycle_totals.candidate_contribution,
            cycle_totals.contribution_refunds,
            cycle_totals.contributions,
            cycle_totals.disbursements,
            cycle_totals.exempt_legal_accounting_disbursement,
            cycle_totals.federal_funds,
            cycle_totals.federal_funds_flag,
            cycle_totals.fundraising_disbursements,
            cycle_totals.individual_contributions,
            cycle_totals.individual_unitemized_contributions,
            cycle_totals.individual_itemized_contributions,
            cycle_totals.loans_received,
            cycle_totals.loans_received_from_candidate,
            cycle_totals.loan_repayments_made,
            cycle_totals.offsets_to_fundraising_expenditures,
            cycle_totals.offsets_to_legal_accounting,
            cycle_totals.offsets_to_operating_expenditures,
            cycle_totals.total_offsets_to_operating_expenditures,
            cycle_totals.operating_expenditures,
            cycle_totals.other_disbursements,
            cycle_totals.other_loans_received,
            cycle_totals.other_political_committee_contributions,
            cycle_totals.other_receipts,
            cycle_totals.political_party_committee_contributions,
            cycle_totals.receipts,
            cycle_totals.refunded_individual_contributions,
            cycle_totals.refunded_other_political_committee_contributions,
            cycle_totals.refunded_political_party_committee_contributions,
            cycle_totals.repayments_loans_made_by_candidate,
            cycle_totals.repayments_other_loans,
            cycle_totals.transfers_from_affiliated_committee,
            cycle_totals.transfers_to_other_authorized_committee,
            cycle_totals.net_operating_expenditures,
            cycle_totals.net_contributions,
            cycle_totals.full_election,
            ending_totals.coverage_end_date,
            ending_totals.transaction_coverage_date,
            ending_totals.last_report_type_full,
            ending_totals.last_beginning_image_number,
            ending_totals.last_cash_on_hand_end_period,
            ending_totals.last_debts_owed_by_committee,
            ending_totals.last_debts_owed_to_committee,
            ending_totals.last_report_year,
            ending_totals.last_net_operating_expenditures,
            ending_totals.last_net_contributions
           FROM (cycle_totals cycle_totals
             LEFT JOIN ending_totals_per_cycle ending_totals ON (((ending_totals.cycle = cycle_totals.cycle) AND ((ending_totals.candidate_id)::text = (cycle_totals.candidate_id)::text))))
        ), election_totals AS (
         SELECT totals.candidate_id,
            max(totals.cycle) AS cycle,
            max(totals.election_year) AS election_year,
            min(totals.coverage_start_date) AS coverage_start_date,
            sum(totals.candidate_contribution) AS candidate_contribution,
            sum(totals.contribution_refunds) AS contribution_refunds,
            sum(totals.contributions) AS contributions,
            sum(totals.disbursements) AS disbursements,
            sum(totals.exempt_legal_accounting_disbursement) AS exempt_legal_accounting_disbursement,
            sum(totals.federal_funds) AS federal_funds,
            (sum(totals.federal_funds) > (0)::numeric) AS federal_funds_flag,
            sum(totals.fundraising_disbursements) AS fundraising_disbursements,
            sum(totals.individual_contributions) AS individual_contributions,
            sum(totals.individual_unitemized_contributions) AS individual_unitemized_contributions,
            sum(totals.individual_itemized_contributions) AS individual_itemized_contributions,
            sum(totals.loans_received) AS loans_received,
            sum(totals.loans_received_from_candidate) AS loans_received_from_candidate,
            sum(totals.loan_repayments_made) AS loan_repayments_made,
            sum(totals.offsets_to_fundraising_expenditures) AS offsets_to_fundraising_expenditures,
            sum(totals.offsets_to_legal_accounting) AS offsets_to_legal_accounting,
            sum(totals.offsets_to_operating_expenditures) AS offsets_to_operating_expenditures,
            sum(totals.total_offsets_to_operating_expenditures) AS total_offsets_to_operating_expenditures,
            sum(totals.operating_expenditures) AS operating_expenditures,
            sum(totals.other_disbursements) AS other_disbursements,
            sum(totals.other_loans_received) AS other_loans_received,
            sum(totals.other_political_committee_contributions) AS other_political_committee_contributions,
            sum(totals.other_receipts) AS other_receipts,
            sum(totals.political_party_committee_contributions) AS political_party_committee_contributions,
            sum(totals.receipts) AS receipts,
            sum(totals.refunded_individual_contributions) AS refunded_individual_contributions,
            sum(totals.refunded_other_political_committee_contributions) AS refunded_other_political_committee_contributions,
            sum(totals.refunded_political_party_committee_contributions) AS refunded_political_party_committee_contributions,
            sum(totals.repayments_loans_made_by_candidate) AS repayments_loans_made_by_candidate,
            sum(totals.repayments_other_loans) AS repayments_other_loans,
            sum(totals.transfers_from_affiliated_committee) AS transfers_from_affiliated_committee,
            sum(totals.transfers_to_other_authorized_committee) AS transfers_to_other_authorized_committee,
            sum(totals.net_operating_expenditures) AS net_operating_expenditures,
            sum(totals.net_contributions) AS net_contributions,
            true AS full_election,
            max(totals.coverage_end_date) AS coverage_end_date,
            max(totals.transaction_coverage_date) AS transaction_coverage_date
           FROM (cycle_totals_with_ending_aggregates totals
             LEFT JOIN ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle <= (election.cand_election_year)::numeric) AND (totals.cycle > (election.prev_election_year)::numeric))))
          GROUP BY totals.candidate_id, election.cand_election_year
        ), election_totals_with_ending_aggregates AS (
         SELECT et.candidate_id,
            et.cycle,
            et.election_year,
            et.coverage_start_date,
            et.candidate_contribution,
            et.contribution_refunds,
            et.contributions,
            et.disbursements,
            et.exempt_legal_accounting_disbursement,
            et.federal_funds,
            et.federal_funds_flag,
            et.fundraising_disbursements,
            et.individual_contributions,
            et.individual_unitemized_contributions,
            et.individual_itemized_contributions,
            et.loans_received,
            et.loans_received_from_candidate,
            et.loan_repayments_made,
            et.offsets_to_fundraising_expenditures,
            et.offsets_to_legal_accounting,
            et.offsets_to_operating_expenditures,
            et.total_offsets_to_operating_expenditures,
            et.operating_expenditures,
            et.other_disbursements,
            et.other_loans_received,
            et.other_political_committee_contributions,
            et.other_receipts,
            et.political_party_committee_contributions,
            et.receipts,
            et.refunded_individual_contributions,
            et.refunded_other_political_committee_contributions,
            et.refunded_political_party_committee_contributions,
            et.repayments_loans_made_by_candidate,
            et.repayments_other_loans,
            et.transfers_from_affiliated_committee,
            et.transfers_to_other_authorized_committee,
            et.net_operating_expenditures,
            et.net_contributions,
            et.full_election,
            et.coverage_end_date,
            et.transaction_coverage_date,
            totals.last_report_type_full,
            totals.last_beginning_image_number,
            totals.last_cash_on_hand_end_period,
            totals.last_debts_owed_by_committee,
            totals.last_debts_owed_to_committee,
            totals.last_report_year,
            totals.last_net_operating_expenditures,
            totals.last_net_contributions
           FROM ((ending_totals_per_cycle totals
             LEFT JOIN ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle = (election.cand_election_year)::numeric))))
             LEFT JOIN election_totals et ON ((((totals.candidate_id)::text = (et.candidate_id)::text) AND (totals.cycle = et.cycle))))
          WHERE (totals.cycle > (1979)::numeric)
        )
 SELECT cycle_totals_with_ending_aggregates.candidate_id,
    cycle_totals_with_ending_aggregates.cycle,
    cycle_totals_with_ending_aggregates.election_year,
    cycle_totals_with_ending_aggregates.coverage_start_date,
    cycle_totals_with_ending_aggregates.candidate_contribution,
    cycle_totals_with_ending_aggregates.contribution_refunds,
    cycle_totals_with_ending_aggregates.contributions,
    cycle_totals_with_ending_aggregates.disbursements,
    cycle_totals_with_ending_aggregates.exempt_legal_accounting_disbursement,
    cycle_totals_with_ending_aggregates.federal_funds,
    cycle_totals_with_ending_aggregates.federal_funds_flag,
    cycle_totals_with_ending_aggregates.fundraising_disbursements,
    cycle_totals_with_ending_aggregates.individual_contributions,
    cycle_totals_with_ending_aggregates.individual_unitemized_contributions,
    cycle_totals_with_ending_aggregates.individual_itemized_contributions,
    cycle_totals_with_ending_aggregates.loans_received,
    cycle_totals_with_ending_aggregates.loans_received_from_candidate,
    cycle_totals_with_ending_aggregates.loan_repayments_made,
    cycle_totals_with_ending_aggregates.offsets_to_fundraising_expenditures,
    cycle_totals_with_ending_aggregates.offsets_to_legal_accounting,
    cycle_totals_with_ending_aggregates.offsets_to_operating_expenditures,
    cycle_totals_with_ending_aggregates.total_offsets_to_operating_expenditures,
    cycle_totals_with_ending_aggregates.operating_expenditures,
    cycle_totals_with_ending_aggregates.other_disbursements,
    cycle_totals_with_ending_aggregates.other_loans_received,
    cycle_totals_with_ending_aggregates.other_political_committee_contributions,
    cycle_totals_with_ending_aggregates.other_receipts,
    cycle_totals_with_ending_aggregates.political_party_committee_contributions,
    cycle_totals_with_ending_aggregates.receipts,
    cycle_totals_with_ending_aggregates.refunded_individual_contributions,
    cycle_totals_with_ending_aggregates.refunded_other_political_committee_contributions,
    cycle_totals_with_ending_aggregates.refunded_political_party_committee_contributions,
    cycle_totals_with_ending_aggregates.repayments_loans_made_by_candidate,
    cycle_totals_with_ending_aggregates.repayments_other_loans,
    cycle_totals_with_ending_aggregates.transfers_from_affiliated_committee,
    cycle_totals_with_ending_aggregates.transfers_to_other_authorized_committee,
    cycle_totals_with_ending_aggregates.net_operating_expenditures,
    cycle_totals_with_ending_aggregates.net_contributions,
    cycle_totals_with_ending_aggregates.full_election,
    cycle_totals_with_ending_aggregates.coverage_end_date,
    cycle_totals_with_ending_aggregates.transaction_coverage_date,
    cycle_totals_with_ending_aggregates.last_report_type_full,
    cycle_totals_with_ending_aggregates.last_beginning_image_number,
    cycle_totals_with_ending_aggregates.last_cash_on_hand_end_period,
    cycle_totals_with_ending_aggregates.last_debts_owed_by_committee,
    cycle_totals_with_ending_aggregates.last_debts_owed_to_committee,
    cycle_totals_with_ending_aggregates.last_report_year,
    cycle_totals_with_ending_aggregates.last_net_operating_expenditures,
    cycle_totals_with_ending_aggregates.last_net_contributions
   FROM cycle_totals_with_ending_aggregates
UNION ALL
 SELECT election_totals_with_ending_aggregates.candidate_id,
    election_totals_with_ending_aggregates.cycle,
    election_totals_with_ending_aggregates.election_year,
    election_totals_with_ending_aggregates.coverage_start_date,
    election_totals_with_ending_aggregates.candidate_contribution,
    election_totals_with_ending_aggregates.contribution_refunds,
    election_totals_with_ending_aggregates.contributions,
    election_totals_with_ending_aggregates.disbursements,
    election_totals_with_ending_aggregates.exempt_legal_accounting_disbursement,
    election_totals_with_ending_aggregates.federal_funds,
    election_totals_with_ending_aggregates.federal_funds_flag,
    election_totals_with_ending_aggregates.fundraising_disbursements,
    election_totals_with_ending_aggregates.individual_contributions,
    election_totals_with_ending_aggregates.individual_unitemized_contributions,
    election_totals_with_ending_aggregates.individual_itemized_contributions,
    election_totals_with_ending_aggregates.loans_received,
    election_totals_with_ending_aggregates.loans_received_from_candidate,
    election_totals_with_ending_aggregates.loan_repayments_made,
    election_totals_with_ending_aggregates.offsets_to_fundraising_expenditures,
    election_totals_with_ending_aggregates.offsets_to_legal_accounting,
    election_totals_with_ending_aggregates.offsets_to_operating_expenditures,
    election_totals_with_ending_aggregates.total_offsets_to_operating_expenditures,
    election_totals_with_ending_aggregates.operating_expenditures,
    election_totals_with_ending_aggregates.other_disbursements,
    election_totals_with_ending_aggregates.other_loans_received,
    election_totals_with_ending_aggregates.other_political_committee_contributions,
    election_totals_with_ending_aggregates.other_receipts,
    election_totals_with_ending_aggregates.political_party_committee_contributions,
    election_totals_with_ending_aggregates.receipts,
    election_totals_with_ending_aggregates.refunded_individual_contributions,
    election_totals_with_ending_aggregates.refunded_other_political_committee_contributions,
    election_totals_with_ending_aggregates.refunded_political_party_committee_contributions,
    election_totals_with_ending_aggregates.repayments_loans_made_by_candidate,
    election_totals_with_ending_aggregates.repayments_other_loans,
    election_totals_with_ending_aggregates.transfers_from_affiliated_committee,
    election_totals_with_ending_aggregates.transfers_to_other_authorized_committee,
    election_totals_with_ending_aggregates.net_operating_expenditures,
    election_totals_with_ending_aggregates.net_contributions,
    election_totals_with_ending_aggregates.full_election,
    election_totals_with_ending_aggregates.coverage_end_date,
    election_totals_with_ending_aggregates.transaction_coverage_date,
    election_totals_with_ending_aggregates.last_report_type_full,
    election_totals_with_ending_aggregates.last_beginning_image_number,
    election_totals_with_ending_aggregates.last_cash_on_hand_end_period,
    election_totals_with_ending_aggregates.last_debts_owed_by_committee,
    election_totals_with_ending_aggregates.last_debts_owed_to_committee,
    election_totals_with_ending_aggregates.last_report_year,
    election_totals_with_ending_aggregates.last_net_operating_expenditures,
    election_totals_with_ending_aggregates.last_net_contributions
   FROM election_totals_with_ending_aggregates;

----Permissions------

ALTER TABLE ofec_totals_candidate_committees_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE ofec_totals_candidate_committees_mv_tmp TO fec;
GRANT SELECT ON TABLE ofec_totals_candidate_committees_mv_tmp TO fec_read;
GRANT SELECT ON TABLE ofec_totals_candidate_committees_mv_tmp TO openfec_read;

----Indexes-----------

CREATE UNIQUE INDEX ofec_totals_candidate_com_candidate_id_cycle_full_elect_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (candidate_id, cycle, full_election);

CREATE INDEX ofec_totals_candidate_committees_mv_candidate_id_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (candidate_id);

CREATE INDEX ofec_totals_candidate_committees_mv_cycle_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (cycle);

CREATE INDEX ofec_totals_candidate_committees_mv_disbursements_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (disbursements);

CREATE INDEX ofec_totals_candidate_committees_mv_election_year_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (election_year);

CREATE INDEX ofec_totals_candidate_committees_mv_federal_funds_flag_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (federal_funds_flag);

CREATE INDEX ofec_totals_candidate_committees_mv_receipts_idx_tmp ON ofec_totals_candidate_committees_mv_tmp USING btree (receipts);

----Rename view & indexes-------

DROP MATERIALIZED VIEW IF EXISTS ofec_totals_candidate_committees_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_totals_candidate_committees_mv_tmp RENAME TO ofec_totals_candidate_committees_mv;

SELECT rename_indexes('ofec_totals_candidate_committees_mv');
