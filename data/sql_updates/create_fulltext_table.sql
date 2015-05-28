drop table if exists dimcand_fulltext;
drop materialized view if exists ofec_candidate_fulltext_mv_tmp;
create materialized view ofec_candidate_fulltext_mv_tmp as
    select distinct on (cand_sk)
        row_number() over () as idx,
        cand_sk,
        case
            when cand_nm is not null then
                setweight(to_tsvector(cand_nm), 'A') ||
                setweight(to_tsvector(cand_id), 'B')
            else null::tsvector
            end
        as fulltxt
    from dimcandproperties dcp
    inner join (
        select distinct cand_sk from dimcandproperties
        where form_tp != 'F2Z'
    ) f2 using (cand_sk)
    -- Use same joins as main candidate views to ensure same candidates
    -- present in all views
    left join dimcandoffice co using (cand_sk)
    inner join dimoffice using (office_sk)
    inner join dimparty using (party_sk)
    where election_yr >= :START_YEAR
    order by cand_sk, election_yr desc
;

create unique index on ofec_candidate_fulltext_mv_tmp(idx);
create index on ofec_candidate_fulltext_mv_tmp using gin(fulltxt);

drop table if exists dimcmte_fulltext;
drop materialized view if exists ofec_committee_fulltext_mv_tmp;
create materialized view ofec_committee_fulltext_mv_tmp as
    select distinct on (cmte_sk)
        row_number() over () as idx,
        cmte_sk,
        case
            when cmte_nm is not null then
                setweight(to_tsvector(cmte_nm), 'A') ||
                setweight(to_tsvector(cmte_id), 'B')
            else null::tsvector
            end
        as fulltxt
    from dimcmteproperties dcp
    left join (
        select
            cmte_sk,
            array_agg(distinct(rpt_yr + rpt_yr % 2))::int[] as cycles
        from (
            select cmte_sk, rpt_yr from factpacsandparties_f3x
            union
            select cmte_sk, rpt_yr from factpresidential_f3p
            union
            select cmte_sk, rpt_yr from facthousesenate_f3
        ) years
        where rpt_yr >= :START_YEAR
        group by cmte_sk
    ) cp_agg using (cmte_sk)
    where array_length(cp_agg.cycles, 1) > 0
    order by cmte_sk, receipt_dt desc
;

create unique index on ofec_committee_fulltext_mv_tmp(idx);
create index on ofec_committee_fulltext_mv_tmp using gin(fulltxt);

drop table if exists name_search_fulltext;
drop materialized view if exists ofec_candidate_committee_fulltext_mv_tmp;
create materialized view ofec_candidate_committee_fulltext_mv_tmp as
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
        join dimparty using (party_sk)
        inner join (
            select distinct cand_sk from dimcandproperties
            where form_tp != 'F2Z'
        ) f2 on c.cand_sk = f2.cand_sk
        where p.election_yr >= :START_YEAR
        order by c.cand_sk, p.election_yr desc
    ), ranked_cmte as (
        select distinct on (cmte_sk)
            cmte_nm as name,
            to_tsvector(cmte_nm) as name_vec,
            cmte_id
        from dimcmteproperties dcp
        left join (
            select
                cmte_sk,
                array_agg(distinct(rpt_yr + rpt_yr % 2))::int[] as cycles
            from (
                select cmte_sk, rpt_yr from factpacsandparties_f3x
                union
                select cmte_sk, rpt_yr from factpresidential_f3p
                union
                select cmte_sk, rpt_yr from facthousesenate_f3
            ) years
            where rpt_yr >= :START_YEAR
            group by cmte_sk
        ) cp_agg using (cmte_sk)
        where array_length(cp_agg.cycles, 1) > 0
        order by cmte_sk, receipt_dt desc
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

create unique index on ofec_candidate_committee_fulltext_mv_tmp(idx);
create index on ofec_candidate_committee_fulltext_mv_tmp using gin(name_vec);
