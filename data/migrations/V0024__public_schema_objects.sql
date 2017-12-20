SET search_path = public, pg_catalog;

--
-- Name: efiling_amendment_chain_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW efiling_amendment_chain_vw AS
 WITH RECURSIVE oldest_filing AS (
         SELECT reps.repid,
            reps.comid,
            reps.previd,
            ARRAY[reps.repid] AS amendment_chain,
            1 AS depth,
            reps.repid AS last
           FROM real_efile.reps
          WHERE (reps.previd IS NULL)
        UNION
         SELECT se.repid,
            se.comid,
            se.previd,
            ((oldest.amendment_chain || se.repid))::numeric(12,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            real_efile.reps se
          WHERE ((se.previd = oldest.repid) AND (se.previd IS NOT NULL))
        ), latest AS (
         SELECT sub_query.repid,
            sub_query.comid,
            sub_query.previd,
            sub_query.amendment_chain,
            sub_query.depth,
            sub_query.last,
            sub_query.rank
           FROM ( SELECT oldest_filing.repid,
                    oldest_filing.comid,
                    oldest_filing.previd,
                    oldest_filing.amendment_chain,
                    oldest_filing.depth,
                    oldest_filing.last,
                    rank() OVER (PARTITION BY oldest_filing.last ORDER BY oldest_filing.depth DESC) AS rank
                   FROM oldest_filing) sub_query
          WHERE (sub_query.rank = 1)
        )
 SELECT of.repid,
    of.comid,
    of.previd,
    of.amendment_chain,
    of.depth,
    of.last,
    late.repid AS most_recent_filing,
    late.amendment_chain AS longest_chain
   FROM (oldest_filing of
     JOIN latest late ON ((of.last = late.last)));


ALTER TABLE efiling_amendment_chain_vw OWNER TO fec;

--
-- Name: electioneering_com_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW electioneering_com_vw AS
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
            nml_form_9.filer_suffix,
            nml_form_9.pg_date
           FROM disclosure.nml_form_9
          WHERE ((((nml_form_9.cmte_id)::text, nml_form_9.beg_cvg_dt, nml_form_9.end_cvg_dt, nml_form_9.pub_distrib_dt, nml_form_9.receipt_dt) IN ( SELECT nml_form_9_1.cmte_id,
                    nml_form_9_1.beg_cvg_dt,
                    nml_form_9_1.end_cvg_dt,
                    nml_form_9_1.pub_distrib_dt,
                    max(nml_form_9_1.receipt_dt) AS max
                   FROM disclosure.nml_form_9 nml_form_9_1
                  WHERE (((nml_form_9_1.rpt_yr)::double precision >=
                        CASE
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 1) THEN date_part('year'::text, now())
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 0) THEN (date_part('year'::text, now()) - (1)::double precision)
                            ELSE NULL::double precision
                        END) AND ((nml_form_9_1.rpt_yr)::double precision <=
                        CASE
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 1) THEN (((date_part('year'::text, now()))::integer + 1))::double precision
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 0) THEN date_part('year'::text, now())
                            ELSE NULL::double precision
                        END))
                  GROUP BY nml_form_9_1.cmte_id, nml_form_9_1.beg_cvg_dt, nml_form_9_1.end_cvg_dt, nml_form_9_1.pub_distrib_dt)) AND (nml_form_9.delete_ind IS NULL))
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
            nml_form_9.filer_suffix,
            nml_form_9.pg_date
           FROM disclosure.nml_form_9
          WHERE (nml_form_9.sub_id IN ( SELECT vs.orig_sub_id
                   FROM disclosure.v_sum_and_det_sum_report vs
                  WHERE ((vs.rpt_yr >= (2007)::numeric) AND ((vs.rpt_yr)::double precision <=
                        CASE
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 1) THEN (date_part('year'::text, now()) - (1)::double precision)
                            WHEN (((date_part('year'::text, now()))::integer % 2) = 0) THEN (date_part('year'::text, now()) - (2)::double precision)
                            ELSE NULL::double precision
                        END))))
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
            WHEN (form_9_vw.number_of_candidates = 0) THEN (1)::bigint
            ELSE form_9_vw.number_of_candidates
        END AS number_of_candidates,
    round((form_9_vw.calculated_cand_share / (
        CASE
            WHEN (form_9_vw.number_of_candidates = 0) THEN (1)::bigint
            ELSE form_9_vw.number_of_candidates
        END)::numeric), 2) AS calculated_cand_share,
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
                  WHERE ((f94_nc.link_id = f9.sub_id) AND (f94_nc.sb_link_id = sb.sub_id) AND (f94_nc.delete_ind IS NULL) AND (sb.delete_ind IS NULL))) AS number_of_candidates,
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
           FROM ((((f9
             JOIN disclosure.nml_sched_b sb ON ((sb.link_id = f9.sub_id)))
             JOIN disclosure.nml_form_94 f94 ON (((f94.link_id = f9.sub_id) AND (f94.sb_link_id = sb.sub_id) AND ((COALESCE(f94.amndt_ind, 'X'::character varying))::text <> 'D'::text) AND (f94.delete_ind IS NULL))))
             JOIN disclosure.cmte_valid_fec_yr cmv ON ((((cmv.cmte_id)::text = (f9.cmte_id)::text) AND (cmv.fec_election_yr = (f9.rpt_yr + (f9.rpt_yr % (2)::numeric))))))
             LEFT JOIN disclosure.cand_valid_fec_yr cnv ON ((((cnv.cand_id)::text = (f94.cand_id)::text) AND (cnv.fec_election_yr = (f9.rpt_yr + (f9.rpt_yr % (2)::numeric))))))) form_9_vw;


ALTER TABLE electioneering_com_vw OWNER TO fec;

--
-- Name: entity_disbursements_chart; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE entity_disbursements_chart (
    idx bigint,
    type text,
    month double precision,
    year double precision,
    cycle numeric,
    adjusted_total_disbursements numeric,
    sum numeric
);


ALTER TABLE entity_disbursements_chart OWNER TO fec;

--
-- Name: entity_receipts_chart; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE entity_receipts_chart (
    idx bigint,
    type text,
    month double precision,
    year double precision,
    cycle numeric,
    adjusted_total_receipts double precision,
    sum double precision
);


ALTER TABLE entity_receipts_chart OWNER TO fec;

--
-- Name: fec_f24_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f24_notice_vw AS
 SELECT f24.cmte_id,
    f24.cmte_nm,
    f24.cmte_st1,
    f24.cmte_st2,
    f24.cmte_city,
    f24.cmte_st,
    f24.cmte_zip,
    f24.amndt_ind,
    f24.orig_amndt_dt,
    f24.rpt_tp,
    f24.rpt_tp_desc,
    f24.rpt_yr,
    f24.receipt_dt,
    (f24.rpt_yr + mod(f24.rpt_yr, (2)::numeric)) AS cycle,
    f24.tres_sign_nm,
    f24.tres_l_nm,
    f24.tres_f_nm,
    f24.tres_m_nm,
    f24.tres_prefix,
    f24.tres_suffix,
    f24.tres_sign_dt,
    f24.sub_id,
    f24.begin_image_num,
    f24.end_image_num,
    f24.form_tp,
    f24.form_tp_desc,
    f24.file_num,
    f24.prev_file_num,
    f24.mst_rct_file_num
   FROM disclosure.nml_form_24 f24
  WHERE (f24.delete_ind IS NULL);


ALTER TABLE fec_f24_notice_vw OWNER TO fec;

--
-- Name: fec_f56_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f56_notice_vw AS
 SELECT f56.filer_cmte_id,
    f56.entity_tp,
    f56.entity_tp_desc,
    f56.contbr_nm,
    f56.contbr_l_nm,
    f56.contbr_f_nm,
    f56.contbr_m_nm,
    f56.contbr_prefix,
    f56.contbr_suffix,
    f56.contbr_st1,
    f56.contbr_st2,
    f56.conbtr_city,
    f56.contbr_st,
    f56.contbr_zip,
    f56.contbr_employer,
    f56.contbr_occupation,
    f56.contb_dt,
    f56.contb_amt,
    f56.cand_id,
    f56.cand_nm,
    f56.cand_office,
    f56.cand_office_desc,
    f56.cand_office_st,
    f56.cand_office_st_desc,
    f56.cand_office_district,
    f56.conduit_cmte_id,
    f56.conduit_nm,
    f56.conduit_st1,
    f56.conduit_st2,
    f56.conduit_city,
    f56.conduit_st,
    f56.conduit_zip,
    f56.amndt_ind,
    f56.amndt_ind_desc,
        CASE
            WHEN ("substring"(((f56.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f56.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F5'::character varying(8) AS filing_form,
    'SA-F56'::character varying(8) AS schedule_type,
    f56.form_tp_desc AS schedule_type_desc,
    f56.image_num,
    f56.file_num,
    f56.sub_id,
    f56.link_id,
    f56.orig_sub_id,
    f5.rpt_yr,
    f5.rpt_tp,
    (f5.rpt_yr + mod(f5.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_56 f56,
    disclosure.nml_form_5 f5
  WHERE ((f56.link_id = f5.sub_id) AND ((f5.rpt_tp)::text = ANY (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])) AND ((f56.amndt_ind)::text <> 'D'::text) AND (f56.delete_ind IS NULL) AND (f5.delete_ind IS NULL));


ALTER TABLE fec_f56_notice_vw OWNER TO fec;

--
-- Name: fec_f57_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f57_notice_vw AS
 SELECT f57.filer_cmte_id,
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
    f57.exp_purpose,
    f57.entity_tp,
    f57.entity_tp_desc,
    f57.catg_cd,
    f57.catg_cd_desc,
    f57.s_o_cand_id,
    f57.s_o_cand_l_nm,
    f57.s_o_cand_f_nm,
    f57.s_o_cand_m_nm,
    f57.s_o_cand_prefix,
    f57.s_o_cand_suffix,
    f57.s_o_cand_nm,
    f57.s_o_cand_office,
    f57.s_o_cand_office_desc,
    f57.s_o_cand_office_st,
    f57.s_o_cand_office_state_desc,
    f57.s_o_cand_office_district,
    f57.s_o_ind,
    f57.s_o_ind_desc,
    f57.election_tp,
    f57.fec_election_tp_desc,
    f57.fec_election_yr,
    f57.election_tp_desc,
    f57.cal_ytd_ofc_sought,
    f57.exp_dt,
    f57.exp_amt,
    f57.exp_tp,
    f57.exp_tp_desc,
    f57.conduit_cmte_id,
    f57.conduit_cmte_nm,
    f57.conduit_cmte_st1,
    f57.conduit_cmte_st2,
    f57.conduit_cmte_city,
    f57.conduit_cmte_st,
    f57.conduit_cmte_zip,
    f57.amndt_ind AS action_cd,
    f57.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f57.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f57.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F5'::character varying(8) AS filing_form,
    'SE-F57'::character varying(8) AS schedule_type,
    f57.form_tp_desc AS schedule_type_desc,
    f57.image_num,
    f57.file_num,
    f57.sub_id,
    f57.link_id,
    f57.orig_sub_id,
    f5.rpt_yr,
    f5.rpt_tp,
    (f5.rpt_yr + mod(f5.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_57 f57,
    disclosure.nml_form_5 f5
  WHERE ((f57.link_id = f5.sub_id) AND ((f5.rpt_tp)::text = ANY (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])) AND ((f57.amndt_ind)::text <> 'D'::text) AND (f57.delete_ind IS NULL) AND (f5.delete_ind IS NULL));


ALTER TABLE fec_f57_notice_vw OWNER TO fec;

--
-- Name: fec_f5_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f5_notice_vw AS
 SELECT f5.indv_org_id,
    f5.indv_org_nm,
    f5.indv_l_nm,
    f5.indv_f_nm,
    f5.indv_m_nm,
    f5.indv_prefix,
    f5.indv_suffix,
    f5.indv_org_st1,
    f5.indv_org_st2,
    f5.indv_org_city,
    f5.indv_org_st,
    f5.indv_org_zip,
    f5.entity_tp,
    f5.addr_chg_flg,
    f5.qual_nonprofit_corp_ind,
    f5.indv_org_employer,
    f5.indv_org_occupation,
    f5.amndt_ind,
    f5.amndt_ind_desc,
    f5.orig_amndt_dt,
    f5.rpt_tp,
    f5.rpt_tp_desc,
    f5.rpt_pgi,
    f5.rpt_pgi_desc,
    f5.cvg_start_dt,
    f5.cvg_end_dt,
    f5.rpt_yr,
    f5.receipt_dt,
    (f5.rpt_yr + mod(f5.rpt_yr, (2)::numeric)) AS cycle,
    f5.ttl_indt_contb,
    f5.ttl_indt_exp,
    f5.filer_nm,
    f5.filer_sign_nm,
    f5.filer_sign_dt,
    f5.filer_l_nm,
    f5.filer_f_nm,
    f5.filer_m_nm,
    f5.filer_prefix,
    f5.filer_suffix,
    f5.notary_sign_dt,
    f5.notary_commission_exprtn_dt,
    f5.notary_nm,
    f5.sub_id,
    f5.begin_image_num,
    f5.end_image_num,
    'F5'::character varying(8) AS form_tp,
    f5.form_tp_desc,
    f5.file_num,
    f5.prev_file_num,
    f5.mst_rct_file_num
   FROM disclosure.nml_form_5 f5
  WHERE ((f5.delete_ind IS NULL) AND ((f5.rpt_tp)::text = ANY (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])));


ALTER TABLE fec_f5_notice_vw OWNER TO fec;

--
-- Name: fec_f65_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f65_notice_vw AS
 SELECT f65.filer_cmte_id,
    f65.contbr_lender_nm,
    f65.contbr_l_nm,
    f65.contbr_f_nm,
    f65.contbr_m_nm,
    f65.contbr_prefix,
    f65.contbr_suffix,
    f65.contbr_lender_st1,
    f65.contbr_lender_st2,
    f65.contbr_lender_city,
    f65.contbr_lender_st,
    f65.contbr_lender_zip,
    f65.contbr_lender_employer,
    f65.contbr_lender_occupation,
    f65.entity_tp,
    f65.entity_tp_desc,
    f65.contb_dt,
    f65.contb_amt,
    f65.cand_id,
    f65.cand_nm,
    f65.cand_office,
    f65.cand_office_desc,
    f65.cand_office_st,
    f65.cand_office_st_desc,
    f65.cand_office_district,
    f65.conduit_cmte_id,
    f65.conduit_cmte_nm,
    f65.conduit_cmte_st1,
    f65.conduit_cmte_st2,
    f65.conduit_cmte_city,
    f65.conduit_cmte_st,
    f65.conduit_cmte_zip,
    f65.amndt_ind AS action_cd,
    f65.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f65.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f65.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    f65.receipt_dt,
    'F6'::character varying(8) AS filing_form,
    'SA-F65'::character varying(8) AS schedule_type,
    f65.form_tp_desc AS schedule_type_desc,
    f65.image_num,
    f65.file_num,
    f65.sub_id,
    f65.link_id,
    f65.orig_sub_id,
    f6.rpt_yr,
    (f6.rpt_yr + mod(f6.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_65 f65,
    disclosure.nml_form_6 f6
  WHERE ((f65.link_id = f6.sub_id) AND ((f65.amndt_ind)::text <> 'D'::text) AND (f65.delete_ind IS NULL) AND (f6.delete_ind IS NULL));


ALTER TABLE fec_f65_notice_vw OWNER TO fec;

--
-- Name: fec_f6_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_f6_notice_vw AS
 SELECT f6.filer_cmte_id,
    f6.filer_cmte_nm,
    f6.filer_cmte_st1,
    f6.filer_cmte_st2,
    f6.filer_cmte_city,
    f6.filer_cmte_st,
    f6.filer_cmte_zip,
    f6.cand_id,
    f6.cand_nm,
    f6.cand_l_nm,
    f6.cand_f_nm,
    f6.cand_m_nm,
    f6.cand_prefix,
    f6.cand_suffix,
    f6.cand_office,
    f6.cand_office_desc,
    f6.cand_office_st,
    f6.cand_office_st_desc,
    f6.cand_office_district,
    f6.amndt_ind,
    f6.orig_amndt_dt,
    f6.rpt_yr,
    f6.receipt_dt,
    (f6.rpt_yr + mod(f6.rpt_yr, (2)::numeric)) AS cycle,
    f6.sign_dt,
    f6.signer_last_name,
    f6.signer_first_name,
    f6.signer_middle_name,
    f6.signer_prefix,
    f6.signer_suffix,
    f6.sub_id,
    f6.begin_image_num,
    f6.end_image_num,
    f6.form_tp,
    f6.form_tp_desc,
    f6.file_num,
    f6.prev_file_num,
    f6.mst_rct_file_num
   FROM disclosure.nml_form_6 f6
  WHERE (f6.delete_ind IS NULL);


ALTER TABLE fec_f6_notice_vw OWNER TO fec;

--
-- Name: fec_fitem_f105_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f105_vw AS
 SELECT f105.filer_cmte_id,
    f105.exp_dt,
    f105.election_tp,
    f105.election_tp_desc,
    f105.fec_election_tp_desc,
    f105.exp_amt,
    f105.loan_chk_flg,
    f105.amndt_ind AS action_cd,
    f105.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f105.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f105.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F105'::character varying(8) AS schedule_type,
    f105.form_tp_desc AS schedule_type_desc,
    f105.image_num,
    f105.file_num,
    f105.link_id,
    f105.orig_sub_id,
    f105.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_105 f105,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f105.sub_id = fi.sub_id) AND ((f105.amndt_ind)::text <> 'D'::text) AND (f105.delete_ind IS NULL));


ALTER TABLE fec_fitem_f105_vw OWNER TO fec;

--
-- Name: fec_fitem_f56_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f56_vw AS
 SELECT f56.filer_cmte_id,
    f56.entity_tp,
    f56.entity_tp_desc,
    f56.contbr_nm,
    f56.contbr_l_nm,
    f56.contbr_f_nm,
    f56.contbr_m_nm,
    f56.contbr_prefix,
    f56.contbr_suffix,
    f56.contbr_st1,
    f56.contbr_st2,
    f56.conbtr_city,
    f56.contbr_st,
    f56.contbr_zip,
    f56.contbr_employer,
    f56.contbr_occupation,
    f56.contb_dt,
    f56.contb_amt,
    f56.cand_id,
    f56.cand_nm,
    f56.cand_office,
    f56.cand_office_desc,
    f56.cand_office_st,
    f56.cand_office_st_desc,
    f56.cand_office_district,
    f56.conduit_cmte_id,
    f56.conduit_nm,
    f56.conduit_st1,
    f56.conduit_st2,
    f56.conduit_city,
    f56.conduit_st,
    f56.conduit_zip,
    f56.amndt_ind AS action_cd,
    f56.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f56.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f56.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SA-F56'::character varying(8) AS schedule_type,
    f56.form_tp_desc AS schedule_type_desc,
    f56.image_num,
    f56.file_num,
    f56.link_id,
    f56.orig_sub_id,
    f56.sub_id,
    'F5'::character varying(8) AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + mod(fi.rpt_yr, (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_56 f56,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f56.sub_id = fi.sub_id) AND ((fi.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])) AND ((f56.amndt_ind)::text <> 'D'::text) AND (f56.delete_ind IS NULL));


ALTER TABLE fec_fitem_f56_vw OWNER TO fec;

--
-- Name: fec_fitem_f57_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f57_vw AS
 SELECT f57.filer_cmte_id,
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
    f57.exp_purpose,
    f57.entity_tp,
    f57.entity_tp_desc,
    f57.catg_cd,
    f57.catg_cd_desc,
    f57.s_o_cand_id,
    f57.s_o_cand_l_nm,
    f57.s_o_cand_f_nm,
    f57.s_o_cand_m_nm,
    f57.s_o_cand_prefix,
    f57.s_o_cand_suffix,
    f57.s_o_cand_nm,
    f57.s_o_cand_office,
    f57.s_o_cand_office_desc,
    f57.s_o_cand_office_st,
    f57.s_o_cand_office_state_desc,
    f57.s_o_cand_office_district,
    f57.s_o_ind,
    f57.s_o_ind_desc,
    f57.election_tp,
    f57.fec_election_tp_desc,
    f57.fec_election_yr,
    f57.election_tp_desc,
    f57.cal_ytd_ofc_sought,
    f57.exp_dt,
    f57.exp_amt,
    f57.exp_tp,
    f57.exp_tp_desc,
    f57.conduit_cmte_id,
    f57.conduit_cmte_nm,
    f57.conduit_cmte_st1,
    f57.conduit_cmte_st2,
    f57.conduit_cmte_city,
    f57.conduit_cmte_st,
    f57.conduit_cmte_zip,
    f57.amndt_ind AS action_cd,
    f57.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f57.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f57.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SE-F57'::character varying(8) AS schedule_type,
    f57.form_tp_desc AS schedule_type_desc,
    f57.link_id,
    f57.image_num,
    f57.file_num,
    f57.orig_sub_id,
    f57.sub_id,
    'F5'::character varying(8) AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + mod(fi.rpt_yr, (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_57 f57,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f57.sub_id = fi.sub_id) AND ((fi.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])) AND ((f57.amndt_ind)::text <> 'D'::text) AND (f57.delete_ind IS NULL));


ALTER TABLE fec_fitem_f57_vw OWNER TO fec;

--
-- Name: fec_fitem_f76_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f76_vw AS
 SELECT f76.org_id,
    f76.communication_tp,
    f76.communication_tp_desc,
    f76.communication_class,
    f76.communication_class_desc,
    f76.communication_dt,
    f76.s_o_ind,
    f76.s_o_ind_desc,
    f76.s_o_cand_id,
    f76.s_o_cand_nm,
    f76.s_o_cand_l_nm,
    f76.s_o_cand_f_nm,
    f76.s_o_cand_m_nm,
    f76.s_o_cand_prefix,
    f76.s_o_cand_suffix,
    f76.s_o_cand_office,
    f76.s_o_cand_office_desc,
    f76.s_o_cand_office_st,
    f76.s_o_cand_office_st_desc,
    f76.s_o_cand_office_district,
    f76.s_o_rpt_pgi,
    f76.s_o_rpt_pgi_desc,
    f76.communication_cost,
    f76.election_other_desc,
    f76.transaction_tp,
    f76.amndt_ind AS action_cd,
    f76.amndt_ind_desc AS action_cd_desc,
    f76.tran_id,
    'F76'::character varying(8) AS schedule_type,
    f76.form_tp_desc AS schedule_type_desc,
    f76.image_num,
    f76.file_num,
    f76.link_id,
    f76.orig_sub_id,
    f76.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_76 f76,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f76.sub_id = fi.sub_id) AND ((f76.amndt_ind)::text <> 'D'::text) AND (f76.delete_ind IS NULL));


ALTER TABLE fec_fitem_f76_vw OWNER TO fec;

--
-- Name: fec_fitem_f91_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f91_vw AS
 SELECT f91.filer_cmte_id,
    f91.shr_ex_ctl_ind_nm,
    f91.shr_ex_ctl_l_nm,
    f91.shr_ex_ctl_f_nm,
    f91.shr_ex_ctl_m_nm,
    f91.shr_ex_ctl_prefix,
    f91.shr_ex_ctl_suffix,
    f91.shr_ex_ctl_street1,
    f91.shr_ex_ctl_street2,
    f91.shr_ex_ctl_city,
    f91.shr_ex_ctl_st,
    f91.shr_ex_ctl_st_desc,
    f91.shr_ex_ctl_zip,
    f91.shr_ex_ctl_employ,
    f91.shr_ex_ctl_occup,
    f91.amndt_ind AS action_cd,
    f91.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f91.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f91.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F91'::character varying(8) AS schedule_type,
    f91.form_tp_desc AS schedule_type_desc,
    f91.begin_image_num,
    f91.file_num,
    f91.link_id,
    f91.orig_sub_id,
    f91.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_91 f91,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f91.sub_id = fi.sub_id) AND ((f91.amndt_ind)::text <> 'D'::text) AND (f91.delete_ind IS NULL));


