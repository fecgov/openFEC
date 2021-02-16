/*
This is migration is for issue #4751 by adding columnss for bank data:
cb.bank_depository_nm,
cb.bank_depository_st1,
cb.bank_depository_st2,
cb.bank_depository_city,
cb.bank_depository_st,
cb.bank_depository_zip,
cb.additional_bank_names array column
*/
-- ----------
-- ofec_filings_all_mv_tmp
-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_all_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_filings_all_mv_tmp 
AS
SELECT row_number() OVER () AS idx,
    CASE
		WHEN upper(substr(filing_history.cand_cmte_id,1,1)) IN ('H','S','P') THEN filing_history.cand_cmte_id
		ELSE NULL
	END AS candidate_id,
	cand.name AS candidate_name,
    filing_history.cand_cmte_id AS committee_id,
    com.name AS committee_name,
    filing_history.sub_id,
    filing_history.cvg_start_dt::text::date::timestamp without time zone AS coverage_start_date,
    filing_history.cvg_end_dt::text::date::timestamp without time zone AS coverage_end_date,
    filing_history.receipt_dt::text::date::timestamp without time zone AS receipt_date,
    filing_history.election_yr AS election_year,
    filing_history.form_tp AS form_type,
    filing_history.rpt_yr AS report_year,
    get_cycle(filing_history.rpt_yr) AS cycle,
    filing_history.rpt_tp AS report_type,
    filing_history.to_from_ind AS document_type,
    expand_document(filing_history.to_from_ind::text) AS document_type_full,
    filing_history.begin_image_num::bigint AS beginning_image_number,
    filing_history.end_image_num AS ending_image_number,
    filing_history.pages,
    filing_history.ttl_receipts AS total_receipts,
    filing_history.ttl_indt_contb AS total_individual_contributions,
    filing_history.net_dons AS net_donations,
    filing_history.ttl_disb AS total_disbursements,
    filing_history.ttl_indt_exp AS total_independent_expenditures,
    filing_history.ttl_communication_cost AS total_communication_cost,
    filing_history.coh_bop AS cash_on_hand_beginning_period,
    filing_history.coh_cop AS cash_on_hand_end_period,
    filing_history.debts_owed_by_cmte AS debts_owed_by_committee,
    filing_history.debts_owed_to_cmte AS debts_owed_to_committee,
    filing_history.hse_pers_funds_amt AS house_personal_funds,
    filing_history.sen_pers_funds_amt AS senate_personal_funds,
    filing_history.oppos_pers_fund_amt AS opposition_personal_funds,
    filing_history.tres_nm AS treasurer_name,
    filing_history.file_num AS file_number,
	CASE
		WHEN upper(filing_history.form_tp::text) IN ('FRQ', 'F99') THEN 0
		ELSE filing_history.prev_file_num
	END AS previous_file_number,
	report.rpt_tp_desc AS report_type_full,
	filing_history.rpt_pgi AS primary_general_indicator,
	filing_history.request_tp AS request_type,
	filing_history.amndt_ind AS amendment_indicator,
	filing_history.lst_updt_dt AS update_date,
	report_pdf_url_or_null(filing_history.begin_image_num::text, filing_history.rpt_yr, com.committee_type::text, filing_history.form_tp::text) AS pdf_url,
	means_filed(filing_history.begin_image_num::text) AS means_filed,
	report_html_url(means_filed(filing_history.begin_image_num::text), filing_history.cand_cmte_id::text, filing_history.file_num::text) AS html_url,
	report_fec_url(filing_history.begin_image_num::text, filing_history.file_num::integer) AS fec_url,
	amendments.amendment_chain,
	CASE
		WHEN upper(filing_history.form_tp::text) IN ('FRQ', 'F99') THEN filing_history.file_num
		WHEN upper(filing_history.form_tp::text) IN ('F1'::text, 'F1M'::text, 'F2'::text) THEN v1.mst_rct_file_num 
		WHEN vs.orig_sub_id IS NOT NULL THEN vs.file_num
		ELSE amendments.mst_rct_file_num
	END AS most_recent_file_number,
	is_amended(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp::text) AS is_amended,
	CASE
		WHEN upper(filing_history.form_tp::text) IN ('FRQ', 'F99') THEN true
		WHEN upper(filing_history.form_tp::text) IN ('F1', 'F1M', 'F2') THEN
	    	CASE 
				WHEN filing_history.file_num = v1.mst_rct_file_num THEN true
				WHEN filing_history.file_num != v1.mst_rct_file_num THEN false
				ELSE NULL
	    	END
		WHEN upper(filing_history.form_tp::text) = 'F5'::text AND filing_history.rpt_tp::text IN ('24'::text, '48'::text) THEN NULL
		WHEN upper(filing_history.form_tp::text) = 'F6'::text THEN NULL
		WHEN upper(filing_history.form_tp::text) = 'F24' THEN 
	    	CASE 
				WHEN filing_history.file_num = amendments.mst_rct_file_num THEN true
				WHEN filing_history.file_num != amendments.mst_rct_file_num THEN false
				ELSE NULL
	    	END
		WHEN vs.orig_sub_id IS NOT NULL THEN true
		WHEN vs.orig_sub_id IS NULL THEN false
		ELSE NULL
	END AS most_recent,
	CASE
		WHEN upper(filing_history.form_tp::text) = 'FRQ'::text THEN 0
		WHEN upper(filing_history.form_tp::text) = 'F99'::text THEN 0
		ELSE array_length(amendments.amendment_chain, 1) - 1
	END AS amendment_version,
	cand.state,
	cand.office,
	cand.district,
	cand.party,
	cmte_valid_fec_yr.cmte_tp,
	get_office_cmte_tp(cand.office, cmte_valid_fec_yr.cmte_tp) AS office_cmte_tp,
	CASE
		WHEN (upper(filing_history.form_tp::text) in ('F3', 'F3X', 'F3P', 'F3L', 'F4', 'F7', 'F13')) or (upper(filing_history.form_tp::text) = 'F5' and upper(filing_history.rpt_tp::text) not in ('24', '48')) THEN 'REPORT'::varchar(10)    
		WHEN (upper(filing_history.form_tp::text) in ('F24', 'F6', 'F9', 'F10', 'F11')) or (upper(filing_history.form_tp::text) = 'F5' and upper(filing_history.rpt_tp::text) in ('24', '48')) THEN 'NOTICE'::varchar(10)    
		WHEN upper(filing_history.form_tp::text) in ('F1','F2') THEN 'STATEMENT'::varchar(10)        
		WHEN upper(filing_history.form_tp::text) in ('F1M', 'F8', 'F99', 'F12', 'FRQ') THEN 'OTHER'::varchar(10)    
	END AS form_category,
	cb.bank_depository_nm,
    cb.bank_depository_st1,
    cb.bank_depository_st2,
    cb.bank_depository_city,
    cb.bank_depository_st,
    cb.bank_depository_zip,
    cb.additional_bank_names
