/*
This migration file is for issue #5361. 
It creates a new view and materialized view pair for the H4 endpoint
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_h4_mv;

CREATE MATERIALIZED VIEW public.ofec_sched_h4_mv AS
SELECT h4.filer_cmte_id AS cmte_id,
h4.evt_purpose_dt AS event_purpose_date,
h4.ttl_amt_disb AS disbursement_amount,
h4.fed_share AS fed_share,
h4.nonfed_share AS nonfed_share,
h4.pye_st1 AS payee_st1,
h4.pye_st2 AS payee_st2,
h4.pye_city AS payee_city,
h4.pye_st AS payee_state,
h4.pye_zip AS payee_zip,
h4.admin_voter_drive_acty_ind AS admin_voter_drive_acty_ind,
h4.fndrsg_acty_ind AS fndrsg_acty_ind,
h4.exempt_acty_ind AS exempt_acty_ind,
h4.direct_cand_supp_acty_ind AS direct_cand_supp_acty_ind,
h4.evt_amt_ytd AS event_amount_ytd,
h4.add_desc AS activity_or_event,
h4.admin_acty_ind AS admin_acty_ind,
h4.gen_voter_drive_acty_ind AS gen_voter_drive_acty_ind,
h4.catg_cd AS catg_cd,
h4.catg_cd_desc AS catg_cd_desc,
h4.pub_comm_ref_pty_chk AS public_comm_indicator,
h4.memo_cd AS memo_cd,
h4.memo_text AS memo_text,
h4.image_num AS image_num,
h4.tran_id AS tran_id,
h4.election_cycle AS election_cycle, 
h4.rpt_tp AS rpt_tp,
h4.rpt_yr AS rpt_yr,
h4.sub_id AS sub_id,
h4.link_id AS link_id,
h4.schedule_type AS schedule_type,
h4.schedule_type_desc AS schedule_type_desc,
h4.orig_sub_id AS orig_sub_id,
h4.back_ref_tran_id AS back_ref_tran_id,
h4.back_ref_sched_id AS back_ref_sched_id,
h4.filing_form AS filing_form,
h4.line_num AS line_num,
h4.file_num AS file_num,
h4.pye_nm AS payee_name,
h4.evt_purpose_nm AS disbursement_purpose,
to_tsvector(parse_fulltext(h4.evt_purpose_nm)) as disbursement_purpose_text,
to_tsvector(parse_fulltext(h4.pye_nm)) as payee_name_text
FROM disclosure.fec_fitem_sched_h4 h4;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_h4_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_h4_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_h4_mv TO fec_read;

-- create index on the ofec_sched_h4_mv (should support sort by cmte_id, event_purpose_date, & disbursement_amount)
CREATE UNIQUE INDEX idx_ofec_sched_h4_mv_cmte_id_date_cycle_sub ON public.ofec_sched_h4_mv USING btree (cmte_id, event_purpose_date, election_cycle, sub_id);

CREATE INDEX idx_ofec_sched_h4_mv_cmte_id ON public.ofec_sched_h4_mv USING btree (cmte_id);

CREATE INDEX idx_ofec_sched_h4_mv_event_purpose_date ON public.ofec_sched_h4_mv USING btree (event_purpose_date);

CREATE INDEX idx_ofec_sched_h4_mv_cycle ON public.ofec_sched_h4_mv USING btree (election_cycle);

CREATE INDEX idx_ofec_sched_h4_mv_sub_id ON public.ofec_sched_h4_mv USING btree (sub_id);

CREATE INDEX idx_ofec_sched_h4_mv_payee_city ON public.ofec_sched_h4_mv USING btree (payee_city);

CREATE INDEX idx_ofec_sched_h4_mv_payee_state ON public.ofec_sched_h4_mv USING btree (payee_state);

CREATE INDEX idx_ofec_sched_h4_mv_payee_zip ON public.ofec_sched_h4_mv USING btree (payee_zip);

CREATE INDEX idx_ofec_sched_h4_mv_disbursement_purpose_text ON public.ofec_sched_h4_mv USING gin (disbursement_purpose);

CREATE INDEX idx_ofec_sched_h4_mv_payee_name_text ON public.ofec_sched_h4_mv USING gin (payee_name);


-- update the interface VW to point to the updated ofec_sched_h4_mv
-- ---------------
CREATE OR REPLACE VIEW public.ofec_sched_h4_vw AS
SELECT * FROM public.ofec_sched_h4_mv;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_h4_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_h4_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_h4_vw TO fec_read;
