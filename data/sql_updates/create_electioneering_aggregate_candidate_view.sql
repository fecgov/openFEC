drop materialized view if exists ofec_electioneering_aggregate_candidate_mv_tmp;
create materialized view ofec_electioneering_aggregate_candidate_mv_tmp as
with disbursements as (
    select * from sched_b
    where link_id in (select link_id from form_94)
    and rpt_yr >= 2002
)
select
    row_number() over () as idx,
    f9.filer_cmte_id as cmte_id,
    f9.cand_id,
    sum(disb.disb_amt) as total,
    count(disb.disb_amt) as count,
    disb.rpt_yr + disb.rpt_yr % 2 as cycle
from form_94 f9
join disbursements disb using (link_id)
where disb.rpt_yr >= :START_YEAR
group by
    f9.filer_cmte_id,
    f9.cand_id,
    cycle
;

create unique index on ofec_electioneering_aggregate_candidate_mv_tmp (idx);

create index on ofec_electioneering_aggregate_candidate_mv_tmp (cmte_id);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (cand_id);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (cycle);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (total);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (count);
