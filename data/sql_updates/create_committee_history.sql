drop materialized view if exists ofec_committee_history_mv_tmp;
create materialized view ofec_committee_history_mv_tmp as
with
    cycles as (
        select distinct
            cmte_sk,
            rpt_yr + rpt_yr % 2 as cycle
        from (
            select cmte_sk, rpt_yr from factpacsandparties_f3x
            union
            select cmte_sk, rpt_yr from factpresidential_f3p
            union
            select cmte_sk, rpt_yr from facthousesenate_f3
        ) years
    ),
    cycle_agg as (
        select
            cmte_sk,
            array_agg(cycles.cycle)::int[] as cycles
        from cycles
        group by cmte_sk
    )
select distinct on (dcp.cmte_sk, cycle)
    row_number() over () as idx,
    cycles.cycle,
    dcp.cmte_sk as committee_key,
    dcp.cmte_id as committee_id,
    dcp.cmte_nm as name,
    dcp.cmte_treasurer_nm as treasurer_name,
    dcp.org_tp as organization_type,
    expand_organization_type(dcp.org_tp) as organization_type_full,
    dcp.cand_pty_affiliation as party,
    dcp.cmte_st as state,
    dcp.expire_date as expire_date,
    -- Address
    dcp.cmte_st1 as street_1,
    dcp.cmte_st2 as street_2,
    dcp.cmte_city as city,
    dcp.cmte_st_desc as state_full,
    dcp.cmte_zip as zip,
    dd.cmte_dsgn as designation,
    expand_committee_designation(dd.cmte_dsgn) as designation_full,
    dd.cmte_tp as committee_type,
    expand_committee_type(dd.cmte_tp) as committee_type_full,
    clean_party(p.party_affiliation_desc) as party_full,
    cycle_agg.cycles
from dimcmteproperties dcp
inner join dimcmtetpdsgn dd using (cmte_sk)
left join dimparty p on dcp.cand_pty_affiliation = p.party_affiliation
left join cycles on dcp.cmte_sk = cycles.cmte_sk and dcp.rpt_yr <= cycles.cycle
left join cycle_agg on dcp.cmte_sk = cycle_agg.cmte_sk
where dcp.rpt_yr >= :START_YEAR
order by dcp.cmte_sk, cycle desc, dcp.rpt_yr desc, dd.receipt_date desc
;

create unique index on ofec_committee_history_mv_tmp(idx);

create index on ofec_committee_history_mv_tmp(cycle);
create index on ofec_committee_history_mv_tmp(committee_id);
create index on ofec_committee_history_mv_tmp(committee_key);
