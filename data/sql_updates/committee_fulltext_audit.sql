drop materialized view if exists ofec_committee_fulltext_audit_mv_tmp;
create materialized view ofec_committee_fulltext_audit_mv_tmp as
select distinct on (cmte_id, cmte_nm)
    row_number() over () as idx,
    cmte_id as id,
    cmte_nm as name,
 case
     when cmte_nm is not null then
            setweight(to_tsvector(cmte_nm), 'A') ||
            setweight(to_tsvector(cmte_id), 'B')
        else null::tsvector
    end as fulltxt
from auditsearch.cmte_audit_vw order by cmte_id;

create unique index on ofec_committee_fulltext_audit_mv_tmp(idx);
create index on ofec_committee_fulltext_audit_mv_tmp using gin(fulltxt);
