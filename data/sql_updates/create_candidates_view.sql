drop view if exists ofec_candidates_vw;
drop materialized view if exists ofec_candidates_mv_tmp;
create materialized view ofec_candidates_mv_tmp as
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
    max(dimoffice.office_district) as district,
    csi_recent.election_yr as active_through,
    array_agg(distinct csi_all.election_yr)::int[] as election_years,
    max(csi_recent.ici_code) as incumbent_challenge,
    case max(csi_recent.ici_code)
        when 'I' then 'Incumbent'
        when 'C' then 'Challenger'
        when 'O' then 'Open seat'
        else 'Unknown' end as incumbent_challenge_full,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(candprops.cand_nm) as name
from dimcand
    left join (select distinct on (cand_sk) cand_sk, election_yr, cand_status, ici_code from dimcandstatusici order by cand_sk, election_yr desc) csi_recent using (cand_sk)
    left join dimcandstatusici csi_all using (cand_sk)
    inner join dimcandoffice co on co.cand_sk = dimcand.cand_sk and (csi_recent.election_yr is null or co.cand_election_yr = csi_recent.election_yr)  -- only joined to get to dimoffice
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
    left join (
        select distinct on (cand_sk) cand_sk, cand_nm from dimcandproperties
            order by cand_sk, candproperties_sk desc
    ) candprops on dimcand.cand_sk = candprops.cand_sk
group by
    dimcand.cand_sk,
    dimcand.cand_id,
    csi_recent.election_yr
;

create index on ofec_candidates_mv_tmp(name);
create index on ofec_candidates_mv_tmp(party);
create index on ofec_candidates_mv_tmp(state);
create index on ofec_candidates_mv_tmp(office);
create index on ofec_candidates_mv_tmp(district);
create index on ofec_candidates_mv_tmp(candidate_id);
create index on ofec_candidates_mv_tmp(election_years);
create index on ofec_candidates_mv_tmp(candidate_status);
create index on ofec_candidates_mv_tmp(incumbent_challenge);