FROM disclosure.f_rpt_or_form_sub filing_history
LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON filing_history.cand_cmte_id::text = cmte_valid_fec_yr.cmte_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cmte_valid_fec_yr.fec_election_yr
LEFT JOIN ofec_committee_history_vw com ON filing_history.cand_cmte_id::text = com.committee_id::text AND get_cycle(filing_history.rpt_yr)::numeric = com.cycle
LEFT JOIN ofec_candidate_history_vw cand ON filing_history.cand_cmte_id::text = cand.candidate_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cand.two_year_period
LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp::text = report.rpt_tp_cd::text
LEFT JOIN ofec_filings_amendments_all_vw amendments ON filing_history.file_num = amendments.file_num
LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON filing_history.sub_id = vs.orig_sub_id
LEFT JOIN ofec_non_financial_amendment_chain_vw v1 ON filing_history.sub_id = v1.sub_id
LEFT JOIN ofec_committee_bank_vw cb ON filing_history.sub_id = cb.sub_id
WHERE filing_history.rpt_yr >= 1979::numeric AND filing_history.form_tp::text <> 'SL'::text AND filing_history.form_tp::text <> 'SI'::text
WITH DATA;



ALTER TABLE public.ofec_filings_all_mv_tmp
    OWNER TO fec;

GRANT ALL ON TABLE public.ofec_filings_all_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_filings_all_mv_tmp TO fec_read;

CREATE UNIQUE INDEX idx_ofec_filings_all_mv_tmp_idx
    ON public.ofec_filings_all_mv_tmp USING btree
    (idx);
CREATE INDEX idx_ofec_filings_all_mv_tmp_amend_ind
    ON public.ofec_filings_all_mv_tmp USING btree
    (amendment_indicator);
CREATE INDEX idx_ofec_filings_all_mv_tmp_beg_img_num
    ON public.ofec_filings_all_mv_tmp USING btree
    (beginning_image_number);
CREATE INDEX idx_ofec_filings_all_mv_tmp_cand_id
    ON public.ofec_filings_all_mv_tmp USING btree
    (candidate_id );
CREATE INDEX idx_ofec_filings_all_mv_tmp_committee_id
    ON public.ofec_filings_all_mv_tmp USING btree
    (committee_id );
CREATE INDEX idx_ofec_filings_all_mv_tmp_cvg_end_dt
    ON public.ofec_filings_all_mv_tmp USING btree
    (coverage_end_date);
CREATE INDEX idx_ofec_filings_all_mv_tmp_cvg_start_dt
    ON public.ofec_filings_all_mv_tmp USING btree
    (coverage_start_date);
CREATE INDEX idx_ofec_filings_all_mv_tmp_cycle
    ON public.ofec_filings_all_mv_tmp USING btree
    (cycle);
CREATE INDEX idx_ofec_filings_all_mv_tmp_cycle_cmte_id
    ON public.ofec_filings_all_mv_tmp USING btree
    (cycle, committee_id );
CREATE INDEX idx_ofec_filings_all_mv_tmp_district
    ON public.ofec_filings_all_mv_tmp USING btree
    (district );
