drop materialized view if exists ofec_candidate_history_mv_tmp cascade;
create materialized view ofec_candidate_history_mv_tmp as
with
    -- Select rows from `cand_valid_fec_yr` that are associated with principal
    -- or authorized committees via `cand_cmte_linkage`
    fec_yr as (
        select
            distinct on (cand_valid_yr_id)
            cand.*
        from cand_valid_fec_yr cand
        join cand_cmte_linkage link on
            cand.cand_id = link.cand_id and
            cand.fec_election_yr = link.fec_election_yr and
            link.linkage_type in ('P', 'A')
    ),
    -- Aggregate election data across cycles by candidate
    cycles as (
        select
            cand_id,
            max(cand_election_yr) as active_through,
            array_agg(fec_election_yr)::int[] as cycles,
            array_agg(cand_election_yr)::int[] as election_years,
            array_agg(cand_office_district)::text[] as election_districts,
            max(fec_election_yr) as max_cycle
        from fec_yr
        group by cand_id
    )
select distinct on (fec_yr.cand_id, fec_yr.fec_election_yr)
    row_number() over () as idx,
    fec_yr.lst_updt_dt as load_date,
    fec_yr.fec_election_yr as two_year_period,
    fec_yr.cand_id as candidate_id,
    fec_yr.cand_name as name,
    fec_yr.cand_state as address_state,
    fec_yr.cand_city as address_city,
    fec_yr.cand_st1 as address_street_1,
    fec_yr.cand_st2 as address_street_2,
    fec_yr.cand_zip as address_zip,
    fec_yr.cand_ici as incumbent_challenge,
    expand_candidate_incumbent(fec_yr.cand_ici) as incumbent_challenge_full,
    fec_yr.cand_status as candidate_status,
    inactive.cand_id is null as candidate_inactive,
    fec_yr.cand_office as office,
    expand_office(fec_yr.cand_office) as office_full,
    fec_yr.cand_office_st as state,
    fec_yr.cand_office_district as district,
    fec_yr.cand_office_district::int as district_number,
    fec_yr.cand_pty_affiliation as party,
    clean_party(dp.party_affiliation_desc) as party_full,
    cycles.cycles,
    cycles.election_years,
    cycles.election_districts,
    cycles.active_through
from fec_yr
left join cycles using (cand_id)
left join dimcand dc using (cand_id)
left join cand_inactive inactive using (cand_id)
inner join dimparty dp on fec_yr.cand_pty_affiliation = dp.party_affiliation
where max_cycle >= :START_YEAR
;

create unique index on ofec_candidate_history_mv_tmp(idx);

create index on ofec_candidate_history_mv_tmp(load_date);
create index on ofec_candidate_history_mv_tmp(candidate_id);
create index on ofec_candidate_history_mv_tmp(two_year_period);
create index on ofec_candidate_history_mv_tmp(office);
create index on ofec_candidate_history_mv_tmp(state);
create index on ofec_candidate_history_mv_tmp(district);
create index on ofec_candidate_history_mv_tmp(district_number);


drop materialized view if exists ofec_candidate_detail_mv_tmp;
create materialized view ofec_candidate_detail_mv_tmp as
select distinct on (candidate_id) * from ofec_candidate_history_mv_tmp
order by candidate_id, two_year_period desc
;

create unique index on ofec_candidate_detail_mv_tmp(idx);

create index on ofec_candidate_detail_mv_tmp(name);
create index on ofec_candidate_detail_mv_tmp(party);
create index on ofec_candidate_detail_mv_tmp(state);
create index on ofec_candidate_detail_mv_tmp(office);
create index on ofec_candidate_detail_mv_tmp(district);
create index on ofec_candidate_detail_mv_tmp(load_date);
create index on ofec_candidate_detail_mv_tmp(party_full);
create index on ofec_candidate_detail_mv_tmp(office_full);
create index on ofec_candidate_detail_mv_tmp(candidate_id);
create index on ofec_candidate_detail_mv_tmp(candidate_status);
create index on ofec_candidate_detail_mv_tmp(incumbent_challenge);

create index on ofec_candidate_detail_mv_tmp using gin (cycles);
create index on ofec_candidate_detail_mv_tmp using gin (election_years);

drop table if exists dimcand_fulltext;
drop materialized view if exists ofec_candidate_fulltext_mv_tmp;
create materialized view ofec_candidate_fulltext_mv_tmp as
select distinct on (candidate_id)
    row_number() over () as idx,
    candidate_id as id,
    name,
    office as office_sought,
    case
        when name is not null then
            setweight(to_tsvector(name), 'A') ||
            setweight(to_tsvector(candidate_id), 'B')
        else null::tsvector
    end
as fulltxt
from ofec_candidate_detail_mv_tmp
;

create unique index on ofec_candidate_fulltext_mv_tmp(idx);
create index on ofec_candidate_fulltext_mv_tmp using gin(fulltxt);
