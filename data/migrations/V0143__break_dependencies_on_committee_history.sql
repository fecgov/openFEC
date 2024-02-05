/*
This migration file is needed to solve https://github.com/fecgov/openFEC/issues/3807

Change dependencies on ofec_committee_history_mv to depend on ofec_committee_history_vw

- 1) materialized view ofec_communication_cost_mv depends on materialized view ofec_committee_history_mv

- 2) materialized view ofec_sched_a_aggregate_state_recipient_totals_mv depends on materialized view ofec_committee_detail_mv

- 3) materialized view ofec_committee_detail_mv depends on materialized view ofec_committee_history_mv


*/

-- 1) materialized view ofec_communication_cost_mv depends on materialized view ofec_committee_history_mv

-- a) `create or replace `XXX_vw` to use new `MV` logic

CREATE OR REPLACE VIEW public.ofec_communication_cost_vw AS
 WITH com_names AS (
         SELECT DISTINCT ON (ofec_committee_history_vw.committee_id) ofec_committee_history_vw.committee_id,
            ofec_committee_history_vw.name AS committee_name
           FROM ofec_committee_history_vw
          ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC
        )
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
    f76.action_cd,
    f76.action_cd_desc,
    f76.tran_id,
    f76.schedule_type,
    f76.schedule_type_desc,
    f76.image_num,
    f76.file_num,
    f76.link_id,
    f76.orig_sub_id,
    f76.sub_id,
    f76.filing_form,
    f76.rpt_tp,
    f76.rpt_yr,
    f76.election_cycle,
    f76.s_o_cand_id AS cand_id,
    f76.org_id AS cmte_id,
    com_names.committee_name,
    report_pdf_url((f76.image_num)::text) AS pdf_url
   FROM (fec_fitem_f76_vw f76
     LEFT JOIN com_names ON (((f76.org_id)::text = (com_names.committee_id)::text)))
  WHERE ((date_part('year'::text, f76.communication_dt))::integer >= 1979);

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_communication_cost_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_communication_cost_mv AS
WITH com_names AS (
         SELECT DISTINCT ON (ofec_committee_history_vw.committee_id) ofec_committee_history_vw.committee_id,
            ofec_committee_history_vw.name AS committee_name
           FROM ofec_committee_history_vw
          ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC
        )
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
    f76.action_cd,
    f76.action_cd_desc,
    f76.tran_id,
    f76.schedule_type,
    f76.schedule_type_desc,
    f76.image_num,
    f76.file_num,
    f76.link_id,
    f76.orig_sub_id,
    f76.sub_id,
    f76.filing_form,
    f76.rpt_tp,
    f76.rpt_yr,
    f76.election_cycle,
    f76.s_o_cand_id AS cand_id,
    f76.org_id AS cmte_id,
    com_names.committee_name,
    report_pdf_url((f76.image_num)::text) AS pdf_url
   FROM (fec_fitem_f76_vw f76
     LEFT JOIN com_names ON (((f76.org_id)::text = (com_names.committee_id)::text)))
  WHERE ((date_part('year'::text, f76.communication_dt))::integer >= 1979)
  WITH DATA;


--Permissions

ALTER TABLE public.ofec_communication_cost_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_communication_cost_mv TO fec;
GRANT SELECT ON TABLE public.ofec_communication_cost_mv TO fec_read;

--Indices

CREATE UNIQUE INDEX ofec_communication_cost_mv_sub_id_idx
ON ofec_communication_cost_mv USING btree (sub_id);

CREATE INDEX ofec_communication_cost_mv_cand_id_idx
ON ofec_communication_cost_mv USING btree (cand_id);

CREATE INDEX ofec_communication_cost_mv_cmte_id_idx
ON ofec_communication_cost_mv USING btree (cmte_id);

CREATE INDEX ofec_communication_cost_mv_communication_class_idx
ON ofec_communication_cost_mv USING btree (communication_class);

CREATE INDEX ofec_communication_cost_mv_communication_cost_idx
ON ofec_communication_cost_mv USING btree (communication_cost);

CREATE INDEX ofec_communication_cost_mv_communication_dt_idx
ON ofec_communication_cost_mv USING btree (communication_dt);

CREATE INDEX ofec_communication_cost_mv_communication_tp_idx
ON ofec_communication_cost_mv USING btree (communication_tp);

CREATE INDEX ofec_communication_cost_mv_filing_form_idx
ON ofec_communication_cost_mv USING btree (filing_form);

CREATE INDEX ofec_communication_cost_mv_image_num_idx
ON ofec_communication_cost_mv USING btree (image_num);

CREATE INDEX ofec_communication_cost_mv_s_o_cand_office_district_idx
ON ofec_communication_cost_mv USING btree (s_o_cand_office_district);

CREATE INDEX ofec_communication_cost_mv_s_o_cand_office_idx
ON ofec_communication_cost_mv USING btree (s_o_cand_office);

CREATE INDEX ofec_communication_cost_mv_s_o_cand_office_st_idx
ON ofec_communication_cost_mv USING btree (s_o_cand_office_st);

CREATE INDEX ofec_communication_cost_mv_s_o_ind_idx
ON ofec_communication_cost_mv USING btree (s_o_ind);

-- d) `create or replace `public.XXX_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW ofec_communication_cost_vw
AS SELECT * FROM ofec_communication_cost_mv;


-- 2) materialized view ofec_sched_a_aggregate_state_recipient_totals_mv depends on materialized view ofec_committee_detail_mv

-- a) `create or replace `XXX_vw` to use new `MV` logic

