-- Create Schedule C materialized view
drop materialized view if exists ofec_sched_c_mv_tmp;
create materialized view ofec_sched_c_mv_tmp as
select
    *,
    to_tsvector(cand_nm) as candidate_name_text,
    to_tsvector(loan_src_nm) as loan_source_name_text,
    now() as pg_date
from fec_fitem_sched_c_vw;

create unique index on ofec_sched_c_mv_tmp (sub_id);

-- Create simple indexes on filtered columns
create index on ofec_sched_c_mv_tmp (cmte_id);
create index on ofec_sched_c_mv_tmp (cand_nm);
create index on ofec_sched_c_mv_tmp (incurred_dt);
create index on ofec_sched_c_mv_tmp (orig_loan_amt);
create index on ofec_sched_c_mv_tmp (image_num);
create index on ofec_sched_c_mv_tmp (rpt_yr);
create index on ofec_sched_c_mv_tmp (pymt_to_dt);
create index on ofec_sched_c_mv_tmp (get_cycle(rpt_yr));
create index on ofec_sched_c_mv_tmp (pg_date);

-- Create composite indexes on sortable columns
create index on ofec_sched_c_mv_tmp (incurred_dt, sub_id);
create index on ofec_sched_c_mv_tmp (pymt_to_dt, sub_id);
create index on ofec_sched_c_mv_tmp (orig_loan_amt, sub_id);

-- Create index on filtered fulltext columns
create index on ofec_sched_c_mv_tmp using gin (candidate_name_text);
create index on ofec_sched_c_mv_tmp using gin (loan_source_name_text);
