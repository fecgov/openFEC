drop materialized view if exists ofec_electioneering_aggregate_candidate_mv_tmp;
create materialized view ofec_electioneering_aggregate_candidate_mv_tmp as
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    sum(calculated_cand_share) as total,
    count(calculated_cand_share) as count,
    rpt_yr + rpt_yr % 2 as cycle
from electioneering_com_vw
    where rpt_yr >= :START_YEAR
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
