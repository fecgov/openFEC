-- This view powers election search
drop materialized view if exists ofec_election_result_mv_tmp;
create materialized view ofec_election_result_mv_tmp as
-- get the years with election records by office, state and district
-- this data starts in 2003
with election_dates_house_senate as(
    select
        election_state,
        office_sought,
        election_district,
        election_yr
    from fecapp.trc_election
    where office_sought != 'P'
        group by
        election_state,
        office_sought,
        election_district,
        election_yr
),
election_dates_president as(
    select distinct on (election_yr)
        'US'::char(2) as election_state,
        office_sought,
        election_district,
        election_yr
    from fecapp.trc_election
    where office_sought = 'P'
        group by
        election_state,
        office_sought,
        election_district,
        election_yr
),
-- Pull background info for the races
-- See discussion in https://github.com/18F/openFEC-web-app/issues/514
incumbent_info as(
    select distinct on (cand_office_st, cand_office_district, cand_office, cand_election_yr) *
    from disclosure.cand_valid_fec_yr
    where
        cand_ici = 'I'
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
-- This creates election records and the incumbent info if applicable.
-- We need to do this because a null in the elections date district data
-- means all the districts in the state but the district is listed,
-- it only applies to one district.
records_with_incumbents_districts as (
    select
        fec.cand_valid_yr_id,
        fec.cand_id,
        ed.election_yr + ed.election_yr % 2 as fec_election_yr,
        fec.cand_election_yr::numeric,
        fec.cand_status,
        fec.cand_ici,
        ed.office_sought as cand_office,
        ed.election_state as cand_office_st,
        ed.election_district as cand_office_district,
        fec.cand_pty_affiliation,
        fec.cand_name,
        ed.election_yr::numeric as election_yr
    from election_dates_house_senate ed
    left join
        incumbent_info fec on
        ed.election_state = fec.cand_office_st and
        ed.office_sought = fec.cand_office and
        -- in the date table the district is 3 characters
        cast(ed.election_district as varchar(2)) = fec.cand_office_district and
        ed.election_yr = fec.cand_election_yr
    where
        election_district is not null and
        election_district != '' and
        election_district != ' '
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
-- This creates election records and the incumbent info if applicable
-- for Senate and House races without districts
records_with_incumbents as (
    select
        fec.cand_valid_yr_id,
        fec.cand_id,
        ed.election_yr + ed.election_yr % 2 as fec_election_yr,
        ed.election_yr as cand_election_yr,
        fec.cand_status,
        fec.cand_ici,
        ed.office_sought as cand_office,
        ed.election_state as cand_office_st,
        case
             when ed.office_sought = 'H'
                 then fec.cand_office_district
             else cast('00' as varchar(2))
        end as cand_office_district,
        fec.cand_pty_affiliation,
        fec.cand_name,
        ed.election_yr::numeric as election_yr
    from election_dates_house_senate ed
    left join
        incumbent_info fec on
        ed.election_state = fec.cand_office_st and
        ed.office_sought = fec.cand_office and
        ed.election_yr = fec.cand_election_yr
    where (ed.election_district is null or ed.election_district = '' or ed.election_district = ' ') and
        ed.office_sought != 'P'
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
records_with_incumbents_president as (
     select
        fec.cand_valid_yr_id,
        fec.cand_id,
        ed.election_yr + ed.election_yr % 2 as fec_election_yr,
        fec.cand_election_yr::numeric,
        fec.cand_status,
        fec.cand_ici,
        ed.office_sought as cand_office,
        'US'::char(2) as cand_office_st,
        cast('00' as varchar(2)) as cand_office_district,
        fec.cand_pty_affiliation,
        fec.cand_name,
        ed.election_yr::numeric as election_yr
    from election_dates_president ed
    left join
        incumbent_info fec on
        ed.election_yr = fec.cand_election_yr
    where
        fec.cand_office = 'P'
    order by
        cand_election_yr desc,
        latest_receipt_dt desc
),
combined as(
    select * from records_with_incumbents_districts
    union all
    select * from records_with_incumbents
    union all
    select * from records_with_incumbents_president
)
select
    *,
    row_number() over () as idx
from combined
;

create unique index on ofec_election_result_mv_tmp (idx);

create index on ofec_election_result_mv_tmp (election_yr);
create index on ofec_election_result_mv_tmp (cand_office);
create index on ofec_election_result_mv_tmp (cand_office_st);
create index on ofec_election_result_mv_tmp (cand_office_district);
