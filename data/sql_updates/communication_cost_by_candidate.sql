drop table if exists ofec_communication_cost_aggregate_candidate_tmp;
create table ofec_communication_cost_aggregate_candidate_tmp as
select
    row_number() over () as idx,
    cmte_id,
    cand_id,
    support_oppose_ind as support_oppose_indicator,
    sum(transaction_amt) as total,
    count(transaction_amt) as count,
    get_cycle(rpt_yr) as cycle
from communication_costs_vw
where rpt_yr >= %(START_YEAR)s and
cand_id is not null
group by
    cmte_id,
    cand_id,
    support_oppose_indicator,
    cycle
;

create unique index on ofec_communication_cost_aggregate_candidate_tmp (idx);

create index on ofec_communication_cost_aggregate_candidate_tmp (cmte_id);
create index on ofec_communication_cost_aggregate_candidate_tmp (cand_id);
create index on ofec_communication_cost_aggregate_candidate_tmp (support_oppose_indicator);
create index on ofec_communication_cost_aggregate_candidate_tmp (cycle);
create index on ofec_communication_cost_aggregate_candidate_tmp (total);
create index on ofec_communication_cost_aggregate_candidate_tmp (count);

drop table if exists ofec_communication_cost_aggregate_candidate;
alter table ofec_communication_cost_aggregate_candidate_tmp rename to ofec_communication_cost_aggregate_candidate;
