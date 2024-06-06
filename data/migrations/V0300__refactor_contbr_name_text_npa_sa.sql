/*
This migration file is for #5859
1) rebuild column contributor_name_text using contbr_id and contbr_nm; remove clean_contbr_id
2) rebuild column recipient_name_text using recipient_cmte_id and recipient_nm; remove clean_recipient_cmte_id
3) Last version: NPA SA -V0298; NPA SB -V0299; NPA total - V0297
4) There is a dependece between the views and totals_mv. However since the NPA total are not shown on website, the views will be deleted during this migration
5) Steps: 
   Create NPA SA and SB tmp MVs
   Create NPA SA and SB tmp views
   Switch NPA total MV to use the tmp views
   Delete and recreate NPA SA and SB regular views using tmp MVs in step 1
   Rename NPA SA and SB tmp MVs
   Switch NPA total MV to use the regular views
   Delete two tmp views
*/

---1. create NPA SA tmp mv---
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_national_party_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_a_national_party_mv_tmp AS
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
    sa.contributor_employer_text,
    sa.contributor_occupation_text,
    sa.is_individual,
    sa.line_number_label,
    sa.cmte_tp,
    sa.org_tp,
    sa.cmte_dsgn,
    CASE
        WHEN sa.receipt_tp IN ('30', '30E', '30F', '30G', '30J', '30K', '30T') THEN 'CONVENTION'
        WHEN sa.receipt_tp IN ('31', '31E', '31F', '31G', '31J', '31K', '31T') THEN 'HEADQUARTERS'
        WHEN sa.receipt_tp IN ('32', '32E', '32F', '32G', '32J', '32K', '32T') THEN 'RECOUNT'
        ELSE 'UNKNOWN'
    END AS party_account,
    v1.name AS contbr_cmte,
    v1.committee_type AS contbr_cmte_type,
    v1.committee_type_full AS contbr_cmte_type_full,
    v1.designation AS contbr_cmte_desgn,
    v1.designation_full AS contbr_cmte_desgn_full,
    v1.organization_type AS contbr_cmte_org,
    v1.organization_type_full AS contbr_cmte_org_full,
    v1.state AS contbr_cmte_state,
    v1.state_full AS contbr_cmte_state_full,
    v1.party AS contbr_cmte_party,
    v1.party_full AS contbr_cmte_party_full,
    to_tsvector(parse_fulltext(COALESCE(sa.contbr_id, '') || ' ' || sa.contbr_nm)) AS contributor_name_text
FROM disclosure.fec_fitem_sched_a sa
LEFT JOIN ofec_committee_history_vw v ON sa.cmte_id = v.committee_id AND sa.two_year_transaction_period = v.cycle
LEFT JOIN ofec_committee_history_vw v1 ON sa.contbr_id = v1.committee_id AND sa.two_year_transaction_period = v1.cycle
WHERE sa.cmte_id in ('C00000935', 'C00003418', 'C00010603', 'C00027466', 'C00042366', 'C00075820', 'C00255695', 'C00279802', 'C00331314', 'C00370221', 'C00418103', 'C00428664')
  AND sa.receipt_tp in ('30','30E', '30F', '30G', '30J', '30K', '30T', '31', '31E', '31F', '31G', '31J', '31K', '31T', '32', '32E', '32F', '32G', '32J', '32K', '32T')
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_a_national_party_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_a_national_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_national_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_a_national_party_mv_tmp_subid
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (sub_id);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_city
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contbr_city);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_emp_text
    ON public.ofec_sched_a_national_party_mv_tmp USING gin
    (contributor_employer_text);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_name_text
    ON public.ofec_sched_a_national_party_mv_tmp USING gin
    (contributor_name_text);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_occ_text
    ON public.ofec_sched_a_national_party_mv_tmp USING gin
    (contributor_occupation_text);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_st
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contbr_st);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_zip
    ON public.ofec_sched_a_national_party_mv_tmp USING gin
    (contbr_zip);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_image_num
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (image_num);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_rpt_yr
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (rpt_yr);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_recipt_amt
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contb_receipt_amt);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_recipt_dt
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contb_receipt_dt);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_cmte_type
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contbr_cmte_type);
CREATE INDEX idx_ofec_sched_a_national_party_mv_tmp_contbr_id
    ON public.ofec_sched_a_national_party_mv_tmp USING btree
    (contbr_id);

