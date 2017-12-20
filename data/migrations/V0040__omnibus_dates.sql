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
            AND election_date < to_date('2018-01-01','YYYY-MM-DD')
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
            AND reports.due_date < to_date('2018-01-01','YYYY-MM-DD')
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
-- Name: ofec_omnibus_dates_mv_tmp_category_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_category_idx ON ofec_omnibus_dates_mv USING btree (category);


--
-- Name: ofec_omnibus_dates_mv_tmp_description_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_description_text_idx ON ofec_omnibus_dates_mv USING gin (description_text);


--
-- Name: ofec_omnibus_dates_mv_tmp_end_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_end_date_idx ON ofec_omnibus_dates_mv USING btree (end_date);


--
-- Name: ofec_omnibus_dates_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_omnibus_dates_mv_tmp_idx_idx ON ofec_omnibus_dates_mv USING btree (idx);


--
-- Name: ofec_omnibus_dates_mv_tmp_location_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_location_idx ON ofec_omnibus_dates_mv USING btree (location);


--
-- Name: ofec_omnibus_dates_mv_tmp_start_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_start_date_idx ON ofec_omnibus_dates_mv USING btree (start_date);


--
-- Name: ofec_omnibus_dates_mv_tmp_states_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_states_idx ON ofec_omnibus_dates_mv USING gin (states);


--
-- Name: ofec_omnibus_dates_mv_tmp_summary_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_omnibus_dates_mv_tmp_summary_text_idx ON ofec_omnibus_dates_mv USING gin (summary_text);

--
-- Name: ofec_omnibus_dates_mv; Type: ACL; Schema: public; Owner: fec
--

GRANT SELECT ON TABLE ofec_omnibus_dates_mv TO fec_read;
