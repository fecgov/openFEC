/*
Addresses issue #3399
public.ofec_entity_chart_mv, and ofec_entity_chart_vw are not used by by line chart anymore and can be dropped
*/

SET search_path = public, pg_catalog;

DROP VIEW ofec_entity_chart_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_entity_chart_mv;
