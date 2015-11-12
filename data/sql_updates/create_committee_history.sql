drop materialized view if exists ofec_committee_history_mv_tmp cascade;
create materialized view ofec_committee_history_mv_tmp as
with
    cycles as (
        select
            cmte_id,
            array_agg(fec_election_yr)::int[] as cycles,
            max(fec_election_yr) as max_cycle
        from cmte_valid_fec_yr
        group by cmte_id
    ),
    filings_original as (
        select committee_id, min(receipt_date) receipt_date from vw_filing_history
        where report_year >= :START_YEAR
        group by committee_id
    ),
    candidates as (
        select
            cmte_id,
            array_agg(distinct cand_id)::text[] as candidate_ids
        from cand_cmte_linkage
        group by cmte_id
    )
select distinct on (fec_yr.cmte_id, fec_yr.fec_election_yr)
    row_number() over () as idx,
    fec_yr.fec_election_yr as cycle,
    dcp.cmte_sk as committee_key,
    fec_yr.cmte_id as committee_id,
    fec_yr.cmte_nm as name,
    fec_yr.tres_nm as treasurer_name,
    dcp.org_tp as organization_type,
    expand_organization_type(dcp.org_tp) as organization_type_full,
    dcp.expire_date as expire_date,
    -- Address
    fec_yr.cmte_st1 as street_1,
    fec_yr.cmte_st2 as street_2,
    fec_yr.cmte_city as city,
    fec_yr.cmte_st as state,
    dcp.cmte_st_desc as state_full,
    fec_yr.cmte_zip as zip,
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
    fec_yr.cmte_email as email,
    dcp.cmte_fax as fax,
    fec_yr.cmte_url as website,
    dcp.form_tp as form_type,
    dcp.leadership_pac as leadership_pac,
    dcp.lobbyist_registrant_pac_flg as lobbyist_registrant_pac,
    dcp.party_cmte_type as party_type,
    dcp.party_cmte_type_desc as party_type_full,
    dcp.qual_dt as qualifying_date,
    fec_yr.latest_receipt_dt as last_file_date,
    filings_original.receipt_date as first_file_date,
    fec_yr.cmte_dsgn as designation,
    expand_committee_designation(fec_yr.cmte_dsgn) as designation_full,
    fec_yr.cmte_tp as committee_type,
    expand_committee_type(fec_yr.cmte_tp) as committee_type_full,
    fec_yr.cmte_filing_freq as filing_frequency,
    fec_yr.cmte_pty_affiliation as party,
    fec_yr.cmte_pty_affiliation_desc as party_full,
    cycles.cycles,
    coalesce(candidates.candidate_ids, '{}'::text[]) as candidate_ids
from cmte_valid_fec_yr fec_yr
left join dimcmteproperties dcp on fec_yr.cmte_id = dcp.cmte_id and fec_yr.fec_election_yr >= dcp.rpt_yr
left join cycles on fec_yr.cmte_id = cycles.cmte_id
left join filings_original on fec_yr.cmte_id = filings_original.committee_id
left join candidates on fec_yr.cmte_id = candidates.cmte_id
where cycles.max_cycle >= :START_YEAR
order by fec_yr.cmte_id, fec_yr.fec_election_yr desc, dcp.rpt_yr desc
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
