drop table if exists ofec_committee_history_tmp cascade;
create table ofec_committee_history_tmp as
with
    cycles as (
        select
            cmte_id,
            array_agg(fec_election_yr)::int[] as cycles,
            max(fec_election_yr) as max_cycle
        from cmte_valid_fec_yr
        group by cmte_id
    ),
    dates as (
        select
            committee_id as cmte_id,
            min(receipt_date) as first_file_date,
            max(receipt_date) as last_file_date,
            max(receipt_date) filter (where form_type = 'F1') as last_f1_date
        from vw_filing_history
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
    fec_yr.cmte_id as committee_id,
    fec_yr.cmte_nm as name,
    fec_yr.tres_nm as treasurer_name,
    to_tsvector(fec_yr.tres_nm) as treasurer_text,
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
    dates.first_file_date,
    dates.last_file_date,
    dates.last_f1_date,
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
left join dates on fec_yr.cmte_id = dates.cmte_id
left join candidates on fec_yr.cmte_id = candidates.cmte_id
where cycles.max_cycle >= %(START_YEAR)s
order by fec_yr.cmte_id, fec_yr.fec_election_yr desc, dcp.rpt_yr desc
;

create unique index on ofec_committee_history_tmp(idx);

create index on ofec_committee_history_tmp(cycle);
create index on ofec_committee_history_tmp(committee_id);
create index on ofec_committee_history_tmp(designation);

drop table if exists ofec_committee_history;
alter table ofec_committee_history_tmp rename to ofec_committee_history;
