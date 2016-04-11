-- creating totals flags to the basic candidate data after the totals have been computed

create materialized view ofec_candidate_flag_tmp as
select
    row_number() over () as idx,
    candidate_id,
    array_agg(five_thousand_flag)::boolean array @> array[cast('true' as boolean)] as five_thousand_flag,
    array_agg(federal_funds_flag)::boolean array @> array[cast('true' as boolean)] as federal_funds_flag
from ofec_candidate_totals_mv_tmp
group by candidate_id
;

create unique index on ofec_candidate_flag_tmp(idx);
create index on ofec_candidate_flag_tmp(candidate_id);
create index on ofec_candidate_flag_tmp(five_thousand_flag);
create index on ofec_candidate_flag_tmp(federal_funds_flag);
