 CREATE OR REPLACE VIEW ofec_processed_filing_vw AS
 WITH RECURSIVE oldest_filing AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id,
            f_rpt_or_form_sub.rpt_yr,
            f_rpt_or_form_sub.rpt_tp,
            f_rpt_or_form_sub.amndt_ind,
            f_rpt_or_form_sub.receipt_dt::text::date AS receipt_date,
            f_rpt_or_form_sub.file_num,
            f_rpt_or_form_sub.prev_file_num,
            f_rpt_or_form_sub.form_tp AS form,
            ARRAY[f_rpt_or_form_sub.file_num] AS amendment_chain,
            1 AS depth,
            f_rpt_or_form_sub.file_num AS last
           FROM disclosure.f_rpt_or_form_sub
          WHERE f_rpt_or_form_sub.file_num = f_rpt_or_form_sub.prev_file_num AND f_rpt_or_form_sub.file_num > 0::numeric
        UNION
         SELECT filing.cand_cmte_id,
            filing.rpt_yr,
            filing.rpt_tp,
            filing.amndt_ind,
            filing.receipt_dt::text::date AS receipt_date,
            filing.file_num,
            filing.prev_file_num,
            filing.form_tp AS form,
            (oldest.amendment_chain || filing.file_num)::numeric(7,0)[] AS "numeric",
            oldest.depth + 1,
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            disclosure.f_rpt_or_form_sub filing
          WHERE filing.prev_file_num = oldest.file_num
            AND filing.file_num <> filing.prev_file_num AND filing.file_num > 0::numeric
        )
 SELECT row_number() OVER () AS idx,
    oldest_filing.cand_cmte_id,
    oldest_filing.rpt_yr,
    oldest_filing.rpt_tp,
    oldest_filing.amndt_ind,
    oldest_filing.receipt_date,
    oldest_filing.file_num,
    oldest_filing.prev_file_num,
    oldest_filing.form,
    last_value(oldest_filing.file_num) OVER amendment_group_entire::numeric(7,0) AS mst_rct_file_num,
    array_agg(oldest_filing.file_num) OVER amendment_group_up_to_current AS amendment_chain
   FROM oldest_filing
   WINDOW amendment_group_entire AS
        (PARTITION BY oldest_filing.last
            ORDER BY oldest_filing.depth
            RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
   amendment_group_up_to_current AS
        (PARTITION BY oldest_filing.last
            ORDER BY oldest_filing.depth)
;

ALTER VIEW ofec_processed_filing_vw OWNER TO fec;

DROP MATERIALIZED VIEW ofec_amendments_mv CASCADE;

CREATE MATERIALIZED VIEW ofec_amendments_mv AS
SELECT row_number() OVER () AS idx, *
FROM (SELECT
        cand_cmte_id,
        rpt_yr,
        rpt_tp,
        amndt_ind,
        receipt_date,
        file_num,
        prev_file_num,
        form,
        mst_rct_file_num,
        amendment_chain
       FROM ofec_processed_filing_vw
    WHERE form NOT IN ('F1', 'F1M', 'F2')
    UNION ALL
    SELECT
        cand_cmte_id,
        rpt_yr,
        rpt_tp,
        amndt_ind,
        receipt_dt::text::date as receipt_date,
        file_num,
        prev_file_num,
        form_tp as form,
        last_value(file_num) OVER candidate_committee_group_entire AS mst_rct_file_num,
        array_agg(file_num) OVER candidate_committee_group_up_to_current AS amendment_chain
       FROM disclosure.f_rpt_or_form_sub
    WHERE form_tp IN ('F1', 'F1M', 'F2')
       WINDOW candidate_committee_group_entire AS
            (PARTITION BY cand_cmte_id, form_tp
                ORDER BY file_num NULLS FIRST
                RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
       candidate_committee_group_up_to_current AS
            (PARTITION BY cand_cmte_id, form_tp
                ORDER BY file_num NULLS FIRST)
) combined;

ALTER TABLE ofec_amendments_mv OWNER TO fec;

CREATE UNIQUE INDEX ofec_amendments_mv_idx_idx ON ofec_amendments_mv USING btree(idx);

CREATE MATERIALIZED VIEW public.ofec_filings_amendments_all_mv AS
 WITH combined AS (
         SELECT ofec_amendments_mv.idx,
            ofec_amendments_mv.cand_cmte_id,
            ofec_amendments_mv.rpt_yr,
            ofec_amendments_mv.rpt_tp,
            ofec_amendments_mv.amndt_ind,
            ofec_amendments_mv.receipt_date,
            ofec_amendments_mv.file_num,
            ofec_amendments_mv.prev_file_num,
            ofec_amendments_mv.mst_rct_file_num,
            ofec_amendments_mv.amendment_chain
           FROM public.ofec_amendments_mv
        UNION ALL
         SELECT ofec_presidential_paper_amendments_mv.idx,
            ofec_presidential_paper_amendments_mv.cmte_id,
            ofec_presidential_paper_amendments_mv.rpt_yr,
            ofec_presidential_paper_amendments_mv.rpt_tp,
            ofec_presidential_paper_amendments_mv.amndt_ind,
            ofec_presidential_paper_amendments_mv.receipt_dt,
            ofec_presidential_paper_amendments_mv.file_num,
            ofec_presidential_paper_amendments_mv.prev_file_num,
            ofec_presidential_paper_amendments_mv.mst_rct_file_num,
            ofec_presidential_paper_amendments_mv.amendment_chain
           FROM public.ofec_presidential_paper_amendments_mv
        UNION ALL
         SELECT ofec_house_senate_paper_amendments_mv.idx,
            ofec_house_senate_paper_amendments_mv.cmte_id,
            ofec_house_senate_paper_amendments_mv.rpt_yr,
            ofec_house_senate_paper_amendments_mv.rpt_tp,
            ofec_house_senate_paper_amendments_mv.amndt_ind,
            ofec_house_senate_paper_amendments_mv.receipt_dt,
            ofec_house_senate_paper_amendments_mv.file_num,
            ofec_house_senate_paper_amendments_mv.prev_file_num,
            ofec_house_senate_paper_amendments_mv.mst_rct_file_num,
            ofec_house_senate_paper_amendments_mv.amendment_chain
           FROM public.ofec_house_senate_paper_amendments_mv
        UNION ALL
         SELECT ofec_pac_party_paper_amendments_mv.idx,
            ofec_pac_party_paper_amendments_mv.cmte_id,
            ofec_pac_party_paper_amendments_mv.rpt_yr,
            ofec_pac_party_paper_amendments_mv.rpt_tp,
            ofec_pac_party_paper_amendments_mv.amndt_ind,
            ofec_pac_party_paper_amendments_mv.receipt_dt,
            ofec_pac_party_paper_amendments_mv.file_num,
            ofec_pac_party_paper_amendments_mv.prev_file_num,
            ofec_pac_party_paper_amendments_mv.mst_rct_file_num,
            ofec_pac_party_paper_amendments_mv.amendment_chain
           FROM public.ofec_pac_party_paper_amendments_mv
        )
 SELECT row_number() OVER () AS idx2,
    combined.idx,
    combined.cand_cmte_id,
    combined.rpt_yr,
    combined.rpt_tp,
    combined.amndt_ind,
    combined.receipt_date,
    combined.file_num,
    combined.prev_file_num,
    combined.mst_rct_file_num,
    combined.amendment_chain
   FROM combined
  WITH DATA;

ALTER TABLE public.ofec_filings_amendments_all_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_filings_mv AS
 WITH filings AS (
         SELECT cand.candidate_id,
            cand.name AS candidate_name,
            filing_history.cand_cmte_id AS committee_id,
            com.name AS committee_name,
            filing_history.sub_id,
            ((filing_history.cvg_start_dt)::text)::date AS coverage_start_date,
            ((filing_history.cvg_end_dt)::text)::date AS coverage_end_date,
            ((filing_history.receipt_dt)::text)::date AS receipt_date,
            filing_history.election_yr AS election_year,
            filing_history.form_tp AS form_type,
            filing_history.rpt_yr AS report_year,
            public.get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            filing_history.to_from_ind AS document_type,
            public.expand_document((filing_history.to_from_ind)::text) AS document_type_full,
            (filing_history.begin_image_num)::bigint AS beginning_image_number,
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
            public.report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, (filing_history.form_tp)::text) AS pdf_url,
            public.means_filed((filing_history.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((filing_history.begin_image_num)::text), (filing_history.cand_cmte_id)::text, (filing_history.file_num)::text) AS html_url,
            public.report_fec_url((filing_history.begin_image_num)::text, (filing_history.file_num)::integer) AS fec_url,
            amendments.amendment_chain,
            amendments.mst_rct_file_num AS most_recent_file_number,
            public.is_amended((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS is_amended,
            public.is_most_recent((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS most_recent,
                CASE
                    WHEN (upper((filing_history.form_tp)::text) = 'FRQ'::text) THEN 0
                    WHEN (upper((filing_history.form_tp)::text) = 'F99'::text) THEN 0
                    ELSE (array_length(amendments.amendment_chain, 1) - 1)
                END AS amendment_version,
            cand.state,
            cand.office,
            cand.district,
            cand.party
           FROM ((((disclosure.f_rpt_or_form_sub filing_history
             LEFT JOIN public.ofec_committee_history_mv com ON ((((filing_history.cand_cmte_id)::text = (com.committee_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN public.ofec_candidate_history_mv cand ON ((((filing_history.cand_cmte_id)::text = (cand.candidate_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
             LEFT JOIN staging.ref_rpt_tp report ON (((filing_history.rpt_tp)::text = (report.rpt_tp_cd)::text)))
             LEFT JOIN public.ofec_filings_amendments_all_mv amendments ON ((filing_history.file_num = amendments.file_num)))
          WHERE ((filing_history.rpt_yr >= (1979)::numeric) AND ((filing_history.form_tp)::text <> 'SL'::text))
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
            public.get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            NULL::character varying(1) AS document_type,
            NULL::text AS document_type_full,
            (filing_history.begin_image_num)::bigint AS beginning_image_number,
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
            public.report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, 'RFAI'::text) AS pdf_url,
            public.means_filed((filing_history.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((filing_history.begin_image_num)::text), (filing_history.id)::text, (filing_history.file_num)::text) AS html_url,
            NULL::text AS fec_url,
            NULL::numeric[] AS amendment_chain,
            NULL::integer AS most_recent_file_number,
            NULL::boolean AS is_amended,
            true AS most_recent,
            0 AS amendement_version,
            cand.state,
            cand.office,
            cand.district,
            cand.party
           FROM (((disclosure.nml_form_rfai filing_history
             LEFT JOIN public.ofec_committee_history_mv com ON ((((filing_history.id)::text = (com.committee_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN public.ofec_candidate_history_mv cand ON ((((filing_history.id)::text = (cand.candidate_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
             LEFT JOIN staging.ref_rpt_tp report ON (((filing_history.rpt_tp)::text = (report.rpt_tp_cd)::text)))
          WHERE ((filing_history.rpt_yr >= (1979)::numeric) AND (filing_history.delete_ind IS NULL))
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
            filings.party
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
            rfai_filings.party
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
    combined.party
   FROM combined
  WITH DATA;

ALTER TABLE public.ofec_filings_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_combined_mv AS
 WITH last_subset AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.orig_sub_id,
            v_sum_and_det_sum_report.cmte_id,
            v_sum_and_det_sum_report.coh_cop,
            v_sum_and_det_sum_report.debts_owed_by_cmte,
            v_sum_and_det_sum_report.debts_owed_to_cmte,
            v_sum_and_det_sum_report.net_op_exp,
            v_sum_and_det_sum_report.net_contb,
            v_sum_and_det_sum_report.rpt_yr,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision)) DESC NULLS LAST
        ), last AS (
         SELECT ls.cmte_id,
            ls.orig_sub_id,
            ls.coh_cop,
            ls.cycle,
            ls.debts_owed_by_cmte,
            ls.debts_owed_to_cmte,
            ls.net_op_exp,
            ls.net_contb,
            ls.rpt_yr,
            of.candidate_id,
            of.beginning_image_number,
            of.coverage_end_date,
            of.form_type,
            of.report_type_full,
            of.report_type,
            of.candidate_name,
            of.committee_name
           FROM (last_subset ls
             LEFT JOIN public.ofec_filings_mv of ON ((ls.orig_sub_id = of.sub_id)))
        ), first AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.coh_bop AS cash_on_hand,
            v_sum_and_det_sum_report.cmte_id AS committee_id,
                CASE
                    WHEN (v_sum_and_det_sum_report.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum_and_det_sum_report.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            public.get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((public.get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (public.get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision))
        ), committee_info AS (
         SELECT DISTINCT ON (cmte_valid_fec_yr.cmte_id, cmte_valid_fec_yr.fec_election_yr) cmte_valid_fec_yr.cmte_id,
            cmte_valid_fec_yr.fec_election_yr,
            cmte_valid_fec_yr.cmte_nm,
            cmte_valid_fec_yr.cmte_tp,
            cmte_valid_fec_yr.cmte_dsgn,
            cmte_valid_fec_yr.cmte_pty_affiliation_desc
           FROM disclosure.cmte_valid_fec_yr
        )
 SELECT public.get_cycle(vsd.rpt_yr) AS cycle,
    max((last.candidate_id)::text) AS candidate_id,
    max((last.candidate_name)::text) AS candidate_name,
    max((last.committee_name)::text) AS committee_name,
    max(last.beginning_image_number) AS last_beginning_image_number,
    max(last.coh_cop) AS last_cash_on_hand_end_period,
    max(last.debts_owed_by_cmte) AS last_debts_owed_by_committee,
    max(last.debts_owed_to_cmte) AS last_debts_owed_to_committee,
    max(last.net_contb) AS last_net_contributions,
    max(last.net_op_exp) AS last_net_operating_expenditures,
    max((last.report_type)::text) AS last_report_type,
    max((last.report_type_full)::text) AS last_report_type_full,
    max(last.rpt_yr) AS last_report_year,
    max(last.coverage_end_date) AS coverage_end_date,
    max(vsd.orig_sub_id) AS sub_id,
    min(first.cash_on_hand) AS cash_on_hand_beginning_period,
    min(first.coverage_start_date) AS coverage_start_date,
    sum(vsd.all_loans_received_per) AS all_loans_received,
    sum(vsd.cand_cntb) AS candidate_contribution,
    sum((vsd.cand_loan_repymnt + vsd.oth_loan_repymts)) AS loan_repayments_made,
    sum(vsd.cand_loan_repymnt) AS loan_repayments_candidate_loans,
    sum(vsd.cand_loan) AS loans_made_by_candidate,
    sum(vsd.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
    sum(vsd.cand_loan) AS loans_received_from_candidate,
    sum(vsd.coord_exp_by_pty_cmte_per) AS coordinated_expenditures_by_party_committee,
    sum(vsd.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
    sum(vsd.fed_cand_cmte_contb_per) AS fed_candidate_committee_contributions,
    sum(vsd.fed_cand_contb_ref_per) AS fed_candidate_contribution_refunds,
    (sum(vsd.fed_funds_per) > (0)::numeric) AS federal_funds_flag,
    sum(vsd.fed_funds_per) AS fed_disbursements,
    sum(vsd.fed_funds_per) AS federal_funds,
    sum(vsd.fndrsg_disb) AS fundraising_disbursements,
    sum(vsd.indv_contb) AS individual_contributions,
    sum(vsd.indv_item_contb) AS individual_itemized_contributions,
    sum(vsd.indv_ref) AS refunded_individual_contributions,
    sum(vsd.indv_unitem_contb) AS individual_unitemized_contributions,
    sum(vsd.loan_repymts_received_per) AS loan_repayments_received,
    sum(vsd.loans_made_per) AS loans_made,
    sum(vsd.net_contb) AS net_contributions,
    sum(vsd.net_op_exp) AS net_operating_expenditures,
    sum(vsd.non_alloc_fed_elect_actvy_per) AS non_allocated_fed_election_activity,
    sum(vsd.offsets_to_fndrsg) AS offsets_to_fundraising_expenditures,
    sum(vsd.offsets_to_legal_acctg) AS offsets_to_legal_accounting,
    sum(((vsd.offsets_to_op_exp + vsd.offsets_to_fndrsg) + vsd.offsets_to_legal_acctg)) AS total_offsets_to_operating_expenditures,
    sum(vsd.offsets_to_op_exp) AS offsets_to_operating_expenditures,
    sum(vsd.op_exp_per) AS operating_expenditures,
    sum(vsd.oth_cmte_contb) AS other_political_committee_contributions,
    sum(vsd.oth_cmte_ref) AS refunded_other_political_committee_contributions,
    sum(vsd.oth_loan_repymts) AS loan_repayments_other_loans,
    sum(vsd.oth_loan_repymts) AS repayments_other_loans,
    sum(vsd.oth_loans) AS all_other_loans,
    sum(vsd.oth_loans) AS other_loans_received,
    sum(vsd.other_disb_per) AS other_disbursements,
    sum(vsd.other_fed_op_exp_per) AS other_fed_operating_expenditures,
    sum(vsd.other_receipts) AS other_fed_receipts,
    sum(vsd.other_receipts) AS other_receipts,
    sum(vsd.pol_pty_cmte_contb) AS refunded_political_party_committee_contributions,
    sum(vsd.pty_cmte_contb) AS political_party_committee_contributions,
    sum(vsd.shared_fed_actvy_fed_shr_per) AS shared_fed_activity,
    sum(vsd.shared_fed_actvy_nonfed_per) AS allocated_federal_election_levin_share,
    sum(vsd.shared_fed_actvy_nonfed_per) AS shared_fed_activity_nonfed,
    sum(vsd.shared_fed_op_exp_per) AS shared_fed_operating_expenditures,
    sum(vsd.shared_nonfed_op_exp_per) AS shared_nonfed_operating_expenditures,
    sum(vsd.tranf_from_nonfed_acct_per) AS transfers_from_nonfed_account,
    sum(vsd.tranf_from_nonfed_levin_per) AS transfers_from_nonfed_levin,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_committee,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_affiliated_party,
    sum(vsd.tranf_from_other_auth_cmte) AS transfers_from_other_authorized_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_affiliated_committee,
    sum(vsd.tranf_to_other_auth_cmte) AS transfers_to_other_authorized_committee,
    sum(vsd.ttl_contb_ref) AS contribution_refunds,
    sum(vsd.ttl_contb) AS contributions,
    sum(vsd.ttl_disb) AS disbursements,
    sum(vsd.ttl_fed_elect_actvy_per) AS fed_election_activity,
    sum(vsd.ttl_fed_receipts_per) AS fed_receipts,
    sum(vsd.ttl_loan_repymts) AS loan_repayments,
    sum(vsd.ttl_loans) AS loans_received,
    sum(vsd.ttl_loans) AS loans,
    sum(vsd.ttl_nonfed_tranf_per) AS total_transfers,
    sum(vsd.ttl_receipts) AS receipts,
    max((committee_info.cmte_tp)::text) AS committee_type,
    max(public.expand_committee_type((committee_info.cmte_tp)::text)) AS committee_type_full,
    max((committee_info.cmte_dsgn)::text) AS committee_designation,
    max(public.expand_committee_designation((committee_info.cmte_dsgn)::text)) AS committee_designation_full,
    max((committee_info.cmte_pty_affiliation_desc)::text) AS party_full,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
        CASE
            WHEN (max((last.form_type)::text) = ANY (ARRAY['F3'::text, 'F3P'::text])) THEN NULL::numeric
            ELSE sum(vsd.indt_exp_per)
        END AS independent_expenditures
   FROM (((disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN last ON ((((vsd.cmte_id)::text = (last.cmte_id)::text) AND (public.get_cycle(vsd.rpt_yr) = last.cycle))))
     LEFT JOIN first ON ((((vsd.cmte_id)::text = (first.committee_id)::text) AND (public.get_cycle(vsd.rpt_yr) = first.cycle))))
     LEFT JOIN committee_info ON ((((vsd.cmte_id)::text = (committee_info.cmte_id)::text) AND ((public.get_cycle(vsd.rpt_yr))::numeric = committee_info.fec_election_yr))))
  WHERE ((public.get_cycle(vsd.rpt_yr) >= 1979) AND (((vsd.form_tp_cd)::text <> 'F5'::text) OR (((vsd.form_tp_cd)::text = 'F5'::text) AND ((vsd.rpt_tp)::text <> ALL (ARRAY[('24'::character varying)::text, ('48'::character varying)::text])))) AND ((vsd.form_tp_cd)::text <> 'F6'::text))
  GROUP BY vsd.cmte_id, vsd.form_tp_cd, (public.get_cycle(vsd.rpt_yr))
  WITH DATA;

ALTER TABLE public.ofec_totals_combined_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_house_senate_mv AS
 WITH hs_cycle AS (
         SELECT DISTINCT ON (cand_cmte_linkage.cmte_id, cand_cmte_linkage.fec_election_yr) cand_cmte_linkage.cmte_id AS committee_id,
            cand_cmte_linkage.cand_election_yr,
            cand_cmte_linkage.fec_election_yr AS cycle
           FROM disclosure.cand_cmte_linkage
          ORDER BY cand_cmte_linkage.cmte_id, cand_cmte_linkage.fec_election_yr, cand_cmte_linkage.cand_election_yr
        )
 SELECT f3.candidate_id,
    f3.cycle,
    f3.sub_id AS idx,
    f3.committee_id,
    hs_cycle.cand_election_yr AS election_cycle,
    f3.coverage_start_date,
    f3.coverage_end_date,
    f3.all_other_loans,
    f3.candidate_contribution,
    f3.contribution_refunds,
    f3.contributions,
    f3.disbursements,
    f3.individual_contributions,
    f3.individual_itemized_contributions,
    f3.individual_unitemized_contributions,
    f3.loan_repayments,
    f3.loan_repayments_candidate_loans,
    f3.loan_repayments_other_loans,
    f3.loans,
    f3.loans_made_by_candidate,
    f3.net_contributions,
    f3.net_operating_expenditures,
    f3.offsets_to_operating_expenditures,
    f3.operating_expenditures,
    f3.other_disbursements,
    f3.other_political_committee_contributions,
    f3.other_receipts,
    f3.political_party_committee_contributions,
    f3.receipts,
    f3.refunded_individual_contributions,
    f3.refunded_other_political_committee_contributions,
    f3.refunded_political_party_committee_contributions,
    f3.transfers_from_other_authorized_committee,
    f3.transfers_to_other_authorized_committee,
    f3.last_report_type_full,
    f3.last_beginning_image_number,
    f3.cash_on_hand_beginning_period,
    f3.last_cash_on_hand_end_period,
    f3.last_debts_owed_by_committee,
    f3.last_debts_owed_to_committee,
    f3.last_report_year,
    f3.committee_name,
    f3.committee_type,
    f3.committee_designation,
    f3.committee_type_full,
    f3.committee_designation_full,
    f3.party_full
   FROM (public.ofec_totals_combined_mv f3
     LEFT JOIN hs_cycle USING (committee_id, cycle))
  WHERE ((f3.form_type)::text = 'F3'::text)
  WITH DATA;

ALTER TABLE public.ofec_totals_house_senate_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_presidential_mv AS
 SELECT ofec_totals_combined_mv.sub_id AS idx,
    ofec_totals_combined_mv.committee_id,
    ofec_totals_combined_mv.cycle,
    ofec_totals_combined_mv.coverage_start_date,
    ofec_totals_combined_mv.coverage_end_date,
    ofec_totals_combined_mv.candidate_contribution,
    ofec_totals_combined_mv.contribution_refunds,
    ofec_totals_combined_mv.contributions,
    ofec_totals_combined_mv.disbursements,
    ofec_totals_combined_mv.exempt_legal_accounting_disbursement,
    ofec_totals_combined_mv.federal_funds,
    ofec_totals_combined_mv.federal_funds_flag,
    ofec_totals_combined_mv.fundraising_disbursements,
    ofec_totals_combined_mv.individual_contributions,
    ofec_totals_combined_mv.individual_unitemized_contributions,
    ofec_totals_combined_mv.individual_itemized_contributions,
    ofec_totals_combined_mv.loans_received,
    ofec_totals_combined_mv.loans_received_from_candidate,
    ofec_totals_combined_mv.loan_repayments_made,
    ofec_totals_combined_mv.offsets_to_fundraising_expenditures,
    ofec_totals_combined_mv.offsets_to_legal_accounting,
    ofec_totals_combined_mv.offsets_to_operating_expenditures,
    ofec_totals_combined_mv.total_offsets_to_operating_expenditures,
    ofec_totals_combined_mv.operating_expenditures,
    ofec_totals_combined_mv.other_disbursements,
    ofec_totals_combined_mv.other_loans_received,
    ofec_totals_combined_mv.other_political_committee_contributions,
    ofec_totals_combined_mv.other_receipts,
    ofec_totals_combined_mv.political_party_committee_contributions,
    ofec_totals_combined_mv.receipts,
    ofec_totals_combined_mv.refunded_individual_contributions,
    ofec_totals_combined_mv.refunded_other_political_committee_contributions,
    ofec_totals_combined_mv.refunded_political_party_committee_contributions,
    ofec_totals_combined_mv.loan_repayments_made AS repayments_loans_made_by_candidate,
    ofec_totals_combined_mv.loan_repayments_other_loans,
    ofec_totals_combined_mv.repayments_other_loans,
    ofec_totals_combined_mv.transfers_from_affiliated_committee,
    ofec_totals_combined_mv.transfers_to_other_authorized_committee,
    ofec_totals_combined_mv.cash_on_hand_beginning_period AS cash_on_hand_beginning_of_period,
    ofec_totals_combined_mv.last_debts_owed_by_committee AS debts_owed_by_cmte,
    ofec_totals_combined_mv.last_debts_owed_to_committee AS debts_owed_to_cmte,
    ofec_totals_combined_mv.net_contributions,
    ofec_totals_combined_mv.net_operating_expenditures,
    ofec_totals_combined_mv.last_report_type_full,
    ofec_totals_combined_mv.last_beginning_image_number,
    ofec_totals_combined_mv.cash_on_hand_beginning_period,
    ofec_totals_combined_mv.last_cash_on_hand_end_period,
    ofec_totals_combined_mv.last_debts_owed_by_committee,
    ofec_totals_combined_mv.last_debts_owed_to_committee,
    ofec_totals_combined_mv.last_net_contributions,
    ofec_totals_combined_mv.last_net_operating_expenditures,
    ofec_totals_combined_mv.last_report_year,
    ofec_totals_combined_mv.committee_name,
    ofec_totals_combined_mv.committee_type,
    ofec_totals_combined_mv.committee_designation,
    ofec_totals_combined_mv.committee_type_full,
    ofec_totals_combined_mv.committee_designation_full,
    ofec_totals_combined_mv.party_full
   FROM public.ofec_totals_combined_mv
  WHERE ((ofec_totals_combined_mv.form_type)::text = 'F3P'::text)
  WITH DATA;

ALTER TABLE public.ofec_totals_presidential_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_candidate_totals_mv AS
 WITH totals AS (
         SELECT ofec_totals_house_senate_mv.committee_id,
            ofec_totals_house_senate_mv.cycle,
            ofec_totals_house_senate_mv.receipts,
            ofec_totals_house_senate_mv.disbursements,
            ofec_totals_house_senate_mv.last_cash_on_hand_end_period,
            ofec_totals_house_senate_mv.last_debts_owed_by_committee,
            ofec_totals_house_senate_mv.coverage_start_date,
            ofec_totals_house_senate_mv.coverage_end_date,
            false AS federal_funds_flag
           FROM public.ofec_totals_house_senate_mv
        UNION ALL
         SELECT ofec_totals_presidential_mv.committee_id,
            ofec_totals_presidential_mv.cycle,
            ofec_totals_presidential_mv.receipts,
            ofec_totals_presidential_mv.disbursements,
            ofec_totals_presidential_mv.last_cash_on_hand_end_period,
            ofec_totals_presidential_mv.last_debts_owed_by_committee,
            ofec_totals_presidential_mv.coverage_start_date,
            ofec_totals_presidential_mv.coverage_end_date,
            ofec_totals_presidential_mv.federal_funds_flag
           FROM public.ofec_totals_presidential_mv
        ), link AS (
         SELECT DISTINCT ofec_cand_cmte_linkage_mv.cand_id,
            (ofec_cand_cmte_linkage_mv.cand_election_yr + (ofec_cand_cmte_linkage_mv.cand_election_yr % (2)::numeric)) AS rounded_election_yr,
            ofec_cand_cmte_linkage_mv.fec_election_yr,
            ofec_cand_cmte_linkage_mv.cmte_id,
            ofec_cand_cmte_linkage_mv.cmte_dsgn
           FROM public.ofec_cand_cmte_linkage_mv
          WHERE ((ofec_cand_cmte_linkage_mv.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[]))
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, totals_1.cycle) link.cand_id AS candidate_id,
            max(link.rounded_election_yr) AS election_year,
            totals_1.cycle,
            false AS is_election,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements,
            (sum(totals_1.receipts) > (0)::numeric) AS has_raised_funds,
            sum(totals_1.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            sum(totals_1.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(totals_1.coverage_start_date) AS coverage_start_date,
            max(totals_1.coverage_end_date) AS coverage_end_date,
            (array_agg(totals_1.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM (link
             JOIN totals totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          GROUP BY link.cand_id, totals_1.cycle
        ), election_aggregates AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            sum(cycle_totals.receipts) AS receipts,
            sum(cycle_totals.disbursements) AS disbursements,
            (sum(cycle_totals.receipts) > (0)::numeric) AS has_raised_funds,
            min(cycle_totals.coverage_start_date) AS coverage_start_date,
            max(cycle_totals.coverage_end_date) AS coverage_end_date,
            (array_agg(cycle_totals.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM cycle_totals
          GROUP BY cycle_totals.candidate_id, cycle_totals.election_year
        ), election_latest AS (
         SELECT DISTINCT ON (totals_1.candidate_id, totals_1.election_year) totals_1.candidate_id,
            totals_1.election_year,
            totals_1.cash_on_hand_end_period,
            totals_1.debts_owed_by_committee,
            totals_1.federal_funds_flag
           FROM cycle_totals totals_1
          ORDER BY totals_1.candidate_id, totals_1.election_year, totals_1.cycle DESC
        ), election_totals AS (
         SELECT totals_1.candidate_id,
            totals_1.election_year,
            totals_1.election_year AS cycle,
            true AS is_election,
            totals_1.receipts,
            totals_1.disbursements,
            totals_1.has_raised_funds,
            latest.cash_on_hand_end_period,
            latest.debts_owed_by_committee,
            totals_1.coverage_start_date,
            totals_1.coverage_end_date,
            totals_1.federal_funds_flag
           FROM (election_aggregates totals_1
             JOIN election_latest latest USING (candidate_id, election_year))
        ), combined_totals AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.election_year,
            cycle_totals.cycle,
            cycle_totals.is_election,
            cycle_totals.receipts,
            cycle_totals.disbursements,
            cycle_totals.has_raised_funds,
            cycle_totals.cash_on_hand_end_period,
            cycle_totals.debts_owed_by_committee,
            cycle_totals.coverage_start_date,
            cycle_totals.coverage_end_date,
            cycle_totals.federal_funds_flag
           FROM cycle_totals
        UNION ALL
         SELECT election_totals.candidate_id,
            election_totals.election_year,
            election_totals.cycle,
            election_totals.is_election,
            election_totals.receipts,
            election_totals.disbursements,
            election_totals.has_raised_funds,
            election_totals.cash_on_hand_end_period,
            election_totals.debts_owed_by_committee,
            election_totals.coverage_start_date,
            election_totals.coverage_end_date,
            election_totals.federal_funds_flag
           FROM election_totals
        )
 SELECT cand.candidate_id,
    cand.candidate_election_year AS election_year,
    cand.two_year_period AS cycle,
    COALESCE(totals.is_election,
        CASE
            WHEN (cand.candidate_election_year = cand.two_year_period) THEN true
            ELSE false
        END) AS is_election,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.has_raised_funds, false) AS has_raised_funds,
    COALESCE(totals.cash_on_hand_end_period, (0)::numeric) AS cash_on_hand_end_period,
    COALESCE(totals.debts_owed_by_committee, (0)::numeric) AS debts_owed_by_committee,
    totals.coverage_start_date,
    totals.coverage_end_date,
    COALESCE(totals.federal_funds_flag, false) AS federal_funds_flag
   FROM (public.ofec_candidate_history_with_future_election_mv cand
     LEFT JOIN combined_totals totals ON ((((cand.candidate_id)::text = (totals.candidate_id)::text) AND (cand.two_year_period = totals.cycle))))
  WITH DATA;

ALTER TABLE public.ofec_candidate_totals_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_candidate_flag_mv AS
 SELECT row_number() OVER () AS idx,
    ofec_candidate_history_mv.candidate_id,
    (array_agg(oct.has_raised_funds) @> ARRAY[true]) AS has_raised_funds,
    (array_agg(oct.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
   FROM (public.ofec_candidate_history_mv
     LEFT JOIN public.ofec_candidate_totals_mv oct USING (candidate_id))
  GROUP BY ofec_candidate_history_mv.candidate_id
  WITH DATA;

ALTER TABLE public.ofec_candidate_flag_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_candidate_fulltext_mv AS
 WITH nicknames AS (
         SELECT ofec_nicknames.candidate_id,
            string_agg(ofec_nicknames.nickname, ' '::text) AS nicknames
           FROM public.ofec_nicknames
          GROUP BY ofec_nicknames.candidate_id
        ), totals AS (
         SELECT link.cand_id AS candidate_id,
            sum(totals_1.receipts) AS receipts,
            sum(totals_1.disbursements) AS disbursements
           FROM (disclosure.cand_cmte_linkage link
             JOIN public.ofec_totals_combined_mv totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          WHERE (((link.cmte_dsgn)::text = ANY (ARRAY[('P'::character varying)::text, ('A'::character varying)::text])) AND ((substr((link.cand_id)::text, 1, 1) = (link.cmte_tp)::text) OR ((link.cmte_tp)::text <> ALL (ARRAY[('P'::character varying)::text, ('S'::character varying)::text, ('H'::character varying)::text]))))
          GROUP BY link.cand_id
        )
 SELECT DISTINCT ON (candidate_id) row_number() OVER () AS idx,
    candidate_id AS id,
    ofec_candidate_detail_mv.name,
    ofec_candidate_detail_mv.office AS office_sought,
        CASE
            WHEN (ofec_candidate_detail_mv.name IS NOT NULL) THEN ((setweight(to_tsvector((ofec_candidate_detail_mv.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(nicknames.nicknames, ''::text)), 'A'::"char")) || setweight(to_tsvector((candidate_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    (COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) AS total_activity
   FROM ((public.ofec_candidate_detail_mv
     LEFT JOIN nicknames USING (candidate_id))
     LEFT JOIN totals USING (candidate_id))
  WITH DATA;

ALTER TABLE public.ofec_candidate_fulltext_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_committee_fulltext_mv AS
 WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM public.ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_mv.committee_id,
            sum(ofec_totals_combined_mv.receipts) AS receipts,
            sum(ofec_totals_combined_mv.disbursements) AS disbursements,
            sum(ofec_totals_combined_mv.independent_expenditures) AS independent_expenditures
           FROM public.ofec_totals_combined_mv
          GROUP BY ofec_totals_combined_mv.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector((cd.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(pac.pacronyms, ''::text)), 'A'::"char")) || setweight(to_tsvector((committee_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts,
    COALESCE(totals.disbursements, (0)::numeric) AS disbursements,
    COALESCE(totals.independent_expenditures, (0)::numeric) AS independent_expenditures,
    ((COALESCE(totals.receipts, (0)::numeric) + COALESCE(totals.disbursements, (0)::numeric)) + COALESCE(totals.independent_expenditures, (0)::numeric)) AS total_activity
   FROM ((public.ofec_committee_detail_mv cd
     LEFT JOIN pacronyms pac USING (committee_id))
     LEFT JOIN totals USING (committee_id))
  WITH DATA;

ALTER TABLE public.ofec_committee_fulltext_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_pacs_parties_mv AS
 SELECT oft.sub_id AS idx,
    oft.committee_id,
    oft.committee_name,
    oft.cycle,
    oft.coverage_start_date,
    oft.coverage_end_date,
    oft.all_loans_received,
    oft.allocated_federal_election_levin_share,
    oft.contribution_refunds,
    oft.contributions,
    oft.coordinated_expenditures_by_party_committee,
    oft.disbursements,
    oft.fed_candidate_committee_contributions,
    oft.fed_candidate_contribution_refunds,
    oft.fed_disbursements,
    oft.fed_election_activity,
    oft.fed_receipts,
    oft.independent_expenditures,
    oft.refunded_individual_contributions,
    oft.individual_itemized_contributions,
    oft.individual_unitemized_contributions,
    oft.individual_contributions,
    oft.loan_repayments_other_loans AS loan_repayments_made,
    oft.loan_repayments_other_loans,
    oft.loan_repayments_received,
    oft.loans_made,
    oft.transfers_to_other_authorized_committee,
    oft.net_operating_expenditures,
    oft.non_allocated_fed_election_activity,
    oft.total_transfers,
    oft.offsets_to_operating_expenditures,
    oft.operating_expenditures,
    oft.operating_expenditures AS fed_operating_expenditures,
    oft.other_disbursements,
    oft.other_fed_operating_expenditures,
    oft.other_fed_receipts,
    oft.other_political_committee_contributions,
    oft.refunded_other_political_committee_contributions,
    oft.political_party_committee_contributions,
    oft.refunded_political_party_committee_contributions,
    oft.receipts,
    oft.shared_fed_activity,
    oft.shared_fed_activity_nonfed,
    oft.shared_fed_operating_expenditures,
    oft.shared_nonfed_operating_expenditures,
    oft.transfers_from_affiliated_party,
    oft.transfers_from_nonfed_account,
    oft.transfers_from_nonfed_levin,
    oft.transfers_to_affiliated_committee,
    oft.net_contributions,
    oft.last_report_type_full,
    oft.last_beginning_image_number,
    oft.last_cash_on_hand_end_period,
    oft.cash_on_hand_beginning_period,
    oft.last_debts_owed_by_committee,
    oft.last_debts_owed_to_committee,
    oft.last_report_year,
    oft.committee_type,
    oft.committee_designation,
    oft.committee_type_full,
    oft.committee_designation_full,
    oft.party_full,
    comm_dets.designation
   FROM (public.ofec_totals_combined_mv oft
     JOIN public.ofec_committee_detail_mv comm_dets USING (committee_id))
  WHERE ((oft.form_type)::text = 'F3X'::text)
  WITH DATA;

ALTER TABLE public.ofec_totals_pacs_parties_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_pacs_mv AS
 SELECT ofec_totals_pacs_parties_mv.idx,
    ofec_totals_pacs_parties_mv.committee_id,
    ofec_totals_pacs_parties_mv.committee_name,
    ofec_totals_pacs_parties_mv.cycle,
    ofec_totals_pacs_parties_mv.coverage_start_date,
    ofec_totals_pacs_parties_mv.coverage_end_date,
    ofec_totals_pacs_parties_mv.all_loans_received,
    ofec_totals_pacs_parties_mv.allocated_federal_election_levin_share,
    ofec_totals_pacs_parties_mv.contribution_refunds,
    ofec_totals_pacs_parties_mv.contributions,
    ofec_totals_pacs_parties_mv.coordinated_expenditures_by_party_committee,
    ofec_totals_pacs_parties_mv.disbursements,
    ofec_totals_pacs_parties_mv.fed_candidate_committee_contributions,
    ofec_totals_pacs_parties_mv.fed_candidate_contribution_refunds,
    ofec_totals_pacs_parties_mv.fed_disbursements,
    ofec_totals_pacs_parties_mv.fed_election_activity,
    ofec_totals_pacs_parties_mv.fed_receipts,
    ofec_totals_pacs_parties_mv.independent_expenditures,
    ofec_totals_pacs_parties_mv.refunded_individual_contributions,
    ofec_totals_pacs_parties_mv.individual_itemized_contributions,
    ofec_totals_pacs_parties_mv.individual_unitemized_contributions,
    ofec_totals_pacs_parties_mv.individual_contributions,
    ofec_totals_pacs_parties_mv.loan_repayments_made,
    ofec_totals_pacs_parties_mv.loan_repayments_other_loans,
    ofec_totals_pacs_parties_mv.loan_repayments_received,
    ofec_totals_pacs_parties_mv.loans_made,
    ofec_totals_pacs_parties_mv.transfers_to_other_authorized_committee,
    ofec_totals_pacs_parties_mv.net_operating_expenditures,
    ofec_totals_pacs_parties_mv.non_allocated_fed_election_activity,
    ofec_totals_pacs_parties_mv.total_transfers,
    ofec_totals_pacs_parties_mv.offsets_to_operating_expenditures,
    ofec_totals_pacs_parties_mv.operating_expenditures,
    ofec_totals_pacs_parties_mv.fed_operating_expenditures,
    ofec_totals_pacs_parties_mv.other_disbursements,
    ofec_totals_pacs_parties_mv.other_fed_operating_expenditures,
    ofec_totals_pacs_parties_mv.other_fed_receipts,
    ofec_totals_pacs_parties_mv.other_political_committee_contributions,
    ofec_totals_pacs_parties_mv.refunded_other_political_committee_contributions,
    ofec_totals_pacs_parties_mv.political_party_committee_contributions,
    ofec_totals_pacs_parties_mv.refunded_political_party_committee_contributions,
    ofec_totals_pacs_parties_mv.receipts,
    ofec_totals_pacs_parties_mv.shared_fed_activity,
    ofec_totals_pacs_parties_mv.shared_fed_activity_nonfed,
    ofec_totals_pacs_parties_mv.shared_fed_operating_expenditures,
    ofec_totals_pacs_parties_mv.shared_nonfed_operating_expenditures,
    ofec_totals_pacs_parties_mv.transfers_from_affiliated_party,
    ofec_totals_pacs_parties_mv.transfers_from_nonfed_account,
    ofec_totals_pacs_parties_mv.transfers_from_nonfed_levin,
    ofec_totals_pacs_parties_mv.transfers_to_affiliated_committee,
    ofec_totals_pacs_parties_mv.net_contributions,
    ofec_totals_pacs_parties_mv.last_report_type_full,
    ofec_totals_pacs_parties_mv.last_beginning_image_number,
    ofec_totals_pacs_parties_mv.last_cash_on_hand_end_period,
    ofec_totals_pacs_parties_mv.cash_on_hand_beginning_period,
    ofec_totals_pacs_parties_mv.last_debts_owed_by_committee,
    ofec_totals_pacs_parties_mv.last_debts_owed_to_committee,
    ofec_totals_pacs_parties_mv.last_report_year,
    ofec_totals_pacs_parties_mv.committee_type,
    ofec_totals_pacs_parties_mv.committee_designation,
    ofec_totals_pacs_parties_mv.committee_type_full,
    ofec_totals_pacs_parties_mv.committee_designation_full,
    ofec_totals_pacs_parties_mv.party_full,
    ofec_totals_pacs_parties_mv.designation
   FROM public.ofec_totals_pacs_parties_mv
  WHERE ((ofec_totals_pacs_parties_mv.committee_type = 'N'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'Q'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'O'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'V'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'W'::text))
  WITH DATA;

ALTER TABLE public.ofec_totals_pacs_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_parties_mv AS
 SELECT pp.idx,
    pp.committee_id,
    pp.committee_name,
    pp.cycle,
    pp.coverage_start_date,
    pp.coverage_end_date,
    pp.all_loans_received,
    pp.allocated_federal_election_levin_share,
    pp.contribution_refunds,
    pp.contributions,
    pp.coordinated_expenditures_by_party_committee,
    pp.disbursements,
    pp.fed_candidate_committee_contributions,
    pp.fed_candidate_contribution_refunds,
    pp.fed_disbursements,
    pp.fed_election_activity,
    pp.fed_receipts,
    pp.independent_expenditures,
    pp.refunded_individual_contributions,
    pp.individual_itemized_contributions,
    pp.individual_unitemized_contributions,
    pp.individual_contributions,
    pp.loan_repayments_made,
    pp.loan_repayments_other_loans,
    pp.loan_repayments_received,
    pp.loans_made,
    pp.transfers_to_other_authorized_committee,
    pp.net_operating_expenditures,
    pp.non_allocated_fed_election_activity,
    pp.total_transfers,
    pp.offsets_to_operating_expenditures,
    pp.operating_expenditures,
    pp.fed_operating_expenditures,
    pp.other_disbursements,
    pp.other_fed_operating_expenditures,
    pp.other_fed_receipts,
    pp.other_political_committee_contributions,
    pp.refunded_other_political_committee_contributions,
    pp.political_party_committee_contributions,
    pp.refunded_political_party_committee_contributions,
    pp.receipts,
    pp.shared_fed_activity,
    pp.shared_fed_activity_nonfed,
    pp.shared_fed_operating_expenditures,
    pp.shared_nonfed_operating_expenditures,
    pp.transfers_from_affiliated_party,
    pp.transfers_from_nonfed_account,
    pp.transfers_from_nonfed_levin,
    pp.transfers_to_affiliated_committee,
    pp.net_contributions,
    pp.last_report_type_full,
    pp.last_beginning_image_number,
    pp.last_cash_on_hand_end_period,
    pp.cash_on_hand_beginning_period,
    pp.last_debts_owed_by_committee,
    pp.last_debts_owed_to_committee,
    pp.last_report_year,
    pp.committee_type,
    pp.committee_designation,
    pp.committee_type_full,
    pp.committee_designation_full,
    pp.party_full,
    pp.designation
   FROM public.ofec_totals_pacs_parties_mv pp
  WHERE ((pp.committee_type = 'X'::text) OR (pp.committee_type = 'Y'::text))
  WITH DATA;

ALTER TABLE public.ofec_totals_parties_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_entity_chart_mv AS
 WITH cand_totals AS (
         SELECT 'candidate'::text AS type,
            date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_house_senate_mv.receipts, (0)::numeric) - ((((COALESCE(ofec_totals_house_senate_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)))) AS candidate_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_house_senate_mv.disbursements, (0)::numeric) - (((COALESCE(ofec_totals_house_senate_mv.transfers_to_other_authorized_committee, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.other_disbursements, (0)::numeric)))) AS candidate_adjusted_total_disbursements
           FROM public.ofec_totals_house_senate_mv
          WHERE (ofec_totals_house_senate_mv.cycle >= 2008)
          GROUP BY (date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date))
        ), pac_totals AS (
         SELECT 'pac'::text AS type,
            date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_pacs_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_pacs_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)))) AS pac_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_pacs_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_pacs_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.transfers_to_affiliated_committee, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.other_disbursements, (0)::numeric)))) AS pac_adjusted_total_disbursements
           FROM public.ofec_totals_pacs_mv
          WHERE ((ofec_totals_pacs_mv.committee_type = ANY (ARRAY['N'::text, 'Q'::text, 'O'::text, 'V'::text, 'W'::text])) AND ((ofec_totals_pacs_mv.designation)::text <> 'J'::text) AND (ofec_totals_pacs_mv.cycle >= 2008))
          GROUP BY (date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date))
        ), party_totals AS (
         SELECT 'party'::text AS type,
            date_part('month'::text, ofec_totals_parties_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_parties_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_parties_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_parties_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_parties_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)))) AS party_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_parties_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_parties_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_parties_mv.transfers_to_other_authorized_committee, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.other_disbursements, (0)::numeric)))) AS party_adjusted_total_disbursements
           FROM public.ofec_totals_parties_mv
          WHERE ((ofec_totals_parties_mv.committee_type = ANY (ARRAY['X'::text, 'Y'::text])) AND ((ofec_totals_parties_mv.designation)::text <> 'J'::text) AND ((ofec_totals_parties_mv.committee_id)::text <> ALL (ARRAY[('C00578419'::character varying)::text, ('C00485110'::character varying)::text, ('C00422048'::character varying)::text, ('C00567057'::character varying)::text, ('C00483586'::character varying)::text, ('C00431791'::character varying)::text, ('C00571133'::character varying)::text, ('C00500405'::character varying)::text, ('C00435560'::character varying)::text, ('C00572958'::character varying)::text, ('C00493254'::character varying)::text, ('C00496570'::character varying)::text, ('C00431593'::character varying)::text])) AND (ofec_totals_parties_mv.cycle >= 2008))
          GROUP BY (date_part('month'::text, ofec_totals_parties_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_parties_mv.coverage_end_date))
        ), combined AS (
         SELECT month,
            year,
            ((year)::numeric + ((year)::numeric % (2)::numeric)) AS cycle,
                CASE
                    WHEN (max(cand_totals.candidate_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(cand_totals.candidate_adjusted_total_receipts)
                END AS candidate_receipts,
                CASE
                    WHEN (max(cand_totals.candidate_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(cand_totals.candidate_adjusted_total_disbursements)
                END AS canidate_disbursements,
                CASE
                    WHEN (max(pac_totals.pac_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(pac_totals.pac_adjusted_total_receipts)
                END AS pac_receipts,
                CASE
                    WHEN (max(pac_totals.pac_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(pac_totals.pac_adjusted_total_disbursements)
                END AS pac_disbursements,
                CASE
                    WHEN (max(party_totals.party_adjusted_total_receipts) IS NULL) THEN (0)::numeric
                    ELSE max(party_totals.party_adjusted_total_receipts)
                END AS party_receipts,
                CASE
                    WHEN (max(party_totals.party_adjusted_total_disbursements) IS NULL) THEN (0)::numeric
                    ELSE max(party_totals.party_adjusted_total_disbursements)
                END AS party_disbursements
           FROM ((cand_totals
             FULL JOIN pac_totals USING (month, year))
             FULL JOIN party_totals USING (month, year))
          GROUP BY month, year
          ORDER BY year, month
        )
 SELECT row_number() OVER () AS idx,
    combined.month,
    combined.year,
    combined.cycle,
    public.last_day_of_month(make_timestamp((combined.year)::integer, (combined.month)::integer, 1, 0, 0, (0.0)::double precision)) AS date,
    sum(combined.candidate_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_candidate_receipts,
    combined.candidate_receipts,
    sum(combined.canidate_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_candidate_disbursements,
    combined.canidate_disbursements,
    sum(combined.pac_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_pac_receipts,
    combined.pac_receipts,
    sum(combined.pac_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_pac_disbursements,
    combined.pac_disbursements,
    sum(combined.party_receipts) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_party_receipts,
    combined.party_receipts,
    sum(combined.party_disbursements) OVER (PARTITION BY combined.cycle ORDER BY combined.year, combined.month) AS cumulative_party_disbursements,
    combined.party_disbursements
   FROM combined
  WHERE (combined.cycle >= (2008)::numeric)
  WITH DATA;

ALTER TABLE public.ofec_entity_chart_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_filings_all_mv AS
 WITH filings AS (
         SELECT cand.candidate_id,
            cand.name AS candidate_name,
            filing_history.cand_cmte_id AS committee_id,
            com.name AS committee_name,
            filing_history.sub_id,
            ((filing_history.cvg_start_dt)::text)::date AS coverage_start_date,
            ((filing_history.cvg_end_dt)::text)::date AS coverage_end_date,
            ((filing_history.receipt_dt)::text)::date AS receipt_date,
            filing_history.election_yr AS election_year,
            filing_history.form_tp AS form_type,
            filing_history.rpt_yr AS report_year,
            public.get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            filing_history.to_from_ind AS document_type,
            public.expand_document((filing_history.to_from_ind)::text) AS document_type_full,
            (filing_history.begin_image_num)::bigint AS beginning_image_number,
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
            public.report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, (filing_history.form_tp)::text) AS pdf_url,
            public.means_filed((filing_history.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((filing_history.begin_image_num)::text), (filing_history.cand_cmte_id)::text, (filing_history.file_num)::text) AS html_url,
            public.report_fec_url((filing_history.begin_image_num)::text, (filing_history.file_num)::integer) AS fec_url,
            amendments.amendment_chain,
            amendments.mst_rct_file_num AS most_recent_file_number,
            public.is_amended((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS is_amended,
            public.is_most_recent((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS most_recent,
                CASE
                    WHEN (upper((filing_history.form_tp)::text) = 'FRQ'::text) THEN 0
                    WHEN (upper((filing_history.form_tp)::text) = 'F99'::text) THEN 0
                    ELSE (array_length(amendments.amendment_chain, 1) - 1)
                END AS amendment_version,
            cand.state,
            cand.office,
            cand.district,
            cand.party,
            cmte_valid_fec_yr.cmte_tp,
            public.get_office_cmte_tp(cand.office, cmte_valid_fec_yr.cmte_tp) AS office_cmte_tp
           FROM (((((disclosure.f_rpt_or_form_sub filing_history
             LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON ((((filing_history.cand_cmte_id)::text = (cmte_valid_fec_yr.cmte_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cmte_valid_fec_yr.fec_election_yr))))
             LEFT JOIN public.ofec_committee_history_mv com ON ((((filing_history.cand_cmte_id)::text = (com.committee_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN public.ofec_candidate_history_mv cand ON ((((filing_history.cand_cmte_id)::text = (cand.candidate_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
             LEFT JOIN staging.ref_rpt_tp report ON (((filing_history.rpt_tp)::text = (report.rpt_tp_cd)::text)))
             LEFT JOIN public.ofec_filings_amendments_all_mv amendments ON ((filing_history.file_num = amendments.file_num)))
          WHERE ((filing_history.rpt_yr >= (1979)::numeric) AND ((filing_history.form_tp)::text <> 'SL'::text))
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
            public.get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            NULL::character varying(1) AS document_type,
            NULL::text AS document_type_full,
            (filing_history.begin_image_num)::bigint AS beginning_image_number,
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
            public.report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, 'RFAI'::text) AS pdf_url,
            public.means_filed((filing_history.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((filing_history.begin_image_num)::text), (filing_history.id)::text, (filing_history.file_num)::text) AS html_url,
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
            public.get_office_cmte_tp(cand.office, cmte_valid_fec_yr.cmte_tp) AS office_cmte_tp
           FROM ((((disclosure.nml_form_rfai filing_history
             LEFT JOIN disclosure.cmte_valid_fec_yr cmte_valid_fec_yr ON ((((filing_history.id)::text = (cmte_valid_fec_yr.cmte_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cmte_valid_fec_yr.fec_election_yr))))
             LEFT JOIN public.ofec_committee_history_mv com ON ((((filing_history.id)::text = (com.committee_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN public.ofec_candidate_history_mv cand ON ((((filing_history.id)::text = (cand.candidate_id)::text) AND ((public.get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
             LEFT JOIN staging.ref_rpt_tp report ON (((filing_history.rpt_tp)::text = (report.rpt_tp_cd)::text)))
          WHERE ((filing_history.rpt_yr >= (1979)::numeric) AND (filing_history.delete_ind IS NULL))
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

ALTER TABLE public.ofec_filings_all_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_report_pac_party_all_mv AS
 WITH f3_by_non_house_senate AS (
         SELECT r.sub_id,
            r.cvg_start_dt,
            r.cvg_end_dt,
            r.receipt_dt,
            (r.rpt_yr + (r.rpt_yr % (2)::numeric)) AS cycle,
            r.cand_cmte_id AS committee_id,
            c.cmte_tp,
            'Form 3'::text AS form_tp,
            r.rpt_yr,
            r.rpt_tp,
            ref_rpt_tp.rpt_tp_desc AS report_type_full,
            r.amndt_ind,
                CASE
                    WHEN ((r.amndt_ind)::text = 'N'::text) THEN 'NEW'::text
                    WHEN ((r.amndt_ind)::text = 'A'::text) THEN 'AMENDMENT'::text
                    ELSE NULL::text
                END AS amendment_indicator_full,
            r.request_tp,
            r.begin_image_num,
            r.end_image_num,
            r.ttl_receipts,
            r.ttl_indt_contb,
            r.ttl_disb,
            r.coh_bop,
            r.coh_cop,
            r.debts_owed_by_cmte,
            r.debts_owed_to_cmte,
            r.file_num,
            r.prev_file_num,
            r.rpt_pgi AS primary_general_indicator,
                CASE
                    WHEN (vs.orig_sub_id IS NOT NULL) THEN 'Y'::text
                    ELSE 'N'::text
                END AS most_recent_filing_flag
           FROM (((disclosure.f_rpt_or_form_sub r
             JOIN disclosure.cmte_valid_fec_yr c ON ((((c.cmte_id)::text = (r.cand_cmte_id)::text) AND (c.fec_election_yr = (r.rpt_yr + (r.rpt_yr % (2)::numeric))))))
             LEFT JOIN disclosure.v_sum_and_det_sum_report vs ON ((r.sub_id = vs.orig_sub_id)))
             LEFT JOIN staging.ref_rpt_tp ref_rpt_tp ON (((ref_rpt_tp.rpt_tp_cd)::text = (r.rpt_tp)::text)))
          WHERE ((r.rpt_yr >= (1979)::numeric) AND ((c.cmte_tp)::text <> ALL ((ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying, 'I'::character varying])::text[])) AND ((r.form_tp)::text = 'F3'::text))
        ), pac_party_report AS (
         SELECT f3x.cmte_id AS committee_id,
            f3x.election_cycle AS cycle,
            f3x.cvg_start_dt AS coverage_start_date,
            f3x.cvg_end_dt AS coverage_end_date,
            f3x.all_loans_received_per AS all_loans_received_period,
            f3x.all_loans_received_ytd,
            f3x.shared_fed_actvy_nonfed_per AS allocated_federal_election_levin_share_period,
            f3x.begin_image_num AS beginning_image_number,
            f3x.calendar_yr AS calendar_ytd,
            f3x.coh_begin_calendar_yr AS cash_on_hand_beginning_calendar_ytd,
            f3x.coh_bop AS cash_on_hand_beginning_period,
            f3x.coh_coy AS cash_on_hand_close_ytd,
            f3x.coh_cop AS cash_on_hand_end_period,
            f3x.coord_exp_by_pty_cmte_per AS coordinated_expenditures_by_party_committee_period,
            f3x.coord_exp_by_pty_cmte_ytd AS coordinated_expenditures_by_party_committee_ytd,
            f3x.debts_owed_by_cmte AS debts_owed_by_committee,
            f3x.debts_owed_to_cmte AS debts_owed_to_committee,
            f3x.end_image_num AS end_image_number,
            f3x.fed_cand_cmte_contb_ref_ytd AS fed_candidate_committee_contribution_refunds_ytd,
            f3x.fed_cand_cmte_contb_per AS fed_candidate_committee_contributions_period,
            f3x.fed_cand_cmte_contb_ytd AS fed_candidate_committee_contributions_ytd,
            f3x.fed_cand_contb_ref_per AS fed_candidate_contribution_refunds_period,
            f3x.indt_exp_per AS independent_expenditures_period,
            f3x.indt_exp_ytd AS independent_expenditures_ytd,
            f3x.indv_contb_ref_per AS refunded_individual_contributions_period,
            f3x.indv_contb_ref_ytd AS refunded_individual_contributions_ytd,
            f3x.indv_item_contb_per AS individual_itemized_contributions_period,
            f3x.indv_item_contb_ytd AS individual_itemized_contributions_ytd,
            f3x.indv_unitem_contb_per AS individual_unitemized_contributions_period,
            f3x.indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
            f3x.loan_repymts_made_per AS loan_repayments_made_period,
            f3x.loan_repymts_made_ytd AS loan_repayments_made_ytd,
            f3x.loan_repymts_received_per AS loan_repayments_received_period,
            f3x.loan_repymts_received_ytd AS loan_repayments_received_ytd,
            f3x.loans_made_per AS loans_made_period,
            f3x.loans_made_ytd,
            f3x.net_contb_per AS net_contributions_period,
            f3x.net_contb_ytd AS net_contributions_ytd,
            f3x.net_op_exp_per AS net_operating_expenditures_period,
            f3x.net_op_exp_ytd AS net_operating_expenditures_ytd,
            f3x.non_alloc_fed_elect_actvy_per AS non_allocated_fed_election_activity_period,
            f3x.non_alloc_fed_elect_actvy_ytd AS non_allocated_fed_election_activity_ytd,
            f3x.shared_nonfed_op_exp_per AS nonfed_share_allocated_disbursements_period,
            f3x.offests_to_op_exp AS offsets_to_operating_expenditures_period,
            f3x.offsets_to_op_exp_ytd_i AS offsets_to_operating_expenditures_ytd,
            f3x.other_disb_per AS other_disbursements_period,
            f3x.other_disb_ytd AS other_disbursements_ytd,
            f3x.other_fed_op_exp_per AS other_fed_operating_expenditures_period,
            f3x.other_fed_op_exp_ytd AS other_fed_operating_expenditures_ytd,
            f3x.other_fed_receipts_per AS other_fed_receipts_period,
            f3x.other_fed_receipts_ytd,
            f3x.other_pol_cmte_refund AS refunded_other_political_committee_contributions_period,
            f3x.other_pol_cmte_refund_ytd AS refunded_other_political_committee_contributions_ytd,
            f3x.other_pol_cmte_contb_per_i AS other_political_committee_contributions_period,
            f3x.other_pol_cmte_contb_ytd_i AS other_political_committee_contributions_ytd,
            f3x.pol_pty_cmte_refund AS refunded_political_party_committee_contributions_period,
            f3x.pol_pty_cmte_refund_ytd AS refunded_political_party_committee_contributions_ytd,
            f3x.pol_pty_cmte_contb_per_i AS political_party_committee_contributions_period,
            f3x.pol_pty_cmte_contb_ytd_i AS political_party_committee_contributions_ytd,
            f3x.rpt_yr AS report_year,
            f3x.shared_fed_actvy_nonfed_ytd AS shared_fed_activity_nonfed_ytd,
            f3x.shared_fed_actvy_fed_shr_per AS shared_fed_activity_period,
            f3x.shared_fed_actvy_fed_shr_ytd AS shared_fed_activity_ytd,
            f3x.shared_fed_op_exp_per AS shared_fed_operating_expenditures_period,
            f3x.shared_fed_op_exp_ytd AS shared_fed_operating_expenditures_ytd,
            f3x.shared_nonfed_op_exp_per AS shared_nonfed_operating_expenditures_period,
            f3x.shared_nonfed_op_exp_ytd AS shared_nonfed_operating_expenditures_ytd,
            f3x.subttl_sum_page_per AS subtotal_summary_page_period,
            f3x.subttl_sum_ytd AS subtotal_summary_ytd,
            f3x.ttl_contb_refund AS total_contribution_refunds_period,
            f3x.ttl_contb_refund_ytd AS total_contribution_refunds_ytd,
            f3x.ttl_contb_per AS total_contributions_period,
            f3x.ttl_contb_ytd AS total_contributions_ytd,
            f3x.ttl_disb AS total_disbursements_period,
            f3x.ttl_disb_ytd AS total_disbursements_ytd,
            f3x.ttl_fed_disb_per AS total_fed_disbursements_period,
            f3x.ttl_fed_disb_ytd AS total_fed_disbursements_ytd,
            f3x.ttl_fed_elect_actvy_per AS total_fed_election_activity_period,
            f3x.ttl_fed_elect_actvy_ytd AS total_fed_election_activity_ytd,
            f3x.ttl_fed_op_exp_per AS total_fed_operating_expenditures_period,
            f3x.ttl_fed_op_exp_ytd AS total_fed_operating_expenditures_ytd,
            f3x.ttl_fed_receipts_per AS total_fed_receipts_period,
            f3x.ttl_fed_receipts_ytd AS total_fed_receipts_ytd,
            f3x.ttl_indv_contb AS total_individual_contributions_period,
            f3x.ttl_indv_contb_ytd AS total_individual_contributions_ytd,
            f3x.ttl_nonfed_tranf_per AS total_nonfed_transfers_period,
            f3x.ttl_nonfed_tranf_ytd AS total_nonfed_transfers_ytd,
            f3x.ttl_op_exp_per AS total_operating_expenditures_period,
            f3x.ttl_op_exp_ytd AS total_operating_expenditures_ytd,
            f3x.ttl_receipts AS total_receipts_period,
            f3x.ttl_receipts_ytd AS total_receipts_ytd,
            f3x.tranf_from_affiliated_pty_per AS transfers_from_affiliated_party_period,
            f3x.tranf_from_affiliated_pty_ytd AS transfers_from_affiliated_party_ytd,
            f3x.tranf_from_nonfed_acct_per AS transfers_from_nonfed_account_period,
            f3x.tranf_from_nonfed_acct_ytd AS transfers_from_nonfed_account_ytd,
            f3x.tranf_from_nonfed_levin_per AS transfers_from_nonfed_levin_period,
            f3x.tranf_from_nonfed_levin_ytd AS transfers_from_nonfed_levin_ytd,
            f3x.tranf_to_affliliated_cmte_per AS transfers_to_affiliated_committee_period,
            f3x.tranf_to_affilitated_cmte_ytd AS transfers_to_affilitated_committees_ytd,
            'Form 3X'::text AS form_tp,
            f3x.rpt_tp AS report_type,
            f3x.rpt_tp_desc AS report_type_full,
            (f3x.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
            f3x.receipt_dt AS receipt_date,
            f3x.file_num AS file_number,
            f3x.amndt_ind AS amendment_indicator,
            f3x.amndt_ind_desc AS amendment_indicator_full,
            public.means_filed((f3x.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((f3x.begin_image_num)::text), (f3x.cmte_id)::text, (f3x.file_num)::text) AS html_url,
            public.report_fec_url((f3x.begin_image_num)::text, (f3x.file_num)::integer) AS fec_url
           FROM public.fec_vsum_f3x_vw f3x
          WHERE (f3x.election_cycle >= (1979)::numeric)
        UNION ALL
         SELECT f3.committee_id,
            f3.cycle,
            ((f3.cvg_start_dt)::text)::timestamp without time zone AS cvg_start_dt,
            ((f3.cvg_end_dt)::text)::timestamp without time zone AS cvg_end_dt,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.begin_image_num,
            NULL::numeric,
            NULL::numeric,
            f3.coh_bop,
            NULL::numeric,
            f3.coh_cop,
            NULL::numeric,
            NULL::numeric,
            f3.debts_owed_by_cmte,
            f3.debts_owed_to_cmte,
            f3.end_image_num,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.rpt_yr,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.ttl_disb,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.ttl_indt_contb,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.ttl_receipts,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            NULL::numeric,
            f3.form_tp,
            f3.rpt_tp,
            f3.report_type_full,
            (f3.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
            ((f3.receipt_dt)::text)::timestamp without time zone AS receipt_dt,
            f3.file_num,
            f3.amndt_ind,
            f3.amendment_indicator_full,
            public.means_filed((f3.begin_image_num)::text) AS means_filed,
            public.report_html_url(public.means_filed((f3.begin_image_num)::text), (f3.committee_id)::text, (f3.file_num)::text) AS html_url,
            public.report_fec_url((f3.begin_image_num)::text, (f3.file_num)::integer) AS fec_url
           FROM f3_by_non_house_senate f3
        )
 SELECT row_number() OVER () AS idx,
    rpt.committee_id,
    rpt.cycle,
    rpt.coverage_start_date,
    rpt.coverage_end_date,
    rpt.all_loans_received_period,
    rpt.all_loans_received_ytd,
    rpt.allocated_federal_election_levin_share_period,
    rpt.beginning_image_number,
    rpt.calendar_ytd,
    rpt.cash_on_hand_beginning_calendar_ytd,
    rpt.cash_on_hand_beginning_period,
    rpt.cash_on_hand_close_ytd,
    rpt.cash_on_hand_end_period,
    rpt.coordinated_expenditures_by_party_committee_period,
    rpt.coordinated_expenditures_by_party_committee_ytd,
    rpt.debts_owed_by_committee,
    rpt.debts_owed_to_committee,
    rpt.end_image_number,
    rpt.fed_candidate_committee_contribution_refunds_ytd,
    rpt.fed_candidate_committee_contributions_period,
    rpt.fed_candidate_committee_contributions_ytd,
    rpt.fed_candidate_contribution_refunds_period,
    rpt.independent_expenditures_period,
    rpt.independent_expenditures_ytd,
    rpt.refunded_individual_contributions_period,
    rpt.refunded_individual_contributions_ytd,
    rpt.individual_itemized_contributions_period,
    rpt.individual_itemized_contributions_ytd,
    rpt.individual_unitemized_contributions_period,
    rpt.individual_unitemized_contributions_ytd,
    rpt.loan_repayments_made_period,
    rpt.loan_repayments_made_ytd,
    rpt.loan_repayments_received_period,
    rpt.loan_repayments_received_ytd,
    rpt.loans_made_period,
    rpt.loans_made_ytd,
    rpt.net_contributions_period,
    rpt.net_contributions_ytd,
    rpt.net_operating_expenditures_period,
    rpt.net_operating_expenditures_ytd,
    rpt.non_allocated_fed_election_activity_period,
    rpt.non_allocated_fed_election_activity_ytd,
    rpt.nonfed_share_allocated_disbursements_period,
    rpt.offsets_to_operating_expenditures_period,
    rpt.offsets_to_operating_expenditures_ytd,
    rpt.other_disbursements_period,
    rpt.other_disbursements_ytd,
    rpt.other_fed_operating_expenditures_period,
    rpt.other_fed_operating_expenditures_ytd,
    rpt.other_fed_receipts_period,
    rpt.other_fed_receipts_ytd,
    rpt.refunded_other_political_committee_contributions_period,
    rpt.refunded_other_political_committee_contributions_ytd,
    rpt.other_political_committee_contributions_period,
    rpt.other_political_committee_contributions_ytd,
    rpt.refunded_political_party_committee_contributions_period,
    rpt.refunded_political_party_committee_contributions_ytd,
    rpt.political_party_committee_contributions_period,
    rpt.political_party_committee_contributions_ytd,
    rpt.report_year,
    rpt.shared_fed_activity_nonfed_ytd,
    rpt.shared_fed_activity_period,
    rpt.shared_fed_activity_ytd,
    rpt.shared_fed_operating_expenditures_period,
    rpt.shared_fed_operating_expenditures_ytd,
    rpt.shared_nonfed_operating_expenditures_period,
    rpt.shared_nonfed_operating_expenditures_ytd,
    rpt.subtotal_summary_page_period,
    rpt.subtotal_summary_ytd,
    rpt.total_contribution_refunds_period,
    rpt.total_contribution_refunds_ytd,
    rpt.total_contributions_period,
    rpt.total_contributions_ytd,
    rpt.total_disbursements_period,
    rpt.total_disbursements_ytd,
    rpt.total_fed_disbursements_period,
    rpt.total_fed_disbursements_ytd,
    rpt.total_fed_election_activity_period,
    rpt.total_fed_election_activity_ytd,
    rpt.total_fed_operating_expenditures_period,
    rpt.total_fed_operating_expenditures_ytd,
    rpt.total_fed_receipts_period,
    rpt.total_fed_receipts_ytd,
    rpt.total_individual_contributions_period,
    rpt.total_individual_contributions_ytd,
    rpt.total_nonfed_transfers_period,
    rpt.total_nonfed_transfers_ytd,
    rpt.total_operating_expenditures_period,
    rpt.total_operating_expenditures_ytd,
    rpt.total_receipts_period,
    rpt.total_receipts_ytd,
    rpt.transfers_from_affiliated_party_period,
    rpt.transfers_from_affiliated_party_ytd,
    rpt.transfers_from_nonfed_account_period,
    rpt.transfers_from_nonfed_account_ytd,
    rpt.transfers_from_nonfed_levin_period,
    rpt.transfers_from_nonfed_levin_ytd,
    rpt.transfers_to_affiliated_committee_period,
    rpt.transfers_to_affilitated_committees_ytd,
    rpt.form_tp,
    rpt.report_type,
    rpt.report_type_full,
    rpt.is_amended,
    rpt.receipt_date,
    rpt.file_number,
    rpt.amendment_indicator,
    rpt.amendment_indicator_full,
    rpt.means_filed,
    rpt.html_url,
    rpt.fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    public.is_most_recent((rpt.file_number)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (pac_party_report rpt
     LEFT JOIN public.ofec_filings_amendments_all_mv amendments ON ((rpt.file_number = amendments.file_num)))
  WITH DATA;

ALTER TABLE public.ofec_report_pac_party_all_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_reports_house_senate_mv AS
 SELECT row_number() OVER () AS idx,
    f3.cmte_id AS committee_id,
    f3.election_cycle AS cycle,
    f3.cvg_start_dt AS coverage_start_date,
    f3.cvg_end_dt AS coverage_end_date,
    f3.agr_amt_pers_contrib_gen AS aggregate_amount_personal_contributions_general,
    f3.agr_amt_contrib_pers_fund_prim AS aggregate_contributions_personal_funds_primary,
    f3.all_other_loans_per AS all_other_loans_period,
    f3.all_other_loans_ytd,
    f3.begin_image_num AS beginning_image_number,
    f3.cand_contb_per AS candidate_contribution_period,
    f3.cand_contb_ytd AS candidate_contribution_ytd,
    f3.coh_bop AS cash_on_hand_beginning_period,
    f3.coh_cop AS cash_on_hand_end_period,
    f3.debts_owed_by_cmte AS debts_owed_by_committee,
    f3.debts_owed_to_cmte AS debts_owed_to_committee,
    f3.end_image_num AS end_image_number,
    f3.grs_rcpt_auth_cmte_gen AS gross_receipt_authorized_committee_general,
    f3.grs_rcpt_auth_cmte_prim AS gross_receipt_authorized_committee_primary,
    f3.grs_rcpt_min_pers_contrib_gen AS gross_receipt_minus_personal_contribution_general,
    f3.grs_rcpt_min_pers_contrib_prim AS gross_receipt_minus_personal_contributions_primary,
    f3.indv_item_contb_per AS individual_itemized_contributions_period,
    f3.indv_unitem_contb_per AS individual_unitemized_contributions_period,
    f3.loan_repymts_cand_loans_per AS loan_repayments_candidate_loans_period,
    f3.loan_repymts_cand_loans_ytd AS loan_repayments_candidate_loans_ytd,
    f3.loan_repymts_other_loans_per AS loan_repayments_other_loans_period,
    f3.loan_repymts_other_loans_ytd AS loan_repayments_other_loans_ytd,
    f3.loans_made_by_cand_per AS loans_made_by_candidate_period,
    f3.loans_made_by_cand_ytd AS loans_made_by_candidate_ytd,
    f3.net_contb_per AS net_contributions_period,
    f3.net_contb_ytd AS net_contributions_ytd,
    f3.net_op_exp_per AS net_operating_expenditures_period,
    f3.net_op_exp_ytd AS net_operating_expenditures_ytd,
    f3.offsets_to_op_exp_per AS offsets_to_operating_expenditures_period,
    f3.offsets_to_op_exp_ytd AS offsets_to_operating_expenditures_ytd,
    f3.op_exp_per AS operating_expenditures_period,
    f3.op_exp_ytd AS operating_expenditures_ytd,
    f3.other_disb_per AS other_disbursements_period,
    f3.other_disb_ytd AS other_disbursements_ytd,
    f3.other_pol_cmte_contb_per AS other_political_committee_contributions_period,
    f3.other_pol_cmte_contb_ytd AS other_political_committee_contributions_ytd,
    f3.other_receipts_per AS other_receipts_period,
    f3.other_receipts_ytd,
    f3.pol_pty_cmte_contb_per AS political_party_committee_contributions_period,
    f3.pol_pty_cmte_contb_ytd AS political_party_committee_contributions_ytd,
    f3.ref_indv_contb_per AS refunded_individual_contributions_period,
    f3.ref_indv_contb_ytd AS refunded_individual_contributions_ytd,
    f3.ref_other_pol_cmte_contb_per AS refunded_other_political_committee_contributions_period,
    f3.ref_other_pol_cmte_contb_ytd AS refunded_other_political_committee_contributions_ytd,
    f3.ref_pol_pty_cmte_contb_per AS refunded_political_party_committee_contributions_period,
    f3.ref_pol_pty_cmte_contb_ytd AS refunded_political_party_committee_contributions_ytd,
    f3.ref_ttl_contb_col_ttl_ytd AS refunds_total_contributions_col_total_ytd,
    f3.subttl_per AS subtotal_period,
    f3.ttl_contb_ref_col_ttl_per AS total_contribution_refunds_col_total_period,
    f3.ttl_contb_ref_per AS total_contribution_refunds_period,
    f3.ttl_contb_ref_ytd AS total_contribution_refunds_ytd,
    f3.ttl_contb_column_ttl_per AS total_contributions_column_total_period,
    f3.ttl_contb_per AS total_contributions_period,
    f3.ttl_contb_ytd AS total_contributions_ytd,
    f3.ttl_disb_per AS total_disbursements_period,
    f3.ttl_disb_ytd AS total_disbursements_ytd,
    f3.ttl_indv_contb_per AS total_individual_contributions_period,
    f3.ttl_indv_contb_ytd AS total_individual_contributions_ytd,
    f3.ttl_indv_item_contb_ytd AS individual_itemized_contributions_ytd,
    f3.ttl_indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
    f3.ttl_loan_repymts_per AS total_loan_repayments_made_period,
    f3.ttl_loan_repymts_ytd AS total_loan_repayments_made_ytd,
    f3.ttl_loans_per AS total_loans_received_period,
    f3.ttl_loans_ytd AS total_loans_received_ytd,
    f3.ttl_offsets_to_op_exp_per AS total_offsets_to_operating_expenditures_period,
    f3.ttl_offsets_to_op_exp_ytd AS total_offsets_to_operating_expenditures_ytd,
    f3.ttl_op_exp_per AS total_operating_expenditures_period,
    f3.ttl_op_exp_ytd AS total_operating_expenditures_ytd,
    f3.ttl_receipts_per AS total_receipts_period,
    f3.ttl_receipts_ytd AS total_receipts_ytd,
    f3.tranf_from_other_auth_cmte_per AS transfers_from_other_authorized_committee_period,
    f3.tranf_from_other_auth_cmte_ytd AS transfers_from_other_authorized_committee_ytd,
    f3.tranf_to_other_auth_cmte_per AS transfers_to_other_authorized_committee_period,
    f3.tranf_to_other_auth_cmte_ytd AS transfers_to_other_authorized_committee_ytd,
    f3.rpt_tp AS report_type,
    f3.rpt_tp_desc AS report_type_full,
    f3.rpt_yr AS report_year,
    (f3.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
    f3.receipt_dt AS receipt_date,
    f3.file_num AS file_number,
    f3.amndt_ind AS amendment_indicator,
    f3.amndt_ind_desc AS amendment_indicator_full,
    public.means_filed((f3.begin_image_num)::text) AS means_filed,
    public.report_html_url(public.means_filed((f3.begin_image_num)::text), (f3.cmte_id)::text, (f3.file_num)::text) AS html_url,
    public.report_fec_url((f3.begin_image_num)::text, (f3.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    public.is_most_recent((f3.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (public.fec_vsum_f3_vw f3
     LEFT JOIN ( SELECT ofec_amendments_mv.idx,
            ofec_amendments_mv.cand_cmte_id,
            ofec_amendments_mv.rpt_yr,
            ofec_amendments_mv.rpt_tp,
            ofec_amendments_mv.amndt_ind,
            ofec_amendments_mv.receipt_date,
            ofec_amendments_mv.file_num,
            ofec_amendments_mv.prev_file_num,
            ofec_amendments_mv.mst_rct_file_num,
            ofec_amendments_mv.amendment_chain
           FROM public.ofec_amendments_mv
        UNION ALL
         SELECT ofec_house_senate_paper_amendments_mv.idx,
            ofec_house_senate_paper_amendments_mv.cmte_id,
            ofec_house_senate_paper_amendments_mv.rpt_yr,
            ofec_house_senate_paper_amendments_mv.rpt_tp,
            ofec_house_senate_paper_amendments_mv.amndt_ind,
            ofec_house_senate_paper_amendments_mv.receipt_dt,
            ofec_house_senate_paper_amendments_mv.file_num,
            ofec_house_senate_paper_amendments_mv.prev_file_num,
            ofec_house_senate_paper_amendments_mv.mst_rct_file_num,
            ofec_house_senate_paper_amendments_mv.amendment_chain
           FROM public.ofec_house_senate_paper_amendments_mv) amendments ON ((f3.file_num = amendments.file_num)))
  WHERE (f3.election_cycle >= (1979)::numeric)
  WITH DATA;

ALTER TABLE public.ofec_reports_house_senate_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_reports_pacs_parties_mv AS
 SELECT row_number() OVER () AS idx,
    f3x.cmte_id AS committee_id,
    f3x.election_cycle AS cycle,
    f3x.cvg_start_dt AS coverage_start_date,
    f3x.cvg_end_dt AS coverage_end_date,
    f3x.all_loans_received_per AS all_loans_received_period,
    f3x.all_loans_received_ytd,
    f3x.shared_fed_actvy_nonfed_per AS allocated_federal_election_levin_share_period,
    f3x.begin_image_num AS beginning_image_number,
    f3x.calendar_yr AS calendar_ytd,
    f3x.coh_begin_calendar_yr AS cash_on_hand_beginning_calendar_ytd,
    f3x.coh_bop AS cash_on_hand_beginning_period,
    f3x.coh_coy AS cash_on_hand_close_ytd,
    f3x.coh_cop AS cash_on_hand_end_period,
    f3x.coord_exp_by_pty_cmte_per AS coordinated_expenditures_by_party_committee_period,
    f3x.coord_exp_by_pty_cmte_ytd AS coordinated_expenditures_by_party_committee_ytd,
    f3x.debts_owed_by_cmte AS debts_owed_by_committee,
    f3x.debts_owed_to_cmte AS debts_owed_to_committee,
    f3x.end_image_num AS end_image_number,
    f3x.fed_cand_cmte_contb_ref_ytd AS fed_candidate_committee_contribution_refunds_ytd,
    f3x.fed_cand_cmte_contb_per AS fed_candidate_committee_contributions_period,
    f3x.fed_cand_cmte_contb_ytd AS fed_candidate_committee_contributions_ytd,
    f3x.fed_cand_contb_ref_per AS fed_candidate_contribution_refunds_period,
    f3x.indt_exp_per AS independent_expenditures_period,
    f3x.indt_exp_ytd AS independent_expenditures_ytd,
    f3x.indv_contb_ref_per AS refunded_individual_contributions_period,
    f3x.indv_contb_ref_ytd AS refunded_individual_contributions_ytd,
    f3x.indv_item_contb_per AS individual_itemized_contributions_period,
    f3x.indv_item_contb_ytd AS individual_itemized_contributions_ytd,
    f3x.indv_unitem_contb_per AS individual_unitemized_contributions_period,
    f3x.indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
    f3x.loan_repymts_made_per AS loan_repayments_made_period,
    f3x.loan_repymts_made_ytd AS loan_repayments_made_ytd,
    f3x.loan_repymts_received_per AS loan_repayments_received_period,
    f3x.loan_repymts_received_ytd AS loan_repayments_received_ytd,
    f3x.loans_made_per AS loans_made_period,
    f3x.loans_made_ytd,
    f3x.net_contb_per AS net_contributions_period,
    f3x.net_contb_ytd AS net_contributions_ytd,
    f3x.net_op_exp_per AS net_operating_expenditures_period,
    f3x.net_op_exp_ytd AS net_operating_expenditures_ytd,
    f3x.non_alloc_fed_elect_actvy_per AS non_allocated_fed_election_activity_period,
    f3x.non_alloc_fed_elect_actvy_ytd AS non_allocated_fed_election_activity_ytd,
    f3x.shared_nonfed_op_exp_per AS nonfed_share_allocated_disbursements_period,
    f3x.offests_to_op_exp AS offsets_to_operating_expenditures_period,
    f3x.offsets_to_op_exp_ytd_i AS offsets_to_operating_expenditures_ytd,
    f3x.other_disb_per AS other_disbursements_period,
    f3x.other_disb_ytd AS other_disbursements_ytd,
    f3x.other_fed_op_exp_per AS other_fed_operating_expenditures_period,
    f3x.other_fed_op_exp_ytd AS other_fed_operating_expenditures_ytd,
    f3x.other_fed_receipts_per AS other_fed_receipts_period,
    f3x.other_fed_receipts_ytd,
    f3x.other_pol_cmte_refund AS refunded_other_political_committee_contributions_period,
    f3x.other_pol_cmte_refund_ytd AS refunded_other_political_committee_contributions_ytd,
    f3x.other_pol_cmte_contb_per_i AS other_political_committee_contributions_period,
    f3x.other_pol_cmte_contb_ytd_i AS other_political_committee_contributions_ytd,
    f3x.pol_pty_cmte_refund AS refunded_political_party_committee_contributions_period,
    f3x.pol_pty_cmte_refund_ytd AS refunded_political_party_committee_contributions_ytd,
    f3x.pol_pty_cmte_contb_per_i AS political_party_committee_contributions_period,
    f3x.pol_pty_cmte_contb_ytd_i AS political_party_committee_contributions_ytd,
    f3x.rpt_yr AS report_year,
    f3x.shared_fed_actvy_nonfed_ytd AS shared_fed_activity_nonfed_ytd,
    f3x.shared_fed_actvy_fed_shr_per AS shared_fed_activity_period,
    f3x.shared_fed_actvy_fed_shr_ytd AS shared_fed_activity_ytd,
    f3x.shared_fed_op_exp_per AS shared_fed_operating_expenditures_period,
    f3x.shared_fed_op_exp_ytd AS shared_fed_operating_expenditures_ytd,
    f3x.shared_nonfed_op_exp_per AS shared_nonfed_operating_expenditures_period,
    f3x.shared_nonfed_op_exp_ytd AS shared_nonfed_operating_expenditures_ytd,
    f3x.subttl_sum_page_per AS subtotal_summary_page_period,
    f3x.subttl_sum_ytd AS subtotal_summary_ytd,
    f3x.ttl_contb_refund AS total_contribution_refunds_period,
    f3x.ttl_contb_refund_ytd AS total_contribution_refunds_ytd,
    f3x.ttl_contb_per AS total_contributions_period,
    f3x.ttl_contb_ytd AS total_contributions_ytd,
    f3x.ttl_disb AS total_disbursements_period,
    f3x.ttl_disb_ytd AS total_disbursements_ytd,
    f3x.ttl_fed_disb_per AS total_fed_disbursements_period,
    f3x.ttl_fed_disb_ytd AS total_fed_disbursements_ytd,
    f3x.ttl_fed_elect_actvy_per AS total_fed_election_activity_period,
    f3x.ttl_fed_elect_actvy_ytd AS total_fed_election_activity_ytd,
    f3x.ttl_fed_op_exp_per AS total_fed_operating_expenditures_period,
    f3x.ttl_fed_op_exp_ytd AS total_fed_operating_expenditures_ytd,
    f3x.ttl_fed_receipts_per AS total_fed_receipts_period,
    f3x.ttl_fed_receipts_ytd AS total_fed_receipts_ytd,
    f3x.ttl_indv_contb AS total_individual_contributions_period,
    f3x.ttl_indv_contb_ytd AS total_individual_contributions_ytd,
    f3x.ttl_nonfed_tranf_per AS total_nonfed_transfers_period,
    f3x.ttl_nonfed_tranf_ytd AS total_nonfed_transfers_ytd,
    f3x.ttl_op_exp_per AS total_operating_expenditures_period,
    f3x.ttl_op_exp_ytd AS total_operating_expenditures_ytd,
    f3x.ttl_receipts AS total_receipts_period,
    f3x.ttl_receipts_ytd AS total_receipts_ytd,
    f3x.tranf_from_affiliated_pty_per AS transfers_from_affiliated_party_period,
    f3x.tranf_from_affiliated_pty_ytd AS transfers_from_affiliated_party_ytd,
    f3x.tranf_from_nonfed_acct_per AS transfers_from_nonfed_account_period,
    f3x.tranf_from_nonfed_acct_ytd AS transfers_from_nonfed_account_ytd,
    f3x.tranf_from_nonfed_levin_per AS transfers_from_nonfed_levin_period,
    f3x.tranf_from_nonfed_levin_ytd AS transfers_from_nonfed_levin_ytd,
    f3x.tranf_to_affliliated_cmte_per AS transfers_to_affiliated_committee_period,
    f3x.tranf_to_affilitated_cmte_ytd AS transfers_to_affilitated_committees_ytd,
    f3x.rpt_tp AS report_type,
    f3x.rpt_tp_desc AS report_type_full,
    (f3x.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
    f3x.receipt_dt AS receipt_date,
    f3x.file_num AS file_number,
    f3x.amndt_ind AS amendment_indicator,
    f3x.amndt_ind_desc AS amendment_indicator_full,
    public.means_filed((f3x.begin_image_num)::text) AS means_filed,
    public.report_html_url(public.means_filed((f3x.begin_image_num)::text), (f3x.cmte_id)::text, (f3x.file_num)::text) AS html_url,
    public.report_fec_url((f3x.begin_image_num)::text, (f3x.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    public.is_most_recent((f3x.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (public.fec_vsum_f3x_vw f3x
     LEFT JOIN ( SELECT ofec_amendments_mv.idx,
            ofec_amendments_mv.cand_cmte_id,
            ofec_amendments_mv.rpt_yr,
            ofec_amendments_mv.rpt_tp,
            ofec_amendments_mv.amndt_ind,
            ofec_amendments_mv.receipt_date,
            ofec_amendments_mv.file_num,
            ofec_amendments_mv.prev_file_num,
            ofec_amendments_mv.mst_rct_file_num,
            ofec_amendments_mv.amendment_chain
           FROM public.ofec_amendments_mv
        UNION ALL
         SELECT ofec_pac_party_paper_amendments_mv.idx,
            ofec_pac_party_paper_amendments_mv.cmte_id,
            ofec_pac_party_paper_amendments_mv.rpt_yr,
            ofec_pac_party_paper_amendments_mv.rpt_tp,
            ofec_pac_party_paper_amendments_mv.amndt_ind,
            ofec_pac_party_paper_amendments_mv.receipt_dt,
            ofec_pac_party_paper_amendments_mv.file_num,
            ofec_pac_party_paper_amendments_mv.prev_file_num,
            ofec_pac_party_paper_amendments_mv.mst_rct_file_num,
            ofec_pac_party_paper_amendments_mv.amendment_chain
           FROM public.ofec_pac_party_paper_amendments_mv) amendments ON ((f3x.file_num = amendments.file_num)))
  WHERE (f3x.election_cycle >= (1979)::numeric)
  WITH DATA;

ALTER TABLE public.ofec_reports_pacs_parties_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_reports_presidential_mv AS
 SELECT row_number() OVER () AS idx,
    f3p.cmte_id AS committee_id,
    f3p.election_cycle AS cycle,
    f3p.cvg_start_dt AS coverage_start_date,
    f3p.cvg_end_dt AS coverage_end_date,
    f3p.begin_image_num AS beginning_image_number,
    f3p.cand_contb_per AS candidate_contribution_period,
    f3p.cand_contb_ytd AS candidate_contribution_ytd,
    f3p.coh_bop AS cash_on_hand_beginning_period,
    f3p.coh_cop AS cash_on_hand_end_period,
    f3p.debts_owed_by_cmte AS debts_owed_by_committee,
    f3p.debts_owed_to_cmte AS debts_owed_to_committee,
    f3p.end_image_num AS end_image_number,
    f3p.exempt_legal_acctg_disb_per AS exempt_legal_accounting_disbursement_period,
    f3p.exempt_legal_acctg_disb_ytd AS exempt_legal_accounting_disbursement_ytd,
    f3p.exp_subject_limits AS expenditure_subject_to_limits,
    f3p.fed_funds_per AS federal_funds_period,
    f3p.fed_funds_ytd AS federal_funds_ytd,
    f3p.fndrsg_disb_per AS fundraising_disbursements_period,
    f3p.fndrsg_disb_ytd AS fundraising_disbursements_ytd,
    f3p.indv_unitem_contb_per AS individual_unitemized_contributions_period,
    f3p.indv_unitem_contb_ytd AS individual_unitemized_contributions_ytd,
    f3p.indv_item_contb_per AS individual_itemized_contributions_period,
    f3p.indv_item_contb_ytd AS individual_itemized_contributions_ytd,
    f3p.ttl_indiv_contb_per AS total_individual_contributions_period,
    f3p.indv_contb_ytd AS total_individual_contributions_ytd,
    f3p.items_on_hand_liquidated,
    f3p.loans_received_from_cand_per AS loans_received_from_candidate_period,
    f3p.loans_received_from_cand_ytd AS loans_received_from_candidate_ytd,
    f3p.net_contb_sum_page_per AS net_contributions_cycle_to_date,
    f3p.net_op_exp_sum_page_per AS net_operating_expenditures_cycle_to_date,
    f3p.offsets_to_fndrsg_exp_ytd AS offsets_to_fundraising_exp_ytd,
    f3p.offsets_to_fndrsg_exp_per AS offsets_to_fundraising_expenditures_period,
    f3p.offsets_to_fndrsg_exp_ytd AS offsets_to_fundraising_expenditures_ytd,
    f3p.offsets_to_legal_acctg_per AS offsets_to_legal_accounting_period,
    f3p.offsets_to_legal_acctg_ytd AS offsets_to_legal_accounting_ytd,
    f3p.offsets_to_op_exp_per AS offsets_to_operating_expenditures_period,
    f3p.offsets_to_op_exp_ytd AS offsets_to_operating_expenditures_ytd,
    f3p.op_exp_per AS operating_expenditures_period,
    f3p.op_exp_ytd AS operating_expenditures_ytd,
    f3p.other_disb_per AS other_disbursements_period,
    f3p.other_disb_ytd AS other_disbursements_ytd,
    f3p.other_loans_received_per AS other_loans_received_period,
    f3p.other_loans_received_ytd,
    f3p.other_pol_cmte_contb_per AS other_political_committee_contributions_period,
    f3p.other_pol_cmte_contb_ytd AS other_political_committee_contributions_ytd,
    f3p.other_receipts_per AS other_receipts_period,
    f3p.other_receipts_ytd,
    f3p.pol_pty_cmte_contb_per AS political_party_committee_contributions_period,
    f3p.pol_pty_cmte_contb_ytd AS political_party_committee_contributions_ytd,
    f3p.ref_indv_contb_per AS refunded_individual_contributions_period,
    f3p.ref_indv_contb_ytd AS refunded_individual_contributions_ytd,
    f3p.ref_other_pol_cmte_contb_per AS refunded_other_political_committee_contributions_period,
    f3p.ref_other_pol_cmte_contb_ytd AS refunded_other_political_committee_contributions_ytd,
    f3p.ref_pol_pty_cmte_contb_per AS refunded_political_party_committee_contributions_period,
    f3p.ref_pol_pty_cmte_contb_ytd AS refunded_political_party_committee_contributions_ytd,
    f3p.repymts_loans_made_by_cand_per AS repayments_loans_made_by_candidate_period,
    f3p.repymts_loans_made_cand_ytd AS repayments_loans_made_candidate_ytd,
    f3p.repymts_other_loans_per AS repayments_other_loans_period,
    f3p.repymts_other_loans_ytd AS repayments_other_loans_ytd,
    f3p.rpt_yr AS report_year,
    f3p.subttl_sum_page_per AS subtotal_summary_period,
    f3p.ttl_contb_ref_per AS total_contribution_refunds_period,
    f3p.ttl_contb_ref_ytd AS total_contribution_refunds_ytd,
    f3p.ttl_contb_per AS total_contributions_period,
    f3p.ttl_contb_ytd AS total_contributions_ytd,
    f3p.ttl_disb_per AS total_disbursements_period,
    f3p.ttl_disb_ytd AS total_disbursements_ytd,
    f3p.ttl_loan_repymts_made_per AS total_loan_repayments_made_period,
    f3p.ttl_loan_repymts_made_ytd AS total_loan_repayments_made_ytd,
    f3p.ttl_loans_received_per AS total_loans_received_period,
    f3p.ttl_loans_received_ytd AS total_loans_received_ytd,
    f3p.ttl_offsets_to_op_exp_per AS total_offsets_to_operating_expenditures_period,
    f3p.ttl_offsets_to_op_exp_ytd AS total_offsets_to_operating_expenditures_ytd,
    f3p.ttl_per AS total_period,
    f3p.ttl_receipts_per AS total_receipts_period,
    f3p.ttl_receipts_ytd AS total_receipts_ytd,
    f3p.ttl_ytd AS total_ytd,
    f3p.tranf_from_affilated_cmte_per AS transfers_from_affiliated_committee_period,
    f3p.tranf_from_affiliated_cmte_ytd AS transfers_from_affiliated_committee_ytd,
    f3p.tranf_to_other_auth_cmte_per AS transfers_to_other_authorized_committee_period,
    f3p.tranf_to_other_auth_cmte_ytd AS transfers_to_other_authorized_committee_ytd,
    f3p.rpt_tp AS report_type,
    f3p.rpt_tp_desc AS report_type_full,
    (f3p.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
    f3p.receipt_dt AS receipt_date,
    f3p.file_num AS file_number,
    f3p.amndt_ind AS amendment_indicator,
    f3p.amndt_ind_desc AS amendment_indicator_full,
    public.means_filed((f3p.begin_image_num)::text) AS means_filed,
    public.report_html_url(public.means_filed((f3p.begin_image_num)::text), (f3p.cmte_id)::text, (f3p.file_num)::text) AS html_url,
    public.report_fec_url((f3p.begin_image_num)::text, (f3p.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    public.is_most_recent((f3p.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (public.fec_vsum_f3p_vw f3p
     LEFT JOIN ( SELECT ofec_amendments_mv.idx,
            ofec_amendments_mv.cand_cmte_id,
            ofec_amendments_mv.rpt_yr,
            ofec_amendments_mv.rpt_tp,
            ofec_amendments_mv.amndt_ind,
            ofec_amendments_mv.receipt_date,
            ofec_amendments_mv.file_num,
            ofec_amendments_mv.prev_file_num,
            ofec_amendments_mv.mst_rct_file_num,
            ofec_amendments_mv.amendment_chain
           FROM public.ofec_amendments_mv
        UNION ALL
         SELECT ofec_presidential_paper_amendments_mv.idx,
            ofec_presidential_paper_amendments_mv.cmte_id,
            ofec_presidential_paper_amendments_mv.rpt_yr,
            ofec_presidential_paper_amendments_mv.rpt_tp,
            ofec_presidential_paper_amendments_mv.amndt_ind,
            ofec_presidential_paper_amendments_mv.receipt_dt,
            ofec_presidential_paper_amendments_mv.file_num,
            ofec_presidential_paper_amendments_mv.prev_file_num,
            ofec_presidential_paper_amendments_mv.mst_rct_file_num,
            ofec_presidential_paper_amendments_mv.amendment_chain
           FROM public.ofec_presidential_paper_amendments_mv) amendments ON ((f3p.file_num = amendments.file_num)))
  WHERE (f3p.election_cycle >= (1979)::numeric)
  WITH DATA;

ALTER TABLE public.ofec_reports_presidential_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_size_merged_mv AS
 WITH grouped AS (
         SELECT ofec_totals_combined_mv.committee_id AS cmte_id,
            ofec_totals_combined_mv.cycle,
            0 AS size,
            ofec_totals_combined_mv.individual_unitemized_contributions AS total,
            0 AS count
           FROM public.ofec_totals_combined_mv
          WHERE (ofec_totals_combined_mv.cycle >= 2007)
        UNION ALL
         SELECT sched_a_aggregate_size.cmte_id,
            sched_a_aggregate_size.cycle,
            sched_a_aggregate_size.size,
            sched_a_aggregate_size.total,
            sched_a_aggregate_size.count
           FROM disclosure.dsc_sched_a_aggregate_size sched_a_aggregate_size
        )
 SELECT row_number() OVER () AS idx,
    grouped.cmte_id,
    grouped.cycle,
    grouped.size,
    sum(grouped.total) AS total,
        CASE
            WHEN (grouped.size = 0) THEN NULL::numeric
            ELSE sum(grouped.count)
        END AS count
   FROM grouped
  GROUP BY grouped.cmte_id, grouped.cycle, grouped.size
  WITH DATA;

ALTER TABLE public.ofec_sched_a_aggregate_size_merged_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_candidate_committees_mv AS
 WITH last_cycle AS (
         SELECT DISTINCT ON (v_sum.cmte_id, link.fec_election_yr) v_sum.cmte_id,
            v_sum.rpt_yr AS report_year,
            v_sum.coh_cop AS cash_on_hand_end_period,
            v_sum.net_op_exp AS net_operating_expenditures,
            v_sum.net_contb AS net_contributions,
                CASE
                    WHEN (v_sum.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            ((v_sum.cvg_end_dt)::text)::timestamp without time zone AS coverage_end_date,
            trans_date.transaction_coverage_date,
            v_sum.debts_owed_by_cmte AS debts_owed_by_committee,
            v_sum.debts_owed_to_cmte AS debts_owed_to_committee,
            of.report_type_full,
            of.beginning_image_number,
            link.cand_id AS candidate_id,
            link.fec_election_yr AS cycle,
            link.cand_election_yr AS election_year
           FROM (((disclosure.v_sum_and_det_sum_report v_sum
             LEFT JOIN public.ofec_cand_cmte_linkage_mv link USING (cmte_id))
             LEFT JOIN public.ofec_filings_mv of ON ((of.sub_id = v_sum.orig_sub_id)))
             LEFT JOIN public.ofec_agg_coverage_date_mv trans_date ON ((((link.cmte_id)::text = (trans_date.committee_id)::text) AND (link.fec_election_yr = trans_date.fec_election_yr))))
          WHERE ((((v_sum.form_tp_cd)::text = 'F3P'::text) OR ((v_sum.form_tp_cd)::text = 'F3'::text)) AND (((link.cmte_dsgn)::text = 'A'::text) OR ((link.cmte_dsgn)::text = 'P'::text)) AND (v_sum.cvg_end_dt <> (99999999)::numeric) AND (link.fec_election_yr = (public.get_cycle(((date_part('year'::text, ((v_sum.cvg_end_dt)::text)::timestamp without time zone))::integer)::numeric))::numeric) AND (link.fec_election_yr >= (1979)::numeric))
          ORDER BY v_sum.cmte_id, link.fec_election_yr, v_sum.cvg_end_dt DESC NULLS LAST
        ), ending_totals_per_cycle AS (
         SELECT last.cycle,
            last.candidate_id,
            max(last.coverage_end_date) AS coverage_end_date,
            max(last.transaction_coverage_date) AS transaction_coverage_date,
            min(last.coverage_start_date) AS coverage_start_date,
            max((last.report_type_full)::text) AS last_report_type_full,
            max(last.beginning_image_number) AS last_beginning_image_number,
            sum(last.cash_on_hand_end_period) AS last_cash_on_hand_end_period,
            sum(last.debts_owed_by_committee) AS last_debts_owed_by_committee,
            sum(last.debts_owed_to_committee) AS last_debts_owed_to_committee,
            max(last.report_year) AS last_report_year,
            sum(last.net_operating_expenditures) AS last_net_operating_expenditures,
            sum(last.net_contributions) AS last_net_contributions
           FROM last_cycle last
          GROUP BY last.cycle, last.candidate_id
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, link.fec_election_yr) link.cand_id AS candidate_id,
            link.fec_election_yr AS cycle,
            max(link.fec_election_yr) AS election_year,
            min(((p.cvg_start_dt)::text)::timestamp without time zone) AS coverage_start_date,
            sum(p.cand_cntb) AS candidate_contribution,
            sum(p.ttl_contb_ref) AS contribution_refunds,
            sum(p.ttl_contb) AS contributions,
            sum(p.ttl_disb) AS disbursements,
            sum(p.exempt_legal_acctg_disb) AS exempt_legal_accounting_disbursement,
            sum(p.fed_funds_per) AS federal_funds,
            (sum(p.fed_funds_per) > (0)::numeric) AS federal_funds_flag,
            sum(p.fndrsg_disb) AS fundraising_disbursements,
            sum(p.indv_contb) AS individual_contributions,
            sum(p.indv_unitem_contb) AS individual_unitemized_contributions,
            sum(p.indv_item_contb) AS individual_itemized_contributions,
            sum(p.ttl_loans) AS loans_received,
            sum(p.cand_loan) AS loans_received_from_candidate,
            sum((p.cand_loan_repymnt + p.oth_loan_repymts)) AS loan_repayments_made,
            sum(p.offsets_to_fndrsg) AS offsets_to_fundraising_expenditures,
            sum(p.offsets_to_legal_acctg) AS offsets_to_legal_accounting,
            sum(p.offsets_to_op_exp) AS offsets_to_operating_expenditures,
            sum(((p.offsets_to_op_exp + p.offsets_to_fndrsg) + p.offsets_to_legal_acctg)) AS total_offsets_to_operating_expenditures,
            sum(p.op_exp_per) AS operating_expenditures,
            sum(p.other_disb_per) AS other_disbursements,
            sum(p.oth_loans) AS other_loans_received,
            sum(p.oth_cmte_contb) AS other_political_committee_contributions,
            sum(p.other_receipts) AS other_receipts,
            sum(p.pty_cmte_contb) AS political_party_committee_contributions,
            sum(p.ttl_receipts) AS receipts,
            sum(p.indv_ref) AS refunded_individual_contributions,
            sum(p.oth_cmte_ref) AS refunded_other_political_committee_contributions,
            sum(p.pol_pty_cmte_contb) AS refunded_political_party_committee_contributions,
            sum(p.cand_loan_repymnt) AS repayments_loans_made_by_candidate,
            sum(p.oth_loan_repymts) AS repayments_other_loans,
            sum(p.tranf_from_other_auth_cmte) AS transfers_from_affiliated_committee,
            sum(p.tranf_to_other_auth_cmte) AS transfers_to_other_authorized_committee,
            sum(p.net_op_exp) AS net_operating_expenditures,
            sum(p.net_contb) AS net_contributions,
            false AS full_election
           FROM (public.ofec_cand_cmte_linkage_mv link
             LEFT JOIN disclosure.v_sum_and_det_sum_report p ON ((((link.cmte_id)::text = (p.cmte_id)::text) AND (link.fec_election_yr = (public.get_cycle(p.rpt_yr))::numeric))))
          WHERE ((link.fec_election_yr >= (1979)::numeric) AND (p.cvg_start_dt <> (99999999)::numeric) AND (((p.form_tp_cd)::text = 'F3P'::text) OR ((p.form_tp_cd)::text = 'F3'::text)) AND (((link.cmte_dsgn)::text = 'A'::text) OR ((link.cmte_dsgn)::text = 'P'::text)))
          GROUP BY link.fec_election_yr, link.cand_election_yr, link.cand_id
        ), cycle_totals_with_ending_aggregates AS (
         SELECT cycle_totals.candidate_id,
            cycle_totals.cycle,
            cycle_totals.election_year,
            cycle_totals.coverage_start_date,
            cycle_totals.candidate_contribution,
            cycle_totals.contribution_refunds,
            cycle_totals.contributions,
            cycle_totals.disbursements,
            cycle_totals.exempt_legal_accounting_disbursement,
            cycle_totals.federal_funds,
            cycle_totals.federal_funds_flag,
            cycle_totals.fundraising_disbursements,
            cycle_totals.individual_contributions,
            cycle_totals.individual_unitemized_contributions,
            cycle_totals.individual_itemized_contributions,
            cycle_totals.loans_received,
            cycle_totals.loans_received_from_candidate,
            cycle_totals.loan_repayments_made,
            cycle_totals.offsets_to_fundraising_expenditures,
            cycle_totals.offsets_to_legal_accounting,
            cycle_totals.offsets_to_operating_expenditures,
            cycle_totals.total_offsets_to_operating_expenditures,
            cycle_totals.operating_expenditures,
            cycle_totals.other_disbursements,
            cycle_totals.other_loans_received,
            cycle_totals.other_political_committee_contributions,
            cycle_totals.other_receipts,
            cycle_totals.political_party_committee_contributions,
            cycle_totals.receipts,
            cycle_totals.refunded_individual_contributions,
            cycle_totals.refunded_other_political_committee_contributions,
            cycle_totals.refunded_political_party_committee_contributions,
            cycle_totals.repayments_loans_made_by_candidate,
            cycle_totals.repayments_other_loans,
            cycle_totals.transfers_from_affiliated_committee,
            cycle_totals.transfers_to_other_authorized_committee,
            cycle_totals.net_operating_expenditures,
            cycle_totals.net_contributions,
            cycle_totals.full_election,
            ending_totals.coverage_end_date,
            ending_totals.transaction_coverage_date,
            ending_totals.last_report_type_full,
            ending_totals.last_beginning_image_number,
            ending_totals.last_cash_on_hand_end_period,
            ending_totals.last_debts_owed_by_committee,
            ending_totals.last_debts_owed_to_committee,
            ending_totals.last_report_year,
            ending_totals.last_net_operating_expenditures,
            ending_totals.last_net_contributions
           FROM (cycle_totals cycle_totals
             LEFT JOIN ending_totals_per_cycle ending_totals ON (((ending_totals.cycle = cycle_totals.cycle) AND ((ending_totals.candidate_id)::text = (cycle_totals.candidate_id)::text))))
        ), election_totals AS (
         SELECT totals.candidate_id,
            max(totals.cycle) AS cycle,
            max(totals.election_year) AS election_year,
            min(totals.coverage_start_date) AS coverage_start_date,
            sum(totals.candidate_contribution) AS candidate_contribution,
            sum(totals.contribution_refunds) AS contribution_refunds,
            sum(totals.contributions) AS contributions,
            sum(totals.disbursements) AS disbursements,
            sum(totals.exempt_legal_accounting_disbursement) AS exempt_legal_accounting_disbursement,
            sum(totals.federal_funds) AS federal_funds,
            (sum(totals.federal_funds) > (0)::numeric) AS federal_funds_flag,
            sum(totals.fundraising_disbursements) AS fundraising_disbursements,
            sum(totals.individual_contributions) AS individual_contributions,
            sum(totals.individual_unitemized_contributions) AS individual_unitemized_contributions,
            sum(totals.individual_itemized_contributions) AS individual_itemized_contributions,
            sum(totals.loans_received) AS loans_received,
            sum(totals.loans_received_from_candidate) AS loans_received_from_candidate,
            sum(totals.loan_repayments_made) AS loan_repayments_made,
            sum(totals.offsets_to_fundraising_expenditures) AS offsets_to_fundraising_expenditures,
            sum(totals.offsets_to_legal_accounting) AS offsets_to_legal_accounting,
            sum(totals.offsets_to_operating_expenditures) AS offsets_to_operating_expenditures,
            sum(totals.total_offsets_to_operating_expenditures) AS total_offsets_to_operating_expenditures,
            sum(totals.operating_expenditures) AS operating_expenditures,
            sum(totals.other_disbursements) AS other_disbursements,
            sum(totals.other_loans_received) AS other_loans_received,
            sum(totals.other_political_committee_contributions) AS other_political_committee_contributions,
            sum(totals.other_receipts) AS other_receipts,
            sum(totals.political_party_committee_contributions) AS political_party_committee_contributions,
            sum(totals.receipts) AS receipts,
            sum(totals.refunded_individual_contributions) AS refunded_individual_contributions,
            sum(totals.refunded_other_political_committee_contributions) AS refunded_other_political_committee_contributions,
            sum(totals.refunded_political_party_committee_contributions) AS refunded_political_party_committee_contributions,
            sum(totals.repayments_loans_made_by_candidate) AS repayments_loans_made_by_candidate,
            sum(totals.repayments_other_loans) AS repayments_other_loans,
            sum(totals.transfers_from_affiliated_committee) AS transfers_from_affiliated_committee,
            sum(totals.transfers_to_other_authorized_committee) AS transfers_to_other_authorized_committee,
            sum(totals.net_operating_expenditures) AS net_operating_expenditures,
            sum(totals.net_contributions) AS net_contributions,
            true AS full_election,
            max(totals.coverage_end_date) AS coverage_end_date,
            max(totals.transaction_coverage_date) AS transaction_coverage_date
           FROM (cycle_totals_with_ending_aggregates totals
             LEFT JOIN public.ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle <= (election.cand_election_year)::numeric) AND (totals.cycle > (election.prev_election_year)::numeric))))
          GROUP BY totals.candidate_id, election.cand_election_year
        ), election_totals_with_ending_aggregates AS (
         SELECT et.candidate_id,
            et.cycle,
            et.election_year,
            et.coverage_start_date,
            et.candidate_contribution,
            et.contribution_refunds,
            et.contributions,
            et.disbursements,
            et.exempt_legal_accounting_disbursement,
            et.federal_funds,
            et.federal_funds_flag,
            et.fundraising_disbursements,
            et.individual_contributions,
            et.individual_unitemized_contributions,
            et.individual_itemized_contributions,
            et.loans_received,
            et.loans_received_from_candidate,
            et.loan_repayments_made,
            et.offsets_to_fundraising_expenditures,
            et.offsets_to_legal_accounting,
            et.offsets_to_operating_expenditures,
            et.total_offsets_to_operating_expenditures,
            et.operating_expenditures,
            et.other_disbursements,
            et.other_loans_received,
            et.other_political_committee_contributions,
            et.other_receipts,
            et.political_party_committee_contributions,
            et.receipts,
            et.refunded_individual_contributions,
            et.refunded_other_political_committee_contributions,
            et.refunded_political_party_committee_contributions,
            et.repayments_loans_made_by_candidate,
            et.repayments_other_loans,
            et.transfers_from_affiliated_committee,
            et.transfers_to_other_authorized_committee,
            et.net_operating_expenditures,
            et.net_contributions,
            et.full_election,
            et.coverage_end_date,
            et.transaction_coverage_date,
            totals.last_report_type_full,
            totals.last_beginning_image_number,
            totals.last_cash_on_hand_end_period,
            totals.last_debts_owed_by_committee,
            totals.last_debts_owed_to_committee,
            totals.last_report_year,
            totals.last_net_operating_expenditures,
            totals.last_net_contributions
           FROM ((ending_totals_per_cycle totals
             LEFT JOIN public.ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle = (election.cand_election_year)::numeric))))
             LEFT JOIN election_totals et ON ((((totals.candidate_id)::text = (et.candidate_id)::text) AND (totals.cycle = et.cycle))))
          WHERE (totals.cycle > (1979)::numeric)
        )
 SELECT cycle_totals_with_ending_aggregates.candidate_id,
    cycle_totals_with_ending_aggregates.cycle,
    cycle_totals_with_ending_aggregates.election_year,
    cycle_totals_with_ending_aggregates.coverage_start_date,
    cycle_totals_with_ending_aggregates.candidate_contribution,
    cycle_totals_with_ending_aggregates.contribution_refunds,
    cycle_totals_with_ending_aggregates.contributions,
    cycle_totals_with_ending_aggregates.disbursements,
    cycle_totals_with_ending_aggregates.exempt_legal_accounting_disbursement,
    cycle_totals_with_ending_aggregates.federal_funds,
    cycle_totals_with_ending_aggregates.federal_funds_flag,
    cycle_totals_with_ending_aggregates.fundraising_disbursements,
    cycle_totals_with_ending_aggregates.individual_contributions,
    cycle_totals_with_ending_aggregates.individual_unitemized_contributions,
    cycle_totals_with_ending_aggregates.individual_itemized_contributions,
    cycle_totals_with_ending_aggregates.loans_received,
    cycle_totals_with_ending_aggregates.loans_received_from_candidate,
    cycle_totals_with_ending_aggregates.loan_repayments_made,
    cycle_totals_with_ending_aggregates.offsets_to_fundraising_expenditures,
    cycle_totals_with_ending_aggregates.offsets_to_legal_accounting,
    cycle_totals_with_ending_aggregates.offsets_to_operating_expenditures,
    cycle_totals_with_ending_aggregates.total_offsets_to_operating_expenditures,
    cycle_totals_with_ending_aggregates.operating_expenditures,
    cycle_totals_with_ending_aggregates.other_disbursements,
    cycle_totals_with_ending_aggregates.other_loans_received,
    cycle_totals_with_ending_aggregates.other_political_committee_contributions,
    cycle_totals_with_ending_aggregates.other_receipts,
    cycle_totals_with_ending_aggregates.political_party_committee_contributions,
    cycle_totals_with_ending_aggregates.receipts,
    cycle_totals_with_ending_aggregates.refunded_individual_contributions,
    cycle_totals_with_ending_aggregates.refunded_other_political_committee_contributions,
    cycle_totals_with_ending_aggregates.refunded_political_party_committee_contributions,
    cycle_totals_with_ending_aggregates.repayments_loans_made_by_candidate,
    cycle_totals_with_ending_aggregates.repayments_other_loans,
    cycle_totals_with_ending_aggregates.transfers_from_affiliated_committee,
    cycle_totals_with_ending_aggregates.transfers_to_other_authorized_committee,
    cycle_totals_with_ending_aggregates.net_operating_expenditures,
    cycle_totals_with_ending_aggregates.net_contributions,
    cycle_totals_with_ending_aggregates.full_election,
    cycle_totals_with_ending_aggregates.coverage_end_date,
    cycle_totals_with_ending_aggregates.transaction_coverage_date,
    cycle_totals_with_ending_aggregates.last_report_type_full,
    cycle_totals_with_ending_aggregates.last_beginning_image_number,
    cycle_totals_with_ending_aggregates.last_cash_on_hand_end_period,
    cycle_totals_with_ending_aggregates.last_debts_owed_by_committee,
    cycle_totals_with_ending_aggregates.last_debts_owed_to_committee,
    cycle_totals_with_ending_aggregates.last_report_year,
    cycle_totals_with_ending_aggregates.last_net_operating_expenditures,
    cycle_totals_with_ending_aggregates.last_net_contributions
   FROM cycle_totals_with_ending_aggregates
UNION ALL
 SELECT election_totals_with_ending_aggregates.candidate_id,
    election_totals_with_ending_aggregates.cycle,
    election_totals_with_ending_aggregates.election_year,
    election_totals_with_ending_aggregates.coverage_start_date,
    election_totals_with_ending_aggregates.candidate_contribution,
    election_totals_with_ending_aggregates.contribution_refunds,
    election_totals_with_ending_aggregates.contributions,
    election_totals_with_ending_aggregates.disbursements,
    election_totals_with_ending_aggregates.exempt_legal_accounting_disbursement,
    election_totals_with_ending_aggregates.federal_funds,
    election_totals_with_ending_aggregates.federal_funds_flag,
    election_totals_with_ending_aggregates.fundraising_disbursements,
    election_totals_with_ending_aggregates.individual_contributions,
    election_totals_with_ending_aggregates.individual_unitemized_contributions,
    election_totals_with_ending_aggregates.individual_itemized_contributions,
    election_totals_with_ending_aggregates.loans_received,
    election_totals_with_ending_aggregates.loans_received_from_candidate,
    election_totals_with_ending_aggregates.loan_repayments_made,
    election_totals_with_ending_aggregates.offsets_to_fundraising_expenditures,
    election_totals_with_ending_aggregates.offsets_to_legal_accounting,
    election_totals_with_ending_aggregates.offsets_to_operating_expenditures,
    election_totals_with_ending_aggregates.total_offsets_to_operating_expenditures,
    election_totals_with_ending_aggregates.operating_expenditures,
    election_totals_with_ending_aggregates.other_disbursements,
    election_totals_with_ending_aggregates.other_loans_received,
    election_totals_with_ending_aggregates.other_political_committee_contributions,
    election_totals_with_ending_aggregates.other_receipts,
    election_totals_with_ending_aggregates.political_party_committee_contributions,
    election_totals_with_ending_aggregates.receipts,
    election_totals_with_ending_aggregates.refunded_individual_contributions,
    election_totals_with_ending_aggregates.refunded_other_political_committee_contributions,
    election_totals_with_ending_aggregates.refunded_political_party_committee_contributions,
    election_totals_with_ending_aggregates.repayments_loans_made_by_candidate,
    election_totals_with_ending_aggregates.repayments_other_loans,
    election_totals_with_ending_aggregates.transfers_from_affiliated_committee,
    election_totals_with_ending_aggregates.transfers_to_other_authorized_committee,
    election_totals_with_ending_aggregates.net_operating_expenditures,
    election_totals_with_ending_aggregates.net_contributions,
    election_totals_with_ending_aggregates.full_election,
    election_totals_with_ending_aggregates.coverage_end_date,
    election_totals_with_ending_aggregates.transaction_coverage_date,
    election_totals_with_ending_aggregates.last_report_type_full,
    election_totals_with_ending_aggregates.last_beginning_image_number,
    election_totals_with_ending_aggregates.last_cash_on_hand_end_period,
    election_totals_with_ending_aggregates.last_debts_owed_by_committee,
    election_totals_with_ending_aggregates.last_debts_owed_to_committee,
    election_totals_with_ending_aggregates.last_report_year,
    election_totals_with_ending_aggregates.last_net_operating_expenditures,
    election_totals_with_ending_aggregates.last_net_contributions
   FROM election_totals_with_ending_aggregates
  WITH DATA;

ALTER TABLE public.ofec_totals_candidate_committees_mv OWNER TO fec;

CREATE MATERIALIZED VIEW public.ofec_totals_ie_only_mv AS
 SELECT ofec_totals_combined_mv.sub_id AS idx,
    ofec_totals_combined_mv.committee_id,
    ofec_totals_combined_mv.cycle,
    ofec_totals_combined_mv.coverage_start_date,
    ofec_totals_combined_mv.coverage_end_date,
    ofec_totals_combined_mv.contributions AS total_independent_contributions,
    ofec_totals_combined_mv.independent_expenditures AS total_independent_expenditures,
    ofec_totals_combined_mv.last_beginning_image_number,
    ofec_totals_combined_mv.committee_name,
    ofec_totals_combined_mv.committee_type,
    ofec_totals_combined_mv.committee_designation,
    ofec_totals_combined_mv.committee_type_full,
    ofec_totals_combined_mv.committee_designation_full,
    ofec_totals_combined_mv.party_full
   FROM public.ofec_totals_combined_mv
  WHERE ((ofec_totals_combined_mv.form_type)::text = 'F5'::text)
  WITH DATA;

ALTER TABLE public.ofec_totals_ie_only_mv OWNER TO fec;

CREATE INDEX ofec_candidate_flag_mv_candidate_id_idx ON public.ofec_candidate_flag_mv USING btree (candidate_id);

CREATE INDEX ofec_candidate_flag_mv_federal_funds_flag_idx ON public.ofec_candidate_flag_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_flag_mv_has_raised_funds_idx ON public.ofec_candidate_flag_mv USING btree (has_raised_funds);

CREATE UNIQUE INDEX ofec_candidate_flag_mv_idx_idx ON public.ofec_candidate_flag_mv USING btree (idx);

CREATE INDEX ofec_candidate_fulltext_mv_disbursements_idx1 ON public.ofec_candidate_fulltext_mv USING btree (disbursements);

CREATE INDEX ofec_candidate_fulltext_mv_fulltxt_idx1 ON public.ofec_candidate_fulltext_mv USING gin (fulltxt);

CREATE UNIQUE INDEX ofec_candidate_fulltext_mv_idx_idx1 ON public.ofec_candidate_fulltext_mv USING btree (idx);

CREATE INDEX ofec_candidate_fulltext_mv_receipts_idx1 ON public.ofec_candidate_fulltext_mv USING btree (receipts);

CREATE INDEX ofec_candidate_fulltext_mv_total_activity_idx1 ON public.ofec_candidate_fulltext_mv USING btree (total_activity);

CREATE UNIQUE INDEX ofec_candidate_totals_mv_candidate_id_cycle_is_election_idx ON public.ofec_candidate_totals_mv USING btree (candidate_id, cycle, is_election);

CREATE INDEX ofec_candidate_totals_mv_candidate_id_idx ON public.ofec_candidate_totals_mv USING btree (candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_candidate_id_idx ON public.ofec_candidate_totals_mv USING btree (cycle, candidate_id);

CREATE INDEX ofec_candidate_totals_mv_cycle_idx ON public.ofec_candidate_totals_mv USING btree (cycle);

CREATE INDEX ofec_candidate_totals_mv_disbursements_idx ON public.ofec_candidate_totals_mv USING btree (disbursements);

CREATE INDEX ofec_candidate_totals_mv_election_year_idx ON public.ofec_candidate_totals_mv USING btree (election_year);

CREATE INDEX ofec_candidate_totals_mv_federal_funds_flag_idx ON public.ofec_candidate_totals_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_candidate_totals_mv_has_raised_funds_idx ON public.ofec_candidate_totals_mv USING btree (has_raised_funds);

CREATE INDEX ofec_candidate_totals_mv_is_election_idx ON public.ofec_candidate_totals_mv USING btree (is_election);

CREATE INDEX ofec_candidate_totals_mv_receipts_idx ON public.ofec_candidate_totals_mv USING btree (receipts);

CREATE INDEX ofec_committee_fulltext_mv_disbursements_idx1 ON public.ofec_committee_fulltext_mv USING btree (disbursements);

CREATE INDEX ofec_committee_fulltext_mv_fulltxt_idx1 ON public.ofec_committee_fulltext_mv USING gin (fulltxt);

CREATE UNIQUE INDEX ofec_committee_fulltext_mv_idx_idx1 ON public.ofec_committee_fulltext_mv USING btree (idx);

CREATE INDEX ofec_committee_fulltext_mv_independent_expenditures_idx1 ON public.ofec_committee_fulltext_mv USING btree (independent_expenditures);

CREATE INDEX ofec_committee_fulltext_mv_receipts_idx1 ON public.ofec_committee_fulltext_mv USING btree (receipts);

CREATE INDEX ofec_committee_fulltext_mv_total_activity_idx1 ON public.ofec_committee_fulltext_mv USING btree (total_activity);

CREATE INDEX ofec_entity_chart_mv_cycle_idx1 ON public.ofec_entity_chart_mv USING btree (cycle);

CREATE UNIQUE INDEX ofec_entity_chart_mv_idx_idx1 ON public.ofec_entity_chart_mv USING btree (idx);

CREATE INDEX ofec_filings_all_mv_amendment_indicator_idx1 ON public.ofec_filings_all_mv USING btree (amendment_indicator);

CREATE INDEX ofec_filings_all_mv_beginning_image_number_idx1 ON public.ofec_filings_all_mv USING btree (beginning_image_number);

CREATE INDEX ofec_filings_all_mv_candidate_id_idx1 ON public.ofec_filings_all_mv USING btree (candidate_id);

CREATE INDEX ofec_filings_all_mv_committee_id_idx1 ON public.ofec_filings_all_mv USING btree (committee_id);

CREATE INDEX ofec_filings_all_mv_coverage_end_date_idx1 ON public.ofec_filings_all_mv USING btree (coverage_end_date);

CREATE INDEX ofec_filings_all_mv_coverage_start_date_idx1 ON public.ofec_filings_all_mv USING btree (coverage_start_date);

CREATE INDEX ofec_filings_all_mv_cycle_committee_id_idx1 ON public.ofec_filings_all_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_filings_all_mv_cycle_idx1 ON public.ofec_filings_all_mv USING btree (cycle);

CREATE INDEX ofec_filings_all_mv_district_idx1 ON public.ofec_filings_all_mv USING btree (district);

CREATE INDEX ofec_filings_all_mv_form_type_idx1 ON public.ofec_filings_all_mv USING btree (form_type);

CREATE UNIQUE INDEX ofec_filings_all_mv_idx_idx1 ON public.ofec_filings_all_mv USING btree (idx);

CREATE INDEX ofec_filings_all_mv_office_cmte_tp_idx1 ON public.ofec_filings_all_mv USING btree (office_cmte_tp);

CREATE INDEX ofec_filings_all_mv_office_idx1 ON public.ofec_filings_all_mv USING btree (office);

CREATE INDEX ofec_filings_all_mv_party_idx1 ON public.ofec_filings_all_mv USING btree (party);

CREATE INDEX ofec_filings_all_mv_primary_general_indicator_idx1 ON public.ofec_filings_all_mv USING btree (primary_general_indicator);

CREATE INDEX ofec_filings_all_mv_receipt_date_idx1 ON public.ofec_filings_all_mv USING btree (receipt_date);

CREATE INDEX ofec_filings_all_mv_report_type_full_idx1 ON public.ofec_filings_all_mv USING btree (report_type_full);

CREATE INDEX ofec_filings_all_mv_report_type_idx1 ON public.ofec_filings_all_mv USING btree (report_type);

CREATE INDEX ofec_filings_all_mv_report_year_idx1 ON public.ofec_filings_all_mv USING btree (report_year);

CREATE INDEX ofec_filings_all_mv_request_type_idx1 ON public.ofec_filings_all_mv USING btree (request_type);

CREATE INDEX ofec_filings_all_mv_state_idx1 ON public.ofec_filings_all_mv USING btree (state);

CREATE INDEX ofec_filings_all_mv_total_disbursements_idx1 ON public.ofec_filings_all_mv USING btree (total_disbursements);

CREATE INDEX ofec_filings_all_mv_total_independent_expenditures_idx1 ON public.ofec_filings_all_mv USING btree (total_independent_expenditures);

CREATE INDEX ofec_filings_all_mv_total_receipts_idx1 ON public.ofec_filings_all_mv USING btree (total_receipts);

CREATE INDEX ofec_filings_amendments_all_mv_file_num_idx1 ON public.ofec_filings_amendments_all_mv USING btree (file_num);

CREATE UNIQUE INDEX ofec_filings_amendments_all_mv_idx2_idx ON public.ofec_filings_amendments_all_mv USING btree (idx2);

CREATE INDEX ofec_filings_mv_amendment_indicator_idx_idx1 ON public.ofec_filings_mv USING btree (amendment_indicator, idx);

CREATE INDEX ofec_filings_mv_beginning_image_number_idx_idx1 ON public.ofec_filings_mv USING btree (beginning_image_number, idx);

CREATE INDEX ofec_filings_mv_candidate_id_idx_idx1 ON public.ofec_filings_mv USING btree (candidate_id, idx);

CREATE INDEX ofec_filings_mv_committee_id_idx_idx1 ON public.ofec_filings_mv USING btree (committee_id, idx);

CREATE INDEX ofec_filings_mv_coverage_end_date_idx_idx1 ON public.ofec_filings_mv USING btree (coverage_end_date, idx);

CREATE INDEX ofec_filings_mv_coverage_start_date_idx_idx1 ON public.ofec_filings_mv USING btree (coverage_start_date, idx);

CREATE INDEX ofec_filings_mv_cycle_committee_id_idx1 ON public.ofec_filings_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_filings_mv_cycle_idx_idx1 ON public.ofec_filings_mv USING btree (cycle, idx);

CREATE INDEX ofec_filings_mv_district_idx_idx ON public.ofec_filings_mv USING btree (district, idx);

CREATE INDEX ofec_filings_mv_form_type_idx_idx1 ON public.ofec_filings_mv USING btree (form_type, idx);

CREATE UNIQUE INDEX ofec_filings_mv_idx_idx1 ON public.ofec_filings_mv USING btree (idx);

CREATE INDEX ofec_filings_mv_office_idx_idx ON public.ofec_filings_mv USING btree (office, idx);

CREATE INDEX ofec_filings_mv_party_idx_idx ON public.ofec_filings_mv USING btree (party, idx);

CREATE INDEX ofec_filings_mv_primary_general_indicator_idx_idx1 ON public.ofec_filings_mv USING btree (primary_general_indicator, idx);

CREATE INDEX ofec_filings_mv_receipt_date_idx_idx1 ON public.ofec_filings_mv USING btree (receipt_date, idx);

CREATE INDEX ofec_filings_mv_report_type_full_idx_idx ON public.ofec_filings_mv USING btree (report_type_full, idx);

CREATE INDEX ofec_filings_mv_report_type_idx_idx1 ON public.ofec_filings_mv USING btree (report_type, idx);

CREATE INDEX ofec_filings_mv_report_year_idx_idx1 ON public.ofec_filings_mv USING btree (report_year, idx);

CREATE INDEX ofec_filings_mv_state_idx_idx ON public.ofec_filings_mv USING btree (state, idx);

CREATE INDEX ofec_filings_mv_total_disbursements_idx_idx1 ON public.ofec_filings_mv USING btree (total_disbursements, idx);

CREATE INDEX ofec_filings_mv_total_independent_expenditures_idx_idx1 ON public.ofec_filings_mv USING btree (total_independent_expenditures, idx);

CREATE INDEX ofec_filings_mv_total_receipts_idx_idx1 ON public.ofec_filings_mv USING btree (total_receipts, idx);

CREATE INDEX ofec_report_pac_party_all_mv_begin_image_number_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (beginning_image_number, idx);

CREATE INDEX ofec_report_pac_party_all_mv_committee_id_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (committee_id, idx);

CREATE INDEX ofec_report_pac_party_all_mv_cvg_end_date_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (coverage_end_date, idx);

CREATE INDEX ofec_report_pac_party_all_mv_cvg_start_date_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (coverage_start_date, idx);

CREATE INDEX ofec_report_pac_party_all_mv_cycle_committee_id_idx ON public.ofec_report_pac_party_all_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_report_pac_party_all_mv_cycle_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_report_pac_party_all_mv_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (idx);

CREATE INDEX ofec_report_pac_party_all_mv_ie_period_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (independent_expenditures_period, idx);

CREATE INDEX ofec_report_pac_party_all_mv_is_amended_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (is_amended, idx);

CREATE INDEX ofec_report_pac_party_all_mv_receipt_date_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (receipt_date, idx);

CREATE INDEX ofec_report_pac_party_all_mv_report_type_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (report_type, idx);

CREATE INDEX ofec_report_pac_party_all_mv_report_year_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (report_year, idx);

CREATE INDEX ofec_report_pac_party_all_mv_total_disb_period_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (total_disbursements_period, idx);

CREATE INDEX ofec_report_pac_party_all_mv_total_receipts_period_idx_idx ON public.ofec_report_pac_party_all_mv USING btree (total_receipts_period, idx);

CREATE INDEX ofec_reports_house_senate_mv__total_disbursements_period_id_idx ON public.ofec_reports_house_senate_mv USING btree (total_disbursements_period, idx);

CREATE INDEX ofec_reports_house_senate_mv_beginning_image_number_idx_idx ON public.ofec_reports_house_senate_mv USING btree (beginning_image_number, idx);

CREATE INDEX ofec_reports_house_senate_mv_committee_id_idx_idx ON public.ofec_reports_house_senate_mv USING btree (committee_id, idx);

CREATE INDEX ofec_reports_house_senate_mv_coverage_end_date_idx_idx ON public.ofec_reports_house_senate_mv USING btree (coverage_end_date, idx);

CREATE INDEX ofec_reports_house_senate_mv_coverage_start_date_idx_idx ON public.ofec_reports_house_senate_mv USING btree (coverage_start_date, idx);

CREATE INDEX ofec_reports_house_senate_mv_cycle_idx_idx ON public.ofec_reports_house_senate_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_reports_house_senate_mv_idx_idx ON public.ofec_reports_house_senate_mv USING btree (idx);

CREATE INDEX ofec_reports_house_senate_mv_is_amended_idx_idx1 ON public.ofec_reports_house_senate_mv USING btree (is_amended, idx);

CREATE INDEX ofec_reports_house_senate_mv_receipt_date_idx_idx ON public.ofec_reports_house_senate_mv USING btree (receipt_date, idx);

CREATE INDEX ofec_reports_house_senate_mv_report_type_idx_idx ON public.ofec_reports_house_senate_mv USING btree (report_type, idx);

CREATE INDEX ofec_reports_house_senate_mv_report_year_idx_idx ON public.ofec_reports_house_senate_mv USING btree (report_year, idx);

CREATE INDEX ofec_reports_house_senate_mv_total_receipts_period_idx_idx ON public.ofec_reports_house_senate_mv USING btree (total_receipts_period, idx);

CREATE INDEX ofec_reports_pacs_parties_mv__independent_expenditures_per_idx1 ON public.ofec_reports_pacs_parties_mv USING btree (independent_expenditures_period, idx);

CREATE INDEX ofec_reports_pacs_parties_mv__total_disbursements_period_id_idx ON public.ofec_reports_pacs_parties_mv USING btree (total_disbursements_period, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_beginning_image_number_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (beginning_image_number, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_committee_id_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (committee_id, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_coverage_end_date_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (coverage_end_date, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_coverage_start_date_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (coverage_start_date, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_cycle_committee_id_idx1 ON public.ofec_reports_pacs_parties_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_reports_pacs_parties_mv_cycle_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (cycle, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_cycle_idx_idx3 ON public.ofec_reports_pacs_parties_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_reports_pacs_parties_mv_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (idx);

CREATE INDEX ofec_reports_pacs_parties_mv_is_amended_idx_idx1 ON public.ofec_reports_pacs_parties_mv USING btree (is_amended, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_receipt_date_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (receipt_date, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_report_type_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (report_type, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_report_year_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (report_year, idx);

CREATE INDEX ofec_reports_pacs_parties_mv_total_receipts_period_idx_idx ON public.ofec_reports_pacs_parties_mv USING btree (total_receipts_period, idx);

CREATE INDEX ofec_reports_presidential_mv__total_disbursements_period_id_idx ON public.ofec_reports_presidential_mv USING btree (total_disbursements_period, idx);

CREATE INDEX ofec_reports_presidential_mv_beginning_image_number_idx_idx ON public.ofec_reports_presidential_mv USING btree (beginning_image_number, idx);

CREATE INDEX ofec_reports_presidential_mv_committee_id_idx_idx ON public.ofec_reports_presidential_mv USING btree (committee_id, idx);

CREATE INDEX ofec_reports_presidential_mv_coverage_end_date_idx_idx ON public.ofec_reports_presidential_mv USING btree (coverage_end_date, idx);

CREATE INDEX ofec_reports_presidential_mv_coverage_start_date_idx_idx ON public.ofec_reports_presidential_mv USING btree (coverage_start_date, idx);

CREATE INDEX ofec_reports_presidential_mv_cycle_committee_id_idx1 ON public.ofec_reports_presidential_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_reports_presidential_mv_cycle_idx_idx ON public.ofec_reports_presidential_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_reports_presidential_mv_idx_idx ON public.ofec_reports_presidential_mv USING btree (idx);

CREATE INDEX ofec_reports_presidential_mv_is_amended_idx_idx1 ON public.ofec_reports_presidential_mv USING btree (is_amended, idx);

CREATE INDEX ofec_reports_presidential_mv_receipt_date_idx_idx ON public.ofec_reports_presidential_mv USING btree (receipt_date, idx);

CREATE INDEX ofec_reports_presidential_mv_report_type_idx_idx ON public.ofec_reports_presidential_mv USING btree (report_type, idx);

CREATE INDEX ofec_reports_presidential_mv_report_year_idx_idx ON public.ofec_reports_presidential_mv USING btree (report_year, idx);

CREATE INDEX ofec_reports_presidential_mv_total_receipts_period_idx_idx ON public.ofec_reports_presidential_mv USING btree (total_receipts_period, idx);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_cmte_id_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (cmte_id, idx);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_count_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (count, idx);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_cycle_cmte_id ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (cycle, cmte_id);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_cycle_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_sched_a_aggregate_size_merged_mv_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (idx);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_size_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (size, idx);

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_total_idx ON public.ofec_sched_a_aggregate_size_merged_mv USING btree (total, idx);

CREATE UNIQUE INDEX ofec_totals_candidate_com_candidate_id_cycle_full_elect_idx ON public.ofec_totals_candidate_committees_mv USING btree (candidate_id, cycle, full_election);

CREATE INDEX ofec_totals_candidate_committees_mv_candidate_id_idx ON public.ofec_totals_candidate_committees_mv USING btree (candidate_id);

CREATE INDEX ofec_totals_candidate_committees_mv_cycle_idx ON public.ofec_totals_candidate_committees_mv USING btree (cycle);

CREATE INDEX ofec_totals_candidate_committees_mv_disbursements_idx ON public.ofec_totals_candidate_committees_mv USING btree (disbursements);

CREATE INDEX ofec_totals_candidate_committees_mv_election_year_idx ON public.ofec_totals_candidate_committees_mv USING btree (election_year);

CREATE INDEX ofec_totals_candidate_committees_mv_federal_funds_flag_idx ON public.ofec_totals_candidate_committees_mv USING btree (federal_funds_flag);

CREATE INDEX ofec_totals_candidate_committees_mv_receipts_idx ON public.ofec_totals_candidate_committees_mv USING btree (receipts);

CREATE INDEX ofec_totals_combined_mv_committee_designation_full_sub__idx ON public.ofec_totals_combined_mv USING btree (committee_designation_full, sub_id);

CREATE INDEX ofec_totals_combined_mv_committee_id_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (committee_id, sub_id);

CREATE INDEX ofec_totals_combined_mv_committee_type_full_sub_id_idx ON public.ofec_totals_combined_mv USING btree (committee_type_full, sub_id);

CREATE INDEX ofec_totals_combined_mv_cycle_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (cycle, sub_id);

CREATE INDEX ofec_totals_combined_mv_disbursements_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (disbursements, sub_id);

CREATE INDEX ofec_totals_combined_mv_receipts_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (receipts, sub_id);

CREATE UNIQUE INDEX ofec_totals_combined_mv_sub_id_idx1 ON public.ofec_totals_combined_mv USING btree (sub_id);

CREATE INDEX ofec_totals_house_senate_mv_t_committee_designation_full_id_idx ON public.ofec_totals_house_senate_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_house_senate_mv_candidate_id_idx_idx1 ON public.ofec_totals_house_senate_mv USING btree (candidate_id, idx);

CREATE INDEX ofec_totals_house_senate_mv_committee_id_idx_idx ON public.ofec_totals_house_senate_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_house_senate_mv_committee_type_full_idx_idx ON public.ofec_totals_house_senate_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_house_senate_mv_cycle_committee_id_idx1 ON public.ofec_totals_house_senate_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_house_senate_mv_cycle_committee_id_idx3 ON public.ofec_totals_house_senate_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_house_senate_mv_cycle_idx_idx ON public.ofec_totals_house_senate_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_totals_house_senate_mv_idx_idx ON public.ofec_totals_house_senate_mv USING btree (idx);

CREATE INDEX ofec_totals_ie_only_mv_committee_designation_full_idx_idx ON public.ofec_totals_ie_only_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_committee_id_idx_idx ON public.ofec_totals_ie_only_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_ie_only_mv_committee_type_full_idx_idx ON public.ofec_totals_ie_only_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_ie_only_mv_cycle_committee_id_idx1 ON public.ofec_totals_ie_only_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_ie_only_mv_cycle_idx_idx ON public.ofec_totals_ie_only_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_totals_ie_only_mv_idx_idx ON public.ofec_totals_ie_only_mv USING btree (idx);

CREATE INDEX ofec_totals_pacs_mv_committee_designation_full_idx_idx ON public.ofec_totals_pacs_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_pacs_mv_committee_id_idx_idx1 ON public.ofec_totals_pacs_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_pacs_mv_committee_type_full_idx_idx ON public.ofec_totals_pacs_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_pacs_mv_committee_type_idx_idx1 ON public.ofec_totals_pacs_mv USING btree (committee_type, idx);

CREATE INDEX ofec_totals_pacs_mv_cycle_idx_idx1 ON public.ofec_totals_pacs_mv USING btree (cycle, idx);

CREATE INDEX ofec_totals_pacs_mv_designation_idx_idx1 ON public.ofec_totals_pacs_mv USING btree (designation, idx);

CREATE INDEX ofec_totals_pacs_mv_disbursements_idx1 ON public.ofec_totals_pacs_mv USING btree (disbursements);

CREATE UNIQUE INDEX ofec_totals_pacs_mv_idx_idx1 ON public.ofec_totals_pacs_mv USING btree (idx);

CREATE INDEX ofec_totals_pacs_mv_receipts_idx1 ON public.ofec_totals_pacs_mv USING btree (receipts);

CREATE INDEX ofec_totals_pacs_parties_mv_t_committee_designation_full_id_idx ON public.ofec_totals_pacs_parties_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_committee_id_idx_idx ON public.ofec_totals_pacs_parties_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_committee_type_full_idx_idx ON public.ofec_totals_pacs_parties_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_committee_type_idx_idx1 ON public.ofec_totals_pacs_parties_mv USING btree (committee_type, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_cycle_idx_idx ON public.ofec_totals_pacs_parties_mv USING btree (cycle, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_designation_idx_idx1 ON public.ofec_totals_pacs_parties_mv USING btree (designation, idx);

CREATE INDEX ofec_totals_pacs_parties_mv_disbursements_idx1 ON public.ofec_totals_pacs_parties_mv USING btree (disbursements);

CREATE UNIQUE INDEX ofec_totals_pacs_parties_mv_idx_idx ON public.ofec_totals_pacs_parties_mv USING btree (idx);

CREATE INDEX ofec_totals_pacs_parties_mv_receipts_idx1 ON public.ofec_totals_pacs_parties_mv USING btree (receipts);

CREATE INDEX ofec_totals_parties_mv_committee_designation_full_idx_idx ON public.ofec_totals_parties_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_parties_mv_committee_id_idx_idx1 ON public.ofec_totals_parties_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_parties_mv_committee_type_full_idx_idx ON public.ofec_totals_parties_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_parties_mv_committee_type_idx_idx1 ON public.ofec_totals_parties_mv USING btree (committee_type, idx);

CREATE INDEX ofec_totals_parties_mv_cycle_idx_idx1 ON public.ofec_totals_parties_mv USING btree (cycle, idx);

CREATE INDEX ofec_totals_parties_mv_designation_idx_idx1 ON public.ofec_totals_parties_mv USING btree (designation, idx);

CREATE INDEX ofec_totals_parties_mv_disbursements_idx1 ON public.ofec_totals_parties_mv USING btree (disbursements);

CREATE UNIQUE INDEX ofec_totals_parties_mv_idx_idx1 ON public.ofec_totals_parties_mv USING btree (idx);

CREATE INDEX ofec_totals_parties_mv_receipts_idx1 ON public.ofec_totals_parties_mv USING btree (receipts);

CREATE INDEX ofec_totals_presidential_mv_t_committee_designation_full_id_idx ON public.ofec_totals_presidential_mv USING btree (committee_designation_full, idx);

CREATE INDEX ofec_totals_presidential_mv_committee_id_idx_idx1 ON public.ofec_totals_presidential_mv USING btree (committee_id, idx);

CREATE INDEX ofec_totals_presidential_mv_committee_type_full_idx_idx ON public.ofec_totals_presidential_mv USING btree (committee_type_full, idx);

CREATE INDEX ofec_totals_presidential_mv_cycle_committee_id_idx1 ON public.ofec_totals_presidential_mv USING btree (cycle, committee_id);

CREATE INDEX ofec_totals_presidential_mv_cycle_idx_idx1 ON public.ofec_totals_presidential_mv USING btree (cycle, idx);

CREATE UNIQUE INDEX ofec_totals_presidential_mv_idx_idx1 ON public.ofec_totals_presidential_mv USING btree (idx);

GRANT SELECT ON TABLE public.ofec_filings_amendments_all_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_filings_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_combined_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_house_senate_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_presidential_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_candidate_totals_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_candidate_flag_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_candidate_fulltext_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_committee_fulltext_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_pacs_parties_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_pacs_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_parties_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_entity_chart_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_filings_all_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_report_pac_party_all_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_reports_house_senate_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_reports_pacs_parties_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_reports_presidential_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_size_merged_mv TO fec_read;

GRANT SELECT ON TABLE public.ofec_totals_candidate_committees_mv TO fec_read;
GRANT SELECT ON TABLE public.ofec_totals_candidate_committees_mv TO openfec_read;

GRANT SELECT ON TABLE public.ofec_totals_ie_only_mv TO fec_read;