ALTER TABLE fec_fitem_f91_vw OWNER TO fec;

--
-- Name: fec_fitem_f94_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_f94_vw AS
 SELECT f94.filer_cmte_id,
    f94.cand_id,
    f94.cand_nm,
    f94.cand_l_nm,
    f94.cand_f_nm,
    f94.cand_m_nm,
    f94.cand_prefix,
    f94.cand_suffix,
    f94.cand_office,
    f94.cand_office_desc,
    f94.cand_office_st,
    f94.cand_office_st_desc,
    f94.cand_office_district,
    f94.election_tp,
    f94.election_tp_desc,
    f94.fec_election_tp_desc,
    f94.amndt_ind AS action_cd,
    f94.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'F94'::character varying(8) AS schedule_type,
    f94.form_tp_desc AS schedule_type_desc,
    f94.begin_image_num,
    f94.sb_link_id,
    f94.file_num,
    f94.link_id,
    f94.orig_sub_id,
    f94.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_94 f94,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((f94.sub_id = fi.sub_id) AND ((f94.amndt_ind)::text <> 'D'::text) AND (f94.delete_ind IS NULL));


ALTER TABLE fec_fitem_f94_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_a_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_a_vw AS
 SELECT sa.cmte_id,
    sa.cmte_nm,
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
    sa.amndt_ind AS action_cd,
    sa.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    sa.back_ref_sched_nm,
    'SA'::character varying(8) AS schedule_type,
    sa.form_tp_desc AS schedule_type_desc,
    sa.line_num,
    sa.image_num,
    sa.file_num,
    sa.link_id,
    sa.orig_sub_id,
    sa.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_a sa,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sa.sub_id = fi.sub_id) AND ((sa.amndt_ind)::text <> 'D'::text) AND (sa.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_a_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_b_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_b_vw AS
 SELECT sb.cmte_id,
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
    sb.amndt_ind AS action_cd,
    sb.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'SB'::character varying(8) AS schedule_type,
    sb.form_tp_desc AS schedule_type_desc,
    sb.line_num,
    sb.image_num,
    sb.file_num,
    sb.link_id,
    sb.orig_sub_id,
    sb.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_b sb,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sb.sub_id = fi.sub_id) AND ((sb.amndt_ind)::text <> 'D'::text) AND (sb.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_b_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_c1_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_c1_vw AS
 SELECT sc1.cmte_id,
    sc1.cmte_nm,
    sc1.entity_tp_desc,
    sc1.loan_src_nm,
    sc1.loan_src_st1,
    sc1.loan_src_st2,
    sc1.loan_src_city,
    sc1.loan_src_st,
    sc1.loan_src_zip,
    sc1.entity_tp,
    sc1.loan_amt,
    sc1.interest_rate_pct,
    sc1.incurred_dt,
    sc1.due_dt,
    sc1.loan_restructured_flg,
    sc1.orig_loan_dt,
    sc1.credit_amt_this_draw,
    sc1.ttl_bal,
    sc1.other_liable_pty_flg,
    sc1.collateral_flg,
    sc1.collateral_desc,
    sc1.collateral_value,
    sc1.perfected_interest_flg,
    sc1.future_income_flg,
    sc1.future_income_desc,
    sc1.future_income_est_value,
    sc1.depository_acct_est_dt,
    sc1.acct_loc_nm,
    sc1.acct_loc_st1,
    sc1.acct_loc_st2,
    sc1.acct_loc_city,
    sc1.acct_loc_st,
    sc1.acct_loc_zip,
    sc1.depository_acct_auth_dt,
    sc1.loan_basis_desc,
    sc1.tres_sign_nm,
    sc1.tres_l_nm,
    sc1.tres_f_nm,
    sc1.tres_m_nm,
    sc1.tres_prefix,
    sc1.tres_suffix,
    sc1.tres_sign_dt,
    sc1.auth_sign_nm,
    sc1.auth_sign_l_nm,
    sc1.auth_sign_f_nm,
    sc1.auth_sign_m_nm,
    sc1.auth_sign_prefix,
    sc1.auth_sign_suffix,
    sc1.auth_rep_title,
    sc1.auth_sign_dt,
    sc1.amndt_ind AS action_cd,
    sc1.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sc1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc1.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sc1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc1.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    'SC1'::character varying(8) AS schedule_type,
    sc1.form_tp_desc AS schedule_type_desc,
    sc1.line_num,
    sc1.image_num,
    sc1.file_num,
    sc1.link_id,
    sc1.orig_sub_id,
    sc1.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_c1 sc1,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sc1.sub_id = fi.sub_id) AND ((sc1.amndt_ind)::text <> 'D'::text) AND (sc1.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_c1_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_c2_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_c2_vw AS
 SELECT sc2.cmte_id,
    sc2.back_ref_tran_id,
    sc2.guar_endr_nm,
    sc2.guar_endr_l_nm,
    sc2.guar_endr_f_nm,
    sc2.guar_endr_m_nm,
    sc2.guar_endr_prefix,
    sc2.guar_endr_suffix,
    sc2.guar_endr_st1,
    sc2.guar_endr_st2,
    sc2.guar_endr_city,
    sc2.guar_endr_st,
    sc2.guar_endr_zip,
    sc2.guar_endr_employer,
    sc2.guar_endr_occupation,
    sc2.amt_guaranteed_outstg,
    sc2.receipt_dt,
    sc2.amndt_ind AS action_cd,
    sc2.amndt_ind_desc AS action_cd_desc,
    sc2.file_num,
        CASE
            WHEN ("substring"(((sc2.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc2.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    fi.form_tp_cd AS filing_form,
    'SC2'::character varying(8) AS schedule_type,
    sc2.form_tp_desc AS schedule_type_desc,
    sc2.line_num,
    sc2.image_num,
    sc2.sub_id,
    sc2.link_id,
    sc2.orig_sub_id,
    fi.rpt_yr,
    fi.rpt_tp,
    (fi.rpt_yr + mod(fi.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_sched_c2 sc2,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sc2.sub_id = fi.sub_id) AND ((sc2.amndt_ind)::text <> 'D'::text) AND (sc2.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_c2_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_c_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_c_vw AS
 SELECT sc.cmte_id,
    sc.cmte_nm,
    sc.loan_src_l_nm,
    sc.loan_src_f_nm,
    sc.loan_src_m_nm,
    sc.loan_src_prefix,
    sc.loan_src_suffix,
    sc.loan_src_nm,
    sc.loan_src_st1,
    sc.loan_src_st2,
    sc.loan_src_city,
    sc.loan_src_st,
    sc.loan_src_zip,
    sc.entity_tp,
    sc.entity_tp_desc,
    sc.election_tp,
    sc.fec_election_tp_desc,
    sc.fec_election_tp_year,
    sc.election_tp_desc,
    sc.orig_loan_amt,
    sc.pymt_to_dt,
    sc.loan_bal,
    sc.incurred_dt,
    sc.due_dt_terms,
    sc.interest_rate_terms,
    sc.secured_ind,
    sc.sched_a_line_num,
    sc.pers_fund_yes_no,
    sc.memo_cd,
    sc.memo_text,
    sc.fec_cmte_id,
    sc.cand_id,
    sc.cand_nm,
    sc.cand_nm_first,
    sc.cand_nm_last,
    sc.cand_m_nm,
    sc.cand_prefix,
    sc.cand_suffix,
    sc.cand_office,
    sc.cand_office_desc,
    sc.cand_office_st,
    sc.cand_office_state_desc,
    sc.cand_office_district,
    sc.amndt_ind AS action_cd,
    sc.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sc.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SC'::character varying(8) AS schedule_type,
    sc.form_tp_desc AS schedule_type_desc,
    sc.line_num,
    sc.image_num,
    sc.file_num,
    sc.link_id,
    sc.orig_sub_id,
    sc.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_c sc,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sc.sub_id = fi.sub_id) AND ((sc.amndt_ind)::text <> 'D'::text) AND (sc.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_c_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_d_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_d_vw AS
 SELECT sd.cmte_id,
    sd.cmte_nm,
    sd.cred_dbtr_id,
    sd.cred_dbtr_nm,
    sd.creditor_debtor_name_text,
    sd.cred_dbtr_l_nm,
    sd.cred_dbtr_f_nm,
    sd.cred_dbtr_m_nm,
    sd.cred_dbtr_prefix,
    sd.cred_dbtr_suffix,
    sd.cred_dbtr_st1,
    sd.cred_dbtr_st2,
    sd.cred_dbtr_city,
    sd.cred_dbtr_st,
    sd.cred_dbtr_zip,
    sd.entity_tp,
    sd.nature_debt_purpose,
    sd.outstg_bal_bop,
    sd.amt_incurred_per,
    sd.pymt_per,
    sd.outstg_bal_cop,
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
    sd.amndt_ind AS action_cd,
    sd.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sd.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sd.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SD'::character varying(8) AS schedule_type,
    sd.form_tp_desc AS schedule_type_desc,
    sd.line_num,
    sd.image_num,
    sd.file_num,
    sd.link_id,
    sd.orig_sub_id,
    sd.sub_id,
    sd.pg_date,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_d sd,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sd.sub_id = fi.sub_id) AND ((sd.amndt_ind)::text <> 'D'::text) AND (sd.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_d_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_e_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_e_vw AS
 SELECT se.cmte_id,
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
    se.exp_dt,
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
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'SE'::character varying(8) AS schedule_type,
    se.form_tp_desc AS schedule_type_desc,
    se.line_num,
    se.image_num,
    se.file_num,
    se.link_id,
    se.orig_sub_id,
    se.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_e se,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((se.sub_id = fi.sub_id) AND ((se.amndt_ind)::text <> 'D'::text) AND (se.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_e_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_f_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_f_vw AS
 SELECT sf.cmte_id,
    sf.cmte_nm,
    sf.cmte_desg_coord_exp_ind,
    sf.desg_cmte_id,
    sf.desg_cmte_nm,
    sf.subord_cmte_id,
    sf.subord_cmte_nm,
    sf.subord_cmte_st1,
    sf.subord_cmte_st2,
    sf.subord_cmte_city,
    sf.subord_cmte_st,
    sf.subord_cmte_zip,
    sf.entity_tp,
    sf.entity_tp_desc,
    sf.pye_nm,
    sf.payee_l_nm,
    sf.payee_f_nm,
    sf.payee_m_nm,
    sf.payee_prefix,
    sf.payee_suffix,
    to_tsvector((sf.pye_nm)::text) AS payee_name_text,
    sf.pye_st1,
    sf.pye_st2,
    sf.pye_city,
    sf.pye_st,
    sf.pye_zip,
    sf.aggregate_gen_election_exp,
    sf.exp_tp,
    sf.exp_tp_desc,
    sf.exp_purpose_desc,
    sf.exp_dt,
    sf.exp_amt,
    sf.cand_id,
    sf.cand_nm,
    sf.cand_nm_first,
    sf.cand_nm_last,
    sf.cand_m_nm,
    sf.cand_prefix,
    sf.cand_suffix,
    sf.cand_office,
    sf.cand_office_desc,
    sf.cand_office_st,
    sf.cand_office_st_desc,
    sf.cand_office_district,
    sf.conduit_cmte_id,
    sf.conduit_cmte_nm,
    sf.conduit_cmte_st1,
    sf.conduit_cmte_st2,
    sf.conduit_cmte_city,
    sf.conduit_cmte_st,
    sf.conduit_cmte_zip,
    sf.amndt_ind AS action_cd,
    sf.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    sf.memo_cd,
    sf.memo_cd_desc,
    sf.memo_text,
    sf.unlimited_spending_flg,
    sf.unlimited_spending_flg_desc,
    sf.catg_cd,
    sf.catg_cd_desc,
    'SF'::character varying(8) AS schedule_type,
    sf.form_tp_desc AS schedule_type_desc,
    sf.line_num,
    sf.image_num,
    sf.file_num,
    sf.link_id,
    sf.orig_sub_id,
    sf.sub_id,
    sf.pg_date,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_f sf,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((sf.sub_id = fi.sub_id) AND ((sf.amndt_ind)::text <> 'D'::text) AND (sf.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_f_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h1_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h1_vw AS
 SELECT h1.filer_cmte_id,
    h1.filer_cmte_nm,
    h1.np_fixed_fed_pct,
    h1.hsp_min_fed_pct,
    h1.hsp_est_fed_dir_cand_supp_pct,
    h1.hsp_est_nonfed_cand_supp_pct,
    h1.hsp_actl_fed_dir_cand_supp_amt,
    h1.hsp_actl_nonfed_cand_supp_amt,
    h1.hsp_actl_fed_dir_cand_supp_pct,
    h1.ssf_fed_est_dir_cand_supp_pct,
    h1.ssf_nfed_est_dir_cand_supp_pct,
    h1.ssf_actl_fed_dir_cand_supp_amt,
    h1.ssf_actl_nonfed_cand_supp_amt,
    h1.ssf_actl_fed_dir_cand_supp_pct,
    h1.president_ind,
    h1.us_senate_ind,
    h1.us_congress_ind,
    h1.subttl_fed,
    h1.governor_ind,
    h1.other_st_offices_ind,
    h1.st_senate_ind,
    h1.st_rep_ind,
    h1.local_cand_ind,
    h1.extra_non_fed_point_ind,
    h1.subttl_non_fed,
    h1.ttl_fed_and_nonfed,
    h1.fed_alloctn,
    h1.amndt_ind AS action_cd,
    h1.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h1.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    h1.st_loc_pres_only,
    h1.st_loc_pres_sen,
    h1.st_loc_sen_only,
    h1.st_loc_nonpres_nonsen,
    h1.flat_min_fed_pct,
    h1.fed_pct,
    h1.non_fed_pct,
    h1.admin_ratio_chk,
    h1.gen_voter_drive_chk,
    h1.pub_comm_ref_pty_chk,
    'H1'::character varying(8) AS schedule_type,
    h1.form_tp_desc AS schedule_type_desc,
    h1.image_num,
    h1.file_num,
    h1.link_id,
    h1.orig_sub_id,
    h1.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h1 h1,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h1.sub_id = fi.sub_id) AND ((h1.amndt_ind)::text <> 'D'::text) AND (h1.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h1_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h2_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h2_vw AS
 SELECT h2.filer_cmte_id,
    h2.filer_cmte_nm,
    h2.evt_activity_nm,
    h2.fndsg_acty_flg,
    h2.exempt_acty_flg,
    h2.direct_cand_support_acty_flg,
    h2.ratio_cd,
    h2.ratio_cd_desc,
    h2.fed_pct_amt,
    h2.nonfed_pct_amt,
    h2.amndt_ind AS action_cd,
    h2.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h2.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h2.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'H2'::character varying(8) AS schedule_type,
    h2.form_tp_desc AS schedule_type_desc,
    h2.image_num,
    h2.file_num,
    h2.link_id,
    h2.orig_sub_id,
    h2.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h2 h2,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h2.sub_id = fi.sub_id) AND ((h2.amndt_ind)::text <> 'D'::text) AND (h2.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h2_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h3_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h3_vw AS
 SELECT h3.filer_cmte_id,
    h3.filer_cmte_nm,
    h3.acct_nm,
    h3.evt_nm,
    h3.evt_tp,
    h3.event_tp_desc,
    h3.tranf_dt,
    h3.tranf_amt,
    h3.ttl_tranf_amt,
    h3.amndt_ind AS action_cd,
    h3.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h3.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h3.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h3.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h3.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    'H3'::character varying(8) AS schedule_type,
    h3.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN ((h3.line_num IS NOT NULL) AND (fi.rpt_yr <= (2004)::numeric)) THEN h3.line_num
            WHEN ((h3.line_num IS NULL) AND (fi.rpt_yr <= (2004)::numeric)) THEN '18'::character varying
            WHEN ((h3.line_num IS NOT NULL) AND (fi.rpt_yr >= (2005)::numeric)) THEN h3.line_num
            WHEN ((h3.line_num IS NULL) AND (fi.rpt_yr >= (2005)::numeric)) THEN '18A'::character varying
            ELSE NULL::character varying
        END AS line_num,
    h3.image_num,
    h3.file_num,
    h3.link_id,
    h3.orig_sub_id,
    h3.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h3 h3,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h3.sub_id = fi.sub_id) AND ((h3.amndt_ind)::text <> 'D'::text) AND (h3.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h3_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h4_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h4_vw AS
 SELECT h4.filer_cmte_id,
    h4.filer_cmte_nm,
    h4.entity_tp,
    h4.entity_tp_desc,
    h4.pye_nm,
    h4.payee_l_nm,
    h4.payee_f_nm,
    h4.payee_m_nm,
    h4.payee_prefix,
    h4.payee_suffix,
    h4.pye_st1,
    h4.pye_st2,
    h4.pye_city,
    h4.pye_st,
    h4.pye_zip,
    h4.evt_purpose_nm,
    h4.evt_purpose_desc,
    h4.evt_purpose_dt,
    h4.ttl_amt_disb,
    h4.evt_purpose_category_tp,
    h4.evt_purpose_category_tp_desc,
    h4.fed_share,
    h4.nonfed_share,
    h4.admin_voter_drive_acty_ind,
    h4.fndrsg_acty_ind,
    h4.exempt_acty_ind,
    h4.direct_cand_supp_acty_ind,
    h4.evt_amt_ytd,
    h4.add_desc,
    h4.cand_id,
    h4.cand_nm,
    h4.cand_nm_first,
    h4.cand_nm_last,
    h4.cand_office,
    h4.cand_office_desc,
    h4.cand_office_st,
    h4.cand_office_st_desc,
    h4.cand_office_district,
    h4.conduit_cmte_id,
    h4.conduit_cmte_nm,
    h4.conduit_cmte_st1,
    h4.conduit_cmte_st2,
    h4.conduit_cmte_city,
    h4.conduit_cmte_st,
    h4.conduit_cmte_zip,
    h4.admin_acty_ind,
    h4.gen_voter_drive_acty_ind,
    h4.catg_cd,
    h4.catg_cd_desc,
    h4.disb_tp,
    h4.disb_tp_desc,
    h4.pub_comm_ref_pty_chk,
    h4.memo_cd,
    h4.memo_cd_desc,
    h4.memo_text,
    h4.amndt_ind AS action_cd,
    h4.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'H4'::character varying(8) AS schedule_type,
    h4.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN (h4.line_num IS NOT NULL) THEN h4.line_num
            ELSE '21A'::character varying
        END AS line_num,
    h4.image_num,
    h4.file_num,
    h4.link_id,
    h4.orig_sub_id,
    h4.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h4 h4,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h4.sub_id = fi.sub_id) AND ((h4.amndt_ind)::text <> 'D'::text) AND (h4.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h4_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h5_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h5_vw AS
 SELECT h5.filer_cmte_id,
    h5.filer_cmte_nm,
    h5.acct_nm,
    h5.tranf_dt,
    h5.ttl_tranf_amt_voter_reg,
    h5.ttl_tranf_voter_id,
    h5.ttl_tranf_gotv,
    h5.ttl_tranf_gen_campgn_actvy,
    h5.ttl_tranf_amt,
    h5.amndt_ind AS action_cd,
    h5.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h5.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h5.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'H5'::character varying(8) AS schedule_type,
    h5.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN (h5.line_num IS NOT NULL) THEN h5.line_num
            ELSE '18B'::character varying
        END AS line_num,
    h5.image_num,
    h5.file_num,
    h5.link_id,
    h5.orig_sub_id,
    h5.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h5 h5,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h5.sub_id = fi.sub_id) AND ((h5.amndt_ind)::text <> 'D'::text) AND (h5.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h5_vw OWNER TO fec;

--
-- Name: fec_fitem_sched_h6_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_fitem_sched_h6_vw AS
 SELECT h6.filer_cmte_id,
    h6.filer_cmte_nm,
    h6.entity_tp,
    h6.pye_nm,
    h6.payee_l_nm,
    h6.payee_f_nm,
    h6.payee_m_nm,
    h6.payee_prefix,
    h6.payee_suffix,
    h6.pye_st1,
    h6.pye_st2,
    h6.pye_city,
    h6.pye_st,
    h6.pye_st_desc,
    h6.pye_zip,
    h6.catg_cd,
    h6.catg_cd_desc,
    h6.disb_purpose,
    h6.disb_purpose_cat,
    h6.disb_dt,
    h6.ttl_amt_disb,
    h6.fed_share,
    h6.levin_share,
    h6.voter_reg_yn_flg,
    h6.voter_reg_yn_flg_desc,
    h6.voter_id_yn_flg,
    h6.voter_id_yn_flg_desc,
    h6.gotv_yn_flg,
    h6.gotv_yn_flg_desc,
    h6.gen_campgn_yn_flg,
    h6.gen_campgn_yn_flg_desc,
    h6.evt_amt_ytd,
    h6.add_desc,
    h6.fec_committee_id,
    h6.cand_id,
    h6.cand_nm,
    h6.cand_office,
    h6.cand_office_st_desc,
    h6.cand_office_st,
    h6.cand_office_district,
    h6.conduit_cmte_id,
    h6.conduit_cmte_nm,
    h6.conduit_cmte_st1,
    h6.conduit_cmte_st2,
    h6.conduit_cmte_city,
    h6.conduit_cmte_st,
    h6.conduit_cmte_st_desc,
    h6.conduit_cmte_zip,
    h6.memo_cd,
    h6.memo_cd_desc,
    h6.memo_text,
    h6.amndt_ind AS action_cd,
    h6.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'H6'::character varying(8) AS schedule_type,
        CASE
            WHEN (h6.line_num IS NOT NULL) THEN h6.line_num
            ELSE '30A'::character varying
        END AS line_num,
    h6.image_num,
    h6.file_num,
    h6.link_id,
    h6.orig_sub_id,
    h6.sub_id,
    fi.form_tp_cd AS filing_form,
    fi.rpt_tp,
    fi.rpt_yr,
    (fi.rpt_yr + (fi.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h6 h6,
    disclosure.f_item_receipt_or_exp fi
  WHERE ((h6.sub_id = fi.sub_id) AND ((h6.amndt_ind)::text <> 'D'::text) AND (h6.delete_ind IS NULL));


ALTER TABLE fec_fitem_sched_h6_vw OWNER TO fec;

--
-- Name: fec_form_10_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_10_vw AS
 SELECT f10.filer_cmte_id,
    f10.cand_nm,
    f10.cand_id,
    f10.cand_office,
    f10.cand_office_st,
    f10.cand_office_district,
    f10.cmte_nm,
    f10.cmte_st1,
    f10.cmte_st2,
    f10.cmte_city,
    f10.cmte_st,
    f10.cmte_zip,
    f10.prev_exp_agg,
    f10.exp_ttl_this_rpt,
    f10.exp_ttl_cycl_to_dt,
    f10.cand_sign_nm,
    f10.can_sign_dt,
    f10.cand_office_desc,
    f10.cand_office_st_desc,
    f10.cmte_st_desc,
    f10.form_6_chk,
    f10.contbr_employer,
    f10.contbr_occupation,
    f10.amndt_ind_desc,
    f10.amndt_ind,
    f10.receipt_dt,
    f10.rpt_yr,
    (f10.rpt_yr + mod(f10.rpt_yr, (2)::numeric)) AS cycle,
    f10.form_tp,
    f10.form_tp_desc,
    f10.begin_image_num,
    f10.end_image_num,
    f10.sub_id,
    f10.file_num,
    f10.prev_file_num,
    f10.mst_rct_file_num
   FROM disclosure.nml_form_10 f10
  WHERE (f10.delete_ind IS NULL);


ALTER TABLE fec_form_10_vw OWNER TO fec;

--
-- Name: fec_form_11_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_11_vw AS
 SELECT f11.filer_cmte_id,
    f11.cand_nm,
    f11.cand_last_name,
    f11.cand_first_name,
    f11.cand_middle_name,
    f11.cand_prefix,
    f11.cand_suffix,
    f11.cand_id,
    f11.cand_office,
    f11.cand_office_desc,
    f11.cand_office_st,
    f11.cand_office_st_desc,
    f11.cand_office_district,
    f11.cmte_nm,
    f11.cmte_st1,
    f11.cmte_st2,
    f11.cmte_city,
    f11.cmte_st,
    f11.cmte_st_desc,
    f11.cmte_zip,
    f11.oppos_cand_nm,
    f11.oppos_cand_last_name,
    f11.oppos_cand_first_name,
    f11.oppos_cand_middle_name,
    f11.oppos_cand_prefix,
    f11.oppos_cand_suffix,
    f11.oppos_cmte_nm,
    f11.oppos_cmte_id,
    f11.oppos_cmte_st1,
    f11.oppos_cmte_st2,
    f11.oppos_cmte_city,
    f11.oppos_cmte_st,
    f11.oppos_cmte_st_desc,
    f11.oppos_cmte_zip,
    f11.form_10_recpt_dt,
    f11.oppos_pers_fund_amt,
    f11.election_tp,
    f11.election_tp_desc,
    f11.fec_election_tp_desc,
    f11.reg_special_elect_tp,
    f11.reg_special_elect_tp_desc,
    f11.cand_tres_sign_nm,
    f11.cand_tres_last_name,
    f11.cand_tres_first_name,
    f11.cand_tres_middle_name,
    f11.cand_tres_prefix,
    f11.cand_tres_suffix,
    f11.cand_tres_sign_dt,
    f11.sub_id,
    f11.begin_image_num,
    f11.end_image_num,
    f11.amndt_ind,
    f11.amndt_ind_desc,
    f11.receipt_dt,
    f11.rpt_yr,
    (f11.rpt_yr + mod(f11.rpt_yr, (2)::numeric)) AS cycle,
    f11.form_tp,
    f11.form_tp_desc,
    f11.file_num,
    f11.prev_file_num,
    f11.mst_rct_file_num
   FROM disclosure.nml_form_11 f11
  WHERE (f11.delete_ind IS NULL);


ALTER TABLE fec_form_11_vw OWNER TO fec;

--
-- Name: fec_form_12_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_12_vw AS
 SELECT f12.filer_cmte_id,
    f12.cand_nm,
    f12.cand_last_name,
    f12.cand_first_name,
    f12.cand_middle_name,
    f12.cand_prefix,
    f12.cand_suffix,
    f12.cand_id,
    f12.cand_office,
    f12.cand_office_desc,
    f12.cand_office_st,
    f12.cand_office_st_desc,
    f12.cand_office_district,
    f12.cmte_nm,
    f12.cmte_st1,
    f12.cmte_st2,
    f12.cmte_city,
    f12.cmte_st,
    f12.cmte_st_desc,
    f12.cmte_zip,
    f12.election_tp,
    f12.fec_election_tp_desc,
    f12.reg_special_elect_tp,
    f12.reg_special_elect_tp_desc,
    f12.hse_date_reached_100,
    f12.hse_pers_funds_amt,
    f12.hse_form_11_prev_dt,
    f12.sen_date_reached_110,
    f12.sen_pers_funds_amt,
    f12.sen_form_11_prev_dt,
    f12.cand_tres_sign_nm,
    f12.cand_tres_last_name,
    f12.cand_tres_first_name,
    f12.cand_tres_middle_name,
    f12.cand_tres_prefix,
    f12.cand_tres_suffix,
    f12.cand_tres_sign_dt,
    f12.sub_id,
    f12.begin_image_num,
    f12.end_image_num,
    f12.amndt_ind,
    f12.amndt_ind_desc,
    f12.receipt_dt,
    f12.rpt_yr,
    (f12.rpt_yr + mod(f12.rpt_yr, (2)::numeric)) AS cycle,
    f12.form_tp,
    f12.form_tp_desc,
    f12.file_num,
    f12.prev_file_num,
    f12.mst_rct_file_num
   FROM disclosure.nml_form_12 f12
  WHERE (f12.delete_ind IS NULL);


ALTER TABLE fec_form_12_vw OWNER TO fec;

--
-- Name: fec_form_13_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_13_vw AS
 SELECT f13.cmte_id,
    f13.cmte_nm,
    f13.cmte_st1,
    f13.cmte_st2,
    f13.cmte_city,
    f13.cmte_st,
    f13.cmte_zip,
    f13.cmte_addr_chg_flg,
    f13.cmte_tp,
    f13.cmte_tp_desc,
    f13.ttl_dons_accepted,
    f13.ttl_dons_refunded,
    f13.net_dons,
    f13.desig_officer_last_nm,
    f13.desig_officer_first_nm,
    f13.desig_officer_middle_nm,
    f13.desig_officer_prefix,
    f13.desig_officer_suffix,
    f13.designated_officer_nm,
    f13.amndt_ind,
    f13.cvg_start_dt,
    f13.cvg_end_dt,
    f13.rpt_tp,
    f13.rpt_yr,
    (f13.rpt_yr + mod(f13.rpt_yr, (2)::numeric)) AS cycle,
    f13.receipt_dt,
    f13.signature_dt,
    f13.sub_id,
    f13.begin_image_num,
    f13.end_image_num,
    f13.form_tp,
    f13.file_num,
    f13.prev_file_num,
    f13.mst_rct_file_num,
        CASE
            WHEN (((f13.cmte_id)::text, f13.cvg_end_dt, f13.receipt_dt) IN ( SELECT nml_form_13.cmte_id,
                nml_form_13.cvg_end_dt,
                max(nml_form_13.receipt_dt) AS receipt_dt
               FROM disclosure.nml_form_13
              WHERE (nml_form_13.delete_ind IS NULL)
              GROUP BY nml_form_13.cmte_id, nml_form_13.cvg_end_dt)) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM disclosure.nml_form_13 f13
  WHERE (f13.delete_ind IS NULL);


ALTER TABLE fec_form_13_vw OWNER TO fec;

--
-- Name: fec_form_1m_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_1m_vw AS
 SELECT f1m.cmte_id,
    f1m.cmte_nm,
    f1m.cmte_st1,
    f1m.cmte_st2,
    f1m.cmte_city,
    f1m.cmte_st,
    f1m.cmte_zip,
    f1m.cmte_tp,
    f1m.cmte_tp_desc,
    f1m.affiliation_dt,
    f1m.affiliated_cmte_id,
    f1m.affiliated_cmte_nm,
    f1m.fst_cand_id,
    f1m.fst_cand_nm,
    f1m.fst_cand_office,
    f1m.fst_cand_office_desc,
    f1m.fst_cand_office_st,
    f1m.fst_cand_office_st_desc,
    f1m.fst_cand_office_district,
    f1m.fst_cand_contb_dt,
    f1m.sec_cand_id,
    f1m.sec_cand_nm,
    f1m.sec_cand_office,
    f1m.sec_cand_office_desc,
    f1m.sec_cand_office_st,
    f1m.sec_cand_office_st_desc,
    f1m.sec_cand_office_district,
    f1m.sec_cand_contb_dt,
    f1m.trd_cand_id,
    f1m.trd_cand_nm,
    f1m.trd_cand_office,
    f1m.trd_cand_office_desc,
    f1m.trd_cand_office_st,
    f1m.trd_cand_office_st_desc,
    f1m.trd_cand_office_district,
    f1m.trd_cand_contb_dt,
    f1m.frth_cand_id,
    f1m.frth_cand_nm,
    f1m.frth_cand_office,
    f1m.frth_cand_office_desc,
    f1m.frth_cand_office_st,
    f1m.frth_cand_office_st_desc,
    f1m.frth_cand_office_district,
    f1m.frth_cand_contb_dt,
    f1m.fith_cand_id,
    f1m.fith_cand_nm,
    f1m.fith_cand_office,
    f1m.fith_cand_office_desc,
    f1m.fith_cand_office_st,
    f1m.fith_cand_office_st_desc,
    f1m.fith_cand_office_district,
    f1m.fith_cand_contb_dt,
    f1m.fiftyfirst_cand_contbr_dt,
    f1m.fst_cand_l_nm,
    f1m.fst_cand_f_nm,
    f1m.fst_cand_m_nm,
    f1m.fst_cand_prefix,
    f1m.fst_cand_suffix,
    f1m.sec_cand_l_nm,
    f1m.sec_cand_f_nm,
    f1m.sec_cand_m_nm,
    f1m.sec_cand_prefix,
    f1m.sec_cand_suffix,
    f1m.trd_cand_l_nm,
    f1m.trd_cand_f_nm,
    f1m.trd_cand_m_nm,
    f1m.trd_cand_prefix,
    f1m.trd_cand_suffix,
    f1m.frth_cand_l_nm,
    f1m.frth_cand_f_nm,
    f1m.frth_cand_m_nm,
    f1m.frth_cand_prefix,
    f1m.frth_cand_suffix,
    f1m.fith_cand_l_nm,
    f1m.fith_cand_f_nm,
    f1m.fith_cand_m_nm,
    f1m.fith_cand_prefix,
    f1m.fith_cand_suffix,
    f1m.tres_sign_nm,
    f1m.tres_sign_l_nm,
    f1m.tres_sign_f_nm,
    f1m.tres_sign_m_nm,
    f1m.tres_sign_prefix,
    f1m.tres_sign_suffix,
    f1m.tres_sign_dt,
    f1m.orig_registration_dt,
    f1m.qual_dt,
    f1m.receipt_dt,
    f1m.rpt_yr,
    (f1m.rpt_yr + mod(f1m.rpt_yr, (2)::numeric)) AS cycle,
    f1m.file_num,
    f1m.prev_file_num,
    f1m.mst_rct_file_num,
    f1m.sub_id,
    f1m.begin_image_num,
    f1m.end_image_num,
    'F1M'::character varying(8) AS form_tp,
    f1m.form_tp_desc
   FROM disclosure.nml_form_1m f1m
  WHERE ((f1m.delete_ind IS NULL) AND (f1m.rpt_yr >= (1977)::numeric));


ALTER TABLE fec_form_1m_vw OWNER TO fec;

--
-- Name: fec_form_1s_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_1s_vw AS
 SELECT f1s.cmte_id,
    f1s.affiliated_cmte_id,
    f1s.affiliated_cmte_nm,
    f1s.affiliated_cmte_st1,
    f1s.affiliated_cmte_st2,
    f1s.affiliated_cmte_city,
    f1s.affiliated_cmte_st,
    f1s.affiliated_cmte_zip,
    f1s.cmte_rltshp,
    f1s.org_tp,
    f1s.org_tp_desc,
    f1s.designated_agent_nm,
    f1s.designated_agent_st1,
    f1s.designated_agent_st2,
    f1s.designated_agent_city,
    f1s.designated_agent_st,
    f1s.designated_agent_zip,
    f1s.designated_agent_title,
    f1s.designated_agent_ph_num,
    f1s.bank_depository_nm,
    f1s.bank_depository_st1,
    f1s.bank_depository_st2,
    f1s.bank_depository_city,
    f1s.bank_depository_st,
    f1s.bank_depository_zip,
    f1s.joint_cmte_nm,
    f1s.joint_cmte_id,
    f1s.affiliated_relationship_cd,
    f1s.affiliated_cand_id,
    f1s.affiliated_cand_l_nm,
    f1s.affiliated_cand_f_nm,
    f1s.affiliated_cand_m_nm,
    f1s.affiliated_cand_prefix,
    f1s.affiliated_cand_suffix,
    f1s.designated_agent_l_nm,
    f1s.designated_agent_f_nm,
    f1s.designated_agent_m_nm,
    f1s.designated_agent_prefix,
    f1s.designated_agent_suffix,
    f1.receipt_dt,
    f1.rpt_yr,
    (f1.rpt_yr + mod(f1.rpt_yr, (2)::numeric)) AS cycle,
    f1s.file_num,
    f1s.sub_id,
    f1s.link_id,
    f1s.image_num,
    f1s.form_tp,
    f1s.form_tp_desc,
    f1s.amndt_ind,
    f1s.amndt_ind_desc,
        CASE
            WHEN (f1s.link_id IN ( SELECT nml_form_1.sub_id
               FROM disclosure.nml_form_1
              WHERE (((nml_form_1.cmte_id)::text, nml_form_1.receipt_dt) IN ( SELECT f1_1.cmte_id,
                        max(f1_1.receipt_dt) AS max
                       FROM disclosure.nml_form_1 f1_1
                      WHERE ((f1_1.delete_ind IS NULL) AND (f1_1.sub_id IN ( SELECT nml_form_1s.link_id
                               FROM disclosure.nml_form_1s
                              WHERE (nml_form_1s.delete_ind IS NULL))))
                      GROUP BY f1_1.cmte_id)))) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM disclosure.nml_form_1s f1s,
    disclosure.nml_form_1 f1
  WHERE ((f1.sub_id = f1s.link_id) AND (f1.delete_ind IS NULL) AND (f1s.delete_ind IS NULL));


ALTER TABLE fec_form_1s_vw OWNER TO fec;

--
-- Name: fec_form_2s_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_2s_vw AS
 SELECT f2s.cand_id,
    f2s.auth_cmte_id,
    f2s.auth_cmte_nm,
    f2s.auth_cmte_st1,
    f2s.auth_cmte_st2,
    f2s.auth_cmte_city,
    f2s.auth_cmte_st,
    f2s.auth_cmte_zip,
    f2s.file_num,
    f2s.amndt_ind,
    f2s.amndt_ind_desc,
    f2s.sub_id,
    f2s.link_id,
    f2s.begin_image_num AS image_num,
    f2s.form_tp,
    f2s.form_tp_desc,
    f2.receipt_dt,
    f2.rpt_yr,
    (f2.rpt_yr + mod(f2.rpt_yr, (2)::numeric)) AS cycle,
        CASE
            WHEN (f2s.link_id IN ( SELECT nml_form_2.sub_id
               FROM disclosure.nml_form_2
              WHERE (((nml_form_2.cand_id)::text, nml_form_2.election_yr, nml_form_2.receipt_dt) IN ( SELECT f2_1.cand_id,
                        f2_1.election_yr,
                        max(f2_1.receipt_dt) AS max
                       FROM disclosure.nml_form_2 f2_1
                      WHERE ((f2_1.delete_ind IS NULL) AND (f2_1.sub_id IN ( SELECT nml_form_2s.link_id
                               FROM disclosure.nml_form_2s
                              WHERE (nml_form_2s.delete_ind IS NULL))))
                      GROUP BY f2_1.cand_id, f2_1.election_yr)))) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM disclosure.nml_form_2s f2s,
    disclosure.nml_form_2 f2
  WHERE ((f2.sub_id = f2s.link_id) AND (f2.delete_ind IS NULL) AND (f2s.delete_ind IS NULL));


ALTER TABLE fec_form_2s_vw OWNER TO fec;

--
-- Name: fec_form_3l_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_3l_vw AS
 SELECT f3l.cmte_id,
    f3l.cmte_nm,
    f3l.cmte_st1,
    f3l.cmte_st2,
    f3l.cmte_city,
    f3l.cmte_st,
    f3l.cmte_zip,
    f3l.cmte_addr_chg_flg,
    f3l.cmte_election_st,
    f3l.cmte_election_st_desc,
    f3l.cmte_election_district,
    f3l.amndt_ind,
    f3l.amndt_ind_desc,
    f3l.rpt_tp,
    f3l.rpt_tp_desc,
    f3l.rpt_pgi,
    f3l.rpt_pgi_desc,
    f3l.election_dt,
    f3l.election_st,
    f3l.election_st_desc,
    f3l.cvg_start_dt,
    f3l.cvg_end_dt,
    f3l.receipt_dt,
    f3l.rpt_yr,
    (f3l.rpt_yr + mod(f3l.rpt_yr, (2)::numeric)) AS cycle,
    f3l.semi_an_per_5c_5d,
    f3l.semi_an_jan_jun_6b,
    f3l.semi_an_jul_dec_6b,
    f3l.qtr_mon_bundled_contb,
    f3l.semi_an_bundled_contb,
    f3l.tres_l_nm,
    f3l.tres_f_nm,
    f3l.tres_m_nm,
    f3l.tres_prefix,
    f3l.tres_suffix,
    f3l.tres_sign_dt,
    f3l.sub_id,
    f3l.begin_image_num,
    f3l.end_image_num,
    f3l.form_tp,
    f3l.form_tp_desc,
    f3l.file_num,
    f3l.prev_file_num,
    f3l.mst_rct_file_num
   FROM disclosure.nml_form_3l f3l
  WHERE (f3l.delete_ind IS NULL);


ALTER TABLE fec_form_3l_vw OWNER TO fec;

--
-- Name: fec_form_82_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_82_vw AS
 SELECT f82.cmte_id,
    f82.cmte_nm,
    f82.cred_tp,
    f82.cred_tp_desc,
    f82.cred_nm,
    f82.cred_st1,
    f82.cred_st2,
    f82.cred_city,
    f82.cred_st,
    f82.cred_zip,
    f82.entity_tp,
    f82.incurred_dt,
    f82.amt_owed_cred,
    f82.amt_offered_settle,
    f82.terms_initial_extention_desc,
    f82.debt_repymt_efforts_desc,
    f82.steps_obtain_funds_desc,
    f82.similar_effort_flg,
    f82.similar_effort_desc,
    f82.terms_settlement_flg,
    f82.terms_of_settlement_desc,
    f82.cand_id,
    f82.cand_nm,
    f82.cand_office,
    f82.cand_office_desc,
    f82.cand_office_st,
    f82.cand_office_st_desc,
    f82.cand_office_district,
    f82.add_cmte_id,
    f82.creditor_sign_nm,
    f82.creditor_sign_dt,
    f82.amndt_ind AS action_cd,
    f82.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f82.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f82.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    f82.receipt_dt,
    f82.form_tp,
    f82.form_tp_desc,
    f82.image_num,
    f82.sub_id,
    f82.link_id,
    f82.file_num,
    f8.rpt_yr,
    (f8.rpt_yr + mod(f8.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_82 f82,
    disclosure.nml_form_8 f8
  WHERE ((f82.link_id = f8.sub_id) AND ((f82.amndt_ind)::text <> 'D'::text) AND (f82.delete_ind IS NULL) AND (f8.delete_ind IS NULL));


ALTER TABLE fec_form_82_vw OWNER TO fec;

--
-- Name: fec_form_83_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_83_vw AS
 SELECT f83.cmte_id,
    f83.cmte_nm,
    f83.cred_tp,
    f83.cred_tp_desc,
    f83.cred_nm,
    f83.cred_st1,
    f83.cred_st2,
    f83.cred_city,
    f83.cred_st,
    f83.cred_zip,
    f83.entity_tp,
    f83.disputed_debt_flg,
    f83.incurred_dt,
    f83.amt_owed_cred,
    f83.amt_offered_settle,
    f83.add_cmte_id,
    f83.cand_id,
    f83.cand_nm,
    f83.cand_office,
    f83.cand_office_desc,
    f83.cand_office_st,
    f83.cand_office_st_desc,
    f83.cand_office_district,
    f83.amndt_ind AS action_cd,
    f83.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f83.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f83.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    f83.receipt_dt,
    f83.form_tp,
    f83.form_tp_desc,
    f83.sub_id,
    f83.link_id,
    f83.image_num,
    f83.file_num,
    f8.rpt_yr,
    (f8.rpt_yr + mod(f8.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_form_83 f83,
    disclosure.nml_form_8 f8
  WHERE ((f83.link_id = f8.sub_id) AND ((f83.amndt_ind)::text <> 'D'::text) AND (f83.delete_ind IS NULL) AND (f8.delete_ind IS NULL));


ALTER TABLE fec_form_83_vw OWNER TO fec;

--
-- Name: fec_form_8_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_8_vw AS
 SELECT f8.cmte_id,
    f8.cmte_nm,
    f8.cmte_st1,
    f8.cmte_st2,
    f8.cmte_city,
    f8.cmte_st,
    f8.cmte_zip,
    f8.coh,
    f8.calender_yr,
    f8.ttl_liquidated_assets,
    f8.ttl_assets,
    f8.ytd_reciepts,
    f8.ytd_disb,
    f8.ttl_amt_debts_owed,
    f8.ttl_num_cred_owed,
    f8.ttl_num_cred_part2,
    f8.ttl_amt_debts_owed_part2,
    f8.ttl_amt_paid_cred,
    f8.term_flg,
    f8.term_dt_desc,
    f8.addl_auth_cmte_flg,
    f8.add_auth_cmte_desc,
    f8.sufficient_amt_to_pay_ttl_flg,
    f8.sufficient_amt_to_pay_desc,
    f8.prev_debt_settlement_plan_flg,
    f8.residual_funds_flg,
    f8.residual_funds_desc,
    f8.remaining_amt_flg,
    f8.remaining_amt_desc,
    f8.tres_sign_nm,
    f8.tres_sign_dt,
    f8.amndt_ind,
    f8.amndt_ind_desc,
    f8.receipt_dt,
    f8.rpt_yr,
    (f8.rpt_yr + mod(f8.rpt_yr, (2)::numeric)) AS cycle,
    f8.form_tp,
    f8.form_tp_desc,
    f8.file_num,
    f8.prev_file_num,
    f8.mst_rct_file_num,
    f8.sub_id,
    f8.begin_image_num,
    f8.end_image_num
   FROM disclosure.nml_form_8 f8
  WHERE (f8.delete_ind IS NULL);


ALTER TABLE fec_form_8_vw OWNER TO fec;

--
-- Name: fec_form_99_misc_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_99_misc_vw AS
 SELECT f99.cmte_id,
    f99.cmte_nm,
    f99.cmte_st1,
    f99.cmte_st2,
    f99.cmte_city,
    f99.cmte_st,
    f99.cmte_zip,
    f99.tres_sign_nm,
    f99.tres_l_nm,
    f99.tres_f_nm,
    f99.tres_m_nm,
    f99.tres_prefix,
    f99.tres_suffix,
    f99.tres_sign_dt,
    f99.text_field,
    f99.to_from_ind,
    f99.to_from_ind_desc,
    f99.text_cd,
    f99.text_cd_desc,
    f99.rpt_tp,
    f99.rpt_tp_desc,
    f99.amndt_ind,
    f99.amndt_ind_desc,
    f99.cvg_start_dt,
    f99.cvg_end_dt,
    f99.rpt_yr,
    f99.receipt_dt,
    (f99.rpt_yr + mod(f99.rpt_yr, (2)::numeric)) AS cycle,
    f99.file_num,
    f99.sub_id,
    f99.begin_image_num,
    f99.end_image_num,
    f99.form_tp,
    f99.form_tp_desc
   FROM disclosure.nml_form_99_misc f99
  WHERE (f99.delete_ind IS NULL);


ALTER TABLE fec_form_99_misc_vw OWNER TO fec;

--
-- Name: fec_form_rfai_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_form_rfai_vw AS
 SELECT rfai.id,
    rfai.request_tp,
    rfai.request_tp_desc,
    rfai.cvg_start_dt,
    rfai.cvg_end_dt,
    rfai.rpt_tp,
    rfai.rpt_tp_desc,
    rfai.amndt_ind,
    rfai.amndt_ind_desc,
    rfai.rpt_yr,
    (rfai.rpt_yr + mod(rfai.rpt_yr, (2)::numeric)) AS cycle,
    rfai.rfai_dt,
    rfai.response_due_dt,
    rfai.response_dt,
    rfai.sub_id,
    rfai.begin_image_num,
    rfai.end_image_num
   FROM disclosure.nml_form_rfai rfai
  WHERE (rfai.delete_ind IS NULL);


ALTER TABLE fec_form_rfai_vw OWNER TO fec;

--
-- Name: fec_sched_e_notice_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_sched_e_notice_vw AS
 SELECT se.cmte_id,
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
    se.exp_dt,
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
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'SE'::character varying(8) AS schedule_type,
    se.form_tp_desc AS schedule_type_desc,
    se.line_num,
    se.image_num,
    se.file_num,
    se.link_id,
    se.orig_sub_id,
    se.sub_id,
    'F24'::character varying(8) AS filing_form,
    f24.rpt_tp,
    f24.rpt_yr,
    (f24.rpt_yr + mod(f24.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_sched_e se,
    disclosure.nml_form_24 f24
  WHERE ((se.link_id = f24.sub_id) AND (f24.delete_ind IS NULL) AND (se.delete_ind IS NULL) AND ((se.amndt_ind)::text <> 'D'::text));


ALTER TABLE fec_sched_e_notice_vw OWNER TO fec;

--
-- Name: fec_vsum_f105_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f105_vw AS
 SELECT f105.filer_cmte_id,
    f105.exp_dt,
    f105.election_tp,
    f105.election_tp_desc,
    f105.fec_election_tp_desc,
    f105.exp_amt,
    f105.loan_chk_flg,
    f105.amndt_ind AS action_cd,
    f105.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f105.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f105.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F105'::character varying(8) AS schedule_type,
    f105.form_tp_desc AS schedule_type_desc,
    f105.image_num,
    f105.file_num,
    f105.link_id,
    f105.orig_sub_id,
    f105.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_105 f105,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f105.link_id = vs.orig_sub_id) AND ((f105.amndt_ind)::text <> 'D'::text) AND (f105.delete_ind IS NULL));


ALTER TABLE fec_vsum_f105_vw OWNER TO fec;

--
-- Name: fec_vsum_f1_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f1_vw AS
 WITH f AS (
         SELECT nml_form_1.cmte_id,
            min((nml_form_1.begin_image_num)::text) AS f_begin_image_num,
            'Y' AS first_form_1
           FROM disclosure.nml_form_1
          WHERE ((nml_form_1.delete_ind IS NULL) AND (nml_form_1.rpt_yr >= (1977)::numeric) AND (((nml_form_1.cmte_id)::text, nml_form_1.receipt_dt) IN ( SELECT nml_form_1_1.cmte_id,
                    min(nml_form_1_1.receipt_dt) AS min
                   FROM disclosure.nml_form_1 nml_form_1_1
                  WHERE ((nml_form_1_1.delete_ind IS NULL) AND (nml_form_1_1.rpt_yr >= (1977)::numeric))
                  GROUP BY nml_form_1_1.cmte_id)))
          GROUP BY nml_form_1.cmte_id
        )
 SELECT f1.cmte_id,
    f1.cmte_nm,
    f1.cmte_st1,
    f1.cmte_st2,
    f1.cmte_city,
    f1.cmte_st,
    f1.cmte_zip,
    f1.cmte_email,
    f1.cmte_web_url,
    f1.cmte_fax,
    f1.cmte_nm_chg_flg,
    f1.cmte_addr_chg_flg,
    f1.cmte_email_chg_flg,
    f1.cmte_url_chg_flg,
    f1.filing_freq,
    f1.filing_freq_desc,
    f1.f3l_filing_freq,
    f1.filed_cmte_tp,
    f1.filed_cmte_tp_desc,
    f1.qual_dt,
    f1.efiling_cmte_tp,
    f1.filed_cmte_dsgn,
    f1.filed_cmte_dsgn_desc,
    f1.jntfndrsg_cmte_flg,
    f1.org_tp,
    f1.org_tp_desc,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_id,
    f1.cand_nm,
    f1.cand_nm_first,
    f1.cand_nm_last,
    f1.cand_m_nm,
    f1.cand_prefix,
    f1.cand_suffix,
    f1.cand_office,
    f1.cand_office_desc,
    f1.cand_office_st,
    f1.cand_office_st_desc,
    f1.cand_office_district,
    f1.cand_pty_affiliation,
    f1.cand_pty_affiliation_desc,
    f1.cand_pty_tp,
    f1.cand_pty_tp_desc,
    f1.affiliated_cmte_id,
    f1.affiliated_cmte_nm,
    f1.affiliated_cmte_st1,
    f1.affiliated_cmte_st2,
    f1.affiliated_cmte_city,
    f1.affiliated_cmte_st,
    f1.affiliated_cmte_zip,
    f1.affiliated_cand_id,
    f1.affiliated_cand_l_nm,
    f1.affiliated_cand_f_nm,
    f1.affiliated_cand_m_nm,
    f1.affiliated_cand_prefix,
    f1.affiliated_cand_suffix,
    f1.cmte_rltshp,
    f1.affiliated_relationship_cd,
    f1.cust_rec_nm,
    f1.cust_rec_l_nm,
    f1.cust_rec_f_nm,
    f1.cust_rec_m_nm,
    f1.cust_rec_prefix,
    f1.cust_rec_suffix,
    f1.cust_rec_st1,
    f1.cust_rec_st2,
    f1.cust_rec_city,
    f1.cust_rec_st,
    f1.cust_rec_zip,
    f1.cust_rec_title,
    f1.cust_rec_ph_num,
    f1.tres_nm,
    f1.tres_l_nm,
    f1.tres_f_nm,
    f1.tres_m_nm,
    f1.tres_prefix,
    f1.tres_suffix,
    f1.tres_st1,
    f1.tres_st2,
    f1.tres_city,
    f1.tres_st,
    f1.tres_zip,
    f1.tres_title,
    f1.tres_ph_num,
    f1.designated_agent_nm,
    f1.designated_agent_l_nm,
    f1.designated_agent_f_nm,
    f1.designated_agent_m_nm,
    f1.designated_agent_prefix,
    f1.designated_agent_suffix,
    f1.designated_agent_st1,
    f1.designated_agent_st2,
    f1.designated_agent_city,
    f1.designated_agent_st,
    f1.designated_agent_zip,
    f1.designated_agent_title,
    f1.designated_agent_ph_num,
    f1.bank_depository_nm,
    f1.bank_depository_st1,
    f1.bank_depository_st2,
    f1.bank_depository_city,
    f1.bank_depository_st,
    f1.bank_depository_zip,
    f1.sec_bank_depository_nm,
    f1.sec_bank_depository_st1,
    f1.sec_bank_depository_st2,
    f1.sec_bank_depository_city,
    f1.sec_bank_depository_st,
    f1.sec_bank_depository_zip,
    f1.tres_sign_nm,
    f1.sign_l_nm,
    f1.sign_f_nm,
    f1.sign_m_nm,
    f1.sign_prefix,
    f1.sign_suffix,
    f1.tres_sign_dt,
    f1.receipt_dt,
    f1.rpt_yr,
    (f1.rpt_yr + (f1.rpt_yr % (2)::numeric)) AS election_cycle,
    f1.file_num,
    f1.prev_file_num,
    f1.mst_rct_file_num,
    f1.begin_image_num,
    f1.end_image_num,
    'F1'::text AS form_tp,
    f1.form_tp_desc,
    f1.amndt_ind,
    f1.amndt_ind_desc,
    f1.sub_id,
        CASE
            WHEN (f.first_form_1 IS NOT NULL) THEN (f.first_form_1)::character varying
            ELSE 'N'::character varying
        END AS first_form_1
   FROM (disclosure.nml_form_1 f1
     LEFT JOIN f ON ((((f1.begin_image_num)::text = f.f_begin_image_num) AND ((f1.cmte_id)::text = (f.cmte_id)::text))))
  WHERE ((f1.delete_ind IS NULL) AND (f1.rpt_yr >= (1977)::numeric));


ALTER TABLE fec_vsum_f1_vw OWNER TO fec;

--
-- Name: fec_vsum_f2_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f2_vw AS
 WITH f AS (
         SELECT nml_form_2.cand_id,
            nml_form_2.election_yr,
            min((nml_form_2.begin_image_num)::text) AS f_begin_image_num,
            'Y' AS first_form_2
           FROM disclosure.nml_form_2
          WHERE ((nml_form_2.delete_ind IS NULL) AND (((nml_form_2.cand_id)::text, nml_form_2.election_yr, nml_form_2.receipt_dt) IN ( SELECT nml_form_2_1.cand_id,
                    nml_form_2_1.election_yr,
                    min(nml_form_2_1.receipt_dt) AS min
                   FROM disclosure.nml_form_2 nml_form_2_1
                  WHERE (nml_form_2_1.delete_ind IS NULL)
                  GROUP BY nml_form_2_1.cand_id, nml_form_2_1.election_yr)))
          GROUP BY nml_form_2.cand_id, nml_form_2.election_yr
        )
 SELECT f2.cand_id,
    f2.cand_nm,
    f2.cand_nm_first,
    f2.cand_nm_last,
    f2.cand_m_nm,
    f2.cand_prefix,
    f2.cand_suffix,
    f2.cand_st1,
    f2.cand_st2,
    f2.cand_city,
    f2.cand_st,
    f2.cand_zip,
    f2.addr_chg_flg,
    f2.cand_pty_affiliation,
    f2.cand_pty_affiliation_desc,
    f2.cand_office,
    f2.cand_office_desc,
    f2.cand_office_st,
    f2.cand_office_st_desc,
    f2.cand_office_district,
    f2.election_yr,
    f2.pcc_cmte_id,
    f2.pcc_cmte_nm,
    f2.pcc_cmte_st1,
    f2.pcc_cmte_st2,
    f2.pcc_cmte_city,
    f2.pcc_cmte_st,
    f2.pcc_cmte_zip,
    f2.addl_auth_cmte_id,
    f2.addl_auth_cmte_nm,
    f2.addl_auth_cmte_st1,
    f2.addl_auth_cmte_st2,
    f2.addl_auth_cmte_city,
    f2.addl_auth_cmte_st,
    f2.addl_auth_cmte_zip,
    f2.cand_sign_nm,
    f2.cand_sign_l_nm,
    f2.cand_sign_f_nm,
    f2.cand_sign_m_nm,
    f2.cand_sign_prefix,
    f2.cand_sign_suffix,
    f2.cand_sign_dt,
    f2.party_cd,
    f2.party_cd_desc,
    f2.amndt_ind,
    f2.amndt_ind_desc,
    f2.cand_ici,
    f2.cand_ici_desc,
    f2.cand_status,
    f2.cand_status_desc,
    f2.prim_pers_funds_decl,
    f2.gen_pers_funds_decl,
    f2.receipt_dt,
    f2.rpt_yr,
    (f2.rpt_yr + (f2.rpt_yr % (2)::numeric)) AS election_cycle,
    f2.file_num,
    f2.prev_file_num,
    f2.mst_rct_file_num,
    f2.begin_image_num,
    f2.end_image_num,
    'F2'::character varying(8) AS form_tp,
    f2.form_tp_desc,
    f2.sub_id,
        CASE
            WHEN (f.first_form_2 IS NOT NULL) THEN (f.first_form_2)::character varying
            ELSE 'N'::character varying
        END AS first_form_2
   FROM (disclosure.nml_form_2 f2
     LEFT JOIN f ON ((((f2.begin_image_num)::text = f.f_begin_image_num) AND ((f2.cand_id)::text = (f.cand_id)::text))))
  WHERE (f2.delete_ind IS NULL);


ALTER TABLE fec_vsum_f2_vw OWNER TO fec;

--
-- Name: fec_vsum_f3_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3_vw AS
 SELECT f3.cmte_id,
    f3.cmte_nm,
    f3.cmte_st1,
    f3.cmte_st2,
    f3.cmte_city,
    f3.cmte_st,
    f3.cmte_zip,
    f3.cmte_addr_chg_flg,
    f3.cmte_election_st,
    f3.cmte_election_st_desc,
    f3.cmte_election_district,
    f3.amndt_ind,
    f3.amndt_ind_desc,
    f3.rpt_tp,
    f3.rpt_tp_desc,
    f3.rpt_pgi,
    f3.rpt_pgi_desc,
    f3.election_dt,
    f3.election_st,
    f3.election_st_desc,
    f3.cvg_start_dt,
    f3.cvg_end_dt,
    f3.rpt_yr,
    f3.receipt_dt,
    (f3.rpt_yr + (f3.rpt_yr % (2)::numeric)) AS election_cycle,
    f3.tres_sign_nm,
    f3.tres_l_nm,
    f3.tres_f_nm,
    f3.tres_m_nm,
    f3.tres_prefix,
    f3.tres_suffix,
    f3.tres_sign_dt,
    f3.ttl_contb_per,
    f3.ttl_contb_ref_per,
    f3.net_contb_per,
    f3.ttl_op_exp_per,
    f3.ttl_offsets_to_op_exp_per,
    f3.net_op_exp_per,
    f3.coh_cop_i AS coh_cop_line_8,
    GREATEST(f3.coh_cop_i, f3.coh_cop_ii) AS coh_cop,
    f3.debts_owed_to_cmte,
    f3.debts_owed_by_cmte,
    f3.indv_item_contb_per,
    f3.indv_unitem_contb_per,
    f3.ttl_indv_contb_per,
    f3.pol_pty_cmte_contb_per,
    f3.other_pol_cmte_contb_per,
    f3.cand_contb_per,
    f3.ttl_contb_column_ttl_per,
    f3.tranf_from_other_auth_cmte_per,
    f3.loans_made_by_cand_per,
    f3.all_other_loans_per,
    f3.ttl_loans_per,
    f3.offsets_to_op_exp_per,
    f3.other_receipts_per,
    f3.ttl_receipts_per_i AS ttl_receipts_line_16,
    GREATEST(f3.ttl_receipts_per_i, f3.ttl_receipts_ii) AS ttl_receipts_per,
    f3.op_exp_per,
    f3.tranf_to_other_auth_cmte_per,
    f3.loan_repymts_cand_loans_per,
    f3.loan_repymts_other_loans_per,
    f3.ttl_loan_repymts_per,
    f3.ref_indv_contb_per,
    f3.ref_pol_pty_cmte_contb_per,
    f3.ref_other_pol_cmte_contb_per,
    f3.ttl_contb_ref_col_ttl_per,
    f3.other_disb_per,
    f3.ttl_disb_per_i AS ttl_disb_line_22,
    GREATEST(f3.ttl_disb_per_i, f3.ttl_disb_per_ii) AS ttl_disb_per,
    f3.coh_bop,
    f3.ttl_receipts_ii AS ttl_receipts_line_24,
    f3.subttl_per,
    f3.ttl_disb_per_ii AS ttl_disb_line_26,
    f3.coh_cop_ii AS coh_cop_line_27,
    f3.ttl_contb_ytd,
    f3.ttl_contb_ref_ytd,
    f3.net_contb_ytd,
    f3.ttl_op_exp_ytd,
    f3.ttl_offsets_to_op_exp_ytd,
    f3.net_op_exp_ytd,
    f3.ttl_indv_item_contb_ytd,
    f3.ttl_indv_unitem_contb_ytd,
    f3.ttl_indv_contb_ytd,
    f3.pol_pty_cmte_contb_ytd,
    f3.other_pol_cmte_contb_ytd,
    f3.cand_contb_ytd,
    f3.ttl_contb_col_ttl_ytd,
    f3.tranf_from_other_auth_cmte_ytd,
    f3.loans_made_by_cand_ytd,
    f3.all_other_loans_ytd,
    f3.ttl_loans_ytd,
    f3.offsets_to_op_exp_ytd,
    f3.other_receipts_ytd,
    f3.ttl_receipts_ytd,
    f3.op_exp_ytd,
    f3.tranf_to_other_auth_cmte_ytd,
    f3.loan_repymts_cand_loans_ytd,
    f3.loan_repymts_other_loans_ytd,
    f3.ttl_loan_repymts_ytd,
    f3.ref_indv_contb_ytd,
    f3.ref_pol_pty_cmte_contb_ytd,
    f3.ref_other_pol_cmte_contb_ytd,
    f3.ref_ttl_contb_col_ttl_ytd,
    f3.other_disb_ytd,
    f3.ttl_disb_ytd,
    f3.grs_rcpt_auth_cmte_prim,
    f3.agr_amt_contrib_pers_fund_prim,
    f3.grs_rcpt_min_pers_contrib_prim,
    f3.grs_rcpt_auth_cmte_gen,
    f3.agr_amt_pers_contrib_gen,
    f3.grs_rcpt_min_pers_contrib_gen,
    f3.cand_id,
    f3.cand_nm,
    f3.f3z1_rpt_tp,
    f3.f3z1_rpt_tp_desc,
    f3.begin_image_num,
    f3.end_image_num,
    'F3'::character varying(8) AS form_tp,
    f3.form_tp_desc,
    f3.file_num,
    f3.prev_file_num,
    f3.mst_rct_file_num,
    f3.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_3 f3
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3.sub_id = vs.orig_sub_id)))
  WHERE (f3.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3_vw OWNER TO fec;

--
-- Name: fec_vsum_f3p_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3p_vw AS
 SELECT f3p.cmte_id,
    f3p.cmte_nm,
    f3p.cmte_st1,
    f3p.cmte_st2,
    f3p.cmte_city,
    f3p.cmte_st,
    f3p.cmte_zip,
    f3p.addr_chg_flg,
    f3p.activity_primary,
    f3p.activity_general,
    f3p.term_rpt_flag,
    f3p.amndt_ind,
    f3p.amndt_ind_desc,
    f3p.rpt_tp,
    f3p.rpt_tp_desc,
    f3p.rpt_pgi,
    f3p.rpt_pgi_desc,
    f3p.election_dt,
    f3p.election_st,
    f3p.election_st_desc,
    f3p.cvg_start_dt,
    f3p.cvg_end_dt,
    f3p.rpt_yr,
    f3p.receipt_dt,
    (f3p.rpt_yr + (f3p.rpt_yr % (2)::numeric)) AS election_cycle,
    f3p.tres_sign_nm,
    f3p.tres_sign_dt,
    f3p.tres_l_nm,
    f3p.tres_f_nm,
    f3p.tres_m_nm,
    f3p.tres_prefix,
    f3p.tres_suffix,
    f3p.coh_bop,
    GREATEST(f3p.ttl_receipts_sum_page_per, f3p.ttl_receipts_per) AS ttl_receipts_per,
    f3p.ttl_receipts_sum_page_per,
    f3p.subttl_sum_page_per,
    GREATEST(f3p.ttl_disb_sum_page_per, f3p.ttl_disb_per) AS ttl_disb_per,
    f3p.ttl_disb_sum_page_per,
    f3p.coh_cop,
    f3p.debts_owed_to_cmte,
    f3p.debts_owed_by_cmte,
    f3p.exp_subject_limits,
    f3p.net_contb_sum_page_per,
    f3p.net_op_exp_sum_page_per,
    f3p.fed_funds_per,
    f3p.indv_item_contb_per,
    f3p.indv_unitem_contb_per,
    f3p.indv_contb_per AS ttl_indiv_contb_per,
    f3p.pol_pty_cmte_contb_per,
    f3p.other_pol_cmte_contb_per,
    f3p.cand_contb_per,
    f3p.ttl_contb_per,
    f3p.tranf_from_affilated_cmte_per,
    f3p.loans_received_from_cand_per,
    f3p.other_loans_received_per,
    f3p.ttl_loans_received_per,
    f3p.offsets_to_op_exp_per,
    f3p.offsets_to_fndrsg_exp_per,
    f3p.offsets_to_legal_acctg_per,
    f3p.ttl_offsets_to_op_exp_per,
    f3p.other_receipts_per,
    f3p.ttl_receipts_per AS ttl_receipts_per_line_22,
    f3p.op_exp_per,
    f3p.tranf_to_other_auth_cmte_per,
    f3p.fndrsg_disb_per,
    f3p.exempt_legal_acctg_disb_per,
    f3p.repymts_loans_made_by_cand_per,
    f3p.repymts_other_loans_per,
    f3p.ttl_loan_repymts_made_per,
    f3p.ref_indv_contb_per,
    f3p.ref_pol_pty_cmte_contb_per,
    f3p.ref_other_pol_cmte_contb_per,
    f3p.ttl_contb_ref_per,
    f3p.other_disb_per,
    f3p.ttl_disb_per AS ttl_disb_per_line_30,
    f3p.items_on_hand_liquidated,
    f3p.alabama_per,
    f3p.alaska_per,
    f3p.arizona_per,
    f3p.arkansas_per,
    f3p.california_per,
    f3p.colorado_per,
    f3p.connecticut_per,
    f3p.delaware_per,
    f3p.district_columbia_per,
    f3p.florida_per,
    f3p.georgia_per,
    f3p.hawaii_per,
    f3p.idaho_per,
    f3p.illinois_per,
    f3p.indiana_per,
    f3p.iowa_per,
    f3p.kansas_per,
    f3p.kentucky_per,
    f3p.louisiana_per,
    f3p.maine_per,
    f3p.maryland_per,
    f3p.massachusetts_per,
    f3p.michigan_per,
    f3p.minnesota_per,
    f3p.mississippi_per,
    f3p.missouri_per,
    f3p.montana_per,
    f3p.nebraska_per,
    f3p.nevada_per,
    f3p.new_hampshire_per,
    f3p.new_jersey_per,
    f3p.new_mexico_per,
    f3p.new_york_per,
    f3p.north_carolina_per,
    f3p.north_dakota_per,
    f3p.ohio_per,
    f3p.oklahoma_per,
    f3p.oregon_per,
    f3p.pennsylvania_per,
    f3p.rhode_island_per,
    f3p.south_carolina_per,
    f3p.south_dakota_per,
    f3p.tennessee_per,
    f3p.texas_per,
    f3p.utah_per,
    f3p.vermont_per,
    f3p.virginia_per,
    f3p.washington_per,
    f3p.west_virginia_per,
    f3p.wisconsin_per,
    f3p.wyoming_per,
    f3p.puerto_rico_per,
    f3p.guam_per,
    f3p.virgin_islands_per,
    f3p.ttl_per,
    f3p.fed_funds_ytd,
    f3p.indv_item_contb_ytd,
    f3p.indv_unitem_contb_ytd,
    f3p.indv_contb_ytd,
    f3p.pol_pty_cmte_contb_ytd,
    f3p.other_pol_cmte_contb_ytd,
    f3p.cand_contb_ytd,
    f3p.ttl_contb_ytd,
    f3p.tranf_from_affiliated_cmte_ytd,
    f3p.loans_received_from_cand_ytd,
    f3p.other_loans_received_ytd,
    f3p.ttl_loans_received_ytd,
    f3p.offsets_to_op_exp_ytd,
    f3p.offsets_to_fndrsg_exp_ytd,
    f3p.offsets_to_legal_acctg_ytd,
    f3p.ttl_offsets_to_op_exp_ytd,
    f3p.other_receipts_ytd,
    f3p.ttl_receipts_ytd,
    f3p.op_exp_ytd,
    f3p.tranf_to_other_auth_cmte_ytd,
    f3p.fndrsg_disb_ytd,
    f3p.exempt_legal_acctg_disb_ytd,
    f3p.repymts_loans_made_cand_ytd,
    f3p.repymts_other_loans_ytd,
    f3p.ttl_loan_repymts_made_ytd,
    f3p.ref_indv_contb_ytd,
    f3p.ref_pol_pty_cmte_contb_ytd,
    f3p.ref_other_pol_cmte_contb_ytd,
    f3p.ttl_contb_ref_ytd,
    f3p.other_disb_ytd,
    f3p.ttl_disb_ytd,
    f3p.alabama_ytd,
    f3p.alaska_ytd,
    f3p.arizona_ytd,
    f3p.arkansas_ytd,
    f3p.california_ytd,
    f3p.colorado_ytd,
    f3p.connecticut_ytd,
    f3p.delaware_ytd,
    f3p.district_columbia_ytd,
    f3p.florida_ytd,
    f3p.georgia_ytd,
    f3p.hawaii_ytd,
    f3p.idaho_ytd,
    f3p.illinois_ytd,
    f3p.indiana_ytd,
    f3p.iowa_ytd,
    f3p.kansas_ytd,
    f3p.kentucky_ytd,
    f3p.louisiana_ytd,
    f3p.maine_ytd,
    f3p.maryland_ytd,
    f3p.massachusetts_ytd,
    f3p.michigan_ytd,
    f3p.minnesota_ytd,
    f3p.mississippi_ytd,
    f3p.missouri_ytd,
    f3p.montana_ytd,
    f3p.nebraska_ytd,
    f3p.nevada_ytd,
    f3p.new_hampshire_ytd,
    f3p.new_jersey_ytd,
    f3p.new_mexico_ytd,
    f3p.new_york_ytd,
    f3p.north_carolina_ytd,
    f3p.north_dakota_ytd,
    f3p.ohio_ytd,
    f3p.oklahoma_ytd,
    f3p.oregon_ytd,
    f3p.pennsylvania_ytd,
    f3p.rhode_island_ytd,
    f3p.south_carolina_ytd,
    f3p.south_dakota_ytd,
    f3p.tennessee_ytd,
    f3p.texas_ytd,
    f3p.utah_ytd,
    f3p.vermont_ytd,
    f3p.virginia_ytd,
    f3p.washington_ytd,
    f3p.west_virginia_ytd,
    f3p.wisconsin_ytd,
    f3p.wyoming_ytd,
    f3p.puerto_rico_ytd,
    f3p.guam_ytd,
    f3p.virgin_islands_ytd,
    f3p.ttl_ytd,
    f3p.begin_image_num,
    f3p.end_image_num,
    'F3P'::character varying(8) AS form_tp,
    f3p.form_tp_desc,
    f3p.file_num,
    f3p.prev_file_num,
    f3p.mst_rct_file_num,
    f3p.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_3p f3p
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3p.sub_id = vs.orig_sub_id)))
  WHERE (f3p.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3p_vw OWNER TO fec;

--
-- Name: fec_vsum_f3ps_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3ps_vw AS
 SELECT f3ps.cmte_id,
    f3ps.cmte_nm,
    f3ps.election_dt,
    f3ps.day_after_election_dt,
    f3ps.net_contb,
    f3ps.net_exp,
    f3ps.fed_funds,
    f3ps.indv_item_contb,
    f3ps.indv_unitem_contb,
    f3ps.indv_contb,
    f3ps.pol_pty_cmte_contb,
    f3ps.pac_contb,
    f3ps.cand_contb,
    f3ps.ttl_contb,
    f3ps.tranf_from_affiliated_cmte,
    f3ps.loans_received_from_cand,
    f3ps.other_loans_received,
    f3ps.ttl_loans,
    f3ps.op_exp,
    f3ps.fndrsg_exp,
    f3ps.legal_and_acctg_exp,
    f3ps.ttl_offsets_to_op_exp,
    f3ps.other_receipts,
    f3ps.ttl_receipts,
    f3ps.op_exp2,
    f3ps.tranf_to_other_auth_cmte,
    f3ps.fndrsg_disb,
    f3ps.exempt_legal_and_acctg_disb,
    f3ps.loan_repymts_made_by_cand,
    f3ps.other_repymts,
    f3ps.ttl_loan_repymts_made,
    f3ps.ref_indv_contb,
    f3ps.ref_pol_pty_contb,
    f3ps.ref_other_pol_cmte_contb,
    f3ps.ttl_contb_ref,
    f3ps.other_disb,
    f3ps.ttl_disb,
    f3ps.alabama,
    f3ps.alaska,
    f3ps.arizona,
    f3ps.arkansas,
    f3ps.california,
    f3ps.colorado,
    f3ps.connecticut,
    f3ps.delaware,
    f3ps.district_columbia,
    f3ps.florida,
    f3ps.georgia,
    f3ps.hawaii,
    f3ps.idaho,
    f3ps.illinois,
    f3ps.indiana,
    f3ps.iowa,
    f3ps.kansas,
    f3ps.kentucky,
    f3ps.louisiana,
    f3ps.maine,
    f3ps.maryland,
    f3ps.massachusetts,
    f3ps.michigan,
    f3ps.minnesota,
    f3ps.mississippi,
    f3ps.missouri,
    f3ps.montana,
    f3ps.nebraska,
    f3ps.nevada,
    f3ps.new_hampshire,
    f3ps.new_jersey,
    f3ps.new_mexico,
    f3ps.new_york,
    f3ps.north_carolina,
    f3ps.north_dakota,
    f3ps.ohio,
    f3ps.oklahoma,
    f3ps.oregon,
    f3ps.pennsylvania,
    f3ps.rhode_island,
    f3ps.south_carolina,
    f3ps.south_dakota,
    f3ps.tennessee,
    f3ps.texas,
    f3ps.utah,
    f3ps.vermont,
    f3ps.virginia,
    f3ps.washington,
    f3ps.west_virginia,
    f3ps.wisconsin,
    f3ps.wyoming,
    f3ps.puerto_rico,
    f3ps.guam,
    f3ps.virgin_islands,
    f3ps.ttl,
    f3ps.file_num,
    f3ps.link_id,
    f3ps.image_num,
    'F3PS'::character varying(8) AS form_tp,
    f3ps.form_tp_desc,
    f3ps.sub_id,
    f3p.receipt_dt,
    f3p.rpt_tp,
    f3p.rpt_yr,
    (f3p.rpt_yr + (f3p.rpt_yr % (2)::numeric)) AS election_cycle,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM ((disclosure.nml_form_3ps f3ps
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3ps.link_id = vs.orig_sub_id)))
     JOIN disclosure.nml_form_3p f3p ON ((f3ps.link_id = f3p.sub_id)))
  WHERE (f3ps.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3ps_vw OWNER TO fec;

--
-- Name: fec_vsum_f3s_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3s_vw AS
 SELECT f3s.cmte_id,
    f3s.cmte_nm,
    f3s.election_dt,
    f3s.day_after_election_dt,
    f3s.ttl_contb,
    f3s.ttl_contb_ref,
    f3s.net_contb,
    f3s.ttl_op_exp,
    f3s.ttl_offsets_to_op_exp,
    f3s.net_op_exp,
    f3s.indv_item_contb,
    f3s.indv_unitem_contb,
    f3s.ttl_indv_contb,
    f3s.pol_pty_cmte_contb,
    f3s.other_pol_cmte_contb,
    f3s.cand_contb,
    f3s.ttl_contb_column_ttl,
    f3s.tranf_from_other_auth_cmte,
    f3s.loans_made_by_cand,
    f3s.all_other_loans,
    f3s.ttl_loans,
    f3s.offsets_to_op_exp,
    f3s.other_receipts,
    f3s.ttl_receipts,
    f3s.op_exp,
    f3s.tranf_to_other_auth_cmte,
    f3s.loan_repymts_cand_loans,
    f3s.loan_repymts_other_loans,
    f3s.ttl_loan_repymts,
    f3s.ref_indv_contb,
    f3s.ref_pol_pty_cmte_contb,
    f3s.ref_other_pol_cmte_contb,
    f3s.ttl_contb_ref_col_ttl,
    f3s.other_disb,
    f3s.ttl_disb,
    f3s.file_num,
    f3s.link_id,
    f3s.image_num,
    'F3S'::character varying(8) AS form_tp,
    f3s.form_tp_desc,
    f3s.amndt_ind AS action_cd,
    f3s.amndt_ind_desc AS action_cd_desc,
    f3s.sub_id,
    f3.receipt_dt,
    f3.rpt_tp,
    f3.rpt_yr,
    (f3.rpt_yr + (f3.rpt_yr % (2)::numeric)) AS election_cycle,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM ((disclosure.nml_form_3s f3s
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3s.sub_id = vs.orig_sub_id)))
     JOIN disclosure.nml_form_3 f3 ON ((f3s.link_id = f3.sub_id)))
  WHERE (f3s.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3s_vw OWNER TO fec;

--
-- Name: fec_vsum_f3x_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3x_vw AS
 SELECT f3x.cmte_id,
    f3x.cmte_nm,
    f3x.cmte_st1,
    f3x.cmte_st2,
    f3x.cmte_city,
    f3x.cmte_st,
    f3x.cmte_zip,
    f3x.cmte_addr_chg_flg,
    f3x.qual_cmte_flg,
    f3x.amndt_ind,
    f3x.amndt_ind_desc,
    f3x.rpt_tp,
    f3x.rpt_tp_desc,
    f3x.rpt_pgi,
    f3x.rpt_pgi_desc,
    f3x.election_dt,
    f3x.election_st,
    f3x.election_st_desc,
    f3x.cvg_start_dt,
    f3x.cvg_end_dt,
    f3x.rpt_yr,
    f3x.receipt_dt,
    (f3x.rpt_yr + (f3x.rpt_yr % (2)::numeric)) AS election_cycle,
    f3x.tres_sign_nm,
    f3x.tres_sign_dt,
    f3x.tres_l_nm,
    f3x.tres_f_nm,
    f3x.tres_m_nm,
    f3x.tres_prefix,
    f3x.tres_suffix,
    f3x.multicand_flg,
    f3x.coh_bop,
    GREATEST(f3x.ttl_receipts_sum_page_per, f3x.ttl_receipts_per) AS ttl_receipts,
    f3x.ttl_receipts_sum_page_per,
    f3x.subttl_sum_page_per,
    GREATEST(f3x.ttl_disb_sum_page_per, f3x.ttl_disb_per) AS ttl_disb,
    f3x.ttl_disb_sum_page_per,
    f3x.coh_cop,
    f3x.debts_owed_to_cmte,
    f3x.debts_owed_by_cmte,
    f3x.indv_item_contb_per,
    f3x.indv_unitem_contb_per,
    f3x.ttl_indv_contb,
    f3x.pol_pty_cmte_contb_per_i,
    f3x.other_pol_cmte_contb_per_i,
    f3x.ttl_contb_col_ttl_per,
    f3x.tranf_from_affiliated_pty_per,
    f3x.all_loans_received_per,
    f3x.loan_repymts_received_per,
    GREATEST(f3x.offsets_to_op_exp_per_i, f3x.offsets_to_op_exp_per_ii) AS offests_to_op_exp,
    f3x.offsets_to_op_exp_per_i AS offests_to_op_exp_line_15,
    f3x.fed_cand_contb_ref_per,
    f3x.other_fed_receipts_per,
    f3x.tranf_from_nonfed_acct_per,
    f3x.tranf_from_nonfed_levin_per,
    f3x.ttl_nonfed_tranf_per,
    f3x.ttl_receipts_per AS ttl_receipts_per_line_19,
    f3x.ttl_fed_receipts_per,
    f3x.shared_fed_op_exp_per,
    f3x.shared_nonfed_op_exp_per,
    f3x.other_fed_op_exp_per,
    f3x.ttl_op_exp_per,
    f3x.tranf_to_affliliated_cmte_per,
    f3x.fed_cand_cmte_contb_per,
    f3x.indt_exp_per,
    f3x.coord_exp_by_pty_cmte_per,
    f3x.loan_repymts_made_per,
    f3x.loans_made_per,
    f3x.indv_contb_ref_per,
    f3x.pol_pty_cmte_contb_per_ii AS pol_pty_cmte_refund,
    f3x.other_pol_cmte_contb_per_ii AS other_pol_cmte_refund,
    GREATEST(f3x.ttl_contb_ref_per_i, f3x.ttl_contb_ref_per_ii) AS ttl_contb_refund,
    f3x.ttl_contb_ref_per_i AS ttl_contb_refund_line_28d,
    f3x.other_disb_per,
    f3x.shared_fed_actvy_fed_shr_per,
    f3x.shared_fed_actvy_nonfed_per,
    f3x.non_alloc_fed_elect_actvy_per,
    f3x.ttl_fed_elect_actvy_per,
    f3x.ttl_disb_per AS ttl_disb_per_line_31,
    f3x.ttl_fed_disb_per,
    f3x.ttl_contb_per,
    f3x.ttl_contb_ref_per_ii AS ttl_contb_refund_line_34,
    f3x.net_contb_per,
    f3x.ttl_fed_op_exp_per,
    f3x.offsets_to_op_exp_per_ii AS offests_to_op_exp_line_37,
    f3x.net_op_exp_per,
    f3x.coh_begin_calendar_yr,
    f3x.calendar_yr,
    f3x.ttl_receipts_sum_page_ytd,
    f3x.subttl_sum_ytd,
    f3x.ttl_disb_sum_page_ytd,
    f3x.coh_coy,
    f3x.indv_item_contb_ytd,
    f3x.indv_unitem_contb_ytd,
    f3x.ttl_indv_contb_ytd,
    f3x.pol_pty_cmte_contb_ytd_i,
    f3x.other_pol_cmte_contb_ytd_i,
    f3x.ttl_contb_col_ttl_ytd,
    f3x.tranf_from_affiliated_pty_ytd,
    f3x.all_loans_received_ytd,
    f3x.loan_repymts_received_ytd,
    f3x.offsets_to_op_exp_ytd_i,
    f3x.fed_cand_cmte_contb_ytd,
    f3x.other_fed_receipts_ytd,
    f3x.tranf_from_nonfed_acct_ytd,
    f3x.tranf_from_nonfed_levin_ytd,
    f3x.ttl_nonfed_tranf_ytd,
    f3x.ttl_receipts_ytd,
    f3x.ttl_fed_receipts_ytd,
    f3x.shared_fed_op_exp_ytd,
    f3x.shared_nonfed_op_exp_ytd,
    f3x.other_fed_op_exp_ytd,
    f3x.ttl_op_exp_ytd,
    f3x.tranf_to_affilitated_cmte_ytd,
    f3x.fed_cand_cmte_contb_ref_ytd,
    f3x.indt_exp_ytd,
    f3x.coord_exp_by_pty_cmte_ytd,
    f3x.loan_repymts_made_ytd,
    f3x.loans_made_ytd,
    f3x.indv_contb_ref_ytd,
    f3x.pol_pty_cmte_contb_ytd_ii AS pol_pty_cmte_refund_ytd,
    f3x.other_pol_cmte_contb_ytd_ii AS other_pol_cmte_refund_ytd,
    f3x.ttl_contb_ref_ytd_i AS ttl_contb_refund_ytd,
    f3x.other_disb_ytd,
    f3x.shared_fed_actvy_fed_shr_ytd,
    f3x.shared_fed_actvy_nonfed_ytd,
    f3x.non_alloc_fed_elect_actvy_ytd,
    f3x.ttl_fed_elect_actvy_ytd,
    f3x.ttl_disb_ytd,
    f3x.ttl_fed_disb_ytd,
    f3x.ttl_contb_ytd,
    f3x.ttl_contb_ref_ytd_ii,
    f3x.net_contb_ytd,
    f3x.ttl_fed_op_exp_ytd,
    f3x.offsets_to_op_exp_ytd_ii,
    f3x.net_op_exp_ytd,
    f3x.begin_image_num,
    f3x.end_image_num,
    'F3X'::character varying(8) AS form_tp,
    f3x.form_tp_desc,
    f3x.file_num,
    f3x.prev_file_num,
    f3x.mst_rct_file_num,
    f3x.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_3x f3x
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3x.sub_id = vs.orig_sub_id)))
  WHERE (f3x.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3x_vw OWNER TO fec;

--
-- Name: fec_vsum_f3z_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f3z_vw AS
 SELECT f3z.pcc_id,
    f3z.pcc_nm,
    f3z.auth_cmte_id,
    f3z.auth_cmte_nm,
    f3z.indv_contb,
    f3z.pol_pty_contb,
    f3z.other_pol_cmte_contb,
    f3z.cand_contb,
    f3z.ttl_contb,
    f3z.tranf_from_other_auth_cmte,
    f3z.loans_made_by_cand,
    f3z.all_other_loans,
    f3z.ttl_loans,
    f3z.offsets_to_op_exp,
    f3z.other_receipts,
    f3z.ttl_receipts,
    f3z.op_exp,
    f3z.tranf_to_other_auth_cmte,
    f3z.repymts_loans_made_cand,
    f3z.repymts_all_other_loans,
    f3z.ttl_loan_repymts,
    f3z.ref_indv_contb,
    f3z.ref_pol_pty_cmte_contb,
    f3z.ref_other_pol_cmte_contb,
    f3z.ttl_contb_ref,
    f3z.other_disb,
    f3z.ttl_disb,
    f3z.coh_bop,
    f3z.coh_cop,
    f3z.debts_owed_to_cmte,
    f3z.debts_owed_by_cmte,
    f3z.net_contb,
    f3z.net_op_exp,
    f3z.cvg_start_dt,
    f3z.cvg_end_dt,
    f3z.file_num,
    f3z.link_id,
    f3z.image_num,
    f3z.form_tp,
    f3z.form_tp_desc,
    f3z.sub_id,
    f3.receipt_dt,
    f3.rpt_tp,
    f3.rpt_yr,
    (f3.rpt_yr + (f3.rpt_yr % (2)::numeric)) AS election_cycle,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM ((disclosure.nml_form_3z f3z
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f3z.link_id = vs.orig_sub_id)))
     JOIN disclosure.nml_form_3 f3 ON ((f3z.link_id = f3.sub_id)))
  WHERE (f3z.delete_ind IS NULL);


ALTER TABLE fec_vsum_f3z_vw OWNER TO fec;

--
-- Name: fec_vsum_f56_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f56_vw AS
 SELECT f56.filer_cmte_id,
    f56.entity_tp,
    f56.entity_tp_desc,
    f56.contbr_nm,
    f56.contbr_l_nm,
    f56.contbr_f_nm,
    f56.contbr_m_nm,
    f56.contbr_prefix,
    f56.contbr_suffix,
    f56.contbr_st1,
    f56.contbr_st2,
    f56.conbtr_city,
    f56.contbr_st,
    f56.contbr_zip,
    f56.contbr_employer,
    f56.contbr_occupation,
    f56.contb_dt,
    f56.contb_amt,
    f56.cand_id,
    f56.cand_nm,
    f56.cand_office,
    f56.cand_office_desc,
    f56.cand_office_st,
    f56.cand_office_st_desc,
    f56.cand_office_district,
    f56.conduit_cmte_id,
    f56.conduit_nm,
    f56.conduit_st1,
    f56.conduit_st2,
    f56.conduit_city,
    f56.conduit_st,
    f56.conduit_zip,
    f56.amndt_ind AS action_cd,
    f56.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f56.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f56.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SA-F56'::character varying(8) AS schedule_type,
    f56.form_tp_desc AS schedule_type_desc,
    f56.image_num,
    f56.file_num,
    f56.link_id,
    f56.orig_sub_id,
    f56.sub_id,
    'F5'::character varying(8) AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + mod(vs.rpt_yr, (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_56 f56,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f56.link_id = vs.orig_sub_id) AND ((vs.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])) AND ((f56.amndt_ind)::text <> 'D'::text) AND (f56.delete_ind IS NULL));


ALTER TABLE fec_vsum_f56_vw OWNER TO fec;

--
-- Name: fec_vsum_f57_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE fec_vsum_f57_queue_new (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric
);


ALTER TABLE fec_vsum_f57_queue_new OWNER TO fec;

--
-- Name: fec_vsum_f57_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE fec_vsum_f57_queue_old (
    filer_cmte_id character varying(9),
    pye_nm character varying(200),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    schedule_type character varying(8),
    schedule_type_desc character varying(90),
    link_id numeric(19,0),
    image_num character varying(18),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric
);


ALTER TABLE fec_vsum_f57_queue_old OWNER TO fec;

--
-- Name: fec_vsum_f57_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f57_vw AS
 SELECT f57.filer_cmte_id,
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
    f57.exp_purpose,
    f57.entity_tp,
    f57.entity_tp_desc,
    f57.catg_cd,
    f57.catg_cd_desc,
    f57.s_o_cand_id,
    f57.s_o_cand_l_nm,
    f57.s_o_cand_f_nm,
    f57.s_o_cand_m_nm,
    f57.s_o_cand_prefix,
    f57.s_o_cand_suffix,
    f57.s_o_cand_nm,
    f57.s_o_cand_office,
    f57.s_o_cand_office_desc,
    f57.s_o_cand_office_st,
    f57.s_o_cand_office_state_desc,
    f57.s_o_cand_office_district,
    f57.s_o_ind,
    f57.s_o_ind_desc,
    f57.election_tp,
    f57.fec_election_tp_desc,
    f57.fec_election_yr,
    f57.election_tp_desc,
    f57.cal_ytd_ofc_sought,
    f57.exp_dt,
    f57.exp_amt,
    f57.exp_tp,
    f57.exp_tp_desc,
    f57.conduit_cmte_id,
    f57.conduit_cmte_nm,
    f57.conduit_cmte_st1,
    f57.conduit_cmte_st2,
    f57.conduit_cmte_city,
    f57.conduit_cmte_st,
    f57.conduit_cmte_zip,
    f57.amndt_ind AS action_cd,
    f57.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f57.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f57.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SE-F57'::character varying(8) AS schedule_type,
    f57.form_tp_desc AS schedule_type_desc,
    f57.link_id,
    f57.image_num,
    f57.file_num,
    f57.orig_sub_id,
    f57.sub_id,
    'F5'::character varying(8) AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + mod(vs.rpt_yr, (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_57 f57,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f57.link_id = vs.orig_sub_id) AND ((vs.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])) AND ((f57.amndt_ind)::text <> 'D'::text) AND (f57.delete_ind IS NULL));


ALTER TABLE fec_vsum_f57_vw OWNER TO fec;

--
-- Name: fec_vsum_f5_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f5_vw AS
 SELECT f5.indv_org_id,
    f5.indv_org_nm,
    f5.indv_l_nm,
    f5.indv_f_nm,
    f5.indv_m_nm,
    f5.indv_prefix,
    f5.indv_suffix,
    f5.indv_org_st1,
    f5.indv_org_st2,
    f5.indv_org_city,
    f5.indv_org_st,
    f5.indv_org_zip,
    f5.entity_tp,
    f5.addr_chg_flg,
    f5.qual_nonprofit_corp_ind,
    f5.indv_org_employer,
    f5.indv_org_occupation,
    f5.amndt_ind,
    f5.amndt_ind_desc,
    f5.orig_amndt_dt,
    f5.rpt_tp,
    f5.rpt_tp_desc,
    f5.rpt_pgi,
    f5.rpt_pgi_desc,
    f5.cvg_start_dt,
    f5.cvg_end_dt,
    f5.rpt_yr,
    f5.receipt_dt,
    (f5.rpt_yr + mod(f5.rpt_yr, (2)::numeric)) AS election_cycle,
    f5.ttl_indt_contb,
    f5.ttl_indt_exp,
    f5.filer_nm,
    f5.filer_sign_nm,
    f5.filer_sign_dt,
    f5.filer_l_nm,
    f5.filer_f_nm,
    f5.filer_m_nm,
    f5.filer_prefix,
    f5.filer_suffix,
    f5.notary_sign_dt,
    f5.notary_commission_exprtn_dt,
    f5.notary_nm,
    f5.begin_image_num,
    f5.end_image_num,
    'F5'::character varying(8) AS form_tp,
    f5.form_tp_desc,
    f5.file_num,
    f5.prev_file_num,
    f5.mst_rct_file_num,
    f5.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_5 f5
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f5.sub_id = vs.orig_sub_id)))
  WHERE ((f5.delete_ind IS NULL) AND ((f5.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])));


ALTER TABLE fec_vsum_f5_vw OWNER TO fec;

--
-- Name: fec_vsum_f76_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f76_vw AS
 SELECT f76.org_id,
    f76.communication_tp,
    f76.communication_tp_desc,
    f76.communication_class,
    f76.communication_class_desc,
    f76.communication_dt,
    f76.s_o_ind,
    f76.s_o_ind_desc,
    f76.s_o_cand_id,
    f76.s_o_cand_nm,
    f76.s_o_cand_l_nm,
    f76.s_o_cand_f_nm,
    f76.s_o_cand_m_nm,
    f76.s_o_cand_prefix,
    f76.s_o_cand_suffix,
    f76.s_o_cand_office,
    f76.s_o_cand_office_desc,
    f76.s_o_cand_office_st,
    f76.s_o_cand_office_st_desc,
    f76.s_o_cand_office_district,
    f76.s_o_rpt_pgi,
    f76.s_o_rpt_pgi_desc,
    f76.communication_cost,
    f76.election_other_desc,
    f76.transaction_tp,
    f76.amndt_ind AS action_cd,
    f76.amndt_ind_desc AS action_cd_desc,
    f76.tran_id,
    'F76'::character varying(8) AS schedule_type,
    f76.form_tp_desc AS schedule_type_desc,
    f76.image_num,
    f76.file_num,
    f76.link_id,
    f76.orig_sub_id,
    f76.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_76 f76,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f76.link_id = vs.orig_sub_id) AND ((f76.amndt_ind)::text <> 'D'::text) AND (f76.delete_ind IS NULL));


