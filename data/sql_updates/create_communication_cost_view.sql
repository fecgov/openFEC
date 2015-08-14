drop materialized view if exists ofec_aggregate_communication_cost_candidate_mv_tmp;
create materialized view ofec_aggregate_communication_cost_candidate_mv_tmp as
select
    org_id,
    s_o_cand_id,
    s_o_ind,
    sum(communication_cost) as total_communicaion_cost,
    count(communication_cost) as count,
    cast(extract(YEAR from communication_dt) AS integer) + cast(extract(YEAR from communication_dt) as integer) % 2 as cycle
from form_76
where extract( YEAR from communication_dt) >= :START_YEAR
and s_o_cand_id is not null
and amndt_ind != 'A'
group by org_id, s_o_cand_id, s_o_ind, cycle
;

create index on ofec_aggregate_communication_cost_candidate_mv_tmp (org_id);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (s_o_cand_id);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (cycle);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (total_communicaion_cost);
