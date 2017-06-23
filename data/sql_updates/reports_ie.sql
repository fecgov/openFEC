drop materialized view if exists ofec_reports_ie_only_mv_tmp;
create materialized view ofec_reports_ie_only_mv_tmp as
select
    row_number() over () as idx,
    indv_org_id as committee_id,
    election_cycle as cycle,
    cvg_start_dt as coverage_start_date,
    cvg_end_dt as coverage_end_date,
    rpt_yr as report_year,
    ttl_indt_contb as independent_contributions_period,
    ttl_indt_exp as independent_expenditures_period,
    filer_sign_dt as filer_sign_date,
    notary_sign_dt as notary_sign_date,
    notary_commission_exprtn_dt as notary_commission_experation_date,
    begin_image_num as beginning_image_number,
    end_image_num as end_image_number,
    rpt_tp as report_type,
    rpt_tp_desc as report_type_full,
    most_recent_filing_flag like 'N' as is_amended,
    receipt_dt as receipt_date,
    file_num as file_number,
    amndt_ind as amendment_indicator,
    amndt_ind_desc as amendment_indicator_full,
    means_filed(begin_image_num) as means_filed,
    report_html_url(means_filed(begin_image_num), indv_org_id::text, file_num::text) as html_url,
    report_fec_url(begin_image_num::text, file_num::integer) as fec_url
from
    fec_vsum_f5_vw
where
    election_cycle >= :START_YEAR
;

create unique index on ofec_reports_ie_only_mv_tmp(idx);

create index on ofec_reports_ie_only_mv_tmp(cycle, idx);
create index on ofec_reports_ie_only_mv_tmp(report_type, idx);
create index on ofec_reports_ie_only_mv_tmp(report_year, idx);
create index on ofec_reports_ie_only_mv_tmp(committee_id, idx);
create index on ofec_reports_ie_only_mv_tmp(coverage_end_date, idx);
create index on ofec_reports_ie_only_mv_tmp(coverage_start_date, idx);
create index on ofec_reports_ie_only_mv_tmp(beginning_image_number, idx);
create index on ofec_reports_ie_only_mv_tmp(is_amended, idx);
create index on ofec_reports_ie_only_mv_tmp(receipt_date, idx);
create index on ofec_reports_ie_only_mv_tmp(independent_expenditures_period, idx);


