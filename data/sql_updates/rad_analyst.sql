drop materialized view if exists ofec_rad_mv_tmp;
create materialized view ofec_rad_mv_tmp as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    -- I am not sure we want to sort on this, if the name is different here it will behave differently than the other committee searches by name
    cmte_nm as committee_name,
    anlyst_id,
    rad_branch,
    firstname as first_name,
    lastname as last_name,
    to_tsvector(firstname || ' ' || lastname) as name_txt,
    telephone_ext
from rad_cmte_analyst_search_vw
;

create unique index on ofec_rad_mv_tmp (idx);

create index on ofec_rad_mv_tmp (committee_id);
create index on ofec_rad_mv_tmp (anlyst_id);
create index on ofec_rad_mv_tmp (rad_branch);
create index on ofec_rad_mv_tmp (telephone_ext);
create index on ofec_rad_mv_tmp using gin(name_txt);
