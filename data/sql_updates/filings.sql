drop materialized view if exists ofec_filings_mv_tmp;
create materialized view ofec_filings_mv_tmp as
with filings AS (
    SELECT
        cand.candidate_id                                                         AS candidate_id,
        cand.name                                                                   AS candidate_name,
        filing_history.cand_cmte_id                                                 AS committee_id,
        com.name                                                                    AS committee_name,
        sub_id,
        cast(cast(cvg_start_dt AS TEXT) AS DATE)                                    AS coverage_start_date,
        cast(cast(cvg_end_dt AS TEXT) AS DATE)                                      AS coverage_end_date,
        cast(cast(receipt_dt AS TEXT) AS DATE)                                      AS receipt_date,
        election_yr                                                                 AS election_year,
        filing_history.form_tp                                                      AS form_type,
        rpt_yr                                                                      AS report_year,
        get_cycle(rpt_yr)                                                           AS cycle,
        rpt_tp                                                                      AS report_type,
        to_from_ind                                                                 AS document_type,
        expand_document(to_from_ind)                                                AS document_type_full,
        begin_image_num :: BIGINT                                                   AS beginning_image_number,
        end_image_num                                                               AS ending_image_number,
        pages,
        ttl_receipts                                                                AS total_receipts,
        ttl_indt_contb                                                              AS total_individual_contributions,
        net_dons                                                                    AS net_donations,
        ttl_disb                                                                    AS total_disbursements,
        ttl_indt_exp                                                                AS total_independent_expenditures,
        ttl_communication_cost                                                      AS total_communication_cost,
        coh_bop                                                                     AS cash_on_hand_beginning_period,
        coh_cop                                                                     AS cash_on_hand_end_period,
        debts_owed_by_cmte                                                          AS debts_owed_by_committee,
        debts_owed_to_cmte                                                          AS debts_owed_to_committee,
        -- personal funds aren't a thing anymore
        hse_pers_funds_amt                                                          AS house_personal_funds,
        sen_pers_funds_amt                                                          AS senate_personal_funds,
        oppos_pers_fund_amt                                                         AS opposition_personal_funds,
        filing_history.tres_nm                                                      AS treasurer_name,
        file_num                                                                    AS file_number,
        prev_file_num                                                               AS previous_file_number,
        report.rpt_tp_desc                                                          AS report_type_full,
        rpt_pgi                                                                     AS primary_general_indicator,
        request_tp                                                                  AS request_type,
        amndt_ind                                                                   AS amendment_indicator,
        lst_updt_dt                                                                 AS update_date,
        report_pdf_url_or_null(
            begin_image_num,
            rpt_yr,
            com.committee_type,
            filing_history.form_tp
        )                                                                           AS pdf_url,
        means_filed(begin_image_num)                                                AS means_filed,
        report_fec_url(begin_image_num :: TEXT, filing_history.file_num :: INTEGER) AS fec_url
    FROM disclosure.f_rpt_or_form_sub filing_history
        LEFT JOIN ofec_committee_history_mv_tmp com
            ON filing_history.cand_cmte_id = com.committee_id AND get_cycle(filing_history.rpt_yr) = com.cycle
        LEFT JOIN ofec_candidate_history_mv_tmp cand ON filing_history.cand_cmte_id = cand.candidate_id AND
                                                        get_cycle(filing_history.rpt_yr) = cand.two_year_period
        LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp = report.rpt_tp_cd
    WHERE rpt_yr >= :START_YEAR
),
rfai_filings AS (
    SELECT
        cand.candidate_id AS candidate_id,
        cand.name AS candidate_name,
        id AS committee_id,
        com.name AS committee_name,
        sub_id,
        cvg_start_dt AS coverage_start_date,
        cvg_end_dt AS coverage_end_date,
        rfai_dt AS receipt_date,
        rpt_yr AS election_year,
        'RFAI'::text AS form_type,
        rpt_yr AS report_year,
        get_cycle(rpt_yr) AS CYCLE,
        rpt_tp AS report_type,
        null::character varying(1) AS document_type,
        null::text AS document_type_full,
        begin_image_num::BIGINT AS beginning_image_number,
        end_image_num AS ending_image_number,
        0 AS pages,
        0.00 AS total_receipts,
        0.00 AS total_individual_contributions,
        0.00 AS net_donations,
        0.00 AS total_disbursements,
        0.00 AS total_independent_expenditures,
        0.00 AS total_communication_cost,
        0.00 AS cash_on_hand_beginning_period,
        0.00 AS cash_on_hand_end_period,
        0.00 AS debts_owed_by_committee,
        0.00 AS debts_owed_to_committee,
        -- personal funds aren't a thing anymore
        0.00 AS house_personal_funds,
        0.00 AS senate_personal_funds,
        0.00 AS opposition_personal_funds,
        null::character varying(38) AS treasurer_name,
        file_num AS file_number,
        0 AS previous_file_number,
        report.rpt_tp_desc AS report_type_full,
        null::character varying(5)  AS primary_general_indicator,
        request_tp AS request_type,
        amndt_ind AS amendment_indicator,
        last_update_dt AS update_date,
        report_pdf_url_or_null(
        begin_image_num,
        rpt_yr,
        com.committee_type,
        'RFAI'::text
        ) AS pdf_url,
        means_filed(begin_image_num) AS means_filed,
        report_fec_url(begin_image_num::TEXT, filing_history.file_num::INTEGER ) AS fec_url
    FROM disclosure.nml_form_rfai filing_history
    LEFT JOIN ofec_committee_history_mv_tmp com ON filing_history.id = com.committee_id AND get_cycle(filing_history.rpt_yr) = com.cycle
    LEFT JOIN ofec_candidate_history_mv_tmp cand ON filing_history.id = cand.candidate_id AND get_cycle(filing_history.rpt_yr) = cand.two_year_period
    LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp = report.rpt_tp_cd
WHERE rpt_yr >= :START_YEAR
),
combined as(
    select * from filings
    union all
    select * from rfai_filings
)
select
    row_number() over () as idx,
    combined.*
from combined
;

create unique index on ofec_filings_mv_tmp (idx);

create index on ofec_filings_mv_tmp (committee_id, idx);
create index on ofec_filings_mv_tmp (candidate_id, idx);
create index on ofec_filings_mv_tmp (beginning_image_number, idx);
create index on ofec_filings_mv_tmp (receipt_date, idx);
create index on ofec_filings_mv_tmp (form_type, idx);
create index on ofec_filings_mv_tmp (primary_general_indicator, idx);
create index on ofec_filings_mv_tmp (amendment_indicator, idx);
create index on ofec_filings_mv_tmp (report_type, idx);
create index on ofec_filings_mv_tmp (report_year, idx);
create index on ofec_filings_mv_tmp (cycle, idx);
create index on ofec_filings_mv_tmp (total_receipts, idx);
create index on ofec_filings_mv_tmp (total_disbursements, idx);
create index on ofec_filings_mv_tmp (total_independent_expenditures, idx);
create index on ofec_filings_mv_tmp (coverage_start_date, idx);
create index on ofec_filings_mv_tmp (coverage_end_date, idx);
