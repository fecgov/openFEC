drop materialized view if exists ofec_committee_detail_mv_tmp;
create materialized view ofec_committee_detail_mv_tmp as
select distinct on (committee_id) *
from ofec_committee_history_mv_tmp
order by committee_id, cycle desc
;


create unique index on ofec_committee_detail_mv_tmp (idx);

create index on ofec_committee_detail_mv_tmp(name);
create index on ofec_committee_detail_mv_tmp(party);
create index on ofec_committee_detail_mv_tmp(state);
create index on ofec_committee_detail_mv_tmp(party_full);
create index on ofec_committee_detail_mv_tmp(designation);
create index on ofec_committee_detail_mv_tmp(expire_date);
create index on ofec_committee_detail_mv_tmp(committee_id);
create index on ofec_committee_detail_mv_tmp(committee_type);
create index on ofec_committee_detail_mv_tmp(last_file_date);
create index on ofec_committee_detail_mv_tmp(treasurer_name);
create index on ofec_committee_detail_mv_tmp(first_file_date);
create index on ofec_committee_detail_mv_tmp(designation_full);
create index on ofec_committee_detail_mv_tmp(organization_type);
create index on ofec_committee_detail_mv_tmp(committee_type_full);
create index on ofec_committee_detail_mv_tmp(organization_type_full);

create index on ofec_committee_detail_mv_tmp using gin (cycles);
create index on ofec_committee_detail_mv_tmp using gin (candidate_ids);
create index on ofec_committee_detail_mv_tmp using gin (treasurer_text);
