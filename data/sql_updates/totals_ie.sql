drop materialized view if exists ofec_totals_ie_only_mv_tmp cascade;
create materialized view ofec_totals_ie_only_mv_tmp as
select
    orig_sub_id as sub_id,
    cmte_id as committee_id,
    get_cycle(rpt_yr) as cycle,
    min(cvg_start_dt) as coverage_start_date,
    max(cvg_end_dt) as coverage_end_date,
    sum(ttl_contb) as total_independent_contributions,
    sum(indt_exp_per) as total_independent_expenditures
from
    disclosure.v_sum_and_det_sum_report
where
    election_cycle >= :START_YEAR

group by
    cmte_id,
    get_cycle(rpt_yr)
;

create unique index on ofec_totals_ie_only_mv_tmp(sub_id);

create index on ofec_totals_ie_only_mv_tmp(cycle, sub_id);
create index on ofec_totals_ie_only_mv_tmp(committee_id, sub_id);
