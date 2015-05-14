drop materialized view if exists ofec_candidate_history_mv_tmp;
create materialized view ofec_candidate_history_mv_tmp as
select
    row_number() over () as idx,
    dcp_by_period.candproperties_sk as properties_key,
    dcp_by_period.cand_sk as candidate_key,
    dcp_by_period.record_cand_id as candidate_id,
    dcp_by_period.cand_nm as name,
    dcp_by_period.record_expire_date as expire_date,
    dcp_by_period.record_load_date as load_date,
    dcp_by_period.record_form_tp as form_type,
    dcp_by_period.two_year_period as two_year_period,
    dcp_by_period.cand_st as address_state,
    dcp_by_period.cand_city as address_city,
    dcp_by_period.cand_st1 as address_street_1,
    dcp_by_period.cand_st2 as address_street_2,
    dcp_by_period.cand_st2 as address_street,
    dcp_by_period.cand_zip as address_zip,
    dcp_by_period.cand_ici_desc as incumbent_challenge_full,
    dcp_by_period.cand_ici_cd as incumbent_challenge,
    dcp_by_period.cand_status_cd as candidate_status,
    dcp_by_period.cand_status_desc as candidate_status_full,
    dcp_by_period.cand_inactive_flg as candidate_inactive,
    dcp_by_period.office_tp as office,
    dcp_by_period.office_tp_desc as office_full,
    dcp_by_period.office_state as state,
    dcp_by_period.office_district as district,
    dcp_by_period.party_affiliation as party,
    -- Handle typos and notes in party description:
    -- * "Commandments Party (Removed)" becomes "Commandments Party"
    -- * "Green Party Added)" becomes "Green Party"
    regexp_replace(dcp_by_period.party_affiliation_desc, '\s*(Added|Removed|\(.*?)\)$', '') as party_full
from ofec_two_year_periods
    left join (
        select distinct on (two_year_period, cand_sk)
            dcp.election_yr + dcp.election_yr % 2 as two_year_period,
            dcp.expire_date as record_expire_date,
            dcp.load_date as record_load_date,
            dcp.form_tp as record_form_tp,
            dcp.cand_id as record_cand_id,
            *
        from dimcandproperties dcp
            left join dimcand dc using (cand_sk)
            left join dimcandstatusici dsi using (cand_sk)
            left join dimcandoffice co using (cand_sk)
            inner join dimoffice using (office_sk)
            inner join dimparty using (party_sk)
        order by cand_sk, two_year_period, dcp.candproperties_sk desc
    ) as dcp_by_period on ofec_two_year_periods.year = two_year_period
    where two_year_period >= :START_YEAR
;

create unique index on ofec_candidate_history_mv_tmp(idx);

create index on ofec_candidate_history_mv_tmp(candidate_key);
create index on ofec_candidate_history_mv_tmp(candidate_id);
create index on ofec_candidate_history_mv_tmp(two_year_period);