CREATE OR REPLACE VIEW public.ofec_sched_a_aggregate_state_recipient_totals_vw AS
 WITH grouped_totals AS (
         SELECT sum(agg_st.total) AS total,
            count(agg_st.total) AS count,
            agg_st.cycle,
            agg_st.state,
            agg_st.state_full,
            cd.committee_type,
            cd.committee_type_full
           FROM disclosure.dsc_sched_a_aggregate_state agg_st
             JOIN ofec_committee_detail_vw cd ON agg_st.cmte_id::text = cd.committee_id::text
          WHERE (agg_st.state::text IN (SELECT state_abbrevation
                   FROM staging.ref_zip_to_district))
          GROUP BY agg_st.cycle, agg_st.state, agg_st.state_full, cd.committee_type, cd.committee_type_full
        ), candidate_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_CANDIDATES'::text AS committee_type,
            'All Candidates'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), pacs_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_PACS'::text AS committee_type,
            'All PACs'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['N'::character varying, 'O'::character varying, 'Q'::character varying, 'V'::character varying, 'W'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), overall_total AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL'::text AS committee_type,
            'All'::text AS committee_type_full
           FROM grouped_totals totals
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), combined AS (
         SELECT grouped_totals.total,
            grouped_totals.count,
            grouped_totals.cycle,
            grouped_totals.state,
            grouped_totals.state_full,
            grouped_totals.committee_type,
            grouped_totals.committee_type_full
           FROM grouped_totals
        UNION ALL
         SELECT candidate_totals.total,
            candidate_totals.count,
            candidate_totals.cycle,
            candidate_totals.state,
            candidate_totals.state_full,
            candidate_totals.committee_type,
            candidate_totals.committee_type_full
           FROM candidate_totals
        UNION ALL
         SELECT pacs_totals.total,
            pacs_totals.count,
            pacs_totals.cycle,
            pacs_totals.state,
            pacs_totals.state_full,
            pacs_totals.committee_type,
            pacs_totals.committee_type_full
           FROM pacs_totals
        UNION ALL
         SELECT overall_total.total,
            overall_total.count,
            overall_total.cycle,
            overall_total.state,
            overall_total.state_full,
            overall_total.committee_type,
            overall_total.committee_type_full
           FROM overall_total
  ORDER BY 4, 3, 6
        )
 SELECT row_number() OVER () AS idx,
    combined.total,
    combined.count,
    combined.cycle,
    combined.state,
    combined.state_full,
    combined.committee_type,
    combined.committee_type_full
   FROM combined;

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_sched_a_aggregate_state_recipient_totals_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_sched_a_aggregate_state_recipient_totals_mv AS
 WITH grouped_totals AS (
         SELECT sum(agg_st.total) AS total,
            count(agg_st.total) AS count,
            agg_st.cycle,
            agg_st.state,
            agg_st.state_full,
            cd.committee_type,
            cd.committee_type_full
           FROM disclosure.dsc_sched_a_aggregate_state agg_st
             JOIN ofec_committee_detail_vw cd ON agg_st.cmte_id::text = cd.committee_id::text
          WHERE (agg_st.state::text IN (SELECT state_abbrevation
                   FROM staging.ref_zip_to_district))
          GROUP BY agg_st.cycle, agg_st.state, agg_st.state_full, cd.committee_type, cd.committee_type_full
        ), candidate_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_CANDIDATES'::text AS committee_type,
            'All Candidates'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), pacs_totals AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL_PACS'::text AS committee_type,
            'All PACs'::text AS committee_type_full
           FROM grouped_totals totals
          WHERE totals.committee_type::text = ANY (ARRAY['N'::character varying, 'O'::character varying, 'Q'::character varying, 'V'::character varying, 'W'::character varying]::text[])
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), overall_total AS (
         SELECT sum(totals.total) AS total,
            sum(totals.count) AS count,
            totals.cycle,
            totals.state,
            totals.state_full,
            'ALL'::text AS committee_type,
            'All'::text AS committee_type_full
           FROM grouped_totals totals
          GROUP BY totals.cycle, totals.state, totals.state_full
        ), combined AS (
         SELECT grouped_totals.total,
            grouped_totals.count,
            grouped_totals.cycle,
            grouped_totals.state,
            grouped_totals.state_full,
            grouped_totals.committee_type,
            grouped_totals.committee_type_full
           FROM grouped_totals
        UNION ALL
         SELECT candidate_totals.total,
            candidate_totals.count,
            candidate_totals.cycle,
            candidate_totals.state,
            candidate_totals.state_full,
            candidate_totals.committee_type,
            candidate_totals.committee_type_full
           FROM candidate_totals
        UNION ALL
         SELECT pacs_totals.total,
            pacs_totals.count,
            pacs_totals.cycle,
            pacs_totals.state,
            pacs_totals.state_full,
            pacs_totals.committee_type,
            pacs_totals.committee_type_full
           FROM pacs_totals
        UNION ALL
         SELECT overall_total.total,
            overall_total.count,
            overall_total.cycle,
            overall_total.state,
            overall_total.state_full,
            overall_total.committee_type,
            overall_total.committee_type_full
           FROM overall_total
  ORDER BY 4, 3, 6
        )
 SELECT row_number() OVER () AS idx,
    combined.total,
    combined.count,
    combined.cycle,
    combined.state,
    combined.state_full,
    combined.committee_type,
    combined.committee_type_full
   FROM combined;

