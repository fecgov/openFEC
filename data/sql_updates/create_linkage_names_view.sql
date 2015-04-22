drop materialized view if exists ofec_name_linkage_mv_tmp;
create materialized view ofec_name_linkage_mv_tmp as
select
    row_number() over () as idx,
    l.linkages_sk as linkage_key,
    l.cand_sk as candidate_key,
    l.cmte_sk as committee_key,
    l.cand_id as candidate_id,
    (select max(cand_election_yr) from dimlinkages dl where dl.cand_id = l.cand_id) as active_through,
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
    (select cand_nm from dimcandproperties where dimcandproperties.cand_sk = l.cand_sk order by candproperties_sk desc limit 1) as candidate_name,
    (select cmte_nm from dimcmteproperties where dimcmteproperties.cmte_sk = l.cmte_sk order by cmteproperties_sk desc limit 1) as committee_name
from dimlinkages l;

create unique index on ofec_name_linkage_mv_tmp(idx);

create index on ofec_name_linkage_mv_tmp(candidate_key);
create index on ofec_name_linkage_mv_tmp(committee_key);
