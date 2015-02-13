drop view if exists ofec_committees_vw;
create view ofec_committees_vw as
select distinct
    dimcmte.cmte_sk as committee_key,
    dimcmte.cmte_id as committee_id,
    dd.cmte_dsgn as designation,
    cp.cmte_treasurer_nm as treasurer_name,
    cp.org_tp as orgnization_type_short,
    cp.org_tp_desc as orgnization_type,
    cp.cmte_st as state,
    cp.cand_pty_affiliation as party,
    cp.org_tp as type,
    cp.expire_date as expire_date,
    -- they should give this to us but I am querying around it for now
    (select load_date from dimcmteproperties cp where cp.cmte_sk = dimcmte.cmte_sk order by load_date desc limit 1) as original_registration_date,
    (select cmte_nm from dimcmteproperties cp where cp.cmte_sk = dimcmte.cmte_sk order by cmteproperties_sk desc limit 1) as name
from dimcmte
    inner join dimcmtetpdsgn dd using (cmte_sk)
    inner join dimcmteproperties dc using (cmte_sk)
;
grant select on table ofec_committees_vw to webro;