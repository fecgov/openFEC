drop materialized view if exists ofec_candidate_detail_mv_tmp;
create materialized view ofec_candidate_detail_mv_tmp as
select
    row_number() over () as idx,
    dimcand.cand_sk as candidate_key,
    dimcand.cand_id as candidate_id,
    max(csi_recent.cand_status) as candidate_status,
    case max(csi_recent.cand_status)
        when 'C' then 'Candidate'
        when 'F' then 'Future candidate'
        when 'N' then 'Not yet a candidate'
        when 'P' then 'Prior candidate'
        else 'Unknown' end as candidate_status_full,
    max(co.cand_election_yr) as active_through,
    array_agg(distinct co.cand_election_yr)::int[] as election_years,
    max(csi_recent.cand_inactive_flg) as candidate_inactive,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(dimoffice.office_district) as district,
    max(cand_p_most_recent.cand_nm) as name,
    max(cand_p_most_recent.cand_st) as address_state,
    max(cand_p_most_recent.load_date) as load_date,
    max(cand_p_most_recent.cand_city) as address_city,
    max(cand_p_most_recent.cand_st1) as address_street_1,
    max(cand_p_most_recent.cand_st2) as address_street_2,
    max(cand_p_most_recent.cand_zip) as address_zip,
    max(cand_p_most_recent.cand_ici_desc) as incumbent_challenge_full,
    max(cand_p_most_recent.cand_ici_cd) as incumbent_challenge,
    -- I needed help keeping track of where the information is coming from when we have the information to get the forms linked we can link to the forms for each section.
    -- I would like to replace this information with just links to the form and expire dates
    max(dimcand.form_tp) as form_type,
    max(dimcand.expire_date) as candidate_expire_date,
    max(cand_p_most_recent.expire_date) as properties_expire_date,
    max(cand_p_most_recent.form_tp) as properties_form_type,
    max(csi_recent.expire_date) as status_expire_date,
    max(dimoffice.expire_date) as office_expire_date,
    max(dimparty.expire_date) as party_expire_date
from dimcand
    left join (
        select distinct on (cand_sk, cand_id)
            s.cand_sk, c.cand_id, s.election_yr, s.cand_status, s.ici_code, s.cand_inactive_flg, s.expire_date
        from dimcandstatusici s
            inner join dimcand c using (cand_sk)
        order by cand_sk, cand_id, election_yr desc
    ) csi_recent using (cand_sk, cand_id)
    left join (
        select distinct on (cand_sk) * from dimcandproperties
            order by cand_sk, candproperties_sk desc
    ) cand_p_most_recent using(cand_sk, cand_id)
    left join dimcandoffice co on co.cand_sk = dimcand.cand_sk
    left join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
group by
    dimcand.cand_sk,
    dimcand.cand_id
;

create unique index on ofec_candidate_detail_mv_tmp(idx);

create index on ofec_candidate_detail_mv_tmp(name);
create index on ofec_candidate_detail_mv_tmp(party);
create index on ofec_candidate_detail_mv_tmp(state);
create index on ofec_candidate_detail_mv_tmp(office);
create index on ofec_candidate_detail_mv_tmp(district);
create index on ofec_candidate_detail_mv_tmp(load_date);
create index on ofec_candidate_detail_mv_tmp(candidate_id);
create index on ofec_candidate_detail_mv_tmp(candidate_key);
create index on ofec_candidate_detail_mv_tmp(election_years);
create index on ofec_candidate_detail_mv_tmp(candidate_status);
create index on ofec_candidate_detail_mv_tmp(incumbent_challenge);
create index on ofec_candidate_detail_mv_tmp(candidate_expire_date);
