drop materialized view if exists ofec_communication_cost_mv_tmp;
create materialized view ofec_communication_cost_mv_tmp as
select
    *,
    date_or_null(transaction_dt::text, 'YYYYMMDD') as _transaction_dt,
    row_number() over () as idx
from communication_costs_vw
where rpt_yr >= :START_YEAR
;

create unique index on ofec_communication_cost_mv_tmp (idx);

create index on ofec_communication_cost_mv_tmp (cmte_id);
create index on ofec_communication_cost_mv_tmp (cand_id);
create index on ofec_communication_cost_mv_tmp (cand_office_st);
create index on ofec_communication_cost_mv_tmp (cand_office_district);
create index on ofec_communication_cost_mv_tmp (cand_office);
create index on ofec_communication_cost_mv_tmp (cand_pty_affiliation);
create index on ofec_communication_cost_mv_tmp (_transaction_dt);
create index on ofec_communication_cost_mv_tmp (transaction_amt);
create index on ofec_communication_cost_mv_tmp (communication_tp);
create index on ofec_communication_cost_mv_tmp (communication_class);
create index on ofec_communication_cost_mv_tmp (support_oppose_ind);
create index on ofec_communication_cost_mv_tmp (image_num);
create index on ofec_communication_cost_mv_tmp (line_num);
create index on ofec_communication_cost_mv_tmp (form_tp_cd);
create index on ofec_communication_cost_mv_tmp (sched_tp_cd);
create index on ofec_communication_cost_mv_tmp (rpt_yr);
