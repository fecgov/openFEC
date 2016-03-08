drop table if exists ofec_committee_detail_tmp;
create table ofec_committee_detail_tmp as
select distinct on (committee_id) *
from ofec_committee_history
order by committee_id, cycle desc
;

create unique index on ofec_committee_detail_tmp (idx);

create index on ofec_committee_detail_tmp(name);
create index on ofec_committee_detail_tmp(party);
create index on ofec_committee_detail_tmp(state);
create index on ofec_committee_detail_tmp(party_full);
create index on ofec_committee_detail_tmp(designation);
create index on ofec_committee_detail_tmp(expire_date);
create index on ofec_committee_detail_tmp(committee_id);
create index on ofec_committee_detail_tmp(committee_type);
create index on ofec_committee_detail_tmp(last_file_date);
create index on ofec_committee_detail_tmp(treasurer_name);
create index on ofec_committee_detail_tmp(first_file_date);
create index on ofec_committee_detail_tmp(designation_full);
create index on ofec_committee_detail_tmp(organization_type);
create index on ofec_committee_detail_tmp(committee_type_full);
create index on ofec_committee_detail_tmp(organization_type_full);

create index on ofec_committee_detail_tmp using gin (cycles);
create index on ofec_committee_detail_tmp using gin (candidate_ids);
create index on ofec_committee_detail_tmp using gin (treasurer_text);

drop table if exists ofec_committee_detail;
alter table ofec_committee_detail_tmp rename to ofec_committee_detail;
