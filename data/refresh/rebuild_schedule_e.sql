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

ALTER TABLE public.ofec_sched_e_tmp
  OWNER TO fec;
GRANT SELECT ON TABLE public.ofec_sched_e_tmp TO fec_read;

-- Add in records from the Schedule E notices view
insert into ofec_sched_e_tmp
select *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice,
    to_tsvector(pye_nm) as payee_name_text,
    now() as pg_date
from fec_sched_e_notice_vw;

update ofec_sched_e_tmp
set exp_dt = coalesce(exp_dt, dissem_dt);

-- Add in records for the Form 5 filings
insert into ofec_sched_e_tmp (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,
                              pye_st1, pye_st2, pye_city, pye_st, pye_zip, entity_tp, entity_tp_desc, exp_desc,
                              catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first, s_o_cand_nm_last,
                              s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
                              s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district,
                              s_o_ind, s_o_ind_desc, election_tp, fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt,
                              exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm, conduit_cmte_st1,
                              conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
                              action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id,
                              orig_sub_id, sub_id, filing_form, rpt_tp, rpt_yr, election_cycle, timestamp,
                              pdf_url, is_notice, payee_name_text, pg_date)
select filer_cmte_id, pye_nm, pye_l_nm, pye_f_nm, pye_m_nm, pye_prefix, pye_suffix, pye_st1, pye_st2, pye_city, pye_st,
    pye_zip, entity_tp, entity_tp_desc, exp_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_f_nm,
    s_o_cand_l_nm, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
    s_o_cand_office_st, s_o_cand_office_state_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
    fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
    conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
    tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, filing_form,
    rpt_tp, rpt_yr, election_cycle, cast(null as timestamp) as timestamp, image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice, to_tsvector(pye_nm), now()
from fec_fitem_f57_vw;


insert into ofec_sched_e_tmp (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,
                              pye_st1, pye_st2, pye_city, pye_st, pye_zip, entity_tp, entity_tp_desc, exp_desc,
                              catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first, s_o_cand_nm_last,
                              s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
                              s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district,
                              s_o_ind, s_o_ind_desc, election_tp, fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt,
                              exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm, conduit_cmte_st1,
                              conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
                              action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id,
                              orig_sub_id, sub_id, filing_form, rpt_tp, rpt_yr, election_cycle, timestamp,
                              pdf_url, is_notice, payee_name_text, pg_date)
select filer_cmte_id, pye_nm, pye_l_nm, pye_f_nm, pye_m_nm, pye_prefix, pye_suffix, pye_st1, pye_st2, pye_city, pye_st,
    pye_zip, entity_tp, entity_tp_desc, exp_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_f_nm,
    s_o_cand_l_nm, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
    s_o_cand_office_st, s_o_cand_office_state_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
    fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
    conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
    action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id,
    filing_form, rpt_tp, rpt_yr, cycle, cast(null as timestamp) as timestamp, image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice, to_tsvector(pye_nm), now()
from fec_f57_notice_vw;

-- Reset the exp_dt column based on actual dates available in the data.
update ofec_sched_e_tmp set exp_dt = coalesce(exp_dt, dissem_dt);

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

-- Analyze the table
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
