-- run on data access machine to create foreign tables to RDS
-- the `processed_live` schema should let a full data population
-- run without disturbing data currently stored in `processed`.
-- When it is done and satisfactory the `processed` schema can
-- be dropped and `processed_live` renamed to `processed`.

DROP SCHEMA processed_live;
CREATE SCHEMA processed_live;

CREATE FOREIGN TABLE processed_live.cand_status_ici (
    cand_status_ici_sk numeric(10,0) NOT NULL,
    cand_id character varying(9) NOT NULL,
    election_yr numeric(4,0) NOT NULL,
    ici_code character varying(1),
    cand_status character varying(1),
    cand_inactive_flg character varying(1),
    etl_invalid_flg character(1),
    etl_complete_date date,
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'cand_status_ici');




--
-- Name: form_1; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_1 (
    form_1_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    submit_dt date,
    cmte_nm_chg_flg character varying(1),
    cmte_addr_chg_flg character varying(1),
    cmte_tp character varying(1),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cand_pty_affiliation character varying(3),
    cand_pty_tp character varying(3),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    cust_rec_nm character varying(90),
    cust_rec_st1 character varying(34),
    cust_rec_st2 character varying(34),
    cust_rec_city character varying(30),
    cust_rec_st character varying(2),
    cust_rec_zip character varying(9),
    cust_rec_title character varying(20),
    cust_rec_ph_num character varying(10),
    tres_nm character varying(90),
    tres_st1 character varying(34),
    tres_st2 character varying(34),
    tres_city character varying(30),
    tres_st character varying(2),
    tres_zip character varying(9),
    tres_title character varying(20),
    tres_ph_num character varying(10),
    designated_agent_nm character varying(90),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    sec_bank_depository_nm character varying(200),
    sec_bank_depository_st1 character varying(34),
    sec_bank_depository_st2 character varying(34),
    sec_bank_depository_city character varying(30),
    sec_bank_depository_st character varying(2),
    sec_bank_depository_zip character varying(10),
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    cmte_email character varying(90),
    cmte_web_url character varying(90),
    receipt_dt date,
    filing_freq character varying(1),
    cmte_dsgn character varying(1),
    qual_dt date,
    cmte_fax character varying(12),
    efiling_cmte_tp character varying(1),
    rpt_yr numeric(4,0),
    leadership_pac character varying(1),
    affiliated_relationship_cd character varying(3),
    cmte_email_chg_flg character varying(1),
    cmte_url_chg_flg character varying(1),
    lobbyist_registrant_pac character varying(1),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    cand_l_nm character varying(30),
    cand_f_nm character varying(20),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cust_rec_l_nm character varying(30),
    cust_rec_f_nm character varying(20),
    cust_rec_m_nm character varying(20),
    cust_rec_prefix character varying(10),
    cust_rec_suffix character varying(10),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    f3l_filing_freq character varying(1),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_1');




--
-- Name: form_10; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_10 (
    form_10_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    st1 character varying(34),
    st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    prev_exp_agg numeric(14,2),
    exp_ttl_this_rpt numeric(14,2),
    exp_ttl_cycl_to_dt numeric(14,2),
    cand_sign_nm character varying(38),
    sign_dt date,
    begin_image_num character varying(13),
    end_image_num character varying(13),
    form_tp_desc character varying(90),
    cand_office_desc character varying(20),
    cand_office_st_desc character varying(20),
    cmte_st_desc character varying(20),
    image_tp character varying(10),
    last_update_dt date,
    amndt_ind character varying(1),
    receipt_dt date,
    form_6_chk character varying(1),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    rpt_yr numeric(4,0),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_10');




--
-- Name: form_11; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_11 (
    form_11_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    oppos_cand_nm character varying(38),
    oppos_cmte_nm character varying(90),
    oppos_cmte_id character varying(9),
    oppos_cmte_st1 character varying(34),
    oppos_cmte_st2 character varying(34),
    oppos_cmte_city character varying(18),
    oppos_cmte_st character varying(2),
    oppos_cmte_zip character varying(9),
    form_10_recpt_dt date,
    oppos_pers_fund_amt numeric(14,2),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    reg_special_elect_tp character varying(1),
    cand_tres_sign_nm character varying(38),
    cand_tres_sign_dt date,
    begin_image_num character varying(13),
    end_image_num character varying(13),
    amndt_ind character varying(1),
    receipt_dt date,
    rpt_yr numeric(4,0),
    cand_last_name character varying(30),
    cand_first_name character varying(20),
    cand_middle_name character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    oppos_cand_last_name character varying(30),
    oppos_cand_first_name character varying(20),
    oppos_cand_middle_name character varying(20),
    oppos_cand_prefix character varying(10),
    oppos_cand_suffix character varying(10),
    cand_tres_last_name character varying(30),
    cand_tres_first_name character varying(20),
    cand_tres_middle_name character varying(20),
    cand_tres_prefix character varying(10),
    cand_tres_suffix character varying(10),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_11');




--
-- Name: form_12; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_12 (
    form_12_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    cand_nm character varying(38),
    cand_id character varying(9),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    cmte_nm character varying(90),
    st1 character varying(34),
    st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    election_tp character varying(5),
    reg_special_elect_tp character varying(1),
    fec_election_tp_desc character varying(20),
    hse_date_reached_100 date,
    hse_pers_funds_amt numeric(14,2),
    hse_form_11_prev_dt date,
    sen_date_reached_110 date,
    sen_pers_funds_amt numeric(14,2),
    sen_form_11_prev_dt date,
    cand_tres_sign_nm character varying(38),
    cand_tres_sign_dt date,
    begin_image_num character varying(13),
    end_image_num character varying(13),
    amndt_ind character varying(1),
    receipt_dt date,
    rpt_yr numeric(4,0),
    cand_last_name character varying(30),
    cand_first_name character varying(20),
    cand_middle_name character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_tres_last_name character varying(30),
    cand_tres_first_name character varying(20),
    cand_tres_middle_name character varying(20),
    cand_tres_prefix character varying(10),
    cand_tres_suffix character varying(10),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_12');




--
-- Name: form_13; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_13 (
    form_13_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_tp character varying(1),
    rpt_tp character varying(3),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_dons_accepted numeric(14,2),
    ttl_dons_refunded numeric(14,2),
    net_dons numeric(14,2),
    desig_officer_last_nm character varying(30),
    desig_officer_first_nm character varying(20),
    desig_officer_middle_nm character varying(20),
    desig_officer_prefix character varying(10),
    desig_officer_suffix character varying(10),
    desig_officer_nm character varying(38),
    receipt_dt date,
    signature_dt date,
    rpt_yr numeric(4,0),
    original_report_dt date,
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_13');




--
-- Name: form_1m; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_1m (
    form_1m_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_tp character varying(1),
    affiliation_dt date,
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    fst_cand_id character varying(9),
    fst_cand_nm character varying(90),
    fst_cand_office character varying(1),
    fst_cand_office_st character varying(2),
    fst_cand_office_district character varying(2),
    fst_cand_contb_dt date,
    sec_cand_id character varying(9),
    sec_cand_nm character varying(90),
    sec_cand_office character varying(1),
    sec_cand_office_st character varying(2),
    sec_cand_office_district character varying(2),
    sec_cand_contb_dt date,
    trd_cand_id character varying(9),
    trd_cand_nm character varying(90),
    trd_cand_office character varying(1),
    trd_cand_office_st character varying(2),
    trd_cand_office_district character varying(2),
    trd_cand_contb_dt date,
    frth_cand_id character varying(9),
    frth_cand_nm character varying(90),
    frth_cand_office character varying(1),
    frth_cand_office_st character varying(2),
    frth_cand_office_district character varying(2),
    frth_cand_contb_dt date,
    fith_cand_id character varying(9),
    fith_cand_nm character varying(90),
    fith_cand_office character varying(1),
    fith_cand_office_st character varying(2),
    fith_cand_office_district character varying(2),
    fith_cand_contb_dt date,
    fiftyfirst_cand_contbr_dt date,
    orig_registration_dt date,
    qual_dt date,
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_1m');




--
-- Name: form_1s; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_1s (
    form_1s_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    affiliated_cmte_id character varying(9),
    affiliated_cmte_nm character varying(200),
    affiliated_cmte_st1 character varying(34),
    affiliated_cmte_st2 character varying(34),
    affiliated_cmte_city character varying(30),
    affiliated_cmte_st character varying(2),
    affiliated_cmte_zip character varying(9),
    cmte_rltshp character varying(38),
    org_tp character varying(1),
    designated_agent_nm character varying(200),
    designated_agent_st1 character varying(34),
    designated_agent_st2 character varying(34),
    designated_agent_city character varying(30),
    designated_agent_st character varying(2),
    designated_agent_zip character varying(9),
    designated_agent_title character varying(20),
    designated_agent_ph_num character varying(10),
    bank_depository_nm character varying(200),
    bank_depository_st1 character varying(34),
    bank_depository_st2 character varying(34),
    bank_depository_city character varying(30),
    bank_depository_st character varying(2),
    bank_depository_zip character varying(9),
    receipt_dt date,
    joint_cmte_nm character varying(90),
    joint_cmte_id character varying(9),
    affiliated_relationship_cd character varying(3),
    affiliated_cand_id character varying(9),
    affiliated_cand_l_nm character varying(30),
    affiliated_cand_f_nm character varying(20),
    affiliated_cand_m_nm character varying(20),
    affiliated_cand_prefix character varying(10),
    affiliated_cand_suffix character varying(10),
    designated_agent_l_nm character varying(30),
    designated_agent_f_nm character varying(20),
    designated_agent_m_nm character varying(20),
    designated_agent_prefix character varying(10),
    designated_agent_suffix character varying(10),
    image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_1s');




--
-- Name: form_2; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_2 (
    form_2_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_st1 character varying(34),
    cand_st2 character varying(34),
    cand_city character varying(30),
    cand_st character varying(2),
    cand_zip character varying(9),
    addr_chg_flg character varying(1),
    cand_pty_affiliation character varying(3),
    cand_pty_affiliation_2 character varying(3),
    cand_pty_affiliation_3 character varying(3),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    election_yr numeric(4,0),
    pcc_cmte_id character varying(9),
    pcc_cmte_nm character varying(200),
    pcc_cmte_st1 character varying(34),
    pcc_cmte_st2 character varying(34),
    pcc_cmte_city character varying(30),
    pcc_cmte_st character varying(2),
    pcc_cmte_zip character varying(9),
    addl_auth_cmte_id character varying(9),
    addl_auth_cmte_nm character varying(200),
    addl_auth_cmte_st1 character varying(34),
    addl_auth_cmte_st2 character varying(34),
    addl_auth_cmte_city character varying(18),
    addl_auth_cmte_st character varying(2),
    addl_auth_cmte_zip character varying(9),
    cand_sign_nm character varying(90),
    cand_sign_dt date,
    receipt_dt date,
    party_cd character varying(1),
    cand_ici character varying(1),
    cand_status character varying(1),
    prim_pers_funds_decl numeric(14,2),
    gen_pers_funds_decl numeric(14,2),
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_2');




--
-- Name: form_24; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_24 (
    form_24_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    receipt_dt date,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_24');




--
-- Name: form_2s; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_2s (
    form_2s_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cand_id character varying(9),
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(90),
    auth_cmte_st1 character varying(34),
    auth_cmte_st2 character varying(34),
    auth_cmte_city character varying(18),
    auth_cmte_st character varying(2),
    auth_cmte_zip character varying(9),
    receipt_dt date,
    amndt_ind character varying(1),
    begin_image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_2s');




--
-- Name: form_3; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3 (
    form_3_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_district character varying(2),
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_dt date,
    election_st character varying(2),
    primary_election character varying(1),
    general_election character varying(1),
    special_election character varying(1),
    runoff_election character varying(1),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_cop_i numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_column_ttl_per numeric(14,2),
    tranf_from_other_auth_cmte_per numeric(14,2),
    loans_made_by_cand_per numeric(14,2),
    all_other_loans_per numeric(14,2),
    ttl_loans_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per_i numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    loan_repymts_cand_loans_per numeric(14,2),
    loan_repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_col_ttl_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per_i numeric(14,2),
    coh_bop numeric(14,2),
    ttl_receipts_ii numeric(14,2),
    subttl_per numeric(14,2),
    ttl_disb_per_ii numeric(14,2),
    coh_cop_ii numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    ttl_indv_item_contb_ytd numeric(14,2),
    ttl_indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_other_auth_cmte_ytd numeric(14,2),
    loans_made_by_cand_ytd numeric(14,2),
    all_other_loans_ytd numeric(14,2),
    ttl_loans_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    loan_repymts_cand_loans_ytd numeric(14,2),
    loan_repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ref_ttl_contb_col_ttl_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    grs_rcpt_auth_cmte_prim numeric(14,2),
    agr_amt_contrib_pers_fund_prim numeric(14,2),
    grs_rcpt_min_pers_contrib_prim numeric(14,2),
    grs_rcpt_auth_cmte_gen numeric(14,2),
    agr_amt_pers_contrib_gen numeric(14,2),
    grs_rcpt_min_pers_contrib_gen numeric(14,2),
    cand_id character varying(9),
    cand_nm character varying(38),
    f3z1_rpt_tp character varying(3),
    f3z1_rpt_tp_desc character varying(30),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3');




--
-- Name: form_3l; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3l (
    form_3l_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(28),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    cmte_election_st character varying(2),
    cmte_election_district character varying(2),
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_dt date,
    election_st character varying(2),
    semi_an_per_5c_5d character varying(1),
    cvg_start_dt date,
    cvg_end_dt date,
    semi_an_jan_jun_6b character varying(1),
    semi_an_jul_dec_6b character varying(1),
    qtr_mon_bundled_contb numeric(14,2),
    semi_an_bundled_contb numeric(14,2),
    tres_l_nm character varying(30),
    tres_f_nm character varying(20),
    tres_m_nm character varying(20),
    tres_prefix character varying(10),
    tres_suffix character varying(10),
    tres_sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_31');




--
-- Name: form_3p; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3p (
    form_3p_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    addr_chg_flg character varying(1),
    activity_primary character varying(1),
    activity_general character varying(1),
    term_rpt_flag character varying(1),
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    exp_subject_limits numeric(14,2),
    net_contb_sum_page_per numeric(14,2),
    net_op_exp_sum_page_per numeric(14,2),
    fed_funds_per numeric(14,2),
    indv_contb_per numeric(14,2),
    pol_pty_cmte_contb_per numeric(14,2),
    other_pol_cmte_contb_per numeric(14,2),
    cand_contb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    tranf_from_affilated_cmte_per numeric(14,2),
    loans_received_from_cand_per numeric(14,2),
    other_loans_received_per numeric(14,2),
    ttl_loans_received_per numeric(14,2),
    offsets_to_op_exp_per numeric(14,2),
    offsets_to_fndrsg_exp_per numeric(14,2),
    offsets_to_legal_acctg_per numeric(14,2),
    ttl_offsets_to_op_exp_per numeric(14,2),
    other_receipts_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    op_exp_per numeric(14,2),
    tranf_to_other_auth_cmte_per numeric(14,2),
    fndrsg_disb_per numeric(14,2),
    exempt_legal_acctg_disb_per numeric(14,2),
    repymts_loans_made_by_cand_per numeric(14,2),
    repymts_other_loans_per numeric(14,2),
    ttl_loan_repymts_made_per numeric(14,2),
    ref_indv_contb_per numeric(14,2),
    ref_pol_pty_cmte_contb_per numeric(14,2),
    ref_other_pol_cmte_contb_per numeric(14,2),
    ttl_contb_ref_per numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    items_on_hand_liquidated numeric(14,2),
    alabama_per numeric(14,2),
    alaska_per numeric(14,2),
    arizona_per numeric(14,2),
    arkansas_per numeric(14,2),
    california_per numeric(14,2),
    colorado_per numeric(14,2),
    connecticut_per numeric(14,2),
    delaware_per numeric(14,2),
    district_columbia_per numeric(14,2),
    florida_per numeric(14,2),
    georgia_per numeric(14,2),
    hawaii_per numeric(14,2),
    idaho_per numeric(14,2),
    illinois_per numeric(14,2),
    indiana_per numeric(14,2),
    iowa_per numeric(14,2),
    kansas_per numeric(14,2),
    kentucky_per numeric(14,2),
    louisiana_per numeric(14,2),
    maine_per numeric(14,2),
    maryland_per numeric(14,2),
    massachusetts_per numeric(14,2),
    michigan_per numeric(14,2),
    minnesota_per numeric(14,2),
    mississippi_per numeric(14,2),
    missouri_per numeric(14,2),
    montana_per numeric(14,2),
    nebraska_per numeric(14,2),
    nevada_per numeric(14,2),
    new_hampshire_per numeric(14,2),
    new_jersey_per numeric(14,2),
    new_mexico_per numeric(14,2),
    new_york_per numeric(14,2),
    north_carolina_per numeric(14,2),
    north_dakota_per numeric(14,2),
    ohio_per numeric(14,2),
    oklahoma_per numeric(14,2),
    oregon_per numeric(14,2),
    pennsylvania_per numeric(14,2),
    rhode_island_per numeric(14,2),
    south_carolina_per numeric(14,2),
    south_dakota_per numeric(14,2),
    tennessee_per numeric(14,2),
    texas_per numeric(14,2),
    utah_per numeric(14,2),
    vermont_per numeric(14,2),
    virginia_per numeric(14,2),
    washington_per numeric(14,2),
    west_virginia_per numeric(14,2),
    wisconsin_per numeric(14,2),
    wyoming_per numeric(14,2),
    puerto_rico_per numeric(14,2),
    guam_per numeric(14,2),
    virgin_islands_per numeric(14,2),
    ttl_per numeric(14,2),
    fed_funds_ytd numeric(14,2),
    indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd numeric(14,2),
    other_pol_cmte_contb_ytd numeric(14,2),
    cand_contb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    loans_received_from_cand_ytd numeric(14,2),
    other_loans_received_ytd numeric(14,2),
    ttl_loans_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd numeric(14,2),
    offsets_to_fndrsg_exp_ytd numeric(14,2),
    offsets_to_legal_acctg_ytd numeric(14,2),
    ttl_offsets_to_op_exp_ytd numeric(14,2),
    other_receipts_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    op_exp_ytd numeric(14,2),
    tranf_to_other_auth_cmte_ytd numeric(14,2),
    fndrsg_disb_ytd numeric(14,2),
    exempt_legal_acctg_disb_ytd numeric(14,2),
    repymts_loans_made_cand_ytd numeric(14,2),
    repymts_other_loans_ytd numeric(14,2),
    ttl_loan_repymts_made_ytd numeric(14,2),
    ref_indv_contb_ytd numeric(14,2),
    ref_pol_pty_cmte_contb_ytd numeric(14,2),
    ref_other_pol_cmte_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    alabama_ytd numeric(14,2),
    alaska_ytd numeric(14,2),
    arizona_ytd numeric(14,2),
    arkansas_ytd numeric(14,2),
    california_ytd numeric(14,2),
    colorado_ytd numeric(14,2),
    connecticut_ytd numeric(14,2),
    delaware_ytd numeric(14,2),
    district_columbia_ytd numeric(14,2),
    florida_ytd numeric(14,2),
    georgia_ytd numeric(14,2),
    hawaii_ytd numeric(14,2),
    idaho_ytd numeric(14,2),
    illinois_ytd numeric(14,2),
    indiana_ytd numeric(14,2),
    iowa_ytd numeric(14,2),
    kansas_ytd numeric(14,2),
    kentucky_ytd numeric(14,2),
    louisiana_ytd numeric(14,2),
    maine_ytd numeric(14,2),
    maryland_ytd numeric(14,2),
    massachusetts_ytd numeric(14,2),
    michigan_ytd numeric(14,2),
    minnesota_ytd numeric(14,2),
    mississippi_ytd numeric(14,2),
    missouri_ytd numeric(14,2),
    montana_ytd numeric(14,2),
    nebraska_ytd numeric(14,2),
    nevada_ytd numeric(14,2),
    new_hampshire_ytd numeric(14,2),
    new_jersey_ytd numeric(14,2),
    new_mexico_ytd numeric(14,2),
    new_york_ytd numeric(14,2),
    north_carolina_ytd numeric(14,2),
    north_dakota_ytd numeric(14,2),
    ohio_ytd numeric(14,2),
    oklahoma_ytd numeric(14,2),
    oregon_ytd numeric(14,2),
    pennsylvania_ytd numeric(14,2),
    rhode_island_ytd numeric(14,2),
    south_carolina_ytd numeric(14,2),
    south_dakota_ytd numeric(14,2),
    tennessee_ytd numeric(14,2),
    texas_ytd numeric(14,2),
    utah_ytd numeric(14,2),
    vermont_ytd numeric(14,2),
    virginia_ytd numeric(14,2),
    washington_ytd numeric(14,2),
    west_virginia_ytd numeric(14,2),
    wisconsin_ytd numeric(14,2),
    wyoming_ytd numeric(14,2),
    puerto_rico_ytd numeric(14,2),
    guam_ytd numeric(14,2),
    virgin_islands_ytd numeric(14,2),
    ttl_ytd numeric(14,2),
    tres_sign_nm character varying(38),
    tres_sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3p');




--
-- Name: form_3p_line_31s; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3p_line_31s (
    form_3p31s_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    contbr_lender_nm character varying(90),
    contbr_lender_st1 character varying(34),
    contbr_lender_st2 character varying(34),
    contbr_lender_city character varying(18),
    contbr_lender_st character varying(2),
    contbr_lender_zip character varying(9),
    rpt_pgi character varying(5),
    contbr_lender_employer character varying(38),
    contbr_lender_occupation character varying(38),
    contb_dt date,
    fair_mkt_value_of_item numeric(14,2),
    tran_code character varying(3),
    tran_desc character varying(100),
    cand_id character varying(9),
    cand_nm character varying(38),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(90),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(18),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    memo_flag character varying(1),
    memo_text character varying(100),
    amndt_ind character varying(1),
    tran_id character varying(32),
    receipt_dt date,
    image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3p_line_31s');




--
-- Name: form_3ps; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3ps (
    form_3ps_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    alabama numeric(14,2),
    alaska numeric(14,2),
    arizona numeric(14,2),
    arkansas numeric(14,2),
    california numeric(14,2),
    colorado numeric(14,2),
    connecticut numeric(14,2),
    delaware numeric(14,2),
    district_columbia numeric(14,2),
    florida numeric(14,2),
    georgia numeric(14,2),
    hawaii numeric(14,2),
    idaho numeric(14,2),
    illinois numeric(14,2),
    indiana numeric(14,2),
    iowa numeric(14,2),
    kansas numeric(14,2),
    kentucky numeric(14,2),
    louisiana numeric(14,2),
    maine numeric(14,2),
    maryland numeric(14,2),
    massachusetts numeric(14,2),
    michigan numeric(14,2),
    minnesota numeric(14,2),
    mississippi numeric(14,2),
    missouri numeric(14,2),
    montana numeric(14,2),
    nebraska numeric(14,2),
    nevada numeric(14,2),
    new_hampshire numeric(14,2),
    new_jersey numeric(14,2),
    new_mexico numeric(14,2),
    new_york numeric(14,2),
    north_carolina numeric(14,2),
    north_dakota numeric(14,2),
    ohio numeric(14,2),
    oklahoma numeric(14,2),
    oregon numeric(14,2),
    pennsylvania numeric(14,2),
    rhode_island numeric(14,2),
    south_carolina numeric(14,2),
    south_dakota numeric(14,2),
    tennessee numeric(14,2),
    texas numeric(14,2),
    utah numeric(14,2),
    vermont numeric(14,2),
    virginia numeric(14,2),
    washington numeric(14,2),
    west_virginia numeric(14,2),
    wisconsin numeric(14,2),
    wyoming numeric(14,2),
    puerto_rico numeric(14,2),
    guam numeric(14,2),
    virgin_islands numeric(14,2),
    ttl numeric(14,2),
    election_dt date,
    day_after_election_dt date,
    net_contb numeric(14,2),
    net_exp numeric(14,2),
    fed_funds numeric(14,2),
    indv_contb_other_loans numeric(14,2),
    pol_pty_cmte_contb_other_loans numeric(14,2),
    pac_contb_other_loans numeric(14,2),
    cand_contb_other_loans numeric(14,2),
    ttl_contb_other_loans numeric(14,2),
    tranf_from_affiliated_cmte numeric(14,2),
    loans_received_from_cand numeric(14,2),
    other_loans_received numeric(14,2),
    ttl_loans numeric(14,2),
    op_exp numeric(14,2),
    fndrsg_exp numeric(14,2),
    legal_and_acctg_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp2 numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    fndrsg_disb numeric(14,2),
    exempt_legal_and_acctg_disb numeric(14,2),
    loan_repymts_made_by_cand numeric(14,2),
    other_repymts numeric(14,2),
    ttl_loan_repymts_made numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    receipt_dt date,
    image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3ps');




--
-- Name: form_3s; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3s (
    form_3s_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    ttl_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    net_contb numeric(14,2),
    ttl_op_exp numeric(14,2),
    ttl_offsets_to_op_exp numeric(14,2),
    net_op_exp numeric(14,2),
    indv_item_contb numeric(14,2),
    indv_unitem_contb numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb_column_ttl numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    loan_repymts_cand_loans numeric(14,2),
    loan_repymts_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref_col_ttl numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    election_dt date,
    day_after_election_dt date,
    receipt_dt date,
    image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3s');




--
-- Name: form_3x; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3x (
    form_3x_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_addr_chg_flg character varying(1),
    qual_cmte_flg character varying(1),
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    indv_item_contb_per numeric(14,2),
    indv_unitem_contb_per numeric(14,2),
    ttl_indv_contb numeric(14,2),
    pol_pty_cmte_contb_per_i numeric(14,2),
    other_pol_cmte_contb_per_i numeric(14,2),
    ttl_contb_col_ttl_per numeric(14,2),
    tranf_from_affiliated_pty_per numeric(14,2),
    all_loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    offsets_to_op_exp_per_i numeric(14,2),
    fed_cand_contb_ref_per numeric(14,2),
    other_fed_receipts_per numeric(14,2),
    tranf_from_nonfed_acct_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    ttl_fed_receipts_per numeric(14,2),
    shared_fed_op_exp_per numeric(14,2),
    shared_nonfed_op_exp_per numeric(14,2),
    other_fed_op_exp_per numeric(14,2),
    ttl_op_exp_per numeric(14,2),
    tranf_to_affliliated_cmte_per numeric(14,2),
    fed_cand_cmte_contb_per numeric(14,2),
    indt_exp_per numeric(14,2),
    coord_exp_by_pty_cmte_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    loans_made_per numeric(14,2),
    indv_contb_ref_per numeric(14,2),
    pol_pty_cmte_contb_per_ii numeric(14,2),
    other_pol_cmte_contb_per_ii numeric(14,2),
    ttl_contb_ref_per_i numeric(14,2),
    other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    ttl_fed_disb_per numeric(14,2),
    ttl_contb_per numeric(14,2),
    ttl_contb_ref_per_ii numeric(14,2),
    net_contb_per numeric(14,2),
    ttl_fed_op_exp_per numeric(14,2),
    offsets_to_op_exp_per_ii numeric(14,2),
    net_op_exp_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    indv_item_contb_ytd numeric(14,2),
    indv_unitem_contb_ytd numeric(14,2),
    ttl_indv_contb_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_i numeric(14,2),
    other_pol_cmte_contb_ytd_i numeric(14,2),
    ttl_contb_col_ttl_ytd numeric(14,2),
    tranf_from_affiliated_pty_ytd numeric(14,2),
    all_loans_received_ytd numeric(14,2),
    loan_repymts_received_ytd numeric(14,2),
    offsets_to_op_exp_ytd_i numeric(14,2),
    fed_cand_cmte_contb_ytd numeric(14,2),
    other_fed_receipts_ytd numeric(14,2),
    tranf_from_nonfed_acct_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    ttl_fed_receipts_ytd numeric(14,2),
    shared_fed_op_exp_ytd numeric(14,2),
    shared_nonfed_op_exp_ytd numeric(14,2),
    other_fed_op_exp_ytd numeric(14,2),
    ttl_op_exp_ytd numeric(14,2),
    tranf_to_affilitated_cmte_ytd numeric(14,2),
    fed_cand_cmte_contb_ref_ytd numeric(14,2),
    indt_exp_ytd numeric(14,2),
    coord_exp_by_pty_cmte_ytd numeric(14,2),
    loan_repymts_made_ytd numeric(14,2),
    loans_made_ytd numeric(14,2),
    indv_contb_ref_ytd numeric(14,2),
    pol_pty_cmte_contb_ytd_ii numeric(14,2),
    other_pol_cmte_contb_ytd_ii numeric(14,2),
    ttl_contb_ref_ytd_i numeric(14,2),
    other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    ttl_fed_disb_ytd numeric(14,2),
    ttl_contb_ytd numeric(14,2),
    ttl_contb_ref_ytd_ii numeric(14,2),
    net_contb_ytd numeric(14,2),
    ttl_fed_op_exp_ytd numeric(14,2),
    offsets_to_op_exp_ytd_ii numeric(14,2),
    net_op_exp_ytd numeric(14,2),
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    multicand_flg character varying(1),
    receipt_dt date,
    rpt_yr numeric(4,0),
    tranf_from_nonfed_levin_per numeric(14,2),
    ttl_nonfed_tranf_per numeric(14,2),
    shared_fed_actvy_fed_shr_per numeric(14,2),
    shared_fed_actvy_nonfed_per numeric(14,2),
    non_alloc_fed_elect_actvy_per numeric(14,2),
    ttl_fed_elect_actvy_per numeric(14,2),
    tranf_from_nonfed_levin_ytd numeric(14,2),
    ttl_nonfed_tranf_ytd numeric(14,2),
    shared_fed_actvy_fed_shr_ytd numeric(14,2),
    shared_fed_actvy_nonfed_ytd numeric(14,2),
    non_alloc_fed_elect_actvy_ytd numeric(14,2),
    ttl_fed_elect_actvy_ytd numeric(14,2),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3x');




--
-- Name: form_3z; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_3z (
    form_3z_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    pcc_id character varying(9),
    pcc_nm character varying(90),
    cvg_start_dt date,
    cvg_end_dt date,
    auth_cmte_id character varying(9),
    auth_cmte_nm character varying(90),
    indv_contb numeric(14,2),
    pol_pty_contb numeric(14,2),
    other_pol_cmte_contb numeric(14,2),
    cand_contb numeric(14,2),
    ttl_contb numeric(14,2),
    tranf_from_other_auth_cmte numeric(14,2),
    loans_made_by_cand numeric(14,2),
    all_other_loans numeric(14,2),
    ttl_loans numeric(14,2),
    offsets_to_op_exp numeric(14,2),
    other_receipts numeric(14,2),
    ttl_receipts numeric(14,2),
    op_exp numeric(14,2),
    tranf_to_other_auth_cmte numeric(14,2),
    repymts_loans_made_cand numeric(14,2),
    repymts_all_other_loans numeric(14,2),
    ttl_loan_repymts numeric(14,2),
    ref_indv_contb numeric(14,2),
    ref_pol_pty_cmte_contb numeric(14,2),
    ref_other_pol_cmte_contb numeric(14,2),
    ttl_contb_ref numeric(14,2),
    other_disb numeric(14,2),
    ttl_disb numeric(14,2),
    coh_bop numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte numeric(14,2),
    debts_owed_by_cmte numeric(14,2),
    net_contb numeric(14,2),
    net_op_exp numeric(14,2),
    receipt_dt date,
    image_num character varying(13),
    sub_id numeric(19,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_3z');




--
-- Name: form_4; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_4 (
    form_4_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    cmte_tp character varying(1),
    cmte_desc character varying(40),
    rpt_tp character varying(3),
    cvg_start_dt date,
    cvg_end_dt date,
    coh_bop numeric(14,2),
    ttl_receipts_sum_page_per numeric(14,2),
    subttl_sum_page_per numeric(14,2),
    ttl_disb_sum_page_per numeric(14,2),
    coh_cop numeric(14,2),
    debts_owed_to_cmte_per numeric(14,2),
    debts_owed_by_cmte_per numeric(14,2),
    convn_exp_per numeric(14,2),
    ref_reb_ret_convn_exp_per numeric(14,2),
    exp_subject_limits_per numeric(14,2),
    exp_prior_yrs_subject_lim_per numeric(14,2),
    ttl_exp_subject_limits numeric(14,2),
    fed_funds_per numeric(14,2),
    item_convn_exp_contb_per numeric(14,2),
    unitem_convn_exp_contb_per numeric(14,2),
    subttl_convn_exp_contb_per numeric(14,2),
    tranf_from_affiliated_cmte_per numeric(14,2),
    loans_received_per numeric(14,2),
    loan_repymts_received_per numeric(14,2),
    subttl_loan_repymts_per numeric(14,2),
    item_ref_reb_ret_per numeric(14,2),
    unitem_ref_reb_ret_per numeric(14,2),
    subttl_ref_reb_ret_per numeric(14,2),
    item_other_ref_reb_ret_per numeric(14,2),
    unitem_other_ref_reb_ret_per numeric(14,2),
    subttl_other_ref_reb_ret_per numeric(14,2),
    item_other_income_per numeric(14,2),
    unitem_other_income_per numeric(14,2),
    subttl_other_income_per numeric(14,2),
    ttl_receipts_per numeric(14,2),
    item_convn_exp_disb_per numeric(14,2),
    unitem_convn_exp_disb_per numeric(14,2),
    subttl_convn_exp_disb_per numeric(14,2),
    tranf_to_affiliated_cmte_per numeric(14,2),
    loans_made_per numeric(14,2),
    loan_repymts_made_per numeric(14,2),
    subttl_loan_repymts_disb_per numeric(14,2),
    item_other_disb_per numeric(14,2),
    unitem_other_disb_per numeric(14,2),
    subttl_other_disb_per numeric(14,2),
    ttl_disb_per numeric(14,2),
    coh_begin_calendar_yr numeric(14,2),
    calendar_yr numeric(4,0),
    ttl_receipts_sum_page_ytd numeric(14,2),
    subttl_sum_page_ytd numeric(14,2),
    ttl_disb_sum_page_ytd numeric(14,2),
    coh_coy numeric(14,2),
    convn_exp_ytd numeric(14,2),
    ref_reb_ret_convn_exp_ytd numeric(14,2),
    exp_subject_limits_ytd numeric(14,2),
    exp_prior_yrs_subject_lim_ytd numeric(14,2),
    ttl_exp_subject_limits_ytd numeric(14,2),
    fed_funds_ytd numeric(14,2),
    subttl_convn_exp_contb_ytd numeric(14,2),
    tranf_from_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_ytd numeric(14,2),
    subttl_ref_reb_ret_deposit_ytd numeric(14,2),
    subttl_other_ref_reb_ret_ytd numeric(14,2),
    subttl_other_income_ytd numeric(14,2),
    ttl_receipts_ytd numeric(14,2),
    subttl_convn_exp_disb_ytd numeric(14,2),
    tranf_to_affiliated_cmte_ytd numeric(14,2),
    subttl_loan_repymts_disb_ytd numeric(14,2),
    subttl_other_disb_ytd numeric(14,2),
    ttl_disb_ytd numeric(14,2),
    tres_sign_nm character varying(38),
    tres_sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    begin_image_num character varying(11),
    end_image_num character varying(11),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_4');




--
-- Name: form_5; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_5 (
    form_5_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    amndt_ind character varying(1),
    indv_org_id character varying(9),
    indv_org_nm character varying(90),
    indv_org_st1 character varying(34),
    indv_org_st2 character varying(34),
    indv_org_city character varying(18),
    indv_org_st character varying(2),
    indv_org_zip character varying(9),
    addr_chg_flg character varying(1),
    qual_nonprofit_corp_ind character varying(1),
    indv_org_employer character varying(38),
    indv_org_occupation character varying(38),
    rpt_tp character varying(3),
    rpt_pgi character varying(5),
    election_tp character varying(2),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_indt_contb numeric(14,2),
    ttl_indt_exp numeric(14,2),
    filer_nm character varying(38),
    filer_sign_nm character varying(38),
    filer_sign_dt date,
    notary_sign_dt date,
    notary_commission_exprtn_dt date,
    notary_nm character varying(38),
    receipt_dt date,
    rpt_yr numeric(4,0),
    entity_tp character varying(3),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_5');




--
-- Name: form_6; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_6 (
    form_6_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    filer_cmte_id character varying(9),
    filer_cmte_nm character varying(200),
    filer_cmte_st1 character varying(34),
    filer_cmte_st2 character varying(34),
    filer_cmte_city character varying(30),
    filer_cmte_st character varying(2),
    filer_cmte_zip character varying(9),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_office character varying(1),
    cand_office_st character varying(2),
    cand_office_district character varying(2),
    sign_dt date,
    receipt_dt date,
    rpt_yr numeric(4,0),
    signer_last_name character varying(30),
    signer_first_name character varying(20),
    signer_middle_name character varying(20),
    signer_prefix character varying(10),
    signer_suffix character varying(10),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_6');




--
-- Name: form_7; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_7 (
    form_7_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    org_id character varying(9),
    org_nm character varying(90),
    org_st1 character varying(34),
    org_st2 character varying(34),
    org_city character varying(18),
    org_st character varying(2),
    org_zip character varying(9),
    org_tp character varying(1),
    rpt_tp character varying(3),
    election_dt date,
    election_st character varying(2),
    cvg_start_dt date,
    cvg_end_dt date,
    ttl_communication_cost numeric(14,2),
    filer_sign_nm character varying(38),
    filer_sign_dt date,
    filer_title character varying(20),
    receipt_dt date,
    rpt_pgi character varying(1),
    amndt_ind character varying(1),
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_7');




--
-- Name: form_8; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_8 (
    form_8_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(90),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(18),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    coh numeric(14,2),
    calender_yr date,
    ttl_liquidated_assets numeric(14,2),
    ttl_assets numeric(14,2),
    ytd_reciepts numeric(14,2),
    ytd_disb numeric(14,2),
    ttl_amt_debts_owed numeric(14,2),
    ttl_num_cred_owed numeric(8,0),
    ttl_num_cred_part2 numeric(8,0),
    ttl_amt_debts_owed_part2 numeric(14,2),
    ttl_amt_paid_cred numeric(14,2),
    term_flg character varying(1),
    term_dt_desc character varying(15),
    addl_auth_cmte_flg character varying(1),
    add_auth_cmte_desc character varying(300),
    sufficient_amt_to_pay_ttl_flg character varying(1),
    sufficient_amt_to_pay_desc character varying(100),
    prev_debt_settlement_plan_flg character varying(1),
    residual_funds_flg character varying(1),
    residual_funds_desc character varying(100),
    remaining_amt_flg character varying(1),
    remaining_amt_desc character varying(100),
    tres_sign_nm character varying(38),
    tres_sign_dt date,
    receipt_dt date,
    amndt_ind character varying(1),
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_8');




--
-- Name: form_9; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_9 (
    form_9_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    ind_org_corp_nm character varying(90),
    ind_org_corp_st1 character varying(34),
    ind_org_corp_st2 character varying(34),
    ind_org_corp_city character varying(18),
    ind_org_corp_st character varying(2),
    ind_org_corp_zip character varying(9),
    addr_chg_flg character varying(1),
    ind_org_corp_emp character varying(38),
    ind_org_corp_occup character varying(38),
    cvg_start_dt date,
    cvg_end_dt date,
    pub_distrib_dt date,
    qual_nonprofit_flg character varying(18),
    segr_bank_acct_flg character varying(1),
    ind_custod_nm character varying(38),
    ind_custod_st1 character varying(34),
    ind_custod_st2 character varying(34),
    ind_custod_city character varying(18),
    ind_custod_st character varying(2),
    ind_custod_zip character varying(9),
    ind_custod_emp character varying(38),
    ind_custod_occup character varying(38),
    ttl_dons_this_stmt numeric(14,2),
    ttl_disb_this_stmt numeric(14,2),
    filer_sign_nm character varying(38),
    filer_sign_dt date,
    begin_image_num character varying(11),
    end_image_num character varying(11),
    last_update_dt date,
    amndt_ind character varying(1),
    receipt_dt date,
    rpt_tp character varying(3),
    comm_title character varying(40),
    rpt_yr numeric(4,0),
    entity_tp character varying(3),
    filer_cd character varying(3),
    filer_cd_desc character varying(20),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_9');




--
-- Name: form_99_misc; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.form_99_misc (
    form_99_misc_sk numeric(10,0) NOT NULL,
    form_tp character varying(8),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    cmte_st1 character varying(34),
    cmte_st2 character varying(34),
    cmte_city character varying(30),
    cmte_st character varying(2),
    cmte_zip character varying(9),
    tres_sign_nm character varying(90),
    tres_sign_dt date,
    text_field character varying(4000),
    to_from_ind character varying(1),
    receipt_dt date,
    text_cd character varying(3),
    text_cd_desc character varying(40),
    rpt_yr numeric(4,0),
    begin_image_num character varying(13),
    end_image_num character varying(13),
    sub_id numeric(19,0),
    two_yr_period numeric(4,0),
    transaction_id numeric(10,0),
    etl_invalid_flg character(1),
    etl_complete_date date,
    filing_type character(1),
    record_ind character(1),
    mrf_rec character(1),
    load_date date NOT NULL,
    update_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'form_99_misc');




--
-- Name: log_audit_dml; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.log_audit_dml (
    dml_id numeric(8,0) NOT NULL,
    run_id numeric(8,0),
    audit_id numeric(8,0),
    dml_type character varying(12) NOT NULL,
    target_table character varying(32) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    row_count numeric(10,0),
    dml_desc character varying(100),
    cpu_minutes numeric(8,4),
    elapsed_minutes numeric(8,4),
    start_cpu_time numeric NOT NULL,
    start_clock_time numeric NOT NULL
) SERVER rds OPTIONS (schema_name 'processed', table_name 'log_audit_dml');




--
-- Name: log_audit_module; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.log_audit_module (
    audit_id numeric(8,0) NOT NULL,
    run_id numeric(8,0),
    module_name character varying(65) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    input_parameters character varying(500),
    error_message character varying(4000),
    cpu_minutes numeric(8,4),
    elapsed_minutes numeric(8,4),
    start_cpu_time numeric NOT NULL,
    start_clock_time numeric NOT NULL
) SERVER rds OPTIONS (schema_name 'processed', table_name 'log_audit_module');




--
-- Name: log_audit_process; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.log_audit_process (
    run_id numeric(8,0) NOT NULL,
    session_id numeric(22,0) NOT NULL,
    process_name character varying(30),
    interface_name character varying(6) NOT NULL,
    module_name character varying(65) NOT NULL,
    start_time timestamp without time zone NOT NULL,
    input_parameters character varying(500),
    messages character varying(4000),
    cpu_minutes numeric(8,4),
    elapsed_minutes numeric(8,4),
    start_cpu_time numeric NOT NULL,
    start_clock_time numeric NOT NULL
) SERVER rds OPTIONS (schema_name 'processed', table_name 'log_audit_process');




--
-- Name: log_dml_errors; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.log_dml_errors (
    "ora_err_number$" numeric,
    "ora_err_mesg$" character varying(2000),
    "ora_err_rowid$" character varying,
    "ora_err_optyp$" character varying(2),
    "ora_err_tag$" character varying(100),
    seq_no numeric(10,0),
    form_tp character varying(100),
    file_num character varying(100),
    receipt_dt character varying(100),
    begin_image_num character varying(100),
    end_image_num character varying(100),
    image_num character varying(100),
    cmte_id character varying(100),
    auth_cmte_id character varying(100),
    pcc_cmte_id character varying(100),
    pcc_id character varying(100),
    cand_id character varying(100),
    sub_id character varying(100),
    load_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'log_dml_errors');




--
-- Name: ref_cand_ici; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_cand_ici (
    cand_ici_cd character(1) NOT NULL,
    cand_ici_desc character varying(100),
    incumbent_flg character(1),
    open_flg character(1)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_cand_ici');




--
-- Name: ref_cand_status; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_cand_status (
    cand_status_cd character(1) NOT NULL,
    cand_status_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_cand_status');




--
-- Name: ref_cmte_dsgn; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_cmte_dsgn (
    cmte_dsgn character(1) NOT NULL,
    cmte_dsgn_desc character varying(90)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_cmte_dsgn');




--
-- Name: ref_cmte_type; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_cmte_type (
    cmte_tp character(1) NOT NULL,
    cmte_tp_desc character varying(90),
    explanation character varying(1000)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_cmte_type');




--
-- Name: ref_election; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_election (
    election_tp character(1) NOT NULL,
    election_tp_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_election');




--
-- Name: ref_entity_type; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_entity_type (
    entity_tp character varying(3) NOT NULL,
    entity_tp_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_entity_type');




--
-- Name: ref_form_type; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_form_type (
    form_tp character varying(15) NOT NULL,
    form_tp_desc character varying(100),
    form_nm character varying(1000),
    obsolete_flg character(1) DEFAULT 'N'::bpchar,
    obsolete_date date
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_form_type');




--
-- Name: ref_office; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_office (
    office_tp character(1) NOT NULL,
    office_tp_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_office');




--
-- Name: ref_org_type; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_org_type (
    org_tp character(1) NOT NULL,
    org_tp_desc character varying(90)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_org_type');




--
-- Name: ref_party; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_party (
    party_cd character varying(3) NOT NULL,
    party_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_party');




--
-- Name: ref_report_type; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_report_type (
    rpt_tp character varying(3) NOT NULL,
    rpt_tp_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_report_type');




--
-- Name: ref_state; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_state (
    state_cd character varying(2) NOT NULL,
    state_nm character varying(90)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_state');




--
-- Name: ref_transaction_code; Type: TABLE; Schema: processed; Owner: ec2-user; Tablespace:
--

CREATE FOREIGN TABLE processed_live.ref_transaction_code (
    transaction_cd character varying(3) NOT NULL,
    transaction_desc character varying(100)
) SERVER rds OPTIONS (schema_name 'processed', table_name 'ref_transaction_code');



