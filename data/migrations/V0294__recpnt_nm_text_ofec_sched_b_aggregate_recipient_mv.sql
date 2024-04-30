/*
This migration file is for #5739

1) Add ts_vector column: recipient_text to ofec_sched_b_aggregate_recipient_mv
   Last vision: V0241
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_aggregate_recipient_mv_tmp;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_sched_b_aggregate_recipient_mv_tmp
AS
 SELECT sb.cmte_id,
    sb.cycle::numeric(4,0),
    sb.recipient_nm,
    ROUND(sb.non_memo_total, 2) AS non_memo_total,
    sb.non_memo_count,
    ROUND(sb.memo_total, 2) AS memo_total,
    sb.memo_count,
    row_number() OVER () AS idx,
    v.disbursements,
    to_tsvector(parse_fulltext(sb.recipient_nm)) AS recipient_nm_text
   FROM disclosure.dsc_sched_b_aggregate_recipient_new sb
    LEFT JOIN ofec_committee_totals_per_cycle_vw v ON sb.cmte_id = v.committee_id AND sb.cycle = v.cycle
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_b_aggregate_recipient_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_b_aggregate_recipient_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_aggregate_recipient_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_idx
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (idx);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_cmteid
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (cmte_id);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_cycle
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (cycle);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_nonmemocount
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (non_memo_count);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_nonmemototal
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (non_memo_total);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_recpnt_nm
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (recipient_nm);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_cycle_cmte_id
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING btree
    (cycle, cmte_id);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_tmp_recpnt_nm_text
    ON public.ofec_sched_b_aggregate_recipient_mv_tmp USING gin
    (recipient_nm_text );

---View has to be dropped first in order to change the data type of column: cycle
DROP VIEW IF EXISTS public.ofec_sched_b_aggregate_recipient_vw;

CREATE OR REPLACE VIEW public.ofec_sched_b_aggregate_recipient_vw AS
SELECT * FROM public.ofec_sched_b_aggregate_recipient_mv_tmp;

ALTER TABLE public.ofec_sched_b_aggregate_recipient_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_b_aggregate_recipient_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_aggregate_recipient_vw TO fec_read;

-- -------------------------
-- Drop old MV
-- -------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_aggregate_recipient_mv;

-- -------------------------
-- Rename _tmp mv to mv
-- -------------------------
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_aggregate_recipient_mv_tmp RENAME TO ofec_sched_b_aggregate_recipient_mv;

-- Rename indexes
ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_idx
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_idx;    

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_cmteid
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_cmteid;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_cycle
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_cycle;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_nonmemocount
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_nonmemocount;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_nonmemototal
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_nonmemototal;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_recpnt_nm
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_recpnt_nm;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_cycle_cmte_id
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_cycle_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_sched_b_aggregate_recipient_mv_tmp_recpnt_nm_text
RENAME TO idx_ofec_sched_b_aggregate_recipient_mv_recpnt_nm_text;
