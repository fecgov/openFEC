drop materialized view if exists ofec_communication_cost_aggregate_candidate_mv_tmp;
create materialized view ofec_communication_cost_aggregate_candidate_mv_tmp as
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    support_oppose_ind as support_oppose_indicator,
    sum(transaction_amt) as total,
    count(transaction_amt) as count,
    rpt_yr + rpt_yr % 2 as cycle
from communication_costs_vw
where rpt_yr >= :START_YEAR
and cand_id is not null
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
