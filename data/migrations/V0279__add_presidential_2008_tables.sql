/*
This is to support issue #5447.
https://github.com/fecgov/openFEC/issues/5447
Add 9 base tables for 2008
*/


-- -----------------------------------------------------
-- disclosure.pres_nml_ca_cm_link_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_nml_ca_cm_link_08d
(
 pr_link_id	numeric(12,0)	NOT NULL
 ,cand_id	varchar(9)	
 ,cand_nm	varchar(90)	
 ,election_yr	numeric(4,0)	
 ,cmte_id	varchar(9)	
 ,cmte_nm	varchar(200)	
 ,filed_cmte_tp	varchar(2)	
 ,filed_cmte_dsgn	varchar(1)	
 ,link_tp	numeric(1,0)	
 ,active	varchar(1)	
 ,cand_pty_affiliation	varchar(3)	
 ,pg_date timestamp NULL DEFAULT now()
,CONSTRAINT pres_nml_ca_cm_link_08d_pkey PRIMARY KEY (pr_link_id)
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE disclosure.pres_nml_ca_cm_link_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_nml_ca_cm_link_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_nml_ca_cm_link_08d TO fec_read;


-- -----------------------------------------------------
-- disclosure.pres_ca_cm_sched_a_join_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_ca_cm_sched_a_join_08d
(
 cand_id	varchar(9)	
 ,contbr_st	varchar(2)	
 ,zip_3	varchar(3)	
 ,contb_receipt_amt	numeric(14,2)	
 ,election_yr	numeric(4,0)	
 ,pg_date timestamp NULL DEFAULT now()
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.pres_ca_cm_sched_a_join_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_ca_cm_sched_a_join_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_ca_cm_sched_a_join_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_ca_cm_sched_state_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_ca_cm_sched_state_08d
(
 cand_id	varchar(9)	
 ,contbr_st	varchar(2)	
 ,cand_pty_affiliation	varchar(3)	
 ,cand_nm	varchar(90)	
 ,net_receipts_state	numeric	
 ,pg_date timestamp NULL DEFAULT now()
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE disclosure.pres_ca_cm_sched_state_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_ca_cm_sched_state_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_ca_cm_sched_state_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_ca_cm_sched_link_sum_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_ca_cm_sched_link_sum_08d
(
 contb_range_id	numeric(2,0)	
 ,cand_id	varchar(9)	
 ,contb_receipt_amt	numeric(14,2)	
 ,pg_date timestamp NULL DEFAULT now()
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.pres_ca_cm_sched_link_sum_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_ca_cm_sched_link_sum_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_ca_cm_sched_link_sum_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_nml_sched_a_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_nml_sched_a_08d
(
 file_num	numeric(7,0)	
 ,cmte_id	varchar(9)	
 ,cand_id	varchar(9)	
 ,cand_nm	varchar(90)	
 ,contbr_nm	varchar(200)	
 ,contb_receipt_amt	numeric(14,2)	
 ,contb_receipt_dt	timestamp	
 ,contbr_city	varchar(30)	
 ,contbr_st	varchar(2)	
 ,contbr_zip	varchar(9)	
 ,contbr_employer	varchar(38)	
 ,contbr_occupation	varchar(38)	
 ,memo_cd	varchar(1)	
 ,memo_text	varchar(100)	
 ,tran_id	varchar(32)	
 ,back_ref_tran_id	varchar(32)	
 ,zip_3	varchar(3)	
 ,contbr_nm_last	varchar(30)	
 ,contbr_nm_first	varchar(20)	
 ,contbr_nm_middle	varchar(20)	
 ,contbr_nm_prefix	varchar(10)	
 ,contbr_nm_suffix	varchar(10)	
 ,form_tp	varchar(8)	
 ,load_status	numeric(1,0)	
 ,contbr_org_nm	varchar(200)	
 ,record_id	numeric(16,0)	NOT NULL
 ,receipt_desc	varchar(100)	
 ,load_dt	timestamp	
 ,rpt_yr	numeric(4,0)	
 ,election_yr	numeric(4,0)	
 ,election_tp	varchar(5)	
 ,pg_date timestamp NULL DEFAULT now()
,CONSTRAINT pres_nml_sched_a_08d_pkey PRIMARY KEY (record_id)
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE disclosure.pres_nml_sched_a_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_nml_sched_a_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_nml_sched_a_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_nml_sched_b_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_nml_sched_b_08d
(
 file_num	numeric(7,0)	
 ,cmte_id	varchar(9)	
 ,cand_id	varchar(9)	
 ,cand_nm	varchar(90)	
 ,recipient_nm	varchar(200)	
 ,disb_amt	numeric(14,2)	
 ,disb_dt	timestamp	
 ,recipient_city	varchar(30)	
 ,recipient_st	varchar(2)	
 ,recipient_zip	varchar(9)	
 ,disb_desc	varchar(40)	
 ,memo_cd	varchar(1)	
 ,memo_text	varchar(100)	
 ,tran_id	varchar(32)	
 ,back_ref_tran_id	varchar(32)	
 ,form_tp	varchar(8)	
 ,record_id	numeric(16,0)	NOT NULL
 ,cmte_nm	varchar(200)	
 ,load_status	numeric(1,0)	
 ,load_dt	timestamp	
 ,rpt_yr	numeric(4,0)	
 ,election_yr	numeric(4,0)	
 ,payee_l_nm	varchar(30)	
 ,payee_f_nm	varchar(20)	
 ,payee_m_nm	varchar(20)	
 ,payee_prefix	varchar(10)	
 ,payee_suffix	varchar(10)	
 ,election_tp	varchar(5)	
 ,pg_date timestamp NULL DEFAULT now()
 ,CONSTRAINT pres_nml_sched_b_08d_pkey PRIMARY KEY (record_id)
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.pres_nml_sched_b_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_nml_sched_b_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_nml_sched_b_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_f3p_totals_ca_cm_link_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_f3p_totals_ca_cm_link_08d
(
 pr_link_id	numeric(12,0)	NOT NULL
 ,cmte_id	varchar(9)	
 ,cmte_nm	varchar(200)	
 ,filed_cmte_tp	varchar(2)	
 ,filed_cmte_dsgn	varchar(1)	
 ,link_tp	numeric(1,0)	
 ,active	varchar(1)	
 ,cand_pty_affiliation	varchar(3)	
 ,cand_id	varchar(9)	
 ,cand_nm	varchar(90)	
 ,election_yr	numeric(4,0)	
 ,ttl_contb_per	numeric(14,2)	
 ,indv_contb_per	numeric	
 ,pol_pty_cmte_contb_per	numeric	
 ,other_pol_cmte_contb_per	numeric	
 ,cand_contb_per	numeric	
 ,ref_indv_contb_per	numeric(14,2)	
 ,ref_pol_pty_cmte_contb_per	numeric(14,2)	
 ,ref_other_pol_cmte_contb_per	numeric(14,2)	
 ,tranf_from_affilated_cmte_per	numeric(14,2)	
 ,loans_received_from_cand_per	numeric(14,2)	
 ,other_loans_received_per	numeric(14,2)	
 ,repymts_loans_made_by_cand_per	numeric(14,2)	
 ,repymts_other_loans_per	numeric(14,2)	
 ,op_exp_per	numeric(14,2)	
 ,offsets_to_op_exp_per	numeric(14,2)	
 ,other_receipts_per	numeric(14,2)	
 ,debts_owed_by_cmte	numeric(14,2)	
 ,coh_cop	numeric	
 ,load_dt	timestamp	
 ,fndrsg_disb_per	numeric(14,2)	
 ,offsets_to_fndrsg_exp_per	numeric(14,2)	
 ,exempt_legal_acctg_disb_per	numeric(14,2)	
 ,offsets_to_legal_acctg_per	numeric(14,2)	
 ,other_disb_per	numeric(14,2)	
 ,mst_rct_rpt_yr	numeric(4,0)	
 ,mst_rct_rpt_tp	varchar(3)	
 ,coh_bop	numeric(14,2)	
 ,ttl_receipts_sum_page_per	numeric(14,2)	
 ,subttl_sum_page_per	numeric(14,2)	
 ,ttl_disb_sum_page_per	numeric(14,2)	
 ,debts_owed_to_cmte	numeric(14,2)	
 ,exp_subject_limits	numeric(14,2)	
 ,net_contb_sum_page_per	numeric(14,2)	
 ,net_op_exp_sum_page_per	numeric(14,2)	
 ,fed_funds_per	numeric(14,2)	
 ,ttl_loans_received_per	numeric(14,2)	
 ,ttl_offsets_to_op_exp_per	numeric(14,2)	
 ,ttl_receipts_per	numeric(14,2)	
 ,tranf_to_other_auth_cmte_per	numeric(14,2)	
 ,ttl_loan_repymts_made_per	numeric(14,2)	
 ,ttl_contb_ref_per	numeric(14,2)	
 ,ttl_disb_per	numeric(14,2)	
 ,items_on_hand_liquidated	numeric(14,2)	
 ,ttl_per	numeric(14,2)	
 ,indv_item_contb_per	numeric(14,2)	
 ,indv_unitem_contb_per	numeric(14,2)	
 ,pg_date timestamp NULL DEFAULT now()
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.pres_f3p_totals_ca_cm_link_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_f3p_totals_ca_cm_link_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_f3p_totals_ca_cm_link_08d TO fec_read;


-- -----------------------------------------------------
-- disclosure.pres_nml_f3p_totals_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_nml_f3p_totals_08d
(
 cand_id	varchar(9)	NOT NULL
 ,cand_nm	varchar(90)	
 ,election_yr	numeric(4,0)	NOT NULL
 ,ttl_contb_per	numeric(14,2)	
 ,indv_contb_per	numeric	
 ,pol_pty_cmte_contb_per	numeric	
 ,other_pol_cmte_contb_per	numeric	
 ,cand_contb_per	numeric	
 ,ref_indv_contb_per	numeric(14,2)	
 ,ref_pol_pty_cmte_contb_per	numeric(14,2)	
 ,ref_other_pol_cmte_contb_per	numeric(14,2)	
 ,tranf_from_affilated_cmte_per	numeric(14,2)	
 ,loans_received_from_cand_per	numeric(14,2)	
 ,other_loans_received_per	numeric(14,2)	
 ,repymts_loans_made_by_cand_per	numeric(14,2)	
 ,repymts_other_loans_per	numeric(14,2)	
 ,op_exp_per	numeric(14,2)	
 ,offsets_to_op_exp_per	numeric(14,2)	
 ,other_receipts_per	numeric(14,2)	
 ,debts_owed_by_cmte	numeric(14,2)	
 ,coh_cop	numeric	
 ,load_dt	timestamp	
 ,fndrsg_disb_per	numeric(14,2)	
 ,offsets_to_fndrsg_exp_per	numeric(14,2)	
 ,exempt_legal_acctg_disb_per	numeric(14,2)	
 ,offsets_to_legal_acctg_per	numeric(14,2)	
 ,other_disb_per	numeric(14,2)	
 ,mst_rct_rpt_yr	numeric(4,0)	
 ,mst_rct_rpt_tp	varchar(3)	
 ,coh_bop	numeric(14,2)	
 ,ttl_receipts_sum_page_per	numeric(14,2)	
 ,subttl_sum_page_per	numeric(14,2)	
 ,ttl_disb_sum_page_per	numeric(14,2)	
 ,debts_owed_to_cmte	numeric(14,2)	
 ,exp_subject_limits	numeric(14,2)	
 ,net_contb_sum_page_per	numeric(14,2)	
 ,net_op_exp_sum_page_per	numeric(14,2)	
 ,fed_funds_per	numeric(14,2)	
 ,ttl_loans_received_per	numeric(14,2)	
 ,ttl_offsets_to_op_exp_per	numeric(14,2)	
 ,ttl_receipts_per	numeric(14,2)	
 ,tranf_to_other_auth_cmte_per	numeric(14,2)	
 ,ttl_loan_repymts_made_per	numeric(14,2)	
 ,ttl_contb_ref_per	numeric(14,2)	
 ,ttl_disb_per	numeric(14,2)	
 ,items_on_hand_liquidated	numeric(14,2)	
 ,ttl_per	numeric(14,2)	
 ,indv_item_contb_per	numeric(14,2)	
 ,indv_unitem_contb_per	numeric(14,2)	
 ,pg_date timestamp NULL DEFAULT now()
,CONSTRAINT pres_nml_f3p_totals_08d_pkey PRIMARY KEY (cand_id,election_yr)
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE disclosure.pres_nml_f3p_totals_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_nml_f3p_totals_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_nml_f3p_totals_08d TO fec_read;

-- -----------------------------------------------------
-- disclosure.pres_nml_form_3p_08d
-- -----------------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.pres_nml_form_3p_08d
(
 file_num	numeric(7,0)	
 ,prev_file_num	numeric(7,0)	
 ,cmte_id	varchar(9)	
 ,cand_id	varchar(9)	
 ,cvg_start_dt	timestamp	
 ,cvg_end_dt	timestamp	
 ,rpt_tp	varchar(3)	
 ,rpt_yr	numeric(4,0)	
 ,cmte_nm	varchar(200)	
 ,cand_nm	varchar(90)	
 ,coh_cop	numeric(14,2)	
 ,indv_contb_per	numeric(14,2)	
 ,pol_pty_cmte_contb_per	numeric(14,2)	
 ,other_pol_cmte_contb_per	numeric(14,2)	
 ,cand_contb_per	numeric(14,2)	
 ,ttl_contb_per	numeric(14,2)	
 ,load_dt	timestamp	
 ,debts_owed_by_cmte	numeric(14,2)	
 ,record_id	numeric(16,0)	NOT NULL
 ,ref_indv_contb_per	numeric(14,2)	
 ,ref_pol_pty_cmte_contb_per	numeric(14,2)	
 ,ref_other_pol_cmte_contb_per	numeric(14,2)	
 ,tranf_from_affilated_cmte_per	numeric(14,2)	
 ,loans_received_from_cand_per	numeric(14,2)	
 ,repymts_loans_made_by_cand_per	numeric(14,2)	
 ,other_loans_received_per	numeric(14,2)	
 ,repymts_other_loans_per	numeric(14,2)	
 ,op_exp_per	numeric(14,2)	
 ,offsets_to_op_exp_per	numeric(14,2)	
 ,other_receipts_per	numeric(14,2)	
 ,receipt_dt	timestamp	
 ,load_status	numeric(1,0)	
 ,fndrsg_disb_per	numeric(14,2)	
 ,offsets_to_fndrsg_exp_per	numeric(14,2)	
 ,exempt_legal_acctg_disb_per	numeric(14,2)	
 ,offsets_to_legal_acctg_per	numeric(14,2)	
 ,other_disb_per	numeric(14,2)	
 ,election_yr	numeric(4,0)	
 ,begin_image_num	varchar(18)	
 ,end_image_num	varchar(18)	
 ,amndt_ind	varchar(1)	
 ,cmte_st1	varchar(34)	
 ,cmte_st2	varchar(34)	
 ,cmte_city	varchar(30)	
 ,cmte_st	varchar(2)	
 ,cmte_zip	varchar(9)	
 ,addr_chg_flg	varchar(1)	
 ,activity_primary	varchar(1)	
 ,activity_general	varchar(1)	
 ,term_rpt_flag	varchar(1)	
 ,rpt_pgi	varchar(5)	
 ,election_dt	timestamp	
 ,election_st	varchar(2)	
 ,coh_bop	numeric(14,2)	
 ,ttl_receipts_sum_page_per	numeric(14,2)	
 ,subttl_sum_page_per	numeric(14,2)	
 ,ttl_disb_sum_page_per	numeric(14,2)	
 ,debts_owed_to_cmte	numeric(14,2)	
 ,exp_subject_limits	numeric(14,2)	
 ,net_contb_sum_page_per	numeric(14,2)	
 ,net_op_exp_sum_page_per	numeric(14,2)	
 ,fed_funds_per	numeric(14,2)	
 ,ttl_loans_received_per	numeric(14,2)	
 ,ttl_offsets_to_op_exp_per	numeric(14,2)	
 ,ttl_receipts_per	numeric(14,2)	
 ,tranf_to_other_auth_cmte_per	numeric(14,2)	
 ,ttl_loan_repymts_made_per	numeric(14,2)	
 ,ttl_contb_ref_per	numeric(14,2)	
 ,ttl_disb_per	numeric(14,2)	
 ,items_on_hand_liquidated	numeric(14,2)	
 ,ttl_per	numeric(14,2)	
 ,fed_funds_ytd	numeric(14,2)	
 ,indv_contb_ytd	numeric(14,2)	
 ,pol_pty_cmte_contb_ytd	numeric(14,2)	
 ,other_pol_cmte_contb_ytd	numeric(14,2)	
 ,cand_contb_ytd	numeric(14,2)	
 ,ttl_contb_ytd	numeric(14,2)	
 ,tranf_from_affiliated_cmte_ytd	numeric(14,2)	
 ,loans_received_from_cand_ytd	numeric(14,2)	
 ,other_loans_received_ytd	numeric(14,2)	
 ,ttl_loans_received_ytd	numeric(14,2)	
 ,offsets_to_op_exp_ytd	numeric(14,2)	
 ,offsets_to_fndrsg_exp_ytd	numeric(14,2)	
 ,offsets_to_legal_acctg_ytd	numeric(14,2)	
 ,ttl_offsets_to_op_exp_ytd	numeric(14,2)	
 ,other_receipts_ytd	numeric(14,2)	
 ,ttl_receipts_ytd	numeric(14,2)	
 ,op_exp_ytd	numeric(14,2)	
 ,tranf_to_other_auth_cmte_ytd	numeric(14,2)	
 ,fndrsg_disb_ytd	numeric(14,2)	
 ,exempt_legal_acctg_disb_ytd	numeric(14,2)	
 ,repymts_loans_made_cand_ytd	numeric(14,2)	
 ,repymts_other_loans_ytd	numeric(14,2)	
 ,ttl_loan_repymts_made_ytd	numeric(14,2)	
 ,ref_indv_contb_ytd	numeric(14,2)	
 ,ref_pol_pty_cmte_contb_ytd	numeric(14,2)	
 ,ref_other_pol_cmte_contb_ytd	numeric(14,2)	
 ,ttl_contb_ref_ytd	numeric(14,2)	
 ,other_disb_ytd	numeric(14,2)	
 ,ttl_disb_ytd	numeric(14,2)	
 ,ttl_ytd	numeric(14,2)	
 ,tres_sign_nm	varchar(90)	
 ,tres_sign_dt	timestamp	
 ,indv_item_contb_per	numeric(14,2)	
 ,indv_unitem_contb_per	numeric(14,2)	
 ,indv_item_contb_ytd	numeric(14,2)	
 ,indv_unitem_contb_ytd	numeric(14,2)	
 ,tres_l_nm	varchar(30)	
 ,tres_f_nm	varchar(20)	
 ,tres_m_nm	varchar(20)	
 ,tres_prefix	varchar(10)	
 ,tres_suffix	varchar(10)	
 ,pg_date timestamp NULL DEFAULT now()
 ,CONSTRAINT pres_nml_form_3p_08d_pkey PRIMARY KEY (record_id)
)
WITH (OIDS=FALSE)');
	EXCEPTION 
             WHEN duplicate_table THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.pres_nml_form_3p_08d OWNER TO fec;
GRANT ALL ON TABLE disclosure.pres_nml_form_3p_08d TO fec;
GRANT SELECT ON TABLE disclosure.pres_nml_form_3p_08d TO fec_read;

