create materialized view ofec_candidate_history_latest_mv_tmp as
select distinct on (cand.candidate_id, election.cand_election_year)
    cand.*,
    election.cand_election_year
from ofec_candidate_history_mv_tmp cand
join ofec_candidate_election_mv_tmp election on
    cand.candidate_id = election.candidate_id and
    cand.two_year_period <= election.cand_election_year and
    cand.two_year_period > election.prev_election_year
order by
    cand.candidate_id,
    election.cand_election_year,
    cand.two_year_period desc
;

create unique index on ofec_candidate_history_latest_mv_tmp (candidate_id, cand_election_year);

create index on ofec_candidate_history_latest_mv_tmp (candidate_id);
create index on ofec_candidate_history_latest_mv_tmp (cand_election_year);
