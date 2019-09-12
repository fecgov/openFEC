/*
This migration file is to solve issue #3908

There is a set of fec_vsum_sched_xxx, which was created in very early days of this project. 
We have tables (disclosure.fec_fitem_sched_xxx) that better suits the needs. 
This set of views need to be dropped for 
1) better maintenance 
2) to prevent people use it by mistake.

public.fec_fitem_f76_vw is currently been used by the following two MVs:
ofec_communication_cost_aggregate_candidate_mv
ofec_communication_cost_mv

Those two depending MVs will to be 
redefined to use the more accurate table disclosure.fec_fitem_f76
Then public.fec_fitem_f76_vw will be dropped. 

*/

-- ------------------------------------------------
-- ofec_communication_cost_aggregate_candidate_mv
-- ------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_communication_cost_aggregate_candidate_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_communication_cost_aggregate_candidate_mv_tmp AS 
 SELECT row_number() OVER () AS idx,
    f76.s_o_ind AS support_oppose_indicator,
    f76.org_id AS cmte_id,
    f76.s_o_cand_id AS cand_id,
    sum(f76.communication_cost) AS total,
    count(f76.communication_cost) AS count,
    date_part('year'::text, f76.communication_dt)::integer + date_part('year'::text, f76.communication_dt)::integer % 2 AS cycle
   FROM disclosure.fec_fitem_f76 as f76
  WHERE date_part('year'::text, f76.communication_dt) >= 1979::double precision AND f76.s_o_cand_id IS NOT NULL
  GROUP BY f76.org_id, f76.s_o_cand_id, f76.s_o_ind, (date_part('year'::text, f76.communication_dt)::integer + date_part('year'::text, f76.communication_dt)::integer % 2)
WITH DATA;

ALTER TABLE public.ofec_communication_cost_aggregate_candidate_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_communication_cost_aggregate_candidate_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_communication_cost_aggregate_candidate_mv_tmp TO fec_read;

