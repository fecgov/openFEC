-- Creates a table of 2-year periods
drop materialized view if exists ofec_candidate_history_mv;
drop table if exists two_year_periods;
create table two_year_periods as
select year from dimyears
    where (year <= EXTRACT(YEAR FROM now()) +1)
    and year % 2 = 0;

--  Full history of a candidate selecting the most recent record for each 2-year period
drop materialized view if exists ofec_candidate_history_mv;
create materialized view ofec_candidate_history_mv as
select
    dcp_recent.candproperties_sk as properties_key,
    dcp_recent.cand_sk as candidate_key,
    dcp_recent.cand_id as candidate_id,
    dcp_recent.cand_nm as name,
    dcp_recent.record_expire_date as expire_date,
    dcp_recent.record_load_date as load_date,
    dcp_recent.record_form_tp as form_type,
    dcp_recent.two_year_period as two_year_period,
    dcp_recent.cand_st as address_state,
    dcp_recent.cand_city as address_city,
    dcp_recent.cand_st1 as address_street_1,
    dcp_recent.cand_st2 as address_street_2,
    dcp_recent.cand_st2 as address_street,
    dcp_recent.cand_zip as address_zip,
    dcp_recent.cand_ici_desc as incumbent_challenge_full,
    dcp_recent.cand_ici_cd as incumbent_challenge,
    dcp_recent.cand_status_cd as candidate_status,
    dcp_recent.cand_status_desc as candidate_status_full,
    dcp_recent.cand_inactive_flg as candidate_inactive,
    dcp_recent.office_tp as office,
    dcp_recent.office_tp_desc as office_full,
    dcp_recent.office_state as state,
    dcp_recent.office_district as district,
    dcp_recent.party_affiliation as party,
    dcp_recent.party_affiliation_desc as party_full
from two_year_periods
    left join (
        select distinct on (two_year_period, cand_sk) ((CAST(EXTRACT(YEAR FROM dcp.load_date) AS INT) + CAST(EXTRACT(YEAR FROM dcp.load_date) AS INT) % 2)) as two_year_period, dcp.expire_date as record_expire_date, dcp.load_date as record_load_date, dcp.form_tp as record_form_tp, *
        from dimcandproperties dcp
            left join dimcand dc using (cand_sk)
            left join dimcandstatusici dsi using (cand_sk)
            left join dimcandoffice co using (cand_sk)
            inner join dimoffice using (office_sk)
            inner join dimparty using (party_sk)
        order by cand_sk, two_year_period, dcp.load_date desc
    ) as dcp_recent on two_year_periods.year = two_year_period
;

create index on ofec_candidate_history_mv(candidate_key);
create index on ofec_candidate_history_mv(candidate_id);
create index on ofec_candidate_history_mv(two_year_period);