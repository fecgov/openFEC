drop view if exists ofec_candidates_vw;
create view ofec_candidates_vw as
select distinct
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    csi.cand_status as candidate_status_short,
    case csi.cand_status
        when 'C' then 'candidate'
        when 'F' then 'future candidate'
        when 'N' then 'not yet a candidate'
        when 'P' then 'prior candidate'
        else 'unknown' end as candidate_status,
    dimoffice.office_district as district,
    co.cand_election_yr as election_year,
    csi.ici_code as incumbent_challenge_short,
    case csi.ici_code 
        when 'I' then 'incumbent'
        when 'C' then 'challenger'
        when 'O' then 'open seat'
        else 'unknown' end as incumbent_challenge,
    dimoffice.office_tp as office_short,
    dimoffice.office_tp_desc as office,
    dimparty.party_affiliation as party_short,
    dimparty.party_affiliation_desc as party,
    dimoffice.office_state as state,
    (select cand_nm from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as name
from dimcand
    inner join dimcandstatusici csi using (cand_sk)
    inner join dimcandoffice co on co.cand_sk = csi.cand_sk and co.cand_election_yr = csi.election_yr
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
;
grant select on table ofec_candidates_vw to webro;
