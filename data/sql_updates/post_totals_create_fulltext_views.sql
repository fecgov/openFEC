-- Concatenate committee totals
drop table if exists ofec_committee_totals cascade;
create table ofec_committee_totals as
    select committee_id, cycle, receipts from ofec_totals_pacs_parties_mv_tmp
    union all
    select committee_id, cycle, receipts from ofec_totals_house_senate_mv_tmp
    union all
    select committee_id, cycle, receipts from ofec_totals_presidential_mv_tmp
;

-- Create candidate fulltext view
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
from ofec_committee_detail_mv_tmp cd
left join pacronyms pac using (committee_id)
left join totals using (committee_id)
;

create unique index on ofec_committee_fulltext_mv_tmp(idx);

create index on ofec_committee_fulltext_mv_tmp using gin(fulltxt);
create index on ofec_committee_fulltext_mv_tmp (receipts);

-- Create committee fulltext view
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
    from cand_cmte_linkage link
    join ofec_committee_totals totals on
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
