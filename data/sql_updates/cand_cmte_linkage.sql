drop table if exists ofec_cand_cmte_linkage_tmp;
create table ofec_cand_cmte_linkage_tmp as
select
    row_number() over () as idx,
    *
from cand_cmte_linkage
where
    substr(cand_id, 1, 1) = cmte_tp or
    cmte_tp not in ('P', 'S', 'H')
;

create index on ofec_cand_cmte_linkage_tmp(cand_id);
create index on ofec_cand_cmte_linkage_tmp(cmte_id);
create index on ofec_cand_cmte_linkage_tmp(cand_election_yr);
