drop table if exists ofec_candidate_election_tmp;
create table ofec_candidate_election_tmp as
with years as (
    select
        candidate_id,
        unnest(election_years) as cand_election_year
    from ofec_candidate_detail
)
select
    row_number() over () as idx,
    years.*
from years
;

create unique index on ofec_candidate_election_tmp (idx);

create index on ofec_candidate_election_tmp (candidate_id);
create index on ofec_candidate_election_tmp (cand_election_year);

drop table if exists ofec_candidate_election;
alter table ofec_candidate_election_tmp rename to ofec_candidate_election;
