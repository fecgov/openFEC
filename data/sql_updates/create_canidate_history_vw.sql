drop materialized view if exists ofec_candidate_history_vw;
create materialized view ofec_candidate_history_vw as
select
    dimcandproperties.candproperties_sk as properties_key,
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    max(dimcandstatusici.election_yr) as active_through,
    array_agg(distinct dimcandstatusici.election_yr)::int[] as election_years,
    max(dimcandstatusici.cand_inactive_flg) as candidate_inactive,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(dimoffice.office_district) as district,
    dimcandproperties.cand_nm as name,
    dimcandproperties.cand_st as address_state,
    dimcandproperties.expire_date as expire_date,
    dimcandproperties.load_date as load_date,
    dimcandproperties.cand_city as address_city,
    dimcandproperties.cand_st1 as address_street_1,
    dimcandproperties.cand_st2 as address_street_2,
    dimcandproperties.cand_st2 as address_street,
    dimcandproperties.cand_zip as address_zip,
    dimcandproperties.cand_ici_desc as incumbent_challenge_full,
    dimcandproperties.cand_ici_cd as incumbent_challenge,
    dimcandproperties.cand_status_cd as candidate_status,
    dimcandproperties.cand_status_desc as candidate_status_full,
    dimcandproperties.form_tp as form_type
from dimcandproperties
    left join dimcand using (cand_sk)
    left join dimcandstatusici using (cand_sk)
    left join dimcandoffice co using (cand_sk)
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
    left join dimcandstatusici csi_recent using (cand_sk)
group by
    dimcandproperties.candproperties_sk,
    dimcandproperties.cand_nm,
    dimcandproperties.cand_st,
    dimcandproperties.expire_date,
    dimcandproperties.load_date,
    dimcandproperties.cand_city,
    dimcandproperties.cand_st1,
    dimcandproperties.cand_st2,
    dimcandproperties.cand_zip,
    dimcandproperties.cand_ici_desc,
    dimcandproperties.cand_ici_cd,
    dimcandproperties.cand_status_cd,
    dimcandproperties.cand_status_desc,
    dimcand.cand_sk,
    dimcand.cand_id,
    dimcandproperties.form_tp
;

