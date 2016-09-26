-- Create Schedule E table
drop table if exists ofec_sched_e_tmp;
create table ofec_sched_e_tmp as
select
    *,
    cast(null as timestamp) as timestamp,
    image_pdf_url(image_num) as pdf_url,
    coalesce(rpt_tp, '') in ('24', '48') as is_notice,
    to_tsvector(pye_nm) as payee_name_text
from fec_vsum_sched_e;

insert into ofec_sched_e_tmp (cmte_id, pye_nm, payee_l_nm, payee_f_nm,payee_m_nm, payee_prefix, payee_suffix,
                              pye_st1, pye_st2, pye_city, pye_st, pye_zip, entity_tp, entity_tp_desc, exp_desc,
                              catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first, s_o_cand_nm_last,
                              s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
                              s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district,
                              s_o_ind, s_o_ind_desc, election_tp, fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt,
                              exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm, conduit_cmte_st1,
                              conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
                              action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id,
                              orig_sub_id, sub_id, filing_form, pg_date, rpt_tp, rpt_yr, election_cycle, timestamp,
                              pdf_url, is_notice, payee_name_text)
select filer_cmte_id, pye_nm, pye_l_nm, pye_f_nm, pye_m_nm, pye_prefix, pye_suffix,pye_st1, pye_st2, pye_city, pye_st,
    pye_zip, entity_tp, entity_tp_desc, exp_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_f_nm,
    s_o_cand_l_nm, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
    s_o_cand_office_st, s_o_cand_office_state_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
    fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
    conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
    tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, filing_form, pg_date,
    rpt_tp, rpt_yr, election_cycle, cast(null as timestamp) as TIMESTAMP, image_pdf_url(image_num) as pdf_url, False,
    to_tsvector(pye_nm)
from fec_vsum_f57;

drop table if exists ofec_sched_e_notice_tmp;
create table ofec_sched_e_notice_tmp(like ofec_sched_e_tmp);

insert into ofec_sched_e_notice_tmp(cmte_id, pye_nm, payee_l_nm, payee_f_nm,payee_m_nm, payee_prefix, payee_suffix,
                              pye_st1, pye_st2, pye_city, pye_st, pye_zip, entity_tp, entity_tp_desc, exp_desc,
                              catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first, s_o_cand_nm_last,
                              s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
                              s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district,
                              s_o_ind, s_o_ind_desc, election_tp, fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt,
                              exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm, conduit_cmte_st1,
                              conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
                              action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id,
                              orig_sub_id, sub_id, filing_form, pg_date, rpt_tp, rpt_yr, election_cycle, timestamp,
                              pdf_url, is_notice, payee_name_text)
select cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
    pye_zip, entity_tp, entity_tp_desc, exp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
    s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
    s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
    fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
    conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
    tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, filing_form, cast(null as timestamp) as pg_date,
    rpt_tp, rpt_yr, cycle, cast(null as timestamp) as TIMESTAMP, image_pdf_url(image_num) as pdf_url, True,
    to_tsvector(pye_nm)
from fec_sched_e_notice_vw;

insert into ofec_sched_e_notice_tmp(cmte_id, pye_nm, payee_l_nm, payee_f_nm,payee_m_nm, payee_prefix, payee_suffix,
                              pye_st1, pye_st2, pye_city, pye_st, pye_zip, entity_tp, entity_tp_desc, exp_desc,
                              catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first, s_o_cand_nm_last,
                              s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
                              s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district,
                              s_o_ind, s_o_ind_desc, election_tp, fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt,
                              exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm, conduit_cmte_st1,
                              conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd,
                              action_cd_desc, tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id,
                              orig_sub_id, sub_id, filing_form, pg_date, rpt_tp, rpt_yr, election_cycle, timestamp,
                              pdf_url, is_notice, payee_name_text)
select filer_cmte_id, pye_nm, pye_l_nm, pye_f_nm, pye_m_nm, pye_prefix, pye_suffix,pye_st1, pye_st2, pye_city, pye_st,
    pye_zip, entity_tp, entity_tp_desc, exp_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_f_nm,
    s_o_cand_l_nm, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
    s_o_cand_office_st, s_o_cand_office_state_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
    fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
    conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
    tran_id, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, filing_form, cast(null as timestamp) as pg_date,
    rpt_tp, rpt_yr, cycle, cast(null as timestamp) as TIMESTAMP, image_pdf_url(image_num) as pdf_url, False,
    to_tsvector(pye_nm)
from fec_f57_notice_vw;

alter table ofec_sched_e_tmp add primary key (sub_id);

-- Create simple indices on filtered columns
create index on ofec_sched_e_tmp (cmte_id);
create index on ofec_sched_e_tmp (s_o_cand_id);
create index on ofec_sched_e_tmp (entity_tp);
create index on ofec_sched_e_tmp (image_num);
create index on ofec_sched_e_tmp (rpt_yr);
create index on ofec_sched_e_tmp (filing_form);
create index on ofec_sched_e_tmp (get_cycle(rpt_yr));
create index on ofec_sched_e_tmp (is_notice);

