drop view if exists ofec_candidates_vw;
drop materialized view if exists ofec_candidates_mv_tmp;
create materialized view ofec_candidates_mv_tmp as
select
    row_number() over () as idx,
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    max(csi_recent.cand_status) as candidate_status,
    expand_candidate_status(max(csi_recent.cand_status)) as candidate_status_full,
    max(dimoffice.office_district) as district,
    max(co.cand_election_yr) as active_through,
    array_agg(distinct co.cand_election_yr)::int[] as election_years,
    array_agg(distinct(dcp.election_yr + dcp.election_yr % 2))::int[] as cycles,
    max(full_ici.cand_ici_cd) as incumbent_challenge,
    expand_candidate_incumbent(max(full_ici.cand_ici_cd)) as incumbent_challenge_full,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    clean_party(max(dimparty.party_affiliation_desc)) as party_full,
    max(dimoffice.office_state) as state,
    max(candprops.cand_nm) as name
from dimcand
    -- Restrict to candidates with at least one non-F2Z filing
    inner join (
        select distinct cand_sk
        from dimcandproperties
        where form_tp != 'F2Z'
    ) f2 using (cand_sk)
    left join (
        select distinct on (cand_sk) cand_sk, election_yr, cand_status, ici_code
            from dimcandstatusici
            order by cand_sk, election_yr desc
    ) csi_recent using (cand_sk)
    -- there are some holes in this data so we want the last time it was updated
    left join(
        select distinct on (cand_sk)
            cp.cand_sk, cp.cand_ici_desc, cp.cand_ici_cd
        from dimcandproperties cp
        where cand_ici_desc is not null
        order by cand_sk, cand_id, election_yr desc
    ) full_ici using (cand_sk)
    left join dimcandoffice co using (cand_sk)
    left join (
        select distinct on (cand_sk) * from dimcandoffice order by cand_sk, candoffice_sk desc
    ) last_co using (cand_sk)
    inner join dimoffice on last_co.office_sk = dimoffice.office_sk
    inner join dimparty on last_co.party_sk = dimparty.party_sk
    left join (
        select distinct on (cand_sk) cand_sk, cand_nm from dimcandproperties
            order by cand_sk, candproperties_sk desc
    ) candprops using (cand_sk)
    left join dimcandproperties dcp using (cand_sk)
    where dcp.election_yr >= :START_YEAR
group by
    dimcand.cand_sk,
    dimcand.cand_id
-- Candidate must have > 0 records after START_YEAR
having count(dcp) > 0
;

create unique index on ofec_candidates_mv_tmp(idx);

create index on ofec_candidates_mv_tmp(name);
create index on ofec_candidates_mv_tmp(party);
create index on ofec_candidates_mv_tmp(state);
create index on ofec_candidates_mv_tmp(office);
create index on ofec_candidates_mv_tmp(district);
create index on ofec_candidates_mv_tmp(candidate_id);
create index on ofec_candidates_mv_tmp(candidate_key);
create index on ofec_candidates_mv_tmp(candidate_status);
create index on ofec_candidates_mv_tmp(incumbent_challenge);

create index on ofec_candidates_mv_tmp using gin (cycles);
create index on ofec_candidates_mv_tmp using gin (election_years);
