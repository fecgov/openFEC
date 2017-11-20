SET search_path = public, pg_catalog;

--
-- Name: ofec_candidate_history_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_history_mv AS
 WITH fec_yr AS (
         SELECT DISTINCT ON (cand.cand_valid_yr_id) cand.cand_valid_yr_id,
            cand.cand_id,
            cand.fec_election_yr,
            cand.cand_election_yr,
            cand.cand_status,
            cand.cand_ici,
            cand.cand_office,
            cand.cand_office_st,
            cand.cand_office_district,
            cand.cand_pty_affiliation,
            cand.cand_name,
            cand.cand_st1,
            cand.cand_st2,
            cand.cand_city,
            cand.cand_state,
            cand.cand_zip,
            cand.race_pk,
            cand.lst_updt_dt,
            cand.latest_receipt_dt,
            cand.user_id_entered,
            cand.date_entered,
            cand.user_id_changed,
            cand.date_changed,
            cand.ref_cand_pk,
            cand.ref_lst_updt_dt,
            cand.pg_date
           FROM (disclosure.cand_valid_fec_yr cand
             LEFT JOIN disclosure.cand_cmte_linkage link ON ((((cand.cand_id)::text = (link.cand_id)::text) AND (cand.fec_election_yr = link.fec_election_yr) AND ((link.linkage_type)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[])))))
        ), elections AS (
         SELECT dedup.cand_id,
            max(dedup.cand_election_yr) AS active_through,
            (array_agg(dedup.cand_election_yr))::integer[] AS election_years,
            (array_agg(dedup.cand_office_district))::text[] AS election_districts
           FROM ( SELECT DISTINCT ON (fec_yr_1.cand_id, fec_yr_1.cand_election_yr) fec_yr_1.cand_valid_yr_id,
                    fec_yr_1.cand_id,
                    fec_yr_1.fec_election_yr,
                    fec_yr_1.cand_election_yr,
                    fec_yr_1.cand_status,
                    fec_yr_1.cand_ici,
                    fec_yr_1.cand_office,
                    fec_yr_1.cand_office_st,
                    fec_yr_1.cand_office_district,
                    fec_yr_1.cand_pty_affiliation,
                    fec_yr_1.cand_name,
                    fec_yr_1.cand_st1,
                    fec_yr_1.cand_st2,
                    fec_yr_1.cand_city,
                    fec_yr_1.cand_state,
                    fec_yr_1.cand_zip,
                    fec_yr_1.race_pk,
                    fec_yr_1.lst_updt_dt,
                    fec_yr_1.latest_receipt_dt,
                    fec_yr_1.user_id_entered,
                    fec_yr_1.date_entered,
                    fec_yr_1.user_id_changed,
                    fec_yr_1.date_changed,
                    fec_yr_1.ref_cand_pk,
                    fec_yr_1.ref_lst_updt_dt,
                    fec_yr_1.pg_date
                   FROM fec_yr fec_yr_1
                  ORDER BY fec_yr_1.cand_id, fec_yr_1.cand_election_yr) dedup
          GROUP BY dedup.cand_id
        ), cycles AS (
         SELECT fec_yr_1.cand_id,
            (array_agg(fec_yr_1.fec_election_yr))::integer[] AS cycles,
            max(fec_yr_1.fec_election_yr) AS max_cycle
           FROM fec_yr fec_yr_1
          GROUP BY fec_yr_1.cand_id
        ), dates AS (
         SELECT f_rpt_or_form_sub.cand_cmte_id AS cand_id,
            min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
            max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
            max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE ((f_rpt_or_form_sub.form_tp)::text = 'F2'::text)) AS last_f2_date
           FROM disclosure.f_rpt_or_form_sub
          GROUP BY f_rpt_or_form_sub.cand_cmte_id
        )
 SELECT DISTINCT ON (fec_yr.cand_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.lst_updt_dt AS load_date,
    fec_yr.fec_election_yr AS two_year_period,
    fec_yr.cand_election_yr AS candidate_election_year,
    fec_yr.cand_id AS candidate_id,
    fec_yr.cand_name AS name,
    fec_yr.cand_state AS address_state,
    fec_yr.cand_city AS address_city,
    fec_yr.cand_st1 AS address_street_1,
    fec_yr.cand_st2 AS address_street_2,
    fec_yr.cand_zip AS address_zip,
    fec_yr.cand_ici AS incumbent_challenge,
    expand_candidate_incumbent((fec_yr.cand_ici)::text) AS incumbent_challenge_full,
    fec_yr.cand_status AS candidate_status,
    (inactive.cand_id IS NOT NULL) AS candidate_inactive,
    fec_yr.cand_office AS office,
    expand_office((fec_yr.cand_office)::text) AS office_full,
    fec_yr.cand_office_st AS state,
    fec_yr.cand_office_district AS district,
    (fec_yr.cand_office_district)::integer AS district_number,
    fec_yr.cand_pty_affiliation AS party,
    clean_party((ref_party.pty_desc)::text) AS party_full,
    cycles.cycles,
    ((dates.first_file_date)::text)::date AS first_file_date,
    ((dates.last_file_date)::text)::date AS last_file_date,
    ((dates.last_f2_date)::text)::date AS last_f2_date,
    elections.election_years,
    elections.election_districts,
    elections.active_through
   FROM (((((fec_yr
     LEFT JOIN cycles USING (cand_id))
     LEFT JOIN elections USING (cand_id))
     LEFT JOIN dates USING (cand_id))
     LEFT JOIN disclosure.cand_inactive inactive ON ((((fec_yr.cand_id)::text = (inactive.cand_id)::text) AND (fec_yr.fec_election_yr < inactive.election_yr))))
     LEFT JOIN staging.ref_pty ref_party ON (((fec_yr.cand_pty_affiliation)::text = (ref_party.pty_cd)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cand_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~ similar_escape('(P|S|H)%'::text, NULL::text))))))
  WITH NO DATA;


ALTER TABLE ofec_candidate_history_mv OWNER TO fec;

--
-- Name: ofec_candidate_detail_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_detail_mv AS
 SELECT DISTINCT ON (ofec_candidate_history_mv.candidate_id) ofec_candidate_history_mv.idx,
    ofec_candidate_history_mv.load_date,
    ofec_candidate_history_mv.two_year_period,
    ofec_candidate_history_mv.candidate_election_year,
    ofec_candidate_history_mv.candidate_id,
    ofec_candidate_history_mv.name,
    ofec_candidate_history_mv.address_state,
    ofec_candidate_history_mv.address_city,
    ofec_candidate_history_mv.address_street_1,
    ofec_candidate_history_mv.address_street_2,
    ofec_candidate_history_mv.address_zip,
    ofec_candidate_history_mv.incumbent_challenge,
    ofec_candidate_history_mv.incumbent_challenge_full,
    ofec_candidate_history_mv.candidate_status,
    ofec_candidate_history_mv.candidate_inactive,
    ofec_candidate_history_mv.office,
    ofec_candidate_history_mv.office_full,
    ofec_candidate_history_mv.state,
    ofec_candidate_history_mv.district,
    ofec_candidate_history_mv.district_number,
    ofec_candidate_history_mv.party,
    ofec_candidate_history_mv.party_full,
    ofec_candidate_history_mv.cycles,
    ofec_candidate_history_mv.first_file_date,
    ofec_candidate_history_mv.last_file_date,
    ofec_candidate_history_mv.last_f2_date,
    ofec_candidate_history_mv.election_years,
    ofec_candidate_history_mv.election_districts,
    ofec_candidate_history_mv.active_through
   FROM ofec_candidate_history_mv
  ORDER BY ofec_candidate_history_mv.candidate_id, ofec_candidate_history_mv.two_year_period DESC
  WITH NO DATA;


ALTER TABLE ofec_candidate_detail_mv OWNER TO fec;

--
-- Name: ofec_candidate_election_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_election_mv AS
 WITH years AS (
         SELECT ofec_candidate_detail_mv.candidate_id,
            unnest(ofec_candidate_detail_mv.election_years) AS cand_election_year
           FROM ofec_candidate_detail_mv
        )
 SELECT DISTINCT ON (years.candidate_id, years.cand_election_year) years.candidate_id,
    years.cand_election_year,
    GREATEST(prev.cand_election_year, (years.cand_election_year - election_duration(substr((years.candidate_id)::text, 1, 1)))) AS prev_election_year
   FROM (years
     LEFT JOIN years prev ON ((((years.candidate_id)::text = (prev.candidate_id)::text) AND (prev.cand_election_year < years.cand_election_year))))
  ORDER BY years.candidate_id, years.cand_election_year, prev.cand_election_year DESC
  WITH NO DATA;


ALTER TABLE ofec_candidate_election_mv OWNER TO fec;

--
-- Name: ofec_committee_history_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_committee_history_mv AS
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
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids
   FROM ((((disclosure.cmte_valid_fec_yr fec_yr
     LEFT JOIN fec_vsum_f1_vw f1 ON ((((fec_yr.cmte_id)::text = (f1.cmte_id)::text) AND (fec_yr.fec_election_yr >= f1.rpt_yr))))
     LEFT JOIN cycles ON (((fec_yr.cmte_id)::text = (cycles.cmte_id)::text)))
     LEFT JOIN dates ON (((fec_yr.cmte_id)::text = (dates.cmte_id)::text)))
     LEFT JOIN candidates ON (((fec_yr.cmte_id)::text = (candidates.cmte_id)::text)))
  WHERE ((cycles.max_cycle >= (1979)::numeric) AND (NOT ((fec_yr.cmte_id)::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
           FROM unverified_filers_vw
          WHERE ((unverified_filers_vw.cmte_id)::text ~~ 'C%'::text)))))
  ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC
  WITH NO DATA;


ALTER TABLE ofec_committee_history_mv OWNER TO fec;

