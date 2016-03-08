drop table if exists ofec_filings_tmp;
create table ofec_filings_tmp as
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
    fh.treasurer_name,
    file_numeric as file_number,
    previous_file_numeric as previous_file_number,
    report.rpt_tp_desc as report_type_full,
    report_pgi as primary_general_indicator,
    request_type,
    amendment_indicator,
    update_date
from vw_filing_history fh
left join ofec_committee_history com on fh.committee_id = com.committee_id and get_cycle(fh.report_year) = com.cycle
left join ofec_candidate_history cand on fh.committee_id = cand.candidate_id and get_cycle(fh.report_year) = cand.two_year_period
left join dimreporttype report on fh.report_type = report.rpt_tp
where report_year >= %(START_YEAR)s
;

create unique index on ofec_filings_tmp (idx);

create index on ofec_filings_tmp (committee_id, idx);
create index on ofec_filings_tmp (candidate_id, idx);
create index on ofec_filings_tmp (beginning_image_number, idx);
create index on ofec_filings_tmp (receipt_date, idx);
create index on ofec_filings_tmp (form_type, idx);
create index on ofec_filings_tmp (primary_general_indicator, idx);
create index on ofec_filings_tmp (amendment_indicator, idx);
create index on ofec_filings_tmp (report_type, idx);
create index on ofec_filings_tmp (report_year, idx);
create index on ofec_filings_tmp (cycle, idx);
create index on ofec_filings_tmp (total_receipts, idx);
create index on ofec_filings_tmp (total_disbursements, idx);
create index on ofec_filings_tmp (total_independent_expenditures, idx);
create index on ofec_filings_tmp (coverage_start_date, idx);
create index on ofec_filings_tmp (coverage_end_date, idx);

drop table if exists ofec_filings;
alter table ofec_filings_tmp rename to ofec_filings;
