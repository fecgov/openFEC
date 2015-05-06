drop view if exists ofec_committee_detail_vw;
drop materialized view if exists ofec_committee_detail_mv_tmp;
create materialized view ofec_committee_detail_mv_tmp as
select distinct
    row_number() over () as idx,
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
    cp_most_recent.cmte_nm as name,
    -- (select all cand_id from dimlinkages dl where dl.cmte_sk = dimcmte.cmte_sk) as candidate_ids
    -- Below here are committee variables for the detail view
    -- Address
    cp_most_recent.cmte_st1 as street_1,
    cp_most_recent.cmte_st2 as street_2,
    cp_most_recent.cmte_city as city,
    cp_most_recent.cmte_st_desc as state_full,
    cp_most_recent.cmte_zip as zip,
    -- Treasurer
    cp_most_recent.cmte_treasurer_city as treasurer_city,
    cp_most_recent.cmte_treasurer_f_nm as treasurer_name_1,
    cp_most_recent.cmte_treasurer_l_nm as treasurer_name_2,
    cp_most_recent.cmte_treasurer_m_nm as treasurer_name_middle,
    cp_most_recent.cmte_treasurer_ph_num as treasurer_phone,
    cp_most_recent.cmte_treasurer_prefix as treasurer_name_prefix,
    cp_most_recent.cmte_treasurer_st as treasurer_state,
    cp_most_recent.cmte_treasurer_st1 as treasurer_street_1,
    cp_most_recent.cmte_treasurer_st2 as treasurer_street_2,
    cp_most_recent.cmte_treasurer_suffix as treasurer_name_suffix,
    cp_most_recent.cmte_treasurer_title as treasurer_name_title,
    cp_most_recent.cmte_treasurer_zip as treasurer_zip,
    -- Custodian
    cp_most_recent.cmte_custodian_city as custodian_city,
    cp_most_recent.cmte_custodian_f_nm as custodian_name_1,
    cp_most_recent.cmte_custodian_l_nm as custodian_name_2,
    cp_most_recent.cmte_custodian_m_nm as custodian_name_middle,
    cp_most_recent.cmte_custodian_nm as custodian_name_full,
    cp_most_recent.cmte_custodian_ph_num as custodian_phone,
    cp_most_recent.cmte_custodian_prefix as custodian_name_prefix,
    cp_most_recent.cmte_custodian_st as custodian_state,
    cp_most_recent.cmte_custodian_st1 as custodian_street_1,
    cp_most_recent.cmte_custodian_st2 as custodian_street_2,
    cp_most_recent.cmte_custodian_suffix as custodian_name_suffix,
    cp_most_recent.cmte_custodian_title as custodian_name_title,
    cp_most_recent.cmte_custodian_zip as custodian_zip,
    -- Properties
    cp_most_recent.cmte_email as email,
    cp_most_recent.cmte_fax as fax,
    cp_most_recent.cmte_web_url as website,
    dd.filing_freq as filing_frequency,
    cp_most_recent.form_tp as form_type,
    cp_most_recent.leadership_pac as leadership_pac,
    cp_most_recent.load_date as load_date,
    cp_most_recent.lobbyist_registrant_pac_flg as lobbyist_registrant_pac,
    cp_most_recent.party_cmte_type as party_type,
    cp_most_recent.party_cmte_type_desc as party_type_full,
    cp_most_recent.qual_dt as qualifying_date,
    cp_most_recent.receipt_dt as last_file_date,
    cp_original.receipt_dt as first_file_date

from dimcmte
    left join (
        select distinct on (cmte_sk) * from dimcmtetpdsgn
            order by cmte_sk, receipt_date desc
    ) dd using (cmte_sk)
    -- do a DISTINCT ON subselect to get the most recent properties for a committee
    left join (
        select distinct on (cmte_sk) * from dimcmteproperties
            order by cmte_sk, receipt_dt desc
    ) cp_most_recent using (cmte_sk)
    left join(
        select cmte_sk, min(receipt_dt) receipt_dt from dimcmteproperties
            where form_tp = 'F1'
            group by cmte_sk
    ) cp_original using (cmte_sk)
    left join dimparty p on cp_most_recent.cand_pty_affiliation = p.party_affiliation
    left join (
        select distinct on (cmte_sk) cmte_sk, load_date from dimcmteproperties
            order by cmte_sk, cmteproperties_sk
    ) dates on dimcmte.cmte_sk = dates.cmte_sk
    -- inner join dimlinkages dl using (cmte_sk)
;

create unique index on ofec_committee_detail_mv_tmp(idx);

create index on ofec_committee_detail_mv_tmp(designation);
create index on ofec_committee_detail_mv_tmp(expire_date);
create index on ofec_committee_detail_mv_tmp(committee_id);
create index on ofec_committee_detail_mv_tmp(committee_key);
create index on ofec_committee_detail_mv_tmp(committee_type);
create index on ofec_committee_detail_mv_tmp(organization_type);
