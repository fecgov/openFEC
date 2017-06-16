create or replace function check_incumbent_char(office char, election_yr numeric, cand_election_yr numeric, value char)
returns text as $$
    begin
        return case acronym
        -- add upper?
            when 'office' = 'H' and election_yr - cand_election_yr <= 2
                then value
            when 'office' = 'S' and election_yr - cand_election_yr <= 6
                then value
            when 'office' = 'P' and election_yr - cand_election_yr <= 4
                then value
            else null
        end;
    end
$$ language plpgsql;

create or replace function check_incumbent_numeric(office char, election_yr numeric, cand_election_yr numeric, value numeric)
returns text as $$
    begin
        return case acronym
        -- add upper?
            when 'office' = 'H' and election_yr - cand_election_yr <= 2
                then value
            when 'office' = 'S' and election_yr - cand_election_yr <= 6
                then value
            when 'office' = 'P' and election_yr - cand_election_yr <= 4
                then value
            else null
        end;
    end
$$ language plpgsql;



-- Powers election search
drop materialized view if exists ofec_election_result_mv_tmp;
create materialized view ofec_election_result_mv_tmp as
-- get the years with election records by office, state and district
-- this data starts in 2003
with election_dates as(
    select
        election_state,
        office_sought,
        election_district,
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
records_with_incuments as (
    select
        fec.cand_valid_yr_id,
        fec.cand_id,
        fec.fec_election_yr,
        fec.cand_election_yr,
        fec.cand_status,
        fec.cand_ici,
        fec.cand_office,
        fec.cand_office_st,
        fec.cand_office_district,
        fec.cand_pty_affiliation,
        fec.cand_name,
        cand_election_yr as election_yr
    from election_dates
    inner join
        incumbent_info fec on
        election_dates.election_state = fec.cand_office_st and
        election_dates.office_sought = fec.cand_office and
        election_dates.election_district = fec.cand_office_district and
        election_dates.election_yr = fec.cand_election_yr
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
),
-- We don't have future candidates in the ICI data, so we want to look that up
record_without_incubents as (
    select distinct on (ed.cand_office_st, ed.cand_office_district, ed.cand_office, ed.cand_election_yr)
        fec.cand_valid_yr_id,
        check_incumbent_char(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_id::char
        ) as cand_id,
        ed.cand_election_yr + ed.cand_election_yr % 2 as fec_election_yr,
        check_incumbent_numeric(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_election_yr::numeric
        ) as cand_election_yr,
        check_incumbent_char(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_status::char
        ) cand_status,
        check_incumbent_char(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_ici::char
        ) cand_ici,
        ed.cand_office,
        ed.cand_office_st,
        ed.cand_office_district,
        check_incumbent_char(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_pty_affiliation::char
        ) cand_pty_affiliation,
        check_incumbent_char(
            fec.cand_office::char, ed.cand_election_yr::numeric,
            fec.cand_election_yr::numeric, fec.cand_name::char
        ) cand_name,
        ed.cand_election_yr as election_yr
    from election_dates ed
    left join
        incumbent_info fec on
        election_dates.election_state = fec.cand_office_st and
        election_dates.office_sought = fec.cand_office and
        election_dates.election_district = fec.cand_office_district and
        election_dates.election_yr < fec.cand_election_yr
--- trying to find no incumbent records
    -- where fec.xx not exist (
    --     select xx
    --     from election_dates
    --     left join on records_with_incuments
    --     where fec.cand_id is null
    --     order by
    --         cand_office_st,
    --         cand_office,
    --         cand_office_district,
    --         cand_election_yr desc,
    --         latest_receipt_dt desc
    -- )
    order by
        cand_office_st,
        cand_office,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
)
select * from
    records_with_incuments
union all
select * from
    record_without_incubents
;
-- change to idx
create unique index on ofec_election_result_mv_tmp (cand_valid_yr_id);

create index on ofec_election_result_mv_tmp (election_yr);
create index on ofec_election_result_mv_tmp (cand_office);
create index on ofec_election_result_mv_tmp (cand_office_st);
create index on ofec_election_result_mv_tmp (cand_office_district);