ALTER TABLE fec_vsum_f76_vw OWNER TO fec;

--
-- Name: fec_vsum_f7_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f7_vw AS
 SELECT f7.org_id,
    f7.org_nm,
    f7.org_st1,
    f7.org_st2,
    f7.org_city,
    f7.org_st,
    f7.org_zip,
    f7.org_tp,
    f7.org_tp_desc,
    f7.rpt_tp,
    f7.rpt_tp_desc,
    f7.rpt_pgi,
    f7.rpt_pgi_desc,
    f7.amdnt_ind,
    f7.amndt_ind_desc,
    f7.election_dt,
    f7.election_st,
    f7.election_st_desc,
    f7.cvg_start_dt,
    f7.cvg_end_dt,
    f7.ttl_communication_cost,
    f7.filer_sign_nm,
    f7.filer_l_nm,
    f7.filer_f_nm,
    f7.filer_m_nm,
    f7.filer_prefix,
    f7.filer_suffix,
    f7.filer_sign_dt,
    f7.filer_title,
    f7.receipt_dt,
    f7.rpt_yr,
    (f7.rpt_yr + (f7.rpt_yr % (2)::numeric)) AS election_cycle,
    f7.begin_image_num,
    f7.end_image_num,
    'F7'::character varying(8) AS form_tp,
    f7.form_tp_desc,
    f7.file_num,
    f7.prev_file_num,
    f7.mst_rct_file_num,
    f7.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_7 f7
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f7.sub_id = vs.orig_sub_id)))
  WHERE (f7.delete_ind IS NULL);


