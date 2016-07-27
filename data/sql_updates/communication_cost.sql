drop materialized view if exists ofec_communication_cost_mv_tmp;
create materialized view ofec_communication_cost_mv_tmp as
select
    row_number() over () as idx,
    *,
    s_o_cand_id as cand_id,
    org_id as cmte_id,
    report_pdf_url(image_num) as pdf_url
from fec_vsum_f76
where extract(year from communication_dt)::integer >= :START_YEAR
;

create unique index on ofec_communication_cost_mv_tmp (idx);

create index on ofec_communication_cost_mv_tmp (cmte_id);
create index on ofec_communication_cost_mv_tmp (cand_id);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_st);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_district);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office);
create index on ofec_communication_cost_mv_tmp (s_o_ind);
--create index on ofec_communication_cost_mv_tmp (cand_pty_affiliation);
--create index on ofec_communication_cost_mv_tmp (transaction_dt);
--create index on ofec_communication_cost_mv_tmp (transaction_amt);
create index on ofec_communication_cost_mv_tmp (communication_dt);
create index on ofec_communication_cost_mv_tmp (communication_cost);
create index on ofec_communication_cost_mv_tmp (communication_tp);
create index on ofec_communication_cost_mv_tmp (communication_class);
create index on ofec_communication_cost_mv_tmp (image_num);
create index on ofec_communication_cost_mv_tmp (filing_form);
--create index on ofec_communication_cost_mv_tmp (line_num);
--create index on ofec_communication_cost_mv_tmp (sched_tp_cd);
--create index on ofec_communication_cost_mv_tmp (rpt_yr);
