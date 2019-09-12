/*
This migration file is to solve issue #3908

There is a set of fec_vsum_sched_xxx, which was created in very early days of this project. 
We have tables (disclosure.fec_fitem_sched_xxx) that better suits the needs. 
This set of views need to be dropped for 
1) better maintenance 
2) to prevent people use it by mistake.
*/

DROP VIEW IF EXISTS public.fec_vsum_sched_a_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_b_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_c1_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_c2_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_c_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_d_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_e_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_f_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h1_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h2_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h3_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h4_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h5_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_h6_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_i_vw;
DROP VIEW IF EXISTS public.fec_vsum_sched_l_vw;

DROP VIEW IF EXISTS public.fec_vsum_f105_vw;
DROP VIEW IF EXISTS public.fec_vsum_f56_vw;
DROP VIEW IF EXISTS public.fec_vsum_f57_vw;
DROP VIEW IF EXISTS public.fec_vsum_f76_vw;
DROP VIEW IF EXISTS public.fec_vsum_f91_vw;
DROP VIEW IF EXISTS public.fec_vsum_f94_vw;