---2. create NPA SB tmp mv---
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_national_party_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_b_national_party_mv_tmp AS
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
    sb.disbursement_description_text,
    sb.disbursement_purpose_category,
    sb.line_number_label,
    sb.cmte_tp,
    sb.org_tp,
    sb.cmte_dsgn,
    CASE
        WHEN sb.disb_tp  IN ('40', '40T', '40Y', '40Z') THEN 'CONVENTION'
        WHEN sb.disb_tp  IN ('41', '41T', '41Y', '41Z') THEN 'HEADQUARTERS'
        WHEN sb.disb_tp  IN ('42', '42T', '42Y', '42Z') THEN 'RECOUNT'
        ELSE 'UNKNOWN'
    END AS party_account,
    v1.name AS recipient_cmte,
    v1.committee_type AS recipient_cmte_type,
    v1.committee_type_full AS recipient_cmte_type_full,
    v1.designation AS recipient_cmte_desgn,
    v1.designation_full AS recipient_cmte_desgn_full,
    v1.organization_type AS recipient_cmte_org,
    v1.organization_type_full AS recipient_cmte_org_full,
    v1.state AS recipient_cmte_state,
    v1.state_full AS recipient_cmte_state_full,
    v1.party AS recipient_cmte_party,
    v1.party_full AS recipient_cmte_party_full,
    to_tsvector(parse_fulltext(COALESCE(sb.recipient_cmte_id, '') || ' ' || sb.recipient_name_text)) AS recipient_name_text
   FROM disclosure.fec_fitem_sched_b sb
     LEFT JOIN ofec_committee_history_vw v ON sb.cmte_id = v.committee_id AND sb.two_year_transaction_period = v.cycle
     LEFT JOIN ofec_committee_history_vw v1 ON sb.recipient_cmte_id = v1.committee_id AND sb.two_year_transaction_period = v1.cycle
  WHERE sb.cmte_id IN ('C00000935', 'C00003418', 'C00010603', 'C00027466', 'C00042366', 'C00075820', 'C00255695', 'C00279802', 'C00331314', 'C00370221', 'C00418103', 'C00428664') 
    AND sb.disb_tp IN ('40', '40T', '40Y', '40Z', '41', '41T', '41Y', '41Z', '42', '42T', '42Y', '42Z')
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_sched_b_national_party_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_sched_b_national_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_national_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_sched_b_national_party_mv_tmp_subid
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (sub_id);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rcpt_cmte_id
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (recipient_cmte_id);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_desc_text
    ON public.ofec_sched_b_national_party_mv_tmp USING gin
    (disbursement_description_text);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_disb_dt
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (disb_dt);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_image_num
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (image_num);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rcpt_city
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (recipient_city);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rcpt_name_text
    ON public.ofec_sched_b_national_party_mv_tmp USING gin
    (recipient_name_text);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rcpt_st
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (recipient_st);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rpt_yr
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (rpt_yr);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_disb_amt
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (disb_amt);
CREATE INDEX idx_ofec_sched_b_national_party_mv_tmp_rcpt_cmte_type
    ON public.ofec_sched_b_national_party_mv_tmp USING btree
    (recipient_cmte_type);

---3. Create two tmp views---
CREATE OR REPLACE VIEW public.ofec_sched_a_national_party_vw_tmp AS
SELECT * FROM public.ofec_sched_a_national_party_mv_tmp;

CREATE OR REPLACE VIEW public.ofec_sched_b_national_party_vw_tmp AS
SELECT * FROM public.ofec_sched_b_national_party_mv_tmp;

---4. Switch NPA total MV to use the two temp views because of dependence
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv_tmp;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_totals_national_party_mv_tmp AS
WITH cmte_list AS (
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_a_national_party_vw_tmp
        UNION
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_b_national_party_vw_tmp
    ), 
    sa_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period, 
               sum(contb_receipt_amt) AS contribution
        FROM ofec_sched_a_national_party_vw_tmp
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    ), 
    sb_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period,
               sum(disb_amt) AS disbursement
        FROM ofec_sched_b_national_party_vw_tmp
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    )
    SELECT l.cmte_id, l.cmte_nm, l.two_year_transaction_period,
        (SELECT sa_total.contribution
           FROM sa_total
          WHERE sa_total.cmte_id = l.cmte_id 
            AND sa_total.two_year_transaction_period = l.two_year_transaction_period) AS contribution,
        (SELECT sb_total.disbursement
           FROM sb_total
          WHERE sb_total.cmte_id = l.cmte_id
            AND sb_total.two_year_transaction_period = l.two_year_transaction_period) AS disbursement
   FROM cmte_list l
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_totals_national_party_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_totals_national_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_national_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_totals_national_party_mv_tmp_cmteid_cycle
    ON public.ofec_totals_national_party_mv_tmp USING btree
    (cmte_id, two_year_transaction_period);

   ---Rename total_mv_tmp to mv--
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv_tmp RENAME TO ofec_totals_national_party_mv;

ALTER INDEX IF EXISTS idx_ofec_totals_national_party_mv_tmp_cmteid_cycle RENAME TO idx_ofec_totals_national_party_mv_cmteid_cycle; 

---5. After disconnecting the dependence, delete and recreate view because columns have been changed.
  ---SA--
DROP VIEW IF EXISTS public.ofec_sched_a_national_party_vw;

CREATE OR REPLACE VIEW public.ofec_sched_a_national_party_vw AS
SELECT * FROM public.ofec_sched_a_national_party_mv_tmp;

ALTER TABLE public.ofec_sched_a_national_party_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_national_party_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_national_party_vw TO fec_read;

  ---SB--
DROP VIEW IF EXISTS public.ofec_sched_b_national_party_vw;

CREATE OR REPLACE VIEW public.ofec_sched_b_national_party_vw AS
SELECT * FROM public.ofec_sched_b_national_party_mv_tmp;

