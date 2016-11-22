drop materialized view if exists ofec_filings_mv_tmp;
create materialized view ofec_filings_mv_tmp as
select
    row_number() over () as idx,
    cand.candidate_id as candidate_id,
    cand.name as candidate_name,
    --verify that cand_cmte_id is indeed just candidate's committee id--
    filing_history.cand_cmte_id as committee_id,
    com.name as committee_name,
    sub_id,
    coverage_start_date,
    coverage_end_date,
    receipt_date,
    election_year,
    filing_history.form_tp as form_type,
    report_year,
    get_cycle(report_year) as cycle,
    report_type,
    to_from_indicator as document_type,
    expand_document(to_from_indicator) as document_type_full,
    begin_image_numeric::bigint as beginning_image_number,
    end_image_numeric as ending_image_number,
    pages,
    total_receipts,
    total_individual_contributions,
    net_donations,
    total_disbursements,
    total_independent_expenditures,
    total_communication_cost,
    beginning_cash_on_hand as cash_on_hand_beginning_period,
    ending_cash_on_hand as cash_on_hand_end_period,
    debts_owed_by as debts_owed_by_committee,
    debts_owed_to as debts_owed_to_committee,
    -- personal funds aren't a thing anymore
    house_personal_funds,
    senate_personal_funds,
    opposition_personal_funds,
    filing_history.tres_nm as treasurer_name,
    file_numeric as file_number,
    previous_file_numeric as previous_file_number,
    report.rpt_tp_desc as report_type_full,
    report_pgi as primary_general_indicator,
    request_type,
    amendment_indicator,
    update_date,
    report_pdf_url_or_null(
        begin_image_numeric,
        report_year,
        com.committee_type,
        filing_history.form_tp
    ) as pdf_url,
    means_filed(begin_image_numeric) as means_filed,
    report_fec_url(begin_image_numeric::text, filing_history.file_num::integer) as fec_url
from disclosure.f_rpt_or_form_sub filing_history
left join ofec_committee_history_mv_tmp com on filing_history.cand_cmte_id = com.committee_id and get_cycle(filing_history.rpt_yr) = com.cycle
left join ofec_candidate_history_mv_tmp cand on filing_history.cand_cmte_id = cand.candidate_id and get_cycle(filing_history.rpt_yr) = cand.two_year_period
left join staging.ref_rpt_tp report on filing_history.rpt_tp = report.rpt_tp_cd
where report_year >= :START_YEAR
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