--Permissions

ALTER TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv TO fec;
GRANT SELECT ON TABLE public.ofec_sched_a_aggregate_state_recipient_totals_mv TO fec_read;

--Indices

CREATE INDEX ofec_sched_a_aggregate_state_recipient_committee_type_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv
  USING btree
  (committee_type COLLATE pg_catalog."default", idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_cycle_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv
  USING btree
  (cycle, idx);


CREATE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_state_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv
  USING btree
  (state COLLATE pg_catalog."default", idx);


CREATE UNIQUE INDEX ofec_sched_a_aggregate_state_recipient_totals_mv_idx_TMP
  ON public.ofec_sched_a_aggregate_state_recipient_totals_mv
  USING btree
  (idx);


-- d) `create or replace `public.XXX_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW public.ofec_sched_a_aggregate_state_recipient_totals_vw AS
SELECT * FROM public.ofec_sched_a_aggregate_state_recipient_totals_mv;


-- 3) materialized view ofec_committee_detail_mv depends on materialized view ofec_committee_history_mv

-- a) `create or replace `XXX_vw` to use new `MV` logic

CREATE OR REPLACE VIEW public.ofec_committee_detail_vw AS
SELECT DISTINCT ON (ofec_committee_history_vw.committee_id)
    ofec_committee_history_vw.idx,
    ofec_committee_history_vw.cycle,
    ofec_committee_history_vw.committee_id,
    ofec_committee_history_vw.name,
    ofec_committee_history_vw.treasurer_name,
    ofec_committee_history_vw.treasurer_text,
    ofec_committee_history_vw.organization_type,
    ofec_committee_history_vw.organization_type_full,
    ofec_committee_history_vw.street_1,
    ofec_committee_history_vw.street_2,
    ofec_committee_history_vw.city,
    ofec_committee_history_vw.state,
    ofec_committee_history_vw.state_full,
    ofec_committee_history_vw.zip,
    ofec_committee_history_vw.treasurer_city,
    ofec_committee_history_vw.treasurer_name_1,
    ofec_committee_history_vw.treasurer_name_2,
    ofec_committee_history_vw.treasurer_name_middle,
    ofec_committee_history_vw.treasurer_phone,
    ofec_committee_history_vw.treasurer_name_prefix,
    ofec_committee_history_vw.treasurer_state,
    ofec_committee_history_vw.treasurer_street_1,
    ofec_committee_history_vw.treasurer_street_2,
    ofec_committee_history_vw.treasurer_name_suffix,
    ofec_committee_history_vw.treasurer_name_title,
    ofec_committee_history_vw.treasurer_zip,
    ofec_committee_history_vw.custodian_city,
    ofec_committee_history_vw.custodian_name_1,
    ofec_committee_history_vw.custodian_name_2,
    ofec_committee_history_vw.custodian_name_middle,
    ofec_committee_history_vw.custodian_name_full,
    ofec_committee_history_vw.custodian_phone,
    ofec_committee_history_vw.custodian_name_prefix,
    ofec_committee_history_vw.custodian_state,
    ofec_committee_history_vw.custodian_street_1,
    ofec_committee_history_vw.custodian_street_2,
    ofec_committee_history_vw.custodian_name_suffix,
    ofec_committee_history_vw.custodian_name_title,
    ofec_committee_history_vw.custodian_zip,
    ofec_committee_history_vw.email,
    ofec_committee_history_vw.fax,
    ofec_committee_history_vw.website,
    ofec_committee_history_vw.form_type,
    ofec_committee_history_vw.leadership_pac,
    ofec_committee_history_vw.lobbyist_registrant_pac,
    ofec_committee_history_vw.party_type,
    ofec_committee_history_vw.party_type_full,
    ofec_committee_history_vw.qualifying_date,
    ofec_committee_history_vw.first_file_date,
    ofec_committee_history_vw.last_file_date,
    ofec_committee_history_vw.last_f1_date,
    ofec_committee_history_vw.designation,
    ofec_committee_history_vw.designation_full,
    ofec_committee_history_vw.committee_type,
    ofec_committee_history_vw.committee_type_full,
    ofec_committee_history_vw.filing_frequency,
    ofec_committee_history_vw.party,
    ofec_committee_history_vw.party_full,
    ofec_committee_history_vw.cycles,
    ofec_committee_history_vw.candidate_ids
   FROM ofec_committee_history_vw
  ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC;

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_committee_detail_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_committee_detail_mv AS
SELECT DISTINCT ON (ofec_committee_history_vw.committee_id)
    ofec_committee_history_vw.idx,
    ofec_committee_history_vw.cycle,
    ofec_committee_history_vw.committee_id,
    ofec_committee_history_vw.name,
    ofec_committee_history_vw.treasurer_name,
    ofec_committee_history_vw.treasurer_text,
    ofec_committee_history_vw.organization_type,
    ofec_committee_history_vw.organization_type_full,
    ofec_committee_history_vw.street_1,
    ofec_committee_history_vw.street_2,
    ofec_committee_history_vw.city,
    ofec_committee_history_vw.state,
    ofec_committee_history_vw.state_full,
    ofec_committee_history_vw.zip,
    ofec_committee_history_vw.treasurer_city,
    ofec_committee_history_vw.treasurer_name_1,
    ofec_committee_history_vw.treasurer_name_2,
    ofec_committee_history_vw.treasurer_name_middle,
    ofec_committee_history_vw.treasurer_phone,
    ofec_committee_history_vw.treasurer_name_prefix,
    ofec_committee_history_vw.treasurer_state,
    ofec_committee_history_vw.treasurer_street_1,
    ofec_committee_history_vw.treasurer_street_2,
    ofec_committee_history_vw.treasurer_name_suffix,
    ofec_committee_history_vw.treasurer_name_title,
    ofec_committee_history_vw.treasurer_zip,
    ofec_committee_history_vw.custodian_city,
    ofec_committee_history_vw.custodian_name_1,
    ofec_committee_history_vw.custodian_name_2,
    ofec_committee_history_vw.custodian_name_middle,
    ofec_committee_history_vw.custodian_name_full,
    ofec_committee_history_vw.custodian_phone,
    ofec_committee_history_vw.custodian_name_prefix,
    ofec_committee_history_vw.custodian_state,
    ofec_committee_history_vw.custodian_street_1,
    ofec_committee_history_vw.custodian_street_2,
    ofec_committee_history_vw.custodian_name_suffix,
    ofec_committee_history_vw.custodian_name_title,
    ofec_committee_history_vw.custodian_zip,
    ofec_committee_history_vw.email,
    ofec_committee_history_vw.fax,
    ofec_committee_history_vw.website,
    ofec_committee_history_vw.form_type,
    ofec_committee_history_vw.leadership_pac,
    ofec_committee_history_vw.lobbyist_registrant_pac,
    ofec_committee_history_vw.party_type,
    ofec_committee_history_vw.party_type_full,
    ofec_committee_history_vw.qualifying_date,
    ofec_committee_history_vw.first_file_date,
    ofec_committee_history_vw.last_file_date,
    ofec_committee_history_vw.last_f1_date,
    ofec_committee_history_vw.designation,
    ofec_committee_history_vw.designation_full,
    ofec_committee_history_vw.committee_type,
    ofec_committee_history_vw.committee_type_full,
    ofec_committee_history_vw.filing_frequency,
    ofec_committee_history_vw.party,
    ofec_committee_history_vw.party_full,
    ofec_committee_history_vw.cycles,
    ofec_committee_history_vw.candidate_ids
   FROM ofec_committee_history_vw
  ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC;

--Permissions

ALTER TABLE public.ofec_committee_detail_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_detail_mv TO fec;
GRANT SELECT ON TABLE public.ofec_committee_detail_mv TO fec_read;

--Indices

CREATE UNIQUE INDEX ofec_committee_detail_mv_idx_idx1
ON ofec_committee_detail_mv USING btree (idx);

CREATE INDEX ofec_committee_detail_mv_candidate_ids_idx1
ON ofec_committee_detail_mv USING gin (candidate_ids);

CREATE INDEX ofec_committee_detail_mv_committee_id_idx1
ON ofec_committee_detail_mv USING btree (committee_id);

CREATE INDEX ofec_committee_detail_mv_committee_type_full_idx1
ON ofec_committee_detail_mv USING btree (committee_type_full);

CREATE INDEX ofec_committee_detail_mv_committee_type_idx1
ON ofec_committee_detail_mv USING btree (committee_type);

CREATE INDEX ofec_committee_detail_mv_cycles_candidate_ids_idx1
ON ofec_committee_detail_mv USING gin (cycles, candidate_ids);

CREATE INDEX ofec_committee_detail_mv_cycles_idx1
ON ofec_committee_detail_mv USING gin (cycles);

CREATE INDEX ofec_committee_detail_mv_designation_full_idx1
ON ofec_committee_detail_mv USING btree (designation_full);

CREATE INDEX ofec_committee_detail_mv_designation_idx1
ON ofec_committee_detail_mv USING btree (designation);

CREATE INDEX ofec_committee_detail_mv_first_file_date_idx1
ON ofec_committee_detail_mv USING btree (first_file_date);

CREATE INDEX ofec_committee_detail_mv_last_file_date_idx1
ON ofec_committee_detail_mv USING btree (last_file_date);

CREATE INDEX ofec_committee_detail_mv_name_idx1
ON ofec_committee_detail_mv USING btree (name);

CREATE INDEX ofec_committee_detail_mv_organization_type_full_idx1
ON ofec_committee_detail_mv USING btree (organization_type_full);

CREATE INDEX ofec_committee_detail_mv_organization_type_idx1
ON ofec_committee_detail_mv USING btree (organization_type);

CREATE INDEX ofec_committee_detail_mv_party_full_idx1
ON ofec_committee_detail_mv USING btree (party_full);

CREATE INDEX ofec_committee_detail_mv_party_idx1
ON ofec_committee_detail_mv USING btree (party);

CREATE INDEX ofec_committee_detail_mv_state_idx1
ON ofec_committee_detail_mv USING btree (state);

CREATE INDEX ofec_committee_detail_mv_treasurer_name_idx1
ON ofec_committee_detail_mv USING btree (treasurer_name);

CREATE INDEX ofec_committee_detail_mv_treasurer_text_idx1
ON ofec_committee_detail_mv USING gin (treasurer_text);

-- d) `create or replace `public.XXX_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW public.ofec_committee_detail_vw AS
SELECT * FROM public.ofec_committee_detail_mv
