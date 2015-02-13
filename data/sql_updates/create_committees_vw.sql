drop view if exists ofec_committees_vw;
create view ofec_committees_vw as
select distinct
    dimcmte.cmte_sk as committee_key,
    dimcmte.cmte_id as committee_id,
    dd.cmte_dsgn as designation_short,
    case dd.cmte_dsgn
        when 'A' then 'Authorized by a candidate'
        when 'J' then 'Joint fundraising committee'
        when 'P' then 'Principal campaign committee'
        when 'U' then 'Unauthorized'
        when 'B' then 'Lobbyist/Registrant PAC'
        when 'D' then 'Leadership PAC'
        else 'unknown' end as designation,
    dd.cmte_tp as committee_type_short,
    case dd.cmte_tp
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
        else 'unknown' end as committee_type,
    cp.cmte_treasurer_nm as treasurer_name,
    cp.org_tp as organization_type_short,
    cp.org_tp_desc as organization_type,
    cp.cmte_st as state,
    cp.expire_date as expire_date,
    cp.cand_pty_affiliation as party_short,
    p.party_affiliation_desc as party,
    -- they should give this to us but I am querying around it for now
    (select load_date from dimcmteproperties cp where cp.cmte_sk = dimcmte.cmte_sk order by load_date desc limit 1) as original_registration_date,
    (select cmte_nm from dimcmteproperties cp where cp.cmte_sk = dimcmte.cmte_sk order by cmteproperties_sk desc limit 1) as name
    -- (select all cand_id from dimlinkages dl where dl.cmte_sk = dimcmte.cmte_sk) as candidate_ids
from dimcmte
    inner join dimcmtetpdsgn dd using (cmte_sk)
    inner join dimcmteproperties cp using (cmte_sk)
    inner join dimparty p on cp.cand_pty_affiliation = p.party_affiliation
    -- inner join dimlinkages dl using (cmte_sk)
;
grant select on table ofec_committees_vw to webro;