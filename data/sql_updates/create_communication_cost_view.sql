drop materialized view if exists ofec_aggregate_communication_cost_candidate_mv_tmp;
create materialized view ofec_aggregate_communication_cost_candidate_mv_tmp as
select
    org_id as cmte_id,
    s_o_cand_id as cand_id,
    s_o_ind as support_oppose_indicator,
    sum(communication_cost) as total,
    count(communication_cost) as count,
    cast(extract(YEAR from communication_dt) AS integer) +
        cast(extract(YEAR from communication_dt) as integer) % 2
        as cycle
from form_76
where extract(YEAR from communication_dt) >= :START_YEAR
and s_o_cand_id is not null
and amndt_ind != 'A'
group by
    cmte_id,
    cand_id,
    support_oppose_indicator,
    cycle
;

create index on ofec_aggregate_communication_cost_candidate_mv_tmp (cmte_id);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (cand_id);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (support_oppose_indicator);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (cycle);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (total);
create index on ofec_aggregate_communication_cost_candidate_mv_tmp (count);
