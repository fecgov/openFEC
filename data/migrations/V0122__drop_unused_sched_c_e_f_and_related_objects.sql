-- ---------------------------------------------
--  This migration file is part of issue #3100
-- ---------------------------------------------

-- MV should be removed from flow.py and manage.py
DROP VIEW IF EXISTS public.ofec_sched_c_vw;
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_c_mv;

-- MV should be removed from flow.py and manage.py
DROP VIEW IF EXISTS public.ofec_sched_f_vw;
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_f_mv;

-- openFEC/data/refresh/rebuild_schedule_e.sql file should also be removed.  Otherwise this table will keep coming back.
-- scheduled job that run the openFEC/data/refresh/rebuild_schedule_e.sql should also be removed.
-- in manage.py, the refresh_itemized() and rebuild_itemized_e() are dropped.
DROP TABLE IF EXISTS public.ofec_sched_e;


-- these 20 views were created BEFORE their counterpart disclosure.fec_fitem_sched_xxxxx tables had been created/refreshed.  They are no longer needed and should be dropped to avoid confusion to the developers.
DROP VIEW IF EXISTS public.fec_fitem_f56_vw;
DROP VIEW IF EXISTS public.fec_fitem_f57_vw;
--DROP VIEW IF EXISTS public.fec_fitem_f76_vw;
DROP VIEW IF EXISTS public.fec_fitem_f91_vw;
DROP VIEW IF EXISTS public.fec_fitem_f94_vw;
DROP VIEW IF EXISTS public.fec_fitem_f105_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_a_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_b_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_c_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_c1_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_c2_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_d_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_e_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_f_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h1_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h2_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h3_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h4_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h5_vw;
DROP VIEW IF EXISTS public.fec_fitem_sched_h6_vw;

--
DROP TRIGGER IF EXISTS ofec_f57_trigger on disclosure.nml_form_57; 

-- these trigger functions are not being used.
DROP FUNCTION public.fec_vsum_f57_update_queues();
DROP FUNCTION public.ofec_f57_update_notice_queues();
DROP FUNCTION public.ofec_sched_c_update();
DROP FUNCTION public.ofec_sched_e_update_queues();

-- 
DROP TRIGGER IF EXISTS ofec_sched_d_queue_trigger ON disclosure.nml_sched_d;
DROP FUNCTION public.ofec_sched_d_update();
ALTER TABLE disclosure.nml_sched_d DROP COLUMN creditor_debtor_name_text;

-- these queue tables are not used
DROP TABLE IF EXISTS public.ofec_nml_24_queue_new;
DROP TABLE IF EXISTS public.ofec_nml_24_queue_old;
DROP TABLE IF EXISTS public.ofec_f57_queue_old;
DROP TABLE IF EXISTS public.ofec_f57_queue_new;

-- -------------------------------
--  This three sequences are for the original sched_b_aggregate tables.  The three tables had been dropped so these three sequences are not needed anymore
-- -------------------------------
DROP SEQUENCE IF EXISTS public.ofec_sched_b_aggregate_purpose_idx_seq1;

DROP SEQUENCE IF EXISTS public.ofec_sched_b_aggregate_recipient_idx_seq1;

DROP SEQUENCE IF EXISTS public.ofec_sched_b_aggregate_recipient_id_idx_seq1;

-- sample_db.sql need to be updated to remove/update changed tables/columns
