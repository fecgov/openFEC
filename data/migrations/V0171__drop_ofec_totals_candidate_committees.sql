/*
This migration file is to solve issue #3928

The below two database objects are replaced by 
ofec_candidate_totals_detail_mv
ofec_candidate_totals_detail_vw

and we can drop the unused ones
*/

DROP VIEW IF EXISTS public.ofec_totals_candidate_committees_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_candidate_committees_mv; 