ALTER TABLE fec_vsum_f7_vw OWNER TO fec;

--
-- Name: fec_vsum_f91_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f91_vw AS
 SELECT f91.filer_cmte_id,
    f91.shr_ex_ctl_ind_nm,
    f91.shr_ex_ctl_l_nm,
    f91.shr_ex_ctl_f_nm,
    f91.shr_ex_ctl_m_nm,
    f91.shr_ex_ctl_prefix,
    f91.shr_ex_ctl_suffix,
    f91.shr_ex_ctl_street1,
    f91.shr_ex_ctl_street2,
    f91.shr_ex_ctl_city,
    f91.shr_ex_ctl_st,
    f91.shr_ex_ctl_st_desc,
    f91.shr_ex_ctl_zip,
    f91.shr_ex_ctl_employ,
    f91.shr_ex_ctl_occup,
    f91.amndt_ind AS action_cd,
    f91.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f91.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f91.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'F91'::character varying(8) AS schedule_type,
    f91.form_tp_desc AS schedule_type_desc,
    f91.begin_image_num,
    f91.file_num,
    f91.link_id,
    f91.orig_sub_id,
    f91.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_91 f91,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f91.link_id = vs.orig_sub_id) AND ((f91.amndt_ind)::text <> 'D'::text) AND (f91.delete_ind IS NULL));


