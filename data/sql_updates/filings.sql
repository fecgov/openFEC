drop materialized view if exists ofec_filings_mv_tmp;
create materialized view ofec_filings_mv_tmp as
select
    row_number() over () as idx,
    cand.candidate_id as candidate_id,
    cand.name as candidate_name,
    filing_history.cand_cmte_id as committee_id,
    com.name as committee_name,
    sub_id,
    cast(cast(cvg_start_dt as text) as date) as coverage_start_date,
    cast(cast(cvg_end_dt as text) as date) as coverage_end_date,
    cast(cast(receipt_dt as text) as date) as receipt_date,
    election_yr as election_year,
    filing_history.form_tp as form_type,
    rpt_yr as report_year,
    get_cycle(rpt_yr) as cycle,
    rpt_tp as report_type,
    to_from_ind as document_type,
    expand_document(to_from_ind) as document_type_full,
    begin_image_num::bigint as beginning_image_number,
    end_image_num as ending_image_number,
    pages,
    ttl_receipts as total_receipts,
    ttl_indt_contb as total_individual_contributions,
    net_dons as net_donations,
    ttl_disb as total_disbursements,
    ttl_indt_exp as total_independent_expenditures,
    ttl_communication_cost as total_communication_cost,
    coh_bop as cash_on_hand_beginning_period,
    coh_cop as cash_on_hand_end_period,
    debts_owed_by_cmte as debts_owed_by_committee,
    debts_owed_to_cmte as debts_owed_to_committee,
    -- personal funds aren't a thing anymore
    hse_pers_funds_amt as house_personal_funds,
    sen_pers_funds_amt as senate_personal_funds,
    oppos_pers_fund_amt as opposition_personal_funds,
    filing_history.tres_nm as treasurer_name,
    file_num as file_number,
    prev_file_num as previous_file_number,
    report.rpt_tp_desc as report_type_full,
    rpt_pgi as primary_general_indicator,
    request_tp as request_type,
    amndt_ind as amendment_indicator,
    lst_updt_dt as update_date,
    report_pdf_url_or_null(
        begin_image_num,
        rpt_yr,
        com.committee_type,
        filing_history.form_tp
    ) as pdf_url,
    means_filed(begin_image_num) as means_filed,
    report_fec_url(begin_image_num::text, filing_history.file_num::integer) as fec_url
from disclosure.f_rpt_or_form_sub filing_history
left join ofec_committee_history_mv_tmp com on filing_history.cand_cmte_id = com.committee_id and get_cycle(filing_history.rpt_yr) = com.cycle
left join ofec_candidate_history_mv_tmp cand on filing_history.cand_cmte_id = cand.candidate_id and get_cycle(filing_history.rpt_yr) = cand.two_year_period
left join staging.ref_rpt_tp report on filing_history.rpt_tp = report.rpt_tp_cd
where rpt_yr >= :START_YEAR
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
