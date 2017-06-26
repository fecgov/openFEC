-- Create Schedule E table
drop table if exists ofec_sched_e_tmp;
create table ofec_sched_e_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice,
    to_tsvector(pye_nm) as payee_name_text,
    now() as pg_date
from fec_fitem_sched_e_vw;

-- Add in records from the Schedule E notices view
insert into ofec_sched_e_tmp
select *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice,
    to_tsvector(pye_nm) as payee_name_text,
    now() as pg_date
from fec_sched_e_notice_vw;

-- Set up the primary key
create unique index idx_ofec_sched_e_sub_id_tmp on ofec_sched_e_tmp (sub_id);
alter table ofec_sched_e_tmp add constraint ofec_sched_e_sub_id_pkey_tmp primary key using index idx_ofec_sched_e_sub_id_tmp;

-- Create simple indices on filtered columns
create index idx_ofec_sched_e_cmte_id_tmp on ofec_sched_e_tmp (cmte_id);
create index idx_ofec_sched_e_s_o_cand_id_tmp on ofec_sched_e_tmp (s_o_cand_id);
create index idx_ofec_sched_e_entity_tp_tmp on ofec_sched_e_tmp (entity_tp);
create index idx_ofec_sched_e_image_num_tmp on ofec_sched_e_tmp (image_num);
create index idx_ofec_sched_e_rpt_yr_tmp on ofec_sched_e_tmp (rpt_yr);
create index idx_ofec_sched_e_filing_form_tmp on ofec_sched_e_tmp (filing_form);
create index idx_ofec_sched_e_cycle_rpt_yr_tmp on ofec_sched_e_tmp (get_cycle(rpt_yr));
create index idx_ofec_sched_e_is_notice_tmp on ofec_sched_e_tmp (is_notice);
create index idx_ofec_sched_e_pg_date_tmp on ofec_sched_e_tmp (pg_date);

-- Create composite indices on sortable columns
create index idx_ofec_sched_e_exp_dt_sub_id_tmp on ofec_sched_e_tmp (exp_dt, sub_id);
create index idx_ofec_sched_e_exp_amt_sub_id_tmp on ofec_sched_e_tmp (exp_amt, sub_id);
create index idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id_tmp on ofec_sched_e_tmp (cal_ytd_ofc_sought, sub_id);

-- Create indices on filtered fulltext columns
create index idx_ofec_sched_e_payee_name_text_tmp on ofec_sched_e_tmp using gin (payee_name_text);

-- Analyze tables
analyze ofec_sched_e_tmp;

-- Replace the existing table
drop table if exists ofec_sched_e;
alter table ofec_sched_e_tmp rename to ofec_sched_e;

-- Rename indexes
alter index ofec_sched_e_sub_id_pkey_tmp rename to ofec_sched_e_sub_id_pkey;
alter index idx_ofec_sched_e_cmte_id_tmp rename to idx_ofec_sched_e_cmte_id;
alter index idx_ofec_sched_e_s_o_cand_id_tmp rename to idx_ofec_sched_e_s_o_cand_id;
alter index idx_ofec_sched_e_entity_tp_tmp rename to idx_ofec_sched_e_entity_tp;
alter index idx_ofec_sched_e_image_num_tmp rename to idx_ofec_sched_e_image_num;
alter index idx_ofec_sched_e_rpt_yr_tmp rename to idx_ofec_sched_e_rpt_yr;
alter index idx_ofec_sched_e_filing_form_tmp rename to idx_ofec_sched_e_filing_form;
alter index idx_ofec_sched_e_cycle_rpt_yr_tmp rename to idx_ofec_sched_e_cycle_rpt_yr;
alter index idx_ofec_sched_e_is_notice_tmp rename to idx_ofec_sched_e_is_notice;
alter index idx_ofec_sched_e_pg_date_tmp rename to idx_ofec_sched_e_pg_date;
alter index idx_ofec_sched_e_exp_dt_sub_id_tmp rename to idx_ofec_sched_e_exp_dt_sub_id;
alter index idx_ofec_sched_e_exp_amt_sub_id_tmp rename to idx_ofec_sched_e_exp_amt_sub_id;
alter index idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id_tmp rename to idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id;
alter index idx_ofec_sched_e_payee_name_text_tmp rename to idx_ofec_sched_e_payee_name_text;
