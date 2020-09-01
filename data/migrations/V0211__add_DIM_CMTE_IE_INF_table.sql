/*
This is for issue #4574

This is part of the effort to identify candidate committees that change to PAC in the middle of a cycle.
Since financial data goes with committees, not the candidate.  
This association is per fec_election_cycle, 
once PCC convert to PAC, this committee does not associate with the candidate anymore for the entire fec_election_cycle.

disclosure.dim_cmte_ie_inf holds the history of the cmte_tp and cmte_dsgn changes.
Everytime a committee changes its cmte_tp/cmte_dsgn, 
a new recorded will be generate in dim_cmte_ie_inf tables. 
*/

-- ------------------------------------------
-- disclosure.dim_cmte_ie_inf
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.dim_cmte_ie_inf
(
 cmte_pk	numeric(19,0)	NOT NULL
 ,cmte_id	varchar(9)	
 ,cmte_nm	varchar(200)	
 ,cmte_st1	varchar(34)	
 ,cmte_st2	varchar(34)	
 ,cmte_city	varchar(30)	
 ,cmte_st	varchar(2)	
 ,cmte_zip	varchar(9)	
 ,filed_cmte_dsgn	varchar(1)	
 ,filed_cmte_tp	varchar(1)	
 ,filed_cmte_tp_desc	varchar(58)	
 ,cmte_subtp_desc	varchar(35)	
 ,filed_cmte_dsgn_desc	varchar(90)	
 ,jntfndrsg_cmte_flg	varchar(1)	
 ,cmte_pty_affiliation	varchar(3)	
 ,cmte_dsgn_desc	varchar(20)	
 ,cmte_pty_affiliation_desc	varchar(50)	
 ,cmte_class_desc	varchar(20)	
 ,cmte_email	varchar(90)	
 ,cmte_tp_desc	varchar(23)	
 ,cmte_url	varchar(90)	
 ,cmte_filing_freq	varchar(1)	
 ,cmte_filing_freq_desc	varchar(27)	
 ,cmte_qual_start_dt	timestamp	
 ,cmte_term_request_dt	timestamp	
 ,cmte_pty_tp	varchar(3)	
 ,cmte_term_dt	timestamp	
 ,cmte_pty_tp_desc	varchar(90)	
 ,mst_rct_rec_flg	varchar(1)	
 ,lst_updt_dt	timestamp	
 ,cmte_tp_start_dt	timestamp	
 ,cmte_tp_end_dt	timestamp	
 ,org_tp	varchar(1)	
 ,org_tp_desc	varchar(90)	
 ,tres_nm	varchar(90)	
 ,create_date	timestamp	
 ,cmte_dsgn_start_date	timestamp	
 ,cmte_dsgn_end_date	timestamp	
 ,latest_filing_yr	numeric(4,0)	
 ,form_tp	varchar(8)	
 ,cmte_tp_dsgn_start_date	timestamp	
 ,cmte_tp_dsgn_end_date	timestamp	
 ,orig_receipt_dt	timestamp	
 ,latest_receipt_dt	timestamp	
 ,connected_org_nm	varchar(200)	
 ,f3l_filing_freq	varchar(1)	
 ,pg_date	timestamp without time zone DEFAULT now()
,CONSTRAINT dim_cmte_ie_inf_pkey PRIMARY KEY (cmte_pk)
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE disclosure.dim_cmte_ie_inf OWNER TO fec;
GRANT ALL ON TABLE disclosure.dim_cmte_ie_inf TO fec;
GRANT SELECT ON TABLE disclosure.dim_cmte_ie_inf TO fec_read;
