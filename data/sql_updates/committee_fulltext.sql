drop materialized view if exists ofec_committee_fulltext_mv_tmp;
create materialized view ofec_committee_fulltext_mv_tmp as
with pacronyms as (
    select
        "ID NUMBER" as committee_id,
        string_agg("PACRONYM", ' ') as pacronyms
    from ofec_pacronyms
    group by committee_id
), totals as (
    select
        committee_id,
        sum(receipts) as receipts
    from ofec_totals_combined_mv_tmp
    group by committee_id
)
select distinct on (committee_id)
    row_number() over () as idx,
    committee_id as id,
    name,
    case
        when name is not null then
            setweight(to_tsvector(name), 'A') ||
            setweight(to_tsvector(coalesce(pac.pacronyms, '')), 'A') ||
            setweight(to_tsvector(committee_id), 'B')
        else null::tsvector
    end as fulltxt,
    coalesce(totals.receipts, 0) as receipts
from ofec_committee_detail_mv_tmp cd
left join pacronyms pac using (committee_id)
left join totals using (committee_id)
;

create unique index on ofec_committee_fulltext_mv_tmp(idx);

create index on ofec_committee_fulltext_mv_tmp using gin(fulltxt);
create index on ofec_committee_fulltext_mv_tmp (receipts);
