drop materialized view if exists ofec_name_linkage_mv_tmp;
create materialized view ofec_name_linkage_mv_tmp as
select
    l.linkages_sk as linkage_key,
    l.cand_sk as candidate_key,
    l.cmte_sk as committee_key,
    l.cand_id as candidate_id,
    active.active_through,
    l.cand_election_yr as election_year,
    l.cmte_id as committee_id,
    l.cmte_tp as committee_type,
    case l.cmte_tp
        when 'P' then 'Presidential'
        when 'H' then 'House'
        when 'S' then 'Senate'
        when 'C' then 'Communication Cost'
        when 'D' then 'Delegate Committee'
        when 'E' then 'Electioneering Communication'
        when 'I' then 'Independent Expenditor (Person or Group)'
        when 'N' then 'PAC - Nonqualified'
        when 'O' then 'Independent Expenditure-Only (Super PACs)'
        when 'Q' then 'PAC - Qualified'
        when 'U' then 'Single Candidate Independent Expenditure'
        when 'V' then 'PAC with Non-Contribution Account - Nonqualified'
        when 'W' then 'PAC with Non-Contribution Account - Qualified'
        when 'X' then 'Party - Nonqualified'
        when 'Y' then 'Party - Qualified'
        when 'Z' then 'National Party Nonfederal Account'
        else 'unknown' end as committee_type_full,
    l.cmte_dsgn as committee_designation,
    case l.cmte_dsgn
        when 'A' then 'Authorized by a candidate'
        when 'J' then 'Joint fundraising committee'
        when 'P' then 'Principal campaign committee'
        when 'U' then 'Unauthorized'
        when 'B' then 'Lobbyist/Registrant PAC'
        when 'D' then 'Leadership PAC'
        else 'unknown' end as committee_designation_full,
    l.link_date as link_date,
    l.load_date as load_date,
    l.expire_date as expire_date,
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
;

create index on ofec_name_linkage_mv_tmp(candidate_key);
create index on ofec_name_linkage_mv_tmp(committee_key);
