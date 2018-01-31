
CREATE OR REPLACE FUNCTION public.get_office_cmte_tp (p_office varchar, p_cmte_tp varchar)
  RETURNS varchar AS
$BODY$
    begin

        return coalesce(p_office, (case when upper(p_cmte_tp) in ('S','H', 'P') then upper(p_cmte_tp) else null end));

    end

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
ALTER FUNCTION public.get_office_cmte_tp(varchar, varchar)
  OWNER TO fec;
  
  


-- This MATERIALIZED VIEW is used to replace public.ofec_filings_mv
--   During update of ofec_filings_mv to address issue #2723, we realized that 15 other MVs are depending on ofec_filings_mv 
--    	and it is difficult to recreate ofec_filings_mv to include the modification needed using the current process
--	thus the new MV ofec_filings_all_mv is created to fix issue #2723 while we investigate a better way to deal with situation like this

-- -- MATERIALIZED VIEWs public.ofec_filings_amendments_all_mv depending on
REFRESH MATERIALIZED VIEW public.ofec_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_house_senate_paper_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_pac_party_paper_amendments_mv;
REFRESH MATERIALIZED VIEW public.ofec_presidential_paper_amendments_mv;

-- MATERIALIZED VIEWs public.ofec_filings_mv directly depending on
REFRESH MATERIALIZED VIEW public.ofec_filings_amendments_all_mv;

REFRESH MATERIALIZED VIEW public.ofec_candidate_history_mv;
REFRESH MATERIALIZED VIEW public.ofec_committee_history_mv;


CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_filings_all_mv AS 
 WITH filings AS (
         SELECT cand.candidate_id,
            cand.name AS candidate_name,
            filing_history.cand_cmte_id AS committee_id,
            com.name AS committee_name,
            filing_history.sub_id,
            filing_history.cvg_start_dt::text::date AS coverage_start_date,
            filing_history.cvg_end_dt::text::date AS coverage_end_date,
            filing_history.receipt_dt::text::date AS receipt_date,
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
            filing_history.prev_file_num AS previous_file_number,
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
            amendments.mst_rct_file_num AS most_recent_file_number,
            is_amended(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp::text) AS is_amended,
            is_most_recent(amendments.mst_rct_file_num::integer, amendments.file_num::integer, filing_history.form_tp::text) AS most_recent,
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
            get_office_cmte_tp(cand.office,cmte_valid_fec_yr.cmte_tp) as office_cmte_tp
           FROM disclosure.f_rpt_or_form_sub filing_history
             LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON filing_history.cand_cmte_id = cmte_valid_fec_yr.cmte_id AND get_cycle(filing_history.rpt_yr)::numeric = cmte_valid_fec_yr.fec_election_yr
             LEFT JOIN ofec_committee_history_mv com ON filing_history.cand_cmte_id::text = com.committee_id::text AND get_cycle(filing_history.rpt_yr)::numeric = com.cycle
             LEFT JOIN ofec_candidate_history_mv cand ON filing_history.cand_cmte_id::text = cand.candidate_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cand.two_year_period
             LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp::text = report.rpt_tp_cd::text
             LEFT JOIN ofec_filings_amendments_all_mv amendments ON filing_history.file_num = amendments.file_num
          WHERE filing_history.rpt_yr >= 1979::numeric AND filing_history.form_tp::text <> 'SL'::text
        ), rfai_filings AS (
         SELECT cand.candidate_id,
            cand.name AS candidate_name,
            filing_history.id AS committee_id,
            com.name AS committee_name,
            filing_history.sub_id,
            filing_history.cvg_start_dt AS coverage_start_date,
            filing_history.cvg_end_dt AS coverage_end_date,
            filing_history.rfai_dt AS receipt_date,
            filing_history.rpt_yr AS election_year,
            'RFAI'::text AS form_type,
            filing_history.rpt_yr AS report_year,
            get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            NULL::character varying(1) AS document_type,
            NULL::text AS document_type_full,
            filing_history.begin_image_num::bigint AS beginning_image_number,
            filing_history.end_image_num AS ending_image_number,
            NULL::integer AS pages,
            NULL::integer AS total_receipts,
            NULL::integer AS total_individual_contributions,
            NULL::integer AS net_donations,
            NULL::integer AS total_disbursements,
            NULL::integer AS total_independent_expenditures,
            NULL::integer AS total_communication_cost,
            NULL::integer AS cash_on_hand_beginning_period,
            NULL::integer AS cash_on_hand_end_period,
            NULL::integer AS debts_owed_by_committee,
            NULL::integer AS debts_owed_to_committee,
            NULL::integer AS house_personal_funds,
            NULL::integer AS senate_personal_funds,
            NULL::integer AS opposition_personal_funds,
            NULL::character varying(38) AS treasurer_name,
            filing_history.file_num AS file_number,
            0 AS previous_file_number,
            report.rpt_tp_desc AS report_type_full,
            NULL::character varying(5) AS primary_general_indicator,
            filing_history.request_tp AS request_type,
            filing_history.amndt_ind AS amendment_indicator,
            filing_history.last_update_dt AS update_date,
            report_pdf_url_or_null(filing_history.begin_image_num::text, filing_history.rpt_yr, com.committee_type::text, 'RFAI'::text) AS pdf_url,
            means_filed(filing_history.begin_image_num::text) AS means_filed,
            report_html_url(means_filed(filing_history.begin_image_num::text), filing_history.id::text, filing_history.file_num::text) AS html_url,
            NULL::text AS fec_url,
            NULL::numeric[] AS amendment_chain,
            NULL::integer AS most_recent_file_number,
            NULL::boolean AS is_amended,
            true AS most_recent,
            0 AS amendement_version,
            cand.state,
            cand.office,
            cand.district,
            cand.party,
            cmte_valid_fec_yr.cmte_tp,
            get_office_cmte_tp(cand.office,cmte_valid_fec_yr.cmte_tp) as office_cmte_tp            
           FROM disclosure.nml_form_rfai filing_history
             LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON filing_history.id = cmte_valid_fec_yr.cmte_id AND get_cycle(filing_history.rpt_yr)::numeric = cmte_valid_fec_yr.fec_election_yr
             LEFT JOIN ofec_committee_history_mv com ON filing_history.id::text = com.committee_id::text AND get_cycle(filing_history.rpt_yr)::numeric = com.cycle
             LEFT JOIN ofec_candidate_history_mv cand ON filing_history.id::text = cand.candidate_id::text AND get_cycle(filing_history.rpt_yr)::numeric = cand.two_year_period
             LEFT JOIN staging.ref_rpt_tp report ON filing_history.rpt_tp::text = report.rpt_tp_cd::text
          WHERE filing_history.rpt_yr >= 1979::numeric AND filing_history.delete_ind IS NULL
        ), combined AS (
         SELECT filings.candidate_id,
            filings.candidate_name,
            filings.committee_id,
            filings.committee_name,
            filings.sub_id,
            filings.coverage_start_date,
            filings.coverage_end_date,
            filings.receipt_date,
            filings.election_year,
            filings.form_type,
            filings.report_year,
            filings.cycle,
            filings.report_type,
            filings.document_type,
            filings.document_type_full,
            filings.beginning_image_number,
            filings.ending_image_number,
            filings.pages,
            filings.total_receipts,
            filings.total_individual_contributions,
            filings.net_donations,
            filings.total_disbursements,
            filings.total_independent_expenditures,
            filings.total_communication_cost,
            filings.cash_on_hand_beginning_period,
            filings.cash_on_hand_end_period,
            filings.debts_owed_by_committee,
            filings.debts_owed_to_committee,
            filings.house_personal_funds,
            filings.senate_personal_funds,
            filings.opposition_personal_funds,
            filings.treasurer_name,
            filings.file_number,
            filings.previous_file_number,
            filings.report_type_full,
            filings.primary_general_indicator,
            filings.request_type,
            filings.amendment_indicator,
            filings.update_date,
            filings.pdf_url,
            filings.means_filed,
            filings.html_url,
            filings.fec_url,
            filings.amendment_chain,
            filings.most_recent_file_number,
            filings.is_amended,
            filings.most_recent,
            filings.amendment_version,
            filings.state,
            filings.office,
            filings.district,
            filings.party,
            filings.cmte_tp,
            filings.office_cmte_tp
           FROM filings
        UNION ALL
         SELECT rfai_filings.candidate_id,
            rfai_filings.candidate_name,
            rfai_filings.committee_id,
            rfai_filings.committee_name,
            rfai_filings.sub_id,
            rfai_filings.coverage_start_date,
            rfai_filings.coverage_end_date,
            rfai_filings.receipt_date,
            rfai_filings.election_year,
            rfai_filings.form_type,
            rfai_filings.report_year,
            rfai_filings.cycle,
            rfai_filings.report_type,
            rfai_filings.document_type,
            rfai_filings.document_type_full,
            rfai_filings.beginning_image_number,
            rfai_filings.ending_image_number,
            rfai_filings.pages,
            rfai_filings.total_receipts,
            rfai_filings.total_individual_contributions,
            rfai_filings.net_donations,
            rfai_filings.total_disbursements,
            rfai_filings.total_independent_expenditures,
            rfai_filings.total_communication_cost,
            rfai_filings.cash_on_hand_beginning_period,
            rfai_filings.cash_on_hand_end_period,
            rfai_filings.debts_owed_by_committee,
            rfai_filings.debts_owed_to_committee,
            rfai_filings.house_personal_funds,
            rfai_filings.senate_personal_funds,
            rfai_filings.opposition_personal_funds,
            rfai_filings.treasurer_name,
            rfai_filings.file_number,
            rfai_filings.previous_file_number,
            rfai_filings.report_type_full,
            rfai_filings.primary_general_indicator,
            rfai_filings.request_type,
            rfai_filings.amendment_indicator,
            rfai_filings.update_date,
            rfai_filings.pdf_url,
            rfai_filings.means_filed,
            rfai_filings.html_url,
            rfai_filings.fec_url,
            rfai_filings.amendment_chain,
            rfai_filings.most_recent_file_number,
            rfai_filings.is_amended,
            rfai_filings.most_recent,
            rfai_filings.amendement_version,
            rfai_filings.state,
            rfai_filings.office,
            rfai_filings.district,
            rfai_filings.party,
            rfai_filings.cmte_tp,
            rfai_filings.office_cmte_tp
           FROM rfai_filings
        )
 SELECT row_number() OVER () AS idx,
    combined.candidate_id,
    combined.candidate_name,
    combined.committee_id,
    combined.committee_name,
    combined.sub_id,
    combined.coverage_start_date,
    combined.coverage_end_date,
    combined.receipt_date,
    combined.election_year,
    combined.form_type,
    combined.report_year,
    combined.cycle,
    combined.report_type,
    combined.document_type,
    combined.document_type_full,
    combined.beginning_image_number,
    combined.ending_image_number,
    combined.pages,
    combined.total_receipts,
    combined.total_individual_contributions,
    combined.net_donations,
    combined.total_disbursements,
    combined.total_independent_expenditures,
    combined.total_communication_cost,
    combined.cash_on_hand_beginning_period,
    combined.cash_on_hand_end_period,
    combined.debts_owed_by_committee,
    combined.debts_owed_to_committee,
    combined.house_personal_funds,
    combined.senate_personal_funds,
    combined.opposition_personal_funds,
    combined.treasurer_name,
    combined.file_number,
    combined.previous_file_number,
    combined.report_type_full,
    combined.primary_general_indicator,
    combined.request_type,
    combined.amendment_indicator,
    combined.update_date,
    combined.pdf_url,
    combined.means_filed,
    combined.html_url,
    combined.fec_url,
    combined.amendment_chain,
    combined.most_recent_file_number,
    combined.is_amended,
    combined.most_recent,
    combined.amendment_version,
    combined.state,
    combined.office,
    combined.district,
    combined.party,
    combined.cmte_tp,
    combined.office_cmte_tp
   FROM combined
