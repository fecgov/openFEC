drop materialized view if exists ofec_communication_cost_mv_tmp;
create materialized view ofec_communication_cost_mv_tmp as
select *
from form_76
where date_part('year', communication_dt)::int >= :START_YEAR
;

create unique index on ofec_communication_cost_mv_tmp (form_76_sk);

create index on ofec_communication_cost_mv_tmp (org_id);
create index on ofec_communication_cost_mv_tmp (form_tp);
create index on ofec_communication_cost_mv_tmp (communication_tp);
create index on ofec_communication_cost_mv_tmp (communication_class);
create index on ofec_communication_cost_mv_tmp (communication_dt);
create index on ofec_communication_cost_mv_tmp (s_o_ind);
create index on ofec_communication_cost_mv_tmp (s_o_cand_id);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_st);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_district);
create index on ofec_communication_cost_mv_tmp (s_o_rpt_pgi);
create index on ofec_communication_cost_mv_tmp (communication_cost);
create index on ofec_communication_cost_mv_tmp (amndt_ind);
create index on ofec_communication_cost_mv_tmp (image_num);
