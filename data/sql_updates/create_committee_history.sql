drop materialized view if exists ofec_committee_history_mv_tmp cascade;
create materialized view ofec_committee_history_mv_tmp as
with
    cycles as (
        select
            committee_id,
            generate_series(
                min(get_cycle(report_year)),
                max(get_cycle(report_year)),
                2
            ) as cycle
        from vw_filing_history
        group by committee_id
    ),
    cycle_agg as (
        select
            committee_id,
            array_agg(cycles.cycle)::int[] as cycles,
            max(cycles.cycle) as max_cycle
        from cycles
        group by committee_id
    ),
    filings_original as (
        select committee_id, min(receipt_date) receipt_date from vw_filing_history
        where report_year >= :START_YEAR
        group by committee_id
    ),
    candidate_agg as (
        select
            cmte_sk,
            array_agg(distinct cand_id)::text[] as candidate_ids
        from dimlinkages dl
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
    -- Treasurer
    dcp.cmte_treasurer_city as treasurer_city,
    dcp.cmte_treasurer_f_nm as treasurer_name_1,
    dcp.cmte_treasurer_l_nm as treasurer_name_2,
    dcp.cmte_treasurer_m_nm as treasurer_name_middle,
    dcp.cmte_treasurer_ph_num as treasurer_phone,
    dcp.cmte_treasurer_prefix as treasurer_name_prefix,
    dcp.cmte_treasurer_st as treasurer_state,
    dcp.cmte_treasurer_st1 as treasurer_street_1,
    dcp.cmte_treasurer_st2 as treasurer_street_2,
    dcp.cmte_treasurer_suffix as treasurer_name_suffix,
    dcp.cmte_treasurer_title as treasurer_name_title,
    dcp.cmte_treasurer_zip as treasurer_zip,
    -- Custodian
    dcp.cmte_custodian_city as custodian_city,
    dcp.cmte_custodian_f_nm as custodian_name_1,
    dcp.cmte_custodian_l_nm as custodian_name_2,
    dcp.cmte_custodian_m_nm as custodian_name_middle,
    dcp.cmte_custodian_nm as custodian_name_full,
    dcp.cmte_custodian_ph_num as custodian_phone,
    dcp.cmte_custodian_prefix as custodian_name_prefix,
    dcp.cmte_custodian_st as custodian_state,
    dcp.cmte_custodian_st1 as custodian_street_1,
    dcp.cmte_custodian_st2 as custodian_street_2,
    dcp.cmte_custodian_suffix as custodian_name_suffix,
    dcp.cmte_custodian_title as custodian_name_title,
    dcp.cmte_custodian_zip as custodian_zip,
    -- Properties
    dcp.cmte_email as email,
    dcp.cmte_fax as fax,
    dcp.cmte_web_url as website,
    dcp.form_tp as form_type,
    dcp.leadership_pac as leadership_pac,
    dcp.load_date as load_date,
    dcp.lobbyist_registrant_pac_flg as lobbyist_registrant_pac,
    dcp.party_cmte_type as party_type,
    dcp.party_cmte_type_desc as party_type_full,
    dcp.qual_dt as qualifying_date,
    dcp.receipt_dt as last_file_date,
    filings_original.receipt_date as first_file_date,
    dd.cmte_dsgn as designation,
    expand_committee_designation(dd.cmte_dsgn) as designation_full,
    dd.cmte_tp as committee_type,
    expand_committee_type(dd.cmte_tp) as committee_type_full,
    dd.filing_freq as filing_frequency,
    clean_party(p.party_affiliation_desc) as party_full,
    cycle_agg.cycles,
    coalesce(candidate_agg.candidate_ids, '{}'::text[]) as candidate_ids
from dimcmteproperties dcp
left join cycle_agg on dcp.cmte_id = cycle_agg.committee_id
left join cycles on dcp.cmte_id = cycles.committee_id and dcp.rpt_yr <= cycles.cycle
left join dimparty p on dcp.cand_pty_affiliation = p.party_affiliation
left join dimcmtetpdsgn dd on dcp.cmte_sk = dd.cmte_sk and extract(year from dd.receipt_date) <= cycles.cycle
left join filings_original on dcp.cmte_id = filings_original.committee_id
left join candidate_agg on dcp.cmte_sk = candidate_agg.cmte_sk
where max_cycle >= :START_YEAR
order by dcp.cmte_sk, cycle desc, dcp.rpt_yr desc
;

create unique index on ofec_committee_history_mv_tmp(idx);

create index on ofec_committee_history_mv_tmp(cycle);
create index on ofec_committee_history_mv_tmp(committee_id);
create index on ofec_committee_history_mv_tmp(committee_key);
create index on ofec_committee_history_mv_tmp(designation);


drop materialized view if exists ofec_committee_detail_mv_tmp;
create materialized view ofec_committee_detail_mv_tmp as
select distinct on (committee_id) *
from ofec_committee_history_mv_tmp
order by committee_id, cycle desc
;


create unique index on ofec_committee_detail_mv_tmp(idx);

create index on ofec_committee_detail_mv_tmp(name);
create index on ofec_committee_detail_mv_tmp(party);
create index on ofec_committee_detail_mv_tmp(state);
create index on ofec_committee_detail_mv_tmp(party_full);
create index on ofec_committee_detail_mv_tmp(designation);
create index on ofec_committee_detail_mv_tmp(expire_date);
create index on ofec_committee_detail_mv_tmp(committee_id);
create index on ofec_committee_detail_mv_tmp(committee_key);
create index on ofec_committee_detail_mv_tmp(committee_type);
create index on ofec_committee_detail_mv_tmp(last_file_date);
create index on ofec_committee_detail_mv_tmp(treasurer_name);
create index on ofec_committee_detail_mv_tmp(first_file_date);
create index on ofec_committee_detail_mv_tmp(designation_full);
create index on ofec_committee_detail_mv_tmp(organization_type);
create index on ofec_committee_detail_mv_tmp(committee_type_full);
create index on ofec_committee_detail_mv_tmp(organization_type_full);

create index on ofec_committee_detail_mv_tmp using gin (cycles);
create index on ofec_committee_detail_mv_tmp using gin (candidate_ids);

drop table if exists dimcmte_fulltext;
drop materialized view if exists ofec_committee_fulltext_mv_tmp;
create materialized view ofec_committee_fulltext_mv_tmp as
select distinct on (committee_id)
    row_number() over () as idx,
    committee_id as id,
    name,
    case
        when name is not null then
            setweight(to_tsvector(name), 'A') ||
            setweight(to_tsvector(coalesce(pac."PACRONYM", '')), 'A') ||
            setweight(to_tsvector(committee_id), 'B')
        else null::tsvector
    end
as fulltxt
from ofec_committee_detail_mv_tmp cd
left join pacronyms pac on cd.committee_id = pac."ID NUMBER"
;

create unique index on ofec_committee_fulltext_mv_tmp(idx);
create index on ofec_committee_fulltext_mv_tmp using gin(fulltxt);
