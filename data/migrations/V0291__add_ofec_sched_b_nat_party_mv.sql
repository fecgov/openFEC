-- View: public.ofec_sched_b_nat_party_mv_tmp_hc

-- DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_nat_party_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_sched_b_nat_party_mv
AS
 SELECT sb.cmte_id,
    v.name AS cmte_nm,
    v.committee_type,
    v.committee_type_full,
    v.designation,
    v.designation_full,
    v.organization_type,
    v.organization_type_full,
    v.party,
    v.party_full,
    v.filing_frequency,
    v.is_active,
    v.state,
    v.state_full,
    v.treasurer_name,
    sb.recipient_cmte_id,
    sb.recipient_nm,
    sb.payee_l_nm,
    sb.payee_f_nm,
    sb.payee_m_nm,
    sb.payee_prefix,
    sb.payee_suffix,
    sb.payee_employer,
    sb.payee_occupation,
    sb.recipient_st1,
    sb.recipient_st2,
    sb.recipient_city,
    sb.recipient_st,
    sb.recipient_zip,
    sb.disb_desc,
    sb.catg_cd,
    sb.catg_cd_desc,
    sb.entity_tp,
    sb.entity_tp_desc,
    v1.name AS cmte_as_recipient,
    sb.election_tp,
    sb.fec_election_tp_desc,
    sb.fec_election_tp_year,
    sb.election_tp_desc,
    sb.cand_id,
    sb.cand_nm,
    sb.cand_nm_first,
    sb.cand_nm_last,
    sb.cand_m_nm,
    sb.cand_prefix,
    sb.cand_suffix,
    sb.cand_office,
    sb.cand_office_desc,
    sb.cand_office_st,
    sb.cand_office_st_desc,
    sb.cand_office_district,
    sb.disb_dt,
    sb.disb_amt,
    sb.memo_cd,
    sb.memo_cd_desc,
    sb.memo_text,
    sb.disb_tp,
    sb.disb_tp_desc,
    sb.conduit_cmte_nm,
    sb.conduit_cmte_st1,
    sb.conduit_cmte_st2,
    sb.conduit_cmte_city,
    sb.conduit_cmte_st,
    sb.conduit_cmte_zip,
    sb.national_cmte_nonfed_acct,
    sb.ref_disp_excess_flg,
    sb.comm_dt,
    sb.benef_cmte_nm,
    sb.semi_an_bundled_refund,
    sb.action_cd,
    sb.action_cd_desc,
    sb.tran_id,
    sb.back_ref_tran_id,
    sb.back_ref_sched_id,
    sb.schedule_type,
    sb.schedule_type_desc,
    sb.line_num,
    sb.image_num,
    sb.file_num,
    sb.link_id,
    sb.orig_sub_id,
    sb.sub_id,
    sb.filing_form,
    sb.rpt_tp,
    sb.rpt_yr,
    sb.two_year_transaction_period,
    sb.pdf_url,
    sb.recipient_name_text,
    sb.disbursement_description_text,
    sb.disbursement_purpose_category,
    sb.clean_recipient_cmte_id,
    sb.line_number_label,
    sb.cmte_tp,
    sb.org_tp,
    sb.cmte_dsgn,
    CASE
        WHEN sb.disb_tp IN ('40', '40T', '40Y', '40Z') THEN 'CONVENTION ACCOUNT'
        WHEN sb.disb_tp IN ('41', '41T', '41Y', '41Z') THEN 'HEADQUARTERS ACCOUNT'
        WHEN sb.disb_tp IN ('42', '42T', '42Y', '42Z') THEN 'RECOUNT ACCOUNT'
        ELSE 'UNKNOWN'
    END AS party_account,
    v1.committee_type AS cmte_as_recipient_type,
    v1.committee_type_full AS cmte_as_recipient_type_full,
    v1.designation AS cmte_as_recipient_desgn,
    v1.designation_full AS cmte_as_recipient_desgn_full,
    v1.organization_type AS cmte_as_recipient_org,
    v1.organization_type_full AS cmte_as_recipient_org_full,
    v1.state AS cmte_as_recipient_state,
    v1.state_full AS cmte_as_recipient_state_full,
    v1.party AS cmte_as_recipient_party,
    v1.party_full AS cmte_as_recipient_party_full
   FROM disclosure.fec_fitem_sched_b sb
     LEFT JOIN ofec_committee_history_vw v ON sb.cmte_id = v.committee_id AND sb.two_year_transaction_period = v.cycle
     LEFT JOIN ofec_committee_history_vw v1 ON sb.clean_recipient_cmte_id = v1.committee_id AND sb.two_year_transaction_period = v1.cycle
  WHERE sb.cmte_id IN ('C00000935', 'C00003418', 'C00010603', 'C00027466', 'C00042366', 'C00075820', 'C00255695', 'C00279802', 'C00331314', 'C00370221', 'C00418103', 'C00428664') 
    AND sb.line_num IN ('21B', '29') 
    AND sb.disb_tp IN ('40', '40T', '40Y', '40Z', '41', '41T', '41Y', '41Z', '42', '42T', '42Y', '42Z')
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_b_nat_party_mv OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_b_nat_party_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_nat_party_mv TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_b_nat_party_mv_subid
    ON public.ofec_sched_b_nat_party_mv USING btree
    (sub_id);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_cln_rcpt_cmte_id
    ON public.ofec_sched_b_nat_party_mv USING btree
    (clean_recipient_cmte_id);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_desc_text
    ON public.ofec_sched_b_nat_party_mv USING gin
    (disbursement_description_text);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_disb_dt
    ON public.ofec_sched_b_nat_party_mv USING btree
    (disb_dt);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_image_num
    ON public.ofec_sched_b_nat_party_mv USING btree
    (image_num);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_rcpt_city
    ON public.ofec_sched_b_nat_party_mv USING btree
    (recipient_city);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_rcpt_name_text
    ON public.ofec_sched_b_nat_party_mv USING gin
    (recipient_name_text);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_rcpt_st
    ON public.ofec_sched_b_nat_party_mv USING btree
    (recipient_st);
CREATE INDEX idx_ofec_sched_b_nat_party_mv_rpt_yr
    ON public.ofec_sched_b_nat_party_mv USING btree
    (rpt_yr);
