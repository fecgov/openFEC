create or replace function fix_party_spelling(branch text)
returns text as $$
    begin
        return case branch
            when 'Party/Non Pary' then 'Party/Non Party'
            else branch
        end;
    end
$$ language plpgsql;

drop materialized view if exists ofec_rad_mv_tmp;
create materialized view ofec_rad_mv_tmp as
select
    row_number() over () as idx,
    cmte_id as committee_id,
    -- I am not sure we want to filter on this, if the name is different here it will behave differently than the other committee searches by name
    cmte_nm as committee_name,
    anlyst_id as analyst_id,
    cast(anlyst_short_id as numeric) as analyst_short_id,
    fix_party_spelling(rad_branch) as rad_branch,
    firstname as first_name,
    lastname as last_name,
    to_tsvector(firstname || ' ' || lastname) as name_txt,
    telephone_ext
from rad_cmte_analyst_search_vw
;

create unique index on ofec_rad_mv_tmp (idx);

create index on ofec_rad_mv_tmp (committee_id);
create index on ofec_rad_mv_tmp (analyst_id);
create index on ofec_rad_mv_tmp (analyst_short_id);
create index on ofec_rad_mv_tmp (rad_branch);
create index on ofec_rad_mv_tmp (telephone_ext);
create index on ofec_rad_mv_tmp (committee_name);
create index on ofec_rad_mv_tmp (last_name);
create index on ofec_rad_mv_tmp using gin(name_txt);
