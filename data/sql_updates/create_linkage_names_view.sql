drop materialized view if exists ofec_name_linkage_mv_tmp;
create materialized view ofec_name_linkage_mv_tmp as
select
    row_number() over () as idx,
    l.linkages_sk as linkage_key,
    l.cand_sk as candidate_key,
    l.cmte_sk as committee_key,
    l.cand_id as candidate_id,
    active.active_through,
    l.cand_election_yr as election_year,
    l.cmte_id as committee_id,
    l.cmte_tp as committee_type,
    l.cmte_dsgn as committee_designation,
    expand_committee_type(l.cmte_tp) as committee_type_full,
    expand_committee_designation(l.cmte_dsgn) as committee_designation_full,
    l.load_date as load_date,
    candprops.cand_nm as candidate_name,
    cmteprops.cmte_nm as committee_name
from dimlinkages l
left join (
    select distinct on (cand_sk) cand_sk, cand_nm from dimcandproperties
        order by cand_sk, candproperties_sk desc
) candprops on l.cand_sk = candprops.cand_sk
left join (
    select distinct on (cmte_sk) cmte_sk, cmte_nm from dimcmteproperties
        order by cmte_sk, cmteproperties_sk desc
) cmteprops on l.cmte_sk = cmteprops.cmte_sk
left join (
    select cand_id, max(dl.cand_election_yr) as active_through from dimlinkages
        join dimlinkages dl using (cand_id)
        group by cand_id
) active on l.cand_id = active.cand_id
where l.cmte_dsgn != 'U'
and l.expire_date is null
and l.cand_election_yr >= :START_YEAR
;

create unique index on ofec_name_linkage_mv_tmp(idx);

create index on ofec_name_linkage_mv_tmp(candidate_key);
create index on ofec_name_linkage_mv_tmp(committee_key);
create index on ofec_name_linkage_mv_tmp(election_year);
