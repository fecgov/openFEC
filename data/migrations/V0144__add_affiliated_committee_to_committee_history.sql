/*
This migration file is needed to solve https://github.com/fecgov/openFEC/issues/3807

Add `affiliated_committee_name` to `ofec_committee_history_mv`
and `public.ofec_committee_history_vw`

    a) `create or replace `ofec_committee_history_vw` to use new `MV` logic
    b) drop old `MV`
    c) recreate `MV` with new logic
    d) `create or replace `ofec_committee_history_vw` -> `select all` from new `MV`
*/

-- a) `create or replace `ofec_committee_history_vw` to use new `MV` logic
CREATE OR REPLACE VIEW public.ofec_committee_history_vw AS
WITH cycles AS (
         SELECT cmte_valid_fec_yr.cmte_id,
            (array_agg(cmte_valid_fec_yr.fec_election_yr))::integer[] AS cycles,
            max(cmte_valid_fec_yr.fec_election_yr) AS max_cycle
           FROM disclosure.cmte_valid_fec_yr
          GROUP BY cmte_valid_fec_yr.cmte_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F1'::text)) AS last_f1_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        ), candidates AS (
         SELECT cand_cmte_linkage.cmte_id,
            (array_agg(DISTINCT cand_cmte_linkage.cand_id))::text[] AS candidate_ids
           FROM disclosure.cand_cmte_linkage
          GROUP BY cand_cmte_linkage.cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cmte_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.fec_election_yr AS cycle,
    fec_yr.cmte_id AS committee_id,
    fec_yr.cmte_nm AS name,
    fec_yr.tres_nm AS treasurer_name,
    to_tsvector((fec_yr.tres_nm)::text) AS treasurer_text,
    f1.org_tp AS organization_type,
    expand_organization_type((f1.org_tp)::text) AS organization_type_full,
    fec_yr.cmte_st1 AS street_1,
    fec_yr.cmte_st2 AS street_2,
    fec_yr.cmte_city AS city,
    fec_yr.cmte_st AS state,
    expand_state((fec_yr.cmte_st)::text) AS state_full,
    fec_yr.cmte_zip AS zip,
    f1.tres_city AS treasurer_city,
    f1.tres_f_nm AS treasurer_name_1,
    f1.tres_l_nm AS treasurer_name_2,
    f1.tres_m_nm AS treasurer_name_middle,
    f1.tres_ph_num AS treasurer_phone,
    f1.tres_prefix AS treasurer_name_prefix,
    f1.tres_st AS treasurer_state,
    f1.tres_st1 AS treasurer_street_1,
    f1.tres_st2 AS treasurer_street_2,
    f1.tres_suffix AS treasurer_name_suffix,
    f1.tres_title AS treasurer_name_title,
    f1.tres_zip AS treasurer_zip,
    f1.cust_rec_city AS custodian_city,
    f1.cust_rec_f_nm AS custodian_name_1,
    f1.cust_rec_l_nm AS custodian_name_2,
    f1.cust_rec_m_nm AS custodian_name_middle,
    f1.cust_rec_nm AS custodian_name_full,
    f1.cust_rec_ph_num AS custodian_phone,
    f1.cust_rec_prefix AS custodian_name_prefix,
    f1.cust_rec_st AS custodian_state,
    f1.cust_rec_st1 AS custodian_street_1,
    f1.cust_rec_st2 AS custodian_street_2,
    f1.cust_rec_suffix AS custodian_name_suffix,
    f1.cust_rec_title AS custodian_name_title,
    f1.cust_rec_zip AS custodian_zip,
    fec_yr.cmte_email AS email,
    f1.cmte_fax AS fax,
    fec_yr.cmte_url AS website,
    f1.form_tp AS form_type,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp AS party_type,
    f1.cand_pty_tp_desc AS party_type_full,
    f1.qual_dt AS qualifying_date,
    ((dates.first_file_date)::text)::date AS first_file_date,
    ((dates.last_file_date)::text)::date AS last_file_date,
    ((dates.last_f1_date)::text)::date AS last_f1_date,
    fec_yr.cmte_dsgn AS designation,
    expand_committee_designation((fec_yr.cmte_dsgn)::text) AS designation_full,
    fec_yr.cmte_tp AS committee_type,
    expand_committee_type((fec_yr.cmte_tp)::text) AS committee_type_full,
    fec_yr.cmte_filing_freq AS filing_frequency,
    fec_yr.cmte_pty_affiliation AS party,
    fec_yr.cmte_pty_affiliation_desc AS party_full,
    cycles.cycles,
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids,
    f1.affiliated_cmte_nm AS affiliated_committee_name
   FROM ((((disclosure.cmte_valid_fec_yr fec_yr
     LEFT JOIN fec_vsum_f1_vw f1 ON ((((fec_yr.cmte_id)::text = (f1.cmte_id)::text) AND (fec_yr.fec_election_yr >= f1.rpt_yr))))
     LEFT JOIN cycles ON (((fec_yr.cmte_id)::text = (cycles.cmte_id)::text)))
     LEFT JOIN dates ON (((fec_yr.cmte_id)::text = (dates.cmte_id)::text)))
     LEFT JOIN candidates ON (((fec_yr.cmte_id)::text = (candidates.cmte_id)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cmte_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~~ 'C%'::text)))))
  ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC;

-- b) drop old `MV`

DROP MATERIALIZED VIEW public.ofec_committee_history_mv;

-- c) recreate `MV` with new logic

CREATE MATERIALIZED VIEW public.ofec_committee_history_mv AS
WITH cycles AS (
         SELECT cmte_valid_fec_yr.cmte_id,
            (array_agg(cmte_valid_fec_yr.fec_election_yr))::integer[] AS cycles,
            max(cmte_valid_fec_yr.fec_election_yr) AS max_cycle
           FROM disclosure.cmte_valid_fec_yr
          GROUP BY cmte_valid_fec_yr.cmte_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F1'::text)) AS last_f1_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        ), candidates AS (
         SELECT cand_cmte_linkage.cmte_id,
            (array_agg(DISTINCT cand_cmte_linkage.cand_id))::text[] AS candidate_ids
           FROM disclosure.cand_cmte_linkage
          GROUP BY cand_cmte_linkage.cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cmte_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.fec_election_yr AS cycle,
    fec_yr.cmte_id AS committee_id,
    fec_yr.cmte_nm AS name,
    fec_yr.tres_nm AS treasurer_name,
    to_tsvector((fec_yr.tres_nm)::text) AS treasurer_text,
    f1.org_tp AS organization_type,
    expand_organization_type((f1.org_tp)::text) AS organization_type_full,
    fec_yr.cmte_st1 AS street_1,
    fec_yr.cmte_st2 AS street_2,
    fec_yr.cmte_city AS city,
    fec_yr.cmte_st AS state,
    expand_state((fec_yr.cmte_st)::text) AS state_full,
    fec_yr.cmte_zip AS zip,
    f1.tres_city AS treasurer_city,
    f1.tres_f_nm AS treasurer_name_1,
    f1.tres_l_nm AS treasurer_name_2,
    f1.tres_m_nm AS treasurer_name_middle,
    f1.tres_ph_num AS treasurer_phone,
    f1.tres_prefix AS treasurer_name_prefix,
    f1.tres_st AS treasurer_state,
    f1.tres_st1 AS treasurer_street_1,
    f1.tres_st2 AS treasurer_street_2,
    f1.tres_suffix AS treasurer_name_suffix,
    f1.tres_title AS treasurer_name_title,
    f1.tres_zip AS treasurer_zip,
    f1.cust_rec_city AS custodian_city,
    f1.cust_rec_f_nm AS custodian_name_1,
    f1.cust_rec_l_nm AS custodian_name_2,
    f1.cust_rec_m_nm AS custodian_name_middle,
    f1.cust_rec_nm AS custodian_name_full,
    f1.cust_rec_ph_num AS custodian_phone,
    f1.cust_rec_prefix AS custodian_name_prefix,
    f1.cust_rec_st AS custodian_state,
    f1.cust_rec_st1 AS custodian_street_1,
    f1.cust_rec_st2 AS custodian_street_2,
    f1.cust_rec_suffix AS custodian_name_suffix,
    f1.cust_rec_title AS custodian_name_title,
    f1.cust_rec_zip AS custodian_zip,
    fec_yr.cmte_email AS email,
    f1.cmte_fax AS fax,
    fec_yr.cmte_url AS website,
    f1.form_tp AS form_type,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp AS party_type,
    f1.cand_pty_tp_desc AS party_type_full,
    f1.qual_dt AS qualifying_date,
    ((dates.first_file_date)::text)::date AS first_file_date,
    ((dates.last_file_date)::text)::date AS last_file_date,
    ((dates.last_f1_date)::text)::date AS last_f1_date,
    fec_yr.cmte_dsgn AS designation,
    expand_committee_designation((fec_yr.cmte_dsgn)::text) AS designation_full,
    fec_yr.cmte_tp AS committee_type,
    expand_committee_type((fec_yr.cmte_tp)::text) AS committee_type_full,
    fec_yr.cmte_filing_freq AS filing_frequency,
    fec_yr.cmte_pty_affiliation AS party,
    fec_yr.cmte_pty_affiliation_desc AS party_full,
    cycles.cycles,
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids,
    f1.affiliated_cmte_nm AS affiliated_committee_name
   FROM ((((disclosure.cmte_valid_fec_yr fec_yr
     LEFT JOIN fec_vsum_f1_vw f1 ON ((((fec_yr.cmte_id)::text = (f1.cmte_id)::text) AND (fec_yr.fec_election_yr >= f1.rpt_yr))))
     LEFT JOIN cycles ON (((fec_yr.cmte_id)::text = (cycles.cmte_id)::text)))
     LEFT JOIN dates ON (((fec_yr.cmte_id)::text = (dates.cmte_id)::text)))
     LEFT JOIN candidates ON (((fec_yr.cmte_id)::text = (candidates.cmte_id)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cmte_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~~ 'C%'::text)))))
  ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC;

--Permissions

ALTER TABLE public.ofec_committee_history_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_history_mv TO fec;
GRANT SELECT ON TABLE public.ofec_committee_history_mv TO fec_read;

--Indices

CREATE UNIQUE INDEX ofec_committee_history_mv_idx_idx1
ON public.ofec_committee_history_mv
USING btree (idx);

CREATE INDEX ofec_committee_history_mv_committee_id_idx1
ON public.ofec_committee_history_mv
USING btree (committee_id);

CREATE INDEX ofec_committee_history_mv_cycle_committee_id_idx1
ON public.ofec_committee_history_mv
USING btree (cycle, committee_id);

CREATE INDEX ofec_committee_history_mv_cycle_idx1
ON public.ofec_committee_history_mv
USING btree (cycle);

CREATE INDEX ofec_committee_history_mv_designation_idx1
ON public.ofec_committee_history_mv
USING btree (designation);

CREATE INDEX ofec_committee_history_mv_first_file_date_idx
ON public.ofec_committee_history_mv
USING btree (first_file_date);

CREATE INDEX ofec_committee_history_mv_name_idx1
ON public.ofec_committee_history_mv
USING btree (name);

CREATE INDEX ofec_committee_history_mv_state_idx1
ON public.ofec_committee_history_mv
USING btree (state);

CREATE INDEX ofec_committee_history_mv_comid_state_idx1
ON public.ofec_committee_history_mv
USING btree (committee_id, state);


-- d) `create or replace `public.ofec_committee_history_vw` -> `select all` from new `MV`

CREATE OR REPLACE VIEW public.ofec_committee_history_vw AS
SELECT * FROM public.ofec_committee_history_mv
