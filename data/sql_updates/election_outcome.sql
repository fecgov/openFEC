-- Powers election search
------------------------- drop materialized view if exists ofec_election_result_mv_tmp;
------------------------- create materialized view ofec_election_result_mv_tmp as
-- get the years with election records by office, state and district
-- this data starts in 2003
with election_dates as(
    select
        case when office_sought = 'P' then null
            else election_state
        end as election_state,
        office_sought,
       case when office_sought = 'H' and (trim(election_district) = '' or election_district is null) then '00'
            else election_district
        end as election_district,
        election_yr
    from fecapp.trc_election
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
        cand_ici = 'I' and
        fec_election_yr >= 2003
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
records_with_incumbents as (
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
    from election_dates ed
    left join
        incumbent_info fec on
        ed.election_state = fec.cand_office_st and
        ed.office_sought = fec.cand_office and
        ed.election_district = fec.cand_office_district and
        ed.election_yr = fec.cand_election_yr
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
-- We don't have future candidates in the ICI data, so we want to look that up
record_without_incumbents as (
    select * from records_with_incumbents
    where cand_id is null
),
elections_without_incumbents as (
    select distinct on (rwi.cand_office_st, rwi.cand_office_district, rwi.cand_office, rwi.election_yr)
        fec.cand_valid_yr_id,
        check_incumbent_char(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_id::char
        ) as cand_id,
        rwi.fec_election_yr,
        check_incumbent_numeric(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_election_yr::numeric
        )::numeric as cand_election_yr,
        check_incumbent_char(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_status::char
        ) cand_status,
        check_incumbent_char(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_ici::char
        ) cand_ici,
        rwi.cand_office,
        rwi.cand_office_st,
        rwi.cand_office_district,
        check_incumbent_char(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_pty_affiliation::char
        ) cand_pty_affiliation,
        check_incumbent_char(
            fec.cand_office::char, rwi.election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_name::char
        ) cand_name,
        rwi.election_yr
    from record_without_incumbents rwi
    left join
        incumbent_info fec on
        rwi.cand_office_st = fec.cand_office_st and
        rwi.cand_office_district = fec.cand_office_district and
        rwi.cand_office = fec.cand_office and
        rwi.cand_election_yr > fec.cand_election_yr
    order by
        rwi.cand_office_st,
        rwi.cand_office,
        rwi.cand_office_district,
        rwi.election_yr desc,
        fec.cand_election_yr desc,
        fec.latest_receipt_dt desc
),
combined as (
    select * from
        records_with_incumbents
        where cand_id is not null
    union all
    select * from
        record_without_incumbents
)
select
    *,
    row_number() over () as idx
from combined
;
-- change to idx
create unique index on ofec_election_result_mv_tmp (idx);

create index on ofec_election_result_mv_tmp (election_yr);
create index on ofec_election_result_mv_tmp (cand_office);
create index on ofec_election_result_mv_tmp (cand_office_st);
create index on ofec_election_result_mv_tmp (cand_office_district);
