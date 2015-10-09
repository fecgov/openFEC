drop materialized view if exists ofec_filings_mv_tmp;
create materialized view ofec_filings_mv_tmp as
select
    row_number() over () as idx,
    cand.candidate_id as candidate_id,
    cand.name as candidate_name,
    fh.committee_id as committee_id,
    com.name as committee_name,
    sub_id,
    coverage_start_date,
    coverage_end_date,
    receipt_date,
    election_year,
    fh.form_type,
    cast (date_part('year', receipt_date) as numeric) as report_year,
    report_year + report_year % 2 as cycle,
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
    fh.treasurer_name,
    file_numeric as file_number,
    previous_file_numeric as previous_file_number,
    report.rpt_tp_desc as report_type_full,
    report_pgi as primary_general_indicator,
    request_type,
    amendment_indicator,
    update_date
from vw_filing_history fh
left join ofec_committee_history_mv_tmp com on fh.committee_id = com.committee_id and get_cycle(fh.report_year) = com.cycle
left join ofec_candidate_history_mv_tmp cand on fh.committee_id = cand.candidate_id and get_cycle(fh.report_year) = cand.two_year_period
left join dimreporttype report on fh.report_type = report.rpt_tp
where
    filings_year(report_year, receipt_date) >= :START_YEAR
;

create unique index on ofec_filings_mv_tmp (idx);

create index on ofec_filings_mv_tmp (committee_id);
create index on ofec_filings_mv_tmp (candidate_id);
create index on ofec_filings_mv_tmp (beginning_image_number);
create index on ofec_filings_mv_tmp (receipt_date);
create index on ofec_filings_mv_tmp (form_type);
create index on ofec_filings_mv_tmp (primary_general_indicator);
create index on ofec_filings_mv_tmp (amendment_indicator);
create index on ofec_filings_mv_tmp (report_type);
create index on ofec_filings_mv_tmp (report_year);
create index on ofec_filings_mv_tmp (cycle);
create index on ofec_filings_mv_tmp (total_receipts);
create index on ofec_filings_mv_tmp (total_disbursements);
create index on ofec_filings_mv_tmp (total_independent_expenditures);
create index on ofec_filings_mv_tmp (coverage_start_date);
create index on ofec_filings_mv_tmp (coverage_end_date);
