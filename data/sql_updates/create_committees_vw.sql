drop view if exists ofec_candidates_vw;
create view ofec_candidates_vw as
select
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    max(csi_recent.cand_status) as candidate_status_short,
    case max(csi_recent.cand_status)
        when 'C' then 'candidate'
        when 'F' then 'future candidate'
        when 'N' then 'not yet a candidate'
        when 'P' then 'prior candidate'
        else 'unknown' end as candidate_status,
    max(dimoffice.office_district) as district,
    csi_recent.election_yr as active_through,
    (select array_agg(distinct election_yr)::int[] from dimcandstatusici csi where csi.cand_sk = dimcand.cand_sk) as election_years,
    max(csi_recent.ici_code) as incumbent_challenge_short,
    case max(csi_recent.ici_code)
        when 'I' then 'incumbent'
        when 'C' then 'challenger'
        when 'O' then 'open seat'
        else 'unknown' end as incumbent_challenge,
    max(dimoffice.office_tp) as office_short,
    max(dimoffice.office_tp_desc) as office,
    max(dimparty.party_affiliation) as party_short,
    max(dimparty.party_affiliation_desc) as party,
    max(dimoffice.office_state) as state,
    (select cand_nm from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as name
from dimcand
    inner join (select distinct on (cand_sk) cand_sk, election_yr, cand_status, ici_code from dimcandstatusici order by cand_sk, election_yr desc) csi_recent using (cand_sk)
    inner join dimcandoffice co on co.cand_sk = dimcand.cand_sk and co.cand_election_yr = csi_recent.election_yr  -- only joined to get to dimoffice
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
group by
    dimcand.cand_sk,
    dimcand.cand_id,
    csi_recent.election_yr
;
grant select on table ofec_candidates_vw to webro;