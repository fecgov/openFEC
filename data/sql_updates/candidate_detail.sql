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
