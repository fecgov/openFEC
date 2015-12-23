drop materialized view if exists ofec_cand_cmte_linkage_mv_tmp;
create materialized view ofec_cand_cmte_linkage_mv_tmp as
select
    row_number() over () as idx,
    *
from cand_cmte_linkage
where
    substr(cand_id, 1, 1) = cmte_tp or
    cmte_tp not in ('P', 'S', 'H')
;

create unique index on ofec_cand_cmte_linkage_mv_tmp(idx);

create index on ofec_cand_cmte_linkage_mv_tmp(cand_id);
create index on ofec_cand_cmte_linkage_mv_tmp(cmte_id);
create index on ofec_cand_cmte_linkage_mv_tmp(cand_election_yr);
