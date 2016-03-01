drop table if exists ofec_electioneering_tmp;
create table ofec_electioneering_tmp as
-- Find out if there is a better unique identifier
select
    row_number() over () as idx,
    electioneering_com_vw.*,
    to_tsvector(disb_desc) as purpose_description_text
from electioneering_com_vw
where rpt_yr >= %(START_YEAR)s
;

create unique index on ofec_electioneering_tmp (idx);

create index on ofec_electioneering_tmp (cmte_id);
create index on ofec_electioneering_tmp (cand_id);
create index on ofec_electioneering_tmp (cand_office);
create index on ofec_electioneering_tmp (cand_office_st);
create index on ofec_electioneering_tmp (cand_office_district);
create index on ofec_electioneering_tmp (disb_dt);
create index on ofec_electioneering_tmp (reported_disb_amt);
create index on ofec_electioneering_tmp (calculated_cand_share);
create index on ofec_electioneering_tmp (rpt_yr);
create index on ofec_electioneering_tmp (f9_begin_image_num);
create index on ofec_electioneering_tmp (sb_image_num);

create index on ofec_electioneering_tmp using gin (purpose_description_text);

drop table if exists ofec_electioneering;
alter table ofec_electioneering_tmp rename to ofec_electioneering;
