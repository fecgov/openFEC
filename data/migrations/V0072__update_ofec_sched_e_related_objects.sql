-- column schedule_type in public.ofec_sched_e had data type "unknown"
alter table public.ofec_sched_e alter column schedule_type set data type varchar(8);

-- table ofec_sched_e is not populated by queue process, therefore queue process related tables/functions/columns are dropped
alter table public.ofec_sched_e drop column "timestamp";

drop FUNCTION public.ofec_sched_e_f57_notice_update(); 
drop FUNCTION public.ofec_sched_e_notice_update_from_f24();
drop FUNCTION public.ofec_sched_e_update();
drop FUNCTION public.ofec_sched_e_update_from_f57();

drop FUNCTION public.ofec_sched_e_update_fulltext();
drop FUNCTION public.ofec_sched_e_update_notice_queues();

drop TRIGGER public.nml_form_24_trigger;
drop PROCEDURE public.ofec_sched_e_update_notice_queues();

drop table public.fec_vsum_f57_queue_new;
drop table public.fec_vsum_f57_queue_old;
drop table public.ofec_sched_e_queue_new;
drop table public.ofec_sched_e_queue_old;
-- 
/Users/jjeng/Projects/openFEC/data/sample_db.sql



