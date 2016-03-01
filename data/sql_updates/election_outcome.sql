-- See discussion in https://github.com/18F/openFEC-web-app/issues/514
drop table if exists ofec_election_result_tmp;
create table ofec_election_result_tmp as
(
    select fec_election_yr - 4 as election_yr, *
    from cand_valid_fec_yr
    where
        cand_ici = 'I' and
        cand_office = 'P' and
        fec_election_yr in (cand_election_yr, cand_election_yr + 4)
    order by fec_election_yr desc
)
union all
(
    select distinct on (cand_office_st, cand_election_yr)
        cand_election_yr - 6 as election_yr, *
    from cand_valid_fec_yr
    where
        cand_ici = 'I' and
        cand_office = 'S'
    order by
        cand_office_st,
        cand_election_yr desc,
        latest_receipt_dt desc
)
union all
(
    select distinct on (cand_office_st, cand_office_district, cand_election_yr)
        cand_election_yr - 2 as election_yr, *
    from cand_valid_fec_yr
    where
        cand_ici = 'I' and
        cand_office = 'H'
    order by
        cand_office_st,
        cand_office_district,
        cand_election_yr desc,
        latest_receipt_dt desc
)
;

create unique index on ofec_election_result_tmp (cand_valid_yr_id);

create index on ofec_election_result_tmp (election_yr);
create index on ofec_election_result_tmp (cand_office);
create index on ofec_election_result_tmp (cand_office_st);
create index on ofec_election_result_tmp (cand_office_district);

drop table if exists ofec_election_result;
alter table ofec_election_result_tmp rename to ofec_election_result;
