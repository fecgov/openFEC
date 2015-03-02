drop view if exists ofec_candidates_vw;
create view ofec_candidates_vw as
select
    max(dimcand.cand_sk) as candidate_key,
    max(dimcand.cand_id) as candidate_id,
    max(csi_recent.cand_status) as candidate_status,
    case max(csi_recent.cand_status)
        when 'C' then 'Candidate'
        when 'F' then 'Future candidate'
        when 'N' then 'Not yet a candidate'
        when 'P' then 'Prior candidate'
        else 'Unknown' end as candidate_status_full,
    max(csi_recent.election_yr) as active_through,
    array_agg(distinct csi_all.election_yr)::int[] as election_years,
    max(csi_recent.ici_code) as incumbent_challenge,
    case max(csi_recent.ici_code)
        when 'I' then 'Incumbent'
        when 'C' then 'Challenger'
        when 'O' then 'Open seat'
        else 'Unknown' end as incumbent_challenge_full,
    max(csi_recent.cand_inactive_flg) as candidate_inactive,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(dimoffice.office_district) as district,
    max(cp_most_recent.cand_nm) as name,
    max(cp_most_recent.expire_date) as expire_date,
    max(cp_most_recent.load_date) as load_date,
    max(cp_most_recent.form_tp) as form_type,
    max(cp_most_recent.cand_city) as address_city,
    max(cp_most_recent.cand_st)  as address_state,
    max(cp_most_recent.cand_st1) as address_street_1,
    max(cp_most_recent.cand_zip) as address_zip

from dimcand
    left join (
        select distinct on (cand_sk) cand_sk, election_yr, cand_status, ici_code, cand_inactive_flg from dimcandstatusici order by cand_sk, election_yr desc
    ) csi_recent using (cand_sk)
    left join dimcandstatusici csi_all using (cand_sk)
    left join dimcandoffice co on co.cand_sk = dimcand.cand_sk and (csi_recent.election_yr is null or co.cand_election_yr = csi_recent.election_yr)  -- only joined to get to dimoffice
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
    left join (
        select distinct on (cand_sk) cand_sk, cand_nm, expire_date, load_date, form_tp, cand_city, cand_st1, cand_st, cand_zip, cand_status_cd, cand_status_desc from dimcandproperties order by cand_sk desc
    ) cp_most_recent on cp_most_recent.cand_sk = cp_most_recent.cand_sk
group by
    dimcand.cand_sk,
    dimcand.cand_id,
    csi_recent.election_yr
;
