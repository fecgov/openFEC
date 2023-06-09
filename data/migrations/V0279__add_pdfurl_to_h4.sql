/*
This migration file is for issue #5364. 
It adds pdf_url to the H4 endpoint
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_h4_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_h4_mv_tmp AS
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
to_tsvector(parse_fulltext(h4.pye_nm)) as payee_name_text,
cmte.cmte_nm AS cmte_nm,
cmte.cmte_tp AS cmte_tp,
cmte.cmte_dsgn AS cmte_dsgn,
image_pdf_url(h4.image_num) as pdf_url
FROM disclosure.fec_fitem_sched_h4 h4
LEFT OUTER JOIN disclosure.cmte_valid_fec_yr cmte
ON h4.filer_cmte_id = cmte.cmte_id AND h4.election_cycle = cmte.fec_election_yr;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_h4_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_h4_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_h4_mv_tmp TO fec_read;

-- create indexes on the ofec_sched_h4_mv 
CREATE UNIQUE INDEX idx_ofec_sched_h4_mv_tmp_sub_id_date_amount ON public.ofec_sched_h4_mv_tmp USING btree (sub_id, event_purpose_date, disbursement_amount);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_cmte_id ON public.ofec_sched_h4_mv_tmp USING btree (cmte_id);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_cmte_nm ON public.ofec_sched_h4_mv_tmp USING btree (cmte_nm);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_cmte_tp ON public.ofec_sched_h4_mv_tmp USING btree (cmte_tp);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_cmte_dsgn ON public.ofec_sched_h4_mv_tmp USING btree (cmte_dsgn);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_event_purpose_date ON public.ofec_sched_h4_mv_tmp USING btree (event_purpose_date);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_disbursement_amount ON public.ofec_sched_h4_mv_tmp USING btree (disbursement_amount);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_cycle ON public.ofec_sched_h4_mv_tmp USING btree (election_cycle);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_sub_id ON public.ofec_sched_h4_mv_tmp USING btree (sub_id);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_payee_city ON public.ofec_sched_h4_mv_tmp USING btree (payee_city);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_payee_state ON public.ofec_sched_h4_mv_tmp USING btree (payee_state);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_payee_zip ON public.ofec_sched_h4_mv_tmp USING btree (payee_zip);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_disbursement_purpose ON public.ofec_sched_h4_mv_tmp USING btree (disbursement_purpose);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_disbursement_purpose_text ON public.ofec_sched_h4_mv_tmp USING gin (disbursement_purpose_text);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_payee_name ON public.ofec_sched_h4_mv_tmp USING btree (payee_name);

CREATE INDEX idx_ofec_sched_h4_mv_tmp_payee_name_text ON public.ofec_sched_h4_mv_tmp USING gin (payee_name_text);


-- update the interface VW to point to the updated ofec_sched_h4_mv
-- ---------------
CREATE OR REPLACE VIEW public.ofec_sched_h4_vw AS
SELECT * FROM public.ofec_sched_h4_mv_tmp;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_h4_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_h4_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_h4_vw TO fec_read;

--rename
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_h4_mv;
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_h4_mv_tmp RENAME TO ofec_sched_h4_mv;

-- create index on the ofec_sched_h4_mv (should support sort by sub_id, event_purpose_date, & disbursement_amount)
ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_sub_id_date_amount RENAME TO idx_ofec_sched_h4_mv_sub_id_date_amount;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_cmte_id RENAME TO idx_ofec_sched_h4_mv_cmte_id;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_cmte_nm RENAME TO idx_ofec_sched_h4_mv_cmte_nm;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_cmte_tp RENAME TO idx_ofec_sched_h4_mv_cmte_tp;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_cmte_dsgn RENAME TO idx_ofec_sched_h4_mv_cmte_dsgn;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_event_purpose_date RENAME TO idx_ofec_sched_h4_mv_event_purpose_date ;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_disbursement_amount RENAME TO idx_ofec_sched_h4_mv_disbursement_amount;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_cycle RENAME TO idx_ofec_sched_h4_mv_cycle;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_sub_id RENAME TO idx_ofec_sched_h4_mv_sub_id;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_payee_city RENAME TO idx_ofec_sched_h4_mv_payee_city;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_payee_state RENAME TO idx_ofec_sched_h4_mv_payee_state;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_payee_zip RENAME TO idx_ofec_sched_h4_mv_payee_zip;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_disbursement_purpose RENAME TO idx_ofec_sched_h4_mv_disbursement_purpose;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_disbursement_purpose_text RENAME TO idx_ofec_sched_h4_mv_disbursement_purpose_text;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_payee_name RENAME TO idx_ofec_sched_h4_mv_payee_name;

ALTER INDEX public.idx_ofec_sched_h4_mv_tmp_payee_name_text RENAME TO idx_ofec_sched_h4_mv_payee_name_text;