WITH DATA;

ALTER TABLE public.ofec_filings_all_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_filings_all_mv TO fec;
GRANT SELECT ON TABLE public.ofec_filings_all_mv TO fec_read;


CREATE INDEX ofec_filings_all_mv_amendment_indicator_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (amendment_indicator COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_beginning_image_number_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (beginning_image_number, idx);


CREATE INDEX ofec_filings_all_mv_candidate_id_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (candidate_id COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_committee_id_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (committee_id COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_coverage_end_date_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (coverage_end_date, idx);


CREATE INDEX ofec_filings_all_mv_coverage_start_date_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (coverage_start_date, idx);


CREATE INDEX ofec_filings_all_mv_cycle_committee_id_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (cycle, committee_id COLLATE pg_catalog."default");


CREATE INDEX ofec_filings_all_mv_cycle_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (cycle, idx);


CREATE INDEX ofec_filings_all_mv_district_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (district COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_form_type_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (form_type COLLATE pg_catalog."default", idx);


CREATE UNIQUE INDEX ofec_filings_all_mv_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (idx);


CREATE INDEX ofec_filings_all_mv_office_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (office COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_party_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (party COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_primary_general_indicator_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (primary_general_indicator COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_receipt_date_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (receipt_date, idx);


CREATE INDEX ofec_filings_all_mv_report_type_full_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (report_type_full COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_report_type_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (report_type COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_report_year_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (report_year, idx);


CREATE INDEX ofec_filings_all_mv_state_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (state COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_filings_all_mv_total_disbursements_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (total_disbursements, idx);


CREATE INDEX ofec_filings_all_mv_total_independent_expenditures_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (total_independent_expenditures, idx);


CREATE INDEX ofec_filings_all_mv_total_receipts_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (total_receipts, idx);


CREATE INDEX ofec_filings_all_mv_office_cmte_tp_idx_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (office_cmte_tp, idx);
