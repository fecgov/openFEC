-- Powers election search merges with ofec_cand_history to make election views
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
    select distinct on (cand_office_st, cand_office_district, cand_election_yr) *
    from disclosure.cand_valid_fec_yr
    where
        cand_ici = 'I' and
        fec_election_yr >= 2003
    order by
        cand_office_st,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
)
select
    fec.*,
    cand_election_yr as election_yr
from election_dates
left join
    incumbent_info fec on
    election_dates.election_state = fec.cand_office_st and
    election_dates.office_sought = fec.cand_office and
    election_dates.election_district = fec.cand_office_district and
    election_dates.election_yr = fec.cand_election_yr
order by
    cand_office_st,
    cand_office_district,
    cand_election_yr desc,
    latest_receipt_dt desc
;

create unique index on ofec_election_result_mv_tmp (cand_valid_yr_id);

create index on ofec_election_result_mv_tmp (election_yr);
create index on ofec_election_result_mv_tmp (cand_office);
create index on ofec_election_result_mv_tmp (cand_office_st);
create index on ofec_election_result_mv_tmp (cand_office_district);
