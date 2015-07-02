drop view if exists ofec_filings_vw;
drop materialized view if exists ofec_filings_vw_tmp;
create materialized view ofec_filings_vw_tmp as
select
    row_number() over () as idx,
    cand.candidate_id as candidate_id,
    cand.name as candidate_name,
    com.committee_id as committee_id,
    com.name as committee_name,
    sub_id,
    coverage_start_date,
    coverage_end_date,
    receipt_date,
    election_year,
    fh.form_type,
    report_year,
    report_type,
    to_from_indicator as document_type,
    begin_image_numeric as beginning_image_number,
    end_image_numeric as ending_image_number,
    pages,
    total_receipts,
    total_individual_contributions,
    net_donations,
    total_disbursements,
    total_independent_expenditures,
    total_communication_cost,
    beginning_cash_on_hand,
    ending_cash_on_hand,
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
left join ofec_committee_history_mv com on fh.committee_id = com.committee_id and fh.report_year + fh.report_year % 2 = com.cycle
left join ofec_candidate_history_mv cand on fh.committee_id = cand.candidate_id and fh.report_year + fh.report_year % 2 = cand.cycle
left join dimreporttype report on fh.report_type = report.rpt_tp
where
    report_year >= :START_YEAR
;

create index on public.ofec_filings_vw_tmp(committee_id);
create index on public.ofec_filings_vw_tmp(candidate_id);
create index on public.ofec_filings_vw_tmp(beginning_image_number);
create index on public.ofec_filings_vw_tmp(receipt_date);
create index on public.ofec_filings_vw_tmp(form_type);
create index on public.ofec_filings_vw_tmp(primary_general_indicator);
create index on public.ofec_filings_vw_tmp(amendment_indicator);
create index on public.ofec_filings_vw_tmp(report_type);
create index on public.ofec_filings_vw_tmp(report_year);