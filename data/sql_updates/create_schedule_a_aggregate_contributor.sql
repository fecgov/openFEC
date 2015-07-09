-- Aggregate Schedule A filings by recipient, contributor, and cycle
-- Note: Cycle refers to year for form F3X filers, else two-year period
drop materialized view if exists ofec_sched_a_aggregate_contributor_mv_tmp;
create materialized view ofec_sched_a_aggregate_contributor_mv_tmp as
select distinct on (cmte_id, contbr_id, cycle)
    row_number() over () as idx,
    cmte_id,
    contbr_id,
    case
        when filing_form = 'F3X' then rpt_yr
        else rpt_yr + rpt_yr % 2
    end as cycle,
    contb_aggregate_ytd as total
from sched_a
where rpt_yr >= :START_YEAR_ITEMIZED
and contbr_id is not null
and entity_tp != 'IND'
order by cmte_id, contbr_id, cycle, contb_receipt_dt desc
;

create unique index on ofec_sched_a_aggregate_contributor_mv_tmp (idx);

create index on ofec_sched_a_aggregate_contributor_mv_tmp (cmte_id);
create index on ofec_sched_a_aggregate_contributor_mv_tmp (contbr_id);
create index on ofec_sched_a_aggregate_contributor_mv_tmp (cycle);
create index on ofec_sched_a_aggregate_contributor_mv_tmp (total);
