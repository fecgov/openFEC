drop materialized view if exists ofec_candidate_fulltext_audit_mv_tmp;
create materialized view ofec_candidate_fulltext_audit_mv_tmp as
select distinct on (cand_id, cand_name)
    row_number() over () as idx,
    cand_id as id,
    cand_name as name,
case
    when cand_name is not null then
		setweight(to_tsvector(cand_name), 'A') ||
		setweight(to_tsvector(cand_id), 'B')
	else null::tsvector
end as fulltxt
from auditsearch.cand_audit_vw order by cand_id;

create unique index on ofec_candidate_fulltext_audit_mv_tmp(idx);
create index on ofec_candidate_fulltext_audit_mv_tmp using gin(fulltxt);
