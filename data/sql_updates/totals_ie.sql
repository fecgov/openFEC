drop materialized view if exists ofec_totals_ie_only_mv_tmp cascade;
create materialized view ofec_totals_ie_only_mv_tmp as
select
    sub_id,
    committee_id,
    cycle,
    coverage_start_date,
    coverage_end_date,
    contributions as total_independent_contributions,
    independent_expenditures as total_independent_expenditures,
    last_beginning_image_number
from
    ofec_totals_combined_mv_tmp
where
    form_type = 'F5'
;

create unique index on ofec_totals_ie_only_mv_tmp(sub_id);

create index on ofec_totals_ie_only_mv_tmp(cycle, sub_id);
create index on ofec_totals_ie_only_mv_tmp(committee_id, sub_id);
