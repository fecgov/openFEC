drop materialized view if exists ofec_communication_cost_mv_tmp;
create materialized view ofec_communication_cost_mv_tmp as
select
    row_number() over () as idx,
    f76.*,
    f76.s_o_cand_id as cand_id,
    f76.org_id as cmte_id,
    committee_history.name as committee_name,
    report_pdf_url(image_num) as pdf_url
from fec_vsum_f76_vw f76
    left join ofec_committee_history_mv_tmp committee_history on f76.org_id = committee_history.committee_id
where extract(year from communication_dt)::integer >= :START_YEAR
;

create unique index on ofec_communication_cost_mv_tmp (sub_id);

create index on ofec_communication_cost_mv_tmp (cmte_id);
create index on ofec_communication_cost_mv_tmp (cand_id);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_st);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office_district);
create index on ofec_communication_cost_mv_tmp (s_o_cand_office);
create index on ofec_communication_cost_mv_tmp (s_o_ind);
create index on ofec_communication_cost_mv_tmp (communication_dt);
create index on ofec_communication_cost_mv_tmp (communication_cost);
create index on ofec_communication_cost_mv_tmp (communication_tp);
create index on ofec_communication_cost_mv_tmp (communication_class);
create index on ofec_communication_cost_mv_tmp (image_num);
create index on ofec_communication_cost_mv_tmp (filing_form);