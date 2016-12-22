drop materialized view if exists ofec_communication_cost_aggregate_candidate_mv_tmp;
create materialized view ofec_communication_cost_aggregate_candidate_mv_tmp as
select
    row_number() over () as idx,
    s_o_ind as support_oppose_indicator,
    org_id as cmte_id,
    s_o_cand_id as cand_id,
    sum(communication_cost) as total,
    count(communication_cost) as count,
    extract(year from communication_dt)::integer + extract(year from communication_dt)::integer % 2 as cycle
from fec_vsum_f76_vw
where extract(year from communication_dt) >= :START_YEAR
and s_o_cand_id is not null
group by
    org_id,
    s_o_cand_id,
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
