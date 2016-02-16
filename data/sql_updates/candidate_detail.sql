drop table if exists ofec_candidate_detail_tmp;
create table ofec_candidate_detail_tmp as
select distinct on (candidate_id) * from ofec_candidate_history
order by candidate_id, two_year_period desc
;

create unique index on ofec_candidate_detail_tmp(idx);

create index on ofec_candidate_detail_tmp(name);
create index on ofec_candidate_detail_tmp(party);
create index on ofec_candidate_detail_tmp(state);
create index on ofec_candidate_detail_tmp(office);
create index on ofec_candidate_detail_tmp(district);
create index on ofec_candidate_detail_tmp(load_date);
create index on ofec_candidate_detail_tmp(party_full);
create index on ofec_candidate_detail_tmp(office_full);
create index on ofec_candidate_detail_tmp(candidate_id);
create index on ofec_candidate_detail_tmp(candidate_status);
create index on ofec_candidate_detail_tmp(incumbent_challenge);

create index on ofec_candidate_detail_tmp using gin (cycles);
create index on ofec_candidate_detail_tmp using gin (election_years);

drop table if exists ofec_candidate_detail;
alter table ofec_candidate_detail_tmp rename to ofec_candidate_detail;
