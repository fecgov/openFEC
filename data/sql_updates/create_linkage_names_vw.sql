drop view if exists name_linkage_vw; -- the old name-- this line can be removed in the future
drop view if exists ofec_name_linkage_vw;
create view ofec_name_linkage_vw as
select
    dimlinkages.linkages_sk as linkage_key,
    dimlinkages.cand_sk as candidate_key,
    dimlinkages.cmte_sk as committee_key,
    dimlinkages.cand_id as candidate_id,
    dimlinkages.cand_election_yr as active_through,
    dimlinkages.cmte_id as committee_id,
    dimlinkages.cmte_tp as committee_type,
    case dimlinkages.cmte_tp
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
    dimlinkages.cmte_dsgn as committee_designation,
    case dimlinkages.cmte_dsgn
        when 'A' then 'Authorized by a candidate'
        when 'J' then 'Joint fundraising committee'
        when 'P' then 'Principal campaign committee'
        when 'U' then 'Unauthorized'
        when 'B' then 'Lobbyist/Registrant PAC'
        when 'D' then 'Leadership PAC'
        else 'unknown' end as committee_designation_full,
    dimlinkages.link_date as link_date,
    dimlinkages.load_date as load_date,
    dimlinkages.expire_date as expire_date,
    (select cand_nm from dimcandproperties where dimcandproperties.cand_sk = dimlinkages.cand_sk order by candproperties_sk desc limit 1) as candidate_name,
    (select cmte_nm from dimcmteproperties where dimcmteproperties.cmte_sk = dimlinkages.cmte_sk order by cmteproperties_sk desc limit 1) as committee_name
from dimlinkages;