ALTER TABLE fec_vsum_f91_vw OWNER TO fec;

--
-- Name: fec_vsum_f94_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f94_vw AS
 SELECT f94.filer_cmte_id,
    f94.cand_id,
    f94.cand_nm,
    f94.cand_l_nm,
    f94.cand_f_nm,
    f94.cand_m_nm,
    f94.cand_prefix,
    f94.cand_suffix,
    f94.cand_office,
    f94.cand_office_desc,
    f94.cand_office_st,
    f94.cand_office_st_desc,
    f94.cand_office_district,
    f94.election_tp,
    f94.election_tp_desc,
    f94.fec_election_tp_desc,
    f94.amndt_ind AS action_cd,
    f94.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((f94.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN f94.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'F94'::character varying(8) AS schedule_type,
    f94.form_tp_desc AS schedule_type_desc,
    f94.begin_image_num,
    f94.sb_link_id,
    f94.file_num,
    f94.link_id,
    f94.orig_sub_id,
    f94.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_form_94 f94,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((f94.link_id = vs.orig_sub_id) AND ((f94.amndt_ind)::text <> 'D'::text) AND (f94.delete_ind IS NULL));


ALTER TABLE fec_vsum_f94_vw OWNER TO fec;

--
-- Name: fec_vsum_f9_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_f9_vw AS
 SELECT f9.cmte_id,
    f9.ind_org_corp_nm,
    f9.indv_l_nm,
    f9.indv_f_nm,
    f9.indv_m_nm,
    f9.indv_prefix,
    f9.indv_suffix,
    f9.ind_org_corp_st1,
    f9.ind_org_corp_st2,
    f9.ind_org_corp_city,
    f9.ind_org_corp_st,
    f9.ind_org_corp_st_desc,
    f9.ind_org_corp_zip,
    f9.entity_tp,
    f9.addr_chg_flg,
    f9.addr_chg_flg_desc,
    f9.ind_org_corp_emp,
    f9.ind_org_corp_occup,
    f9.amndt_ind,
    f9.rpt_tp,
    f9.beg_cvg_dt,
    f9.end_cvg_dt,
    f9.comm_title,
    f9.pub_distrib_dt,
    f9.qual_nonprofit_flg,
    f9.qual_nonprofit_flg_desc,
    f9.segr_bank_acct_flg,
    f9.segr_bank_acct_flg_desc,
    f9.ind_custod_nm,
    f9.cust_l_nm,
    f9.cust_f_nm,
    f9.cust_m_nm,
    f9.cust_prefix,
    f9.cust_suffix,
    f9.ind_custod_st1,
    f9.ind_custod_st2,
    f9.ind_custod_city,
    f9.ind_custod_st,
    f9.ind_custod_st_desc,
    f9.ind_custod_zip,
    f9.ind_custod_emp,
    f9.ind_custod_occup,
    f9.ttl_dons_this_stmt,
    f9.ttl_disb_this_stmt,
    f9.filer_sign_nm,
    f9.filer_l_nm,
    f9.filer_f_nm,
    f9.filer_m_nm,
    f9.filer_prefix,
    f9.filer_suffix,
    f9.filer_sign_dt,
    f9.filer_cd,
    f9.filer_cd_desc,
    f9.begin_image_num,
    f9.end_image_num,
    'F9'::character varying(8) AS form_tp,
    f9.form_tp_desc,
    f9.receipt_dt,
    f9.rpt_yr,
    (f9.rpt_yr + (f9.rpt_yr % (2)::numeric)) AS election_cycle,
    f9.file_num,
    f9.prev_file_num,
    f9.mst_rct_file_num,
    f9.sub_id,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_9 f9
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f9.sub_id = vs.orig_sub_id)))
  WHERE (f9.delete_ind IS NULL);


