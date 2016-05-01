drop materialized view if exists ofec_electioneering_mv_tmp;
create materialized view ofec_electioneering_mv_tmp as
select
    row_number() over () as idx,
    electioneering_com_vw.*,
    image_pdf_url(sb_image_num) as pdf_url,
    to_tsvector(disb_desc) as purpose_description_text
from electioneering_com_vw
where rpt_yr >= :START_YEAR
;

create unique index on ofec_electioneering_mv_tmp (idx);

create index on ofec_electioneering_mv_tmp (cmte_id);
create index on ofec_electioneering_mv_tmp (cand_id);
create index on ofec_electioneering_mv_tmp (cand_office);
create index on ofec_electioneering_mv_tmp (cand_office_st);
create index on ofec_electioneering_mv_tmp (cand_office_district);
create index on ofec_electioneering_mv_tmp (disb_dt);
create index on ofec_electioneering_mv_tmp (reported_disb_amt);
create index on ofec_electioneering_mv_tmp (calculated_cand_share);
create index on ofec_electioneering_mv_tmp (rpt_yr);
create index on ofec_electioneering_mv_tmp (f9_begin_image_num);
create index on ofec_electioneering_mv_tmp (sb_image_num);

create index on ofec_electioneering_mv_tmp using gin (purpose_description_text);
