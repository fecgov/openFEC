drop materialized view if exists ofec_filings_amendments_all_mv_tmp;
--there is a lot of room for refactoring I believe, but I feel it's
--best to keep paper and electronic separate until the kinks in paper
--can (maybe?) get worked out (drastically improved, next step see
--if paper can be combined to one table)
create materialized view ofec_filings_amendments_all_mv_tmp as
with combined AS (
  SELECT *
  from ofec_amendments_mv_tmp
  union all
  SELECT *
  FROM ofec_presidential_paper_amendments_mv_tmp
  UNION ALL
  SELECT *
  FROM ofec_house_senate_paper_amendments_mv_tmp
  UNION ALL
  SELECT *
  FROM ofec_pac_party_paper_amendments_mv_tmp
) select row_number() over () as idx2, * from combined;

create unique index on ofec_filings_amendments_all_mv_tmp(idx2);
create index on ofec_filings_amendments_all_mv_tmp(file_num);


drop materialized view if exists ofec_filings_mv_tmp;
create materialized view ofec_filings_mv_tmp as
with filings as (
    select
        cand.candidate_id as candidate_id,
        cand.name as candidate_name,
        filing_history.cand_cmte_id as committee_id,
        com.name as committee_name,
        sub_id,
        cast(cast(cvg_start_dt as text) as date) as coverage_start_date,
        cast(cast(cvg_end_dt as text) as date) as coverage_end_date,
        cast(cast(filing_history.receipt_dt as text) as date) as receipt_date,
        election_yr as election_year,
        filing_history.form_tp as form_type,
        filing_history.rpt_yr as report_year,
        get_cycle(filing_history.rpt_yr) as cycle,
        filing_history.rpt_tp as report_type,
        to_from_ind as document_type,
        expand_document(to_from_ind) as document_type_full,
        begin_image_num :: BIGINT as beginning_image_number,
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
        filing_history.file_num as file_number,
        --for now let's not derive prev_file_num from amendments tables
        filing_history.prev_file_num as previous_file_number,
        report.rpt_tp_desc as report_type_full,
        rpt_pgi as primary_general_indicator,
        request_tp as request_type,
        filing_history.amndt_ind as amendment_indicator,
        lst_updt_dt as update_date,
        report_pdf_url_or_null(
            begin_image_num,
            filing_history.rpt_yr,
            com.committee_type,
            filing_history.form_tp
        ) as pdf_url,
        means_filed(begin_image_num) as means_filed,
        report_html_url(means_filed(begin_image_num), filing_history.cand_cmte_id::text, filing_history.file_num::text) as html_url,
        report_fec_url(begin_image_num::text, filing_history.file_num::integer) as fec_url,
        amendments.amendment_chain,
        --amendments.prev_file_num as previous_file_number,
        amendments.mst_rct_file_num as most_recent_file_number,
        is_amended(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp) as is_amended,
        is_most_recent(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp) as most_recent,
        case when upper(filing_history.form_tp) = 'FRQ' then 0
             when upper(filing_history.form_tp) = 'F99' then 0
		         else array_length(amendments.amendment_chain, 1) - 1
	        end as amendment_version
    from disclosure.f_rpt_or_form_sub filing_history
        left join ofec_committee_history_mv_tmp com
            on filing_history.cand_cmte_id = com.committee_id and get_cycle(filing_history.rpt_yr) = com.cycle
        left join ofec_candidate_history_mv_tmp cand on filing_history.cand_cmte_id = cand.candidate_id and
                                                        get_cycle(filing_history.rpt_yr) = cand.two_year_period
        left join staging.ref_rpt_tp report on filing_history.rpt_tp = report.rpt_tp_cd
        left join ofec_filings_amendments_all_mv_tmp amendments on filing_history.file_num = amendments.file_num
    where filing_history.rpt_yr >= :START_YEAR and filing_history.form_tp != 'SL'

),
rfai_filings as (
    select
        cand.candidate_id as candidate_id,
        cand.name as candidate_name,
        id as committee_id,
        com.name as committee_name,
        sub_id,
        cvg_start_dt as coverage_start_date,
        cvg_end_dt as coverage_end_date,
        rfai_dt as receipt_date,
        rpt_yr as election_year,
        'RFAI'::text as form_type,
        rpt_yr as report_year,
        get_cycle(rpt_yr) as CYCLE,
        rpt_tp as report_type,
        null::character varying(1) as document_type,
        null::text as document_type_full,
        begin_image_num::bigint as beginning_image_number,
        end_image_num as ending_image_number,
        null::int as pages,
        null::int as total_receipts,
        null::int as total_individual_contributions,
        null::int as net_donations,
        null::int as total_disbursements,
        null::int as total_independent_expenditures,
        null::int as total_communication_cost,
        null::int as cash_on_hand_beginning_period,
        null::int as cash_on_hand_end_period,
        null::int as debts_owed_by_committee,
        null::int as debts_owed_to_committee,
        -- personal funds aren't a thing anymore
        null::int as house_personal_funds,
        null::int as senate_personal_funds,
        null::int as opposition_personal_funds,
        null::character varying(38) as treasurer_name,
        file_num as file_number,
        0 as previous_file_number,
        report.rpt_tp_desc as report_type_full,
        null::character varying(5)  as primary_general_indicator,
        request_tp as request_type,
        amndt_ind as amendment_indicator,
        last_update_dt as update_date,
        report_pdf_url_or_null(
            begin_image_num,
            filing_history.rpt_yr,
            com.committee_type,
            'RFAI'::text
        ) as pdf_url,
        means_filed(begin_image_num) as means_filed,
        report_html_url(means_filed(begin_image_num), id::text, filing_history.file_num::text) as html_url,
        null::text as fec_url,
        null::numeric[] as amendment_chain,
        null::int as most_recent_file_number,
        null::boolean as is_amended,
        True as most_recent,
        0 as amendement_version
    from disclosure.nml_form_rfai filing_history
    left join ofec_committee_history_mv_tmp com on filing_history.id = com.committee_id and get_cycle(filing_history.rpt_yr) = com.cycle
    left join ofec_candidate_history_mv_tmp cand on filing_history.id = cand.candidate_id and get_cycle(filing_history.rpt_yr) = cand.two_year_period
    left join staging.ref_rpt_tp report on filing_history.rpt_tp = report.rpt_tp_cd
WHERE rpt_yr >= :START_YEAR and delete_ind is null
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
create index on ofec_filings_mv_tmp (report_type_full, idx);
create index on ofec_filings_mv_tmp (report_year, idx);
create index on ofec_filings_mv_tmp (cycle, idx);
create index on ofec_filings_mv_tmp (total_receipts, idx);
create index on ofec_filings_mv_tmp (total_disbursements, idx);
create index on ofec_filings_mv_tmp (total_independent_expenditures, idx);
create index on ofec_filings_mv_tmp (coverage_start_date, idx);
create index on ofec_filings_mv_tmp (coverage_end_date, idx);
create index on ofec_filings_mv_tmp (cycle, committee_id);
