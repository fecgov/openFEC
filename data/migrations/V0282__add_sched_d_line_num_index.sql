/*
This migration file will add a line num index
issue #5510 (Debts - add line_number as a filterable field)
*/

-- ---------------
-- ofec_sched_d_mv
-- ---------------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_d_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_sched_d_mv_tmp AS
    SELECT
        sd.sub_id,
        sd.cmte_id,
        sd.image_num,
        sd.filing_form,
        sd.link_id,
        sd.line_num,
        sd.tran_id,
        sd.file_num,
        sd.orig_sub_id,
        sd.cmte_nm,
        sd.cred_dbtr_id,
        sd.cred_dbtr_nm,
        sd.cred_dbtr_l_nm,
        sd.cred_dbtr_f_nm,
        sd.cred_dbtr_m_nm,
        sd.cred_dbtr_prefix,
        sd.cred_dbtr_suffix,
        sd.cred_dbtr_st1,
        sd.cred_dbtr_st2,
        sd.cred_dbtr_city,
        sd.cred_dbtr_st,
        sd.creditor_debtor_name_text,
        sd.entity_tp,
        sd.nature_debt_purpose,
        sd.outstg_bal_bop,
        sd.outstg_bal_cop,
        sd.amt_incurred_per,
        sd.pymt_per,
        sd.cand_id,
        sd.cand_nm,
        sd.cand_nm_first,
        sd.cand_nm_last,
        sd.cand_office,
        sd.cand_office_st,
        sd.cand_office_st_desc,
        sd.cand_office_district,
        sd.conduit_cmte_id,
        sd.conduit_cmte_nm,
        sd.conduit_cmte_st1,
        sd.conduit_cmte_st2,
        sd.conduit_cmte_city,
        sd.conduit_cmte_st,
        sd.conduit_cmte_zip,
        sd.action_cd,
        sd.action_cd_desc,
        sd.schedule_type,
        sd.schedule_type_desc,
        sd.election_cycle,
        sd.rpt_tp,
        sd.rpt_yr,
        fr.cvg_start_dt::text::date::timestamp without time zone as coverage_start_date,
        fr.cvg_end_dt::text::date::timestamp without time zone as coverage_end_date
    FROM disclosure.fec_fitem_sched_d sd
    LEFT JOIN disclosure.f_rpt_or_form_sub fr
        ON sd.link_id = fr.sub_id
WITH DATA;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_d_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_d_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_sched_d_mv_tmp TO fec_read;

-- create unique index on the  MV
CREATE UNIQUE INDEX idx_ofec_sched_d_mv_tmp_sub_id ON public.ofec_sched_d_mv_tmp USING btree (sub_id);

-- Create indices on filtered columns
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_cand_id on ofec_sched_d_mv_tmp USING btree (cand_id);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_pymt_per on ofec_sched_d_mv_tmp USING btree (pymt_per);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_amt_incurred_per on ofec_sched_d_mv_tmp USING btree (amt_incurred_per);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_outstg_bal_bop on ofec_sched_d_mv_tmp USING btree (outstg_bal_bop);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_outstg_bal_cop on ofec_sched_d_mv_tmp USING btree (outstg_bal_cop);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_nature_debt_purpose on ofec_sched_d_mv_tmp USING btree (nature_debt_purpose);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_cred_dbtr_nm on ofec_sched_d_mv_tmp USING btree (cred_dbtr_nm);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_coverage_start_date on ofec_sched_d_mv_tmp USING btree (coverage_start_date);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_coverage_end_date on ofec_sched_d_mv_tmp USING btree (coverage_end_date);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_rpt_tp on ofec_sched_d_mv_tmp USING btree (rpt_tp);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_rpt_yr on ofec_sched_d_mv_tmp USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_ofec_sched_d_mv_tmp_line_num on ofec_sched_d_mv_tmp USING btree (line_num);

-- update the interface VW to point to the updated tmp MV
-- ---------------
CREATE OR REPLACE VIEW public.ofec_sched_d_vw AS
SELECT * FROM public.ofec_sched_d_mv_tmp;

-- grant correct ownership/permission
ALTER TABLE public.ofec_sched_d_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_d_vw TO fec;
GRANT SELECT ON TABLE public.ofec_sched_d_vw TO fec_read;

--drop MV and rename tmp MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_sched_d_mv;
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_sched_d_mv_tmp RENAME TO ofec_sched_d_mv;

-- rename indexes
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_sub_id RENAME TO idx_ofec_sched_d_mv_sub_id;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_cand_id RENAME TO idx_ofec_sched_d_mv_cand_id;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_pymt_per RENAME TO idx_ofec_sched_d_mv_pymt_per;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_amt_incurred_per RENAME TO idx_ofec_sched_d_mv_amt_incurred_per;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_outstg_bal_bop RENAME TO idx_ofec_sched_d_mv_outstg_bal_bop;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_outstg_bal_cop RENAME TO idx_ofec_sched_d_mv_outstg_bal_cop;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_nature_debt_purpose RENAME TO idx_ofec_sched_d_mv_nature_debt_purpose;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_cred_dbtr_nm RENAME TO idx_ofec_sched_d_mv_cred_dbtr_nm;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_coverage_start_date RENAME TO idx_ofec_sched_d_mv_coverage_start_date;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_coverage_end_date RENAME TO idx_ofec_sched_d_mv_coverage_end_date;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_rpt_tp RENAME TO idx_ofec_sched_d_mv_rpt_tp;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_rpt_yr RENAME TO idx_ofec_sched_d_mv_rpt_yr;
ALTER INDEX public.idx_ofec_sched_d_mv_tmp_line_num RENAME TO idx_ofec_sched_d_mv_line_num;
