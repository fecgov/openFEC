drop table if exists ofec_committee_fulltext_tmp;
create table ofec_committee_fulltext_tmp as
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
    from ofec_committee_totals
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
from ofec_committee_detail cd
left join pacronyms pac using (committee_id)
left join totals using (committee_id)
;

create index on ofec_committee_fulltext_tmp using gin(fulltxt);
create index on ofec_committee_fulltext_tmp (receipts);

drop table if exists ofec_committee_fulltext;
alter table ofec_committee_fulltext_tmp rename to ofec_committee_fulltext;