ALTER TABLE public.ofec_sched_b_national_party_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_b_national_party_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_b_national_party_vw TO fec_read;

---6. Drop old SA MV and rename tmp_mv
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_national_party_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_a_national_party_mv_tmp RENAME TO ofec_sched_a_national_party_mv;

ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_subid RENAME TO idx_ofec_sched_a_national_party_mv_subid; 

ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_city RENAME TO idx_ofec_sched_a_national_party_mv_contbr_city;
   
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_emp_text RENAME TO idx_ofec_sched_a_national_party_mv_contbr_emp_text;
    
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_name_text RENAME TO idx_ofec_sched_a_national_party_mv_contbr_name_text;
   
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_occ_text RENAME TO idx_ofec_sched_a_national_party_mv_contbr_occ_text;
   
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_st RENAME TO idx_ofec_sched_a_national_party_mv_contbr_st;
    
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_zip RENAME TO idx_ofec_sched_a_national_party_mv_contbr_zip;
    
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_image_num RENAME TO idx_ofec_sched_a_national_party_mv_image_num;
    
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_rpt_yr RENAME TO idx_ofec_sched_a_national_party_mv_rpt_yr;
   
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_recipt_amt RENAME TO idx_ofec_sched_a_national_party_mv_recipt_amt;
   
ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_recipt_dt RENAME TO idx_ofec_sched_a_national_party_mv_recipt_dt;

ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_cmte_type RENAME TO idx_ofec_sched_a_national_party_mv_contbr_cmte_type;

ALTER INDEX IF EXISTS idx_ofec_sched_a_national_party_mv_tmp_contbr_id RENAME TO idx_ofec_sched_a_national_party_mv_contbr_id;

---7. Drop old SB mv and Rename
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_national_party_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_b_national_party_mv_tmp RENAME TO ofec_sched_b_national_party_mv;

ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_subid RENAME TO idx_ofec_sched_b_national_party_mv_subid; 

ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rcpt_cmte_id RENAME TO idx_ofec_sched_b_national_party_mv_rcpt_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_desc_text RENAME TO idx_ofec_sched_b_national_party_mv_desc_text;
   
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_disb_dt RENAME TO idx_ofec_sched_b_national_party_mv_disb_dt;
    
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_image_num RENAME TO idx_ofec_sched_b_national_party_mv_image_num;
   
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rcpt_city RENAME TO idx_ofec_sched_b_national_party_mv_rcpt_city;
   
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rcpt_name_text RENAME TO idx_ofec_sched_b_national_party_mv_rcpt_name_text;
    
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rcpt_st RENAME TO idx_ofec_sched_b_national_party_mv_rcpt_st;
    
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rpt_yr RENAME TO idx_ofec_sched_b_national_party_mv_rpt_yr;
    
ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_disb_amt RENAME TO idx_ofec_sched_b_national_party_mv_disb_amt;

ALTER INDEX IF EXISTS idx_ofec_sched_b_national_party_mv_tmp_rcpt_cmte_type RENAME TO idx_ofec_sched_b_national_party_mv_rcpt_cmte_type;

---8. Switch NPA total mv back to regular views
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv_tmp;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_totals_national_party_mv_tmp AS
WITH cmte_list AS (
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_a_national_party_vw
        UNION
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_b_national_party_vw
    ), 
    sa_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period, 
               sum(contb_receipt_amt) AS contribution
        FROM ofec_sched_a_national_party_vw
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    ), 
    sb_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period,
               sum(disb_amt) AS disbursement
        FROM ofec_sched_b_national_party_vw
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    )
    SELECT l.cmte_id, l.cmte_nm, l.two_year_transaction_period,
        (SELECT sa_total.contribution
           FROM sa_total
          WHERE sa_total.cmte_id = l.cmte_id 
            AND sa_total.two_year_transaction_period = l.two_year_transaction_period) AS contribution,
        (SELECT sb_total.disbursement
           FROM sb_total
          WHERE sb_total.cmte_id = l.cmte_id
            AND sb_total.two_year_transaction_period = l.two_year_transaction_period) AS disbursement
   FROM cmte_list l
WITH DATA;

ALTER TABLE IF EXISTS public.ofec_totals_national_party_mv_tmp OWNER TO fec;

GRANT ALL ON TABLE public.ofec_totals_national_party_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_totals_national_party_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_totals_national_party_mv_tmp_cmteid_cycle
    ON public.ofec_totals_national_party_mv_tmp USING btree
    (cmte_id, two_year_transaction_period);

   ---Rename total_mv_tmp to mv---
DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv_tmp RENAME TO ofec_totals_national_party_mv;

ALTER INDEX IF EXISTS idx_ofec_totals_national_party_mv_tmp_cmteid_cycle RENAME TO idx_ofec_totals_national_party_mv_cmteid_cycle; 

   ---Drop tmp view--
DROP VIEW IF EXISTS public.ofec_sched_a_national_party_vw_tmp;
DROP VIEW IF EXISTS public.ofec_sched_b_national_party_vw_tmp;
