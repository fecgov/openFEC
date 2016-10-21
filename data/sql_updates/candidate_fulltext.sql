drop materialized view if exists ofec_candidate_fulltext_mv_tmp;
create materialized view ofec_candidate_fulltext_mv_tmp as
with nicknames as (
    select
        candidate_id,
        string_agg(nickname, ' ') as nicknames
    from ofec_nicknames
    group by candidate_id
), totals as (
    select
        cand_id as candidate_id,
        sum(receipts) as receipts
    from disclosure.cand_cmte_linkage link
    join ofec_totals_combined_mv_tmp totals on
        link.cmte_id = totals.committee_id and
        link.fec_election_yr = totals.cycle
    where
        cmte_dsgn in ('P', 'A') and (
            substr(cand_id, 1, 1) = cmte_tp or
            cmte_tp not in ('P', 'S', 'H')
        )
    group by cand_id
)
select distinct on (candidate_id)
    row_number() over () as idx,
    candidate_id as id,
    name,
    office as office_sought,
    case
        when name is not null then
            setweight(to_tsvector(name), 'A') ||
            setweight(to_tsvector(coalesce(nicknames, '')), 'A') ||
            setweight(to_tsvector(candidate_id), 'B')
        else null::tsvector
    end as fulltxt,
    coalesce(totals.receipts, 0) as receipts
from ofec_candidate_detail_mv_tmp
left join nicknames using (candidate_id)
left join totals using (candidate_id)
;

create unique index on ofec_candidate_fulltext_mv_tmp(idx);

create index on ofec_candidate_fulltext_mv_tmp using gin(fulltxt);
create index on ofec_candidate_fulltext_mv_tmp (receipts);
