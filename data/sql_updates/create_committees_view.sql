drop view if exists ofec_committees_vw;
drop materialized view if exists ofec_committees_mv;
create materialized view ofec_committees_mv as
select distinct
    dimcmte.cmte_sk as committee_key,
    dimcmte.cmte_id as committee_id,
    dd.cmte_dsgn as designation,
    case dd.cmte_dsgn
        when 'A' then 'Authorized by a candidate'
        when 'J' then 'Joint fundraising committee'
        when 'P' then 'Principal campaign committee'
        when 'U' then 'Unauthorized'
        when 'B' then 'Lobbyist/Registrant PAC'
        when 'D' then 'Leadership PAC'
        else 'unknown' end as designation_full,
    dd.cmte_tp as committee_type,
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
        else 'unknown' end as committee_type_full,
    cp_most_recent.cmte_treasurer_nm as treasurer_name,
    cp_most_recent.org_tp as organization_type,
    cp_most_recent.org_tp_desc as organization_type_full,
    cp_most_recent.cmte_st as state,
    cp_most_recent.expire_date as expire_date,
    cp_most_recent.cand_pty_affiliation as party,
    p.party_affiliation_desc as party_full,
    -- contrary to most recent, we'll need to pull just the oldest load_date here, since they don't give us registration dates yet
    (select distinct on (cmte_sk) load_date from dimcmteproperties cp where cp.cmte_sk = dimcmte.cmte_sk order by cmte_sk, cmteproperties_sk) as original_registration_date,
    cp_most_recent.cmte_nm as name,
    candidates.candidate_ids
from dimcmte
    left join dimcmtetpdsgn dd using (cmte_sk)
    -- do a DISTINCT ON subselect to get the most recent properties for a committee
    left join (
        select distinct on (cmte_sk) cmte_sk, cmte_nm, cmte_treasurer_nm, org_tp, org_tp_desc, cmte_st, expire_date, cand_pty_affiliation from dimcmteproperties order by cmte_sk, cmteproperties_sk desc
    ) cp_most_recent using (cmte_sk)
    left join dimparty p on cp_most_recent.cand_pty_affiliation = p.party_affiliation
    left join (select cmte_sk, array_agg(distinct cand_id)::text[] as candidate_ids from dimlinkages dl group by cmte_sk) candidates on candidates.cmte_sk = dimcmte.cmte_sk
    -- inner join dimlinkages dl using (cmte_sk)
;