ALTER TABLE fec_vsum_f9_vw OWNER TO fec;

--
-- Name: fec_vsum_form_4_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_form_4_vw AS
 SELECT f4.cmte_id,
    f4.cmte_nm,
    f4.cmte_st1,
    f4.cmte_st2,
    f4.cmte_city,
    f4.cmte_st,
    f4.cmte_zip,
    f4.cmte_tp,
    f4.cmte_tp_desc,
    f4.cmte_desc,
    f4.amndt_ind,
    f4.amndt_ind_desc,
    f4.rpt_tp,
    f4.rpt_tp_desc,
    f4.cvg_start_dt,
    f4.cvg_end_dt,
    f4.rpt_yr,
    f4.receipt_dt,
    (f4.rpt_yr + mod(f4.rpt_yr, (2)::numeric)) AS cycle,
    f4.coh_bop,
    f4.ttl_receipts_sum_page_per,
    f4.subttl_sum_page_per,
    f4.ttl_disb_sum_page_per,
    f4.coh_cop,
    f4.debts_owed_to_cmte_per,
    f4.debts_owed_by_cmte_per,
    f4.convn_exp_per,
    f4.ref_reb_ret_convn_exp_per,
    f4.exp_subject_limits_per,
    f4.exp_prior_yrs_subject_lim_per,
    f4.ttl_exp_subject_limits,
    f4.fed_funds_per,
    f4.item_convn_exp_contb_per,
    f4.unitem_convn_exp_contb_per,
    f4.subttl_convn_exp_contb_per,
    f4.tranf_from_affiliated_cmte_per,
    f4.loans_received_per,
    f4.loan_repymts_received_per,
    f4.subttl_loan_repymts_per,
    f4.item_ref_reb_ret_per,
    f4.unitem_ref_reb_ret_per,
    f4.subttl_ref_reb_ret_per,
    f4.item_other_ref_reb_ret_per,
    f4.unitem_other_ref_reb_ret_per,
    f4.subttl_other_ref_reb_ret_per,
    f4.item_other_income_per,
    f4.unitem_other_income_per,
    f4.subttl_other_income_per,
    f4.ttl_receipts_per,
    f4.item_convn_exp_disb_per,
    f4.unitem_convn_exp_disb_per,
    f4.subttl_convn_exp_disb_per,
    f4.tranf_to_affiliated_cmte_per,
    f4.loans_made_per,
    f4.loan_repymts_made_per,
    f4.subttl_loan_repymts_disb_per,
    f4.item_other_disb_per,
    f4.unitem_other_disb_per,
    f4.subttl_other_disb_per,
    f4.ttl_disb_per,
    f4.coh_begin_calendar_yr,
    f4.calendar_yr,
    f4.ttl_receipts_sum_page_ytd,
    f4.subttl_sum_page_ytd,
    f4.ttl_disb_sum_page_ytd,
    f4.coh_coy,
    f4.convn_exp_ytd,
    f4.ref_reb_ret_convn_exp_ytd,
    f4.exp_subject_limits_ytd,
    f4.exp_prior_yrs_subject_lim_ytd,
    f4.ttl_exp_subject_limits_ytd,
    f4.fed_funds_ytd,
    f4.subttl_convn_exp_contb_ytd,
    f4.tranf_from_affiliated_cmte_ytd,
    f4.subttl_loan_repymts_ytd,
    f4.subttl_ref_reb_ret_deposit_ytd,
    f4.subttl_other_ref_reb_ret_ytd,
    f4.subttl_other_income_ytd,
    f4.ttl_receipts_ytd,
    f4.subttl_convn_exp_disb_ytd,
    f4.tranf_to_affiliated_cmte_ytd,
    f4.subttl_loan_repymts_disb_ytd,
    f4.subttl_other_disb_ytd,
    f4.ttl_disb_ytd,
    f4.tres_sign_nm,
    f4.tres_l_nm,
    f4.tres_f_nm,
    f4.tres_m_nm,
    f4.tres_prefix,
    f4.tres_suffix,
    f4.tres_sign_dt,
    f4.file_num,
    f4.prev_file_num,
    f4.mst_rct_file_num,
    f4.sub_id,
    f4.begin_image_num,
    f4.end_image_num,
    f4.form_tp,
    f4.form_tp_desc,
        CASE
            WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
            ELSE 'N'::text
        END AS most_recent_filing_flag
   FROM (disclosure.nml_form_4 f4
     LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((f4.sub_id = vs.orig_sub_id)))
  WHERE (f4.delete_ind IS NULL);


