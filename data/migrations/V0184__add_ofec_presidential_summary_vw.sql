/*

View for https://github.com/fecgov/openFEC/issues/4178
Adds presidential financial summary
Endpoint: /presidential/financial_summary/

*/

-- View: public.ofec_presidential_financial_summary_vw

CREATE OR REPLACE VIEW public.ofec_presidential_financial_summary_vw AS
SELECT
    row_number() OVER () AS idx,
    cmte_id                        AS committee_id,
    cmte_nm                        AS committee_name,
    filed_cmte_tp                  AS committee_type,
    filed_cmte_dsgn                AS committee_designation,
    active                         AS candidate_active,
    cand_pty_affiliation           AS candidate_party_affiliation,
    cand_id                        AS candidate_id,
    UPPER(TRIM(TRAILING ',' FROM cand_nm))  AS candidate_name, --remove trailing commas
    SUBSTR(cand_nm, 0, strpos(cand_nm,',')) AS candidate_last_name,
    --Bringing this logic from ofec_presidential_by_candidate_vw
    ((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + COALESCE(fed_funds_per,0)) AS net_receipts,
    ROUND(((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + coalesce(fed_funds_per,0))/1000000,1) AS rounded_net_receipts,
    election_yr                    AS election_year,
    -- borrowed field names from ofec_report_pac_party_all_mv, removed `_period`
    --from classic - summary
    indv_contb_per - ref_indv_contb_per AS individual_contributions_less_refunds,
    other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per AS pac_contributions_less_refunds,
    pol_pty_cmte_contb_per -ref_pol_pty_cmte_contb_per AS party_contributions_less_refunds,
    cand_contb_per + loans_received_from_cand_per - repymts_loans_made_by_cand_per AS candidate_contributions_less_repayments,
    (op_exp_per - offsets_to_op_exp_per) + (fndrsg_disb_per - offsets_to_fndrsg_exp_per) + (exempt_legal_acctg_disb_per - offsets_to_legal_acctg_per) + other_disb_per AS disbursements_less_offsets,
    ttl_contb_per                  AS total_contributions,
    indv_contb_per                 AS total_individual_contributions,
    pol_pty_cmte_contb_per         AS political_party_committee_contributions,
    other_pol_cmte_contb_per       AS other_political_committee_contributions,
    cand_contb_per                 AS candidate_contributions,
    ref_indv_contb_per             AS refunded_individual_contributions,
    ref_pol_pty_cmte_contb_per     AS refunded_political_party_committee_contributions,
    ref_other_pol_cmte_contb_per   AS refunded_other_political_committee_contributions,
    tranf_from_affilated_cmte_per  AS transfers_from_affiliated_committees,
    loans_received_from_cand_per   AS loans_received_from_candidate,
    other_loans_received_per       AS other_loans_received,
    repymts_loans_made_by_cand_per AS repayments_loans_made_by_candidate,
    repymts_other_loans_per        AS repayments_other_loans,
    op_exp_per                     AS operating_expenditures,
    offsets_to_op_exp_per          AS offsets_to_operating_expenditures,
    other_receipts_per             AS other_receipts,
    debts_owed_by_cmte             AS debts_owed_by_committee,
    coh_cop                        AS cash_on_hand_end,
    fndrsg_disb_per                AS fundraising_disbursements,
    offsets_to_fndrsg_exp_per      AS offsets_to_fundraising_expenditures,
    exempt_legal_acctg_disb_per    AS exempt_legal_accounting_disbursement,
    offsets_to_legal_acctg_per     AS offsets_to_legal_accounting,
    other_disb_per                 AS other_disbursements,
    mst_rct_rpt_yr                 AS most_recent_report_year,
    mst_rct_rpt_tp                 AS most_recent_report_type,
    coh_bop                        AS cash_on_hand_beginning,
    ttl_receipts_sum_page_per      AS total_receipts_summary_page,
    subttl_sum_page_per            AS subtotal_summary_page,
    ttl_disb_sum_page_per          AS total_disbursements_summary_page,
    debts_owed_to_cmte             AS debts_owed_to_committee,
    exp_subject_limits             AS expenditure_subject_to_limits,
    net_contb_sum_page_per         AS net_contributions,
    net_op_exp_sum_page_per        AS net_operating_expenditures,
    fed_funds_per                  AS federal_funds,
    ttl_loans_received_per         AS total_loans_received,
    ttl_offsets_to_op_exp_per      AS total_offsets_to_operating_expenditures,
    ttl_receipts_per               AS total_receipts,
    tranf_to_other_auth_cmte_per   AS transfers_to_other_authorized_committees,
    ttl_loan_repymts_made_per      AS total_loan_repayments_made,
    ttl_contb_ref_per              AS total_contribution_refunds,
    ttl_disb_per                   AS total_disbursements,
    items_on_hand_liquidated       AS items_on_hand_liquidated,
    ttl_per                        AS total,
    indv_item_contb_per            AS individual_itemized_contributions,
    indv_unitem_contb_per          AS individual_unitemized_contributions,
    load_dt                        AS load_date
FROM (SELECT 2020 as election_year, *
    --2020 data
    FROM disclosure.pres_f3p_totals_ca_cm_link_20d
    UNION
    -- 2016 data
    SELECT 2016 as election_year, *
    FROM disclosure.pres_f3p_totals_ca_cm_link_16) AS combined
ORDER BY election_year, net_receipts DESC;

ALTER TABLE public.ofec_presidential_financial_summary_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_presidential_financial_summary_vw TO fec;
GRANT SELECT ON TABLE public.ofec_presidential_financial_summary_vw TO fec_read;
