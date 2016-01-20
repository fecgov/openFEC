drop materialized view if exists ofec_electioneering_aggregate_candidate_mv_tmp;
create materialized view ofec_electioneering_aggregate_candidate_mv_tmp as
with disbursements as (
    select * from sched_b
    where link_id in (select link_id from form_94)
    and rpt_yr >= 2002
)
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    sum(calculated_cand_share) as total,
    count(calculated_cand_share) as count,
    rpt_yr + rpt_yr % 2 as cycle
from electioneering_com_vw
group by
    cmte_id,
    cand_id,
    cycle
;

create unique index on ofec_electioneering_aggregate_candidate_mv_tmp (idx);

create index on ofec_electioneering_aggregate_candidate_mv_tmp (cmte_id);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (cand_id);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (cycle);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (total);
create index on ofec_electioneering_aggregate_candidate_mv_tmp (count);
