
-- This materialized view is created for ticket #4988.
-- This materialized view includes committee total disbursements per cycle
-- View: public.ofec_sched_b_aggregate_recipient_mv

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_aggregate_recipient_mv;

CREATE MATERIALIZED VIEW public.ofec_sched_b_aggregate_recipient_mv
AS
SELECT sb.cmte_id,
    sb.cycle,
    sb.recipient_nm,
    sb.non_memo_total,
    sb.non_memo_count,
    sb.memo_total,
    sb.memo_count,
    sb.idx,
    v.disbursements
FROM disclosure.dsc_sched_b_aggregate_recipient_new sb
LEFT JOIN ofec_committee_totals_per_cycle_vw v ON sb.cmte_id = v.committee_id AND sb.cycle = v.cycle
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_b_aggregate_recipient_mv
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_b_aggregate_recipient_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_aggregate_recipient_mv TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_b_aggregate_recipient_mv_idx
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (idx);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_cmteid
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (cmte_id);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_cycle
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (cycle);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_nonmemocount
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (non_memo_count);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_nonmemototal
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (non_memo_total);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_recpnt_nm
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (recipient_nm);
CREATE INDEX idx_ofec_sched_b_aggregate_recipient_mv_cycle_cmte_id
    ON public.ofec_sched_b_aggregate_recipient_mv USING btree
    (cycle, cmte_id);
