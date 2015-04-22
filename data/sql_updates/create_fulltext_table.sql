drop table if exists dimcand_fulltext;
drop materialized view if exists dimcand_fulltext_mv;
create materialized view dimcand_fulltext_mv as
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
    group by c.cand_sk
;

create unique index on dimcand_fulltext_mv(idx);
create index on dimcand_fulltext_mv using gin(fulltxt);

drop table if exists dimcmte_fulltext;
drop materialized view if exists dimcmte_fulltext_mv;
create materialized view dimcmte_fulltext_mv as
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
    left outer join dimcmteproperties p on c.cmte_sk = p.cmte_sk
    group by c.cmte_sk
;

create unique index on dimcmte_fulltext_mv(idx);
create index on dimcmte_fulltext_mv using gin(fulltxt);

drop table if exists name_search_fulltext;
drop materialized view if exists name_search_fulltext_mv;
create materialized view name_search_fulltext_mv as
with
    ranked_cand as (
        select
            p.cand_nm as name,
            to_tsvector(p.cand_nm) as name_vec,
            c.cand_id,
            row_number() over
                (partition by c.cand_id order by p.load_date desc)
                as load_order,
            null::text as cmte_id,
            o.office_tp as office_sought
        from dimcand c
        join dimcandproperties p on (p.cand_sk = c.cand_sk)
        join dimcandoffice co on (co.cand_sk = c.cand_sk)
        join dimoffice o on (co.office_sk = o.office_sk)
    ), ranked_cmte as (
        select
            p.cmte_nm as name,
            to_tsvector(p.cmte_nm) as name_vec,
            c.cmte_id,
            row_number()
                over (partition by c.cmte_id order by p.load_date desc)
                as load_order
        from dimcmte c
        join dimcmteproperties p on (p.cmte_sk = c.cmte_sk)
    )
    select distinct
        row_number() over () as idx,
        name,
        name_vec,
        cand_id,
        cmte_id,
        office_sought
    from ranked_cand
    where load_order = 1
    union
    select distinct
        row_number() over () + (select count(*) from ranked_cand) as idx,
        name,
        name_vec,
        null as cand_id,
        cmte_id,
        null as office_sought
    from ranked_cmte
    where load_order = 1
;

create unique index on name_search_fulltext_mv(idx);
create index on name_search_fulltext_mv using gin(name_vec);
