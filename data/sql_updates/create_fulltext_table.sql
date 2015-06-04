drop table if exists dimcand_fulltext;
drop materialized view if exists ofec_candidate_fulltext_mv_tmp;
create materialized view ofec_candidate_fulltext_mv_tmp as
    select distinct on (cand_sk)
        row_number() over () as idx,
        cand_id as id,
        cand_nm as name,
        dof.office_tp as office_sought,
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
    inner join dimoffice dof using (office_sk)
    inner join dimparty dp using (party_sk)
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
        cmte_id as id,
        cmte_nm as name,
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
            union all
            select cmte_sk, rpt_yr from factpresidential_f3p
            union all
            select cmte_sk, rpt_yr from facthousesenate_f3
            union all
            select cmte_sk, rpt_yr from dimcmteproperties
        ) years
        where rpt_yr >= :START_YEAR
        group by cmte_sk
    ) cp_agg using (cmte_sk)
    where array_length(cp_agg.cycles, 1) > 0
    order by cmte_sk, receipt_dt desc
;

create unique index on ofec_committee_fulltext_mv_tmp(idx);
create index on ofec_committee_fulltext_mv_tmp using gin(fulltxt);