-- Create composite indices on sortable columns
create index on ofec_sched_e_tmp (exp_dt, sub_id);
create index on ofec_sched_e_tmp (exp_amt, sub_id);
create index on ofec_sched_e_tmp (cal_ytd_ofc_sought, sub_id);

-- Create indices on filtered fulltext columns
create index on ofec_sched_e_tmp using gin (payee_name_text);

-- Analyze tables
analyze ofec_sched_e_tmp;

-- Create queue tables to hold changes to Schedule E
drop table if exists ofec_sched_e_queue_new;
drop table if exists ofec_sched_e_queue_old;
drop table if exists ofec_nml_24_queue_new;
drop table if exists ofec_nml_24_queue_old;
drop table if exists ofec_f57_queue_old;
drop table if exists ofec_f57_queue_new;
--drop table if exists ofec_nml_sched_e_new;
--drop table if exists ofec_nml_sched_e_old;

create table ofec_nml_24_queue_new as select * from disclosure.nml_form_24 limit 0;
create table ofec_nml_24_queue_old as select * from disclosure.nml_form_24 limit 0;
create table ofec_f57_queue_old as select * from disclosure.nml_form_57 limit 0;
create table ofec_f57_queue_new as select * from disclosure.nml_form_57 limit 0;
--create table ofec_nml_sched_e_queue_new as select * from disclosure.nml_sched_e limit 0;
--create table ofec_nml_sched_e_queue_old as select * from disclosure.nml_sched_e limit 0;
create table ofec_sched_e_queue_new as select * from fec_vsum_sched_e limit 0;
create table ofec_sched_e_queue_old as select * from fec_vsum_sched_e limit 0;

alter table ofec_sched_e_queue_new add column timestamp timestamp;
alter table ofec_sched_e_queue_old add column timestamp timestamp;
create index on ofec_sched_e_queue_new (sub_id);
create index on ofec_sched_e_queue_old (sub_id);
create index on ofec_sched_e_queue_new (timestamp);
create index on ofec_sched_e_queue_old (timestamp);

-- Create trigger to maintain Schedule E queues
create or replace function ofec_sched_e_update_queues() returns trigger as $$
declare
    start_year int = TG_ARGV[0]::int;
begin
    if tg_op = 'INSERT' then
        delete from ofec_sched_e_queue_new where sub_id = new.sub_id;
        insert into ofec_sched_e_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_sched_e_queue_new where sub_id = new.sub_id;
        delete from ofec_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_sched_e_queue_new values (new.*);
        insert into ofec_sched_e_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_sched_e_queue_old where sub_id = old.sub_id;
        insert into ofec_sched_e_queue_old values (old.*);
        return old;
    end if;
end
$$ language plpgsql;

create or replace function ofec_sched_e_update_notice_queues() returns trigger as $$
begin

    if tg_op = 'INSERT' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_nml_24_queue_new where sub_id = new.sub_id;
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_new values (new.*);
        insert into ofec_nml_24_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_nml_24_queue_old where sub_id = old.sub_id;
        insert into ofec_nml_24_queue_old values (old.*);
        return old;
    end if;
end
$$ language plpgsql;

create or replace function ofec_f57_update_notice_queues() returns trigger as $$
begin

    if tg_op = 'INSERT' then
        delete from ofec_f57_queue_new where sub_id = new.sub_id;
        insert into ofec_f57_queue_new values (new.*);
        return new;
    elsif tg_op = 'UPDATE' then
        delete from ofec_f57_queue_new where sub_id = new.sub_id;
        delete from ofec_f57_queue_old where sub_id = old.sub_id;
        insert into ofec_f57_queue_new values (new.*);
        insert into ofec_f57_queue_old values (old.*);
        return new;
    elsif tg_op = 'DELETE' then
        delete from ofec_f57_queue_old where sub_id = old.sub_id;
        insert into ofec_f57_queue_old values (old.*);
        return old;
    end if;
end
$$ language plpgsql;

drop trigger if exists ofec_sched_e_queue_trigger on sched_e;
create trigger ofec_sched_e_queue_trigger before insert or update or delete
    on sched_e for each row execute procedure ofec_sched_e_update_queues(:START_YEAR_AGGREGATE)
;

drop trigger if exists nml_form_24_trigger on disclosure.nml_form_24;
create trigger nml_form_24_trigger before insert or update or delete
    on disclosure.nml_form_24 for each row execute procedure ofec_sched_e_update_notice_queues()
;

drop trigger if exists ofec_f57_trigger on disclosure.nml_form_57;
create trigger ofec_f57_trigger before insert or update or delete
    on disclosure.nml_form_57 for each row execute procedure ofec_f57_update_notice_queues()
;

drop table if exists ofec_sched_e;
alter table ofec_sched_e_tmp rename to ofec_sched_e;

drop table if exists ofec_sched_e_notice;
alter table ofec_sched_e_notice_tmp rename to ofec_sched_e_notice;
