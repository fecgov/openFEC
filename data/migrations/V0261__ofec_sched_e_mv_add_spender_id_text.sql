/*
This is migration is for issue ##5220
This is the latest version of  public.ofec_sched_e_mv
Add spender ID to tsvector column and rename column 

-- Previous migration file is V0255
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_e_mv_tmp AS
WITH SE AS
(SELECT
fe.cmte_id,
fe.cmte_nm,
fe.pye_nm,
fe.payee_l_nm,
fe.payee_f_nm,
fe.payee_m_nm,
fe.payee_prefix,
fe.payee_suffix,
fe.pye_st1,
fe.pye_st2,
fe.pye_city,
fe.pye_st,
fe.pye_zip,
fe.entity_tp,
fe.entity_tp_desc,
fe.exp_desc,
fe.catg_cd,
fe.catg_cd_desc,
fe.s_o_cand_id,
fe.s_o_cand_nm,
fe.s_o_cand_nm_first,
fe.s_o_cand_nm_last,
fe.s_o_cand_m_nm,
fe.s_o_cand_prefix,
fe.s_o_cand_suffix,
fe.s_o_cand_office,
fe.s_o_cand_office_desc,
fe.s_o_cand_office_st,
fe.s_o_cand_office_st_desc,
fe.s_o_cand_office_district,
fe.s_o_ind,
fe.s_o_ind_desc,
fe.election_tp,
fe.fec_election_tp_desc,
fe.cal_ytd_ofc_sought,
fe.dissem_dt,
fe.exp_amt,
coalesce(fe.exp_dt, fe.dissem_dt) as exp_dt,
fe.exp_tp,
fe.exp_tp_desc,
fe.memo_cd,
fe.memo_cd_desc,
fe.memo_text,
fe.conduit_cmte_id,
fe.conduit_cmte_nm,
fe.conduit_cmte_st1,
fe.conduit_cmte_st2,
fe.conduit_cmte_city,
fe.conduit_cmte_st,
fe.conduit_cmte_zip,
fe.indt_sign_nm,
fe.indt_sign_dt,
fe.notary_sign_nm,
fe.notary_sign_dt,
fe.notary_commission_exprtn_dt,
fe.filer_l_nm,
fe.filer_f_nm,
fe.filer_m_nm,
fe.filer_prefix,
fe.filer_suffix,
fe.action_cd,
fe.action_cd_desc,
fe.tran_id,
fe.back_ref_tran_id,
fe.back_ref_sched_nm,
fe.schedule_type,
fe.schedule_type_desc,
fe.line_num,
fe.image_num,
fe.file_num,
fe.link_id,
fe.orig_sub_id,
fe.sub_id,
fe.filing_form,
fe.rpt_tp,
fe.rpt_yr,
fe.election_cycle,
fe.pdf_url,
coalesce(fe.rpt_tp, '') in ('24', '48') as is_notice,
fe.payee_name_text,
fr.amndt_ind,
fr.prev_file_num,
to_timestamp(to_char(fr.receipt_dt, '99999999'), 'YYYYMMDD')::timestamp without time zone as receipt_dt,
true as most_recent
FROM disclosure.fec_fitem_sched_e fe
JOIN disclosure.f_rpt_or_form_sub fr
ON fe.link_id = fr.sub_id
-- -----------------
UNION
-- public.fec_sched_e_notice_vw
-- -----------------
SELECT
se.cmte_id,
se.cmte_nm,
se.pye_nm,
se.payee_l_nm,
se.payee_f_nm,
se.payee_m_nm,
se.payee_prefix,
se.payee_suffix,
se.pye_st1,
se.pye_st2,
se.pye_city,
se.pye_st,
se.pye_zip,
se.entity_tp,
se.entity_tp_desc,
se.exp_desc,
se.catg_cd,
se.catg_cd_desc,
se.s_o_cand_id,
se.s_o_cand_nm,
se.s_o_cand_nm_first,
se.s_o_cand_nm_last,
se.s_0_cand_m_nm AS s_o_cand_m_nm,
se.s_0_cand_prefix AS s_o_cand_prefix,
se.s_0_cand_suffix AS s_o_cand_suffix,
se.s_o_cand_office,
se.s_o_cand_office_desc,
se.s_o_cand_office_st,
se.s_o_cand_office_st_desc,
se.s_o_cand_office_district,
se.s_o_ind,
se.s_o_ind_desc,
se.election_tp,
se.fec_election_tp_desc,
se.cal_ytd_ofc_sought,
se.dissem_dt,
se.exp_amt,
coalesce(se.exp_dt, se.dissem_dt) as exp_dt,
se.exp_tp,
se.exp_tp_desc,
se.memo_cd,
se.memo_cd_desc,
se.memo_text,
se.conduit_cmte_id,
se.conduit_cmte_nm,
se.conduit_cmte_st1,
se.conduit_cmte_st2,
se.conduit_cmte_city,
se.conduit_cmte_st,
se.conduit_cmte_zip,
se.indt_sign_nm,
se.indt_sign_dt,
se.notary_sign_nm,
se.notary_sign_dt,
se.notary_commission_exprtn_dt,
se.filer_l_nm,
se.filer_f_nm,
se.filer_m_nm,
se.filer_prefix,
se.filer_suffix,
se.amndt_ind AS action_cd,
se.amndt_ind_desc AS action_cd_desc,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.tran_id
    ELSE NULL::character varying
END AS tran_id,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_tran_id
    ELSE NULL::character varying
END AS back_ref_tran_id,
CASE
    WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_sched_nm
    ELSE NULL::character varying
END AS back_ref_sched_nm,
'SE' AS schedule_type,
se.form_tp_desc AS schedule_type_desc,
se.line_num,
se.image_num,
se.file_num,
se.link_id,
se.orig_sub_id,
se.sub_id,
'F24' AS filing_form,
f24.rpt_tp,
f24.rpt_yr,
f24.rpt_yr + mod(f24.rpt_yr, 2::numeric) AS election_cycle,
image_pdf_url(se.image_num) as pdf_url,
coalesce(f24.rpt_tp, '') in ('24', '48') as is_notice,
to_tsvector(parse_fulltext(se.pye_nm)) as payee_name_text,
f24.amndt_ind,
f24.prev_file_num,
f24.receipt_dt,
(CASE WHEN pa.mst_rct_file_num is null THEN null WHEN f24.file_num = pa.mst_rct_file_num THEN true ELSE false end) as most_recent
FROM disclosure.nml_sched_e se
JOIN disclosure.nml_form_24 f24
ON se.link_id = f24.sub_id
LEFT OUTER JOIN ofec_processed_financial_amendment_chain_vw pa
ON f24.file_num = pa.file_num
WHERE f24.delete_ind IS NULL
    AND se.delete_ind IS NULL
    AND se.amndt_ind::text <> 'D'::text
-- -----------------
UNION
-- Add in records for the Form 5 filings
-- -----------------
SELECT
ff57.filer_cmte_id,
null AS cmte_nm,
ff57.pye_nm,
ff57.pye_l_nm,
ff57.pye_f_nm,
ff57.pye_m_nm,
ff57.pye_prefix,
ff57.pye_suffix,
ff57.pye_st1,
ff57.pye_st2,
ff57.pye_city,
ff57.pye_st,
ff57.pye_zip,
ff57.entity_tp,
ff57.entity_tp_desc,
ff57.exp_tp_desc,
ff57.catg_cd,
ff57.catg_cd_desc,
ff57.s_o_cand_id,
ff57.s_o_cand_nm,
ff57.s_o_cand_f_nm,
ff57.s_o_cand_l_nm,
ff57.s_o_cand_m_nm,
ff57.s_o_cand_prefix,
ff57.s_o_cand_suffix,
ff57.s_o_cand_office,
ff57.s_o_cand_office_desc,
ff57.s_o_cand_office_st,
ff57.s_o_cand_office_state_desc,
ff57.s_o_cand_office_district,
ff57.s_o_ind,
ff57.s_o_ind_desc,
ff57.election_tp,
ff57.fec_election_tp_desc,
ff57.cal_ytd_ofc_sought,
null AS dissem_dt,
ff57.exp_amt,
ff57.exp_dt,
ff57.exp_tp,
ff57.exp_tp_desc,
null AS memo_cd,
null AS memo_cd_desc,
null AS memo_text,
ff57.conduit_cmte_id,
ff57.conduit_cmte_nm,
ff57.conduit_cmte_st1,
ff57.conduit_cmte_st2,
ff57.conduit_cmte_city,
ff57.conduit_cmte_st,
ff57.conduit_cmte_zip,
null AS indt_sign_nm,
null AS indt_sign_dt,
null AS notary_sign_nm,
null AS notary_sign_dt,
null AS notary_commission_exprtn_dt,
null AS filer_l_nm,
null AS filer_f_nm,
null AS filer_m_nm,
null AS filer_prefix,
null AS filer_suffix,
ff57.action_cd,
ff57.action_cd_desc,
ff57.tran_id,
null AS back_ref_tran_id,
null AS back_ref_sched_nm,
ff57.schedule_type,
ff57.schedule_type_desc,
null AS line_num,
ff57.image_num,
ff57.file_num,
ff57.link_id,
ff57.orig_sub_id,
ff57.sub_id,
ff57.filing_form,
ff57.rpt_tp,
ff57.rpt_yr,
ff57.election_cycle,
image_pdf_url(ff57.image_num) as pdf_url,
coalesce(ff57.rpt_tp, '') in ('24', '48') AS is_notice,
to_tsvector(parse_fulltext(ff57.pye_nm)),
fr.amndt_ind,
fr.prev_file_num,
to_timestamp(to_char(fr.receipt_dt, '99999999'), 'YYYYMMDD')::timestamp without time zone as receipt_dt,
true as most_recent
FROM disclosure.fec_fitem_f57 ff57
JOIN disclosure.f_rpt_or_form_sub fr
ON ff57.link_id = fr.sub_id
-- -----------------
UNION
-- public.fec_f57_notice_vw
-- -----------------
SELECT
f57.filer_cmte_id,
null AS cmte_nm,
f57.pye_nm,
f57.pye_l_nm,
f57.pye_f_nm,
f57.pye_m_nm,
f57.pye_prefix,
f57.pye_suffix,
f57.pye_st1,
f57.pye_st2,
f57.pye_city,
f57.pye_st,
f57.pye_zip,
f57.entity_tp,
f57.entity_tp_desc,
f57.exp_tp_desc,
f57.catg_cd,
f57.catg_cd_desc,
f57.s_o_cand_id,
f57.s_o_cand_nm,
f57.s_o_cand_f_nm,
f57.s_o_cand_l_nm,
f57.s_o_cand_m_nm,
f57.s_o_cand_prefix,
f57.s_o_cand_suffix,
f57.s_o_cand_office,
f57.s_o_cand_office_desc,
f57.s_o_cand_office_st,
f57.s_o_cand_office_state_desc,
f57.s_o_cand_office_district,
f57.s_o_ind,
f57.s_o_ind_desc,
f57.election_tp,
f57.fec_election_tp_desc,
f57.cal_ytd_ofc_sought,
null AS dissem_dt,
f57.exp_amt,
f57.exp_dt,
f57.exp_tp,
f57.exp_tp_desc,
null AS memo_cd,
null AS memo_cd_desc,
null AS memo_text,
f57.conduit_cmte_id,
f57.conduit_cmte_nm,
f57.conduit_cmte_st1,
f57.conduit_cmte_st2,
f57.conduit_cmte_city,
f57.conduit_cmte_st,
f57.conduit_cmte_zip,
null AS indt_sign_nm,
null AS indt_sign_dt,
null AS notary_sign_nm,
null AS notary_sign_dt,
null AS notary_commission_exprtn_dt,
null AS filer_l_nm,
null AS filer_f_nm,
null AS filer_m_nm,
null AS filer_prefix,
null AS filer_suffix,
f57.amndt_ind,
f57.amndt_ind_desc,
CASE
    WHEN "substring"(f57.sub_id::character varying::text, 1, 1) = '4'::text THEN f57.tran_id
    ELSE NULL::character varying
END AS tran_id,
null AS back_ref_tran_id,
null AS back_ref_sched_nm,
'SE-F57' AS schedule_type,
f57.form_tp_desc AS schedule_type_desc,
null AS line_num,
f57.image_num,
f57.file_num,
f57.link_id,
f57.orig_sub_id,
f57.sub_id,
'F5' AS filing_form,
f5.rpt_tp,
f5.rpt_yr,
f5.rpt_yr + mod(f5.rpt_yr, 2::numeric) AS election_cycle,
image_pdf_url(f57.image_num) as pdf_url,
coalesce(f5.rpt_tp, '') in ('24', '48') AS is_notice,
to_tsvector(parse_fulltext(f57.pye_nm)),
f5.amndt_ind AS amendment_indicator,
f5.prev_file_num AS previous_file_num,
f57.receipt_dt,
(CASE WHEN pa.mst_rct_file_num is null THEN null WHEN f5.file_num = pa.mst_rct_file_num THEN true ELSE false end) as most_recent
FROM disclosure.nml_form_57 f57
JOIN disclosure.nml_form_5 f5
ON f57.link_id = f5.sub_id
LEFT OUTER JOIN ofec_processed_financial_amendment_chain_vw pa
ON f5.file_num = pa.file_num
WHERE (f5.rpt_tp::text = ANY (ARRAY['24'::character varying::text, '48'::character varying::text]))
    AND f57.amndt_ind::text <> 'D'::text
    AND f57.delete_ind IS NULL
    AND f5.delete_ind IS NULL
)
SELECT
SE.cmte_id,
SE.cmte_nm,
pye_nm,
payee_l_nm,
payee_f_nm,
payee_m_nm,
payee_prefix,
payee_suffix,
pye_st1,
pye_st2,
pye_city,
pye_st,
pye_zip,
entity_tp,
entity_tp_desc,
exp_desc,
catg_cd,
catg_cd_desc,
s_o_cand_id,
s_o_cand_nm,
s_o_cand_nm_first,
s_o_cand_nm_last,
s_o_cand_m_nm,
s_o_cand_prefix,
s_o_cand_suffix,
s_o_cand_office_desc,
s_o_cand_office_st_desc,
CASE when se.s_o_ind in ('O', 'S') then se.s_o_ind else NULL::character varying END AS s_o_ind,
s_o_ind_desc,
election_tp,
fec_election_tp_desc,
cal_ytd_ofc_sought,
dissem_dt,
exp_amt,
exp_dt,
exp_tp,
exp_tp_desc,
memo_cd,
memo_cd_desc,
memo_text,
conduit_cmte_id,
conduit_cmte_nm,
conduit_cmte_st1,
conduit_cmte_st2,
conduit_cmte_city,
conduit_cmte_st,
conduit_cmte_zip,
indt_sign_nm,
indt_sign_dt,
notary_sign_nm,
notary_sign_dt,
notary_commission_exprtn_dt,
filer_l_nm,
filer_f_nm,
filer_m_nm,
filer_prefix,
filer_suffix,
action_cd,
action_cd_desc,
tran_id,
back_ref_tran_id,
back_ref_sched_nm,
schedule_type,
schedule_type_desc,
line_num,
image_num,
file_num,
prev_file_num,
amndt_ind,
reps.rptnum AS amndt_number,
link_id,
orig_sub_id,
sub_id,
filing_form,
rpt_tp,
rpt_yr,
election_cycle,
pdf_url,
is_notice,
payee_name_text,
COALESCE(s_o_cand_office, cand.cand_office) AS cand_office,
COALESCE(s_o_cand_office_st, cand.cand_office_st) AS cand_office_st,
COALESCE(s_o_cand_office_district, cand.cand_office_district) AS cand_office_district,
cand.cand_pty_affiliation,
cmte.cmte_tp,
cmte.cmte_dsgn,
now() as pg_date,
receipt_dt as filing_date,
most_recent,
to_tsvector(parse_fulltext(se.cmte_nm||' '||SE.cmte_id)) as spender_name_text
FROM se
LEFT OUTER JOIN disclosure.cand_valid_fec_yr cand
ON se.s_o_cand_id = cand.cand_id AND se.election_cycle = cand.fec_election_yr
LEFT OUTER JOIN disclosure.cmte_valid_fec_yr cmte
ON se.cmte_id = cmte.cmte_id AND se.election_cycle = cmte.fec_election_yr
LEFT OUTER JOIN real_efile.reps ON se.file_num = reps.repid
;

-- grants
ALTER TABLE public.ofec_sched_e_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_e_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_e_mv_tmp TO fec_read;

-- Set up the unique key
create unique index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_sub_id on ofec_sched_e_mv_tmp (sub_id);


-- Create simple indices on filtered columns
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_cmte_id on ofec_sched_e_mv_tmp (cmte_id);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_cand_id on ofec_sched_e_mv_tmp (s_o_cand_id);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_filing_form on ofec_sched_e_mv_tmp (filing_form);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_election_cycle on ofec_sched_e_mv_tmp (election_cycle);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_is_notice on ofec_sched_e_mv_tmp (is_notice);

create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_cand_office on ofec_sched_e_mv_tmp (cand_office);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_cand_office_st on ofec_sched_e_mv_tmp (cand_office_st);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_cand_pty on ofec_sched_e_mv_tmp (cand_pty_affiliation);

create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_filing_dt on ofec_sched_e_mv_tmp (filing_date);
create index IF NOT EXISTS idx_ofec_sched_e_mv_tmp_spender_name_text on ofec_sched_e_mv_tmp USING gin (spender_name_text);


-- ------------------------
CREATE OR REPLACE VIEW ofec_sched_e_vw AS
SELECT * FROM ofec_sched_e_mv_tmp;

ALTER VIEW ofec_sched_e_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_e_vw TO fec_read;
GRANT ALL ON public.ofec_sched_e_vw TO fec;
-- ------------------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv;

ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_e_mv_tmp RENAME TO ofec_sched_e_mv;

-- ---------------------------------
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_sub_id RENAME TO idx_ofec_sched_e_mv_sub_id;

ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_cmte_id RENAME TO idx_ofec_sched_e_mv_cmte_id;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_cand_id RENAME TO idx_ofec_sched_e_mv_cand_id;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_filing_form RENAME TO idx_ofec_sched_e_mv_filing_form;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_election_cycle RENAME TO idx_ofec_sched_e_mv_election_cycle;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_is_notice RENAME TO idx_ofec_sched_e_mv_is_notice;

ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_cand_office RENAME TO idx_ofec_sched_e_mv_cand_office;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_cand_office_st RENAME TO idx_ofec_sched_e_mv_cand_office_st;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_cand_pty RENAME TO idx_ofec_sched_e_mv_cand_pty;

ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_filing_dt RENAME TO idx_ofec_sched_e_mv_filing_dt;
ALTER INDEX IF EXISTS idx_ofec_sched_e_mv_tmp_spender_name_text RENAME TO idx_ofec_sched_e_mv_spender_name_text;
