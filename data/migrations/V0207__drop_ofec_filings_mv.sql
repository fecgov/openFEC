/*
This migration file is for issue #4478

ofec_filings_mv is an older version of ofec_filings_all_mv 

Searching webservices folder confirmed no code refrenecing this MV.

Migration file V0204 for issue #4463 had removed the last usage of this MV 
(ofec_totals_combined_mv). 

Migration file V0205 had removed its counterpart ofec_filings_vw.

It is ready to be dropped now.
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_mv;
