drop materialized view if exists ofec_candidate_detail_vw;
create materialized view ofec_candidate_detail_vw as
select
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    max(csi_recent.cand_status) as candidate_status,
    case max(csi_recent.cand_status)
        when 'C' then 'Candidate'
        when 'F' then 'Future candidate'
        when 'N' then 'Not yet a candidate'
        when 'P' then 'Prior candidate'
        else 'Unknown' end as candidate_status_full,
    max(csi_recent.election_yr) as active_through,
    array_agg(distinct csi_all.election_yr)::int[] as election_years,
    max(csi_recent.cand_inactive_flg) as candidate_inactive,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(dimoffice.office_district) as district,
    -- This seems like an awful way to do this but the left join was not giving the right data
    cand_p_most_recent.cand_nm as name,
    cand_p_most_recent.cand_st  as address_state,
    cand_p_most_recent.expire_date as expire_date,
    cand_p_most_recent.load_date as load_date,
    cand_p_most_recent.cand_city as address_city,
    cand_p_most_recent.cand_st1 as address_street_1,
    cand_p_most_recent.cand_st2 as address_street_2,
    cand_p_most_recent.cand_zip as address_zip,
    cand_p_most_recent.cand_ici_desc as incumbent_challenge_full,
    cand_p_most_recent.cand_ici_cd as incumbent_challenge,
    max(dimcand.form_tp) as form_type
from dimcand
    left join (
        select distinct on (cand_sk) cand_sk, election_yr, cand_status, ici_code, cand_inactive_flg, expire_date from dimcandstatusici order by cand_sk, election_yr desc
    ) csi_recent using (cand_sk)
    left join dimcandstatusici csi_all using (cand_sk)
    left join dimcandoffice co on co.cand_sk = dimcand.cand_sk and (csi_recent.election_yr is null or co.cand_election_yr = csi_recent.election_yr)  -- only joined to get to dimoffice
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
    left join (
        select distinct on (cand_sk) * from dimcandproperties order by cand_sk desc limit 1
    ) cand_p_most_recent on cand_p_most_recent.cand_sk = cand_p_most_recent.cand_sk
group by
    dimcand.cand_sk,
    dimcand.cand_id,
    cand_p_most_recent.cand_nm,
    cand_p_most_recent.cand_st,
    cand_p_most_recent.expire_date,
    cand_p_most_recent.load_date,
    cand_p_most_recent.cand_city,
    cand_p_most_recent.cand_st1,
    cand_p_most_recent.cand_st2,
    cand_p_most_recent.cand_zip,
    cand_p_most_recent.cand_ici_desc,
    cand_p_most_recent.cand_ici_cd
;
