/*
Format Update V8.3 ADD COLUMN orig_amndt_dt TO disclosure.nml_form_9.
This change need to happen similtanously in FECP and DEV/STG/PRD databases.
Column had been added to DEV/STG/PRD databases; migration file submitted to keep track of the change.
*/

/*
-- pg_date column in public.electioneering_com_vw is not used by the downstream MVs
public.ofec_electioneering_aggregate_candidate_mv 
public.ofec_electioneering_mv

-- remove this column from the view so column pg_date can be dropped/re-added after column orig_amndt_dt to the end of the table disclosure.nml_form_9.
Otherwise GoldenGate transfer will encounter problem since it is only mapped at table level
*/
CREATE OR REPLACE VIEW public.electioneering_com_vw AS 
 WITH f9 AS (
         SELECT nml_form_9.form_tp,
            nml_form_9.cmte_id,
            nml_form_9.ind_org_corp_nm,
            nml_form_9.ind_org_corp_st1,
            nml_form_9.ind_org_corp_st2,
            nml_form_9.ind_org_corp_city,
            nml_form_9.ind_org_corp_st,
            nml_form_9.ind_org_corp_zip,
            nml_form_9.addr_chg_flg,
            nml_form_9.ind_org_corp_emp,
            nml_form_9.ind_org_corp_occup,
            nml_form_9.beg_cvg_dt,
            nml_form_9.end_cvg_dt,
            nml_form_9.pub_distrib_dt,
            nml_form_9.qual_nonprofit_flg,
            nml_form_9.segr_bank_acct_flg,
            nml_form_9.ind_custod_nm,
            nml_form_9.ind_custod_st1,
            nml_form_9.ind_custod_st2,
            nml_form_9.ind_custod_city,
            nml_form_9.ind_custod_st,
            nml_form_9.ind_custod_zip,
            nml_form_9.ind_custod_emp,
            nml_form_9.ind_custod_occup,
            nml_form_9.ttl_dons_this_stmt,
            nml_form_9.ttl_disb_this_stmt,
            nml_form_9.filer_sign_nm,
            nml_form_9.filer_sign_dt,
            nml_form_9.sub_id,
            nml_form_9.begin_image_num,
            nml_form_9.end_image_num,
            nml_form_9.form_tp_desc,
            nml_form_9.ind_org_corp_st_desc,
            nml_form_9.addr_chg_flg_desc,
            nml_form_9.qual_nonprofit_flg_desc,
            nml_form_9.segr_bank_acct_flg_desc,
            nml_form_9.ind_custod_st_desc,
            nml_form_9.image_tp,
            nml_form_9.load_status,
            nml_form_9.last_update_dt,
            nml_form_9.delete_ind,
            nml_form_9.amndt_ind,
            nml_form_9.comm_title,
            nml_form_9.receipt_dt,
            nml_form_9.file_num,
            nml_form_9.rpt_yr,
            nml_form_9.prev_file_num,
            nml_form_9.mst_rct_file_num,
            nml_form_9.rpt_tp,
            nml_form_9.entity_tp,
            nml_form_9.filer_cd,
            nml_form_9.filer_cd_desc,
            nml_form_9.indv_l_nm,
            nml_form_9.indv_f_nm,
            nml_form_9.indv_m_nm,
            nml_form_9.indv_prefix,
            nml_form_9.indv_suffix,
            nml_form_9.cust_l_nm,
            nml_form_9.cust_f_nm,
            nml_form_9.cust_m_nm,
            nml_form_9.cust_prefix,
            nml_form_9.cust_suffix,
            nml_form_9.filer_l_nm,
            nml_form_9.filer_f_nm,
            nml_form_9.filer_m_nm,
            nml_form_9.filer_prefix,
            nml_form_9.filer_suffix
           FROM disclosure.nml_form_9
          WHERE ((nml_form_9.cmte_id::text, nml_form_9.beg_cvg_dt, nml_form_9.end_cvg_dt, nml_form_9.pub_distrib_dt, nml_form_9.receipt_dt) IN ( SELECT nml_form_9_1.cmte_id,
                    nml_form_9_1.beg_cvg_dt,
                    nml_form_9_1.end_cvg_dt,
                    nml_form_9_1.pub_distrib_dt,
                    max(nml_form_9_1.receipt_dt) AS max
                   FROM disclosure.nml_form_9 nml_form_9_1
                  WHERE nml_form_9_1.rpt_yr::double precision >=
                        CASE
                            WHEN (date_part('year'::text, now())::integer % 2) = 1 THEN date_part('year'::text, now())
                            WHEN (date_part('year'::text, now())::integer % 2) = 0 THEN date_part('year'::text, now()) - 1::double precision
                            ELSE NULL::double precision
                        END AND nml_form_9_1.rpt_yr::double precision <=
                        CASE
                            WHEN (date_part('year'::text, now())::integer % 2) = 1 THEN (date_part('year'::text, now())::integer + 1)::double precision
                            WHEN (date_part('year'::text, now())::integer % 2) = 0 THEN date_part('year'::text, now())
                            ELSE NULL::double precision
                        END
                  GROUP BY nml_form_9_1.cmte_id, nml_form_9_1.beg_cvg_dt, nml_form_9_1.end_cvg_dt, nml_form_9_1.pub_distrib_dt)) AND nml_form_9.delete_ind IS NULL
        UNION
         SELECT nml_form_9.form_tp,
            nml_form_9.cmte_id,
            nml_form_9.ind_org_corp_nm,
            nml_form_9.ind_org_corp_st1,
            nml_form_9.ind_org_corp_st2,
            nml_form_9.ind_org_corp_city,
            nml_form_9.ind_org_corp_st,
            nml_form_9.ind_org_corp_zip,
            nml_form_9.addr_chg_flg,
            nml_form_9.ind_org_corp_emp,
            nml_form_9.ind_org_corp_occup,
            nml_form_9.beg_cvg_dt,
            nml_form_9.end_cvg_dt,
            nml_form_9.pub_distrib_dt,
            nml_form_9.qual_nonprofit_flg,
            nml_form_9.segr_bank_acct_flg,
            nml_form_9.ind_custod_nm,
            nml_form_9.ind_custod_st1,
            nml_form_9.ind_custod_st2,
            nml_form_9.ind_custod_city,
            nml_form_9.ind_custod_st,
            nml_form_9.ind_custod_zip,
            nml_form_9.ind_custod_emp,
            nml_form_9.ind_custod_occup,
            nml_form_9.ttl_dons_this_stmt,
            nml_form_9.ttl_disb_this_stmt,
            nml_form_9.filer_sign_nm,
            nml_form_9.filer_sign_dt,
            nml_form_9.sub_id,
            nml_form_9.begin_image_num,
            nml_form_9.end_image_num,
            nml_form_9.form_tp_desc,
            nml_form_9.ind_org_corp_st_desc,
            nml_form_9.addr_chg_flg_desc,
            nml_form_9.qual_nonprofit_flg_desc,
            nml_form_9.segr_bank_acct_flg_desc,
            nml_form_9.ind_custod_st_desc,
            nml_form_9.image_tp,
            nml_form_9.load_status,
            nml_form_9.last_update_dt,
            nml_form_9.delete_ind,
            nml_form_9.amndt_ind,
            nml_form_9.comm_title,
            nml_form_9.receipt_dt,
            nml_form_9.file_num,
            nml_form_9.rpt_yr,
            nml_form_9.prev_file_num,
            nml_form_9.mst_rct_file_num,
            nml_form_9.rpt_tp,
            nml_form_9.entity_tp,
            nml_form_9.filer_cd,
            nml_form_9.filer_cd_desc,
            nml_form_9.indv_l_nm,
            nml_form_9.indv_f_nm,
            nml_form_9.indv_m_nm,
            nml_form_9.indv_prefix,
            nml_form_9.indv_suffix,
            nml_form_9.cust_l_nm,
            nml_form_9.cust_f_nm,
            nml_form_9.cust_m_nm,
            nml_form_9.cust_prefix,
            nml_form_9.cust_suffix,
            nml_form_9.filer_l_nm,
            nml_form_9.filer_f_nm,
            nml_form_9.filer_m_nm,
            nml_form_9.filer_prefix,
            nml_form_9.filer_suffix
           FROM disclosure.nml_form_9
          WHERE (nml_form_9.sub_id IN ( SELECT vs.orig_sub_id
                   FROM disclosure.v_sum_and_det_sum_report vs
                  WHERE vs.rpt_yr >= 2007::numeric AND vs.rpt_yr::double precision <=
                        CASE
                            WHEN (date_part('year'::text, now())::integer % 2) = 1 THEN date_part('year'::text, now()) - 1::double precision
                            WHEN (date_part('year'::text, now())::integer % 2) = 0 THEN date_part('year'::text, now()) - 2::double precision
                            ELSE NULL::double precision
                        END))
        )
 SELECT form_9_vw.cand_id,
    form_9_vw.cand_name,
    form_9_vw.cand_office,
    form_9_vw.cand_office_st,
    form_9_vw.cand_office_district,
    form_9_vw.cmte_id,
    form_9_vw.cmte_nm,
    form_9_vw.sb_image_num,
    form_9_vw.payee_nm,
    form_9_vw.payee_st1,
    form_9_vw.payee_city,
    form_9_vw.payee_st,
    form_9_vw.disb_desc,
    form_9_vw.disb_dt,
    form_9_vw.comm_dt,
    form_9_vw.pub_distrib_dt,
    form_9_vw.reported_disb_amt,
        CASE
            WHEN form_9_vw.number_of_candidates = 0 THEN 1::bigint
            ELSE form_9_vw.number_of_candidates
        END AS number_of_candidates,
    round(form_9_vw.calculated_cand_share /
        CASE
            WHEN form_9_vw.number_of_candidates = 0 THEN 1::bigint
            ELSE form_9_vw.number_of_candidates
        END::numeric, 2) AS calculated_cand_share,
    form_9_vw.sub_id,
    form_9_vw.link_id,
    form_9_vw.rpt_yr,
    form_9_vw.sb_link_id,
    form_9_vw.f9_begin_image_num,
    form_9_vw.receipt_dt,
    form_9_vw.election_tp,
    form_9_vw.file_num,
    form_9_vw.amndt_ind
   FROM ( SELECT f94.sb_link_id,
            f94.sub_id,
            f94.link_id,
            f9.cmte_id,
            cmv.cmte_nm,
            sb.image_num AS sb_image_num,
            sb.recipient_nm AS payee_nm,
            sb.recipient_st1 AS payee_st1,
            sb.recipient_city AS payee_city,
            sb.recipient_st AS payee_st,
            sb.disb_desc,
            sb.disb_dt,
            sb.comm_dt,
            sb.disb_amt AS reported_disb_amt,
            ( SELECT count(*) AS count
                   FROM disclosure.nml_form_94 f94_nc
                  WHERE f94_nc.link_id = f9.sub_id AND f94_nc.sb_link_id = sb.sub_id AND f94_nc.delete_ind IS NULL AND sb.delete_ind IS NULL) AS number_of_candidates,
            sb.disb_amt AS calculated_cand_share,
            f94.cand_id,
            cnv.cand_name,
            cnv.cand_office,
            cnv.cand_office_st,
            cnv.cand_office_district,
            f9.rpt_yr,
            f9.pub_distrib_dt,
            f9.begin_image_num AS f9_begin_image_num,
            f9.receipt_dt,
            f94.election_tp,
            f9.file_num,
            f9.amndt_ind
           FROM f9
             JOIN disclosure.nml_sched_b sb ON sb.link_id = f9.sub_id
             JOIN disclosure.nml_form_94 f94 ON f94.link_id = f9.sub_id AND f94.sb_link_id = sb.sub_id AND COALESCE(f94.amndt_ind, 'X'::character varying)::text <> 'D'::text AND f94.delete_ind IS NULL
             JOIN disclosure.cmte_valid_fec_yr cmv ON cmv.cmte_id::text = f9.cmte_id::text AND cmv.fec_election_yr = (f9.rpt_yr + f9.rpt_yr % 2::numeric)
             LEFT JOIN disclosure.cand_valid_fec_yr cnv ON cnv.cand_id::text = f94.cand_id::text AND cnv.fec_election_yr = (f9.rpt_yr + f9.rpt_yr % 2::numeric)) form_9_vw;

ALTER TABLE public.electioneering_com_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.electioneering_com_vw TO fec;
GRANT SELECT ON TABLE public.electioneering_com_vw TO fec_read;

-- Adding column to disclosure.nml_form_9
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.nml_form_9 RENAME COLUMN pg_date TO pg_date_bk');
    EXCEPTION 
             WHEN undefined_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.nml_form_9 ADD COLUMN IF NOT EXISTS orig_amndt_dt timestamp without time zone;
ALTER TABLE disclosure.nml_form_9 ADD COLUMN IF NOT EXISTS pg_date timestamp without time zone DEFAULT now();
UPDATE disclosure.nml_form_9 SET pg_date = pg_date_bk;

ALTER TABLE disclosure.nml_form_9 DROP COLUMN IF EXISTS pg_date_bk;


-- Adding column to real_efile.f9
ALTER TABLE real_efile.f9 ADD COLUMN IF NOT EXISTS orig_amndt_dt timestamp without time zone;

-- Adding column to real_pfile.f9
ALTER TABLE real_pfile.f9 ADD COLUMN IF NOT EXISTS orig_amndt_dt timestamp without time zone;
