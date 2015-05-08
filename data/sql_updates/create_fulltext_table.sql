drop table if exists dimcand_fulltext;
drop materialized view if exists dimcand_fulltext_mv_tmp;
create materialized view dimcand_fulltext_mv_tmp as
    select
        row_number() over () as idx,
        c.cand_sk,
        case
            when max(p.cand_nm) is not null then
                setweight(to_tsvector(string_agg(coalesce(p.cand_nm, ''), ' ')), 'A') ||
                setweight(to_tsvector(string_agg(coalesce(c.cand_id, ''), ' ')), 'B')
            else null::tsvector
            end
        as fulltxt
    from dimcand c
    left outer join dimcandproperties p on c.cand_sk = p.cand_sk
    where p.election_yr >= :START_YEAR
    group by c.cand_sk
;

create unique index on dimcand_fulltext_mv_tmp(idx);
create index on dimcand_fulltext_mv_tmp using gin(fulltxt);

drop table if exists dimcmte_fulltext;
drop materialized view if exists dimcmte_fulltext_mv_tmp;
create materialized view dimcmte_fulltext_mv_tmp as
    select
        row_number() over () as idx,
        c.cmte_sk,
        case
            when max(p.cmte_nm) is not null then
                setweight(to_tsvector(string_agg(coalesce(p.cmte_nm, ''), ' ')), 'A') ||
                setweight(to_tsvector(string_agg(coalesce(c.cmte_id, ''), ' ')), 'B')
            else null::tsvector
            end
        as fulltxt
    from dimcmte c
    left outer join dimcmteproperties p using (cmte_sk)
    where p.rpt_yr >= :START_YEAR
    group by c.cmte_sk
;

create unique index on dimcmte_fulltext_mv_tmp(idx);
create index on dimcmte_fulltext_mv_tmp using gin(fulltxt);

drop table if exists name_search_fulltext;
drop materialized view if exists name_search_fulltext_mv_tmp;
create materialized view name_search_fulltext_mv_tmp as
with
    ranked_cand as (
        select distinct on (c.cand_sk)
            p.cand_nm as name,
            to_tsvector(p.cand_nm) as name_vec,
            c.cand_id,
            null::text as cmte_id,
            o.office_tp as office_sought
        from dimcand c
            join dimcandproperties p on (p.cand_sk = c.cand_sk)
            join dimcandoffice co on (co.cand_sk = c.cand_sk)
            join dimoffice o on (co.office_sk = o.office_sk)
        where p.election_yr >= :START_YEAR
        order by c.cand_sk, p.candproperties_sk
    ), ranked_cmte as (
        select distinct on (c.cmte_sk)
            p.cmte_nm as name,
            to_tsvector(p.cmte_nm) as name_vec,
            c.cmte_id
        from dimcmte c
            join dimcmteproperties p using (cmte_sk)
        where p.rpt_yr >= :START_YEAR
        order by c.cmte_sk, p.receipt_dt desc
    )
    select
        row_number() over () as idx,
        name,
        name_vec,
        cand_id,
        cmte_id,
        office_sought
    from ranked_cand
    union
    select
        row_number() over () + (select count(*) from ranked_cand) as idx,
        name,
        name_vec,
        null as cand_id,
        cmte_id,
        null as office_sought
    from ranked_cmte
;

create unique index on name_search_fulltext_mv_tmp(idx);
create index on name_search_fulltext_mv_tmp using gin(name_vec);