-- indexes
CREATE UNIQUE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_idx
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (idx);

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_s_o_ind
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (support_oppose_indicator COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cand_id
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cmte_id
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_count
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (count);

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cycle
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (cycle);

CREATE INDEX idx_ofec_communication_cost_aggregate_candidate_mv_tmp_total
  ON public.ofec_communication_cost_aggregate_candidate_mv_tmp
  USING btree
  (total);

-- point view to the tmp mv
CREATE OR REPLACE VIEW public.ofec_communication_cost_aggregate_candidate_vw AS 
 SELECT * FROM ofec_communication_cost_aggregate_candidate_mv_tmp;

ALTER TABLE public.ofec_communication_cost_aggregate_candidate_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_communication_cost_aggregate_candidate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_communication_cost_aggregate_candidate_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_communication_cost_aggregate_candidate_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW public.ofec_communication_cost_aggregate_candidate_mv_tmp RENAME TO ofec_communication_cost_aggregate_candidate_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_idx RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_idx;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_s_o_ind RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_s_o_ind;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cand_id RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cmte_id RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_count RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_count;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_cycle RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_cycle;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_aggregate_candidate_mv_tmp_total RENAME TO idx_ofec_communication_cost_aggregate_candidate_mv_total;

/*
SELECT f76.s_o_ind AS support_oppose_indicator,
f76.org_id AS cmte_id,
f76.s_o_cand_id AS cand_id,
sum(f76.communication_cost) AS total,
count(f76.communication_cost) AS count,
date_part('year'::text, f76.communication_dt)::integer + date_part('year'::text, f76.communication_dt)::integer % 2 AS cycle
FROM disclosure.fec_fitem_f76 as f76
WHERE date_part('year'::text, f76.communication_dt) >= 1979::double precision AND f76.s_o_cand_id IS NOT NULL
GROUP BY f76.org_id, f76.s_o_cand_id, f76.s_o_ind, (date_part('year'::text, f76.communication_dt)::integer + date_part('year'::text, f76.communication_dt)::integer % 2)
except 
select support_oppose_indicator,
cmte_id,
cand_id,
total,
count,
cycle
FROM public.ofec_communication_cost_aggregate_candidate_mv
*/

-- ------------------------------------------------
-- ofec_communication_cost_mv
--
-- data type for column schedule_type in public.fec_fitem_f76_vw is undefined.
-- data type for column schedule_type in disclosure.fec_fitem_f76 is varchar(8)
-- In openFEC/webservices/common/models/costs.py, schedule_type is defined as String, therefore will not cause problem
-- ------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_communication_cost_mv_tmp;
CREATE MATERIALIZED VIEW public.ofec_communication_cost_mv_tmp AS 
 WITH com_names AS (
         SELECT DISTINCT ON (ofec_committee_history_vw.committee_id) ofec_committee_history_vw.committee_id,
            ofec_committee_history_vw.name AS committee_name
           FROM ofec_committee_history_vw
          ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC
        )
 SELECT f76.org_id,
    f76.communication_tp,
    f76.communication_tp_desc,
    f76.communication_class,
    f76.communication_class_desc,
    f76.communication_dt,
    f76.s_o_ind,
    f76.s_o_ind_desc,
    f76.s_o_cand_id,
    f76.s_o_cand_nm,
    f76.s_o_cand_l_nm,
    f76.s_o_cand_f_nm,
    f76.s_o_cand_m_nm,
    f76.s_o_cand_prefix,
    f76.s_o_cand_suffix,
    f76.s_o_cand_office,
    f76.s_o_cand_office_desc,
    f76.s_o_cand_office_st,
    f76.s_o_cand_office_st_desc,
    f76.s_o_cand_office_district,
    f76.s_o_rpt_pgi,
    f76.s_o_rpt_pgi_desc,
    f76.communication_cost,
    f76.election_other_desc,
    f76.transaction_tp,
    f76.action_cd,
    f76.action_cd_desc,
    f76.tran_id,
    f76.schedule_type,
    f76.schedule_type_desc,
    f76.image_num,
    f76.file_num,
    f76.link_id,
    f76.orig_sub_id,
    f76.sub_id,
    f76.filing_form,
    f76.rpt_tp,
    f76.rpt_yr,
    f76.election_cycle,
    f76.s_o_cand_id AS cand_id,
    f76.org_id AS cmte_id,
    com_names.committee_name,
    report_pdf_url(f76.image_num::text) AS pdf_url
   FROM disclosure.fec_fitem_f76 f76
     LEFT JOIN com_names ON f76.org_id::text = com_names.committee_id::text
  WHERE date_part('year'::text, f76.communication_dt)::integer >= 1979
WITH DATA;

ALTER TABLE public.ofec_communication_cost_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_communication_cost_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_communication_cost_mv_tmp TO fec_read;

-- --------------
-- recreate the view
-- data type for column schedule_type in public.fec_fitem_f76_vw is undefined.
-- data type for column schedule_type in disclosure.fec_fitem_f76 is varchar(8)
-- can not repoint the view to the tmp MV with "CREATE OR REPLACE"
-- Need to DROP and CREATE
-- Since public.ofec_communication_cost_vw had no depending objects, it can be dropped and created without chain reaction
DROP VIEW public.ofec_communication_cost_vw;

CREATE OR REPLACE VIEW public.ofec_communication_cost_vw AS 
 SELECT * FROM ofec_communication_cost_mv_tmp;

ALTER TABLE public.ofec_communication_cost_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_communication_cost_vw TO fec;
GRANT SELECT ON TABLE public.ofec_communication_cost_vw TO fec_read;
-- --------------

-- indexes
CREATE UNIQUE INDEX idx_ofec_communication_cost_mv_tmp_sub_id
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (sub_id);

CREATE INDEX idx_ofec_communication_cost_mv_tmp_cand_id
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_cmte_id
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_comm_class
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (communication_class COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_comm_cost
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (communication_cost);

CREATE INDEX idx_ofec_communication_cost_mv_tmp_comm_dt
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (communication_dt);

CREATE INDEX idx_ofec_communication_cost_mv_tmp_comm_tp
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (communication_tp COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_filing_form
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (filing_form COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_image_num
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (image_num COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_s_o_cand_office_dist
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (s_o_cand_office_district COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_s_o_cand_office
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (s_o_cand_office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_s_o_cand_office_st
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (s_o_cand_office_st COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_communication_cost_mv_tmp_s_o_ind
  ON public.ofec_communication_cost_mv_tmp
  USING btree
  (s_o_ind COLLATE pg_catalog."default");


-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_communication_cost_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW public.ofec_communication_cost_mv_tmp RENAME TO ofec_communication_cost_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_sub_id RENAME TO idx_ofec_communication_cost_mv_sub_id;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_cand_id RENAME TO idx_ofec_communication_cost_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_cmte_id RENAME TO idx_ofec_communication_cost_mv_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_comm_class RENAME TO idx_ofec_communication_cost_mv_comm_class;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_comm_cost RENAME TO idx_ofec_communication_cost_mv_comm_cost;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_comm_dt RENAME TO idx_ofec_communication_cost_mv_comm_dt;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_comm_tp RENAME TO idx_ofec_communication_cost_mv_comm_tp;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_filing_form RENAME TO idx_ofec_communication_cost_mv_filing_form;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_image_num RENAME TO idx_ofec_communication_cost_mv_image_num;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_s_o_cand_office_dist RENAME TO idx_ofec_communication_cost_mv_s_o_cand_office_dist;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_s_o_cand_office RENAME TO idx_ofec_communication_cost_mv_s_o_cand_office;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_s_o_cand_office_st RENAME TO idx_ofec_communication_cost_mv_s_o_cand_office_st;

ALTER INDEX IF EXISTS idx_ofec_communication_cost_mv_tmp_s_o_ind RENAME TO idx_ofec_communication_cost_mv_s_o_ind;

-- --------------
DROP VIEW IF EXISTS public.fec_fitem_f76_vw;
-- --------------