ALTER TABLE fec_vsum_form_4_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_a_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_a_vw AS
 SELECT sa.cmte_id,
    sa.cmte_nm,
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
    sa.amndt_ind AS action_cd,
    sa.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sa.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sa.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    sa.back_ref_sched_nm,
    'SA'::character varying(8) AS schedule_type,
    sa.form_tp_desc AS schedule_type_desc,
    sa.line_num,
    sa.image_num,
    sa.file_num,
    sa.link_id,
    sa.orig_sub_id,
    sa.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_a sa,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sa.link_id = vs.orig_sub_id) AND ((sa.amndt_ind)::text <> 'D'::text) AND (sa.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_a_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_b_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_b_vw AS
 SELECT sb.cmte_id,
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
    sb.amndt_ind AS action_cd,
    sb.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((sb.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sb.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'SB'::character varying(8) AS schedule_type,
    sb.form_tp_desc AS schedule_type_desc,
    sb.line_num,
    sb.image_num,
    sb.file_num,
    sb.link_id,
    sb.orig_sub_id,
    sb.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_b sb,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sb.link_id = vs.orig_sub_id) AND ((sb.amndt_ind)::text <> 'D'::text) AND (sb.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_b_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_c1_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_c1_vw AS
 SELECT sc1.cmte_id,
    sc1.cmte_nm,
    sc1.entity_tp_desc,
    sc1.loan_src_nm,
    sc1.loan_src_st1,
    sc1.loan_src_st2,
    sc1.loan_src_city,
    sc1.loan_src_st,
    sc1.loan_src_zip,
    sc1.entity_tp,
    sc1.loan_amt,
    sc1.interest_rate_pct,
    sc1.incurred_dt,
    sc1.due_dt,
    sc1.loan_restructured_flg,
    sc1.orig_loan_dt,
    sc1.credit_amt_this_draw,
    sc1.ttl_bal,
    sc1.other_liable_pty_flg,
    sc1.collateral_flg,
    sc1.collateral_desc,
    sc1.collateral_value,
    sc1.perfected_interest_flg,
    sc1.future_income_flg,
    sc1.future_income_desc,
    sc1.future_income_est_value,
    sc1.depository_acct_est_dt,
    sc1.acct_loc_nm,
    sc1.acct_loc_st1,
    sc1.acct_loc_st2,
    sc1.acct_loc_city,
    sc1.acct_loc_st,
    sc1.acct_loc_zip,
    sc1.depository_acct_auth_dt,
    sc1.loan_basis_desc,
    sc1.tres_sign_nm,
    sc1.tres_l_nm,
    sc1.tres_f_nm,
    sc1.tres_m_nm,
    sc1.tres_prefix,
    sc1.tres_suffix,
    sc1.tres_sign_dt,
    sc1.auth_sign_nm,
    sc1.auth_sign_l_nm,
    sc1.auth_sign_f_nm,
    sc1.auth_sign_m_nm,
    sc1.auth_sign_prefix,
    sc1.auth_sign_suffix,
    sc1.auth_rep_title,
    sc1.auth_sign_dt,
    sc1.amndt_ind AS action_cd,
    sc1.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sc1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc1.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sc1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc1.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    'SC1'::character varying(8) AS schedule_type,
    sc1.form_tp_desc AS schedule_type_desc,
    sc1.line_num,
    sc1.image_num,
    sc1.file_num,
    sc1.link_id,
    sc1.orig_sub_id,
    sc1.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_c1 sc1,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sc1.link_id = vs.orig_sub_id) AND ((sc1.amndt_ind)::text <> 'D'::text) AND (sc1.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_c1_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_c2_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_c2_vw AS
 SELECT sc2.cmte_id,
    sc2.back_ref_tran_id,
    sc2.guar_endr_nm,
    sc2.guar_endr_l_nm,
    sc2.guar_endr_f_nm,
    sc2.guar_endr_m_nm,
    sc2.guar_endr_prefix,
    sc2.guar_endr_suffix,
    sc2.guar_endr_st1,
    sc2.guar_endr_st2,
    sc2.guar_endr_city,
    sc2.guar_endr_st,
    sc2.guar_endr_zip,
    sc2.guar_endr_employer,
    sc2.guar_endr_occupation,
    sc2.amt_guaranteed_outstg,
    sc2.receipt_dt,
    sc2.amndt_ind AS action_cd,
    sc2.amndt_ind_desc AS action_cd_desc,
    sc2.file_num,
        CASE
            WHEN ("substring"(((sc2.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc2.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    vs.form_tp_cd AS filing_form,
    'SC2'::character varying(8) AS schedule_type,
    sc2.form_tp_desc AS schedule_type_desc,
    sc2.line_num,
    sc2.image_num,
    sc2.sub_id,
    sc2.link_id,
    sc2.orig_sub_id,
    vs.rpt_yr,
    vs.rpt_tp,
    (vs.rpt_yr + mod(vs.rpt_yr, (2)::numeric)) AS cycle
   FROM disclosure.nml_sched_c2 sc2,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sc2.link_id = vs.orig_sub_id) AND ((sc2.amndt_ind)::text <> 'D'::text) AND (sc2.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_c2_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_c_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_c_vw AS
 SELECT sc.cmte_id,
    sc.cmte_nm,
    sc.loan_src_l_nm,
    sc.loan_src_f_nm,
    sc.loan_src_m_nm,
    sc.loan_src_prefix,
    sc.loan_src_suffix,
    sc.loan_src_nm,
    sc.loan_src_st1,
    sc.loan_src_st2,
    sc.loan_src_city,
    sc.loan_src_st,
    sc.loan_src_zip,
    sc.entity_tp,
    sc.entity_tp_desc,
    sc.election_tp,
    sc.fec_election_tp_desc,
    sc.fec_election_tp_year,
    sc.election_tp_desc,
    sc.orig_loan_amt,
    sc.pymt_to_dt,
    sc.loan_bal,
    sc.incurred_dt,
    sc.due_dt_terms,
    sc.interest_rate_terms,
    sc.secured_ind,
    sc.sched_a_line_num,
    sc.pers_fund_yes_no,
    sc.memo_cd,
    sc.memo_text,
    sc.fec_cmte_id,
    sc.cand_id,
    sc.cand_nm,
    sc.cand_nm_first,
    sc.cand_nm_last,
    sc.cand_m_nm,
    sc.cand_prefix,
    sc.cand_suffix,
    sc.cand_office,
    sc.cand_office_desc,
    sc.cand_office_st,
    sc.cand_office_state_desc,
    sc.cand_office_district,
    sc.amndt_ind AS action_cd,
    sc.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sc.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sc.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SC'::character varying(8) AS schedule_type,
    sc.form_tp_desc AS schedule_type_desc,
    sc.line_num,
    sc.image_num,
    sc.file_num,
    sc.link_id,
    sc.orig_sub_id,
    sc.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_c sc,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sc.link_id = vs.orig_sub_id) AND ((sc.amndt_ind)::text <> 'D'::text) AND (sc.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_c_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_d_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_d_vw AS
 SELECT sd.cmte_id,
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
    sd.cred_dbtr_zip,
    sd.entity_tp,
    sd.nature_debt_purpose,
    sd.outstg_bal_bop,
    sd.amt_incurred_per,
    sd.pymt_per,
    sd.outstg_bal_cop,
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
    sd.amndt_ind AS action_cd,
    sd.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sd.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sd.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SD'::character varying(8) AS schedule_type,
    sd.form_tp_desc AS schedule_type_desc,
    sd.line_num,
    sd.image_num,
    sd.file_num,
    sd.link_id,
    sd.orig_sub_id,
    sd.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_d sd,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sd.link_id = vs.orig_sub_id) AND ((sd.amndt_ind)::text <> 'D'::text) AND (sd.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_d_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_e_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_e_vw AS
 SELECT se.cmte_id,
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
    se.exp_dt,
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
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((se.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN se.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    'SE'::character varying(8) AS schedule_type,
    se.form_tp_desc AS schedule_type_desc,
    se.line_num,
    se.image_num,
    se.file_num,
    se.link_id,
    se.orig_sub_id,
    se.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_e se,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((se.link_id = vs.orig_sub_id) AND ((se.amndt_ind)::text <> 'D'::text) AND (se.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_e_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_f_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_f_vw AS
 SELECT sf.cmte_id,
    sf.cmte_nm,
    sf.cmte_desg_coord_exp_ind,
    sf.desg_cmte_id,
    sf.desg_cmte_nm,
    sf.subord_cmte_id,
    sf.subord_cmte_nm,
    sf.subord_cmte_st1,
    sf.subord_cmte_st2,
    sf.subord_cmte_city,
    sf.subord_cmte_st,
    sf.subord_cmte_zip,
    sf.entity_tp,
    sf.entity_tp_desc,
    sf.pye_nm,
    sf.payee_l_nm,
    sf.payee_f_nm,
    sf.payee_m_nm,
    sf.payee_prefix,
    sf.payee_suffix,
    sf.pye_st1,
    sf.pye_st2,
    sf.pye_city,
    sf.pye_st,
    sf.pye_zip,
    sf.aggregate_gen_election_exp,
    sf.exp_tp,
    sf.exp_tp_desc,
    sf.exp_purpose_desc,
    sf.exp_dt,
    sf.exp_amt,
    sf.cand_id,
    sf.cand_nm,
    sf.cand_nm_first,
    sf.cand_nm_last,
    sf.cand_m_nm,
    sf.cand_prefix,
    sf.cand_suffix,
    sf.cand_office,
    sf.cand_office_desc,
    sf.cand_office_st,
    sf.cand_office_st_desc,
    sf.cand_office_district,
    sf.conduit_cmte_id,
    sf.conduit_cmte_nm,
    sf.conduit_cmte_st1,
    sf.conduit_cmte_st2,
    sf.conduit_cmte_city,
    sf.conduit_cmte_st,
    sf.conduit_cmte_zip,
    sf.amndt_ind AS action_cd,
    sf.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((sf.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sf.back_ref_sched_nm
            ELSE NULL::character varying
        END AS back_ref_sched_nm,
    sf.memo_cd,
    sf.memo_cd_desc,
    sf.memo_text,
    sf.unlimited_spending_flg,
    sf.unlimited_spending_flg_desc,
    sf.catg_cd,
    sf.catg_cd_desc,
    'SF'::character varying(8) AS schedule_type,
    sf.form_tp_desc AS schedule_type_desc,
    sf.line_num,
    sf.image_num,
    sf.file_num,
    sf.link_id,
    sf.orig_sub_id,
    sf.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_f sf,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sf.link_id = vs.orig_sub_id) AND ((sf.amndt_ind)::text <> 'D'::text) AND (sf.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_f_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h1_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h1_vw AS
 SELECT h1.filer_cmte_id,
    h1.filer_cmte_nm,
    h1.np_fixed_fed_pct,
    h1.hsp_min_fed_pct,
    h1.hsp_est_fed_dir_cand_supp_pct,
    h1.hsp_est_nonfed_cand_supp_pct,
    h1.hsp_actl_fed_dir_cand_supp_amt,
    h1.hsp_actl_nonfed_cand_supp_amt,
    h1.hsp_actl_fed_dir_cand_supp_pct,
    h1.ssf_fed_est_dir_cand_supp_pct,
    h1.ssf_nfed_est_dir_cand_supp_pct,
    h1.ssf_actl_fed_dir_cand_supp_amt,
    h1.ssf_actl_nonfed_cand_supp_amt,
    h1.ssf_actl_fed_dir_cand_supp_pct,
    h1.president_ind,
    h1.us_senate_ind,
    h1.us_congress_ind,
    h1.subttl_fed,
    h1.governor_ind,
    h1.other_st_offices_ind,
    h1.st_senate_ind,
    h1.st_rep_ind,
    h1.local_cand_ind,
    h1.extra_non_fed_point_ind,
    h1.subttl_non_fed,
    h1.ttl_fed_and_nonfed,
    h1.fed_alloctn,
    h1.amndt_ind AS action_cd,
    h1.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h1.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h1.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    h1.st_loc_pres_only,
    h1.st_loc_pres_sen,
    h1.st_loc_sen_only,
    h1.st_loc_nonpres_nonsen,
    h1.flat_min_fed_pct,
    h1.fed_pct,
    h1.non_fed_pct,
    h1.admin_ratio_chk,
    h1.gen_voter_drive_chk,
    h1.pub_comm_ref_pty_chk,
    'H1'::character varying(8) AS schedule_type,
    h1.form_tp_desc AS schedule_type_desc,
    h1.image_num,
    h1.file_num,
    h1.link_id,
    h1.orig_sub_id,
    h1.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h1 h1,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h1.link_id = vs.orig_sub_id) AND ((h1.amndt_ind)::text <> 'D'::text) AND (h1.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h1_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h2_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h2_vw AS
 SELECT h2.filer_cmte_id,
    h2.filer_cmte_nm,
    h2.evt_activity_nm,
    h2.fndsg_acty_flg,
    h2.exempt_acty_flg,
    h2.direct_cand_support_acty_flg,
    h2.ratio_cd,
    h2.ratio_cd_desc,
    h2.fed_pct_amt,
    h2.nonfed_pct_amt,
    h2.amndt_ind AS action_cd,
    h2.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h2.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h2.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'H2'::character varying(8) AS schedule_type,
    h2.form_tp_desc AS schedule_type_desc,
    h2.image_num,
    h2.file_num,
    h2.link_id,
    h2.orig_sub_id,
    h2.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h2 h2,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h2.link_id = vs.orig_sub_id) AND ((h2.amndt_ind)::text <> 'D'::text) AND (h2.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h2_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h3_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h3_vw AS
 SELECT h3.filer_cmte_id,
    h3.filer_cmte_nm,
    h3.acct_nm,
    h3.evt_nm,
    h3.evt_tp,
    h3.event_tp_desc,
    h3.tranf_dt,
    h3.tranf_amt,
    h3.ttl_tranf_amt,
    h3.amndt_ind AS action_cd,
    h3.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h3.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h3.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h3.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h3.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
    'H3'::character varying(8) AS schedule_type,
    h3.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN ((h3.line_num IS NOT NULL) AND (vs.rpt_yr <= (2004)::numeric)) THEN h3.line_num
            WHEN ((h3.line_num IS NULL) AND (vs.rpt_yr <= (2004)::numeric)) THEN '18'::character varying
            WHEN ((h3.line_num IS NOT NULL) AND (vs.rpt_yr >= (2005)::numeric)) THEN h3.line_num
            WHEN ((h3.line_num IS NULL) AND (vs.rpt_yr >= (2005)::numeric)) THEN '18A'::character varying
            ELSE NULL::character varying
        END AS line_num,
    h3.image_num,
    h3.file_num,
    h3.link_id,
    h3.orig_sub_id,
    h3.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h3 h3,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h3.link_id = vs.orig_sub_id) AND ((h3.amndt_ind)::text <> 'D'::text) AND (h3.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h3_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h4_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h4_vw AS
 SELECT h4.filer_cmte_id,
    h4.filer_cmte_nm,
    h4.entity_tp,
    h4.entity_tp_desc,
    h4.pye_nm,
    h4.payee_l_nm,
    h4.payee_f_nm,
    h4.payee_m_nm,
    h4.payee_prefix,
    h4.payee_suffix,
    h4.pye_st1,
    h4.pye_st2,
    h4.pye_city,
    h4.pye_st,
    h4.pye_zip,
    h4.evt_purpose_nm,
    h4.evt_purpose_desc,
    h4.evt_purpose_dt,
    h4.ttl_amt_disb,
    h4.evt_purpose_category_tp,
    h4.evt_purpose_category_tp_desc,
    h4.fed_share,
    h4.nonfed_share,
    h4.admin_voter_drive_acty_ind,
    h4.fndrsg_acty_ind,
    h4.exempt_acty_ind,
    h4.direct_cand_supp_acty_ind,
    h4.evt_amt_ytd,
    h4.add_desc,
    h4.cand_id,
    h4.cand_nm,
    h4.cand_nm_first,
    h4.cand_nm_last,
    h4.cand_office,
    h4.cand_office_desc,
    h4.cand_office_st,
    h4.cand_office_st_desc,
    h4.cand_office_district,
    h4.conduit_cmte_id,
    h4.conduit_cmte_nm,
    h4.conduit_cmte_st1,
    h4.conduit_cmte_st2,
    h4.conduit_cmte_city,
    h4.conduit_cmte_st,
    h4.conduit_cmte_zip,
    h4.admin_acty_ind,
    h4.gen_voter_drive_acty_ind,
    h4.catg_cd,
    h4.catg_cd_desc,
    h4.disb_tp,
    h4.disb_tp_desc,
    h4.pub_comm_ref_pty_chk,
    h4.memo_cd,
    h4.memo_cd_desc,
    h4.memo_text,
    h4.amndt_ind AS action_cd,
    h4.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((h4.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h4.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'H4'::character varying(8) AS schedule_type,
    h4.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN (h4.line_num IS NOT NULL) THEN h4.line_num
            ELSE '21A'::character varying
        END AS line_num,
    h4.image_num,
    h4.file_num,
    h4.link_id,
    h4.orig_sub_id,
    h4.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h4 h4,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h4.link_id = vs.orig_sub_id) AND ((h4.amndt_ind)::text <> 'D'::text) AND (h4.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h4_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h5_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h5_vw AS
 SELECT h5.filer_cmte_id,
    h5.filer_cmte_nm,
    h5.acct_nm,
    h5.tranf_dt,
    h5.ttl_tranf_amt_voter_reg,
    h5.ttl_tranf_voter_id,
    h5.ttl_tranf_gotv,
    h5.ttl_tranf_gen_campgn_actvy,
    h5.ttl_tranf_amt,
    h5.amndt_ind AS action_cd,
    h5.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h5.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h5.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'H5'::character varying(8) AS schedule_type,
    h5.form_tp_desc AS schedule_type_desc,
        CASE
            WHEN (h5.line_num IS NOT NULL) THEN h5.line_num
            ELSE '18B'::character varying
        END AS line_num,
    h5.image_num,
    h5.file_num,
    h5.link_id,
    h5.orig_sub_id,
    h5.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h5 h5,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h5.link_id = vs.orig_sub_id) AND ((h5.amndt_ind)::text <> 'D'::text) AND (h5.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h5_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_h6_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_h6_vw AS
 SELECT h6.filer_cmte_id,
    h6.filer_cmte_nm,
    h6.entity_tp,
    h6.pye_nm,
    h6.payee_l_nm,
    h6.payee_f_nm,
    h6.payee_m_nm,
    h6.payee_prefix,
    h6.payee_suffix,
    h6.pye_st1,
    h6.pye_st2,
    h6.pye_city,
    h6.pye_st,
    h6.pye_st_desc,
    h6.pye_zip,
    h6.catg_cd,
    h6.catg_cd_desc,
    h6.disb_purpose,
    h6.disb_purpose_cat,
    h6.disb_dt,
    h6.ttl_amt_disb,
    h6.fed_share,
    h6.levin_share,
    h6.voter_reg_yn_flg,
    h6.voter_reg_yn_flg_desc,
    h6.voter_id_yn_flg,
    h6.voter_id_yn_flg_desc,
    h6.gotv_yn_flg,
    h6.gotv_yn_flg_desc,
    h6.gen_campgn_yn_flg,
    h6.gen_campgn_yn_flg_desc,
    h6.evt_amt_ytd,
    h6.add_desc,
    h6.fec_committee_id,
    h6.cand_id,
    h6.cand_nm,
    h6.cand_office,
    h6.cand_office_st_desc,
    h6.cand_office_st,
    h6.cand_office_district,
    h6.conduit_cmte_id,
    h6.conduit_cmte_nm,
    h6.conduit_cmte_st1,
    h6.conduit_cmte_st2,
    h6.conduit_cmte_city,
    h6.conduit_cmte_st,
    h6.conduit_cmte_st_desc,
    h6.conduit_cmte_zip,
    h6.memo_cd,
    h6.memo_cd_desc,
    h6.memo_text,
    h6.amndt_ind AS action_cd,
    h6.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.tran_id
            ELSE NULL::character varying
        END AS tran_id,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.back_ref_tran_id
            ELSE NULL::character varying
        END AS back_ref_tran_id,
        CASE
            WHEN ("substring"(((h6.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN h6.back_ref_sched_id
            ELSE NULL::character varying
        END AS back_ref_sched_id,
    'H6'::character varying(8) AS schedule_type,
        CASE
            WHEN (h6.line_num IS NOT NULL) THEN h6.line_num
            ELSE '30A'::character varying
        END AS line_num,
    h6.image_num,
    h6.file_num,
    h6.link_id,
    h6.orig_sub_id,
    h6.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_h6 h6,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((h6.link_id = vs.orig_sub_id) AND ((h6.amndt_ind)::text <> 'D'::text) AND (h6.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_h6_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_i_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_i_vw AS
 SELECT si.filer_cmte_id,
    si.filer_cmte_nm,
    si.acct_num,
    si.acct_nm,
    si.other_acct_num,
    si.cvg_start_dt,
    si.cvg_end_dt,
    si.ttl_receipts_per,
    si.tranf_to_fed_alloctn_per,
    si.tranf_to_st_local_pty_per,
    si.direct_st_local_cand_supp_per,
    si.other_disb_per,
    si.ttl_disb_per,
    si.coh_bop,
    si.receipts_per,
    si.subttl_per,
    si.disb_per,
    si.coh_cop,
    si.ttl_reciepts_ytd,
    si.tranf_to_fed_alloctn_ytd,
    si.tranf_to_st_local_pty_ytd,
    si.direct_st_local_cand_supp_ytd,
    si.other_disb_ytd,
    si.ttl_disb_ytd,
    si.coh_boy,
    si.receipts_ytd,
    si.subttl_ytd,
    si.disb_ytd,
    si.coh_coy,
    si.amndt_ind AS action_cd,
    si.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((si.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN si.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SI'::character varying(8) AS schedule_type,
    si.form_tp_desc AS schedule_type_desc,
    si.begin_image_num,
    si.end_image_num,
    si.file_num,
    si.link_id,
    si.orig_sub_id,
    si.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_i si,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((si.link_id = vs.orig_sub_id) AND ((si.amndt_ind)::text <> 'D'::text) AND (si.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_i_vw OWNER TO fec;

--
-- Name: fec_vsum_sched_l_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW fec_vsum_sched_l_vw AS
 SELECT sl.filer_cmte_id,
    sl.filer_cmte_nm,
    sl.acct_nm,
    sl.other_acct_num,
    sl.cvg_start_dt,
    sl.cvg_end_dt,
    sl.item_receipts_per_pers,
    sl.unitem_receipts_per_pers,
    sl.ttl_receipts_per_pers,
    sl.other_receipts_per,
    sl.ttl_receipts_per,
    sl.voter_reg_amt_per,
    sl.voter_id_amt_per,
    sl.gotv_amt_per,
    sl.generic_campaign_amt_per,
    sl.ttl_disb_sub_per,
    sl.other_disb_per,
    sl.ttl_disb_per,
    sl.coh_bop,
    sl.receipts_per,
    sl.subttl_per,
    sl.disb_per,
    sl.coh_cop,
    sl.item_receipts_ytd_pers,
    sl.unitem_receipts_ytd_pers,
    sl.ttl_reciepts_ytd_pers,
    sl.other_receipts_ytd,
    sl.ttl_receipts_ytd,
    sl.voter_reg_amt_ytd,
    sl.voter_id_amt_ytd,
    sl.gotv_amt_ytd,
    sl.generic_campaign_amt_ytd,
    sl.ttl_disb_ytd_sub,
    sl.other_disb_ytd,
    sl.ttl_disb_ytd,
    sl.coh_boy,
    sl.receipts_ytd,
    sl.subttl_ytd,
    sl.disb_ytd,
    sl.coh_coy,
    sl.amndt_ind AS action_cd,
    sl.amndt_ind_desc AS action_cd_desc,
        CASE
            WHEN ("substring"(((sl.sub_id)::character varying)::text, 1, 1) = '4'::text) THEN sl.tran_id
            ELSE NULL::character varying
        END AS tran_id,
    'SL'::character varying(8) AS schedule_type,
    sl.form_tp_desc AS schedule_type_desc,
    sl.begin_image_num,
    sl.end_image_num,
    sl.file_num,
    sl.link_id,
    sl.orig_sub_id,
    sl.sub_id,
    vs.form_tp_cd AS filing_form,
    vs.rpt_tp,
    vs.rpt_yr,
    (vs.rpt_yr + (vs.rpt_yr % (2)::numeric)) AS election_cycle
   FROM disclosure.nml_sched_l sl,
    disclosure.v_sum_and_det_sum_report vs
  WHERE ((sl.link_id = vs.orig_sub_id) AND ((sl.amndt_ind)::text <> 'D'::text) AND (sl.delete_ind IS NULL));


ALTER TABLE fec_vsum_sched_l_vw OWNER TO fec;

--
-- Name: ofec_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_amendments_mv AS
 WITH RECURSIVE oldest_filing AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id,
            f_rpt_or_form_sub.rpt_yr,
            f_rpt_or_form_sub.rpt_tp,
            f_rpt_or_form_sub.amndt_ind,
            ((f_rpt_or_form_sub.receipt_dt)::text)::date AS receipt_date,
            f_rpt_or_form_sub.file_num,
            f_rpt_or_form_sub.prev_file_num,
            ARRAY[f_rpt_or_form_sub.file_num] AS amendment_chain,
            1 AS depth,
            f_rpt_or_form_sub.file_num AS last
           FROM disclosure.f_rpt_or_form_sub
          WHERE ((f_rpt_or_form_sub.file_num = f_rpt_or_form_sub.prev_file_num) AND (f_rpt_or_form_sub.file_num > (0)::numeric))
        UNION
         SELECT f3.cand_cmte_id,
            f3.rpt_yr,
            f3.rpt_tp,
            f3.amndt_ind,
            ((f3.receipt_dt)::text)::date AS receipt_date,
            f3.file_num,
            f3.prev_file_num,
            ((oldest.amendment_chain || f3.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            disclosure.f_rpt_or_form_sub f3
          WHERE ((f3.prev_file_num = oldest.file_num) AND (f3.file_num <> f3.prev_file_num) AND (f3.file_num > (0)::numeric))
        ), most_recent_filing AS (
         SELECT a.cand_cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_date,
            a.file_num,
            a.prev_file_num,
            a.amendment_chain,
            a.depth,
            a.last
           FROM (oldest_filing a
             LEFT JOIN oldest_filing b ON ((((a.cand_cmte_id)::text = (b.cand_cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cand_cmte_id IS NULL)
        ), electronic_filer_chain AS (
         SELECT old_f.cand_cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_date,
            old_f.file_num,
            old_f.prev_file_num,
            mrf.file_num AS mst_rct_file_num,
            old_f.amendment_chain
           FROM (oldest_filing old_f
             JOIN most_recent_filing mrf ON ((((old_f.cand_cmte_id)::text = (mrf.cand_cmte_id)::text) AND (old_f.last = mrf.last))))
        )
 SELECT row_number() OVER () AS idx,
    electronic_filer_chain.cand_cmte_id,
    electronic_filer_chain.rpt_yr,
    electronic_filer_chain.rpt_tp,
    electronic_filer_chain.amndt_ind,
    electronic_filer_chain.receipt_date,
    electronic_filer_chain.file_num,
    electronic_filer_chain.prev_file_num,
    electronic_filer_chain.mst_rct_file_num,
    electronic_filer_chain.amendment_chain
   FROM electronic_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_amendments_mv OWNER TO fec;

--
-- Name: ofec_cand_cmte_linkage_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_cand_cmte_linkage_mv AS
 SELECT row_number() OVER () AS idx,
    cand_cmte_linkage.linkage_id,
    cand_cmte_linkage.cand_id,
    cand_cmte_linkage.cand_election_yr,
    cand_cmte_linkage.fec_election_yr,
    cand_cmte_linkage.cmte_id,
    cand_cmte_linkage.cmte_tp,
    cand_cmte_linkage.cmte_dsgn,
    cand_cmte_linkage.linkage_type,
    cand_cmte_linkage.user_id_entered,
    cand_cmte_linkage.date_entered,
    cand_cmte_linkage.user_id_changed,
    cand_cmte_linkage.date_changed,
    cand_cmte_linkage.cmte_count_cand_yr,
    cand_cmte_linkage.efile_paper_ind,
    cand_cmte_linkage.pg_date
   FROM disclosure.cand_cmte_linkage
  WHERE ((substr((cand_cmte_linkage.cand_id)::text, 1, 1) = (cand_cmte_linkage.cmte_tp)::text) OR ((cand_cmte_linkage.cmte_tp)::text <> ALL ((ARRAY['P'::character varying, 'S'::character varying, 'H'::character varying])::text[])))
  WITH NO DATA;


ALTER TABLE ofec_cand_cmte_linkage_mv OWNER TO fec;

--
-- Name: unverified_filers_vw; Type: VIEW; Schema: public; Owner: fec
--

CREATE VIEW unverified_filers_vw AS
 SELECT cmte_cand_query.cmte_id,
    cmte_cand_query.filer_tp,
    cmte_cand_query.cand_cmte_tp,
    cmte_cand_query.filed_cmte_tp_desc,
    (disclosure.get_pcmte_nm(cmte_cand_query.cmte_id, (cmte_cand_query.filer_tp)::numeric))::character varying(200) AS cmte_nm,
    disclosure.get_first_receipt_dt(cmte_cand_query.cmte_id, (cmte_cand_query.filer_tp)::numeric) AS first_receipt_dt
   FROM ( SELECT cv.cmte_id,
            1 AS filer_tp,
                CASE
                    WHEN ((cv.cmte_tp)::text = 'H'::text) THEN 'H'::text
                    WHEN ((cv.cmte_tp)::text = 'S'::text) THEN 'S'::text
                    WHEN ((cv.cmte_tp)::text = 'P'::text) THEN 'P'::text
                    ELSE 'O'::text
                END AS cand_cmte_tp,
                CASE
                    WHEN ((cv.cmte_tp)::text = 'H'::text) THEN 'HOUSE'::text
                    WHEN ((cv.cmte_tp)::text = 'S'::text) THEN 'SENATE'::text
                    WHEN ((cv.cmte_tp)::text = 'P'::text) THEN 'PRESIDENTIAL'::text
                    WHEN ((cv.cmte_tp)::text = 'N'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'Q'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'O'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'U'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'V'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'W'::text) THEN 'POLITICAL ACTION COMMITTEE (PAC)'::text
                    WHEN ((cv.cmte_tp)::text = 'X'::text) THEN 'POLITICAL PARTY COMMITTEE'::text
                    WHEN ((cv.cmte_tp)::text = 'Y'::text) THEN 'POLITICAL PARTY COMMITTEE'::text
                    ELSE 'OTHER'::text
                END AS filed_cmte_tp_desc
           FROM disclosure.cmte_valid_fec_yr cv,
            disclosure.unverified_cand_cmte b
          WHERE ((cv.cmte_id)::text = (b.cand_cmte_id)::text)
        UNION
         SELECT cv.cand_id AS cmte_id,
            2 AS filer_tp,
            cv.cand_office AS cand_cmte_tp,
                CASE
                    WHEN ((cv.cand_office)::text = 'H'::text) THEN 'HOUSE'::text
                    WHEN ((cv.cand_office)::text = 'S'::text) THEN 'SENATE'::text
                    WHEN ((cv.cand_office)::text = 'P'::text) THEN 'PRESIDENTIAL'::text
                    ELSE 'OTHER'::text
                END AS filed_cmte_tp_desc
           FROM disclosure.cand_valid_fec_yr cv,
            disclosure.unverified_cand_cmte b
          WHERE ((cv.cand_id)::text = (b.cand_cmte_id)::text)) cmte_cand_query;

ALTER TABLE unverified_filers_vw OWNER TO fec;
