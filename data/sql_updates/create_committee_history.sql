drop materialized view if exists ofec_committee_history_mv_tmp;
create materialized view ofec_committee_history_mv_tmp as
select
    row_number() over () as idx,
    dc.cmte_sk as committee_key,
    dc.cmte_id as committee_id,
    dcp.cmte_nm as name,
    dd.cmte_dsgn as designation,
    case dd.cmte_dsgn
        when 'A' then 'Authorized by a candidate'
        when 'J' then 'Joint fundraising committee'
        when 'P' then 'Principal campaign committee'
        when 'U' then 'Unauthorized'
        when 'B' then 'Lobbyist/Registrant PAC'
        when 'D' then 'Leadership PAC'
        else 'unknown'
    end as designation_full,
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
        else 'unknown'
    end as committee_type_full,
    dcp.cmte_treasurer_nm as treasurer_name,
    dcp.org_tp as organization_type,
    -- Columns org_tp and org_tp_desc may be inconsistent; trust org_tp
    case dcp.org_tp
        when 'C' then 'Corporation'
        when 'L' then 'Labor Organization'
        when 'M' then 'Membership Organization'
        when 'T' then 'Trade Association'
        when 'V' then 'Cooperative'
        when 'W' then 'Corporation w/o capital stock'
        else null
    end as organization_type_full,
    dcp.cand_pty_affiliation as party,
    dcp.cmte_st as state,
    dcp.expire_date as expire_date,
    regexp_replace(p.party_affiliation_desc, '\s*(Added|Removed|\(.*?)\)$', '') as party_full,
    pd.year as cycle
from dimcmte dc
left join (
    select distinct on (cmte_sk) * from dimcmtetpdsgn
        order by cmte_sk, receipt_date desc
) dd using (cmte_sk)
left join (
    select distinct on (cmte_sk) * from dimcmteproperties
        order by cmte_sk, receipt_dt desc
) dcp using (cmte_sk)
left join dimparty p on dcp.cand_pty_affiliation = p.party_affiliation
inner join ofec_two_year_periods pd on (dcp.rpt_yr + dcp.rpt_yr % 2) = pd.year
;

create unique index on ofec_candidate_history_mv_tmp(idx);
