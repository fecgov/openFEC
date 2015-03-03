drop view if exists ofec_candidate_detail_vw;
create view ofec_candidate_detail_vw as
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
    max(csi_recent.cand_inactive_flg) as candidate_inactive,
    max(dimoffice.office_tp) as office,
    max(dimoffice.office_tp_desc) as office_full,
    max(dimparty.party_affiliation) as party,
    max(dimparty.party_affiliation_desc) as party_full,
    max(dimoffice.office_state) as state,
    max(dimoffice.office_district) as district,
    -- This seems like an awful way to do this but the left join was not giving the right data
    (select cand_nm from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as name,
    (select cand_st from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as address_state,
    (select expire_date from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as expire_date,
    (select load_date from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as load_date,
    (select cand_city from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as address_city,
    (select cand_st1 from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as address_street_1,
    (select cand_st2 from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as address_street_2,
    (select cand_zip from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as address_zip,
    (select cand_ici_desc from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as incumbent_challenge_full,
    (select cand_ici_cd from dimcandproperties cp where cp.cand_sk = dimcand.cand_sk order by candproperties_sk desc limit 1) as incumbent_challenge,

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
    dimcand.cand_sk
;
