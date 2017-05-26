drop materialized view if exists ofec_sched_f_mv_tmp;
create materialized view ofec_sched_f_mv_tmp as
select
  *,
  to_tsvector(pye_nm) as payee_name_text,
  now() as pg_date
from fec_vsum_sched_f_vw;

create unique index on ofec_sched_f_mv_tmp (sub_id);
create index on ofec_sched_f_mv_tmp (cmte_id, sub_id);
create index on ofec_sched_f_mv_tmp (cand_id, sub_id);
create index on ofec_sched_f_mv_tmp (image_num, sub_id);
create index on ofec_sched_f_mv_tmp (exp_amt, sub_id);
create index on ofec_sched_f_mv_tmp (exp_dt, sub_id);
create index on ofec_sched_f_mv_tmp using gin (payee_name_text);
