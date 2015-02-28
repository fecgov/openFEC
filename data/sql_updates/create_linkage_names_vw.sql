drop view if exists name_linkage_vw;
create view name_linkage_vw as
select
    dimlinkages.linkages_sk as linkage_key,
    dimlinkages.cand_sk as candidate_key,
    dimlinkages.cmte_sk as committee_key,
    dimlinkages.cand_id as candidate_id,
    dimlinkages.cand_election_yr as active_through,
    dimlinkages.cmte_id as committee_id,
    dimlinkages.cmte_tp as committee_type,
    dimlinkages.cmte_dsgn as committee_designation,
    dimlinkages.link_date as link_date,
    dimlinkages.load_date as load_date,
    dimlinkages.expire_date as expire_date,
    (select cand_nm from dimcandproperties where dimcandproperties.cand_sk = dimlinkages.cand_sk order by candproperties_sk desc limit 1) as candidate_name,
    (select cmte_nm from dimcmteproperties where dimcmteproperties.cmte_sk = dimlinkages.cmte_sk order by cmteproperties_sk desc limit 1) as committee_name
from dimlinkages;