--
-- Name: ofec_house_senate_paper_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_house_senate_paper_amendments_mv AS
 WITH RECURSIVE oldest_filing_paper AS (
         SELECT nml_form_3.cmte_id,
            nml_form_3.rpt_yr,
            nml_form_3.rpt_tp,
            nml_form_3.amndt_ind,
            nml_form_3.receipt_dt,
            nml_form_3.file_num,
            nml_form_3.prev_file_num,
            nml_form_3.mst_rct_file_num,
            ARRAY[nml_form_3.file_num] AS amendment_chain,
            ARRAY[nml_form_3.receipt_dt] AS date_chain,
            1 AS depth,
            nml_form_3.file_num AS last
           FROM disclosure.nml_form_3
          WHERE (((nml_form_3.amndt_ind)::text = 'N'::text) AND (nml_form_3.file_num < (0)::numeric))
        UNION
         SELECT f3.cmte_id,
            f3.rpt_yr,
            f3.rpt_tp,
            f3.amndt_ind,
            f3.receipt_dt,
            f3.file_num,
            f3.prev_file_num,
            f3.mst_rct_file_num,
            ((oldest.amendment_chain || f3.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.date_chain || f3.receipt_dt) AS "timestamp",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing_paper oldest,
            disclosure.nml_form_3 f3
          WHERE (((f3.amndt_ind)::text = 'A'::text) AND ((f3.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3.rpt_yr = oldest.rpt_yr) AND ((f3.cmte_id)::text = (oldest.cmte_id)::text) AND (f3.file_num < (0)::numeric) AND (f3.receipt_dt > oldest.date_chain[array_length(oldest.date_chain, 1)]))
        ), longest_path AS (
         SELECT b.cmte_id,
            b.rpt_yr,
            b.rpt_tp,
            b.amndt_ind,
            b.receipt_dt,
            b.file_num,
            b.prev_file_num,
            b.mst_rct_file_num,
            b.amendment_chain,
            b.date_chain,
            b.depth,
            b.last
           FROM (oldest_filing_paper a
             LEFT JOIN oldest_filing_paper b ON ((a.file_num = b.file_num)))
          WHERE (a.depth < b.depth)
        ), filtered_longest_path AS (
         SELECT DISTINCT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            old_f.mst_rct_file_num,
            old_f.amendment_chain,
            old_f.date_chain,
            old_f.depth,
            old_f.last
           FROM (oldest_filing_paper old_f
             JOIN longest_path lp ON ((old_f.last = lp.last)))
          WHERE (old_f.file_num <> lp.file_num)
        UNION ALL
         SELECT longest_path.cmte_id,
            longest_path.rpt_yr,
            longest_path.rpt_tp,
            longest_path.amndt_ind,
            longest_path.receipt_dt,
            longest_path.file_num,
            longest_path.prev_file_num,
            longest_path.mst_rct_file_num,
            longest_path.amendment_chain,
            longest_path.date_chain,
            longest_path.depth,
            longest_path.last
           FROM longest_path
        UNION ALL
         SELECT DISTINCT ofp.cmte_id,
            ofp.rpt_yr,
            ofp.rpt_tp,
            ofp.amndt_ind,
            ofp.receipt_dt,
            ofp.file_num,
            ofp.prev_file_num,
            ofp.mst_rct_file_num,
            ofp.amendment_chain,
            ofp.date_chain,
            ofp.depth,
            ofp.last
           FROM oldest_filing_paper ofp
          WHERE (NOT (ofp.last IN ( SELECT longest_path.last
                   FROM longest_path)))
  ORDER BY 11 DESC
        )
 SELECT row_number() OVER () AS idx,
    filtered_longest_path.cmte_id,
    filtered_longest_path.rpt_yr,
    filtered_longest_path.rpt_tp,
    filtered_longest_path.amndt_ind,
    filtered_longest_path.receipt_dt,
    filtered_longest_path.file_num,
    filtered_longest_path.prev_file_num,
    filtered_longest_path.mst_rct_file_num,
    filtered_longest_path.amendment_chain
   FROM filtered_longest_path
  WITH NO DATA;


ALTER TABLE ofec_house_senate_paper_amendments_mv OWNER TO fec;

--
-- Name: ofec_pac_party_paper_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_pac_party_paper_amendments_mv AS
 WITH RECURSIVE oldest_filing_paper AS (
         SELECT nml_form_3x.cmte_id,
            nml_form_3x.rpt_yr,
            nml_form_3x.rpt_tp,
            nml_form_3x.amndt_ind,
            nml_form_3x.receipt_dt,
            nml_form_3x.file_num,
            nml_form_3x.prev_file_num,
            nml_form_3x.mst_rct_file_num,
            ARRAY[nml_form_3x.file_num] AS amendment_chain,
            ARRAY[nml_form_3x.receipt_dt] AS date_chain,
            1 AS depth,
            nml_form_3x.file_num AS last
           FROM disclosure.nml_form_3x
          WHERE (((nml_form_3x.amndt_ind)::text = 'N'::text) AND (nml_form_3x.file_num < (0)::numeric))
        UNION
         SELECT f3x.cmte_id,
            f3x.rpt_yr,
            f3x.rpt_tp,
            f3x.amndt_ind,
            f3x.receipt_dt,
            f3x.file_num,
            f3x.prev_file_num,
            f3x.mst_rct_file_num,
            ((oldest.amendment_chain || f3x.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.date_chain || f3x.receipt_dt) AS "timestamp",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing_paper oldest,
            disclosure.nml_form_3x f3x
          WHERE (((f3x.amndt_ind)::text = 'A'::text) AND ((f3x.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3x.rpt_yr = oldest.rpt_yr) AND ((f3x.cmte_id)::text = (oldest.cmte_id)::text) AND (f3x.file_num < (0)::numeric) AND (f3x.receipt_dt > oldest.date_chain[array_length(oldest.date_chain, 1)]))
        ), longest_path AS (
         SELECT b.cmte_id,
            b.rpt_yr,
            b.rpt_tp,
            b.amndt_ind,
            b.receipt_dt,
            b.file_num,
            b.prev_file_num,
            b.mst_rct_file_num,
            b.amendment_chain,
            b.date_chain,
            b.depth,
            b.last
           FROM (oldest_filing_paper a
             LEFT JOIN oldest_filing_paper b ON ((a.file_num = b.file_num)))
          WHERE (a.depth < b.depth)
        ), filtered_longest_path AS (
         SELECT DISTINCT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            old_f.mst_rct_file_num,
            old_f.amendment_chain,
            old_f.date_chain,
            old_f.depth,
            old_f.last
           FROM oldest_filing_paper old_f,
            longest_path lp
          WHERE (old_f.date_chain <= lp.date_chain)
          ORDER BY old_f.depth DESC
        ), paper_recent_filing AS (
         SELECT a.cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_dt,
            a.file_num,
            a.prev_file_num,
            a.mst_rct_file_num,
            a.amendment_chain,
            a.date_chain,
            a.depth,
            a.last
           FROM (filtered_longest_path a
             LEFT JOIN filtered_longest_path b ON ((((a.cmte_id)::text = (b.cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cmte_id IS NULL)
        ), paper_filer_chain AS (
         SELECT flp.cmte_id,
            flp.rpt_yr,
            flp.rpt_tp,
            flp.amndt_ind,
            flp.receipt_dt,
            flp.file_num,
            flp.prev_file_num,
            prf.file_num AS mst_rct_file_num,
            flp.amendment_chain
           FROM (filtered_longest_path flp
             JOIN paper_recent_filing prf ON ((((flp.cmte_id)::text = (prf.cmte_id)::text) AND (flp.last = prf.last))))
        )
 SELECT row_number() OVER () AS idx,
    paper_filer_chain.cmte_id,
    paper_filer_chain.rpt_yr,
    paper_filer_chain.rpt_tp,
    paper_filer_chain.amndt_ind,
    paper_filer_chain.receipt_dt,
    paper_filer_chain.file_num,
    paper_filer_chain.prev_file_num,
    paper_filer_chain.mst_rct_file_num,
    paper_filer_chain.amendment_chain
   FROM paper_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_pac_party_paper_amendments_mv OWNER TO fec;

--
-- Name: ofec_presidential_paper_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_presidential_paper_amendments_mv AS
 WITH RECURSIVE oldest_filing_paper AS (
         SELECT nml_form_3p.cmte_id,
            nml_form_3p.rpt_yr,
            nml_form_3p.rpt_tp,
            nml_form_3p.amndt_ind,
            nml_form_3p.receipt_dt,
            nml_form_3p.file_num,
            nml_form_3p.prev_file_num,
            nml_form_3p.mst_rct_file_num,
            ARRAY[nml_form_3p.file_num] AS amendment_chain,
            ARRAY[nml_form_3p.receipt_dt] AS date_chain,
            1 AS depth,
            nml_form_3p.file_num AS last
           FROM disclosure.nml_form_3p
          WHERE (((nml_form_3p.amndt_ind)::text = 'N'::text) AND (nml_form_3p.file_num < (0)::numeric))
        UNION
         SELECT f3p.cmte_id,
            f3p.rpt_yr,
            f3p.rpt_tp,
            f3p.amndt_ind,
            f3p.receipt_dt,
            f3p.file_num,
            f3p.prev_file_num,
            f3p.mst_rct_file_num,
            ((oldest.amendment_chain || f3p.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.date_chain || f3p.receipt_dt) AS "timestamp",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing_paper oldest,
            disclosure.nml_form_3p f3p
          WHERE (((f3p.amndt_ind)::text = 'A'::text) AND ((f3p.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3p.rpt_yr = oldest.rpt_yr) AND ((f3p.cmte_id)::text = (oldest.cmte_id)::text) AND (f3p.file_num < (0)::numeric) AND (f3p.receipt_dt > oldest.date_chain[array_length(oldest.date_chain, 1)]))
        ), longest_path AS (
         SELECT b.cmte_id,
            b.rpt_yr,
            b.rpt_tp,
            b.amndt_ind,
            b.receipt_dt,
            b.file_num,
            b.prev_file_num,
            b.mst_rct_file_num,
            b.amendment_chain,
            b.date_chain,
            b.depth,
            b.last
           FROM (oldest_filing_paper a
             LEFT JOIN oldest_filing_paper b ON ((a.file_num = b.file_num)))
          WHERE (a.depth < b.depth)
        ), filtered_longest_path AS (
         SELECT DISTINCT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            old_f.mst_rct_file_num,
            old_f.amendment_chain,
            old_f.date_chain,
            old_f.depth,
            old_f.last
           FROM oldest_filing_paper old_f,
            longest_path lp
          WHERE (old_f.date_chain <= lp.date_chain)
          ORDER BY old_f.depth DESC
        ), paper_recent_filing AS (
         SELECT a.cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_dt,
            a.file_num,
            a.prev_file_num,
            a.mst_rct_file_num,
            a.amendment_chain,
            a.date_chain,
            a.depth,
            a.last
           FROM (filtered_longest_path a
             LEFT JOIN filtered_longest_path b ON ((((a.cmte_id)::text = (b.cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cmte_id IS NULL)
        ), paper_filer_chain AS (
         SELECT flp.cmte_id,
            flp.rpt_yr,
            flp.rpt_tp,
            flp.amndt_ind,
            flp.receipt_dt,
            flp.file_num,
            flp.prev_file_num,
            prf.file_num AS mst_rct_file_num,
            flp.amendment_chain
           FROM (filtered_longest_path flp
             JOIN paper_recent_filing prf ON ((((flp.cmte_id)::text = (prf.cmte_id)::text) AND (flp.last = prf.last))))
        )
 SELECT row_number() OVER () AS idx,
    paper_filer_chain.cmte_id,
    paper_filer_chain.rpt_yr,
    paper_filer_chain.rpt_tp,
    paper_filer_chain.amndt_ind,
    paper_filer_chain.receipt_dt,
    paper_filer_chain.file_num,
    paper_filer_chain.prev_file_num,
    paper_filer_chain.mst_rct_file_num,
    paper_filer_chain.amendment_chain
   FROM paper_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_presidential_paper_amendments_mv OWNER TO fec;

--
-- Name: ofec_filings_amendments_all_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_filings_amendments_all_mv AS
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
           FROM ofec_amendments_mv
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
           FROM ofec_presidential_paper_amendments_mv
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
           FROM ofec_house_senate_paper_amendments_mv
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
           FROM ofec_pac_party_paper_amendments_mv
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
  WITH NO DATA;


ALTER TABLE ofec_filings_amendments_all_mv OWNER TO fec;

--
-- Name: ofec_filings_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_filings_mv AS
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
            get_cycle(filing_history.rpt_yr) AS cycle,
            filing_history.rpt_tp AS report_type,
            filing_history.to_from_ind AS document_type,
            expand_document((filing_history.to_from_ind)::text) AS document_type_full,
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
            report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, (filing_history.form_tp)::text) AS pdf_url,
            means_filed((filing_history.begin_image_num)::text) AS means_filed,
            report_html_url(means_filed((filing_history.begin_image_num)::text), (filing_history.cand_cmte_id)::text, (filing_history.file_num)::text) AS html_url,
            report_fec_url((filing_history.begin_image_num)::text, (filing_history.file_num)::integer) AS fec_url,
            amendments.amendment_chain,
            amendments.mst_rct_file_num AS most_recent_file_number,
            is_amended((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS is_amended,
            is_most_recent((amendments.mst_rct_file_num)::integer, (amendments.file_num)::integer, (filing_history.form_tp)::text) AS most_recent,
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
             LEFT JOIN ofec_committee_history_mv com ON ((((filing_history.cand_cmte_id)::text = (com.committee_id)::text) AND ((get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN ofec_candidate_history_mv cand ON ((((filing_history.cand_cmte_id)::text = (cand.candidate_id)::text) AND ((get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
             LEFT JOIN staging.ref_rpt_tp report ON (((filing_history.rpt_tp)::text = (report.rpt_tp_cd)::text)))
             LEFT JOIN ofec_filings_amendments_all_mv amendments ON ((filing_history.file_num = amendments.file_num)))
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
            get_cycle(filing_history.rpt_yr) AS cycle,
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
            report_pdf_url_or_null((filing_history.begin_image_num)::text, filing_history.rpt_yr, (com.committee_type)::text, 'RFAI'::text) AS pdf_url,
            means_filed((filing_history.begin_image_num)::text) AS means_filed,
            report_html_url(means_filed((filing_history.begin_image_num)::text), (filing_history.id)::text, (filing_history.file_num)::text) AS html_url,
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
             LEFT JOIN ofec_committee_history_mv com ON ((((filing_history.id)::text = (com.committee_id)::text) AND ((get_cycle(filing_history.rpt_yr))::numeric = com.cycle))))
             LEFT JOIN ofec_candidate_history_mv cand ON ((((filing_history.id)::text = (cand.candidate_id)::text) AND ((get_cycle(filing_history.rpt_yr))::numeric = cand.two_year_period))))
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
  WITH NO DATA;


ALTER TABLE ofec_filings_mv OWNER TO fec;

--
-- Name: ofec_totals_combined_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_combined_mv AS
 WITH last_subset AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.orig_sub_id,
            v_sum_and_det_sum_report.cmte_id,
            v_sum_and_det_sum_report.coh_cop,
            v_sum_and_det_sum_report.debts_owed_by_cmte,
            v_sum_and_det_sum_report.debts_owed_to_cmte,
            v_sum_and_det_sum_report.net_op_exp,
            v_sum_and_det_sum_report.net_contb,
            v_sum_and_det_sum_report.rpt_yr,
            get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision)) DESC NULLS LAST
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
             LEFT JOIN ofec_filings_mv of ON ((ls.orig_sub_id = of.sub_id)))
        ), first AS (
         SELECT DISTINCT ON (v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr))) v_sum_and_det_sum_report.coh_bop AS cash_on_hand,
            v_sum_and_det_sum_report.cmte_id AS committee_id,
                CASE
                    WHEN (v_sum_and_det_sum_report.cvg_start_dt = (99999999)::numeric) THEN NULL::timestamp without time zone
                    ELSE (((v_sum_and_det_sum_report.cvg_start_dt)::text)::date)::timestamp without time zone
                END AS coverage_start_date,
            get_cycle(v_sum_and_det_sum_report.rpt_yr) AS cycle
           FROM disclosure.v_sum_and_det_sum_report
          WHERE ((get_cycle(v_sum_and_det_sum_report.rpt_yr) >= 1979) AND (((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F5'::text) OR (((v_sum_and_det_sum_report.form_tp_cd)::text = 'F5'::text) AND ((v_sum_and_det_sum_report.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])))) AND ((v_sum_and_det_sum_report.form_tp_cd)::text <> 'F6'::text))
          ORDER BY v_sum_and_det_sum_report.cmte_id, (get_cycle(v_sum_and_det_sum_report.rpt_yr)), (to_timestamp((v_sum_and_det_sum_report.cvg_end_dt)::double precision))
        ), committee_info AS (
         SELECT DISTINCT ON (cmte_valid_fec_yr.cmte_id, cmte_valid_fec_yr.fec_election_yr) cmte_valid_fec_yr.cmte_id,
            cmte_valid_fec_yr.fec_election_yr,
            cmte_valid_fec_yr.cmte_nm,
            cmte_valid_fec_yr.cmte_tp,
            cmte_valid_fec_yr.cmte_dsgn,
            cmte_valid_fec_yr.cmte_pty_affiliation_desc
           FROM disclosure.cmte_valid_fec_yr
        )
 SELECT get_cycle(vsd.rpt_yr) AS cycle,
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
    max(expand_committee_type((committee_info.cmte_tp)::text)) AS committee_type_full,
    max((committee_info.cmte_dsgn)::text) AS committee_designation,
    max(expand_committee_designation((committee_info.cmte_dsgn)::text)) AS committee_designation_full,
    max((committee_info.cmte_pty_affiliation_desc)::text) AS party_full,
    vsd.cmte_id AS committee_id,
    vsd.form_tp_cd AS form_type,
        CASE
            WHEN (max((last.form_type)::text) = ANY (ARRAY['F3'::text, 'F3P'::text])) THEN NULL::numeric
            ELSE sum(vsd.indt_exp_per)
        END AS independent_expenditures
   FROM (((disclosure.v_sum_and_det_sum_report vsd
     LEFT JOIN last ON ((((vsd.cmte_id)::text = (last.cmte_id)::text) AND (get_cycle(vsd.rpt_yr) = last.cycle))))
     LEFT JOIN first ON ((((vsd.cmte_id)::text = (first.committee_id)::text) AND (get_cycle(vsd.rpt_yr) = first.cycle))))
     LEFT JOIN committee_info ON ((((vsd.cmte_id)::text = (committee_info.cmte_id)::text) AND ((get_cycle(vsd.rpt_yr))::numeric = committee_info.fec_election_yr))))
  WHERE ((get_cycle(vsd.rpt_yr) >= 1979) AND (((vsd.form_tp_cd)::text <> 'F5'::text) OR (((vsd.form_tp_cd)::text = 'F5'::text) AND ((vsd.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])))) AND ((vsd.form_tp_cd)::text <> 'F6'::text))
  GROUP BY vsd.cmte_id, vsd.form_tp_cd, (get_cycle(vsd.rpt_yr))
  WITH NO DATA;


ALTER TABLE ofec_totals_combined_mv OWNER TO fec;

--
-- Name: ofec_totals_house_senate_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_house_senate_mv AS
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
   FROM (ofec_totals_combined_mv f3
     LEFT JOIN hs_cycle USING (committee_id, cycle))
  WHERE ((f3.form_type)::text = 'F3'::text)
  WITH NO DATA;


ALTER TABLE ofec_totals_house_senate_mv OWNER TO fec;

--
-- Name: ofec_totals_presidential_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_presidential_mv AS
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
   FROM ofec_totals_combined_mv
  WHERE ((ofec_totals_combined_mv.form_type)::text = 'F3P'::text)
  WITH NO DATA;


ALTER TABLE ofec_totals_presidential_mv OWNER TO fec;

--
-- Name: ofec_candidate_totals_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_totals_mv AS
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
           FROM ofec_totals_house_senate_mv
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
           FROM ofec_totals_presidential_mv
        ), cycle_totals AS (
         SELECT DISTINCT ON (link.cand_id, totals.cycle) link.cand_id AS candidate_id,
            max(election.cand_election_year) AS election_year,
            totals.cycle,
            false AS is_election,
            sum(totals.receipts) AS receipts,
            sum(totals.disbursements) AS disbursements,
            (sum(totals.receipts) > (0)::numeric) AS has_raised_funds,
            sum(totals.last_cash_on_hand_end_period) AS cash_on_hand_end_period,
            sum(totals.last_debts_owed_by_committee) AS debts_owed_by_committee,
            min(totals.coverage_start_date) AS coverage_start_date,
            max(totals.coverage_end_date) AS coverage_end_date,
            (array_agg(totals.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
           FROM ((ofec_cand_cmte_linkage_mv link
             JOIN totals ON ((((link.cmte_id)::text = (totals.committee_id)::text) AND (link.fec_election_yr = (totals.cycle)::numeric))))
             LEFT JOIN ofec_candidate_election_mv election ON ((((link.cand_id)::text = (election.candidate_id)::text) AND (totals.cycle <= election.cand_election_year) AND (totals.cycle > election.prev_election_year))))
          WHERE ((link.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[]))
          GROUP BY link.cand_id, election.cand_election_year, totals.cycle
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
         SELECT DISTINCT ON (totals.candidate_id, totals.election_year) totals.candidate_id,
            totals.election_year,
            totals.cash_on_hand_end_period,
            totals.debts_owed_by_committee,
            totals.federal_funds_flag
           FROM cycle_totals totals
          ORDER BY totals.candidate_id, totals.election_year, totals.cycle DESC
        ), election_totals AS (
         SELECT totals.candidate_id,
            totals.election_year,
            totals.election_year AS cycle,
            true AS is_election,
            totals.receipts,
            totals.disbursements,
            totals.has_raised_funds,
            latest.cash_on_hand_end_period,
            latest.debts_owed_by_committee,
            totals.coverage_start_date,
            totals.coverage_end_date,
            totals.federal_funds_flag
           FROM (election_aggregates totals
             JOIN election_latest latest USING (candidate_id, election_year))
        )
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
  WITH NO DATA;


ALTER TABLE ofec_candidate_totals_mv OWNER TO fec;

--
-- Name: ofec_candidate_flag; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_flag AS
 SELECT row_number() OVER () AS idx,
    ofec_candidate_history_mv.candidate_id,
    (array_agg(oct.has_raised_funds) @> ARRAY[true]) AS has_raised_funds,
    (array_agg(oct.federal_funds_flag) @> ARRAY[true]) AS federal_funds_flag
   FROM (ofec_candidate_history_mv
     LEFT JOIN ofec_candidate_totals_mv oct USING (candidate_id))
  GROUP BY ofec_candidate_history_mv.candidate_id
  WITH NO DATA;


ALTER TABLE ofec_candidate_flag OWNER TO fec;

--
-- Name: ofec_nicknames; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_nicknames (
    index bigint,
    candidate_id text,
    nickname text
);


ALTER TABLE ofec_nicknames OWNER TO fec;

--
-- Name: ofec_candidate_fulltext_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_fulltext_mv AS
 WITH nicknames AS (
         SELECT ofec_nicknames.candidate_id,
            string_agg(ofec_nicknames.nickname, ' '::text) AS nicknames
           FROM ofec_nicknames
          GROUP BY ofec_nicknames.candidate_id
        ), totals AS (
         SELECT link.cand_id AS candidate_id,
            sum(totals_1.receipts) AS receipts
           FROM (disclosure.cand_cmte_linkage link
             JOIN ofec_totals_combined_mv totals_1 ON ((((link.cmte_id)::text = (totals_1.committee_id)::text) AND (link.fec_election_yr = (totals_1.cycle)::numeric))))
          WHERE (((link.cmte_dsgn)::text = ANY ((ARRAY['P'::character varying, 'A'::character varying])::text[])) AND ((substr((link.cand_id)::text, 1, 1) = (link.cmte_tp)::text) OR ((link.cmte_tp)::text <> ALL ((ARRAY['P'::character varying, 'S'::character varying, 'H'::character varying])::text[]))))
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
    COALESCE(totals.receipts, (0)::numeric) AS receipts
   FROM ((ofec_candidate_detail_mv
     LEFT JOIN nicknames USING (candidate_id))
     LEFT JOIN totals USING (candidate_id))
  WITH NO DATA;


ALTER TABLE ofec_candidate_fulltext_mv OWNER TO fec;

--
-- Name: ofec_candidate_history_latest_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_candidate_history_latest_mv AS
 SELECT DISTINCT ON (cand.candidate_id, election.cand_election_year) cand.idx,
    cand.load_date,
    cand.two_year_period,
    cand.candidate_election_year,
    cand.candidate_id,
    cand.name,
    cand.address_state,
    cand.address_city,
    cand.address_street_1,
    cand.address_street_2,
    cand.address_zip,
    cand.incumbent_challenge,
    cand.incumbent_challenge_full,
    cand.candidate_status,
    cand.candidate_inactive,
    cand.office,
    cand.office_full,
    cand.state,
    cand.district,
    cand.district_number,
    cand.party,
    cand.party_full,
    cand.cycles,
    cand.first_file_date,
    cand.last_file_date,
    cand.last_f2_date,
    cand.election_years,
    cand.election_districts,
    cand.active_through,
    election.cand_election_year
   FROM (ofec_candidate_history_mv cand
     JOIN ofec_candidate_election_mv election ON ((((cand.candidate_id)::text = (election.candidate_id)::text) AND (cand.two_year_period <= (election.cand_election_year)::numeric) AND (cand.two_year_period > (election.prev_election_year)::numeric))))
  ORDER BY cand.candidate_id, election.cand_election_year, cand.two_year_period DESC
  WITH NO DATA;


ALTER TABLE ofec_candidate_history_latest_mv OWNER TO fec;

--
-- Name: ofec_committee_detail_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_committee_detail_mv AS
 SELECT DISTINCT ON (ofec_committee_history_mv.committee_id) ofec_committee_history_mv.idx,
    ofec_committee_history_mv.cycle,
    ofec_committee_history_mv.committee_id,
    ofec_committee_history_mv.name,
    ofec_committee_history_mv.treasurer_name,
    ofec_committee_history_mv.treasurer_text,
    ofec_committee_history_mv.organization_type,
    ofec_committee_history_mv.organization_type_full,
    ofec_committee_history_mv.street_1,
    ofec_committee_history_mv.street_2,
    ofec_committee_history_mv.city,
    ofec_committee_history_mv.state,
    ofec_committee_history_mv.state_full,
    ofec_committee_history_mv.zip,
    ofec_committee_history_mv.treasurer_city,
    ofec_committee_history_mv.treasurer_name_1,
    ofec_committee_history_mv.treasurer_name_2,
    ofec_committee_history_mv.treasurer_name_middle,
    ofec_committee_history_mv.treasurer_phone,
    ofec_committee_history_mv.treasurer_name_prefix,
    ofec_committee_history_mv.treasurer_state,
    ofec_committee_history_mv.treasurer_street_1,
    ofec_committee_history_mv.treasurer_street_2,
    ofec_committee_history_mv.treasurer_name_suffix,
    ofec_committee_history_mv.treasurer_name_title,
    ofec_committee_history_mv.treasurer_zip,
    ofec_committee_history_mv.custodian_city,
    ofec_committee_history_mv.custodian_name_1,
    ofec_committee_history_mv.custodian_name_2,
    ofec_committee_history_mv.custodian_name_middle,
    ofec_committee_history_mv.custodian_name_full,
    ofec_committee_history_mv.custodian_phone,
    ofec_committee_history_mv.custodian_name_prefix,
    ofec_committee_history_mv.custodian_state,
    ofec_committee_history_mv.custodian_street_1,
    ofec_committee_history_mv.custodian_street_2,
    ofec_committee_history_mv.custodian_name_suffix,
    ofec_committee_history_mv.custodian_name_title,
    ofec_committee_history_mv.custodian_zip,
    ofec_committee_history_mv.email,
    ofec_committee_history_mv.fax,
    ofec_committee_history_mv.website,
    ofec_committee_history_mv.form_type,
    ofec_committee_history_mv.leadership_pac,
    ofec_committee_history_mv.lobbyist_registrant_pac,
    ofec_committee_history_mv.party_type,
    ofec_committee_history_mv.party_type_full,
    ofec_committee_history_mv.qualifying_date,
    ofec_committee_history_mv.first_file_date,
    ofec_committee_history_mv.last_file_date,
    ofec_committee_history_mv.last_f1_date,
    ofec_committee_history_mv.designation,
    ofec_committee_history_mv.designation_full,
    ofec_committee_history_mv.committee_type,
    ofec_committee_history_mv.committee_type_full,
    ofec_committee_history_mv.filing_frequency,
    ofec_committee_history_mv.party,
    ofec_committee_history_mv.party_full,
    ofec_committee_history_mv.cycles,
    ofec_committee_history_mv.candidate_ids
   FROM ofec_committee_history_mv
  ORDER BY ofec_committee_history_mv.committee_id, ofec_committee_history_mv.cycle DESC
  WITH NO DATA;


ALTER TABLE ofec_committee_detail_mv OWNER TO fec;

--
-- Name: ofec_pacronyms; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_pacronyms (
    index bigint,
    "PACRONYM" text,
    "ID NUMBER" text,
    "FULL NAME" text,
    "CITY" text,
    "STATE" text,
    "CONNECTED ORGANIZATION OR SPONSOR NAME" text,
    "DESIGNATION" text,
    "COMMITTEE TYPE" text
);


ALTER TABLE ofec_pacronyms OWNER TO fec;

--
-- Name: ofec_committee_fulltext_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_committee_fulltext_mv AS
 WITH pacronyms AS (
         SELECT ofec_pacronyms."ID NUMBER" AS committee_id,
            string_agg(ofec_pacronyms."PACRONYM", ' '::text) AS pacronyms
           FROM ofec_pacronyms
          GROUP BY ofec_pacronyms."ID NUMBER"
        ), totals AS (
         SELECT ofec_totals_combined_mv.committee_id,
            sum(ofec_totals_combined_mv.receipts) AS receipts
           FROM ofec_totals_combined_mv
          GROUP BY ofec_totals_combined_mv.committee_id
        )
 SELECT DISTINCT ON (committee_id) row_number() OVER () AS idx,
    committee_id AS id,
    cd.name,
        CASE
            WHEN (cd.name IS NOT NULL) THEN ((setweight(to_tsvector((cd.name)::text), 'A'::"char") || setweight(to_tsvector(COALESCE(pac.pacronyms, ''::text)), 'A'::"char")) || setweight(to_tsvector((committee_id)::text), 'B'::"char"))
            ELSE NULL::tsvector
        END AS fulltxt,
    COALESCE(totals.receipts, (0)::numeric) AS receipts
   FROM ((ofec_committee_detail_mv cd
     LEFT JOIN pacronyms pac USING (committee_id))
     LEFT JOIN totals USING (committee_id))
  WITH NO DATA;


ALTER TABLE ofec_committee_fulltext_mv OWNER TO fec;

--
-- Name: ofec_committee_totals; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_committee_totals (
    committee_id character varying(9),
    cycle numeric(10,0),
    receipts numeric
);


ALTER TABLE ofec_committee_totals OWNER TO fec;

--
-- Name: ofec_communication_cost_aggregate_candidate_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_communication_cost_aggregate_candidate_mv AS
 SELECT row_number() OVER () AS idx,
    fec_fitem_f76_vw.s_o_ind AS support_oppose_indicator,
    fec_fitem_f76_vw.org_id AS cmte_id,
    fec_fitem_f76_vw.s_o_cand_id AS cand_id,
    sum(fec_fitem_f76_vw.communication_cost) AS total,
    count(fec_fitem_f76_vw.communication_cost) AS count,
    ((date_part('year'::text, fec_fitem_f76_vw.communication_dt))::integer + ((date_part('year'::text, fec_fitem_f76_vw.communication_dt))::integer % 2)) AS cycle
   FROM fec_fitem_f76_vw
  WHERE ((date_part('year'::text, fec_fitem_f76_vw.communication_dt) >= (1979)::double precision) AND (fec_fitem_f76_vw.s_o_cand_id IS NOT NULL))
  GROUP BY fec_fitem_f76_vw.org_id, fec_fitem_f76_vw.s_o_cand_id, fec_fitem_f76_vw.s_o_ind, ((date_part('year'::text, fec_fitem_f76_vw.communication_dt))::integer + ((date_part('year'::text, fec_fitem_f76_vw.communication_dt))::integer % 2))
  WITH NO DATA;


ALTER TABLE ofec_communication_cost_aggregate_candidate_mv OWNER TO fec;

--
-- Name: ofec_communication_cost_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_communication_cost_mv AS
 WITH com_names AS (
         SELECT DISTINCT ON (ofec_committee_history_mv.committee_id) ofec_committee_history_mv.committee_id,
            ofec_committee_history_mv.name AS committee_name
           FROM ofec_committee_history_mv
          ORDER BY ofec_committee_history_mv.committee_id, ofec_committee_history_mv.cycle DESC
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
  WITH NO DATA;


ALTER TABLE ofec_communication_cost_mv OWNER TO fec;

--
-- Name: ofec_election_dates; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_election_dates (
    index bigint,
    race_pk bigint,
    office text,
    office_desc text,
    state text,
    state_desc text,
    district bigint,
    election_yr bigint,
    open_seat_flg text,
    create_date timestamp without time zone,
    election_type_id text,
    cycle_start_dt timestamp without time zone,
    cycle_end_dt timestamp without time zone,
    election_dt timestamp without time zone,
    senate_class double precision
);


ALTER TABLE ofec_election_dates OWNER TO fec;

--
-- Name: ofec_election_result_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_election_result_mv AS
 WITH election_dates_house_senate AS (
         SELECT trc_election.election_state,
            trc_election.office_sought,
            trc_election.election_district,
            trc_election.election_yr,
            trc_election.trc_election_type_id
           FROM fecapp.trc_election
          WHERE ((trc_election.office_sought)::text <> 'P'::text)
          GROUP BY trc_election.election_state, trc_election.office_sought, trc_election.election_district, trc_election.election_yr, trc_election.trc_election_type_id
        ), election_dates_president AS (
         SELECT DISTINCT ON (trc_election.election_yr) 'US'::character(2) AS election_state,
            trc_election.office_sought,
            trc_election.election_district,
            trc_election.election_yr,
            trc_election.trc_election_type_id
           FROM fecapp.trc_election
          WHERE ((trc_election.office_sought)::text = 'P'::text)
          GROUP BY trc_election.election_state, trc_election.office_sought, trc_election.election_district, trc_election.election_yr, trc_election.trc_election_type_id
        ), incumbent_info AS (
         SELECT DISTINCT ON (cand_valid_fec_yr.cand_office_st, cand_valid_fec_yr.cand_office, cand_valid_fec_yr.cand_office_district, cand_valid_fec_yr.cand_election_yr) cand_valid_fec_yr.cand_valid_yr_id,
            cand_valid_fec_yr.cand_id,
            cand_valid_fec_yr.fec_election_yr,
            cand_valid_fec_yr.cand_election_yr,
            cand_valid_fec_yr.cand_status,
            cand_valid_fec_yr.cand_ici,
            cand_valid_fec_yr.cand_office,
            cand_valid_fec_yr.cand_office_st,
            cand_valid_fec_yr.cand_office_district,
            cand_valid_fec_yr.cand_pty_affiliation,
            cand_valid_fec_yr.cand_name,
            cand_valid_fec_yr.cand_st1,
            cand_valid_fec_yr.cand_st2,
            cand_valid_fec_yr.cand_city,
            cand_valid_fec_yr.cand_state,
            cand_valid_fec_yr.cand_zip,
            cand_valid_fec_yr.race_pk,
            cand_valid_fec_yr.lst_updt_dt,
            cand_valid_fec_yr.latest_receipt_dt,
            cand_valid_fec_yr.user_id_entered,
            cand_valid_fec_yr.date_entered,
            cand_valid_fec_yr.user_id_changed,
            cand_valid_fec_yr.date_changed,
            cand_valid_fec_yr.ref_cand_pk,
            cand_valid_fec_yr.ref_lst_updt_dt,
            cand_valid_fec_yr.pg_date
           FROM disclosure.cand_valid_fec_yr
          WHERE ((cand_valid_fec_yr.cand_ici)::text = 'I'::text)
          ORDER BY cand_valid_fec_yr.cand_office_st, cand_valid_fec_yr.cand_office, cand_valid_fec_yr.cand_office_district, cand_valid_fec_yr.cand_election_yr DESC, cand_valid_fec_yr.latest_receipt_dt DESC
        ), records_with_incumbents_districts AS (
         SELECT fec.cand_valid_yr_id,
            fec.cand_id,
            (ed.election_yr + (ed.election_yr % (2)::numeric)) AS fec_election_yr,
            fec.cand_election_yr,
            fec.cand_status,
            fec.cand_ici,
            ed.office_sought AS cand_office,
            ed.election_state AS cand_office_st,
            ed.election_district AS cand_office_district,
            fec.cand_pty_affiliation,
            fec.cand_name,
            ed.election_yr,
            ed.trc_election_type_id AS election_type
           FROM (election_dates_house_senate ed
             LEFT JOIN incumbent_info fec ON ((((ed.election_state)::text = (fec.cand_office_st)::text) AND ((ed.office_sought)::text = (fec.cand_office)::text) AND (((ed.election_district)::character varying(2))::text = (fec.cand_office_district)::text) AND (ed.election_yr = fec.cand_election_yr))))
          WHERE ((ed.election_district IS NOT NULL) AND ((ed.election_district)::text <> ''::text) AND ((ed.election_district)::text <> ' '::text))
          ORDER BY ed.election_state, ed.office_sought, ed.election_district, fec.cand_election_yr DESC, fec.latest_receipt_dt DESC
        ), records_with_incumbents AS (
         SELECT fec.cand_valid_yr_id,
            fec.cand_id,
            (ed.election_yr + (ed.election_yr % (2)::numeric)) AS fec_election_yr,
            ed.election_yr AS cand_election_yr,
            fec.cand_status,
            fec.cand_ici,
            ed.office_sought AS cand_office,
            ed.election_state AS cand_office_st,
                CASE
                    WHEN ((ed.office_sought)::text = 'H'::text) THEN fec.cand_office_district
                    ELSE '00'::character varying(2)
                END AS cand_office_district,
            fec.cand_pty_affiliation,
            fec.cand_name,
            ed.election_yr,
            ed.trc_election_type_id AS election_type
           FROM (election_dates_house_senate ed
             LEFT JOIN incumbent_info fec ON ((((ed.election_state)::text = (fec.cand_office_st)::text) AND ((ed.office_sought)::text = (fec.cand_office)::text) AND (ed.election_yr = fec.cand_election_yr))))
          WHERE (((ed.election_district IS NULL) OR ((ed.election_district)::text = ''::text) OR ((ed.election_district)::text = ' '::text)) AND ((ed.office_sought)::text <> 'P'::text))
          ORDER BY ed.election_state, ed.office_sought,
                CASE
                    WHEN ((ed.office_sought)::text = 'H'::text) THEN fec.cand_office_district
                    ELSE '00'::character varying(2)
                END, ed.election_yr DESC, fec.latest_receipt_dt DESC
        ), records_with_incumbents_president AS (
         SELECT fec.cand_valid_yr_id,
            fec.cand_id,
            (ed.election_yr + (ed.election_yr % (2)::numeric)) AS fec_election_yr,
            fec.cand_election_yr,
            fec.cand_status,
            fec.cand_ici,
            ed.office_sought AS cand_office,
            'US'::character(2) AS cand_office_st,
            '00'::character varying(2) AS cand_office_district,
            fec.cand_pty_affiliation,
            fec.cand_name,
            ed.election_yr,
            ed.trc_election_type_id AS election_type
           FROM (election_dates_president ed
             LEFT JOIN incumbent_info fec ON ((ed.election_yr = fec.cand_election_yr)))
          WHERE ((fec.cand_office)::text = 'P'::text)
          ORDER BY fec.cand_election_yr DESC, fec.latest_receipt_dt DESC
        ), combined AS (
         SELECT records_with_incumbents_districts.cand_valid_yr_id,
            records_with_incumbents_districts.cand_id,
            records_with_incumbents_districts.fec_election_yr,
            records_with_incumbents_districts.cand_election_yr,
            records_with_incumbents_districts.cand_status,
            records_with_incumbents_districts.cand_ici,
            records_with_incumbents_districts.cand_office,
            records_with_incumbents_districts.cand_office_st,
            records_with_incumbents_districts.cand_office_district,
            records_with_incumbents_districts.cand_pty_affiliation,
            records_with_incumbents_districts.cand_name,
            records_with_incumbents_districts.election_yr,
            records_with_incumbents_districts.election_type
           FROM records_with_incumbents_districts
        UNION ALL
         SELECT records_with_incumbents.cand_valid_yr_id,
            records_with_incumbents.cand_id,
            records_with_incumbents.fec_election_yr,
            records_with_incumbents.cand_election_yr,
            records_with_incumbents.cand_status,
            records_with_incumbents.cand_ici,
            records_with_incumbents.cand_office,
            records_with_incumbents.cand_office_st,
            records_with_incumbents.cand_office_district,
            records_with_incumbents.cand_pty_affiliation,
            records_with_incumbents.cand_name,
            records_with_incumbents.election_yr,
            records_with_incumbents.election_type
           FROM records_with_incumbents
        UNION ALL
         SELECT records_with_incumbents_president.cand_valid_yr_id,
            records_with_incumbents_president.cand_id,
            records_with_incumbents_president.fec_election_yr,
            records_with_incumbents_president.cand_election_yr,
            records_with_incumbents_president.cand_status,
            records_with_incumbents_president.cand_ici,
            records_with_incumbents_president.cand_office,
            records_with_incumbents_president.cand_office_st,
            records_with_incumbents_president.cand_office_district,
            records_with_incumbents_president.cand_pty_affiliation,
            records_with_incumbents_president.cand_name,
            records_with_incumbents_president.election_yr,
            records_with_incumbents_president.election_type
           FROM records_with_incumbents_president
        )
 SELECT combined.cand_valid_yr_id,
    combined.cand_id,
    combined.fec_election_yr,
    combined.cand_election_yr,
    combined.cand_status,
    combined.cand_ici,
    combined.cand_office,
    combined.cand_office_st,
    combined.cand_office_district,
    combined.cand_pty_affiliation,
    combined.cand_name,
    combined.election_yr,
    combined.election_type,
    row_number() OVER () AS idx
   FROM combined
  WITH NO DATA;


ALTER TABLE ofec_election_result_mv OWNER TO fec;

--
-- Name: ofec_electioneering_aggregate_candidate_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_electioneering_aggregate_candidate_mv AS
 SELECT row_number() OVER () AS idx,
    electioneering_com_vw.cmte_id,
    electioneering_com_vw.cand_id,
    sum(electioneering_com_vw.calculated_cand_share) AS total,
    count(electioneering_com_vw.calculated_cand_share) AS count,
    (electioneering_com_vw.rpt_yr + (electioneering_com_vw.rpt_yr % (2)::numeric)) AS cycle
   FROM electioneering_com_vw
  WHERE (electioneering_com_vw.rpt_yr >= (1979)::numeric)
  GROUP BY electioneering_com_vw.cmte_id, electioneering_com_vw.cand_id, (electioneering_com_vw.rpt_yr + (electioneering_com_vw.rpt_yr % (2)::numeric))
  WITH NO DATA;


ALTER TABLE ofec_electioneering_aggregate_candidate_mv OWNER TO fec;

--
-- Name: ofec_electioneering_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_electioneering_mv AS
 SELECT row_number() OVER () AS idx,
    electioneering_com_vw.cand_id,
    electioneering_com_vw.cand_name,
    electioneering_com_vw.cand_office,
    electioneering_com_vw.cand_office_st,
    electioneering_com_vw.cand_office_district,
    electioneering_com_vw.cmte_id,
    electioneering_com_vw.cmte_nm,
    electioneering_com_vw.sb_image_num,
    electioneering_com_vw.payee_nm,
    electioneering_com_vw.payee_st1,
    electioneering_com_vw.payee_city,
    electioneering_com_vw.payee_st,
    electioneering_com_vw.disb_desc,
    electioneering_com_vw.disb_dt,
    electioneering_com_vw.comm_dt,
    electioneering_com_vw.pub_distrib_dt,
    electioneering_com_vw.reported_disb_amt,
    electioneering_com_vw.number_of_candidates,
    electioneering_com_vw.calculated_cand_share,
    electioneering_com_vw.sub_id,
    electioneering_com_vw.link_id,
    electioneering_com_vw.rpt_yr,
    electioneering_com_vw.sb_link_id,
    electioneering_com_vw.f9_begin_image_num,
    electioneering_com_vw.receipt_dt,
    electioneering_com_vw.election_tp,
    electioneering_com_vw.file_num,
    electioneering_com_vw.amndt_ind,
    image_pdf_url((electioneering_com_vw.sb_image_num)::text) AS pdf_url,
    to_tsvector((electioneering_com_vw.disb_desc)::text) AS purpose_description_text
   FROM electioneering_com_vw
  WHERE (electioneering_com_vw.rpt_yr >= (1979)::numeric)
  WITH NO DATA;


ALTER TABLE ofec_electioneering_mv OWNER TO fec;

--
-- Name: ofec_totals_pacs_parties_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_pacs_parties_mv AS
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
   FROM (ofec_totals_combined_mv oft
     JOIN ofec_committee_detail_mv comm_dets USING (committee_id))
  WHERE ((oft.form_type)::text = 'F3X'::text)
  WITH NO DATA;


ALTER TABLE ofec_totals_pacs_parties_mv OWNER TO fec;

--
-- Name: ofec_totals_pacs_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_pacs_mv AS
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
   FROM ofec_totals_pacs_parties_mv
  WHERE ((ofec_totals_pacs_parties_mv.committee_type = 'N'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'Q'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'O'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'V'::text) OR (ofec_totals_pacs_parties_mv.committee_type = 'W'::text))
  WITH NO DATA;


ALTER TABLE ofec_totals_pacs_mv OWNER TO fec;

--
-- Name: ofec_totals_parties_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_parties_mv AS
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
   FROM ofec_totals_pacs_parties_mv pp
  WHERE ((pp.committee_type = 'X'::text) OR (pp.committee_type = 'Y'::text))
  WITH NO DATA;


ALTER TABLE ofec_totals_parties_mv OWNER TO fec;

--
-- Name: ofec_entity_chart_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_entity_chart_mv AS
 WITH cand_totals AS (
         SELECT 'candidate'::text AS type,
            date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_house_senate_mv.receipts, (0)::numeric) - ((((COALESCE(ofec_totals_house_senate_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)))) AS candidate_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_house_senate_mv.disbursements, (0)::numeric) - (((COALESCE(ofec_totals_house_senate_mv.transfers_to_other_authorized_committee, (0)::numeric) + COALESCE(ofec_totals_house_senate_mv.loan_repayments, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_house_senate_mv.other_disbursements, (0)::numeric)))) AS candidate_adjusted_total_disbursements
           FROM ofec_totals_house_senate_mv
          WHERE (ofec_totals_house_senate_mv.cycle >= 2008)
          GROUP BY (date_part('month'::text, ofec_totals_house_senate_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_house_senate_mv.coverage_end_date))
        ), pac_totals AS (
         SELECT 'pac'::text AS type,
            date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_pacs_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_pacs_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)))) AS pac_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_pacs_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_pacs_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_pacs_mv.transfers_to_affiliated_committee, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_pacs_mv.other_disbursements, (0)::numeric)))) AS pac_adjusted_total_disbursements
           FROM ofec_totals_pacs_mv
          WHERE ((ofec_totals_pacs_mv.committee_type = ANY (ARRAY['N'::text, 'Q'::text, 'O'::text, 'V'::text, 'W'::text])) AND ((ofec_totals_pacs_mv.designation)::text <> 'J'::text) AND (ofec_totals_pacs_mv.cycle >= 2008))
          GROUP BY (date_part('month'::text, ofec_totals_pacs_mv.coverage_end_date)), (date_part('year'::text, ofec_totals_pacs_mv.coverage_end_date))
        ), party_totals AS (
         SELECT 'party'::text AS type,
            date_part('month'::text, ofec_totals_parties_mv.coverage_end_date) AS month,
            date_part('year'::text, ofec_totals_parties_mv.coverage_end_date) AS year,
            sum((COALESCE(ofec_totals_parties_mv.receipts, (0)::numeric) - ((((((COALESCE(ofec_totals_parties_mv.political_party_committee_contributions, (0)::numeric) + COALESCE(ofec_totals_parties_mv.other_political_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.offsets_to_operating_expenditures, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.transfers_from_nonfed_account, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)))) AS party_adjusted_total_receipts,
            sum((COALESCE(ofec_totals_parties_mv.disbursements, (0)::numeric) - (((((COALESCE(ofec_totals_parties_mv.shared_nonfed_operating_expenditures, (0)::numeric) + COALESCE(ofec_totals_parties_mv.transfers_to_other_authorized_committee, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.fed_candidate_committee_contributions, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.loan_repayments_other_loans, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.contribution_refunds, (0)::numeric)) + COALESCE(ofec_totals_parties_mv.other_disbursements, (0)::numeric)))) AS party_adjusted_total_disbursements
           FROM ofec_totals_parties_mv
          WHERE ((ofec_totals_parties_mv.committee_type = ANY (ARRAY['X'::text, 'Y'::text])) AND ((ofec_totals_parties_mv.designation)::text <> 'J'::text) AND ((ofec_totals_parties_mv.committee_id)::text <> ALL ((ARRAY['C00578419'::character varying, 'C00485110'::character varying, 'C00422048'::character varying, 'C00567057'::character varying, 'C00483586'::character varying, 'C00431791'::character varying, 'C00571133'::character varying, 'C00500405'::character varying, 'C00435560'::character varying, 'C00572958'::character varying, 'C00493254'::character varying, 'C00496570'::character varying, 'C00431593'::character varying])::text[])) AND (ofec_totals_parties_mv.cycle >= 2008))
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
    last_day_of_month(make_timestamp((combined.year)::integer, (combined.month)::integer, 1, 0, 0, (0.0)::double precision)) AS date,
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
  WITH NO DATA;


ALTER TABLE ofec_entity_chart_mv OWNER TO fec;

--
-- Name: ofec_f57_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_f57_queue_new (
    sub_id numeric(19,0),
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    receipt_dt timestamp without time zone,
    tran_id character varying(32),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    catg_cd character varying(3),
    exp_tp character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    exp_tp_desc character varying(90),
    file_num numeric(7,0),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    orig_sub_id numeric(19,0),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone
);


ALTER TABLE ofec_f57_queue_new OWNER TO fec;

--
-- Name: ofec_f57_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_f57_queue_old (
    sub_id numeric(19,0),
    link_id numeric(19,0),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    filer_cmte_id character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(90),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_purpose character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(20),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_state_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    receipt_dt timestamp without time zone,
    tran_id character varying(32),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    catg_cd character varying(3),
    exp_tp character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    exp_tp_desc character varying(90),
    file_num numeric(7,0),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    orig_sub_id numeric(19,0),
    pye_l_nm character varying(30),
    pye_f_nm character varying(20),
    pye_m_nm character varying(20),
    pye_prefix character varying(10),
    pye_suffix character varying(10),
    s_o_cand_l_nm character varying(30),
    s_o_cand_f_nm character varying(20),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    pg_date timestamp without time zone
);


ALTER TABLE ofec_f57_queue_old OWNER TO fec;

--
-- Name: ofec_fips_states; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_fips_states (
    index bigint,
    "Name" text,
    "FIPS State Numeric Code" bigint,
    "Official USPS Code" text
);


ALTER TABLE ofec_fips_states OWNER TO fec;

--
-- Name: ofec_house_senate_electronic_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_house_senate_electronic_amendments_mv AS
 WITH RECURSIVE oldest_filing AS (
         SELECT nml_form_3.cmte_id,
            nml_form_3.rpt_yr,
            nml_form_3.rpt_tp,
            nml_form_3.amndt_ind,
            nml_form_3.receipt_dt,
            nml_form_3.file_num,
            nml_form_3.prev_file_num,
            nml_form_3.mst_rct_file_num,
            ARRAY[nml_form_3.file_num] AS amendment_chain,
            1 AS depth,
            nml_form_3.file_num AS last
           FROM disclosure.nml_form_3
          WHERE ((nml_form_3.file_num = nml_form_3.prev_file_num) AND (nml_form_3.file_num = nml_form_3.mst_rct_file_num) AND (nml_form_3.file_num > (0)::numeric))
        UNION
         SELECT f3.cmte_id,
            f3.rpt_yr,
            f3.rpt_tp,
            f3.amndt_ind,
            f3.receipt_dt,
            f3.file_num,
            f3.prev_file_num,
            f3.mst_rct_file_num,
            ((oldest.amendment_chain || f3.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            disclosure.nml_form_3 f3
          WHERE ((f3.prev_file_num = oldest.file_num) AND ((f3.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3.file_num <> f3.prev_file_num) AND (f3.file_num > (0)::numeric))
        ), most_recent_filing AS (
         SELECT a.cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_dt,
            a.file_num,
            a.prev_file_num,
            a.mst_rct_file_num,
            a.amendment_chain,
            a.depth,
            a.last
           FROM (oldest_filing a
             LEFT JOIN oldest_filing b ON ((((a.cmte_id)::text = (b.cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cmte_id IS NULL)
        ), electronic_filer_chain AS (
         SELECT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            mrf.file_num AS mst_rct_file_num,
            old_f.amendment_chain
           FROM (oldest_filing old_f
             JOIN most_recent_filing mrf ON ((((old_f.cmte_id)::text = (mrf.cmte_id)::text) AND (old_f.last = mrf.last))))
        )
 SELECT row_number() OVER () AS idx,
    electronic_filer_chain.cmte_id,
    electronic_filer_chain.rpt_yr,
    electronic_filer_chain.rpt_tp,
    electronic_filer_chain.amndt_ind,
    electronic_filer_chain.receipt_dt,
    electronic_filer_chain.file_num,
    electronic_filer_chain.prev_file_num,
    electronic_filer_chain.mst_rct_file_num,
    electronic_filer_chain.amendment_chain
   FROM electronic_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_house_senate_electronic_amendments_mv OWNER TO fec;

--
-- Name: ofec_nml_24_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_nml_24_queue_new (
    sub_id numeric(19,0),
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    catg_cd character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    s_0_cand_m_nm character varying(20),
    s_0_cand_prefix character varying(10),
    s_0_cand_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    dissem_dt timestamp without time zone,
    pg_date timestamp without time zone
);


ALTER TABLE ofec_nml_24_queue_new OWNER TO fec;

--
-- Name: ofec_nml_24_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_nml_24_queue_old (
    sub_id numeric(19,0),
    link_id numeric(19,0),
    line_num character varying(12),
    image_num character varying(18),
    form_tp character varying(8),
    form_tp_desc character varying(90),
    cmte_id character varying(9),
    cmte_nm character varying(200),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    pye_nm character varying(200),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    exp_desc character varying(100),
    exp_dt timestamp without time zone,
    exp_amt numeric(14,2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    amndt_ind character varying(1),
    amndt_ind_desc character varying(15),
    tran_id character varying(32),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    back_ref_tran_id character varying(32),
    back_ref_sched_nm character varying(8),
    receipt_dt timestamp without time zone,
    record_num character varying(10),
    rpt_tp character varying(3),
    rpt_tp_desc character varying(30),
    rpt_pgi character varying(1),
    rpt_pgi_desc character varying(10),
    image_tp character varying(10),
    load_status numeric(1,0),
    last_update_dt timestamp without time zone,
    delete_ind numeric(1,0),
    mst_rct_rec_flg character varying(1),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    catg_cd character varying(3),
    cal_ytd_ofc_sought numeric(14,2),
    catg_cd_desc character varying(40),
    file_num numeric(7,0),
    orig_sub_id numeric(19,0),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    s_0_cand_m_nm character varying(20),
    s_0_cand_prefix character varying(10),
    s_0_cand_suffix character varying(10),
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    form_tp_cd character varying(8),
    rpt_yr numeric(4,0),
    dissem_dt timestamp without time zone,
    pg_date timestamp without time zone
);


ALTER TABLE ofec_nml_24_queue_old OWNER TO fec;

--
-- Name: ofec_omnibus_dates_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_omnibus_dates_mv AS
 WITH elections_raw AS (
         SELECT trc_election.trc_election_id,
            trc_election.election_state,
            trc_election.election_district,
            trc_election.election_party,
            trc_election.office_sought,
            trc_election.election_date,
            trc_election.election_notes,
            trc_election.sec_user_id_update,
            trc_election.sec_user_id_create,
            trc_election.trc_election_type_id,
            trc_election.trc_election_status_id,
            trc_election.update_date,
            trc_election.create_date,
            trc_election.election_yr,
            trc_election.pg_date,
            rp.pty_cd,
            rp.pty_desc,
            rp.pg_date,
                CASE
                    WHEN (((trc_election.office_sought)::text = 'H'::text) AND ((trc_election.election_district)::text <> ' '::text)) THEN (array_to_string(ARRAY[trc_election.election_state, trc_election.election_district], '-'::text))::character varying
                    ELSE trc_election.election_state
                END AS contest,
            expand_election_type_caucus_convention_clean((trc_election.trc_election_type_id)::text, (trc_election.trc_election_id)::numeric) AS election_type,
            initcap((rp.pty_desc)::text) AS party
           FROM (fecapp.trc_election
             LEFT JOIN staging.ref_pty rp ON (((trc_election.election_party)::text = (rp.pty_cd)::text)))
          WHERE (trc_election.trc_election_status_id = 1)
        ), elections AS (
         SELECT 'election'::text AS category,
            create_election_description(elections_raw.election_type, expand_office_description((elections_raw.office_sought)::text), (array_agg(elections_raw.contest ORDER BY elections_raw.contest))::text[], elections_raw.party, (elections_raw.election_notes)::text) AS description,
            create_election_summary(elections_raw.election_type, expand_office_description((elections_raw.office_sought)::text), (array_agg(elections_raw.contest ORDER BY elections_raw.contest))::text[], elections_raw.party, (elections_raw.election_notes)::text) AS summary,
            array_remove((array_agg(elections_raw.election_state ORDER BY elections_raw.election_state))::text[], NULL::text) AS states,
            NULL::text AS location,
            (elections_raw.election_date)::timestamp without time zone AS start_date,
            NULL::timestamp without time zone AS end_date,
            true AS all_day,
            NULL::text AS url
           FROM elections_raw elections_raw(trc_election_id, election_state, election_district, election_party, office_sought, election_date, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date, create_date, election_yr, pg_date, pty_cd, pty_desc, pg_date_1, contest, election_type, party)
          GROUP BY elections_raw.office_sought, elections_raw.election_date, elections_raw.party, elections_raw.election_type, elections_raw.election_notes
        ), reports_raw AS (
         SELECT reports.trc_election_id,
            reports.trc_report_due_date_id,
            reports.report_year,
            reports.report_type,
            reports.due_date,
            reports.create_date,
            reports.update_date,
            reports.sec_user_id_create,
            reports.sec_user_id_update,
            reports.pg_date,
            ref_rpt_tp.rpt_tp_cd,
            ref_rpt_tp.rpt_tp_desc,
            ref_rpt_tp.pg_date,
            elections_raw.election_state,
            elections_raw.election_district,
            elections_raw.election_party,
            elections_raw.office_sought,
            elections_raw.election_date,
            elections_raw.election_notes,
            elections_raw.sec_user_id_update,
            elections_raw.sec_user_id_create,
            elections_raw.trc_election_type_id,
            elections_raw.trc_election_status_id,
            elections_raw.update_date,
            elections_raw.create_date,
            elections_raw.election_yr,
            elections_raw.pg_date,
            elections_raw.pty_cd,
            elections_raw.pty_desc,
            elections_raw.pg_date_1 AS pg_date,
            elections_raw.contest,
            elections_raw.election_type,
            elections_raw.party,
                CASE
                    WHEN (((elections_raw.office_sought)::text = 'H'::text) AND ((elections_raw.election_district)::text <> ' '::text)) THEN (array_to_string(ARRAY[elections_raw.election_state, elections_raw.election_district], '-'::text))::character varying
                    ELSE elections_raw.election_state
                END AS report_contest
           FROM ((fecapp.trc_report_due_date reports
             LEFT JOIN staging.ref_rpt_tp ON (((reports.report_type)::text = (ref_rpt_tp.rpt_tp_cd)::text)))
             LEFT JOIN elections_raw elections_raw(trc_election_id, election_state, election_district, election_party, office_sought, election_date, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date, create_date, election_yr, pg_date, pty_cd, pty_desc, pg_date_1, contest, election_type, party) USING (trc_election_id))
          WHERE (COALESCE(elections_raw.trc_election_status_id, 1) = 1)
        ), reports AS (
         SELECT ('report-'::text || (reports_raw.report_type)::text) AS category,
            create_report_description((reports_raw.office_sought)::text, (reports_raw.report_type)::text, clean_report((reports_raw.rpt_tp_desc)::text), (array_agg(reports_raw.report_contest ORDER BY reports_raw.report_contest))::text[], (reports_raw.election_notes)::text) AS description,
            create_report_summary((reports_raw.office_sought)::text, (reports_raw.report_type)::text, clean_report((reports_raw.rpt_tp_desc)::text), (array_agg(reports_raw.report_contest ORDER BY reports_raw.report_contest))::text[], (reports_raw.election_notes)::text) AS summary,
            add_reporting_states((array_agg(reports_raw.election_state))::text[], (reports_raw.report_type)::text) AS states,
            NULL::text AS location,
            (reports_raw.due_date)::timestamp without time zone AS start_date,
            NULL::timestamp without time zone AS end_date,
            true AS all_day,
            create_reporting_link((reports_raw.due_date)::timestamp without time zone) AS url
           FROM reports_raw reports_raw(trc_election_id, trc_report_due_date_id, report_year, report_type, due_date, create_date, update_date, sec_user_id_create, sec_user_id_update, pg_date, rpt_tp_cd, rpt_tp_desc, pg_date_1, election_state, election_district, election_party, office_sought, election_date, election_notes, sec_user_id_update_1, sec_user_id_create_1, trc_election_type_id, trc_election_status_id, update_date_1, create_date_1, election_yr, pg_date_2, pty_cd, pty_desc, pg_date_3, contest, election_type, party, report_contest)
          WHERE (NOT (((reports_raw.report_type)::text = ANY ((ARRAY['12C'::character varying, '12P'::character varying, '12CAU'::character varying, '12CON'::character varying, '30CAU'::character varying])::text[])) AND (((date_part('year'::text, reports_raw.due_date))::numeric % (2)::numeric) = (0)::numeric) AND ((reports_raw.office_sought)::text = 'P'::text)))
          GROUP BY reports_raw.report_type, reports_raw.rpt_tp_desc, reports_raw.due_date, reports_raw.office_sought, reports_raw.election_notes
        ), reporting_periods_raw AS (
         SELECT trc_election_dates.trc_election_id,
            trc_election_dates.election_date,
            trc_election_dates.close_of_books,
            trc_election_dates.rc_date,
            trc_election_dates.filing_date,
            trc_election_dates.f48hour_start,
            trc_election_dates.f48hour_end,
            trc_election_dates.notice_mail_date,
            trc_election_dates.losergram_mail_date,
            trc_election_dates.ec_start,
            trc_election_dates.ec_end,
            trc_election_dates.ie_48hour_start,
            trc_election_dates.ie_48hour_end,
            trc_election_dates.ie_24hour_start,
            trc_election_dates.ie_24hour_end,
            trc_election_dates.cc_start,
            trc_election_dates.cc_end,
            trc_election_dates.election_date2,
            trc_election_dates.ballot_deadline,
            trc_election_dates.primary_voter_reg_start,
            trc_election_dates.primary_voter_reg_end,
            trc_election_dates.general_voter_reg_start,
            trc_election_dates.general_voter_reg_end,
            trc_election_dates.date_special_election_set,
            trc_election_dates.create_date,
            trc_election_dates.update_date,
            trc_election_dates.election_party,
            trc_election_dates.display_flag,
            trc_election_dates.pg_date,
            elections_raw.election_state,
            elections_raw.election_district,
            elections_raw.election_party,
            elections_raw.office_sought,
            elections_raw.election_date,
            elections_raw.election_notes,
            elections_raw.sec_user_id_update,
            elections_raw.sec_user_id_create,
            elections_raw.trc_election_type_id,
            elections_raw.trc_election_status_id,
            elections_raw.update_date,
            elections_raw.create_date,
            elections_raw.election_yr,
            elections_raw.pg_date,
            elections_raw.pty_cd,
            elections_raw.pty_desc,
            elections_raw.pg_date_1 AS pg_date,
            elections_raw.contest,
            elections_raw.election_type,
            elections_raw.party,
            elections_raw.contest AS rp_contest,
            elections_raw.election_state AS rp_state,
            elections_raw.election_type AS rp_election_type,
            elections_raw.office_sought AS rp_office,
            elections_raw.party AS rp_party,
            elections_raw.election_notes AS rp_election_notes
           FROM (fecapp.trc_election_dates
             JOIN elections_raw elections_raw(trc_election_id, election_state, election_district, election_party, office_sought, election_date, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date, create_date, election_yr, pg_date, pty_cd, pty_desc, pg_date_1, contest, election_type, party) USING (trc_election_id))
        ), ie_24hr AS (
         SELECT 'IE Periods'::text AS category,
            create_24hr_text(create_election_summary(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ie_24hour_end) AS summary,
            create_24hr_text(create_election_description(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ie_24hour_end) AS description,
            array_remove((array_agg(reporting_periods_raw.rp_state ORDER BY reporting_periods_raw.rp_state))::text[], NULL::text) AS states,
            NULL::text AS location,
            (reporting_periods_raw.ie_24hour_start)::timestamp without time zone AS start_date,
            NULL::timestamp without time zone AS end_date,
            true AS all_day,
            create_reporting_link((reporting_periods_raw.ie_24hour_start)::timestamp without time zone) AS url
           FROM reporting_periods_raw reporting_periods_raw(trc_election_id, election_date, close_of_books, rc_date, filing_date, f48hour_start, f48hour_end, notice_mail_date, losergram_mail_date, ec_start, ec_end, ie_48hour_start, ie_48hour_end, ie_24hour_start, ie_24hour_end, cc_start, cc_end, election_date2, ballot_deadline, primary_voter_reg_start, primary_voter_reg_end, general_voter_reg_start, general_voter_reg_end, date_special_election_set, create_date, update_date, election_party, display_flag, pg_date, election_state, election_district, election_party_1, office_sought, election_date_1, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date_1, create_date_1, election_yr, pg_date_1, pty_cd, pty_desc, pg_date_2, contest, election_type, party, rp_contest, rp_state, rp_election_type, rp_office, rp_party, rp_election_notes)
          GROUP BY reporting_periods_raw.ie_24hour_start, reporting_periods_raw.ie_24hour_end, reporting_periods_raw.rp_office, reporting_periods_raw.rp_election_type, reporting_periods_raw.rp_party, reporting_periods_raw.rp_election_notes
        ), ie_48hr AS (
         SELECT 'IE Periods'::text AS category,
            create_48hr_text(create_election_summary(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ie_48hour_end) AS summary,
            create_48hr_text(create_election_description(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ie_48hour_end) AS description,
            array_remove((array_agg(reporting_periods_raw.rp_state ORDER BY reporting_periods_raw.rp_state))::text[], NULL::text) AS states,
            NULL::text AS location,
            (reporting_periods_raw.ie_48hour_start)::timestamp without time zone AS start_date,
            NULL::timestamp without time zone AS end_date,
            true AS all_day,
            create_reporting_link((reporting_periods_raw.ie_48hour_start)::timestamp without time zone) AS url
           FROM reporting_periods_raw reporting_periods_raw(trc_election_id, election_date, close_of_books, rc_date, filing_date, f48hour_start, f48hour_end, notice_mail_date, losergram_mail_date, ec_start, ec_end, ie_48hour_start, ie_48hour_end, ie_24hour_start, ie_24hour_end, cc_start, cc_end, election_date2, ballot_deadline, primary_voter_reg_start, primary_voter_reg_end, general_voter_reg_start, general_voter_reg_end, date_special_election_set, create_date, update_date, election_party, display_flag, pg_date, election_state, election_district, election_party_1, office_sought, election_date_1, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date_1, create_date_1, election_yr, pg_date_1, pty_cd, pty_desc, pg_date_2, contest, election_type, party, rp_contest, rp_state, rp_election_type, rp_office, rp_party, rp_election_notes)
          GROUP BY reporting_periods_raw.ie_48hour_start, reporting_periods_raw.ie_48hour_end, reporting_periods_raw.rp_office, reporting_periods_raw.rp_election_type, reporting_periods_raw.rp_party, reporting_periods_raw.rp_election_notes
        ), electioneering AS (
         SELECT 'EC Periods'::text AS category,
            create_electioneering_text(create_election_summary(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ec_end) AS summary,
            create_electioneering_text(create_election_description(reporting_periods_raw.rp_election_type, expand_office_description((reporting_periods_raw.rp_office)::text), (array_agg(reporting_periods_raw.rp_contest ORDER BY reporting_periods_raw.rp_contest))::text[], reporting_periods_raw.rp_party, (reporting_periods_raw.rp_election_notes)::text), reporting_periods_raw.ec_end) AS description,
            array_remove((array_agg(reporting_periods_raw.rp_state ORDER BY reporting_periods_raw.rp_state))::text[], NULL::text) AS states,
            NULL::text AS location,
            (reporting_periods_raw.ec_start)::timestamp without time zone AS start_date,
            NULL::timestamp without time zone AS end_date,
            true AS all_day,
            create_reporting_link((reporting_periods_raw.ec_start)::timestamp without time zone) AS url
           FROM reporting_periods_raw reporting_periods_raw(trc_election_id, election_date, close_of_books, rc_date, filing_date, f48hour_start, f48hour_end, notice_mail_date, losergram_mail_date, ec_start, ec_end, ie_48hour_start, ie_48hour_end, ie_24hour_start, ie_24hour_end, cc_start, cc_end, election_date2, ballot_deadline, primary_voter_reg_start, primary_voter_reg_end, general_voter_reg_start, general_voter_reg_end, date_special_election_set, create_date, update_date, election_party, display_flag, pg_date, election_state, election_district, election_party_1, office_sought, election_date_1, election_notes, sec_user_id_update, sec_user_id_create, trc_election_type_id, trc_election_status_id, update_date_1, create_date_1, election_yr, pg_date_1, pty_cd, pty_desc, pg_date_2, contest, election_type, party, rp_contest, rp_state, rp_election_type, rp_office, rp_party, rp_election_notes)
          GROUP BY reporting_periods_raw.ec_start, reporting_periods_raw.ec_end, reporting_periods_raw.rp_office, reporting_periods_raw.rp_election_type, reporting_periods_raw.rp_party, reporting_periods_raw.rp_election_notes
        ), other AS (
         SELECT DISTINCT ON (cal_category.category_name, cal_event.event_name, (describe_cal_event((cal_category.category_name)::text, (cal_event.event_name)::text, (cal_event.description)::text)), (cal_event.location)::text, cal_event.start_date, cal_event.end_date) (cal_category.category_name)::text AS category,
            (cal_event.event_name)::text AS summary,
            describe_cal_event((cal_category.category_name)::text, (cal_event.event_name)::text, (cal_event.description)::text) AS description,
            NULL::text[] AS states,
            (cal_event.location)::text AS location,
            cal_event.start_date,
            cal_event.end_date,
            ((cal_event.use_time)::text = 'N'::text) AS all_day,
            cal_event.url
           FROM ((fecapp.cal_event
             JOIN fecapp.cal_event_category USING (cal_event_id))
             JOIN fecapp.cal_category USING (cal_category_id))
          WHERE (((cal_category.category_name)::text <> ALL ((ARRAY['Election Dates'::character varying, 'Reporting Deadlines'::character varying, 'Quarterly'::character varying, 'Monthly'::character varying, 'Pre and Post-Elections'::character varying, 'IE Periods'::character varying, 'EC Periods'::character varying])::text[])) AND ((cal_category.active)::text = 'Y'::text))
        ), combined AS (
         SELECT elections.category,
            elections.description,
            elections.summary,
            elections.states,
            elections.location,
            elections.start_date,
            elections.end_date,
            elections.all_day,
            elections.url
           FROM elections
        UNION ALL
         SELECT reports.category,
            reports.description,
            reports.summary,
            reports.states,
            reports.location,
            reports.start_date,
            reports.end_date,
            reports.all_day,
            reports.url
           FROM reports
        UNION ALL
         SELECT ie_24hr.category,
            ie_24hr.summary,
            ie_24hr.description,
            ie_24hr.states,
            ie_24hr.location,
            ie_24hr.start_date,
            ie_24hr.end_date,
            ie_24hr.all_day,
            ie_24hr.url
           FROM ie_24hr
        UNION ALL
         SELECT ie_48hr.category,
            ie_48hr.summary,
            ie_48hr.description,
            ie_48hr.states,
            ie_48hr.location,
            ie_48hr.start_date,
            ie_48hr.end_date,
            ie_48hr.all_day,
            ie_48hr.url
           FROM ie_48hr
        UNION ALL
         SELECT electioneering.category,
            electioneering.summary,
            electioneering.description,
            electioneering.states,
            electioneering.location,
            electioneering.start_date,
            electioneering.end_date,
            electioneering.all_day,
            electioneering.url
           FROM electioneering
        UNION ALL
         SELECT other.category,
            other.summary,
            other.description,
            other.states,
            other.location,
            other.start_date,
            other.end_date,
            other.all_day,
            other.url
           FROM other
        )
 SELECT row_number() OVER () AS idx,
    combined.category,
    combined.description,
    combined.summary,
    combined.states,
    combined.location,
    combined.start_date,
    combined.end_date,
    combined.all_day,
    combined.url,
    to_tsvector(combined.summary) AS summary_text,
    to_tsvector(combined.description) AS description_text
   FROM combined
  WITH NO DATA;


ALTER TABLE ofec_omnibus_dates_mv OWNER TO fec;

--
-- Name: ofec_pac_party_electronic_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_pac_party_electronic_amendments_mv AS
 WITH RECURSIVE oldest_filing AS (
         SELECT nml_form_3x.cmte_id,
            nml_form_3x.rpt_yr,
            nml_form_3x.rpt_tp,
            nml_form_3x.amndt_ind,
            nml_form_3x.receipt_dt,
            nml_form_3x.file_num,
            nml_form_3x.prev_file_num,
            nml_form_3x.mst_rct_file_num,
            ARRAY[nml_form_3x.file_num] AS amendment_chain,
            1 AS depth,
            nml_form_3x.file_num AS last
           FROM disclosure.nml_form_3x
          WHERE ((nml_form_3x.file_num = nml_form_3x.prev_file_num) AND (nml_form_3x.file_num = nml_form_3x.mst_rct_file_num) AND (nml_form_3x.file_num > (0)::numeric))
        UNION
         SELECT f3x.cmte_id,
            f3x.rpt_yr,
            f3x.rpt_tp,
            f3x.amndt_ind,
            f3x.receipt_dt,
            f3x.file_num,
            f3x.prev_file_num,
            f3x.mst_rct_file_num,
            ((oldest.amendment_chain || f3x.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            disclosure.nml_form_3x f3x
          WHERE ((f3x.prev_file_num = oldest.file_num) AND ((f3x.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3x.file_num <> f3x.prev_file_num) AND (f3x.file_num > (0)::numeric))
        ), most_recent_filing AS (
         SELECT a.cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_dt,
            a.file_num,
            a.prev_file_num,
            a.mst_rct_file_num,
            a.amendment_chain,
            a.depth,
            a.last
           FROM (oldest_filing a
             LEFT JOIN oldest_filing b ON ((((a.cmte_id)::text = (b.cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cmte_id IS NULL)
        ), electronic_filer_chain AS (
         SELECT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            mrf.file_num AS mst_rct_file_num,
            old_f.amendment_chain
           FROM (oldest_filing old_f
             JOIN most_recent_filing mrf ON ((((old_f.cmte_id)::text = (mrf.cmte_id)::text) AND (old_f.last = mrf.last))))
        )
 SELECT row_number() OVER () AS idx,
    electronic_filer_chain.cmte_id,
    electronic_filer_chain.rpt_yr,
    electronic_filer_chain.rpt_tp,
    electronic_filer_chain.amndt_ind,
    electronic_filer_chain.receipt_dt,
    electronic_filer_chain.file_num,
    electronic_filer_chain.prev_file_num,
    electronic_filer_chain.mst_rct_file_num,
    electronic_filer_chain.amendment_chain
   FROM electronic_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_pac_party_electronic_amendments_mv OWNER TO fec;

--
-- Name: ofec_presidential_electronic_amendments_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_presidential_electronic_amendments_mv AS
 WITH RECURSIVE oldest_filing AS (
         SELECT nml_form_3p.cmte_id,
            nml_form_3p.rpt_yr,
            nml_form_3p.rpt_tp,
            nml_form_3p.amndt_ind,
            nml_form_3p.receipt_dt,
            nml_form_3p.file_num,
            nml_form_3p.prev_file_num,
            nml_form_3p.mst_rct_file_num,
            ARRAY[nml_form_3p.file_num] AS amendment_chain,
            1 AS depth,
            nml_form_3p.file_num AS last
           FROM disclosure.nml_form_3p
          WHERE ((nml_form_3p.file_num = nml_form_3p.prev_file_num) AND (nml_form_3p.file_num = nml_form_3p.mst_rct_file_num) AND (nml_form_3p.file_num > (0)::numeric))
        UNION
         SELECT f3p.cmte_id,
            f3p.rpt_yr,
            f3p.rpt_tp,
            f3p.amndt_ind,
            f3p.receipt_dt,
            f3p.file_num,
            f3p.prev_file_num,
            f3p.mst_rct_file_num,
            ((oldest.amendment_chain || f3p.file_num))::numeric(7,0)[] AS "numeric",
            (oldest.depth + 1),
            oldest.amendment_chain[1] AS amendment_chain
           FROM oldest_filing oldest,
            disclosure.nml_form_3p f3p
          WHERE ((f3p.prev_file_num = oldest.file_num) AND ((f3p.rpt_tp)::text = (oldest.rpt_tp)::text) AND (f3p.file_num <> f3p.prev_file_num) AND (f3p.file_num > (0)::numeric))
        ), most_recent_filing AS (
         SELECT a.cmte_id,
            a.rpt_yr,
            a.rpt_tp,
            a.amndt_ind,
            a.receipt_dt,
            a.file_num,
            a.prev_file_num,
            a.mst_rct_file_num,
            a.amendment_chain,
            a.depth,
            a.last
           FROM (oldest_filing a
             LEFT JOIN oldest_filing b ON ((((a.cmte_id)::text = (b.cmte_id)::text) AND (a.last = b.last) AND (a.depth < b.depth))))
          WHERE (b.cmte_id IS NULL)
        ), electronic_filer_chain AS (
         SELECT old_f.cmte_id,
            old_f.rpt_yr,
            old_f.rpt_tp,
            old_f.amndt_ind,
            old_f.receipt_dt,
            old_f.file_num,
            old_f.prev_file_num,
            mrf.file_num AS mst_rct_file_num,
            old_f.amendment_chain
           FROM (oldest_filing old_f
             JOIN most_recent_filing mrf ON ((((old_f.cmte_id)::text = (mrf.cmte_id)::text) AND (old_f.last = mrf.last))))
        )
 SELECT row_number() OVER () AS idx,
    electronic_filer_chain.cmte_id,
    electronic_filer_chain.rpt_yr,
    electronic_filer_chain.rpt_tp,
    electronic_filer_chain.amndt_ind,
    electronic_filer_chain.receipt_dt,
    electronic_filer_chain.file_num,
    electronic_filer_chain.prev_file_num,
    electronic_filer_chain.mst_rct_file_num,
    electronic_filer_chain.amendment_chain
   FROM electronic_filer_chain
  WITH NO DATA;


ALTER TABLE ofec_presidential_electronic_amendments_mv OWNER TO fec;

--
-- Name: ofec_rad_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_rad_mv AS
 SELECT row_number() OVER () AS idx,
    rad_cmte_analyst_search_vw.cmte_id AS committee_id,
    rad_cmte_analyst_search_vw.cmte_nm AS committee_name,
    rad_cmte_analyst_search_vw.anlyst_id AS analyst_id,
    (rad_cmte_analyst_search_vw.anlyst_short_id)::numeric AS analyst_short_id,
    fix_party_spelling(rad_cmte_analyst_search_vw.rad_branch) AS rad_branch,
    rad_cmte_analyst_search_vw.firstname AS first_name,
    rad_cmte_analyst_search_vw.lastname AS last_name,
    rad_cmte_analyst_search_vw.anlyst_email AS analyst_email,
    rad_cmte_analyst_search_vw.anlyst_title AS analyst_title,
    to_tsvector((((rad_cmte_analyst_search_vw.firstname)::text || ' '::text) || (rad_cmte_analyst_search_vw.lastname)::text)) AS name_txt,
    rad_cmte_analyst_search_vw.telephone_ext
   FROM disclosure.rad_cmte_analyst_search_vw
  WITH NO DATA;


ALTER TABLE ofec_rad_mv OWNER TO fec;

--
-- Name: ofec_reports_house_senate_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_reports_house_senate_mv AS
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
    means_filed((f3.begin_image_num)::text) AS means_filed,
    report_html_url(means_filed((f3.begin_image_num)::text), (f3.cmte_id)::text, (f3.file_num)::text) AS html_url,
    report_fec_url((f3.begin_image_num)::text, (f3.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    is_most_recent((f3.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (fec_vsum_f3_vw f3
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
           FROM ofec_amendments_mv
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
           FROM ofec_house_senate_paper_amendments_mv) amendments ON ((f3.file_num = amendments.file_num)))
  WHERE (f3.election_cycle >= (1979)::numeric)
  WITH NO DATA;


ALTER TABLE ofec_reports_house_senate_mv OWNER TO fec;

--
-- Name: ofec_reports_ie_only_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_reports_ie_only_mv AS
 SELECT row_number() OVER () AS idx,
    fec_vsum_f5_vw.indv_org_id AS committee_id,
    fec_vsum_f5_vw.election_cycle AS cycle,
    fec_vsum_f5_vw.cvg_start_dt AS coverage_start_date,
    fec_vsum_f5_vw.cvg_end_dt AS coverage_end_date,
    fec_vsum_f5_vw.rpt_yr AS report_year,
    fec_vsum_f5_vw.ttl_indt_contb AS independent_contributions_period,
    fec_vsum_f5_vw.ttl_indt_exp AS independent_expenditures_period,
    fec_vsum_f5_vw.filer_sign_dt AS filer_sign_date,
    fec_vsum_f5_vw.notary_sign_dt AS notary_sign_date,
    fec_vsum_f5_vw.notary_commission_exprtn_dt AS notary_commission_experation_date,
    fec_vsum_f5_vw.begin_image_num AS beginning_image_number,
    fec_vsum_f5_vw.end_image_num AS end_image_number,
    fec_vsum_f5_vw.rpt_tp AS report_type,
    fec_vsum_f5_vw.rpt_tp_desc AS report_type_full,
    (fec_vsum_f5_vw.most_recent_filing_flag ~~ 'N'::text) AS is_amended,
    fec_vsum_f5_vw.receipt_dt AS receipt_date,
    fec_vsum_f5_vw.file_num AS file_number,
    fec_vsum_f5_vw.amndt_ind AS amendment_indicator,
    fec_vsum_f5_vw.amndt_ind_desc AS amendment_indicator_full,
    means_filed((fec_vsum_f5_vw.begin_image_num)::text) AS means_filed,
    report_html_url(means_filed((fec_vsum_f5_vw.begin_image_num)::text), (fec_vsum_f5_vw.indv_org_id)::text, (fec_vsum_f5_vw.file_num)::text) AS html_url,
    report_fec_url((fec_vsum_f5_vw.begin_image_num)::text, (fec_vsum_f5_vw.file_num)::integer) AS fec_url
   FROM fec_vsum_f5_vw
  WHERE (fec_vsum_f5_vw.election_cycle >= (1979)::numeric)
  WITH NO DATA;


ALTER TABLE ofec_reports_ie_only_mv OWNER TO fec;

--
-- Name: ofec_reports_pacs_parties_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_reports_pacs_parties_mv AS
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
    means_filed((f3x.begin_image_num)::text) AS means_filed,
    report_html_url(means_filed((f3x.begin_image_num)::text), (f3x.cmte_id)::text, (f3x.file_num)::text) AS html_url,
    report_fec_url((f3x.begin_image_num)::text, (f3x.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    is_most_recent((f3x.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (fec_vsum_f3x_vw f3x
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
           FROM ofec_amendments_mv
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
           FROM ofec_pac_party_paper_amendments_mv) amendments ON ((f3x.file_num = amendments.file_num)))
  WHERE (f3x.election_cycle >= (1979)::numeric)
  WITH NO DATA;


ALTER TABLE ofec_reports_pacs_parties_mv OWNER TO fec;

--
-- Name: ofec_reports_presidential_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_reports_presidential_mv AS
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
    means_filed((f3p.begin_image_num)::text) AS means_filed,
    report_html_url(means_filed((f3p.begin_image_num)::text), (f3p.cmte_id)::text, (f3p.file_num)::text) AS html_url,
    report_fec_url((f3p.begin_image_num)::text, (f3p.file_num)::integer) AS fec_url,
    amendments.amendment_chain,
    amendments.prev_file_num AS previous_file_number,
    amendments.mst_rct_file_num AS most_recent_file_number,
    is_most_recent((f3p.file_num)::integer, (amendments.mst_rct_file_num)::integer) AS most_recent
   FROM (fec_vsum_f3p_vw f3p
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
           FROM ofec_amendments_mv
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
           FROM ofec_presidential_paper_amendments_mv) amendments ON ((f3p.file_num = amendments.file_num)))
  WHERE (f3p.election_cycle >= (1979)::numeric)
  WITH NO DATA;


ALTER TABLE ofec_reports_presidential_mv OWNER TO fec;

--
-- Name: ofec_sched_a_master; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_master (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id text,
    back_ref_tran_id text,
    back_ref_sched_nm character varying(8),
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    "timestamp" timestamp without time zone,
    pg_date timestamp without time zone,
    pdf_url text,
    contributor_name_text tsvector,
    contributor_employer_text tsvector,
    contributor_occupation_text tsvector,
    is_individual boolean,
    clean_contbr_id character varying(9),
    two_year_transaction_period smallint,
    line_number_label text
);


ALTER TABLE ofec_sched_a_master OWNER TO fec;

--
-- Name: ofec_sched_a_1977_1978; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1977_1978 (
    CONSTRAINT ofec_sched_a_1977_1978_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1977, 1978])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1977_1978 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1977_1978 OWNER TO fec;

--
-- Name: ofec_sched_a_1979_1980; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1979_1980 (
    CONSTRAINT ofec_sched_a_1979_1980_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1979, 1980])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1979_1980 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1979_1980 OWNER TO fec;

--
-- Name: ofec_sched_a_1981_1982; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1981_1982 (
    CONSTRAINT ofec_sched_a_1981_1982_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1981, 1982])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1981_1982 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1981_1982 OWNER TO fec;

--
-- Name: ofec_sched_a_1983_1984; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1983_1984 (
    CONSTRAINT ofec_sched_a_1983_1984_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1983, 1984])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1983_1984 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1983_1984 OWNER TO fec;

--
-- Name: ofec_sched_a_1985_1986; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1985_1986 (
    CONSTRAINT ofec_sched_a_1985_1986_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1985, 1986])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1985_1986 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1985_1986 OWNER TO fec;

--
-- Name: ofec_sched_a_1987_1988; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1987_1988 (
    CONSTRAINT ofec_sched_a_1987_1988_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1987, 1988])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1987_1988 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1987_1988 OWNER TO fec;

--
-- Name: ofec_sched_a_1989_1990; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1989_1990 (
    CONSTRAINT ofec_sched_a_1989_1990_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1989, 1990])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1989_1990 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1989_1990 OWNER TO fec;

--
-- Name: ofec_sched_a_1991_1992; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1991_1992 (
    CONSTRAINT ofec_sched_a_1991_1992_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1991, 1992])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1991_1992 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1991_1992 OWNER TO fec;

--
-- Name: ofec_sched_a_1993_1994; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1993_1994 (
    CONSTRAINT ofec_sched_a_1993_1994_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1993, 1994])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1993_1994 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1993_1994 OWNER TO fec;

--
-- Name: ofec_sched_a_1995_1996; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1995_1996 (
    CONSTRAINT ofec_sched_a_1995_1996_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1995, 1996])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1995_1996 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1995_1996 OWNER TO fec;

--
-- Name: ofec_sched_a_1997_1998; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1997_1998 (
    CONSTRAINT ofec_sched_a_1997_1998_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1997, 1998])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1997_1998 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1997_1998 OWNER TO fec;

--
-- Name: ofec_sched_a_1999_2000; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_1999_2000 (
    CONSTRAINT ofec_sched_a_1999_2000_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1999, 2000])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_1999_2000 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_1999_2000 OWNER TO fec;

--
-- Name: ofec_sched_a_2001_2002; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2001_2002 (
    CONSTRAINT ofec_sched_a_2001_2002_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2001, 2002])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2001_2002 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2001_2002 OWNER TO fec;

--
-- Name: ofec_sched_a_2003_2004; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2003_2004 (
    CONSTRAINT ofec_sched_a_2003_2004_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2003, 2004])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2003_2004 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2003_2004 OWNER TO fec;

--
-- Name: ofec_sched_a_2005_2006; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2005_2006 (
    CONSTRAINT ofec_sched_a_2005_2006_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2005, 2006])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2005_2006 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2005_2006 OWNER TO fec;

--
-- Name: ofec_sched_a_2007_2008; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2007_2008 (
    CONSTRAINT ofec_sched_a_2007_2008_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2007, 2008])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2007_2008 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2007_2008 OWNER TO fec;

--
-- Name: ofec_sched_a_2009_2010; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2009_2010 (
    CONSTRAINT ofec_sched_a_2009_2010_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2009, 2010])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2009_2010 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2009_2010 OWNER TO fec;

--
-- Name: ofec_sched_a_2011_2012; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2011_2012 (
    CONSTRAINT ofec_sched_a_2011_2012_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2011, 2012])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2011_2012 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2011_2012 OWNER TO fec;

--
-- Name: ofec_sched_a_2013_2014; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2013_2014 (
    CONSTRAINT ofec_sched_a_2013_2014_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2013, 2014])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2013_2014 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2013_2014 OWNER TO fec;

--
-- Name: ofec_sched_a_2015_2016; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2015_2016 (
    CONSTRAINT ofec_sched_a_2015_2016_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2015, 2016])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2015_2016 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2015_2016 OWNER TO fec;

--
-- Name: ofec_sched_a_2017_2018; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_2017_2018 (
    CONSTRAINT ofec_sched_a_2017_2018_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2017, 2018])))
)
INHERITS (ofec_sched_a_master);
ALTER TABLE ONLY ofec_sched_a_2017_2018 ALTER COLUMN contbr_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_a_2017_2018 OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_contributor; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_contributor (
    cmte_id character varying(9),
    cycle numeric,
    contbr_id character varying,
    contbr_nm text,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_contributor OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_contributor_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_contributor_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_contributor_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_contributor_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_contributor_idx_seq OWNED BY ofec_sched_a_aggregate_contributor.idx;


--
-- Name: ofec_sched_a_aggregate_contributor_type; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_contributor_type (
    cmte_id character varying(9),
    cycle numeric,
    individual boolean,
    total numeric,
    count bigint
);


ALTER TABLE ofec_sched_a_aggregate_contributor_type OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_employer; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_employer (
    cmte_id character varying(9),
    cycle numeric,
    employer character varying(38),
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_employer OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_employer_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_employer_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_employer_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_employer_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_employer_tmp_idx_seq OWNED BY ofec_sched_a_aggregate_employer.idx;


--
-- Name: ofec_sched_a_aggregate_occupation; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_occupation (
    cmte_id character varying(9),
    cycle numeric,
    occupation character varying(38),
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_occupation OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_occupation_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_occupation_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_occupation_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_occupation_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_occupation_tmp_idx_seq OWNED BY ofec_sched_a_aggregate_occupation.idx;


--
-- Name: ofec_sched_a_aggregate_size; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_size (
    cmte_id character varying(9),
    cycle numeric,
    size integer,
    total numeric,
    count bigint
);


ALTER TABLE ofec_sched_a_aggregate_size OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_size_merged; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_size_merged (
    idx bigint,
    cmte_id character varying(9),
    cycle numeric,
    size integer,
    total numeric,
    count numeric
);


ALTER TABLE ofec_sched_a_aggregate_size_merged OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_size_merged_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_sched_a_aggregate_size_merged_mv AS
 WITH grouped AS (
         SELECT ofec_totals_combined_mv.committee_id AS cmte_id,
            ofec_totals_combined_mv.cycle,
            0 AS size,
            ofec_totals_combined_mv.individual_unitemized_contributions AS total,
            0 AS count
           FROM ofec_totals_combined_mv
          WHERE (ofec_totals_combined_mv.cycle >= 2007)
        UNION ALL
         SELECT ofec_sched_a_aggregate_size.cmte_id,
            ofec_sched_a_aggregate_size.cycle,
            ofec_sched_a_aggregate_size.size,
            ofec_sched_a_aggregate_size.total,
            ofec_sched_a_aggregate_size.count
           FROM ofec_sched_a_aggregate_size
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
  WITH NO DATA;


ALTER TABLE ofec_sched_a_aggregate_size_merged_mv OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_state (
    cmte_id character varying(9),
    cycle numeric,
    state character varying(2),
    state_full text,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_state OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_state_old (
    cmte_id character varying(9),
    cycle numeric,
    state character varying(2),
    state_full text,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_state_old OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_recipient_totals; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_state_recipient_totals (
    idx bigint,
    total numeric,
    count numeric,
    cycle numeric,
    state character varying(2),
    state_full text,
    committee_type character varying,
    committee_type_full text
);


ALTER TABLE ofec_sched_a_aggregate_state_recipient_totals OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_recipient_totals_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_sched_a_aggregate_state_recipient_totals_mv AS
 WITH grouped_totals AS (
         SELECT sum(agg_st.total) AS total,
            count(agg_st.total) AS count,
            agg_st.cycle,
            agg_st.state,
            agg_st.state_full,
            cd.committee_type,
            cd.committee_type_full
           FROM (ofec_sched_a_aggregate_state agg_st
             JOIN ofec_committee_detail_mv cd ON (((agg_st.cmte_id)::text = (cd.committee_id)::text)))
          WHERE ((agg_st.state)::text IN ( SELECT ofec_fips_states."Official USPS Code"
                   FROM ofec_fips_states))
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
          WHERE ((totals.committee_type)::text = ANY ((ARRAY['H'::character varying, 'S'::character varying, 'P'::character varying])::text[]))
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
          WHERE ((totals.committee_type)::text = ANY ((ARRAY['N'::character varying, 'O'::character varying, 'Q'::character varying, 'V'::character varying, 'W'::character varying])::text[]))
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
   FROM combined
  WITH NO DATA;


ALTER TABLE ofec_sched_a_aggregate_state_recipient_totals_mv OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_state_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_state_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_state_tmp_idx_seq OWNED BY ofec_sched_a_aggregate_state.idx;


--
-- Name: ofec_sched_a_aggregate_state_tmp_idx_seq1; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_state_tmp_idx_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_state_tmp_idx_seq1 OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_state_tmp_idx_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_state_tmp_idx_seq1 OWNED BY ofec_sched_a_aggregate_state_old.idx;


--
-- Name: ofec_sched_a_aggregate_zip; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_aggregate_zip (
    cmte_id character varying(9),
    cycle numeric,
    zip character varying(9),
    state text,
    state_full text,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_a_aggregate_zip OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_zip_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_a_aggregate_zip_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_a_aggregate_zip_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_a_aggregate_zip_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_a_aggregate_zip_tmp_idx_seq OWNED BY ofec_sched_a_aggregate_zip.idx;


--
-- Name: ofec_sched_a_fulltext; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_fulltext (
    sched_a_sk numeric(10,0) NOT NULL,
    contributor_name_text tsvector,
    contributor_employer_text tsvector,
    contributor_occupation_text tsvector
);


ALTER TABLE ofec_sched_a_fulltext OWNER TO fec;

--
-- Name: ofec_sched_a_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_queue_new (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_nm character varying(8),
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone,
    two_year_transaction_period smallint
);


ALTER TABLE ofec_sched_a_queue_new OWNER TO fec;

--
-- Name: ofec_sched_a_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_a_queue_old (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    contbr_id character varying(9),
    contbr_nm character varying(200),
    contbr_nm_first character varying(38),
    contbr_m_nm character varying(20),
    contbr_nm_last character varying(38),
    contbr_prefix character varying(10),
    contbr_suffix character varying(10),
    contbr_st1 character varying(34),
    contbr_st2 character varying(34),
    contbr_city character varying(30),
    contbr_st character varying(2),
    contbr_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    contbr_employer character varying(38),
    contbr_occupation character varying(38),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_yr character varying(4),
    election_tp_desc character varying(20),
    contb_aggregate_ytd numeric(14,2),
    contb_receipt_dt timestamp without time zone,
    contb_receipt_amt numeric(14,2),
    receipt_tp character varying(3),
    receipt_tp_desc character varying(90),
    receipt_desc character varying(100),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_m_nm character varying(20),
    cand_nm_last character varying(38),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    donor_cmte_nm character varying(200),
    national_cmte_nonfed_acct character varying(9),
    increased_limit character varying(1),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_nm character varying(8),
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone,
    two_year_transaction_period smallint
);


ALTER TABLE ofec_sched_a_queue_old OWNER TO fec;

--
-- Name: ofec_sched_b_master; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_master (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id text,
    back_ref_tran_id text,
    back_ref_sched_id text,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8) NOT NULL,
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric(4,0),
    "timestamp" timestamp without time zone,
    pg_date timestamp without time zone,
    pdf_url text,
    recipient_name_text tsvector,
    disbursement_description_text tsvector,
    disbursement_purpose_category text,
    clean_recipient_cmte_id character varying(9),
    two_year_transaction_period smallint,
    line_number_label text
);


ALTER TABLE ofec_sched_b_master OWNER TO fec;

--
-- Name: ofec_sched_b_1977_1978; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1977_1978 (
    CONSTRAINT ofec_sched_b_1977_1978_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1977, 1978])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1977_1978 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1977_1978 OWNER TO fec;

--
-- Name: ofec_sched_b_1979_1980; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1979_1980 (
    CONSTRAINT ofec_sched_b_1979_1980_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1979, 1980])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1979_1980 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1979_1980 OWNER TO fec;

--
-- Name: ofec_sched_b_1981_1982; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1981_1982 (
    CONSTRAINT ofec_sched_b_1981_1982_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1981, 1982])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1981_1982 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1981_1982 OWNER TO fec;

--
-- Name: ofec_sched_b_1983_1984; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1983_1984 (
    CONSTRAINT ofec_sched_b_1983_1984_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1983, 1984])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1983_1984 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1983_1984 OWNER TO fec;

--
-- Name: ofec_sched_b_1985_1986; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1985_1986 (
    CONSTRAINT ofec_sched_b_1985_1986_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1985, 1986])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1985_1986 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1985_1986 OWNER TO fec;

--
-- Name: ofec_sched_b_1987_1988; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1987_1988 (
    CONSTRAINT ofec_sched_b_1987_1988_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1987, 1988])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1987_1988 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1987_1988 OWNER TO fec;

--
-- Name: ofec_sched_b_1989_1990; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1989_1990 (
    CONSTRAINT ofec_sched_b_1989_1990_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1989, 1990])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1989_1990 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1989_1990 OWNER TO fec;

--
-- Name: ofec_sched_b_1991_1992; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1991_1992 (
    CONSTRAINT ofec_sched_b_1991_1992_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1991, 1992])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1991_1992 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1991_1992 OWNER TO fec;

--
-- Name: ofec_sched_b_1993_1994; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1993_1994 (
    CONSTRAINT ofec_sched_b_1993_1994_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1993, 1994])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1993_1994 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1993_1994 OWNER TO fec;

--
-- Name: ofec_sched_b_1995_1996; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1995_1996 (
    CONSTRAINT ofec_sched_b_1995_1996_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1995, 1996])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1995_1996 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1995_1996 OWNER TO fec;

--
-- Name: ofec_sched_b_1997_1998; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1997_1998 (
    CONSTRAINT ofec_sched_b_1997_1998_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1997, 1998])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1997_1998 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1997_1998 OWNER TO fec;

--
-- Name: ofec_sched_b_1999_2000; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_1999_2000 (
    CONSTRAINT ofec_sched_b_1999_2000_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[1999, 2000])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_1999_2000 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_1999_2000 OWNER TO fec;

--
-- Name: ofec_sched_b_2001_2002; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2001_2002 (
    CONSTRAINT ofec_sched_b_2001_2002_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2001, 2002])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2001_2002 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2001_2002 OWNER TO fec;

--
-- Name: ofec_sched_b_2003_2004; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2003_2004 (
    CONSTRAINT ofec_sched_b_2003_2004_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2003, 2004])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2003_2004 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2003_2004 OWNER TO fec;

--
-- Name: ofec_sched_b_2005_2006; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2005_2006 (
    CONSTRAINT ofec_sched_b_2005_2006_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2005, 2006])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2005_2006 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2005_2006 OWNER TO fec;

--
-- Name: ofec_sched_b_2007_2008; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2007_2008 (
    CONSTRAINT ofec_sched_b_2007_2008_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2007, 2008])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2007_2008 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2007_2008 OWNER TO fec;

--
-- Name: ofec_sched_b_2009_2010; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2009_2010 (
    CONSTRAINT ofec_sched_b_2009_2010_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2009, 2010])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2009_2010 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2009_2010 OWNER TO fec;

--
-- Name: ofec_sched_b_2011_2012; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2011_2012 (
    CONSTRAINT ofec_sched_b_2011_2012_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2011, 2012])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2011_2012 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2011_2012 OWNER TO fec;

--
-- Name: ofec_sched_b_2013_2014; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2013_2014 (
    CONSTRAINT ofec_sched_b_2013_2014_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2013, 2014])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2013_2014 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2013_2014 OWNER TO fec;

--
-- Name: ofec_sched_b_2015_2016; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2015_2016 (
    CONSTRAINT ofec_sched_b_2015_2016_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2015, 2016])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2015_2016 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2015_2016 OWNER TO fec;

--
-- Name: ofec_sched_b_2017_2018; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_2017_2018 (
    CONSTRAINT ofec_sched_b_2017_2018_tmp_two_year_transaction_period_check1 CHECK ((two_year_transaction_period = ANY (ARRAY[2017, 2018])))
)
INHERITS (ofec_sched_b_master);
ALTER TABLE ONLY ofec_sched_b_2017_2018 ALTER COLUMN recipient_st SET STATISTICS 1000;


ALTER TABLE ofec_sched_b_2017_2018 OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_purpose; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_aggregate_purpose (
    cmte_id character varying(9),
    cycle numeric,
    purpose character varying,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_b_aggregate_purpose OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_purpose_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_b_aggregate_purpose_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_b_aggregate_purpose_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_purpose_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_b_aggregate_purpose_tmp_idx_seq OWNED BY ofec_sched_b_aggregate_purpose.idx;


--
-- Name: ofec_sched_b_aggregate_recipient; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_aggregate_recipient (
    cmte_id character varying(9),
    cycle numeric,
    recipient_nm character varying(200),
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_b_aggregate_recipient OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_recipient_id; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_aggregate_recipient_id (
    cmte_id character varying(9),
    cycle numeric,
    recipient_cmte_id character varying,
    recipient_nm text,
    total numeric,
    count bigint,
    idx integer NOT NULL
);


ALTER TABLE ofec_sched_b_aggregate_recipient_id OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_recipient_id_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_b_aggregate_recipient_id_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_b_aggregate_recipient_id_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_recipient_id_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_b_aggregate_recipient_id_tmp_idx_seq OWNED BY ofec_sched_b_aggregate_recipient_id.idx;


--
-- Name: ofec_sched_b_aggregate_recipient_tmp_idx_seq; Type: SEQUENCE; Schema: public; Owner: fec
--

CREATE SEQUENCE ofec_sched_b_aggregate_recipient_tmp_idx_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ofec_sched_b_aggregate_recipient_tmp_idx_seq OWNER TO fec;

--
-- Name: ofec_sched_b_aggregate_recipient_tmp_idx_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fec
--

ALTER SEQUENCE ofec_sched_b_aggregate_recipient_tmp_idx_seq OWNED BY ofec_sched_b_aggregate_recipient.idx;


--
-- Name: ofec_sched_b_fulltext; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_fulltext (
    sched_b_sk numeric(10,0) NOT NULL,
    recipient_name_text tsvector,
    disbursement_description_text tsvector
);


ALTER TABLE ofec_sched_b_fulltext OWNER TO fec;

--
-- Name: ofec_sched_b_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_queue_new (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_id character varying,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone,
    two_year_transaction_period smallint
);


ALTER TABLE ofec_sched_b_queue_new OWNER TO fec;

--
-- Name: ofec_sched_b_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_b_queue_old (
    cmte_id character varying(9),
    recipient_cmte_id character varying(9),
    recipient_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    payee_employer character varying(38),
    payee_occupation character varying(38),
    recipient_st1 character varying(34),
    recipient_st2 character varying(34),
    recipient_city character varying(30),
    recipient_st character varying(2),
    recipient_zip character varying(9),
    disb_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    fec_election_tp_year character varying(4),
    election_tp_desc character varying(20),
    cand_id character varying(9),
    cand_nm character varying(90),
    cand_nm_first character varying(38),
    cand_nm_last character varying(38),
    cand_m_nm character varying(20),
    cand_prefix character varying(10),
    cand_suffix character varying(10),
    cand_office character varying(1),
    cand_office_desc character varying(20),
    cand_office_st character varying(2),
    cand_office_st_desc character varying(20),
    cand_office_district character varying(2),
    disb_dt timestamp without time zone,
    disb_amt numeric(14,2),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    disb_tp character varying(3),
    disb_tp_desc character varying(90),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    national_cmte_nonfed_acct character varying(9),
    ref_disp_excess_flg character varying(1),
    comm_dt timestamp without time zone,
    benef_cmte_nm character varying(200),
    semi_an_bundled_refund numeric(14,2),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_id character varying,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone,
    two_year_transaction_period smallint
);


ALTER TABLE ofec_sched_b_queue_old OWNER TO fec;

--
-- Name: ofec_sched_c_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_sched_c_mv AS
 SELECT fec_fitem_sched_c_vw.cmte_id,
    fec_fitem_sched_c_vw.cmte_nm,
    fec_fitem_sched_c_vw.loan_src_l_nm,
    fec_fitem_sched_c_vw.loan_src_f_nm,
    fec_fitem_sched_c_vw.loan_src_m_nm,
    fec_fitem_sched_c_vw.loan_src_prefix,
    fec_fitem_sched_c_vw.loan_src_suffix,
    fec_fitem_sched_c_vw.loan_src_nm,
    fec_fitem_sched_c_vw.loan_src_st1,
    fec_fitem_sched_c_vw.loan_src_st2,
    fec_fitem_sched_c_vw.loan_src_city,
    fec_fitem_sched_c_vw.loan_src_st,
    fec_fitem_sched_c_vw.loan_src_zip,
    fec_fitem_sched_c_vw.entity_tp,
    fec_fitem_sched_c_vw.entity_tp_desc,
    fec_fitem_sched_c_vw.election_tp,
    fec_fitem_sched_c_vw.fec_election_tp_desc,
    fec_fitem_sched_c_vw.fec_election_tp_year,
    fec_fitem_sched_c_vw.election_tp_desc,
    fec_fitem_sched_c_vw.orig_loan_amt,
    fec_fitem_sched_c_vw.pymt_to_dt,
    fec_fitem_sched_c_vw.loan_bal,
    fec_fitem_sched_c_vw.incurred_dt,
    fec_fitem_sched_c_vw.due_dt_terms,
    fec_fitem_sched_c_vw.interest_rate_terms,
    fec_fitem_sched_c_vw.secured_ind,
    fec_fitem_sched_c_vw.sched_a_line_num,
    fec_fitem_sched_c_vw.pers_fund_yes_no,
    fec_fitem_sched_c_vw.memo_cd,
    fec_fitem_sched_c_vw.memo_text,
    fec_fitem_sched_c_vw.fec_cmte_id,
    fec_fitem_sched_c_vw.cand_id,
    fec_fitem_sched_c_vw.cand_nm,
    fec_fitem_sched_c_vw.cand_nm_first,
    fec_fitem_sched_c_vw.cand_nm_last,
    fec_fitem_sched_c_vw.cand_m_nm,
    fec_fitem_sched_c_vw.cand_prefix,
    fec_fitem_sched_c_vw.cand_suffix,
    fec_fitem_sched_c_vw.cand_office,
    fec_fitem_sched_c_vw.cand_office_desc,
    fec_fitem_sched_c_vw.cand_office_st,
    fec_fitem_sched_c_vw.cand_office_state_desc,
    fec_fitem_sched_c_vw.cand_office_district,
    fec_fitem_sched_c_vw.action_cd,
    fec_fitem_sched_c_vw.action_cd_desc,
    fec_fitem_sched_c_vw.tran_id,
    fec_fitem_sched_c_vw.schedule_type,
    fec_fitem_sched_c_vw.schedule_type_desc,
    fec_fitem_sched_c_vw.line_num,
    fec_fitem_sched_c_vw.image_num,
    fec_fitem_sched_c_vw.file_num,
    fec_fitem_sched_c_vw.link_id,
    fec_fitem_sched_c_vw.orig_sub_id,
    fec_fitem_sched_c_vw.sub_id,
    fec_fitem_sched_c_vw.filing_form,
    fec_fitem_sched_c_vw.rpt_tp,
    fec_fitem_sched_c_vw.rpt_yr,
    fec_fitem_sched_c_vw.election_cycle,
    to_tsvector((fec_fitem_sched_c_vw.cand_nm)::text) AS candidate_name_text,
    to_tsvector((fec_fitem_sched_c_vw.loan_src_nm)::text) AS loan_source_name_text,
    now() AS pg_date
   FROM fec_fitem_sched_c_vw
  WITH NO DATA;


ALTER TABLE ofec_sched_c_mv OWNER TO fec;

--
-- Name: ofec_sched_e; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_e (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    exp_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    dissem_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_dt timestamp without time zone,
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_nm character varying,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0) NOT NULL,
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone,
    pdf_url text,
    is_notice boolean,
    payee_name_text tsvector,
    pg_date timestamp with time zone
);


ALTER TABLE ofec_sched_e OWNER TO fec;

--
-- Name: ofec_sched_e_aggregate_candidate_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_sched_e_aggregate_candidate_mv AS
 WITH records AS (
         SELECT fec_fitem_sched_e_vw.cmte_id,
            fec_fitem_sched_e_vw.s_o_cand_id AS cand_id,
            fec_fitem_sched_e_vw.s_o_ind AS support_oppose_indicator,
            fec_fitem_sched_e_vw.rpt_yr,
            fec_fitem_sched_e_vw.rpt_tp,
            fec_fitem_sched_e_vw.memo_cd,
            fec_fitem_sched_e_vw.exp_amt
           FROM fec_fitem_sched_e_vw
        UNION ALL
         SELECT f57.filer_cmte_id AS cmte_id,
            f57.s_o_cand_id AS cand_id,
            f57.s_o_ind AS support_oppose_indicator,
            f5.rpt_yr,
            f5.rpt_tp,
            NULL::character varying AS memo_cd,
            f57.exp_amt
           FROM (fec_fitem_f57_vw f57
             JOIN fec_vsum_f5_vw f5 ON ((f5.sub_id = f57.link_id)))
        )
 SELECT row_number() OVER () AS idx,
    records.cmte_id,
    records.cand_id,
    records.support_oppose_indicator,
    (records.rpt_yr + (records.rpt_yr % (2)::numeric)) AS cycle,
    sum(records.exp_amt) AS total,
    count(records.exp_amt) AS count
   FROM records
  WHERE ((records.exp_amt IS NOT NULL) AND ((records.rpt_tp)::text <> ALL ((ARRAY['24'::character varying, '48'::character varying])::text[])) AND (((records.memo_cd)::text <> 'X'::text) OR (records.memo_cd IS NULL)))
  GROUP BY records.cmte_id, records.cand_id, records.support_oppose_indicator, (records.rpt_yr + (records.rpt_yr % (2)::numeric))
  WITH NO DATA;


ALTER TABLE ofec_sched_e_aggregate_candidate_mv OWNER TO fec;

--
-- Name: ofec_sched_e_queue_new; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_e_queue_new (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    exp_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    dissem_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_dt timestamp without time zone,
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_nm character varying,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone
);


ALTER TABLE ofec_sched_e_queue_new OWNER TO fec;

--
-- Name: ofec_sched_e_queue_old; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_sched_e_queue_old (
    cmte_id character varying(9),
    cmte_nm character varying(200),
    pye_nm character varying(200),
    payee_l_nm character varying(30),
    payee_f_nm character varying(20),
    payee_m_nm character varying(20),
    payee_prefix character varying(10),
    payee_suffix character varying(10),
    pye_st1 character varying(34),
    pye_st2 character varying(34),
    pye_city character varying(30),
    pye_st character varying(2),
    pye_zip character varying(9),
    entity_tp character varying(3),
    entity_tp_desc character varying(50),
    exp_desc character varying(100),
    catg_cd character varying(3),
    catg_cd_desc character varying(40),
    s_o_cand_id character varying(9),
    s_o_cand_nm character varying(90),
    s_o_cand_nm_first character varying(38),
    s_o_cand_nm_last character varying(38),
    s_o_cand_m_nm character varying(20),
    s_o_cand_prefix character varying(10),
    s_o_cand_suffix character varying(10),
    s_o_cand_office character varying(1),
    s_o_cand_office_desc character varying(20),
    s_o_cand_office_st character varying(2),
    s_o_cand_office_st_desc character varying(20),
    s_o_cand_office_district character varying(2),
    s_o_ind character varying(3),
    s_o_ind_desc character varying(50),
    election_tp character varying(5),
    fec_election_tp_desc character varying(20),
    cal_ytd_ofc_sought numeric(14,2),
    dissem_dt timestamp without time zone,
    exp_amt numeric(14,2),
    exp_dt timestamp without time zone,
    exp_tp character varying(3),
    exp_tp_desc character varying(90),
    memo_cd character varying(1),
    memo_cd_desc character varying(50),
    memo_text character varying(100),
    conduit_cmte_id character varying(9),
    conduit_cmte_nm character varying(200),
    conduit_cmte_st1 character varying(34),
    conduit_cmte_st2 character varying(34),
    conduit_cmte_city character varying(30),
    conduit_cmte_st character varying(2),
    conduit_cmte_zip character varying(9),
    indt_sign_nm character varying(90),
    indt_sign_dt timestamp without time zone,
    notary_sign_nm character varying(90),
    notary_sign_dt timestamp without time zone,
    notary_commission_exprtn_dt timestamp without time zone,
    filer_l_nm character varying(30),
    filer_f_nm character varying(20),
    filer_m_nm character varying(20),
    filer_prefix character varying(10),
    filer_suffix character varying(10),
    action_cd character varying(1),
    action_cd_desc character varying(15),
    tran_id character varying,
    back_ref_tran_id character varying,
    back_ref_sched_nm character varying,
    schedule_type character varying(2),
    schedule_type_desc character varying(90),
    line_num character varying(12),
    image_num character varying(18),
    file_num numeric(7,0),
    link_id numeric(19,0),
    orig_sub_id numeric(19,0),
    sub_id numeric(19,0),
    filing_form character varying(8),
    rpt_tp character varying(3),
    rpt_yr numeric(4,0),
    election_cycle numeric,
    "timestamp" timestamp without time zone
);


ALTER TABLE ofec_sched_e_queue_old OWNER TO fec;

--
-- Name: ofec_sched_f_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_sched_f_mv AS
 SELECT fec_fitem_sched_f_vw.cmte_id,
    fec_fitem_sched_f_vw.cmte_nm,
    fec_fitem_sched_f_vw.cmte_desg_coord_exp_ind,
    fec_fitem_sched_f_vw.desg_cmte_id,
    fec_fitem_sched_f_vw.desg_cmte_nm,
    fec_fitem_sched_f_vw.subord_cmte_id,
    fec_fitem_sched_f_vw.subord_cmte_nm,
    fec_fitem_sched_f_vw.subord_cmte_st1,
    fec_fitem_sched_f_vw.subord_cmte_st2,
    fec_fitem_sched_f_vw.subord_cmte_city,
    fec_fitem_sched_f_vw.subord_cmte_st,
    fec_fitem_sched_f_vw.subord_cmte_zip,
    fec_fitem_sched_f_vw.entity_tp,
    fec_fitem_sched_f_vw.entity_tp_desc,
    fec_fitem_sched_f_vw.pye_nm,
    fec_fitem_sched_f_vw.payee_l_nm,
    fec_fitem_sched_f_vw.payee_f_nm,
    fec_fitem_sched_f_vw.payee_m_nm,
    fec_fitem_sched_f_vw.payee_prefix,
    fec_fitem_sched_f_vw.payee_suffix,
    fec_fitem_sched_f_vw.payee_name_text,
    fec_fitem_sched_f_vw.pye_st1,
    fec_fitem_sched_f_vw.pye_st2,
    fec_fitem_sched_f_vw.pye_city,
    fec_fitem_sched_f_vw.pye_st,
    fec_fitem_sched_f_vw.pye_zip,
    fec_fitem_sched_f_vw.aggregate_gen_election_exp,
    fec_fitem_sched_f_vw.exp_tp,
    fec_fitem_sched_f_vw.exp_tp_desc,
    fec_fitem_sched_f_vw.exp_purpose_desc,
    fec_fitem_sched_f_vw.exp_dt,
    fec_fitem_sched_f_vw.exp_amt,
    fec_fitem_sched_f_vw.cand_id,
    fec_fitem_sched_f_vw.cand_nm,
    fec_fitem_sched_f_vw.cand_nm_first,
    fec_fitem_sched_f_vw.cand_nm_last,
    fec_fitem_sched_f_vw.cand_m_nm,
    fec_fitem_sched_f_vw.cand_prefix,
    fec_fitem_sched_f_vw.cand_suffix,
    fec_fitem_sched_f_vw.cand_office,
    fec_fitem_sched_f_vw.cand_office_desc,
    fec_fitem_sched_f_vw.cand_office_st,
    fec_fitem_sched_f_vw.cand_office_st_desc,
    fec_fitem_sched_f_vw.cand_office_district,
    fec_fitem_sched_f_vw.conduit_cmte_id,
    fec_fitem_sched_f_vw.conduit_cmte_nm,
    fec_fitem_sched_f_vw.conduit_cmte_st1,
    fec_fitem_sched_f_vw.conduit_cmte_st2,
    fec_fitem_sched_f_vw.conduit_cmte_city,
    fec_fitem_sched_f_vw.conduit_cmte_st,
    fec_fitem_sched_f_vw.conduit_cmte_zip,
    fec_fitem_sched_f_vw.action_cd,
    fec_fitem_sched_f_vw.action_cd_desc,
    fec_fitem_sched_f_vw.tran_id,
    fec_fitem_sched_f_vw.back_ref_tran_id,
    fec_fitem_sched_f_vw.back_ref_sched_nm,
    fec_fitem_sched_f_vw.memo_cd,
    fec_fitem_sched_f_vw.memo_cd_desc,
    fec_fitem_sched_f_vw.memo_text,
    fec_fitem_sched_f_vw.unlimited_spending_flg,
    fec_fitem_sched_f_vw.unlimited_spending_flg_desc,
    fec_fitem_sched_f_vw.catg_cd,
    fec_fitem_sched_f_vw.catg_cd_desc,
    fec_fitem_sched_f_vw.schedule_type,
    fec_fitem_sched_f_vw.schedule_type_desc,
    fec_fitem_sched_f_vw.line_num,
    fec_fitem_sched_f_vw.image_num,
    fec_fitem_sched_f_vw.file_num,
    fec_fitem_sched_f_vw.link_id,
    fec_fitem_sched_f_vw.orig_sub_id,
    fec_fitem_sched_f_vw.sub_id,
    fec_fitem_sched_f_vw.pg_date,
    fec_fitem_sched_f_vw.filing_form,
    fec_fitem_sched_f_vw.rpt_tp,
    fec_fitem_sched_f_vw.rpt_yr,
    fec_fitem_sched_f_vw.election_cycle
   FROM fec_fitem_sched_f_vw
  WITH NO DATA;


ALTER TABLE ofec_sched_f_mv OWNER TO fec;

--
-- Name: ofec_totals_candidate_committees_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_candidate_committees_mv AS
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
            v_sum.debts_owed_by_cmte AS debts_owed_by_committee,
            v_sum.debts_owed_to_cmte AS debts_owed_to_committee,
            of.report_type_full,
            of.beginning_image_number,
            link.cand_id AS candidate_id,
            link.fec_election_yr AS cycle,
            link.cand_election_yr AS election_year
           FROM ((disclosure.v_sum_and_det_sum_report v_sum
             LEFT JOIN ofec_cand_cmte_linkage_mv link USING (cmte_id))
             LEFT JOIN ofec_filings_mv of ON ((of.sub_id = v_sum.orig_sub_id)))
          WHERE ((((v_sum.form_tp_cd)::text = 'F3P'::text) OR ((v_sum.form_tp_cd)::text = 'F3'::text)) AND (((link.cmte_dsgn)::text = 'A'::text) OR ((link.cmte_dsgn)::text = 'P'::text)) AND (v_sum.cvg_end_dt <> (99999999)::numeric) AND (link.fec_election_yr = (get_cycle(((date_part('year'::text, ((v_sum.cvg_end_dt)::text)::timestamp without time zone))::integer)::numeric))::numeric) AND (link.fec_election_yr >= (1979)::numeric))
          ORDER BY v_sum.cmte_id, link.fec_election_yr, v_sum.cvg_end_dt DESC NULLS LAST
        ), ending_totals_per_cycle AS (
         SELECT last.cycle,
            last.candidate_id,
            max(last.coverage_end_date) AS coverage_end_date,
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
            sum((p.pol_pty_cmte_contb + p.oth_cmte_ref)) AS contribution_refunds,
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
           FROM (ofec_cand_cmte_linkage_mv link
             LEFT JOIN disclosure.v_sum_and_det_sum_report p ON ((((link.cmte_id)::text = (p.cmte_id)::text) AND (link.fec_election_yr = (get_cycle(p.rpt_yr))::numeric))))
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
            max(totals.coverage_end_date) AS coverage_end_date
           FROM (cycle_totals_with_ending_aggregates totals
             LEFT JOIN ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle <= (election.cand_election_year)::numeric) AND (totals.cycle > (election.prev_election_year)::numeric))))
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
            totals.last_report_type_full,
            totals.last_beginning_image_number,
            totals.last_cash_on_hand_end_period,
            totals.last_debts_owed_by_committee,
            totals.last_debts_owed_to_committee,
            totals.last_report_year,
            totals.last_net_operating_expenditures,
            totals.last_net_contributions
           FROM ((ending_totals_per_cycle totals
             LEFT JOIN ofec_candidate_election_mv election ON ((((totals.candidate_id)::text = (election.candidate_id)::text) AND (totals.cycle = (election.cand_election_year)::numeric))))
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
    election_totals_with_ending_aggregates.last_report_type_full,
    election_totals_with_ending_aggregates.last_beginning_image_number,
    election_totals_with_ending_aggregates.last_cash_on_hand_end_period,
    election_totals_with_ending_aggregates.last_debts_owed_by_committee,
    election_totals_with_ending_aggregates.last_debts_owed_to_committee,
    election_totals_with_ending_aggregates.last_report_year,
    election_totals_with_ending_aggregates.last_net_operating_expenditures,
    election_totals_with_ending_aggregates.last_net_contributions
   FROM election_totals_with_ending_aggregates
  WITH NO DATA;


ALTER TABLE ofec_totals_candidate_committees_mv OWNER TO fec;

--
-- Name: ofec_totals_ie_only_mv; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

CREATE MATERIALIZED VIEW ofec_totals_ie_only_mv AS
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
   FROM ofec_totals_combined_mv
  WHERE ((ofec_totals_combined_mv.form_type)::text = 'F5'::text)
  WITH NO DATA;


ALTER TABLE ofec_totals_ie_only_mv OWNER TO fec;

--
-- Name: ofec_two_year_periods; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_two_year_periods (
    year numeric(4,0)
);


ALTER TABLE ofec_two_year_periods OWNER TO fec;

--
-- Name: ofec_zips_districts; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE ofec_zips_districts (
    index bigint,
    "State" bigint,
    "ZCTA" bigint,
    "Congressional District" bigint
);


ALTER TABLE ofec_zips_districts OWNER TO fec;

--
-- Name: pacronyms; Type: TABLE; Schema: public; Owner: fec
--

CREATE TABLE pacronyms (
    "PACRONYM" character varying(44),
    "ID NUMBER" character varying(9),
    "FULL NAME" character varying(170),
    "CITY" character varying(18),
    "STATE" character varying(4),
    "CONNECTED ORGANIZATION OR SPONSOR NAME" character varying(153),
    "DESIGNATION" character varying(28),
    "COMMITTEE TYPE" character varying(40)
);


ALTER TABLE pacronyms OWNER TO fec;
