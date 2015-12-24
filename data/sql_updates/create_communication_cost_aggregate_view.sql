drop materialized view if exists ofec_communication_cost_aggregate_candidate_mv_tmp;
create materialized view ofec_communication_cost_aggregate_candidate_mv_tmp as
select
    row_number() over () as idx,
    org_id as cmte_id,
    s_o_cand_id as cand_id,
    s_o_ind as support_oppose_indicator,
    sum(communication_cost) as total,
    count(communication_cost) as count,
    date_part('year', communication_dt)::int + date_part('year', communication_dt)::int % 2 as cycle
from form_76
where date_part('year', communication_dt)::int >= :START_YEAR
and s_o_cand_id is not null
group by
    cmte_id,
    cand_id,
    support_oppose_indicator,
    cycle
;

create unique index on ofec_communication_cost_aggregate_candidate_mv_tmp (idx);

create index on ofec_communication_cost_aggregate_candidate_mv_tmp (cmte_id);
create index on ofec_communication_cost_aggregate_candidate_mv_tmp (cand_id);
create index on ofec_communication_cost_aggregate_candidate_mv_tmp (support_oppose_indicator);
create index on ofec_communication_cost_aggregate_candidate_mv_tmp (cycle);
create index on ofec_communication_cost_aggregate_candidate_mv_tmp (total);
create index on ofec_communication_cost_aggregate_candidate_mv_tmp (count);
