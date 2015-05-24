drop materialized view if exists ofec_committee_history_mv_tmp;
create materialized view ofec_committee_history_mv_tmp as
select distinct on (cmte_sk, cycle)
    row_number() over () as idx,
    dcp.rpt_yr + dcp.rpt_yr % 2 as cycle,
    dcp.cmte_sk as committee_key,
    dcp.cmte_id as committee_id,
    dcp.cmte_nm as name,
    dcp.cmte_treasurer_nm as treasurer_name,
    dcp.org_tp as organization_type,
    expand_organization_type(dcp.org_tp) as organization_type_full,
    dcp.cand_pty_affiliation as party,
    dcp.cmte_st as state,
    dcp.expire_date as expire_date,
    dd.cmte_dsgn as designation,
    expand_committee_designation(dd.cmte_dsgn) as designation_full,
    dd.cmte_tp as committee_type,
    expand_committee_type(dd.cmte_tp) as committee_type_full,
    clean_party(p.party_affiliation_desc) as party_full,
    agg.cycles as cycles
from dimcmteproperties dcp
inner join dimcmtetpdsgn dd using (cmte_sk)
left join dimparty p on dcp.cand_pty_affiliation = p.party_affiliation
left join (
    select
        cmte_sk,
        array_agg(distinct(rpt_yr + rpt_yr % 2)) as cycles
    from dimcmteproperties
    group by cmte_sk
) agg using (cmte_sk)
where dd.receipt_date <= dcp.receipt_dt
and dcp.rpt_yr >= :START_YEAR
order by cmte_sk, cycle desc, dd.receipt_date desc
;

create unique index on ofec_committee_history_mv_tmp(idx);

create index on ofec_committee_history_mv_tmp(cycle);
create index on ofec_committee_history_mv_tmp(committee_id);
create index on ofec_committee_history_mv_tmp(committee_key);
