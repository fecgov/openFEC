/*
This migration file is to solve https://github.com/fecgov/openFEC/issues/3866

All below database objects are not being used anymore, so can be dropped.
  
  public.ofec_report_pac_party_all_vw
  public.ofec_report_pac_party_all_mv
  public.ofec_reports_pacs_parties_vw
  public.ofec_reports_pacs_parties_mv
*/


DROP VIEW IF EXISTS public.ofec_report_pac_party_all_vw;

DROP VIEW IF EXISTS public.ofec_reports_pacs_parties_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_report_pac_party_all_mv;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_reports_pacs_parties_mv;

/* 
When a new object is created, if the owner is not specified, the owner will be whoever 
execute the create script (in this case, the new "migrator").  
And need to explicitly specify the owner grant needed privileges
*/

ALTER VIEW public.ofec_reports_pac_party_vw OWNER TO fec;

GRANT SELECT ON public.ofec_reports_pac_party_vw TO fec_read;
