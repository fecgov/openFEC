/*
This migration file is to solve issue #4245

The below two database objects are replaced by 
ofec_totals_pac_party_vw

and we can drop the mv/view that are not being used anymore
*/

DROP VIEW IF EXISTS public.ofec_totals_pacs_parties_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_pacs_parties_mv; 