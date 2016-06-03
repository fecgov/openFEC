-- creating totals flags to the basic candidate data after the totals have been computed

create materialized view ofec_candidate_flag_tmp as
select
    row_number() over () as idx,
    ofec_candidate_history_mv_tmp.candidate_id,
    array_agg(oct.has_raised_funds)::boolean array @> array[cast('true' as boolean)] as has_raised_funds,
    array_agg(oct.federal_funds_flag)::boolean array @> array[cast('true' as boolean)] as federal_funds_flag
from ofec_candidate_history_mv_tmp
    left join ofec_candidate_totals_mv_tmp oct using (candidate_id)
group by ofec_candidate_history_mv_tmp.candidate_id
;

create unique index on ofec_candidate_flag_tmp(idx);
create index on ofec_candidate_flag_tmp(candidate_id);
create index on ofec_candidate_flag_tmp(has_raised_funds);
create index on ofec_candidate_flag_tmp(federal_funds_flag);
