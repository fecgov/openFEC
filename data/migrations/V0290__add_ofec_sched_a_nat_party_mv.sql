/*
This migration file is for #5733

1) Create ofec_sched_a_nat_party_mv which includes all contributions of national party committees
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_nat_party_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_sched_a_nat_party_mv
AS
SELECT sa.cmte_id,
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
    v.first_f1_date,
    v.first_file_date,
    v.is_active,
    v.state,
    v.state_full,
    v.treasurer_name,
    sa.contbr_id,
    sa.contbr_nm,
    sa.contbr_nm_first,
    sa.contbr_m_nm,
    sa.contbr_nm_last,
    sa.contbr_prefix,
    sa.contbr_suffix,
    sa.contbr_st1,
    sa.contbr_st2,
    sa.contbr_city,
    sa.contbr_st,
    sa.contbr_zip,
    sa.entity_tp,
    sa.entity_tp_desc,
    sa.contbr_employer,
    sa.contbr_occupation,
    v1.name AS cmte_contbr,
    sa.election_tp,
    sa.fec_election_tp_desc,
    sa.fec_election_yr,
    sa.election_tp_desc,
    sa.contb_aggregate_ytd,
    sa.contb_receipt_dt,
    sa.contb_receipt_amt,
    sa.receipt_tp,
    sa.receipt_tp_desc,
    sa.receipt_desc,
    sa.memo_cd,
    sa.memo_cd_desc,
    sa.memo_text,
    sa.cand_id,
    sa.cand_nm,
    sa.cand_nm_first,
    sa.cand_m_nm,
    sa.cand_nm_last,
    sa.cand_prefix,
    sa.cand_suffix,
    sa.cand_office,
    sa.cand_office_desc,
    sa.cand_office_st,
    sa.cand_office_st_desc,
    sa.cand_office_district,
    sa.conduit_cmte_id,
    sa.conduit_cmte_nm,
    sa.conduit_cmte_st1,
    sa.conduit_cmte_st2,
    sa.conduit_cmte_city,
    sa.conduit_cmte_st,
    sa.conduit_cmte_zip,
    sa.donor_cmte_nm,
    sa.national_cmte_nonfed_acct,
    sa.increased_limit,
    sa.action_cd,
    sa.action_cd_desc,
    sa.tran_id,
    sa.back_ref_tran_id,
    sa.back_ref_sched_nm,
    sa.schedule_type,
    sa.schedule_type_desc,
    sa.line_num,
    sa.image_num,
    sa.file_num,
    sa.link_id,
    sa.orig_sub_id,
    sa.sub_id,
    sa.filing_form,
    sa.rpt_tp,
    sa.rpt_yr,
    sa.two_year_transaction_period,
    sa.pdf_url,
    sa.contributor_name_text,
    sa.contributor_employer_text,
    sa.contributor_occupation_text,
    sa.is_individual,
    sa.clean_contbr_id,
    sa.line_number_label,
    sa.cmte_tp,
    sa.org_tp,
    sa.cmte_dsgn,
    CASE
        WHEN sa.receipt_tp IN ('30', '30E', '30F', '30G', '30J', '30K', '30T') THEN 'CONVENTION ACCOUNT'
        WHEN sa.receipt_tp IN ('31', '31E', '31F', '31G', '31J', '31K', '31T') THEN 'HEADQUARTERS ACCOUNT'
        WHEN sa.receipt_tp IN ('32', '32E', '32F', '32G', '32J', '32K', '32T') THEN 'RECOUNT ACCOUNT'
        ELSE 'UNKNOWN'
    END AS party_account,
    v1.committee_type AS cmte_contbr_type,
    v1.committee_type_full AS cmte_contbr_type_full,
    v1.designation AS cmte_contbr_desgn,
    v1.designation_full AS cmte_contbr_desgn_full,
    v1.organization_type AS cmte_contbr_org,
    v1.organization_type_full AS cmte_contbr_org_full,
    v1.state AS cmte_contbr_state,
    v1.state_full AS cmte_contbr_state_full,
    v1.party AS cmte_contbr_party,
    v1.party_full AS cmte_contbr_party_full
FROM disclosure.fec_fitem_sched_a sa
LEFT JOIN ofec_committee_history_vw v ON sa.cmte_id = v.committee_id AND sa.two_year_transaction_period = v.cycle
LEFT JOIN ofec_committee_history_vw v1 ON sa.clean_contbr_id = v1.committee_id AND sa.two_year_transaction_period = v1.cycle
WHERE sa.cmte_id in ('C00000935', 'C00003418', 'C00010603', 'C00027466', 'C00042366', 'C00075820', 'C00255695', 'C00279802', 'C00331314', 'C00370221', 'C00418103', 'C00428664')
  AND sa.line_num = '17'
  AND sa.receipt_tp in ('30','30E', '30F', '30G', '30J', '30K', '30T', '31', '31E', '31F', '31G', '31J', '31K', '31T', '32', '32E', '32F', '32G', '32J', '32K', '32T')
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_a_nat_party_mv OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_a_nat_party_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_nat_party_mv TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_a_nat_party_mv_subid
    ON public.ofec_sched_a_nat_party_mv USING btree
    (sub_id);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_cln_contbr_id
    ON public.ofec_sched_a_nat_party_mv USING btree
    (clean_contbr_id );
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_city
    ON public.ofec_sched_a_nat_party_mv USING btree
    (contbr_city);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_emp_text
    ON public.ofec_sched_a_nat_party_mv USING gin
    (contributor_employer_text);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_name_text
    ON public.ofec_sched_a_nat_party_mv USING gin
    (contributor_name_text);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_occ_text
    ON public.ofec_sched_a_nat_party_mv USING gin
    (contributor_occupation_text);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_st
    ON public.ofec_sched_a_nat_party_mv USING btree
    (contbr_st);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_contbr_zip
    ON public.ofec_sched_a_nat_party_mv USING gin
    (contbr_zip);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_image_num
    ON public.ofec_sched_a_nat_party_mv USING btree
    (image_num);
CREATE INDEX idx_ofec_sched_a_nat_party_mv_rpt_yr
    ON public.ofec_sched_a_nat_party_mv USING btree
    (rpt_yr);
