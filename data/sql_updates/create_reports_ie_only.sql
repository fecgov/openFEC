drop view if exists ofec_reports_ie_only_vw;
drop materialized view if exists ofec_reports_ie_only_mv_tmp;
create materialized view ofec_reports_ie_only_mv_tmp as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    factindpexpcontb_f5_sk as key,
    form_5_sk as form_key,
    two_yr_period_sk as cycle,
    -- will this stay the same?
    transaction_sk as transaction_id,
    start_date.dw_date as coverage_start_date,
    end_date.dw_date as coverage_end_date,
    rpt_yr as report_year,
    ttl_indt_contb as independent_contributions_period,
    ttl_indt_exp as independent_expenditures_period,
    filer_sign_dt as filer_sign_date,
    notary_sign_dt as notary_sign_date,
    notary_commission_exprtn_dt as notary_commission_experation_date,
    begin_image_num as beginning_image_number,
    end_image_num as end_image_number,
    ief5.load_date as load_date,
    ief5.expire_date as expire_date,
    rt.rpt_tp as report_type,
    election_type_id as election_type,
    election_type_desc as election_type_full,
    rpt_tp_desc as report_type_full
from
    dimcmte c
    right join factindpexpcontb_f5 ief5 on indv_org_sk = c.cmte_sk
    left join dimreporttype rt using (reporttype_sk)
    left join dimelectiontp et using (electiontp_sk)
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    two_yr_period_sk >= :START_YEAR
;

create unique index on ofec_reports_ie_only_mv_tmp(idx);

create index on ofec_reports_ie_only_mv_tmp(cycle, idx);
create index on ofec_reports_ie_only_mv_tmp(expire_date, idx);
create index on ofec_reports_ie_only_mv_tmp(report_type, idx);
create index on ofec_reports_ie_only_mv_tmp(report_year, idx);
create index on ofec_reports_ie_only_mv_tmp(committee_id, idx);
create index on ofec_reports_ie_only_mv_tmp(coverage_end_date, idx);
create index on ofec_reports_ie_only_mv_tmp(coverage_start_date, idx);
create index on ofec_reports_ie_only_mv_tmp(beginning_image_number, idx);
