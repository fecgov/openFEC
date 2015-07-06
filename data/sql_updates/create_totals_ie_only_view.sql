drop materialized view if exists ofec_totals_ie_only_mv_tmp;
create materialized view ofec_totals_ie_only_mv_tmp as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    two_yr_period_sk as cycle,
    min(start_date.dw_date) as coverage_start_date,
    max(end_date.dw_date) as coverage_end_date,
    sum(ttl_indt_contb) as total_independent_contributions,
    sum(ttl_indt_exp) as total_independent_expenditures
from
    dimcmte c
    right join factindpexpcontb_f5 ief5 on indv_org_sk = c.cmte_sk
    left join dimdates start_date on cvg_start_dt_sk = start_date.date_sk and cvg_start_dt_sk != 1
    left join dimdates end_date on cvg_end_dt_sk = end_date.date_sk and cvg_end_dt_sk != 1
where
    two_yr_period_sk >= :START_YEAR
    and ief5.expire_date is null
group by committee_id, cycle
;

create unique index on ofec_totals_ie_only_mv_tmp(idx);

create index on ofec_totals_ie_only_mv_tmp(cycle);
create index on ofec_totals_ie_only_mv_tmp(committee_id);
