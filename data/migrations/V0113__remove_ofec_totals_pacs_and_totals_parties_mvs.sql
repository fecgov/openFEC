SET search_path = public, pg_catalog;

-- The following two MVs are logically depending on public.ofec_totals_pacs_parties_mv.  
-- public.ofec_totals_parties_mv;
-- public.ofec_totals_pacs_mv;
-- however, they only select from ofec_totals_pacs_parties_mv with simple filter
-- therefore, a simple view should be enough, no need for MVs for them.

-- later research reveals that the two models using these two views are not necessary.  So both views and MVs can be deleted.

-- --------------------------
DROP VIEW IF EXISTS public.ofec_totals_pacs_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_pacs_mv;

-- ----------------------------
-- ----------------------------
DROP VIEW IF EXISTS public.ofec_totals_parties_vw;

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_parties_mv;