CREATE INDEX idx_ofec_filings_all_mv_tmp_form_type
    ON public.ofec_filings_all_mv_tmp USING btree
    (form_type );
CREATE INDEX idx_ofec_filings_all_mv_tmp_office
    ON public.ofec_filings_all_mv_tmp USING btree
    (office );
CREATE INDEX idx_ofec_filings_all_mv_tmp_office_cmte_tp
    ON public.ofec_filings_all_mv_tmp USING btree
    (office_cmte_tp );
CREATE INDEX idx_ofec_filings_all_mv_tmp_party
    ON public.ofec_filings_all_mv_tmp USING btree
    (party );
CREATE INDEX idx_ofec_filings_all_mv_tmp_pri_gnrl_ind
    ON public.ofec_filings_all_mv_tmp USING btree
    (primary_general_indicator );
CREATE INDEX idx_ofec_filings_all_mv_tmp_receipt_date
    ON public.ofec_filings_all_mv_tmp USING btree
    (receipt_date);
CREATE INDEX idx_ofec_filings_all_mv_tmp_req_tp
    ON public.ofec_filings_all_mv_tmp USING btree
    (request_type );
CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_tp
    ON public.ofec_filings_all_mv_tmp USING btree
    (report_type );
CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_tp_full
    ON public.ofec_filings_all_mv_tmp USING btree
    (report_type_full );
CREATE INDEX idx_ofec_filings_all_mv_tmp_rpt_yr
    ON public.ofec_filings_all_mv_tmp USING btree
    (report_year);
CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_disb
    ON public.ofec_filings_all_mv_tmp USING btree
    (total_disbursements);
CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_indpndnt_exp
    ON public.ofec_filings_all_mv_tmp USING btree
    (total_independent_expenditures);
CREATE INDEX idx_ofec_filings_all_mv_tmp_ttl_rcpt
    ON public.ofec_filings_all_mv_tmp USING btree
    (total_receipts);
CREATE INDEX idx_ofec_filings_all_mv_tmp_state
    ON public.ofec_filings_all_mv_tmp USING btree
    (state );
CREATE INDEX idx_ofec_filings_all_mv_tmp_form_category
    ON public.ofec_filings_all_mv_tmp USING btree
    (form_category);  

-- ------------
-- point the view to the _mv_tmp    
-- ------------
CREATE OR REPLACE VIEW public.ofec_filings_all_vw AS 
SELECT * FROM public.ofec_filings_all_mv_tmp;

ALTER TABLE public.ofec_filings_all_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_filings_all_vw TO fec;
GRANT SELECT ON TABLE public.ofec_filings_all_vw TO fec_read;

-- drop old MV
DROP MATERIALIZED VIEW IF EXISTS public.ofec_filings_all_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW public.ofec_filings_all_mv_tmp RENAME TO ofec_filings_all_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_idx RENAME TO idx_ofec_filings_all_mv_idx;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_amend_ind RENAME TO idx_ofec_filings_all_mv_amend_ind;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_beg_img_num RENAME TO idx_ofec_filings_all_mv_beg_img_num;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_cand_id RENAME TO idx_ofec_filings_all_mv_cand_id;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_committee_id RENAME TO idx_ofec_filings_all_mv_committee_id;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_cvg_end_dt RENAME TO idx_ofec_filings_all_mv_cvg_end_dt;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_cvg_start_dt RENAME TO idx_ofec_filings_all_mv_cvg_start_dt;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_cycle RENAME TO idx_ofec_filings_all_mv_cycle;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_cycle_cmte_id RENAME TO idx_ofec_filings_all_mv_cycle_cmte_id;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_district RENAME TO idx_ofec_filings_all_mv_district;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_form_type RENAME TO idx_ofec_filings_all_mv_form_type;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_office RENAME TO idx_ofec_filings_all_mv_office;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_office_cmte_tp RENAME TO idx_ofec_filings_all_mv_office_cmte_tp;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_party RENAME TO idx_ofec_filings_all_mv_party;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_pri_gnrl_ind RENAME TO idx_ofec_filings_all_mv_pri_gnrl_ind;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_receipt_date RENAME TO idx_ofec_filings_all_mv_receipt_date;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_req_tp RENAME TO idx_ofec_filings_all_mv_req_tp;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_rpt_tp RENAME TO idx_ofec_filings_all_mv_rpt_tp;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_rpt_tp_full RENAME TO idx_ofec_filings_all_mv_rpt_tp_full;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_rpt_yr RENAME TO idx_ofec_filings_all_mv_rpt_yr;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_ttl_disb RENAME TO idx_ofec_filings_all_mv_ttl_disb;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_ttl_indpndnt_exp RENAME TO idx_ofec_filings_all_mv_ttl_indpndnt_exp;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_ttl_rcpt RENAME TO idx_ofec_filings_all_mv_ttl_rcpt;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_state RENAME TO idx_ofec_filings_all_mv_state;
ALTER INDEX IF EXISTS idx_ofec_filings_all_mv_tmp_form_category RENAME TO idx_ofec_filings_all_mv_form_category;
