-- Creates a table of 2-year periods
-- drop table if exists two_year_period;
-- create table two_year_period as
-- select year from dimyears
--     where (year <= EXTRACT(YEAR FROM now()) +1)
--     and year % 2 = 0;

--  Full history of a candidate selecting the most recent record for each 2-year period
drop materialized view if exists ofec_candidate_history_vw;
create materialized view ofec_candidate_history_vw as
select
    dcp_recent.candproperties_sk as properties_key,
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    dcs.election_yr as election_year,
    max(dcs.cand_inactive_flg) as candidate_inactive,
    max(do.office_tp) as office,
    max(do.office_tp_desc) as office_full,
    max(dp.party_affiliation) as party,
    max(dp.party_affiliation_desc) as party_full,
    max(do.office_state) as state,
    max(do.office_district) as district,
    dcp_recent.cand_nm as name,
    dcp_recent.cand_st as address_state,
    dcp_recent.expire_date as expire_date,
    dcp_recent.load_date as load_date,
    dcp_recent.cand_city as address_city,
    dcp_recent.cand_st1 as address_street_1,
    dcp_recent.cand_st2 as address_street_2,
    dcp_recent.cand_st2 as address_street,
    dcp_recent.cand_zip as address_zip,
    dcp_recent.cand_ici_desc as incumbent_challenge_full,
    dcp_recent.cand_ici_cd as incumbent_challenge,
    dcp_recent.cand_status_cd as candidate_status,
    dcp_recent.cand_status_desc as candidate_status_full,
    dcp_recent.form_tp as form_type
-- using the two year period table to translate the data into two year periods
    select two_year_period.year
    from (select distinct on (election_yr, cand_id), dcp.candproperties_sk, dcp.cand_nm, dcp.cand_st, dcp.expire_date, dcp.load_date, dcp.cand_city, dcp.cand_st1, dcp.cand_st2, dcp.cand_zip, dcp.cand_ici_desc, dcp.cand_ici_cd, dcp.cand_status_cd, dcp.cand_status_desc  from dimcandproperties dcp
        -- Looking for all records that were turned in before the end of the cycle and
        -- don't expire before the cycle begins to link records to a 2-year period.
        -- The beginning of the period starts one year before the cycle
        where two_year_period.year >= EXTRACT(YEAR FROM load_date) - 1 and expire_date is null or two_year_period.year <= EXTRACT(YEAR FROM expire_date)
        from two_year_period
        -- ordering so that the we just return the most recent record
        order by (dcp.load_date, dcp.election_year, dcp.load_date) desc
    ) as dcp_recent
    from dcp_recent
        left join dimcand using (cand_sk)
        left join dimcandstatusici dcs using (cand_sk)
        left join dimcandoffice dco using (cand_sk)
        inner join dimoffice do using (office_sk)
        inner join dimparty dp using (party_sk)
group by
    dcp_recent.candproperties_sk,
    dcp_recent.cand_nm,
    dcp_recent.cand_st,
    dcp_recent.expire_date,
    dcp_recent.load_date,
    dcp_recent.cand_city,
    dcp_recent.cand_st1,
    dcp_recent.cand_st2,
    dcp_recent.cand_zip,
    dcp_recent.cand_ici_desc,
    dcp_recent.cand_ici_cd,
    dcp_recent.cand_status_cd,
    dcp_recent.cand_status_desc,
    dcs.election_yr,
    dimcand.cand_sk,
    dimcand.cand_id,
    dcp_recent.form_tp
;