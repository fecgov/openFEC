drop table if exists ofec_candidate_history_latest;
create table ofec_candidate_history_latest_tmp as
select distinct on (cand.candidate_id, election.cand_election_year)
    cand.*,
    election.cand_election_year
from ofec_candidate_history cand
join ofec_candidate_election election on
    cand.candidate_id = election.candidate_id and
    cand.two_year_period <= election.cand_election_year and
    cand.two_year_period > election.prev_election_year
order by
    cand.candidate_id,
    election.cand_election_year,
    cand.two_year_period desc
;

create unique index on ofec_candidate_history_latest_tmp (candidate_id, cand_election_year);

create index on ofec_candidate_history_latest_tmp (candidate_id);
create index on ofec_candidate_history_latest_tmp (cand_election_year);

drop table if exists ofec_candidate_history_latest;
alter table ofec_candidate_history_latest_tmp rename to ofec_candidate_history_latest;
