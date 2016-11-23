drop materialized view if exists ofec_committee_history_mv_tmp cascade;
create materialized view ofec_committee_history_mv_tmp as
with
    cycles as (
        select
            cmte_id,
            array_agg(fec_election_yr)::int[] as cycles,
            max(fec_election_yr) as max_cycle
        from disclosure.cmte_valid_fec_yr
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
        from disclosure.cand_cmte_linkage
        group by cmte_id
    )
select distinct on (fec_yr.cmte_id, fec_yr.fec_election_yr)
    row_number() over () as idx,
    fec_yr.fec_election_yr as cycle,
    fec_yr.cmte_id as committee_id,
    fec_yr.cmte_nm as name,
    fec_yr.tres_nm as treasurer_name,
    to_tsvector(fec_yr.tres_nm) as treasurer_text,
    f1.org_tp as organization_type,
    expand_organization_type(f1.org_tp) as organization_type_full,
    --verify, but this column is gone now
    null as expire_date,
    -- Address
    fec_yr.cmte_st1 as street_1,
    fec_yr.cmte_st2 as street_2,
    fec_yr.cmte_city as city,
    fec_yr.cmte_st as state,
    expand_state(fec_yr.cmte_st) as state_full,
    fec_yr.cmte_zip as zip,
    -- Treasurer
    f1.tres_city as treasurer_city,
    f1.tres_f_nm as treasurer_name_1,
    f1.tres_l_nm as treasurer_name_2,
    f1.tres_m_nm as treasurer_name_middle,
    f1.tres_ph_num as treasurer_phone,
    f1.tres_prefix as treasurer_name_prefix,
    f1.tres_st as treasurer_state,
    f1.tres_st1 as treasurer_street_1,
    f1.tres_st2 as treasurer_street_2,
    f1.tres_suffix as treasurer_name_suffix,
    f1.tres_title as treasurer_name_title,
    f1.tres_zip as treasurer_zip,
    -- Custodian
    f1.cust_rec_city as custodian_city,
    f1.cust_rec_f_nm as custodian_name_1,
    f1.cust_rec_l_nm as custodian_name_2,
    f1.cust_rec_m_nm as custodian_name_middle,
    f1.cust_rec_nm as custodian_name_full,
    f1.cust_rec_ph_num as custodian_phone,
    f1.cust_rec_prefix as custodian_name_prefix,
    f1.cust_rec_st as custodian_state,
    f1.cust_rec_st1 as custodian_street_1,
    f1.cust_rec_st2 as custodian_street_2,
    f1.cust_rec_suffix as custodian_name_suffix,
    f1.cust_rec_title as custodian_name_title,
    f1.cust_rec_zip as custodian_zip,
    -- Properties
    fec_yr.cmte_email as email,
    f1.cmte_fax as fax,
    fec_yr.cmte_url as website,
    f1.form_tp as form_type,
    f1.leadership_pac as leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp as party_type,
    f1.cand_pty_tp_desc as party_type_full,
    f1.qual_dt as qualifying_date,
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
from disclosure.cmte_valid_fec_yr fec_yr
left join fec_vsum_f1 f1 on fec_yr.cmte_id = f1.cmte_id and fec_yr.fec_election_yr >= f1.rpt_yr
left join cycles on fec_yr.cmte_id = cycles.cmte_id
left join dates on fec_yr.cmte_id = dates.cmte_id
left join candidates on fec_yr.cmte_id = candidates.cmte_id
where cycles.max_cycle >= :START_YEAR
order by fec_yr.cmte_id, fec_yr.fec_election_yr desc, f1.rpt_yr desc
;

create unique index on ofec_committee_history_mv_tmp(idx);

create index on ofec_committee_history_mv_tmp(name);
create index on ofec_committee_history_mv_tmp(cycle);
create index on ofec_committee_history_mv_tmp(committee_id);
create index on ofec_committee_history_mv_tmp(designation);
