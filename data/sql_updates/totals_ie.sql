drop materialized view if exists ofec_totals_ie_only_mv_tmp cascade;
create materialized view ofec_totals_ie_only_mv_tmp as
select
    row_number() over () as idx,
    indv_org_id as committee_id,
    election_cycle as cycle,
    min(cvg_start_dt) as coverage_start_date,
    max(cvg_end_dt) as coverage_end_date,
    sum(ttl_indt_contb) as total_independent_contributions,
    sum(ttl_indt_exp) as total_independent_expenditures
from
    fec_vsum_f5
where
    election_cycle >= :START_YEAR
    and most_recent_filing_flag like 'Y'
group by
    indv_org_id,
    election_cycle
;

create unique index on ofec_totals_ie_only_mv_tmp(idx);

create index on ofec_totals_ie_only_mv_tmp(cycle, idx);
create index on ofec_totals_ie_only_mv_tmp(committee_id, idx);
