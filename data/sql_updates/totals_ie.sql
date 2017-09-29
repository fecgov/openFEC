drop materialized view if exists ofec_totals_ie_only_mv_tmp cascade;
create materialized view ofec_totals_ie_only_mv_tmp as
select
    sub_id as idx,
    committee_id,
    cycle,
    coverage_start_date,
    coverage_end_date,
    contributions as total_independent_contributions,
    independent_expenditures as total_independent_expenditures,
    last_beginning_image_number,
    committee_name,
    committee_type,
    committee_designation,
    committee_type_full,
    committee_designation_full,
    party_full
from
    ofec_totals_combined_mv_tmp
where
    form_type = 'F5'
;

create unique index on ofec_totals_ie_only_mv_tmp(idx);

create index on ofec_totals_ie_only_mv_tmp(cycle, idx);
create index on ofec_totals_ie_only_mv_tmp(committee_id, idx);
create index on ofec_totals_ie_only_mv_tmp(cycle, committee_id);
create index on ofec_totals_ie_only_mv_tmp(committee_type_full, idx);
create index on ofec_totals_ie_only_mv_tmp(committee_designation_full, idx);
