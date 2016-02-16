drop table if exists ofec_electioneering_aggregate_candidate_tmp;
create table ofec_electioneering_aggregate_candidate_tmp as
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    sum(calculated_cand_share) as total,
    count(calculated_cand_share) as count,
    get_cycle(rpt_yr) as cycle
from electioneering_com_vw
    where rpt_yr >= %(START_YEAR)s
group by
    cmte_id,
    cand_id,
    cycle
;

create unique index on ofec_electioneering_aggregate_candidate_tmp (idx);

create index on ofec_electioneering_aggregate_candidate_tmp (cmte_id);
create index on ofec_electioneering_aggregate_candidate_tmp (cand_id);
create index on ofec_electioneering_aggregate_candidate_tmp (cycle);
create index on ofec_electioneering_aggregate_candidate_tmp (total);
create index on ofec_electioneering_aggregate_candidate_tmp (count);

drop table if exists ofec_electioneering_aggregate_candidate;
alter table ofec_electioneering_aggregate_candidate_tmp rename to ofec_electioneering_aggregate_candidate;
