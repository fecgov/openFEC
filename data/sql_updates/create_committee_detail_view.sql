drop materialized view if exists ofec_committee_detail_mv;
create materialized view ofec_committee_detail_mv as
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
    cp_most_recent.filing_freq as filing_frequency,
    cp_most_recent.form_tp as form_type,
    cp_most_recent.leadership_pac as leadership_pac,
    cp_most_recent.load_date as load_date,
    cp_most_recent.lobbyist_registrant_pac_flg as lobbyist_registrant_pac,
    cp_most_recent.party_cmte_type as party_type,
    cp_most_recent.party_cmte_type_desc as party_type_full,
    cp_most_recent.qual_dt as qualifying_date

from dimcmte
    inner join dimcmtetpdsgn dd using (cmte_sk)
    -- do a DISTINCT ON subselect to get the most recent properties for a committee
    inner join (
        select distinct on (cmte_sk) cmte_sk, cmte_nm, cmte_zip, cmte_treasurer_nm, org_tp, org_tp_desc, cmte_st, expire_date, cand_pty_affiliation, cmte_st1, cmte_st2, cmte_city, cmte_st_desc, cmte_zip cmte_treasurer_city, cmte_treasurer_f_nm, cmte_treasurer_l_nm, cmte_treasurer_m_nm, cmte_treasurer_ph_num, cmte_treasurer_prefix, cmte_treasurer_st, cmte_treasurer_st1, cmte_treasurer_st2, cmte_treasurer_suffix, cmte_treasurer_title, cmte_treasurer_zip, cmte_custodian_city, cmte_custodian_f_nm, cmte_custodian_l_nm, cmte_custodian_m_nm, cmte_custodian_nm, cmte_custodian_ph_num, cmte_custodian_prefix, cmte_custodian_st, cmte_custodian_st1, cmte_custodian_st2, cmte_custodian_suffix, cmte_custodian_title, cmte_custodian_zip, cmte_email, cmte_fax, cmte_web_url, filing_freq, form_tp, leadership_pac, load_date, lobbyist_registrant_pac_flg, party_cmte_type, party_cmte_type_desc, qual_dt from dimcmteproperties order by cmte_sk, cmteproperties_sk desc
    ) cp_most_recent using (cmte_sk)
    left join dimparty p on cp_most_recent.cand_pty_affiliation = p.party_affiliation
    -- inner join dimlinkages dl using (cmte_sk)
;
