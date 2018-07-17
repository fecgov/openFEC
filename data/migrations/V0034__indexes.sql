SET search_path = disclosure, pg_catalog;

--
-- Name: idx_committee_summary_pk; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE UNIQUE INDEX idx_committee_summary_pk ON committee_summary USING btree (cmte_id, cand_id, fec_election_yr);

--
-- Name: nml_sched_b_link_id_idx; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX nml_sched_b_link_id_idx ON nml_sched_b USING btree (link_id);


--
-- Name: ofec_sched_a_aggregate_employer_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cmte_id ON dsc_sched_a_aggregate_employer USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_employer_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_count ON dsc_sched_a_aggregate_employer USING btree (count);


--
-- Name: ofec_sched_a_aggregate_employer_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cycle ON dsc_sched_a_aggregate_employer USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_employer_cycle_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cycle_cmte_id ON dsc_sched_a_aggregate_employer USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_employer_employer; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_employer ON dsc_sched_a_aggregate_employer USING btree (employer);


--
-- Name: ofec_sched_a_aggregate_employer_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_total ON dsc_sched_a_aggregate_employer USING btree (total);


--
-- Name: ofec_sched_a_aggregate_occupation_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cmte_id ON dsc_sched_a_aggregate_occupation USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_occupation_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_count ON dsc_sched_a_aggregate_occupation USING btree (count);


--
-- Name: ofec_sched_a_aggregate_occupation_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cycle ON dsc_sched_a_aggregate_occupation USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_occupation_cycle_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cycle_cmte_id ON dsc_sched_a_aggregate_occupation USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_occupation_occupation; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_occupation ON dsc_sched_a_aggregate_occupation USING btree (occupation);


--
-- Name: ofec_sched_a_aggregate_occupation_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_total ON dsc_sched_a_aggregate_occupation USING btree (total);


--
-- Name: ofec_sched_a_aggregate_size_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cmte_id ON dsc_sched_a_aggregate_size USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_size_cmte_id_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cmte_id_cycle ON dsc_sched_a_aggregate_size USING btree (cmte_id, cycle);


--
-- Name: ofec_sched_a_aggregate_size_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_count ON dsc_sched_a_aggregate_size USING btree (count);


--
-- Name: ofec_sched_a_aggregate_size_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cycle ON dsc_sched_a_aggregate_size USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_size_size; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_size ON dsc_sched_a_aggregate_size USING btree (size);


--
-- Name: ofec_sched_a_aggregate_size_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_total ON dsc_sched_a_aggregate_size USING btree (total);


--
-- Name: ofec_sched_a_aggregate_state_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cmte_id ON dsc_sched_a_aggregate_state USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_count ON dsc_sched_a_aggregate_state USING btree (count);


--
-- Name: ofec_sched_a_aggregate_state_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle ON dsc_sched_a_aggregate_state USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_state_cycle_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle_cmte_id ON dsc_sched_a_aggregate_state USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_state; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state ON dsc_sched_a_aggregate_state USING btree (state);


--
-- Name: ofec_sched_a_aggregate_state_state_full; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state_full ON dsc_sched_a_aggregate_state USING btree (state_full);


--
-- Name: ofec_sched_a_aggregate_state_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_total ON dsc_sched_a_aggregate_state USING btree (total);


--
-- Name: ofec_sched_a_aggregate_zip_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_cmte_id ON dsc_sched_a_aggregate_zip USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_zip_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_count ON dsc_sched_a_aggregate_zip USING btree (count);


--
-- Name: ofec_sched_a_aggregate_zip_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_cycle ON dsc_sched_a_aggregate_zip USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_zip_state; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_state ON dsc_sched_a_aggregate_zip USING btree (state);


--
-- Name: ofec_sched_a_aggregate_zip_state_full; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_state_full ON dsc_sched_a_aggregate_zip USING btree (state_full);


--
-- Name: ofec_sched_a_aggregate_zip_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_total ON dsc_sched_a_aggregate_zip USING btree (total);


--
-- Name: ofec_sched_a_aggregate_zip_zip; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_zip ON dsc_sched_a_aggregate_zip USING btree (zip);


--
-- Name: ofec_sched_b_aggregate_purpose_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cmte_id ON dsc_sched_b_aggregate_purpose USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_purpose_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_count ON dsc_sched_b_aggregate_purpose USING btree (count);


--
-- Name: ofec_sched_b_aggregate_purpose_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cycle ON dsc_sched_b_aggregate_purpose USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_purpose_cycle_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cycle_cmte_id ON dsc_sched_b_aggregate_purpose USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_b_aggregate_purpose_purpose; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_purpose ON dsc_sched_b_aggregate_purpose USING btree (purpose);


--
-- Name: ofec_sched_b_aggregate_purpose_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_total ON dsc_sched_b_aggregate_purpose USING btree (total);


--
-- Name: ofec_sched_b_aggregate_recipient_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cmte_id ON dsc_sched_b_aggregate_recipient USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_count ON dsc_sched_b_aggregate_recipient USING btree (count);


--
-- Name: ofec_sched_b_aggregate_recipient_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cycle ON dsc_sched_b_aggregate_recipient USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_cycle_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cycle_cmte_id ON dsc_sched_b_aggregate_recipient USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cmte_id ON dsc_sched_b_aggregate_recipient_id USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cmte_id_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cmte_id_cycle ON dsc_sched_b_aggregate_recipient_id USING btree (cmte_id, cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_id_count; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_count ON dsc_sched_b_aggregate_recipient_id USING btree (count);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cycle; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cycle ON dsc_sched_b_aggregate_recipient_id USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_id_recipient_cmte_id; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_recipient_cmte_id ON dsc_sched_b_aggregate_recipient_id USING btree (recipient_cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_total ON dsc_sched_b_aggregate_recipient_id USING btree (total);


--
-- Name: ofec_sched_b_aggregate_recipient_recipient_nm; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_recipient_nm ON dsc_sched_b_aggregate_recipient USING btree (recipient_nm);


--
-- Name: ofec_sched_b_aggregate_recipient_total; Type: INDEX; Schema: disclosure; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_total ON dsc_sched_b_aggregate_recipient USING btree (total);


SET search_path = fecapp, pg_catalog;

--
-- Name: trc_election_dates_election_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_dates_election_date_idx ON trc_election_dates USING btree (election_date);


--
-- Name: trc_election_election_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_election_date_idx ON trc_election USING btree (election_date);


--
-- Name: trc_election_election_district_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_election_district_idx ON trc_election USING btree (election_district);


--
-- Name: trc_election_election_state_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_election_state_idx ON trc_election USING btree (election_state);


--
-- Name: trc_election_election_yr_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_election_yr_idx ON trc_election USING btree (election_yr);


--
-- Name: trc_election_office_sought_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_office_sought_idx ON trc_election USING btree (office_sought);


--
-- Name: trc_election_update_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_election_update_date_idx ON trc_election USING btree (update_date);


--
-- Name: trc_report_due_date_create_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_report_due_date_create_date_idx ON trc_report_due_date USING btree (create_date);


--
-- Name: trc_report_due_date_due_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_report_due_date_due_date_idx ON trc_report_due_date USING btree (due_date);


--
-- Name: trc_report_due_date_report_type_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_report_due_date_report_type_idx ON trc_report_due_date USING btree (report_type);


--
-- Name: trc_report_due_date_report_year_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_report_due_date_report_year_idx ON trc_report_due_date USING btree (report_year);


--
-- Name: trc_report_due_date_update_date_idx; Type: INDEX; Schema: fecapp; Owner: fec
--

CREATE INDEX trc_report_due_date_update_date_idx ON trc_report_due_date USING btree (update_date);


SET search_path = public, pg_catalog;

--
-- Name: entity_disbursements_chart_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX entity_disbursements_chart_cycle_idx ON entity_disbursements_chart USING btree (cycle);


--
-- Name: entity_disbursements_chart_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX entity_disbursements_chart_idx_idx ON entity_disbursements_chart USING btree (idx);


--
-- Name: entity_receipts_chart_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX entity_receipts_chart_cycle_idx ON entity_receipts_chart USING btree (cycle);


--
-- Name: entity_receipts_chart_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX entity_receipts_chart_idx_idx ON entity_receipts_chart USING btree (idx);


--
-- Name: idx_ofec_sched_a_1977_1978_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_clean_contbr_id_amt ON ofec_sched_a_1977_1978 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_clean_contbr_id_dt ON ofec_sched_a_1977_1978 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_city_amt ON ofec_sched_a_1977_1978 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_city_dt ON ofec_sched_a_1977_1978 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_st_amt ON ofec_sched_a_1977_1978 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_st_dt ON ofec_sched_a_1977_1978 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_zip_amt ON ofec_sched_a_1977_1978 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contbr_zip_dt ON ofec_sched_a_1977_1978 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_emp_text_amt ON ofec_sched_a_1977_1978 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_emp_text_dt ON ofec_sched_a_1977_1978 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_name_text_amt ON ofec_sched_a_1977_1978 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_name_text_dt ON ofec_sched_a_1977_1978 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_occ_text_amt ON ofec_sched_a_1977_1978 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_contrib_occ_text_dt ON ofec_sched_a_1977_1978 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_entity_tp ON ofec_sched_a_1977_1978 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1977_1978_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_image_num_amt ON ofec_sched_a_1977_1978 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_image_num_dt ON ofec_sched_a_1977_1978 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_is_individual_amt ON ofec_sched_a_1977_1978 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_is_individual_dt ON ofec_sched_a_1977_1978 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_pg_date ON ofec_sched_a_1977_1978 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1977_1978_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_rpt_yr ON ofec_sched_a_1977_1978 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_amount ON ofec_sched_a_1977_1978 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_amount_dt ON ofec_sched_a_1977_1978 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_cmte_id_amount ON ofec_sched_a_1977_1978 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_cmte_id_amt ON ofec_sched_a_1977_1978 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_cmte_id_date ON ofec_sched_a_1977_1978 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_cmte_id_dt ON ofec_sched_a_1977_1978 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_date_amt ON ofec_sched_a_1977_1978 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_line_num_amt ON ofec_sched_a_1977_1978 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_sub_id_line_num_dt ON ofec_sched_a_1977_1978 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_two_year_transaction_period_amt ON ofec_sched_a_1977_1978 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1977_1978_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1977_1978_two_year_transaction_period_dt ON ofec_sched_a_1977_1978 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_clean_contbr_id_amt ON ofec_sched_a_1979_1980 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_clean_contbr_id_dt ON ofec_sched_a_1979_1980 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_city_amt ON ofec_sched_a_1979_1980 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_city_dt ON ofec_sched_a_1979_1980 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_st_amt ON ofec_sched_a_1979_1980 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_st_dt ON ofec_sched_a_1979_1980 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_zip_amt ON ofec_sched_a_1979_1980 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contbr_zip_dt ON ofec_sched_a_1979_1980 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_emp_text_amt ON ofec_sched_a_1979_1980 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_emp_text_dt ON ofec_sched_a_1979_1980 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_name_text_amt ON ofec_sched_a_1979_1980 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_name_text_dt ON ofec_sched_a_1979_1980 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_occ_text_amt ON ofec_sched_a_1979_1980 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_contrib_occ_text_dt ON ofec_sched_a_1979_1980 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_entity_tp ON ofec_sched_a_1979_1980 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1979_1980_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_image_num_amt ON ofec_sched_a_1979_1980 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_image_num_dt ON ofec_sched_a_1979_1980 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_is_individual_amt ON ofec_sched_a_1979_1980 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_is_individual_dt ON ofec_sched_a_1979_1980 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_pg_date ON ofec_sched_a_1979_1980 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1979_1980_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_rpt_yr ON ofec_sched_a_1979_1980 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_amount ON ofec_sched_a_1979_1980 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_amount_dt ON ofec_sched_a_1979_1980 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_cmte_id_amount ON ofec_sched_a_1979_1980 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_cmte_id_amt ON ofec_sched_a_1979_1980 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_cmte_id_date ON ofec_sched_a_1979_1980 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_cmte_id_dt ON ofec_sched_a_1979_1980 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_date_amt ON ofec_sched_a_1979_1980 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_line_num_amt ON ofec_sched_a_1979_1980 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_sub_id_line_num_dt ON ofec_sched_a_1979_1980 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_two_year_transaction_period_amt ON ofec_sched_a_1979_1980 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1979_1980_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1979_1980_two_year_transaction_period_dt ON ofec_sched_a_1979_1980 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_clean_contbr_id_amt ON ofec_sched_a_1981_1982 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_clean_contbr_id_dt ON ofec_sched_a_1981_1982 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_city_amt ON ofec_sched_a_1981_1982 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_city_dt ON ofec_sched_a_1981_1982 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_st_amt ON ofec_sched_a_1981_1982 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_st_dt ON ofec_sched_a_1981_1982 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_zip_amt ON ofec_sched_a_1981_1982 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contbr_zip_dt ON ofec_sched_a_1981_1982 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_emp_text_amt ON ofec_sched_a_1981_1982 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_emp_text_dt ON ofec_sched_a_1981_1982 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_name_text_amt ON ofec_sched_a_1981_1982 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_name_text_dt ON ofec_sched_a_1981_1982 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_occ_text_amt ON ofec_sched_a_1981_1982 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_contrib_occ_text_dt ON ofec_sched_a_1981_1982 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_entity_tp ON ofec_sched_a_1981_1982 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1981_1982_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_image_num_amt ON ofec_sched_a_1981_1982 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_image_num_dt ON ofec_sched_a_1981_1982 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_is_individual_amt ON ofec_sched_a_1981_1982 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_is_individual_dt ON ofec_sched_a_1981_1982 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_pg_date ON ofec_sched_a_1981_1982 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1981_1982_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_rpt_yr ON ofec_sched_a_1981_1982 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_amount ON ofec_sched_a_1981_1982 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_amount_dt ON ofec_sched_a_1981_1982 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_cmte_id_amount ON ofec_sched_a_1981_1982 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_cmte_id_amt ON ofec_sched_a_1981_1982 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_cmte_id_date ON ofec_sched_a_1981_1982 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_cmte_id_dt ON ofec_sched_a_1981_1982 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_date_amt ON ofec_sched_a_1981_1982 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_line_num_amt ON ofec_sched_a_1981_1982 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_sub_id_line_num_dt ON ofec_sched_a_1981_1982 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_two_year_transaction_period_amt ON ofec_sched_a_1981_1982 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1981_1982_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1981_1982_two_year_transaction_period_dt ON ofec_sched_a_1981_1982 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_clean_contbr_id_amt ON ofec_sched_a_1983_1984 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_clean_contbr_id_dt ON ofec_sched_a_1983_1984 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_city_amt ON ofec_sched_a_1983_1984 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_city_dt ON ofec_sched_a_1983_1984 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_st_amt ON ofec_sched_a_1983_1984 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_st_dt ON ofec_sched_a_1983_1984 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_zip_amt ON ofec_sched_a_1983_1984 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contbr_zip_dt ON ofec_sched_a_1983_1984 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_emp_text_amt ON ofec_sched_a_1983_1984 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_emp_text_dt ON ofec_sched_a_1983_1984 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_name_text_amt ON ofec_sched_a_1983_1984 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_name_text_dt ON ofec_sched_a_1983_1984 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_occ_text_amt ON ofec_sched_a_1983_1984 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_contrib_occ_text_dt ON ofec_sched_a_1983_1984 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_entity_tp ON ofec_sched_a_1983_1984 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1983_1984_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_image_num_amt ON ofec_sched_a_1983_1984 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_image_num_dt ON ofec_sched_a_1983_1984 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_is_individual_amt ON ofec_sched_a_1983_1984 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_is_individual_dt ON ofec_sched_a_1983_1984 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_pg_date ON ofec_sched_a_1983_1984 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1983_1984_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_rpt_yr ON ofec_sched_a_1983_1984 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_amount ON ofec_sched_a_1983_1984 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_amount_dt ON ofec_sched_a_1983_1984 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_cmte_id_amount ON ofec_sched_a_1983_1984 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_cmte_id_amt ON ofec_sched_a_1983_1984 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_cmte_id_date ON ofec_sched_a_1983_1984 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_cmte_id_dt ON ofec_sched_a_1983_1984 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_date_amt ON ofec_sched_a_1983_1984 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_line_num_amt ON ofec_sched_a_1983_1984 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_sub_id_line_num_dt ON ofec_sched_a_1983_1984 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_two_year_transaction_period_amt ON ofec_sched_a_1983_1984 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1983_1984_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1983_1984_two_year_transaction_period_dt ON ofec_sched_a_1983_1984 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_clean_contbr_id_amt ON ofec_sched_a_1985_1986 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_clean_contbr_id_dt ON ofec_sched_a_1985_1986 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_city_amt ON ofec_sched_a_1985_1986 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_city_dt ON ofec_sched_a_1985_1986 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_st_amt ON ofec_sched_a_1985_1986 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_st_dt ON ofec_sched_a_1985_1986 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_zip_amt ON ofec_sched_a_1985_1986 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contbr_zip_dt ON ofec_sched_a_1985_1986 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_emp_text_amt ON ofec_sched_a_1985_1986 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_emp_text_dt ON ofec_sched_a_1985_1986 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_name_text_amt ON ofec_sched_a_1985_1986 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_name_text_dt ON ofec_sched_a_1985_1986 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_occ_text_amt ON ofec_sched_a_1985_1986 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_contrib_occ_text_dt ON ofec_sched_a_1985_1986 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_entity_tp ON ofec_sched_a_1985_1986 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1985_1986_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_image_num_amt ON ofec_sched_a_1985_1986 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_image_num_dt ON ofec_sched_a_1985_1986 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_is_individual_amt ON ofec_sched_a_1985_1986 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_is_individual_dt ON ofec_sched_a_1985_1986 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_pg_date ON ofec_sched_a_1985_1986 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1985_1986_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_rpt_yr ON ofec_sched_a_1985_1986 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_amount ON ofec_sched_a_1985_1986 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_amount_dt ON ofec_sched_a_1985_1986 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_cmte_id_amount ON ofec_sched_a_1985_1986 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_cmte_id_amt ON ofec_sched_a_1985_1986 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_cmte_id_date ON ofec_sched_a_1985_1986 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_cmte_id_dt ON ofec_sched_a_1985_1986 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_date_amt ON ofec_sched_a_1985_1986 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_line_num_amt ON ofec_sched_a_1985_1986 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_sub_id_line_num_dt ON ofec_sched_a_1985_1986 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_two_year_transaction_period_amt ON ofec_sched_a_1985_1986 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1985_1986_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1985_1986_two_year_transaction_period_dt ON ofec_sched_a_1985_1986 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_clean_contbr_id_amt ON ofec_sched_a_1987_1988 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_clean_contbr_id_dt ON ofec_sched_a_1987_1988 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_city_amt ON ofec_sched_a_1987_1988 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_city_dt ON ofec_sched_a_1987_1988 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_st_amt ON ofec_sched_a_1987_1988 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_st_dt ON ofec_sched_a_1987_1988 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_zip_amt ON ofec_sched_a_1987_1988 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contbr_zip_dt ON ofec_sched_a_1987_1988 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_emp_text_amt ON ofec_sched_a_1987_1988 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_emp_text_dt ON ofec_sched_a_1987_1988 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_name_text_amt ON ofec_sched_a_1987_1988 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_name_text_dt ON ofec_sched_a_1987_1988 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_occ_text_amt ON ofec_sched_a_1987_1988 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_contrib_occ_text_dt ON ofec_sched_a_1987_1988 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_entity_tp ON ofec_sched_a_1987_1988 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1987_1988_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_image_num_amt ON ofec_sched_a_1987_1988 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_image_num_dt ON ofec_sched_a_1987_1988 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_is_individual_amt ON ofec_sched_a_1987_1988 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_is_individual_dt ON ofec_sched_a_1987_1988 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_pg_date ON ofec_sched_a_1987_1988 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1987_1988_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_rpt_yr ON ofec_sched_a_1987_1988 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_amount ON ofec_sched_a_1987_1988 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_amount_dt ON ofec_sched_a_1987_1988 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_cmte_id_amount ON ofec_sched_a_1987_1988 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_cmte_id_amt ON ofec_sched_a_1987_1988 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_cmte_id_date ON ofec_sched_a_1987_1988 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_cmte_id_dt ON ofec_sched_a_1987_1988 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_date_amt ON ofec_sched_a_1987_1988 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_line_num_amt ON ofec_sched_a_1987_1988 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_sub_id_line_num_dt ON ofec_sched_a_1987_1988 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_two_year_transaction_period_amt ON ofec_sched_a_1987_1988 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1987_1988_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1987_1988_two_year_transaction_period_dt ON ofec_sched_a_1987_1988 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_clean_contbr_id_amt ON ofec_sched_a_1989_1990 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_clean_contbr_id_dt ON ofec_sched_a_1989_1990 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_city_amt ON ofec_sched_a_1989_1990 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_city_dt ON ofec_sched_a_1989_1990 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_st_amt ON ofec_sched_a_1989_1990 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_st_dt ON ofec_sched_a_1989_1990 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_zip_amt ON ofec_sched_a_1989_1990 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contbr_zip_dt ON ofec_sched_a_1989_1990 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_emp_text_amt ON ofec_sched_a_1989_1990 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_emp_text_dt ON ofec_sched_a_1989_1990 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_name_text_amt ON ofec_sched_a_1989_1990 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_name_text_dt ON ofec_sched_a_1989_1990 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_occ_text_amt ON ofec_sched_a_1989_1990 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_contrib_occ_text_dt ON ofec_sched_a_1989_1990 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_entity_tp ON ofec_sched_a_1989_1990 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1989_1990_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_image_num_amt ON ofec_sched_a_1989_1990 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_image_num_dt ON ofec_sched_a_1989_1990 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_is_individual_amt ON ofec_sched_a_1989_1990 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_is_individual_dt ON ofec_sched_a_1989_1990 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_pg_date ON ofec_sched_a_1989_1990 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1989_1990_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_rpt_yr ON ofec_sched_a_1989_1990 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_amount ON ofec_sched_a_1989_1990 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_amount_dt ON ofec_sched_a_1989_1990 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_cmte_id_amount ON ofec_sched_a_1989_1990 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_cmte_id_amt ON ofec_sched_a_1989_1990 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_cmte_id_date ON ofec_sched_a_1989_1990 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_cmte_id_dt ON ofec_sched_a_1989_1990 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_date_amt ON ofec_sched_a_1989_1990 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_line_num_amt ON ofec_sched_a_1989_1990 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_sub_id_line_num_dt ON ofec_sched_a_1989_1990 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_two_year_transaction_period_amt ON ofec_sched_a_1989_1990 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1989_1990_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1989_1990_two_year_transaction_period_dt ON ofec_sched_a_1989_1990 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_clean_contbr_id_amt ON ofec_sched_a_1991_1992 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_clean_contbr_id_dt ON ofec_sched_a_1991_1992 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_city_amt ON ofec_sched_a_1991_1992 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_city_dt ON ofec_sched_a_1991_1992 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_st_amt ON ofec_sched_a_1991_1992 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_st_dt ON ofec_sched_a_1991_1992 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_zip_amt ON ofec_sched_a_1991_1992 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contbr_zip_dt ON ofec_sched_a_1991_1992 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_emp_text_amt ON ofec_sched_a_1991_1992 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_emp_text_dt ON ofec_sched_a_1991_1992 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_name_text_amt ON ofec_sched_a_1991_1992 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_name_text_dt ON ofec_sched_a_1991_1992 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_occ_text_amt ON ofec_sched_a_1991_1992 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_contrib_occ_text_dt ON ofec_sched_a_1991_1992 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_entity_tp ON ofec_sched_a_1991_1992 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1991_1992_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_image_num_amt ON ofec_sched_a_1991_1992 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_image_num_dt ON ofec_sched_a_1991_1992 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_is_individual_amt ON ofec_sched_a_1991_1992 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_is_individual_dt ON ofec_sched_a_1991_1992 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_pg_date ON ofec_sched_a_1991_1992 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1991_1992_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_rpt_yr ON ofec_sched_a_1991_1992 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_amount ON ofec_sched_a_1991_1992 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_amount_dt ON ofec_sched_a_1991_1992 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_cmte_id_amount ON ofec_sched_a_1991_1992 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_cmte_id_amt ON ofec_sched_a_1991_1992 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_cmte_id_date ON ofec_sched_a_1991_1992 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_cmte_id_dt ON ofec_sched_a_1991_1992 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_date_amt ON ofec_sched_a_1991_1992 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_line_num_amt ON ofec_sched_a_1991_1992 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_sub_id_line_num_dt ON ofec_sched_a_1991_1992 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_two_year_transaction_period_amt ON ofec_sched_a_1991_1992 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1991_1992_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1991_1992_two_year_transaction_period_dt ON ofec_sched_a_1991_1992 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_clean_contbr_id_amt ON ofec_sched_a_1993_1994 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_clean_contbr_id_dt ON ofec_sched_a_1993_1994 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_city_amt ON ofec_sched_a_1993_1994 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_city_dt ON ofec_sched_a_1993_1994 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_st_amt ON ofec_sched_a_1993_1994 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_st_dt ON ofec_sched_a_1993_1994 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_zip_amt ON ofec_sched_a_1993_1994 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contbr_zip_dt ON ofec_sched_a_1993_1994 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_emp_text_amt ON ofec_sched_a_1993_1994 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_emp_text_dt ON ofec_sched_a_1993_1994 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_name_text_amt ON ofec_sched_a_1993_1994 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_name_text_dt ON ofec_sched_a_1993_1994 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_occ_text_amt ON ofec_sched_a_1993_1994 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_contrib_occ_text_dt ON ofec_sched_a_1993_1994 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_entity_tp ON ofec_sched_a_1993_1994 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1993_1994_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_image_num_amt ON ofec_sched_a_1993_1994 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_image_num_dt ON ofec_sched_a_1993_1994 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_is_individual_amt ON ofec_sched_a_1993_1994 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_is_individual_dt ON ofec_sched_a_1993_1994 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_pg_date ON ofec_sched_a_1993_1994 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1993_1994_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_rpt_yr ON ofec_sched_a_1993_1994 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_amount ON ofec_sched_a_1993_1994 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_amount_dt ON ofec_sched_a_1993_1994 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_cmte_id_amount ON ofec_sched_a_1993_1994 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_cmte_id_amt ON ofec_sched_a_1993_1994 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_cmte_id_date ON ofec_sched_a_1993_1994 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_cmte_id_dt ON ofec_sched_a_1993_1994 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_date_amt ON ofec_sched_a_1993_1994 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_line_num_amt ON ofec_sched_a_1993_1994 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_sub_id_line_num_dt ON ofec_sched_a_1993_1994 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_two_year_transaction_period_amt ON ofec_sched_a_1993_1994 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1993_1994_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1993_1994_two_year_transaction_period_dt ON ofec_sched_a_1993_1994 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_clean_contbr_id_amt ON ofec_sched_a_1995_1996 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_clean_contbr_id_dt ON ofec_sched_a_1995_1996 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_city_amt ON ofec_sched_a_1995_1996 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_city_dt ON ofec_sched_a_1995_1996 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_st_amt ON ofec_sched_a_1995_1996 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_st_dt ON ofec_sched_a_1995_1996 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_zip_amt ON ofec_sched_a_1995_1996 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contbr_zip_dt ON ofec_sched_a_1995_1996 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_emp_text_amt ON ofec_sched_a_1995_1996 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_emp_text_dt ON ofec_sched_a_1995_1996 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_name_text_amt ON ofec_sched_a_1995_1996 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_name_text_dt ON ofec_sched_a_1995_1996 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_occ_text_amt ON ofec_sched_a_1995_1996 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_contrib_occ_text_dt ON ofec_sched_a_1995_1996 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_entity_tp ON ofec_sched_a_1995_1996 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1995_1996_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_image_num_amt ON ofec_sched_a_1995_1996 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_image_num_dt ON ofec_sched_a_1995_1996 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_is_individual_amt ON ofec_sched_a_1995_1996 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_is_individual_dt ON ofec_sched_a_1995_1996 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_pg_date ON ofec_sched_a_1995_1996 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1995_1996_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_rpt_yr ON ofec_sched_a_1995_1996 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_amount ON ofec_sched_a_1995_1996 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_amount_dt ON ofec_sched_a_1995_1996 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_cmte_id_amount ON ofec_sched_a_1995_1996 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_cmte_id_amt ON ofec_sched_a_1995_1996 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_cmte_id_date ON ofec_sched_a_1995_1996 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_cmte_id_dt ON ofec_sched_a_1995_1996 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_date_amt ON ofec_sched_a_1995_1996 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_line_num_amt ON ofec_sched_a_1995_1996 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_sub_id_line_num_dt ON ofec_sched_a_1995_1996 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_two_year_transaction_period_amt ON ofec_sched_a_1995_1996 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1995_1996_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1995_1996_two_year_transaction_period_dt ON ofec_sched_a_1995_1996 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_clean_contbr_id_amt ON ofec_sched_a_1997_1998 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_clean_contbr_id_dt ON ofec_sched_a_1997_1998 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_city_amt ON ofec_sched_a_1997_1998 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_city_dt ON ofec_sched_a_1997_1998 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_st_amt ON ofec_sched_a_1997_1998 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_st_dt ON ofec_sched_a_1997_1998 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_zip_amt ON ofec_sched_a_1997_1998 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contbr_zip_dt ON ofec_sched_a_1997_1998 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_emp_text_amt ON ofec_sched_a_1997_1998 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_emp_text_dt ON ofec_sched_a_1997_1998 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_name_text_amt ON ofec_sched_a_1997_1998 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_name_text_dt ON ofec_sched_a_1997_1998 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_occ_text_amt ON ofec_sched_a_1997_1998 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_contrib_occ_text_dt ON ofec_sched_a_1997_1998 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_entity_tp ON ofec_sched_a_1997_1998 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1997_1998_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_image_num_amt ON ofec_sched_a_1997_1998 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_image_num_dt ON ofec_sched_a_1997_1998 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_is_individual_amt ON ofec_sched_a_1997_1998 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_is_individual_dt ON ofec_sched_a_1997_1998 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_pg_date ON ofec_sched_a_1997_1998 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1997_1998_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_rpt_yr ON ofec_sched_a_1997_1998 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_amount ON ofec_sched_a_1997_1998 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_amount_dt ON ofec_sched_a_1997_1998 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_cmte_id_amount ON ofec_sched_a_1997_1998 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_cmte_id_amt ON ofec_sched_a_1997_1998 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_cmte_id_date ON ofec_sched_a_1997_1998 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_cmte_id_dt ON ofec_sched_a_1997_1998 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_date_amt ON ofec_sched_a_1997_1998 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_line_num_amt ON ofec_sched_a_1997_1998 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_sub_id_line_num_dt ON ofec_sched_a_1997_1998 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_two_year_transaction_period_amt ON ofec_sched_a_1997_1998 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1997_1998_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1997_1998_two_year_transaction_period_dt ON ofec_sched_a_1997_1998 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_clean_contbr_id_amt ON ofec_sched_a_1999_2000 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_clean_contbr_id_dt ON ofec_sched_a_1999_2000 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_city_amt ON ofec_sched_a_1999_2000 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_city_dt ON ofec_sched_a_1999_2000 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_st_amt ON ofec_sched_a_1999_2000 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_st_dt ON ofec_sched_a_1999_2000 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_zip_amt ON ofec_sched_a_1999_2000 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contbr_zip_dt ON ofec_sched_a_1999_2000 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_emp_text_amt ON ofec_sched_a_1999_2000 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_emp_text_dt ON ofec_sched_a_1999_2000 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_name_text_amt ON ofec_sched_a_1999_2000 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_name_text_dt ON ofec_sched_a_1999_2000 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_occ_text_amt ON ofec_sched_a_1999_2000 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_contrib_occ_text_dt ON ofec_sched_a_1999_2000 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_entity_tp ON ofec_sched_a_1999_2000 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_1999_2000_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_image_num_amt ON ofec_sched_a_1999_2000 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_image_num_dt ON ofec_sched_a_1999_2000 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_is_individual_amt ON ofec_sched_a_1999_2000 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_is_individual_dt ON ofec_sched_a_1999_2000 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_pg_date ON ofec_sched_a_1999_2000 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_1999_2000_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_rpt_yr ON ofec_sched_a_1999_2000 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_amount ON ofec_sched_a_1999_2000 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_amount_dt ON ofec_sched_a_1999_2000 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_cmte_id_amount ON ofec_sched_a_1999_2000 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_cmte_id_amt ON ofec_sched_a_1999_2000 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_cmte_id_date ON ofec_sched_a_1999_2000 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_cmte_id_dt ON ofec_sched_a_1999_2000 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_date_amt ON ofec_sched_a_1999_2000 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_line_num_amt ON ofec_sched_a_1999_2000 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_sub_id_line_num_dt ON ofec_sched_a_1999_2000 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_two_year_transaction_period_amt ON ofec_sched_a_1999_2000 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_1999_2000_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_1999_2000_two_year_transaction_period_dt ON ofec_sched_a_1999_2000 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_clean_contbr_id_amt ON ofec_sched_a_2001_2002 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_clean_contbr_id_dt ON ofec_sched_a_2001_2002 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_city_amt ON ofec_sched_a_2001_2002 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_city_dt ON ofec_sched_a_2001_2002 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_st_amt ON ofec_sched_a_2001_2002 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_st_dt ON ofec_sched_a_2001_2002 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_zip_amt ON ofec_sched_a_2001_2002 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contbr_zip_dt ON ofec_sched_a_2001_2002 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_emp_text_amt ON ofec_sched_a_2001_2002 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_emp_text_dt ON ofec_sched_a_2001_2002 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_name_text_amt ON ofec_sched_a_2001_2002 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_name_text_dt ON ofec_sched_a_2001_2002 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_occ_text_amt ON ofec_sched_a_2001_2002 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_contrib_occ_text_dt ON ofec_sched_a_2001_2002 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_entity_tp ON ofec_sched_a_2001_2002 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2001_2002_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_image_num_amt ON ofec_sched_a_2001_2002 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_image_num_dt ON ofec_sched_a_2001_2002 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_is_individual_amt ON ofec_sched_a_2001_2002 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_is_individual_dt ON ofec_sched_a_2001_2002 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_pg_date ON ofec_sched_a_2001_2002 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2001_2002_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_rpt_yr ON ofec_sched_a_2001_2002 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_amount ON ofec_sched_a_2001_2002 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_amount_dt ON ofec_sched_a_2001_2002 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_cmte_id_amount ON ofec_sched_a_2001_2002 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_cmte_id_amt ON ofec_sched_a_2001_2002 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_cmte_id_date ON ofec_sched_a_2001_2002 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_cmte_id_dt ON ofec_sched_a_2001_2002 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_date_amt ON ofec_sched_a_2001_2002 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_line_num_amt ON ofec_sched_a_2001_2002 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_sub_id_line_num_dt ON ofec_sched_a_2001_2002 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_two_year_transaction_period_amt ON ofec_sched_a_2001_2002 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2001_2002_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2001_2002_two_year_transaction_period_dt ON ofec_sched_a_2001_2002 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_clean_contbr_id_amt ON ofec_sched_a_2003_2004 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_clean_contbr_id_dt ON ofec_sched_a_2003_2004 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_city_amt ON ofec_sched_a_2003_2004 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_city_dt ON ofec_sched_a_2003_2004 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_st_amt ON ofec_sched_a_2003_2004 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_st_dt ON ofec_sched_a_2003_2004 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_zip_amt ON ofec_sched_a_2003_2004 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contbr_zip_dt ON ofec_sched_a_2003_2004 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_emp_text_amt ON ofec_sched_a_2003_2004 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_emp_text_dt ON ofec_sched_a_2003_2004 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_name_text_amt ON ofec_sched_a_2003_2004 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_name_text_dt ON ofec_sched_a_2003_2004 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_occ_text_amt ON ofec_sched_a_2003_2004 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_contrib_occ_text_dt ON ofec_sched_a_2003_2004 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_entity_tp ON ofec_sched_a_2003_2004 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2003_2004_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_image_num_amt ON ofec_sched_a_2003_2004 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_image_num_dt ON ofec_sched_a_2003_2004 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_is_individual_amt ON ofec_sched_a_2003_2004 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_is_individual_dt ON ofec_sched_a_2003_2004 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_pg_date ON ofec_sched_a_2003_2004 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2003_2004_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_rpt_yr ON ofec_sched_a_2003_2004 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_amount ON ofec_sched_a_2003_2004 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_amount_dt ON ofec_sched_a_2003_2004 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_cmte_id_amount ON ofec_sched_a_2003_2004 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_cmte_id_amt ON ofec_sched_a_2003_2004 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_cmte_id_date ON ofec_sched_a_2003_2004 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_cmte_id_dt ON ofec_sched_a_2003_2004 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_date_amt ON ofec_sched_a_2003_2004 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_line_num_amt ON ofec_sched_a_2003_2004 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_sub_id_line_num_dt ON ofec_sched_a_2003_2004 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_two_year_transaction_period_amt ON ofec_sched_a_2003_2004 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2003_2004_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2003_2004_two_year_transaction_period_dt ON ofec_sched_a_2003_2004 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_clean_contbr_id_amt ON ofec_sched_a_2005_2006 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_clean_contbr_id_dt ON ofec_sched_a_2005_2006 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_city_amt ON ofec_sched_a_2005_2006 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_city_dt ON ofec_sched_a_2005_2006 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_st_amt ON ofec_sched_a_2005_2006 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_st_dt ON ofec_sched_a_2005_2006 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_zip_amt ON ofec_sched_a_2005_2006 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contbr_zip_dt ON ofec_sched_a_2005_2006 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_emp_text_amt ON ofec_sched_a_2005_2006 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_emp_text_dt ON ofec_sched_a_2005_2006 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_name_text_amt ON ofec_sched_a_2005_2006 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_name_text_dt ON ofec_sched_a_2005_2006 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_occ_text_amt ON ofec_sched_a_2005_2006 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_contrib_occ_text_dt ON ofec_sched_a_2005_2006 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_entity_tp ON ofec_sched_a_2005_2006 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2005_2006_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_image_num_amt ON ofec_sched_a_2005_2006 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_image_num_dt ON ofec_sched_a_2005_2006 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_is_individual_amt ON ofec_sched_a_2005_2006 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_is_individual_dt ON ofec_sched_a_2005_2006 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_pg_date ON ofec_sched_a_2005_2006 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2005_2006_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_rpt_yr ON ofec_sched_a_2005_2006 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_amount ON ofec_sched_a_2005_2006 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_amount_dt ON ofec_sched_a_2005_2006 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_cmte_id_amount ON ofec_sched_a_2005_2006 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_cmte_id_amt ON ofec_sched_a_2005_2006 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_cmte_id_date ON ofec_sched_a_2005_2006 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_cmte_id_dt ON ofec_sched_a_2005_2006 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_date_amt ON ofec_sched_a_2005_2006 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_line_num_amt ON ofec_sched_a_2005_2006 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_sub_id_line_num_dt ON ofec_sched_a_2005_2006 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_two_year_transaction_period_amt ON ofec_sched_a_2005_2006 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2005_2006_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2005_2006_two_year_transaction_period_dt ON ofec_sched_a_2005_2006 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_clean_contbr_id_amt ON ofec_sched_a_2007_2008 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_clean_contbr_id_dt ON ofec_sched_a_2007_2008 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_city_amt ON ofec_sched_a_2007_2008 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_city_dt ON ofec_sched_a_2007_2008 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_st_amt ON ofec_sched_a_2007_2008 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_st_dt ON ofec_sched_a_2007_2008 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_zip_amt ON ofec_sched_a_2007_2008 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contbr_zip_dt ON ofec_sched_a_2007_2008 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_emp_text_amt ON ofec_sched_a_2007_2008 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_emp_text_dt ON ofec_sched_a_2007_2008 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_name_text_amt ON ofec_sched_a_2007_2008 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_name_text_dt ON ofec_sched_a_2007_2008 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_occ_text_amt ON ofec_sched_a_2007_2008 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_contrib_occ_text_dt ON ofec_sched_a_2007_2008 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_entity_tp ON ofec_sched_a_2007_2008 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2007_2008_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_image_num_amt ON ofec_sched_a_2007_2008 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_image_num_dt ON ofec_sched_a_2007_2008 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_is_individual_amt ON ofec_sched_a_2007_2008 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_is_individual_dt ON ofec_sched_a_2007_2008 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_pg_date ON ofec_sched_a_2007_2008 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2007_2008_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_rpt_yr ON ofec_sched_a_2007_2008 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_amount ON ofec_sched_a_2007_2008 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_amount_dt ON ofec_sched_a_2007_2008 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_cmte_id_amount ON ofec_sched_a_2007_2008 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_cmte_id_amt ON ofec_sched_a_2007_2008 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_cmte_id_date ON ofec_sched_a_2007_2008 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_cmte_id_dt ON ofec_sched_a_2007_2008 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_date_amt ON ofec_sched_a_2007_2008 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_line_num_amt ON ofec_sched_a_2007_2008 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_sub_id_line_num_dt ON ofec_sched_a_2007_2008 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_two_year_transaction_period_amt ON ofec_sched_a_2007_2008 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2007_2008_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2007_2008_two_year_transaction_period_dt ON ofec_sched_a_2007_2008 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_clean_contbr_id_amt ON ofec_sched_a_2009_2010 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_clean_contbr_id_dt ON ofec_sched_a_2009_2010 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_city_amt ON ofec_sched_a_2009_2010 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_city_dt ON ofec_sched_a_2009_2010 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_st_amt ON ofec_sched_a_2009_2010 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_st_dt ON ofec_sched_a_2009_2010 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_zip_amt ON ofec_sched_a_2009_2010 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contbr_zip_dt ON ofec_sched_a_2009_2010 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_emp_text_amt ON ofec_sched_a_2009_2010 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_emp_text_dt ON ofec_sched_a_2009_2010 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_name_text_amt ON ofec_sched_a_2009_2010 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_name_text_dt ON ofec_sched_a_2009_2010 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_occ_text_amt ON ofec_sched_a_2009_2010 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_contrib_occ_text_dt ON ofec_sched_a_2009_2010 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_entity_tp ON ofec_sched_a_2009_2010 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2009_2010_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_image_num_amt ON ofec_sched_a_2009_2010 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_image_num_dt ON ofec_sched_a_2009_2010 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_is_individual_amt ON ofec_sched_a_2009_2010 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_is_individual_dt ON ofec_sched_a_2009_2010 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_pg_date ON ofec_sched_a_2009_2010 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2009_2010_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_rpt_yr ON ofec_sched_a_2009_2010 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_amount ON ofec_sched_a_2009_2010 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_amount_dt ON ofec_sched_a_2009_2010 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_cmte_id_amount ON ofec_sched_a_2009_2010 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_cmte_id_amt ON ofec_sched_a_2009_2010 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_cmte_id_date ON ofec_sched_a_2009_2010 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_cmte_id_dt ON ofec_sched_a_2009_2010 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_date_amt ON ofec_sched_a_2009_2010 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_line_num_amt ON ofec_sched_a_2009_2010 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_sub_id_line_num_dt ON ofec_sched_a_2009_2010 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_two_year_transaction_period_amt ON ofec_sched_a_2009_2010 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2009_2010_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2009_2010_two_year_transaction_period_dt ON ofec_sched_a_2009_2010 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_clean_contbr_id_amt ON ofec_sched_a_2011_2012 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_clean_contbr_id_dt ON ofec_sched_a_2011_2012 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_city_amt ON ofec_sched_a_2011_2012 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_city_dt ON ofec_sched_a_2011_2012 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_st_amt ON ofec_sched_a_2011_2012 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_st_dt ON ofec_sched_a_2011_2012 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_zip_amt ON ofec_sched_a_2011_2012 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contbr_zip_dt ON ofec_sched_a_2011_2012 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_emp_text_amt ON ofec_sched_a_2011_2012 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_emp_text_dt ON ofec_sched_a_2011_2012 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_name_text_amt ON ofec_sched_a_2011_2012 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_name_text_dt ON ofec_sched_a_2011_2012 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_occ_text_amt ON ofec_sched_a_2011_2012 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_contrib_occ_text_dt ON ofec_sched_a_2011_2012 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_entity_tp ON ofec_sched_a_2011_2012 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2011_2012_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_image_num_amt ON ofec_sched_a_2011_2012 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_image_num_dt ON ofec_sched_a_2011_2012 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_is_individual_amt ON ofec_sched_a_2011_2012 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_is_individual_dt ON ofec_sched_a_2011_2012 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_pg_date ON ofec_sched_a_2011_2012 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2011_2012_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_rpt_yr ON ofec_sched_a_2011_2012 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_amount ON ofec_sched_a_2011_2012 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_amount_dt ON ofec_sched_a_2011_2012 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_cmte_id_amount ON ofec_sched_a_2011_2012 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_cmte_id_amt ON ofec_sched_a_2011_2012 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_cmte_id_date ON ofec_sched_a_2011_2012 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_cmte_id_dt ON ofec_sched_a_2011_2012 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_date_amt ON ofec_sched_a_2011_2012 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_line_num_amt ON ofec_sched_a_2011_2012 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_sub_id_line_num_dt ON ofec_sched_a_2011_2012 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_two_year_transaction_period_amt ON ofec_sched_a_2011_2012 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2011_2012_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2011_2012_two_year_transaction_period_dt ON ofec_sched_a_2011_2012 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_clean_contbr_id_amt ON ofec_sched_a_2013_2014 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_clean_contbr_id_dt ON ofec_sched_a_2013_2014 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_city_amt ON ofec_sched_a_2013_2014 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_city_dt ON ofec_sched_a_2013_2014 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_st_amt ON ofec_sched_a_2013_2014 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_st_dt ON ofec_sched_a_2013_2014 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_zip_amt ON ofec_sched_a_2013_2014 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contbr_zip_dt ON ofec_sched_a_2013_2014 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_emp_text_amt ON ofec_sched_a_2013_2014 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_emp_text_dt ON ofec_sched_a_2013_2014 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_name_text_amt ON ofec_sched_a_2013_2014 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_name_text_dt ON ofec_sched_a_2013_2014 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_occ_text_amt ON ofec_sched_a_2013_2014 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_contrib_occ_text_dt ON ofec_sched_a_2013_2014 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_entity_tp ON ofec_sched_a_2013_2014 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2013_2014_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_image_num_amt ON ofec_sched_a_2013_2014 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_image_num_dt ON ofec_sched_a_2013_2014 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_is_individual_amt ON ofec_sched_a_2013_2014 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_is_individual_dt ON ofec_sched_a_2013_2014 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_pg_date ON ofec_sched_a_2013_2014 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2013_2014_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_rpt_yr ON ofec_sched_a_2013_2014 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_amount ON ofec_sched_a_2013_2014 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_amount_dt ON ofec_sched_a_2013_2014 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_cmte_id_amount ON ofec_sched_a_2013_2014 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_cmte_id_amt ON ofec_sched_a_2013_2014 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_cmte_id_date ON ofec_sched_a_2013_2014 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_cmte_id_dt ON ofec_sched_a_2013_2014 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_date_amt ON ofec_sched_a_2013_2014 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_line_num_amt ON ofec_sched_a_2013_2014 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_sub_id_line_num_dt ON ofec_sched_a_2013_2014 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_two_year_transaction_period_amt ON ofec_sched_a_2013_2014 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2013_2014_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2013_2014_two_year_transaction_period_dt ON ofec_sched_a_2013_2014 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_clean_contbr_id_amt ON ofec_sched_a_2015_2016 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_clean_contbr_id_dt ON ofec_sched_a_2015_2016 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_city_amt ON ofec_sched_a_2015_2016 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_city_dt ON ofec_sched_a_2015_2016 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_st_amt ON ofec_sched_a_2015_2016 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_st_dt ON ofec_sched_a_2015_2016 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_zip_amt ON ofec_sched_a_2015_2016 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contbr_zip_dt ON ofec_sched_a_2015_2016 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_emp_text_amt ON ofec_sched_a_2015_2016 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_emp_text_dt ON ofec_sched_a_2015_2016 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_name_text_amt ON ofec_sched_a_2015_2016 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_name_text_dt ON ofec_sched_a_2015_2016 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_occ_text_amt ON ofec_sched_a_2015_2016 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_contrib_occ_text_dt ON ofec_sched_a_2015_2016 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_entity_tp ON ofec_sched_a_2015_2016 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2015_2016_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_image_num_amt ON ofec_sched_a_2015_2016 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_image_num_dt ON ofec_sched_a_2015_2016 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_is_individual_amt ON ofec_sched_a_2015_2016 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_is_individual_dt ON ofec_sched_a_2015_2016 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_pg_date ON ofec_sched_a_2015_2016 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2015_2016_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_rpt_yr ON ofec_sched_a_2015_2016 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_amount ON ofec_sched_a_2015_2016 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_amount_dt ON ofec_sched_a_2015_2016 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_cmte_id_amount ON ofec_sched_a_2015_2016 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_cmte_id_amt ON ofec_sched_a_2015_2016 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_cmte_id_date ON ofec_sched_a_2015_2016 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_cmte_id_dt ON ofec_sched_a_2015_2016 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_date_amt ON ofec_sched_a_2015_2016 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_line_num_amt ON ofec_sched_a_2015_2016 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_sub_id_line_num_dt ON ofec_sched_a_2015_2016 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_two_year_transaction_period_amt ON ofec_sched_a_2015_2016 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2015_2016_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2015_2016_two_year_transaction_period_dt ON ofec_sched_a_2015_2016 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_clean_contbr_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_clean_contbr_id_amt ON ofec_sched_a_2017_2018 USING btree (clean_contbr_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_clean_contbr_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_clean_contbr_id_dt ON ofec_sched_a_2017_2018 USING btree (clean_contbr_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_city_amt ON ofec_sched_a_2017_2018 USING btree (contbr_city, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_city_dt ON ofec_sched_a_2017_2018 USING btree (contbr_city, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_st_amt ON ofec_sched_a_2017_2018 USING btree (contbr_st, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_st_dt ON ofec_sched_a_2017_2018 USING btree (contbr_st, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_zip_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_zip_amt ON ofec_sched_a_2017_2018 USING btree (contbr_zip, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contbr_zip_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contbr_zip_dt ON ofec_sched_a_2017_2018 USING btree (contbr_zip, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_emp_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_emp_text_amt ON ofec_sched_a_2017_2018 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_emp_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_emp_text_dt ON ofec_sched_a_2017_2018 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_name_text_amt ON ofec_sched_a_2017_2018 USING gin (contributor_name_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_name_text_dt ON ofec_sched_a_2017_2018 USING gin (contributor_name_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_occ_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_occ_text_amt ON ofec_sched_a_2017_2018 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_contrib_occ_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_contrib_occ_text_dt ON ofec_sched_a_2017_2018 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_entity_tp ON ofec_sched_a_2017_2018 USING btree (entity_tp);


--
-- Name: idx_ofec_sched_a_2017_2018_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_image_num_amt ON ofec_sched_a_2017_2018 USING btree (image_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_image_num_dt ON ofec_sched_a_2017_2018 USING btree (image_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_is_individual_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_is_individual_amt ON ofec_sched_a_2017_2018 USING btree (is_individual, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_is_individual_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_is_individual_dt ON ofec_sched_a_2017_2018 USING btree (is_individual, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_pg_date ON ofec_sched_a_2017_2018 USING btree (pg_date);


--
-- Name: idx_ofec_sched_a_2017_2018_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_rpt_yr ON ofec_sched_a_2017_2018 USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_amount ON ofec_sched_a_2017_2018 USING btree (contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_amount_dt ON ofec_sched_a_2017_2018 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_cmte_id_amount; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_cmte_id_amount ON ofec_sched_a_2017_2018 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_cmte_id_amt ON ofec_sched_a_2017_2018 USING btree (cmte_id, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_cmte_id_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_cmte_id_date ON ofec_sched_a_2017_2018 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_cmte_id_dt ON ofec_sched_a_2017_2018 USING btree (cmte_id, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_date_amt ON ofec_sched_a_2017_2018 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_line_num_amt ON ofec_sched_a_2017_2018 USING btree (line_num, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_sub_id_line_num_dt ON ofec_sched_a_2017_2018 USING btree (line_num, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_two_year_transaction_period_amt ON ofec_sched_a_2017_2018 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);


--
-- Name: idx_ofec_sched_a_2017_2018_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_a_2017_2018_two_year_transaction_period_dt ON ofec_sched_a_2017_2018 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_clean_recipient_cmte_id_amt ON ofec_sched_b_1977_1978 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_clean_recipient_cmte_id_dt ON ofec_sched_b_1977_1978 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_amt ON ofec_sched_b_1977_1978 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_disb_amt_sub_id ON ofec_sched_b_1977_1978 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_disb_dt_sub_id ON ofec_sched_b_1977_1978 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_dt ON ofec_sched_b_1977_1978 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_disb_desc_text_amt ON ofec_sched_b_1977_1978 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_disb_desc_text_dt ON ofec_sched_b_1977_1978 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_image_num_amt ON ofec_sched_b_1977_1978 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_image_num_dt ON ofec_sched_b_1977_1978 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_pg_date ON ofec_sched_b_1977_1978 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1977_1978_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recip_name_text_amt ON ofec_sched_b_1977_1978 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recip_name_text_dt ON ofec_sched_b_1977_1978 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_city_amt ON ofec_sched_b_1977_1978 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_city_dt ON ofec_sched_b_1977_1978 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_st_amt ON ofec_sched_b_1977_1978 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_st_dt ON ofec_sched_b_1977_1978 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_rpt_yr_amt ON ofec_sched_b_1977_1978 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_rpt_yr_dt ON ofec_sched_b_1977_1978 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_amount_dt ON ofec_sched_b_1977_1978 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_date_amt ON ofec_sched_b_1977_1978 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_line_num_amt ON ofec_sched_b_1977_1978 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_line_num_dt ON ofec_sched_b_1977_1978 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_two_year_transaction_period_amt ON ofec_sched_b_1977_1978 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1977_1978_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1977_1978_two_year_transaction_period_dt ON ofec_sched_b_1977_1978 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_clean_recipient_cmte_id_amt ON ofec_sched_b_1979_1980 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_clean_recipient_cmte_id_dt ON ofec_sched_b_1979_1980 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_amt ON ofec_sched_b_1979_1980 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_disb_amt_sub_id ON ofec_sched_b_1979_1980 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_disb_dt_sub_id ON ofec_sched_b_1979_1980 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_dt ON ofec_sched_b_1979_1980 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_disb_desc_text_amt ON ofec_sched_b_1979_1980 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_disb_desc_text_dt ON ofec_sched_b_1979_1980 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_image_num_amt ON ofec_sched_b_1979_1980 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_image_num_dt ON ofec_sched_b_1979_1980 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_pg_date ON ofec_sched_b_1979_1980 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1979_1980_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recip_name_text_amt ON ofec_sched_b_1979_1980 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recip_name_text_dt ON ofec_sched_b_1979_1980 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_city_amt ON ofec_sched_b_1979_1980 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_city_dt ON ofec_sched_b_1979_1980 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_st_amt ON ofec_sched_b_1979_1980 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_st_dt ON ofec_sched_b_1979_1980 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_rpt_yr_amt ON ofec_sched_b_1979_1980 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_rpt_yr_dt ON ofec_sched_b_1979_1980 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_amount_dt ON ofec_sched_b_1979_1980 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_date_amt ON ofec_sched_b_1979_1980 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_line_num_amt ON ofec_sched_b_1979_1980 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_line_num_dt ON ofec_sched_b_1979_1980 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_two_year_transaction_period_amt ON ofec_sched_b_1979_1980 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1979_1980_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1979_1980_two_year_transaction_period_dt ON ofec_sched_b_1979_1980 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_clean_recipient_cmte_id_amt ON ofec_sched_b_1981_1982 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_clean_recipient_cmte_id_dt ON ofec_sched_b_1981_1982 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_amt ON ofec_sched_b_1981_1982 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_disb_amt_sub_id ON ofec_sched_b_1981_1982 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_disb_dt_sub_id ON ofec_sched_b_1981_1982 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_dt ON ofec_sched_b_1981_1982 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_disb_desc_text_amt ON ofec_sched_b_1981_1982 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_disb_desc_text_dt ON ofec_sched_b_1981_1982 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_image_num_amt ON ofec_sched_b_1981_1982 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_image_num_dt ON ofec_sched_b_1981_1982 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_pg_date ON ofec_sched_b_1981_1982 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1981_1982_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recip_name_text_amt ON ofec_sched_b_1981_1982 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recip_name_text_dt ON ofec_sched_b_1981_1982 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_city_amt ON ofec_sched_b_1981_1982 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_city_dt ON ofec_sched_b_1981_1982 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_st_amt ON ofec_sched_b_1981_1982 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_st_dt ON ofec_sched_b_1981_1982 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_rpt_yr_amt ON ofec_sched_b_1981_1982 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_rpt_yr_dt ON ofec_sched_b_1981_1982 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_amount_dt ON ofec_sched_b_1981_1982 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_date_amt ON ofec_sched_b_1981_1982 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_line_num_amt ON ofec_sched_b_1981_1982 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_line_num_dt ON ofec_sched_b_1981_1982 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_two_year_transaction_period_amt ON ofec_sched_b_1981_1982 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1981_1982_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1981_1982_two_year_transaction_period_dt ON ofec_sched_b_1981_1982 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_clean_recipient_cmte_id_amt ON ofec_sched_b_1983_1984 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_clean_recipient_cmte_id_dt ON ofec_sched_b_1983_1984 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_amt ON ofec_sched_b_1983_1984 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_disb_amt_sub_id ON ofec_sched_b_1983_1984 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_disb_dt_sub_id ON ofec_sched_b_1983_1984 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_dt ON ofec_sched_b_1983_1984 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_disb_desc_text_amt ON ofec_sched_b_1983_1984 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_disb_desc_text_dt ON ofec_sched_b_1983_1984 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_image_num_amt ON ofec_sched_b_1983_1984 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_image_num_dt ON ofec_sched_b_1983_1984 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_pg_date ON ofec_sched_b_1983_1984 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1983_1984_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recip_name_text_amt ON ofec_sched_b_1983_1984 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recip_name_text_dt ON ofec_sched_b_1983_1984 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_city_amt ON ofec_sched_b_1983_1984 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_city_dt ON ofec_sched_b_1983_1984 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_st_amt ON ofec_sched_b_1983_1984 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_st_dt ON ofec_sched_b_1983_1984 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_rpt_yr_amt ON ofec_sched_b_1983_1984 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_rpt_yr_dt ON ofec_sched_b_1983_1984 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_amount_dt ON ofec_sched_b_1983_1984 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_date_amt ON ofec_sched_b_1983_1984 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_line_num_amt ON ofec_sched_b_1983_1984 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_line_num_dt ON ofec_sched_b_1983_1984 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_two_year_transaction_period_amt ON ofec_sched_b_1983_1984 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1983_1984_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1983_1984_two_year_transaction_period_dt ON ofec_sched_b_1983_1984 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_clean_recipient_cmte_id_amt ON ofec_sched_b_1985_1986 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_clean_recipient_cmte_id_dt ON ofec_sched_b_1985_1986 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_amt ON ofec_sched_b_1985_1986 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_disb_amt_sub_id ON ofec_sched_b_1985_1986 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_disb_dt_sub_id ON ofec_sched_b_1985_1986 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_dt ON ofec_sched_b_1985_1986 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_disb_desc_text_amt ON ofec_sched_b_1985_1986 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_disb_desc_text_dt ON ofec_sched_b_1985_1986 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_image_num_amt ON ofec_sched_b_1985_1986 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_image_num_dt ON ofec_sched_b_1985_1986 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_pg_date ON ofec_sched_b_1985_1986 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1985_1986_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recip_name_text_amt ON ofec_sched_b_1985_1986 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recip_name_text_dt ON ofec_sched_b_1985_1986 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_city_amt ON ofec_sched_b_1985_1986 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_city_dt ON ofec_sched_b_1985_1986 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_st_amt ON ofec_sched_b_1985_1986 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_st_dt ON ofec_sched_b_1985_1986 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_rpt_yr_amt ON ofec_sched_b_1985_1986 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_rpt_yr_dt ON ofec_sched_b_1985_1986 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_amount_dt ON ofec_sched_b_1985_1986 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_date_amt ON ofec_sched_b_1985_1986 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_line_num_amt ON ofec_sched_b_1985_1986 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_line_num_dt ON ofec_sched_b_1985_1986 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_two_year_transaction_period_amt ON ofec_sched_b_1985_1986 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1985_1986_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1985_1986_two_year_transaction_period_dt ON ofec_sched_b_1985_1986 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_clean_recipient_cmte_id_amt ON ofec_sched_b_1987_1988 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_clean_recipient_cmte_id_dt ON ofec_sched_b_1987_1988 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_amt ON ofec_sched_b_1987_1988 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_disb_amt_sub_id ON ofec_sched_b_1987_1988 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_disb_dt_sub_id ON ofec_sched_b_1987_1988 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_dt ON ofec_sched_b_1987_1988 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_disb_desc_text_amt ON ofec_sched_b_1987_1988 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_disb_desc_text_dt ON ofec_sched_b_1987_1988 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_image_num_amt ON ofec_sched_b_1987_1988 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_image_num_dt ON ofec_sched_b_1987_1988 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_pg_date ON ofec_sched_b_1987_1988 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1987_1988_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recip_name_text_amt ON ofec_sched_b_1987_1988 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recip_name_text_dt ON ofec_sched_b_1987_1988 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_city_amt ON ofec_sched_b_1987_1988 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_city_dt ON ofec_sched_b_1987_1988 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_st_amt ON ofec_sched_b_1987_1988 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_st_dt ON ofec_sched_b_1987_1988 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_rpt_yr_amt ON ofec_sched_b_1987_1988 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_rpt_yr_dt ON ofec_sched_b_1987_1988 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_amount_dt ON ofec_sched_b_1987_1988 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_date_amt ON ofec_sched_b_1987_1988 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_line_num_amt ON ofec_sched_b_1987_1988 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_line_num_dt ON ofec_sched_b_1987_1988 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_two_year_transaction_period_amt ON ofec_sched_b_1987_1988 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1987_1988_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1987_1988_two_year_transaction_period_dt ON ofec_sched_b_1987_1988 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_clean_recipient_cmte_id_amt ON ofec_sched_b_1989_1990 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_clean_recipient_cmte_id_dt ON ofec_sched_b_1989_1990 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_amt ON ofec_sched_b_1989_1990 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_disb_amt_sub_id ON ofec_sched_b_1989_1990 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_disb_dt_sub_id ON ofec_sched_b_1989_1990 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_dt ON ofec_sched_b_1989_1990 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_disb_desc_text_amt ON ofec_sched_b_1989_1990 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_disb_desc_text_dt ON ofec_sched_b_1989_1990 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_image_num_amt ON ofec_sched_b_1989_1990 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_image_num_dt ON ofec_sched_b_1989_1990 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_pg_date ON ofec_sched_b_1989_1990 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1989_1990_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recip_name_text_amt ON ofec_sched_b_1989_1990 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recip_name_text_dt ON ofec_sched_b_1989_1990 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_city_amt ON ofec_sched_b_1989_1990 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_city_dt ON ofec_sched_b_1989_1990 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_st_amt ON ofec_sched_b_1989_1990 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_st_dt ON ofec_sched_b_1989_1990 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_rpt_yr_amt ON ofec_sched_b_1989_1990 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_rpt_yr_dt ON ofec_sched_b_1989_1990 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_amount_dt ON ofec_sched_b_1989_1990 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_date_amt ON ofec_sched_b_1989_1990 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_line_num_amt ON ofec_sched_b_1989_1990 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_line_num_dt ON ofec_sched_b_1989_1990 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_two_year_transaction_period_amt ON ofec_sched_b_1989_1990 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1989_1990_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1989_1990_two_year_transaction_period_dt ON ofec_sched_b_1989_1990 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_clean_recipient_cmte_id_amt ON ofec_sched_b_1991_1992 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_clean_recipient_cmte_id_dt ON ofec_sched_b_1991_1992 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_amt ON ofec_sched_b_1991_1992 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_disb_amt_sub_id ON ofec_sched_b_1991_1992 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_disb_dt_sub_id ON ofec_sched_b_1991_1992 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_dt ON ofec_sched_b_1991_1992 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_disb_desc_text_amt ON ofec_sched_b_1991_1992 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_disb_desc_text_dt ON ofec_sched_b_1991_1992 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_image_num_amt ON ofec_sched_b_1991_1992 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_image_num_dt ON ofec_sched_b_1991_1992 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_pg_date ON ofec_sched_b_1991_1992 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1991_1992_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recip_name_text_amt ON ofec_sched_b_1991_1992 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recip_name_text_dt ON ofec_sched_b_1991_1992 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_city_amt ON ofec_sched_b_1991_1992 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_city_dt ON ofec_sched_b_1991_1992 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_st_amt ON ofec_sched_b_1991_1992 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_st_dt ON ofec_sched_b_1991_1992 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_rpt_yr_amt ON ofec_sched_b_1991_1992 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_rpt_yr_dt ON ofec_sched_b_1991_1992 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_amount_dt ON ofec_sched_b_1991_1992 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_date_amt ON ofec_sched_b_1991_1992 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_line_num_amt ON ofec_sched_b_1991_1992 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_line_num_dt ON ofec_sched_b_1991_1992 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_two_year_transaction_period_amt ON ofec_sched_b_1991_1992 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1991_1992_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1991_1992_two_year_transaction_period_dt ON ofec_sched_b_1991_1992 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_clean_recipient_cmte_id_amt ON ofec_sched_b_1993_1994 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_clean_recipient_cmte_id_dt ON ofec_sched_b_1993_1994 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_amt ON ofec_sched_b_1993_1994 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_disb_amt_sub_id ON ofec_sched_b_1993_1994 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_disb_dt_sub_id ON ofec_sched_b_1993_1994 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_dt ON ofec_sched_b_1993_1994 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_disb_desc_text_amt ON ofec_sched_b_1993_1994 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_disb_desc_text_dt ON ofec_sched_b_1993_1994 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_image_num_amt ON ofec_sched_b_1993_1994 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_image_num_dt ON ofec_sched_b_1993_1994 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_pg_date ON ofec_sched_b_1993_1994 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1993_1994_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recip_name_text_amt ON ofec_sched_b_1993_1994 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recip_name_text_dt ON ofec_sched_b_1993_1994 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_city_amt ON ofec_sched_b_1993_1994 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_city_dt ON ofec_sched_b_1993_1994 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_st_amt ON ofec_sched_b_1993_1994 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_st_dt ON ofec_sched_b_1993_1994 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_rpt_yr_amt ON ofec_sched_b_1993_1994 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_rpt_yr_dt ON ofec_sched_b_1993_1994 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_amount_dt ON ofec_sched_b_1993_1994 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_date_amt ON ofec_sched_b_1993_1994 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_line_num_amt ON ofec_sched_b_1993_1994 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_line_num_dt ON ofec_sched_b_1993_1994 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_two_year_transaction_period_amt ON ofec_sched_b_1993_1994 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1993_1994_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1993_1994_two_year_transaction_period_dt ON ofec_sched_b_1993_1994 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_clean_recipient_cmte_id_amt ON ofec_sched_b_1995_1996 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_clean_recipient_cmte_id_dt ON ofec_sched_b_1995_1996 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_amt ON ofec_sched_b_1995_1996 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_disb_amt_sub_id ON ofec_sched_b_1995_1996 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_disb_dt_sub_id ON ofec_sched_b_1995_1996 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_dt ON ofec_sched_b_1995_1996 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_disb_desc_text_amt ON ofec_sched_b_1995_1996 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_disb_desc_text_dt ON ofec_sched_b_1995_1996 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_image_num_amt ON ofec_sched_b_1995_1996 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_image_num_dt ON ofec_sched_b_1995_1996 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_pg_date ON ofec_sched_b_1995_1996 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1995_1996_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recip_name_text_amt ON ofec_sched_b_1995_1996 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recip_name_text_dt ON ofec_sched_b_1995_1996 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_city_amt ON ofec_sched_b_1995_1996 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_city_dt ON ofec_sched_b_1995_1996 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_st_amt ON ofec_sched_b_1995_1996 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_st_dt ON ofec_sched_b_1995_1996 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_rpt_yr_amt ON ofec_sched_b_1995_1996 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_rpt_yr_dt ON ofec_sched_b_1995_1996 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_amount_dt ON ofec_sched_b_1995_1996 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_date_amt ON ofec_sched_b_1995_1996 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_line_num_amt ON ofec_sched_b_1995_1996 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_line_num_dt ON ofec_sched_b_1995_1996 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_two_year_transaction_period_amt ON ofec_sched_b_1995_1996 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1995_1996_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1995_1996_two_year_transaction_period_dt ON ofec_sched_b_1995_1996 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_clean_recipient_cmte_id_amt ON ofec_sched_b_1997_1998 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_clean_recipient_cmte_id_dt ON ofec_sched_b_1997_1998 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_amt ON ofec_sched_b_1997_1998 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_disb_amt_sub_id ON ofec_sched_b_1997_1998 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_disb_dt_sub_id ON ofec_sched_b_1997_1998 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_dt ON ofec_sched_b_1997_1998 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_disb_desc_text_amt ON ofec_sched_b_1997_1998 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_disb_desc_text_dt ON ofec_sched_b_1997_1998 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_image_num_amt ON ofec_sched_b_1997_1998 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_image_num_dt ON ofec_sched_b_1997_1998 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_pg_date ON ofec_sched_b_1997_1998 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1997_1998_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recip_name_text_amt ON ofec_sched_b_1997_1998 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recip_name_text_dt ON ofec_sched_b_1997_1998 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_city_amt ON ofec_sched_b_1997_1998 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_city_dt ON ofec_sched_b_1997_1998 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_st_amt ON ofec_sched_b_1997_1998 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_st_dt ON ofec_sched_b_1997_1998 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_rpt_yr_amt ON ofec_sched_b_1997_1998 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_rpt_yr_dt ON ofec_sched_b_1997_1998 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_amount_dt ON ofec_sched_b_1997_1998 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_date_amt ON ofec_sched_b_1997_1998 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_line_num_amt ON ofec_sched_b_1997_1998 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_line_num_dt ON ofec_sched_b_1997_1998 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_two_year_transaction_period_amt ON ofec_sched_b_1997_1998 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1997_1998_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1997_1998_two_year_transaction_period_dt ON ofec_sched_b_1997_1998 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_clean_recipient_cmte_id_amt ON ofec_sched_b_1999_2000 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_clean_recipient_cmte_id_dt ON ofec_sched_b_1999_2000 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_amt ON ofec_sched_b_1999_2000 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_disb_amt_sub_id ON ofec_sched_b_1999_2000 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_disb_dt_sub_id ON ofec_sched_b_1999_2000 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_dt ON ofec_sched_b_1999_2000 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_disb_desc_text_amt ON ofec_sched_b_1999_2000 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_disb_desc_text_dt ON ofec_sched_b_1999_2000 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_image_num_amt ON ofec_sched_b_1999_2000 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_image_num_dt ON ofec_sched_b_1999_2000 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_pg_date ON ofec_sched_b_1999_2000 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_1999_2000_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recip_name_text_amt ON ofec_sched_b_1999_2000 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recip_name_text_dt ON ofec_sched_b_1999_2000 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_city_amt ON ofec_sched_b_1999_2000 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_city_dt ON ofec_sched_b_1999_2000 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_st_amt ON ofec_sched_b_1999_2000 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_st_dt ON ofec_sched_b_1999_2000 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_rpt_yr_amt ON ofec_sched_b_1999_2000 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_rpt_yr_dt ON ofec_sched_b_1999_2000 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_amount_dt ON ofec_sched_b_1999_2000 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_date_amt ON ofec_sched_b_1999_2000 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_line_num_amt ON ofec_sched_b_1999_2000 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_line_num_dt ON ofec_sched_b_1999_2000 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_two_year_transaction_period_amt ON ofec_sched_b_1999_2000 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_1999_2000_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_1999_2000_two_year_transaction_period_dt ON ofec_sched_b_1999_2000 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_clean_recipient_cmte_id_amt ON ofec_sched_b_2001_2002 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_clean_recipient_cmte_id_dt ON ofec_sched_b_2001_2002 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_amt ON ofec_sched_b_2001_2002 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_disb_amt_sub_id ON ofec_sched_b_2001_2002 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_disb_dt_sub_id ON ofec_sched_b_2001_2002 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_dt ON ofec_sched_b_2001_2002 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_disb_desc_text_amt ON ofec_sched_b_2001_2002 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_disb_desc_text_dt ON ofec_sched_b_2001_2002 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_image_num_amt ON ofec_sched_b_2001_2002 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_image_num_dt ON ofec_sched_b_2001_2002 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_pg_date ON ofec_sched_b_2001_2002 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2001_2002_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recip_name_text_amt ON ofec_sched_b_2001_2002 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recip_name_text_dt ON ofec_sched_b_2001_2002 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_city_amt ON ofec_sched_b_2001_2002 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_city_dt ON ofec_sched_b_2001_2002 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_st_amt ON ofec_sched_b_2001_2002 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_st_dt ON ofec_sched_b_2001_2002 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_rpt_yr_amt ON ofec_sched_b_2001_2002 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_rpt_yr_dt ON ofec_sched_b_2001_2002 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_amount_dt ON ofec_sched_b_2001_2002 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_date_amt ON ofec_sched_b_2001_2002 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_line_num_amt ON ofec_sched_b_2001_2002 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_line_num_dt ON ofec_sched_b_2001_2002 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_two_year_transaction_period_amt ON ofec_sched_b_2001_2002 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2001_2002_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2001_2002_two_year_transaction_period_dt ON ofec_sched_b_2001_2002 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_clean_recipient_cmte_id_amt ON ofec_sched_b_2003_2004 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_clean_recipient_cmte_id_dt ON ofec_sched_b_2003_2004 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_amt ON ofec_sched_b_2003_2004 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_disb_amt_sub_id ON ofec_sched_b_2003_2004 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_disb_dt_sub_id ON ofec_sched_b_2003_2004 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_dt ON ofec_sched_b_2003_2004 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_disb_desc_text_amt ON ofec_sched_b_2003_2004 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_disb_desc_text_dt ON ofec_sched_b_2003_2004 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_image_num_amt ON ofec_sched_b_2003_2004 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_image_num_dt ON ofec_sched_b_2003_2004 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_pg_date ON ofec_sched_b_2003_2004 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2003_2004_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recip_name_text_amt ON ofec_sched_b_2003_2004 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recip_name_text_dt ON ofec_sched_b_2003_2004 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_city_amt ON ofec_sched_b_2003_2004 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_city_dt ON ofec_sched_b_2003_2004 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_st_amt ON ofec_sched_b_2003_2004 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_st_dt ON ofec_sched_b_2003_2004 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_rpt_yr_amt ON ofec_sched_b_2003_2004 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_rpt_yr_dt ON ofec_sched_b_2003_2004 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_amount_dt ON ofec_sched_b_2003_2004 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_date_amt ON ofec_sched_b_2003_2004 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_line_num_amt ON ofec_sched_b_2003_2004 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_line_num_dt ON ofec_sched_b_2003_2004 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_two_year_transaction_period_amt ON ofec_sched_b_2003_2004 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2003_2004_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2003_2004_two_year_transaction_period_dt ON ofec_sched_b_2003_2004 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_clean_recipient_cmte_id_amt ON ofec_sched_b_2005_2006 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_clean_recipient_cmte_id_dt ON ofec_sched_b_2005_2006 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_amt ON ofec_sched_b_2005_2006 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_disb_amt_sub_id ON ofec_sched_b_2005_2006 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_disb_dt_sub_id ON ofec_sched_b_2005_2006 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_dt ON ofec_sched_b_2005_2006 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_disb_desc_text_amt ON ofec_sched_b_2005_2006 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_disb_desc_text_dt ON ofec_sched_b_2005_2006 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_image_num_amt ON ofec_sched_b_2005_2006 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_image_num_dt ON ofec_sched_b_2005_2006 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_pg_date ON ofec_sched_b_2005_2006 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2005_2006_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recip_name_text_amt ON ofec_sched_b_2005_2006 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recip_name_text_dt ON ofec_sched_b_2005_2006 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_city_amt ON ofec_sched_b_2005_2006 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_city_dt ON ofec_sched_b_2005_2006 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_st_amt ON ofec_sched_b_2005_2006 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_st_dt ON ofec_sched_b_2005_2006 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_rpt_yr_amt ON ofec_sched_b_2005_2006 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_rpt_yr_dt ON ofec_sched_b_2005_2006 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_amount_dt ON ofec_sched_b_2005_2006 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_date_amt ON ofec_sched_b_2005_2006 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_line_num_amt ON ofec_sched_b_2005_2006 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_line_num_dt ON ofec_sched_b_2005_2006 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_two_year_transaction_period_amt ON ofec_sched_b_2005_2006 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2005_2006_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2005_2006_two_year_transaction_period_dt ON ofec_sched_b_2005_2006 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_clean_recipient_cmte_id_amt ON ofec_sched_b_2007_2008 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_clean_recipient_cmte_id_dt ON ofec_sched_b_2007_2008 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_amt ON ofec_sched_b_2007_2008 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_disb_amt_sub_id ON ofec_sched_b_2007_2008 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_disb_dt_sub_id ON ofec_sched_b_2007_2008 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_dt ON ofec_sched_b_2007_2008 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_disb_desc_text_amt ON ofec_sched_b_2007_2008 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_disb_desc_text_dt ON ofec_sched_b_2007_2008 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_image_num_amt ON ofec_sched_b_2007_2008 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_image_num_dt ON ofec_sched_b_2007_2008 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_pg_date ON ofec_sched_b_2007_2008 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2007_2008_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recip_name_text_amt ON ofec_sched_b_2007_2008 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recip_name_text_dt ON ofec_sched_b_2007_2008 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_city_amt ON ofec_sched_b_2007_2008 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_city_dt ON ofec_sched_b_2007_2008 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_st_amt ON ofec_sched_b_2007_2008 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_st_dt ON ofec_sched_b_2007_2008 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_rpt_yr_amt ON ofec_sched_b_2007_2008 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_rpt_yr_dt ON ofec_sched_b_2007_2008 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_amount_dt ON ofec_sched_b_2007_2008 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_date_amt ON ofec_sched_b_2007_2008 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_line_num_amt ON ofec_sched_b_2007_2008 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_line_num_dt ON ofec_sched_b_2007_2008 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_two_year_transaction_period_amt ON ofec_sched_b_2007_2008 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2007_2008_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2007_2008_two_year_transaction_period_dt ON ofec_sched_b_2007_2008 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_clean_recipient_cmte_id_amt ON ofec_sched_b_2009_2010 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_clean_recipient_cmte_id_dt ON ofec_sched_b_2009_2010 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_amt ON ofec_sched_b_2009_2010 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_disb_amt_sub_id ON ofec_sched_b_2009_2010 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_disb_dt_sub_id ON ofec_sched_b_2009_2010 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_dt ON ofec_sched_b_2009_2010 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_disb_desc_text_amt ON ofec_sched_b_2009_2010 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_disb_desc_text_dt ON ofec_sched_b_2009_2010 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_image_num_amt ON ofec_sched_b_2009_2010 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_image_num_dt ON ofec_sched_b_2009_2010 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_pg_date ON ofec_sched_b_2009_2010 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2009_2010_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recip_name_text_amt ON ofec_sched_b_2009_2010 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recip_name_text_dt ON ofec_sched_b_2009_2010 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_city_amt ON ofec_sched_b_2009_2010 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_city_dt ON ofec_sched_b_2009_2010 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_st_amt ON ofec_sched_b_2009_2010 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_st_dt ON ofec_sched_b_2009_2010 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_rpt_yr_amt ON ofec_sched_b_2009_2010 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_rpt_yr_dt ON ofec_sched_b_2009_2010 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_amount_dt ON ofec_sched_b_2009_2010 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_date_amt ON ofec_sched_b_2009_2010 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_line_num_amt ON ofec_sched_b_2009_2010 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_line_num_dt ON ofec_sched_b_2009_2010 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_two_year_transaction_period_amt ON ofec_sched_b_2009_2010 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2009_2010_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2009_2010_two_year_transaction_period_dt ON ofec_sched_b_2009_2010 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_clean_recipient_cmte_id_amt ON ofec_sched_b_2011_2012 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_clean_recipient_cmte_id_dt ON ofec_sched_b_2011_2012 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_amt ON ofec_sched_b_2011_2012 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_disb_amt_sub_id ON ofec_sched_b_2011_2012 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_disb_dt_sub_id ON ofec_sched_b_2011_2012 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_dt ON ofec_sched_b_2011_2012 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_disb_desc_text_amt ON ofec_sched_b_2011_2012 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_disb_desc_text_dt ON ofec_sched_b_2011_2012 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_image_num_amt ON ofec_sched_b_2011_2012 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_image_num_dt ON ofec_sched_b_2011_2012 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_pg_date ON ofec_sched_b_2011_2012 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2011_2012_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recip_name_text_amt ON ofec_sched_b_2011_2012 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recip_name_text_dt ON ofec_sched_b_2011_2012 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_city_amt ON ofec_sched_b_2011_2012 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_city_dt ON ofec_sched_b_2011_2012 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_st_amt ON ofec_sched_b_2011_2012 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_st_dt ON ofec_sched_b_2011_2012 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_rpt_yr_amt ON ofec_sched_b_2011_2012 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_rpt_yr_dt ON ofec_sched_b_2011_2012 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_amount_dt ON ofec_sched_b_2011_2012 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_date_amt ON ofec_sched_b_2011_2012 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_line_num_amt ON ofec_sched_b_2011_2012 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_line_num_dt ON ofec_sched_b_2011_2012 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_two_year_transaction_period_amt ON ofec_sched_b_2011_2012 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2011_2012_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2011_2012_two_year_transaction_period_dt ON ofec_sched_b_2011_2012 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_clean_recipient_cmte_id_amt ON ofec_sched_b_2013_2014 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_clean_recipient_cmte_id_dt ON ofec_sched_b_2013_2014 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_amt ON ofec_sched_b_2013_2014 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_disb_amt_sub_id ON ofec_sched_b_2013_2014 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_disb_dt_sub_id ON ofec_sched_b_2013_2014 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_dt ON ofec_sched_b_2013_2014 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_disb_desc_text_amt ON ofec_sched_b_2013_2014 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_disb_desc_text_dt ON ofec_sched_b_2013_2014 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_image_num_amt ON ofec_sched_b_2013_2014 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_image_num_dt ON ofec_sched_b_2013_2014 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_pg_date ON ofec_sched_b_2013_2014 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2013_2014_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recip_name_text_amt ON ofec_sched_b_2013_2014 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recip_name_text_dt ON ofec_sched_b_2013_2014 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_city_amt ON ofec_sched_b_2013_2014 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_city_dt ON ofec_sched_b_2013_2014 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_st_amt ON ofec_sched_b_2013_2014 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_st_dt ON ofec_sched_b_2013_2014 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_rpt_yr_amt ON ofec_sched_b_2013_2014 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_rpt_yr_dt ON ofec_sched_b_2013_2014 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_amount_dt ON ofec_sched_b_2013_2014 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_date_amt ON ofec_sched_b_2013_2014 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_line_num_amt ON ofec_sched_b_2013_2014 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_line_num_dt ON ofec_sched_b_2013_2014 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_two_year_transaction_period_amt ON ofec_sched_b_2013_2014 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2013_2014_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2013_2014_two_year_transaction_period_dt ON ofec_sched_b_2013_2014 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_clean_recipient_cmte_id_amt ON ofec_sched_b_2015_2016 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_clean_recipient_cmte_id_dt ON ofec_sched_b_2015_2016 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_amt ON ofec_sched_b_2015_2016 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_disb_amt_sub_id ON ofec_sched_b_2015_2016 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_disb_dt_sub_id ON ofec_sched_b_2015_2016 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_dt ON ofec_sched_b_2015_2016 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_disb_desc_text_amt ON ofec_sched_b_2015_2016 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_disb_desc_text_dt ON ofec_sched_b_2015_2016 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_image_num_amt ON ofec_sched_b_2015_2016 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_image_num_dt ON ofec_sched_b_2015_2016 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_pg_date ON ofec_sched_b_2015_2016 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2015_2016_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recip_name_text_amt ON ofec_sched_b_2015_2016 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recip_name_text_dt ON ofec_sched_b_2015_2016 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_city_amt ON ofec_sched_b_2015_2016 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_city_dt ON ofec_sched_b_2015_2016 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_st_amt ON ofec_sched_b_2015_2016 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_st_dt ON ofec_sched_b_2015_2016 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_rpt_yr_amt ON ofec_sched_b_2015_2016 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_rpt_yr_dt ON ofec_sched_b_2015_2016 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_amount_dt ON ofec_sched_b_2015_2016 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_date_amt ON ofec_sched_b_2015_2016 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_line_num_amt ON ofec_sched_b_2015_2016 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_line_num_dt ON ofec_sched_b_2015_2016 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_two_year_transaction_period_amt ON ofec_sched_b_2015_2016 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2015_2016_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2015_2016_two_year_transaction_period_dt ON ofec_sched_b_2015_2016 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_clean_recipient_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_clean_recipient_cmte_id_amt ON ofec_sched_b_2017_2018 USING btree (clean_recipient_cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_clean_recipient_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_clean_recipient_cmte_id_dt ON ofec_sched_b_2017_2018 USING btree (clean_recipient_cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_cmte_id_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_amt ON ofec_sched_b_2017_2018 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_cmte_id_disb_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_disb_amt_sub_id ON ofec_sched_b_2017_2018 USING btree (cmte_id, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_cmte_id_disb_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_disb_dt_sub_id ON ofec_sched_b_2017_2018 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_cmte_id_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_dt ON ofec_sched_b_2017_2018 USING btree (cmte_id, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_disb_desc_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_disb_desc_text_amt ON ofec_sched_b_2017_2018 USING gin (disbursement_description_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_disb_desc_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_disb_desc_text_dt ON ofec_sched_b_2017_2018 USING gin (disbursement_description_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_image_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_image_num_amt ON ofec_sched_b_2017_2018 USING btree (image_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_image_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_image_num_dt ON ofec_sched_b_2017_2018 USING btree (image_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_pg_date ON ofec_sched_b_2017_2018 USING btree (pg_date);


--
-- Name: idx_ofec_sched_b_2017_2018_recip_name_text_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recip_name_text_amt ON ofec_sched_b_2017_2018 USING gin (recipient_name_text, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_recip_name_text_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recip_name_text_dt ON ofec_sched_b_2017_2018 USING gin (recipient_name_text, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_recipient_city_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_city_amt ON ofec_sched_b_2017_2018 USING btree (recipient_city, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_recipient_city_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_city_dt ON ofec_sched_b_2017_2018 USING btree (recipient_city, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_recipient_st_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_st_amt ON ofec_sched_b_2017_2018 USING btree (recipient_st, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_recipient_st_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_st_dt ON ofec_sched_b_2017_2018 USING btree (recipient_st, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_rpt_yr_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_rpt_yr_amt ON ofec_sched_b_2017_2018 USING btree (rpt_yr, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_rpt_yr_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_rpt_yr_dt ON ofec_sched_b_2017_2018 USING btree (rpt_yr, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_sub_id_amount_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_amount_dt ON ofec_sched_b_2017_2018 USING btree (disb_amt, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_sub_id_date_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_date_amt ON ofec_sched_b_2017_2018 USING btree (disb_dt, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_sub_id_line_num_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_line_num_amt ON ofec_sched_b_2017_2018 USING btree (line_num, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_sub_id_line_num_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_line_num_dt ON ofec_sched_b_2017_2018 USING btree (line_num, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_two_year_transaction_period_amt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_two_year_transaction_period_amt ON ofec_sched_b_2017_2018 USING btree (two_year_transaction_period, disb_amt, sub_id);


--
-- Name: idx_ofec_sched_b_2017_2018_two_year_transaction_period_dt; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_b_2017_2018_two_year_transaction_period_dt ON ofec_sched_b_2017_2018 USING btree (two_year_transaction_period, disb_dt, sub_id);


--
-- Name: idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_cal_ytd_ofc_sought_sub_id ON ofec_sched_e USING btree (cal_ytd_ofc_sought, sub_id);


--
-- Name: idx_ofec_sched_e_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_cmte_id ON ofec_sched_e USING btree (cmte_id);


--
-- Name: idx_ofec_sched_e_cycle_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_cycle_rpt_yr ON ofec_sched_e USING btree (get_cycle(rpt_yr));


--
-- Name: idx_ofec_sched_e_entity_tp; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_entity_tp ON ofec_sched_e USING btree (entity_tp);


--
-- Name: idx_ofec_sched_e_exp_amt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_exp_amt_sub_id ON ofec_sched_e USING btree (exp_amt, sub_id);


--
-- Name: idx_ofec_sched_e_exp_dt_sub_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_exp_dt_sub_id ON ofec_sched_e USING btree (exp_dt, sub_id);


--
-- Name: idx_ofec_sched_e_filing_form; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_filing_form ON ofec_sched_e USING btree (filing_form);


--
-- Name: idx_ofec_sched_e_image_num; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_image_num ON ofec_sched_e USING btree (image_num);


--
-- Name: idx_ofec_sched_e_is_notice; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_is_notice ON ofec_sched_e USING btree (is_notice);


--
-- Name: idx_ofec_sched_e_payee_name_text; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_payee_name_text ON ofec_sched_e USING gin (payee_name_text);


--
-- Name: idx_ofec_sched_e_pg_date; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_pg_date ON ofec_sched_e USING btree (pg_date);


--
-- Name: idx_ofec_sched_e_rpt_yr; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_rpt_yr ON ofec_sched_e USING btree (rpt_yr);


--
-- Name: idx_ofec_sched_e_s_o_cand_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX idx_ofec_sched_e_s_o_cand_id ON ofec_sched_e USING btree (s_o_cand_id);


--
-- Name: ix_ofec_election_dates_index; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ix_ofec_election_dates_index ON ofec_election_dates USING btree (index);


--
-- Name: ix_ofec_nicknames_index; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ix_ofec_nicknames_index ON ofec_nicknames USING btree (index);


--
-- Name: ix_ofec_pacronyms_index; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ix_ofec_pacronyms_index ON ofec_pacronyms USING btree (index);


--
-- Name: ofec_amendments_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_amendments_mv_tmp_idx_idx1 ON ofec_amendments_mv USING btree (idx);


--
-- Name: ofec_cand_cmte_linkage_mv_tmp_cand_election_yr_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_cand_cmte_linkage_mv_tmp_cand_election_yr_idx ON ofec_cand_cmte_linkage_mv USING btree (cand_election_yr);


--
-- Name: ofec_cand_cmte_linkage_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_cand_cmte_linkage_mv_tmp_cand_id_idx ON ofec_cand_cmte_linkage_mv USING btree (cand_id);


--
-- Name: ofec_cand_cmte_linkage_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_cand_cmte_linkage_mv_tmp_cmte_id_idx ON ofec_cand_cmte_linkage_mv USING btree (cmte_id);


--
-- Name: ofec_cand_cmte_linkage_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_cand_cmte_linkage_mv_tmp_idx_idx ON ofec_cand_cmte_linkage_mv USING btree (idx);


--
-- Name: ofec_candidate_detail_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_candidate_id_idx ON ofec_candidate_detail_mv USING btree (candidate_id);


--
-- Name: ofec_candidate_detail_mv_tmp_candidate_status_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_candidate_status_idx ON ofec_candidate_detail_mv USING btree (candidate_status);


--
-- Name: ofec_candidate_detail_mv_tmp_cycles_candidate_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_cycles_candidate_id_idx1 ON ofec_candidate_detail_mv USING btree (cycles, candidate_id);


--
-- Name: ofec_candidate_detail_mv_tmp_cycles_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_cycles_idx ON ofec_candidate_detail_mv USING gin (cycles);


--
-- Name: ofec_candidate_detail_mv_tmp_district_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_district_idx ON ofec_candidate_detail_mv USING btree (district);


--
-- Name: ofec_candidate_detail_mv_tmp_election_years_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_election_years_idx ON ofec_candidate_detail_mv USING gin (election_years);


--
-- Name: ofec_candidate_detail_mv_tmp_first_file_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_first_file_date_idx ON ofec_candidate_detail_mv USING btree (first_file_date);


--
-- Name: ofec_candidate_detail_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_detail_mv_tmp_idx_idx ON ofec_candidate_detail_mv USING btree (idx);


--
-- Name: ofec_candidate_detail_mv_tmp_incumbent_challenge_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_incumbent_challenge_idx ON ofec_candidate_detail_mv USING btree (incumbent_challenge);


--
-- Name: ofec_candidate_detail_mv_tmp_load_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_load_date_idx ON ofec_candidate_detail_mv USING btree (load_date);


--
-- Name: ofec_candidate_detail_mv_tmp_name_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_name_idx ON ofec_candidate_detail_mv USING btree (name);


--
-- Name: ofec_candidate_detail_mv_tmp_office_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_office_full_idx1 ON ofec_candidate_detail_mv USING btree (office_full);


--
-- Name: ofec_candidate_detail_mv_tmp_office_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_office_idx ON ofec_candidate_detail_mv USING btree (office);


--
-- Name: ofec_candidate_detail_mv_tmp_party_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_party_full_idx1 ON ofec_candidate_detail_mv USING btree (party_full);


--
-- Name: ofec_candidate_detail_mv_tmp_party_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_party_idx ON ofec_candidate_detail_mv USING btree (party);


--
-- Name: ofec_candidate_detail_mv_tmp_state_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_detail_mv_tmp_state_idx ON ofec_candidate_detail_mv USING btree (state);


--
-- Name: ofec_candidate_election_mv_tm_cand_election_year_candidate_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_election_mv_tm_cand_election_year_candidate_idx1 ON ofec_candidate_election_mv USING btree (cand_election_year, candidate_id);


--
-- Name: ofec_candidate_election_mv_tm_candidate_id_cand_election_ye_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_election_mv_tm_candidate_id_cand_election_ye_idx ON ofec_candidate_election_mv USING btree (candidate_id, cand_election_year);


--
-- Name: ofec_candidate_election_mv_tmp_cand_election_year_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_election_mv_tmp_cand_election_year_idx ON ofec_candidate_election_mv USING btree (cand_election_year);


--
-- Name: ofec_candidate_election_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_election_mv_tmp_candidate_id_idx ON ofec_candidate_election_mv USING btree (candidate_id);


--
-- Name: ofec_candidate_election_mv_tmp_prev_election_year_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_election_mv_tmp_prev_election_year_idx ON ofec_candidate_election_mv USING btree (prev_election_year);


--
-- Name: ofec_candidate_flag_tmp_candidate_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_flag_tmp_candidate_id_idx1 ON ofec_candidate_flag USING btree (candidate_id);


--
-- Name: ofec_candidate_flag_tmp_federal_funds_flag_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_flag_tmp_federal_funds_flag_idx1 ON ofec_candidate_flag USING btree (federal_funds_flag);


--
-- Name: ofec_candidate_flag_tmp_has_raised_funds_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_flag_tmp_has_raised_funds_idx1 ON ofec_candidate_flag USING btree (has_raised_funds);


--
-- Name: ofec_candidate_flag_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_flag_tmp_idx_idx1 ON ofec_candidate_flag USING btree (idx);


--
-- Name: ofec_candidate_fulltext_mv_tmp_fulltxt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_fulltext_mv_tmp_fulltxt_idx1 ON ofec_candidate_fulltext_mv USING gin (fulltxt);


--
-- Name: ofec_candidate_fulltext_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_fulltext_mv_tmp_idx_idx1 ON ofec_candidate_fulltext_mv USING btree (idx);


--
-- Name: ofec_candidate_fulltext_mv_tmp_receipts_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_fulltext_mv_tmp_receipts_idx1 ON ofec_candidate_fulltext_mv USING btree (receipts);


--
-- Name: ofec_candidate_history_latest_cand_election_year_candidate_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_latest_cand_election_year_candidate_idx1 ON ofec_candidate_history_latest_mv USING btree (cand_election_year, candidate_id);


--
-- Name: ofec_candidate_history_latest_candidate_id_cand_election_ye_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_history_latest_candidate_id_cand_election_ye_idx ON ofec_candidate_history_latest_mv USING btree (candidate_id, cand_election_year);


--
-- Name: ofec_candidate_history_latest_mv_tmp_cand_election_year_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_latest_mv_tmp_cand_election_year_idx ON ofec_candidate_history_latest_mv USING btree (cand_election_year);


--
-- Name: ofec_candidate_history_latest_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_latest_mv_tmp_candidate_id_idx ON ofec_candidate_history_latest_mv USING btree (candidate_id);


--
-- Name: ofec_candidate_history_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_candidate_id_idx ON ofec_candidate_history_mv USING btree (candidate_id);


--
-- Name: ofec_candidate_history_mv_tmp_district_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_district_idx1 ON ofec_candidate_history_mv USING btree (district);


--
-- Name: ofec_candidate_history_mv_tmp_district_number_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_district_number_idx1 ON ofec_candidate_history_mv USING btree (district_number);


--
-- Name: ofec_candidate_history_mv_tmp_first_file_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_first_file_date_idx ON ofec_candidate_history_mv USING btree (first_file_date);


--
-- Name: ofec_candidate_history_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_history_mv_tmp_idx_idx ON ofec_candidate_history_mv USING btree (idx);


--
-- Name: ofec_candidate_history_mv_tmp_load_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_load_date_idx ON ofec_candidate_history_mv USING btree (load_date);


--
-- Name: ofec_candidate_history_mv_tmp_office_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_office_idx1 ON ofec_candidate_history_mv USING btree (office);


--
-- Name: ofec_candidate_history_mv_tmp_state_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_state_idx1 ON ofec_candidate_history_mv USING btree (state);


--
-- Name: ofec_candidate_history_mv_tmp_two_year_period_candidate_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_two_year_period_candidate_id_idx1 ON ofec_candidate_history_mv USING btree (two_year_period, candidate_id);


--
-- Name: ofec_candidate_history_mv_tmp_two_year_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_history_mv_tmp_two_year_period_idx ON ofec_candidate_history_mv USING btree (two_year_period);


--
-- Name: ofec_candidate_totals_mv_tmp_candidate_id_cycle_is_election_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_candidate_totals_mv_tmp_candidate_id_cycle_is_election_idx ON ofec_candidate_totals_mv USING btree (candidate_id, cycle, is_election);


--
-- Name: ofec_candidate_totals_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_candidate_id_idx ON ofec_candidate_totals_mv USING btree (candidate_id);


--
-- Name: ofec_candidate_totals_mv_tmp_cycle_candidate_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_cycle_candidate_id_idx1 ON ofec_candidate_totals_mv USING btree (cycle, candidate_id);


--
-- Name: ofec_candidate_totals_mv_tmp_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_cycle_idx ON ofec_candidate_totals_mv USING btree (cycle);


--
-- Name: ofec_candidate_totals_mv_tmp_disbursements_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_disbursements_idx ON ofec_candidate_totals_mv USING btree (disbursements);


--
-- Name: ofec_candidate_totals_mv_tmp_election_year_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_election_year_idx ON ofec_candidate_totals_mv USING btree (election_year);


--
-- Name: ofec_candidate_totals_mv_tmp_federal_funds_flag_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_federal_funds_flag_idx1 ON ofec_candidate_totals_mv USING btree (federal_funds_flag);


--
-- Name: ofec_candidate_totals_mv_tmp_has_raised_funds_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_has_raised_funds_idx1 ON ofec_candidate_totals_mv USING btree (has_raised_funds);


--
-- Name: ofec_candidate_totals_mv_tmp_is_election_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_is_election_idx ON ofec_candidate_totals_mv USING btree (is_election);


--
-- Name: ofec_candidate_totals_mv_tmp_receipts_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_candidate_totals_mv_tmp_receipts_idx ON ofec_candidate_totals_mv USING btree (receipts);


--
-- Name: ofec_committee_detail_mv_tmp_candidate_ids_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_candidate_ids_idx1 ON ofec_committee_detail_mv USING gin (candidate_ids);


--
-- Name: ofec_committee_detail_mv_tmp_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_committee_id_idx1 ON ofec_committee_detail_mv USING btree (committee_id);


--
-- Name: ofec_committee_detail_mv_tmp_committee_type_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_committee_type_full_idx1 ON ofec_committee_detail_mv USING btree (committee_type_full);


--
-- Name: ofec_committee_detail_mv_tmp_committee_type_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_committee_type_idx1 ON ofec_committee_detail_mv USING btree (committee_type);


--
-- Name: ofec_committee_detail_mv_tmp_cycles_candidate_ids_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_cycles_candidate_ids_idx1 ON ofec_committee_detail_mv USING gin (cycles, candidate_ids);


--
-- Name: ofec_committee_detail_mv_tmp_cycles_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_cycles_idx1 ON ofec_committee_detail_mv USING gin (cycles);


--
-- Name: ofec_committee_detail_mv_tmp_designation_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_designation_full_idx1 ON ofec_committee_detail_mv USING btree (designation_full);


--
-- Name: ofec_committee_detail_mv_tmp_designation_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_designation_idx1 ON ofec_committee_detail_mv USING btree (designation);


--
-- Name: ofec_committee_detail_mv_tmp_first_file_date_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_first_file_date_idx1 ON ofec_committee_detail_mv USING btree (first_file_date);


--
-- Name: ofec_committee_detail_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_committee_detail_mv_tmp_idx_idx1 ON ofec_committee_detail_mv USING btree (idx);


--
-- Name: ofec_committee_detail_mv_tmp_last_file_date_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_last_file_date_idx1 ON ofec_committee_detail_mv USING btree (last_file_date);


--
-- Name: ofec_committee_detail_mv_tmp_name_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_name_idx1 ON ofec_committee_detail_mv USING btree (name);


--
-- Name: ofec_committee_detail_mv_tmp_organization_type_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_organization_type_full_idx1 ON ofec_committee_detail_mv USING btree (organization_type_full);


--
-- Name: ofec_committee_detail_mv_tmp_organization_type_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_organization_type_idx1 ON ofec_committee_detail_mv USING btree (organization_type);


--
-- Name: ofec_committee_detail_mv_tmp_party_full_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_party_full_idx1 ON ofec_committee_detail_mv USING btree (party_full);


--
-- Name: ofec_committee_detail_mv_tmp_party_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_party_idx1 ON ofec_committee_detail_mv USING btree (party);


--
-- Name: ofec_committee_detail_mv_tmp_state_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_state_idx1 ON ofec_committee_detail_mv USING btree (state);


--
-- Name: ofec_committee_detail_mv_tmp_treasurer_name_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_treasurer_name_idx1 ON ofec_committee_detail_mv USING btree (treasurer_name);


--
-- Name: ofec_committee_detail_mv_tmp_treasurer_text_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_detail_mv_tmp_treasurer_text_idx1 ON ofec_committee_detail_mv USING gin (treasurer_text);


--
-- Name: ofec_committee_fulltext_mv_tmp_fulltxt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_fulltext_mv_tmp_fulltxt_idx1 ON ofec_committee_fulltext_mv USING gin (fulltxt);


--
-- Name: ofec_committee_fulltext_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_committee_fulltext_mv_tmp_idx_idx1 ON ofec_committee_fulltext_mv USING btree (idx);


--
-- Name: ofec_committee_fulltext_mv_tmp_receipts_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_fulltext_mv_tmp_receipts_idx1 ON ofec_committee_fulltext_mv USING btree (receipts);


--
-- Name: ofec_committee_history_mv_tmp_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_committee_id_idx1 ON ofec_committee_history_mv USING btree (committee_id);


--
-- Name: ofec_committee_history_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_cycle_committee_id_idx1 ON ofec_committee_history_mv USING btree (cycle, committee_id);


--
-- Name: ofec_committee_history_mv_tmp_cycle_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_cycle_idx1 ON ofec_committee_history_mv USING btree (cycle);


--
-- Name: ofec_committee_history_mv_tmp_designation_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_designation_idx1 ON ofec_committee_history_mv USING btree (designation);


--
-- Name: ofec_committee_history_mv_tmp_first_file_date_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_first_file_date_idx ON ofec_committee_history_mv USING btree (first_file_date);


--
-- Name: ofec_committee_history_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_committee_history_mv_tmp_idx_idx1 ON ofec_committee_history_mv USING btree (idx);


--
-- Name: ofec_committee_history_mv_tmp_name_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_committee_history_mv_tmp_name_idx1 ON ofec_committee_history_mv USING btree (name);


--
-- Name: ofec_communication_cost_aggregate__support_oppose_indicator_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate__support_oppose_indicator_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (support_oppose_indicator);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_cand_id_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (cand_id);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_cmte_id_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (cmte_id);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_count_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_count_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (count);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_cycle_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (cycle);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_idx_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (idx);


--
-- Name: ofec_communication_cost_aggregate_candidate_mv_tmp_total_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_aggregate_candidate_mv_tmp_total_idx ON ofec_communication_cost_aggregate_candidate_mv USING btree (total);


--
-- Name: ofec_communication_cost_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_cand_id_idx ON ofec_communication_cost_mv USING btree (cand_id);


--
-- Name: ofec_communication_cost_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_cmte_id_idx ON ofec_communication_cost_mv USING btree (cmte_id);


--
-- Name: ofec_communication_cost_mv_tmp_communication_class_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_communication_class_idx ON ofec_communication_cost_mv USING btree (communication_class);


--
-- Name: ofec_communication_cost_mv_tmp_communication_cost_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_communication_cost_idx ON ofec_communication_cost_mv USING btree (communication_cost);


--
-- Name: ofec_communication_cost_mv_tmp_communication_dt_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_communication_dt_idx ON ofec_communication_cost_mv USING btree (communication_dt);


--
-- Name: ofec_communication_cost_mv_tmp_communication_tp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_communication_tp_idx ON ofec_communication_cost_mv USING btree (communication_tp);


--
-- Name: ofec_communication_cost_mv_tmp_filing_form_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_filing_form_idx ON ofec_communication_cost_mv USING btree (filing_form);


--
-- Name: ofec_communication_cost_mv_tmp_image_num_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_image_num_idx ON ofec_communication_cost_mv USING btree (image_num);


--
-- Name: ofec_communication_cost_mv_tmp_s_o_cand_office_district_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_s_o_cand_office_district_idx ON ofec_communication_cost_mv USING btree (s_o_cand_office_district);


--
-- Name: ofec_communication_cost_mv_tmp_s_o_cand_office_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_s_o_cand_office_idx ON ofec_communication_cost_mv USING btree (s_o_cand_office);


--
-- Name: ofec_communication_cost_mv_tmp_s_o_cand_office_st_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_s_o_cand_office_st_idx ON ofec_communication_cost_mv USING btree (s_o_cand_office_st);


--
-- Name: ofec_communication_cost_mv_tmp_s_o_ind_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_communication_cost_mv_tmp_s_o_ind_idx ON ofec_communication_cost_mv USING btree (s_o_ind);


--
-- Name: ofec_communication_cost_mv_tmp_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_communication_cost_mv_tmp_sub_id_idx ON ofec_communication_cost_mv USING btree (sub_id);


--
-- Name: ofec_election_dates_district_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_dates_district_idx ON ofec_election_dates USING btree (district);


--
-- Name: ofec_election_dates_election_yr_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_dates_election_yr_idx ON ofec_election_dates USING btree (election_yr);


--
-- Name: ofec_election_dates_office_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_dates_office_idx ON ofec_election_dates USING btree (office);


--
-- Name: ofec_election_dates_senate_class_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_dates_senate_class_idx ON ofec_election_dates USING btree (senate_class);


--
-- Name: ofec_election_dates_state_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_dates_state_idx ON ofec_election_dates USING btree (state);


--
-- Name: ofec_election_result_mv_tmp_cand_office_district_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_result_mv_tmp_cand_office_district_idx1 ON ofec_election_result_mv USING btree (cand_office_district);


--
-- Name: ofec_election_result_mv_tmp_cand_office_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_result_mv_tmp_cand_office_idx1 ON ofec_election_result_mv USING btree (cand_office);


--
-- Name: ofec_election_result_mv_tmp_cand_office_st_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_result_mv_tmp_cand_office_st_idx1 ON ofec_election_result_mv USING btree (cand_office_st);


--
-- Name: ofec_election_result_mv_tmp_election_yr_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_election_result_mv_tmp_election_yr_idx1 ON ofec_election_result_mv USING btree (election_yr);


--
-- Name: ofec_election_result_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_election_result_mv_tmp_idx_idx ON ofec_election_result_mv USING btree (idx);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_cand_id_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (cand_id);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_cmte_id_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (cmte_id);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_count_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_count_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (count);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_cycle_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (cycle);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_idx_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (idx);


--
-- Name: ofec_electioneering_aggregate_candidate_mv_tmp_total_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_aggregate_candidate_mv_tmp_total_idx ON ofec_electioneering_aggregate_candidate_mv USING btree (total);


--
-- Name: ofec_electioneering_mv_tmp_calculated_cand_share_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_calculated_cand_share_idx ON ofec_electioneering_mv USING btree (calculated_cand_share);


--
-- Name: ofec_electioneering_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_cand_id_idx ON ofec_electioneering_mv USING btree (cand_id);


--
-- Name: ofec_electioneering_mv_tmp_cand_office_district_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_cand_office_district_idx ON ofec_electioneering_mv USING btree (cand_office_district);


--
-- Name: ofec_electioneering_mv_tmp_cand_office_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_cand_office_idx ON ofec_electioneering_mv USING btree (cand_office);


--
-- Name: ofec_electioneering_mv_tmp_cand_office_st_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_cand_office_st_idx ON ofec_electioneering_mv USING btree (cand_office_st);


--
-- Name: ofec_electioneering_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_cmte_id_idx ON ofec_electioneering_mv USING btree (cmte_id);


--
-- Name: ofec_electioneering_mv_tmp_disb_dt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_disb_dt_idx1 ON ofec_electioneering_mv USING btree (disb_dt);


--
-- Name: ofec_electioneering_mv_tmp_f9_begin_image_num_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_f9_begin_image_num_idx ON ofec_electioneering_mv USING btree (f9_begin_image_num);


--
-- Name: ofec_electioneering_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_electioneering_mv_tmp_idx_idx ON ofec_electioneering_mv USING btree (idx);


--
-- Name: ofec_electioneering_mv_tmp_purpose_description_text_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_purpose_description_text_idx1 ON ofec_electioneering_mv USING gin (purpose_description_text);


--
-- Name: ofec_electioneering_mv_tmp_reported_disb_amt_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_reported_disb_amt_idx ON ofec_electioneering_mv USING btree (reported_disb_amt);


--
-- Name: ofec_electioneering_mv_tmp_rpt_yr_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_rpt_yr_idx ON ofec_electioneering_mv USING btree (rpt_yr);


--
-- Name: ofec_electioneering_mv_tmp_sb_image_num_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_electioneering_mv_tmp_sb_image_num_idx ON ofec_electioneering_mv USING btree (sb_image_num);


--
-- Name: ofec_filings_amendments_all_mv_tmp_file_num_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_amendments_all_mv_tmp_file_num_idx1 ON ofec_filings_amendments_all_mv USING btree (file_num);


--
-- Name: ofec_filings_amendments_all_mv_tmp_idx2_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_filings_amendments_all_mv_tmp_idx2_idx ON ofec_filings_amendments_all_mv USING btree (idx2);


--
-- Name: ofec_filings_mv_tmp_amendment_indicator_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_amendment_indicator_idx_idx1 ON ofec_filings_mv USING btree (amendment_indicator, idx);


--
-- Name: ofec_filings_mv_tmp_beginning_image_number_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_beginning_image_number_idx_idx1 ON ofec_filings_mv USING btree (beginning_image_number, idx);


--
-- Name: ofec_filings_mv_tmp_candidate_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_candidate_id_idx_idx1 ON ofec_filings_mv USING btree (candidate_id, idx);


--
-- Name: ofec_filings_mv_tmp_committee_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_committee_id_idx_idx1 ON ofec_filings_mv USING btree (committee_id, idx);


--
-- Name: ofec_filings_mv_tmp_coverage_end_date_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_coverage_end_date_idx_idx1 ON ofec_filings_mv USING btree (coverage_end_date, idx);


--
-- Name: ofec_filings_mv_tmp_coverage_start_date_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_coverage_start_date_idx_idx1 ON ofec_filings_mv USING btree (coverage_start_date, idx);


--
-- Name: ofec_filings_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_cycle_committee_id_idx1 ON ofec_filings_mv USING btree (cycle, committee_id);


--
-- Name: ofec_filings_mv_tmp_cycle_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_cycle_idx_idx1 ON ofec_filings_mv USING btree (cycle, idx);


--
-- Name: ofec_filings_mv_tmp_district_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_district_idx_idx ON ofec_filings_mv USING btree (district, idx);


--
-- Name: ofec_filings_mv_tmp_form_type_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_form_type_idx_idx1 ON ofec_filings_mv USING btree (form_type, idx);


--
-- Name: ofec_filings_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_filings_mv_tmp_idx_idx1 ON ofec_filings_mv USING btree (idx);


--
-- Name: ofec_filings_mv_tmp_office_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_office_idx_idx ON ofec_filings_mv USING btree (office, idx);


--
-- Name: ofec_filings_mv_tmp_party_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_party_idx_idx ON ofec_filings_mv USING btree (party, idx);


--
-- Name: ofec_filings_mv_tmp_primary_general_indicator_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_primary_general_indicator_idx_idx1 ON ofec_filings_mv USING btree (primary_general_indicator, idx);


--
-- Name: ofec_filings_mv_tmp_receipt_date_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_receipt_date_idx_idx1 ON ofec_filings_mv USING btree (receipt_date, idx);


--
-- Name: ofec_filings_mv_tmp_report_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_report_type_full_idx_idx ON ofec_filings_mv USING btree (report_type_full, idx);


--
-- Name: ofec_filings_mv_tmp_report_type_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_report_type_idx_idx1 ON ofec_filings_mv USING btree (report_type, idx);


--
-- Name: ofec_filings_mv_tmp_report_year_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_report_year_idx_idx1 ON ofec_filings_mv USING btree (report_year, idx);


--
-- Name: ofec_filings_mv_tmp_state_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_state_idx_idx ON ofec_filings_mv USING btree (state, idx);


--
-- Name: ofec_filings_mv_tmp_total_disbursements_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_total_disbursements_idx_idx1 ON ofec_filings_mv USING btree (total_disbursements, idx);


--
-- Name: ofec_filings_mv_tmp_total_independent_expenditures_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_total_independent_expenditures_idx_idx1 ON ofec_filings_mv USING btree (total_independent_expenditures, idx);


--
-- Name: ofec_filings_mv_tmp_total_receipts_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_filings_mv_tmp_total_receipts_idx_idx1 ON ofec_filings_mv USING btree (total_receipts, idx);


--
-- Name: ofec_house_senate_electronic_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_house_senate_electronic_amendments_mv_tmp_idx_idx ON ofec_house_senate_electronic_amendments_mv USING btree (idx);


--
-- Name: ofec_house_senate_paper_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_house_senate_paper_amendments_mv_tmp_idx_idx ON ofec_house_senate_paper_amendments_mv USING btree (idx);



--
-- Name: ofec_pac_party_electronic_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_pac_party_electronic_amendments_mv_tmp_idx_idx ON ofec_pac_party_electronic_amendments_mv USING btree (idx);


--
-- Name: ofec_pac_party_paper_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_pac_party_paper_amendments_mv_tmp_idx_idx ON ofec_pac_party_paper_amendments_mv USING btree (idx);


--
-- Name: ofec_presidential_electronic_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_presidential_electronic_amendments_mv_tmp_idx_idx ON ofec_presidential_electronic_amendments_mv USING btree (idx);


--
-- Name: ofec_presidential_paper_amendments_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_presidential_paper_amendments_mv_tmp_idx_idx ON ofec_presidential_paper_amendments_mv USING btree (idx);


--
-- Name: ofec_rad_mv_tmp_analyst_email_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_analyst_email_idx ON ofec_rad_mv USING btree (analyst_email);


--
-- Name: ofec_rad_mv_tmp_analyst_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_analyst_id_idx ON ofec_rad_mv USING btree (analyst_id);


--
-- Name: ofec_rad_mv_tmp_analyst_short_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_analyst_short_id_idx ON ofec_rad_mv USING btree (analyst_short_id);


--
-- Name: ofec_rad_mv_tmp_analyst_title_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_analyst_title_idx1 ON ofec_rad_mv USING btree (analyst_title);


--
-- Name: ofec_rad_mv_tmp_committee_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_committee_id_idx ON ofec_rad_mv USING btree (committee_id);


--
-- Name: ofec_rad_mv_tmp_committee_name_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_committee_name_idx ON ofec_rad_mv USING btree (committee_name);


--
-- Name: ofec_rad_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_rad_mv_tmp_idx_idx ON ofec_rad_mv USING btree (idx);


--
-- Name: ofec_rad_mv_tmp_last_name_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_last_name_idx ON ofec_rad_mv USING btree (last_name);


--
-- Name: ofec_rad_mv_tmp_name_txt_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_name_txt_idx ON ofec_rad_mv USING gin (name_txt);


--
-- Name: ofec_rad_mv_tmp_rad_branch_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_rad_branch_idx ON ofec_rad_mv USING btree (rad_branch);


--
-- Name: ofec_rad_mv_tmp_telephone_ext_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_rad_mv_tmp_telephone_ext_idx ON ofec_rad_mv USING btree (telephone_ext);


--
-- Name: ofec_reports_house_senate_mv__total_disbursements_period_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv__total_disbursements_period_id_idx ON ofec_reports_house_senate_mv USING btree (total_disbursements_period, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_beginning_image_number_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_beginning_image_number_idx_idx ON ofec_reports_house_senate_mv USING btree (beginning_image_number, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_committee_id_idx_idx ON ofec_reports_house_senate_mv USING btree (committee_id, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_coverage_end_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_coverage_end_date_idx_idx ON ofec_reports_house_senate_mv USING btree (coverage_end_date, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_coverage_start_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_coverage_start_date_idx_idx ON ofec_reports_house_senate_mv USING btree (coverage_start_date, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_cycle_idx_idx ON ofec_reports_house_senate_mv USING btree (cycle, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_reports_house_senate_mv_tmp_idx_idx ON ofec_reports_house_senate_mv USING btree (idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_is_amended_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_is_amended_idx_idx1 ON ofec_reports_house_senate_mv USING btree (is_amended, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_receipt_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_receipt_date_idx_idx ON ofec_reports_house_senate_mv USING btree (receipt_date, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_report_type_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_report_type_idx_idx ON ofec_reports_house_senate_mv USING btree (report_type, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_report_year_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_report_year_idx_idx ON ofec_reports_house_senate_mv USING btree (report_year, idx);


--
-- Name: ofec_reports_house_senate_mv_tmp_total_receipts_period_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_house_senate_mv_tmp_total_receipts_period_idx_idx ON ofec_reports_house_senate_mv USING btree (total_receipts_period, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_beginning_image_number_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_beginning_image_number_idx_idx ON ofec_reports_ie_only_mv USING btree (beginning_image_number, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_committee_id_idx_idx ON ofec_reports_ie_only_mv USING btree (committee_id, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_coverage_end_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_coverage_end_date_idx_idx ON ofec_reports_ie_only_mv USING btree (coverage_end_date, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_coverage_start_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_coverage_start_date_idx_idx ON ofec_reports_ie_only_mv USING btree (coverage_start_date, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_cycle_idx_idx ON ofec_reports_ie_only_mv USING btree (cycle, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_reports_ie_only_mv_tmp_idx_idx ON ofec_reports_ie_only_mv USING btree (idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_independent_expenditures_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_independent_expenditures_period_idx ON ofec_reports_ie_only_mv USING btree (independent_expenditures_period, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_is_amended_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_is_amended_idx_idx1 ON ofec_reports_ie_only_mv USING btree (is_amended, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_receipt_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_receipt_date_idx_idx ON ofec_reports_ie_only_mv USING btree (receipt_date, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_report_type_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_report_type_idx_idx ON ofec_reports_ie_only_mv USING btree (report_type, idx);


--
-- Name: ofec_reports_ie_only_mv_tmp_report_year_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_ie_only_mv_tmp_report_year_idx_idx ON ofec_reports_ie_only_mv USING btree (report_year, idx);


--
-- Name: ofec_reports_pacs_parties_mv__independent_expenditures_per_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv__independent_expenditures_per_idx1 ON ofec_reports_pacs_parties_mv USING btree (independent_expenditures_period, idx);


--
-- Name: ofec_reports_pacs_parties_mv__total_disbursements_period_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv__total_disbursements_period_id_idx ON ofec_reports_pacs_parties_mv USING btree (total_disbursements_period, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_beginning_image_number_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_beginning_image_number_idx_idx ON ofec_reports_pacs_parties_mv USING btree (beginning_image_number, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_committee_id_idx_idx ON ofec_reports_pacs_parties_mv USING btree (committee_id, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_coverage_end_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_coverage_end_date_idx_idx ON ofec_reports_pacs_parties_mv USING btree (coverage_end_date, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_coverage_start_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_coverage_start_date_idx_idx ON ofec_reports_pacs_parties_mv USING btree (coverage_start_date, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_cycle_committee_id_idx1 ON ofec_reports_pacs_parties_mv USING btree (cycle, committee_id);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_cycle_idx_idx ON ofec_reports_pacs_parties_mv USING btree (cycle, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_cycle_idx_idx3; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_cycle_idx_idx3 ON ofec_reports_pacs_parties_mv USING btree (cycle, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_reports_pacs_parties_mv_tmp_idx_idx ON ofec_reports_pacs_parties_mv USING btree (idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_is_amended_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_is_amended_idx_idx1 ON ofec_reports_pacs_parties_mv USING btree (is_amended, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_receipt_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_receipt_date_idx_idx ON ofec_reports_pacs_parties_mv USING btree (receipt_date, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_report_type_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_report_type_idx_idx ON ofec_reports_pacs_parties_mv USING btree (report_type, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_report_year_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_report_year_idx_idx ON ofec_reports_pacs_parties_mv USING btree (report_year, idx);


--
-- Name: ofec_reports_pacs_parties_mv_tmp_total_receipts_period_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_pacs_parties_mv_tmp_total_receipts_period_idx_idx ON ofec_reports_pacs_parties_mv USING btree (total_receipts_period, idx);


--
-- Name: ofec_reports_presidential_mv__total_disbursements_period_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv__total_disbursements_period_id_idx ON ofec_reports_presidential_mv USING btree (total_disbursements_period, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_beginning_image_number_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_beginning_image_number_idx_idx ON ofec_reports_presidential_mv USING btree (beginning_image_number, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_committee_id_idx_idx ON ofec_reports_presidential_mv USING btree (committee_id, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_coverage_end_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_coverage_end_date_idx_idx ON ofec_reports_presidential_mv USING btree (coverage_end_date, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_coverage_start_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_coverage_start_date_idx_idx ON ofec_reports_presidential_mv USING btree (coverage_start_date, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_cycle_committee_id_idx1 ON ofec_reports_presidential_mv USING btree (cycle, committee_id);


--
-- Name: ofec_reports_presidential_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_cycle_idx_idx ON ofec_reports_presidential_mv USING btree (cycle, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_reports_presidential_mv_tmp_idx_idx ON ofec_reports_presidential_mv USING btree (idx);


--
-- Name: ofec_reports_presidential_mv_tmp_is_amended_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_is_amended_idx_idx1 ON ofec_reports_presidential_mv USING btree (is_amended, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_receipt_date_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_receipt_date_idx_idx ON ofec_reports_presidential_mv USING btree (receipt_date, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_report_type_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_report_type_idx_idx ON ofec_reports_presidential_mv USING btree (report_type, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_report_year_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_report_year_idx_idx ON ofec_reports_presidential_mv USING btree (report_year, idx);


--
-- Name: ofec_reports_presidential_mv_tmp_total_receipts_period_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_reports_presidential_mv_tmp_total_receipts_period_idx_idx ON ofec_reports_presidential_mv USING btree (total_receipts_period, idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_cmte_type_full_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_ag_st_recipient_totals_cmte_type_full_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (committee_type_full, idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_cmte_type_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_ag_st_recipient_totals_cmte_type_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (committee_type, idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_ag_st_recipient_totals_cycle_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (cycle, idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_a_ag_st_recipient_totals_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_state_full_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_ag_st_recipient_totals_state_full_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (state_full, idx);


--
-- Name: ofec_sched_a_ag_st_recipient_totals_state_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_ag_st_recipient_totals_state_idx ON ofec_sched_a_aggregate_state_recipient_totals USING btree (state, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_cmte_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_cmte_id_idx_idx ON ofec_sched_a_aggregate_contributor USING btree (cmte_id, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_contbr_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_contbr_id_idx_idx ON ofec_sched_a_aggregate_contributor USING btree (contbr_id, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_count_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_count_idx_idx ON ofec_sched_a_aggregate_contributor USING btree (count, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_cycle_idx_idx ON ofec_sched_a_aggregate_contributor USING btree (cycle, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_total_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_total_idx_idx ON ofec_sched_a_aggregate_contributor USING btree (total, idx);


--
-- Name: ofec_sched_a_aggregate_contributor_type_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_type_cmte_id_idx ON ofec_sched_a_aggregate_contributor_type USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_contributor_type_count_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_type_count_idx ON ofec_sched_a_aggregate_contributor_type USING btree (count);


--
-- Name: ofec_sched_a_aggregate_contributor_type_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_type_cycle_idx ON ofec_sched_a_aggregate_contributor_type USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_contributor_type_individual_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_type_individual_idx ON ofec_sched_a_aggregate_contributor_type USING btree (individual);


--
-- Name: ofec_sched_a_aggregate_contributor_type_total_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_contributor_type_total_idx ON ofec_sched_a_aggregate_contributor_type USING btree (total);


--
-- Name: ofec_sched_a_aggregate_employer_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cmte_id ON ofec_sched_a_aggregate_employer USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_employer_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_count ON ofec_sched_a_aggregate_employer USING btree (count);


--
-- Name: ofec_sched_a_aggregate_employer_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cycle ON ofec_sched_a_aggregate_employer USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_employer_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_cycle_cmte_id ON ofec_sched_a_aggregate_employer USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_employer_employer; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_employer ON ofec_sched_a_aggregate_employer USING btree (employer);


--
-- Name: ofec_sched_a_aggregate_employer_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_employer_total ON ofec_sched_a_aggregate_employer USING btree (total);


--
-- Name: ofec_sched_a_aggregate_occupation_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cmte_id ON ofec_sched_a_aggregate_occupation USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_occupation_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_count ON ofec_sched_a_aggregate_occupation USING btree (count);


--
-- Name: ofec_sched_a_aggregate_occupation_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cycle ON ofec_sched_a_aggregate_occupation USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_occupation_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_cycle_cmte_id ON ofec_sched_a_aggregate_occupation USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_occupation_occupation; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_occupation ON ofec_sched_a_aggregate_occupation USING btree (occupation);


--
-- Name: ofec_sched_a_aggregate_occupation_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_occupation_total ON ofec_sched_a_aggregate_occupation USING btree (total);


--
-- Name: ofec_sched_a_aggregate_size_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cmte_id ON ofec_sched_a_aggregate_size USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_size_cmte_id_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cmte_id_cycle ON ofec_sched_a_aggregate_size USING btree (cmte_id, cycle);


--
-- Name: ofec_sched_a_aggregate_size_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_count ON ofec_sched_a_aggregate_size USING btree (count);


--
-- Name: ofec_sched_a_aggregate_size_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_cycle ON ofec_sched_a_aggregate_size USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_size_merged_cmte_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_cmte_idx ON ofec_sched_a_aggregate_size_merged USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_size_merged_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_cycle ON ofec_sched_a_aggregate_size_merged USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_size_merged_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_cycle_cmte_id ON ofec_sched_a_aggregate_size_merged USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_size_merged_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_a_aggregate_size_merged_idx ON ofec_sched_a_aggregate_size_merged USING btree (idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_cmte_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cmte_id_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (cmte_id, idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_count_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_count_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (count, idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_cmte_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_cmte_id_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_cycle_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (cycle, idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_size_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_size_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (size, idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_mv_tmp_total_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_mv_tmp_total_idx_idx1 ON ofec_sched_a_aggregate_size_merged_mv USING btree (total, idx);


--
-- Name: ofec_sched_a_aggregate_size_merged_size; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_merged_size ON ofec_sched_a_aggregate_size_merged USING btree (size);


--
-- Name: ofec_sched_a_aggregate_size_size; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_size ON ofec_sched_a_aggregate_size USING btree (size);


--
-- Name: ofec_sched_a_aggregate_size_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_size_total ON ofec_sched_a_aggregate_size USING btree (total);


--
-- Name: ofec_sched_a_aggregate_state_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cmte_id ON ofec_sched_a_aggregate_state USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_cmte_id_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cmte_id_old ON ofec_sched_a_aggregate_state_old USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_count ON ofec_sched_a_aggregate_state USING btree (count);


--
-- Name: ofec_sched_a_aggregate_state_count_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_count_old ON ofec_sched_a_aggregate_state_old USING btree (count);


--
-- Name: ofec_sched_a_aggregate_state_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle ON ofec_sched_a_aggregate_state USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_state_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle_cmte_id ON ofec_sched_a_aggregate_state USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_cycle_cmte_id_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle_cmte_id_old ON ofec_sched_a_aggregate_state_old USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_a_aggregate_state_cycle_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_cycle_old ON ofec_sched_a_aggregate_state_old USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_state_state; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state ON ofec_sched_a_aggregate_state USING btree (state);


--
-- Name: ofec_sched_a_aggregate_state_state_full; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state_full ON ofec_sched_a_aggregate_state USING btree (state_full);


--
-- Name: ofec_sched_a_aggregate_state_state_full_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state_full_old ON ofec_sched_a_aggregate_state_old USING btree (state_full);


--
-- Name: ofec_sched_a_aggregate_state_state_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_state_old ON ofec_sched_a_aggregate_state_old USING btree (state);


--
-- Name: ofec_sched_a_aggregate_state_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_total ON ofec_sched_a_aggregate_state USING btree (total);


--
-- Name: ofec_sched_a_aggregate_state_total_old; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_state_total_old ON ofec_sched_a_aggregate_state_old USING btree (total);


--
-- Name: ofec_sched_a_aggregate_zip_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_cmte_id ON ofec_sched_a_aggregate_zip USING btree (cmte_id);


--
-- Name: ofec_sched_a_aggregate_zip_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_count ON ofec_sched_a_aggregate_zip USING btree (count);


--
-- Name: ofec_sched_a_aggregate_zip_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_cycle ON ofec_sched_a_aggregate_zip USING btree (cycle);


--
-- Name: ofec_sched_a_aggregate_zip_state; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_state ON ofec_sched_a_aggregate_zip USING btree (state);


--
-- Name: ofec_sched_a_aggregate_zip_state_full; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_state_full ON ofec_sched_a_aggregate_zip USING btree (state_full);


--
-- Name: ofec_sched_a_aggregate_zip_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_total ON ofec_sched_a_aggregate_zip USING btree (total);


--
-- Name: ofec_sched_a_aggregate_zip_zip; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_aggregate_zip_zip ON ofec_sched_a_aggregate_zip USING btree (zip);


--
-- Name: ofec_sched_a_fulltext_contributor_employer_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_fulltext_contributor_employer_text_idx ON ofec_sched_a_fulltext USING gin (contributor_employer_text);


--
-- Name: ofec_sched_a_fulltext_contributor_name_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_fulltext_contributor_name_text_idx ON ofec_sched_a_fulltext USING gin (contributor_name_text);


--
-- Name: ofec_sched_a_fulltext_contributor_occupation_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_fulltext_contributor_occupation_text_idx ON ofec_sched_a_fulltext USING gin (contributor_occupation_text);


--
-- Name: ofec_sched_a_queue_new_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_new_sub_id_idx ON ofec_sched_a_queue_new USING btree (sub_id);


--
-- Name: ofec_sched_a_queue_new_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_new_timestamp_idx ON ofec_sched_a_queue_new USING btree ("timestamp");


--
-- Name: ofec_sched_a_queue_new_two_year_transaction_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_new_two_year_transaction_period_idx ON ofec_sched_a_queue_new USING btree (two_year_transaction_period);


--
-- Name: ofec_sched_a_queue_old_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_old_sub_id_idx ON ofec_sched_a_queue_old USING btree (sub_id);


--
-- Name: ofec_sched_a_queue_old_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_old_timestamp_idx ON ofec_sched_a_queue_old USING btree ("timestamp");


--
-- Name: ofec_sched_a_queue_old_two_year_transaction_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_a_queue_old_two_year_transaction_period_idx ON ofec_sched_a_queue_old USING btree (two_year_transaction_period);


--
-- Name: ofec_sched_b_aggregate_purpose_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cmte_id ON ofec_sched_b_aggregate_purpose USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_purpose_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_count ON ofec_sched_b_aggregate_purpose USING btree (count);


--
-- Name: ofec_sched_b_aggregate_purpose_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cycle ON ofec_sched_b_aggregate_purpose USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_purpose_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_cycle_cmte_id ON ofec_sched_b_aggregate_purpose USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_b_aggregate_purpose_purpose; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_purpose ON ofec_sched_b_aggregate_purpose USING btree (purpose);


--
-- Name: ofec_sched_b_aggregate_purpose_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_purpose_total ON ofec_sched_b_aggregate_purpose USING btree (total);


--
-- Name: ofec_sched_b_aggregate_recipient_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cmte_id ON ofec_sched_b_aggregate_recipient USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_count ON ofec_sched_b_aggregate_recipient USING btree (count);


--
-- Name: ofec_sched_b_aggregate_recipient_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cycle ON ofec_sched_b_aggregate_recipient USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_cycle_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_cycle_cmte_id ON ofec_sched_b_aggregate_recipient USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cmte_id ON ofec_sched_b_aggregate_recipient_id USING btree (cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cmte_id_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cmte_id_cycle ON ofec_sched_b_aggregate_recipient_id USING btree (cmte_id, cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_id_count; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_count ON ofec_sched_b_aggregate_recipient_id USING btree (count);


--
-- Name: ofec_sched_b_aggregate_recipient_id_cycle; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_cycle ON ofec_sched_b_aggregate_recipient_id USING btree (cycle);


--
-- Name: ofec_sched_b_aggregate_recipient_id_recipient_cmte_id; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_recipient_cmte_id ON ofec_sched_b_aggregate_recipient_id USING btree (recipient_cmte_id);


--
-- Name: ofec_sched_b_aggregate_recipient_id_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_id_total ON ofec_sched_b_aggregate_recipient_id USING btree (total);


--
-- Name: ofec_sched_b_aggregate_recipient_recipient_nm; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_recipient_nm ON ofec_sched_b_aggregate_recipient USING btree (recipient_nm);


--
-- Name: ofec_sched_b_aggregate_recipient_total; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_aggregate_recipient_total ON ofec_sched_b_aggregate_recipient USING btree (total);


--
-- Name: ofec_sched_b_fulltext_disbursement_description_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_fulltext_disbursement_description_text_idx ON ofec_sched_b_fulltext USING gin (disbursement_description_text);


--
-- Name: ofec_sched_b_fulltext_recipient_name_text_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_fulltext_recipient_name_text_idx ON ofec_sched_b_fulltext USING gin (recipient_name_text);


--
-- Name: ofec_sched_b_queue_new_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_new_sub_id_idx ON ofec_sched_b_queue_new USING btree (sub_id);


--
-- Name: ofec_sched_b_queue_new_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_new_timestamp_idx ON ofec_sched_b_queue_new USING btree ("timestamp");


--
-- Name: ofec_sched_b_queue_new_two_year_transaction_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_new_two_year_transaction_period_idx ON ofec_sched_b_queue_new USING btree (two_year_transaction_period);


--
-- Name: ofec_sched_b_queue_old_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_old_sub_id_idx ON ofec_sched_b_queue_old USING btree (sub_id);


--
-- Name: ofec_sched_b_queue_old_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_old_timestamp_idx ON ofec_sched_b_queue_old USING btree ("timestamp");


--
-- Name: ofec_sched_b_queue_old_two_year_transaction_period_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_b_queue_old_two_year_transaction_period_idx ON ofec_sched_b_queue_old USING btree (two_year_transaction_period);


--
-- Name: ofec_sched_c_mv_tmp_cand_nm_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_cand_nm_idx1 ON ofec_sched_c_mv USING btree (cand_nm);


--
-- Name: ofec_sched_c_mv_tmp_candidate_name_text_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_candidate_name_text_idx1 ON ofec_sched_c_mv USING gin (candidate_name_text);


--
-- Name: ofec_sched_c_mv_tmp_cmte_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_cmte_id_idx1 ON ofec_sched_c_mv USING btree (cmte_id);


--
-- Name: ofec_sched_c_mv_tmp_get_cycle_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_get_cycle_idx1 ON ofec_sched_c_mv USING btree (get_cycle(rpt_yr));


--
-- Name: ofec_sched_c_mv_tmp_image_num_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_image_num_idx1 ON ofec_sched_c_mv USING btree (image_num);


--
-- Name: ofec_sched_c_mv_tmp_incurred_dt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_incurred_dt_idx1 ON ofec_sched_c_mv USING btree (incurred_dt);


--
-- Name: ofec_sched_c_mv_tmp_incurred_dt_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_incurred_dt_sub_id_idx1 ON ofec_sched_c_mv USING btree (incurred_dt, sub_id);


--
-- Name: ofec_sched_c_mv_tmp_loan_source_name_text_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_loan_source_name_text_idx1 ON ofec_sched_c_mv USING gin (loan_source_name_text);


--
-- Name: ofec_sched_c_mv_tmp_orig_loan_amt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_orig_loan_amt_idx1 ON ofec_sched_c_mv USING btree (orig_loan_amt);


--
-- Name: ofec_sched_c_mv_tmp_orig_loan_amt_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_orig_loan_amt_sub_id_idx1 ON ofec_sched_c_mv USING btree (orig_loan_amt, sub_id);


--
-- Name: ofec_sched_c_mv_tmp_pg_date_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_pg_date_idx1 ON ofec_sched_c_mv USING btree (pg_date);


--
-- Name: ofec_sched_c_mv_tmp_pymt_to_dt_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_pymt_to_dt_idx1 ON ofec_sched_c_mv USING btree (pymt_to_dt);


--
-- Name: ofec_sched_c_mv_tmp_pymt_to_dt_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_pymt_to_dt_sub_id_idx1 ON ofec_sched_c_mv USING btree (pymt_to_dt, sub_id);


--
-- Name: ofec_sched_c_mv_tmp_rpt_yr_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_c_mv_tmp_rpt_yr_idx1 ON ofec_sched_c_mv USING btree (rpt_yr);


--
-- Name: ofec_sched_c_mv_tmp_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_c_mv_tmp_sub_id_idx1 ON ofec_sched_c_mv USING btree (sub_id);


--
-- Name: ofec_sched_e_aggregate_candidate_m_support_oppose_indicator_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_m_support_oppose_indicator_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (support_oppose_indicator);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_cand_id_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (cand_id);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_cmte_id_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (cmte_id);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_count_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_count_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (count);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_cycle_cand_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_cycle_cand_id_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (cycle, cand_id);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_cycle_cmte_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_cycle_cmte_id_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (cycle, cmte_id);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_cycle_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (cycle);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_idx_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (idx);


--
-- Name: ofec_sched_e_aggregate_candidate_mv_tmp_total_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_aggregate_candidate_mv_tmp_total_idx ON ofec_sched_e_aggregate_candidate_mv USING btree (total);


--
-- Name: ofec_sched_e_queue_new_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_queue_new_sub_id_idx ON ofec_sched_e_queue_new USING btree (sub_id);


--
-- Name: ofec_sched_e_queue_new_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_queue_new_timestamp_idx ON ofec_sched_e_queue_new USING btree ("timestamp");


--
-- Name: ofec_sched_e_queue_old_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_queue_old_sub_id_idx ON ofec_sched_e_queue_old USING btree (sub_id);


--
-- Name: ofec_sched_e_queue_old_timestamp_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_e_queue_old_timestamp_idx ON ofec_sched_e_queue_old USING btree ("timestamp");


--
-- Name: ofec_sched_f_mv_tmp_cand_id_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_cand_id_sub_id_idx1 ON ofec_sched_f_mv USING btree (cand_id, sub_id);


--
-- Name: ofec_sched_f_mv_tmp_cmte_id_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_cmte_id_sub_id_idx1 ON ofec_sched_f_mv USING btree (cmte_id, sub_id);


--
-- Name: ofec_sched_f_mv_tmp_exp_amt_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_exp_amt_sub_id_idx1 ON ofec_sched_f_mv USING btree (exp_amt, sub_id);


--
-- Name: ofec_sched_f_mv_tmp_exp_dt_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_exp_dt_sub_id_idx1 ON ofec_sched_f_mv USING btree (exp_dt, sub_id);


--
-- Name: ofec_sched_f_mv_tmp_image_num_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_image_num_sub_id_idx1 ON ofec_sched_f_mv USING btree (image_num, sub_id);


--
-- Name: ofec_sched_f_mv_tmp_payee_name_text_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_sched_f_mv_tmp_payee_name_text_idx1 ON ofec_sched_f_mv USING gin (payee_name_text);


--
-- Name: ofec_sched_f_mv_tmp_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_sched_f_mv_tmp_sub_id_idx1 ON ofec_sched_f_mv USING btree (sub_id);


--
-- Name: ofec_totals_candidate_committ_candidate_id_cycle_full_elect_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_candidate_committ_candidate_id_cycle_full_elect_idx ON ofec_totals_candidate_committees_mv USING btree (candidate_id, cycle, full_election);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_candidate_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_candidate_id_idx ON ofec_totals_candidate_committees_mv USING btree (candidate_id);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_cycle_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_cycle_idx ON ofec_totals_candidate_committees_mv USING btree (cycle);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_disbursements_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_disbursements_idx ON ofec_totals_candidate_committees_mv USING btree (disbursements);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_election_year_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_election_year_idx ON ofec_totals_candidate_committees_mv USING btree (election_year);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_federal_funds_flag_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_federal_funds_flag_idx ON ofec_totals_candidate_committees_mv USING btree (federal_funds_flag);


--
-- Name: ofec_totals_candidate_committees_mv_tmp_receipts_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_candidate_committees_mv_tmp_receipts_idx ON ofec_totals_candidate_committees_mv USING btree (receipts);


--
-- Name: ofec_totals_combined_mv_tmp_committee_designation_full_sub__idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_committee_designation_full_sub__idx ON ofec_totals_combined_mv USING btree (committee_designation_full, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_committee_id_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_committee_id_sub_id_idx1 ON ofec_totals_combined_mv USING btree (committee_id, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_committee_type_full_sub_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_committee_type_full_sub_id_idx ON ofec_totals_combined_mv USING btree (committee_type_full, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_cycle_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_cycle_sub_id_idx1 ON ofec_totals_combined_mv USING btree (cycle, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_disbursements_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_disbursements_sub_id_idx1 ON ofec_totals_combined_mv USING btree (disbursements, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_receipts_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_combined_mv_tmp_receipts_sub_id_idx1 ON ofec_totals_combined_mv USING btree (receipts, sub_id);


--
-- Name: ofec_totals_combined_mv_tmp_sub_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_combined_mv_tmp_sub_id_idx1 ON ofec_totals_combined_mv USING btree (sub_id);


--
-- Name: ofec_totals_house_senate_mv_t_committee_designation_full_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_t_committee_designation_full_id_idx ON ofec_totals_house_senate_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_house_senate_mv_tmp_candidate_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_candidate_id_idx_idx1 ON ofec_totals_house_senate_mv USING btree (candidate_id, idx);


--
-- Name: ofec_totals_house_senate_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_committee_id_idx_idx ON ofec_totals_house_senate_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_house_senate_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_committee_type_full_idx_idx ON ofec_totals_house_senate_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_house_senate_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_cycle_committee_id_idx1 ON ofec_totals_house_senate_mv USING btree (cycle, committee_id);


--
-- Name: ofec_totals_house_senate_mv_tmp_cycle_committee_id_idx3; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_cycle_committee_id_idx3 ON ofec_totals_house_senate_mv USING btree (cycle, committee_id);


--
-- Name: ofec_totals_house_senate_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_house_senate_mv_tmp_cycle_idx_idx ON ofec_totals_house_senate_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_house_senate_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_house_senate_mv_tmp_idx_idx ON ofec_totals_house_senate_mv USING btree (idx);


--
-- Name: ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_designation_full_idx_idx ON ofec_totals_ie_only_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_ie_only_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_id_idx_idx ON ofec_totals_ie_only_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_ie_only_mv_tmp_committee_type_full_idx_idx ON ofec_totals_ie_only_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_committee_id_idx1 ON ofec_totals_ie_only_mv USING btree (cycle, committee_id);


--
-- Name: ofec_totals_ie_only_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_ie_only_mv_tmp_cycle_idx_idx ON ofec_totals_ie_only_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_ie_only_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_ie_only_mv_tmp_idx_idx ON ofec_totals_ie_only_mv USING btree (idx);


--
-- Name: ofec_totals_pacs_mv_tmp_committee_designation_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_committee_designation_full_idx_idx ON ofec_totals_pacs_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_committee_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_committee_id_idx_idx1 ON ofec_totals_pacs_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_committee_type_full_idx_idx ON ofec_totals_pacs_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_committee_type_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_committee_type_idx_idx1 ON ofec_totals_pacs_mv USING btree (committee_type, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_cycle_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_cycle_idx_idx1 ON ofec_totals_pacs_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_designation_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_designation_idx_idx1 ON ofec_totals_pacs_mv USING btree (designation, idx);


--
-- Name: ofec_totals_pacs_mv_tmp_disbursements_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_disbursements_idx1 ON ofec_totals_pacs_mv USING btree (disbursements);


--
-- Name: ofec_totals_pacs_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_pacs_mv_tmp_idx_idx1 ON ofec_totals_pacs_mv USING btree (idx);


--
-- Name: ofec_totals_pacs_mv_tmp_receipts_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_mv_tmp_receipts_idx1 ON ofec_totals_pacs_mv USING btree (receipts);


--
-- Name: ofec_totals_pacs_parties_mv_t_committee_designation_full_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_t_committee_designation_full_id_idx ON ofec_totals_pacs_parties_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_committee_id_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_committee_id_idx_idx ON ofec_totals_pacs_parties_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_committee_type_full_idx_idx ON ofec_totals_pacs_parties_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_committee_type_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_committee_type_idx_idx1 ON ofec_totals_pacs_parties_mv USING btree (committee_type, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_cycle_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_cycle_idx_idx ON ofec_totals_pacs_parties_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_designation_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_designation_idx_idx1 ON ofec_totals_pacs_parties_mv USING btree (designation, idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_disbursements_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_disbursements_idx1 ON ofec_totals_pacs_parties_mv USING btree (disbursements);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_pacs_parties_mv_tmp_idx_idx ON ofec_totals_pacs_parties_mv USING btree (idx);


--
-- Name: ofec_totals_pacs_parties_mv_tmp_receipts_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_pacs_parties_mv_tmp_receipts_idx1 ON ofec_totals_pacs_parties_mv USING btree (receipts);


--
-- Name: ofec_totals_parties_mv_tmp_committee_designation_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_committee_designation_full_idx_idx ON ofec_totals_parties_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_parties_mv_tmp_committee_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_committee_id_idx_idx1 ON ofec_totals_parties_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_parties_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_committee_type_full_idx_idx ON ofec_totals_parties_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_parties_mv_tmp_committee_type_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_committee_type_idx_idx1 ON ofec_totals_parties_mv USING btree (committee_type, idx);


--
-- Name: ofec_totals_parties_mv_tmp_cycle_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_cycle_idx_idx1 ON ofec_totals_parties_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_parties_mv_tmp_designation_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_designation_idx_idx1 ON ofec_totals_parties_mv USING btree (designation, idx);


--
-- Name: ofec_totals_parties_mv_tmp_disbursements_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_disbursements_idx1 ON ofec_totals_parties_mv USING btree (disbursements);


--
-- Name: ofec_totals_parties_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_parties_mv_tmp_idx_idx1 ON ofec_totals_parties_mv USING btree (idx);


--
-- Name: ofec_totals_parties_mv_tmp_receipts_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_parties_mv_tmp_receipts_idx1 ON ofec_totals_parties_mv USING btree (receipts);


--
-- Name: ofec_totals_presidential_mv_t_committee_designation_full_id_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_presidential_mv_t_committee_designation_full_id_idx ON ofec_totals_presidential_mv USING btree (committee_designation_full, idx);


--
-- Name: ofec_totals_presidential_mv_tmp_committee_id_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_presidential_mv_tmp_committee_id_idx_idx1 ON ofec_totals_presidential_mv USING btree (committee_id, idx);


--
-- Name: ofec_totals_presidential_mv_tmp_committee_type_full_idx_idx; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_presidential_mv_tmp_committee_type_full_idx_idx ON ofec_totals_presidential_mv USING btree (committee_type_full, idx);


--
-- Name: ofec_totals_presidential_mv_tmp_cycle_committee_id_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_presidential_mv_tmp_cycle_committee_id_idx1 ON ofec_totals_presidential_mv USING btree (cycle, committee_id);


--
-- Name: ofec_totals_presidential_mv_tmp_cycle_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE INDEX ofec_totals_presidential_mv_tmp_cycle_idx_idx1 ON ofec_totals_presidential_mv USING btree (cycle, idx);


--
-- Name: ofec_totals_presidential_mv_tmp_idx_idx1; Type: INDEX; Schema: public; Owner: fec
--

CREATE UNIQUE INDEX ofec_totals_presidential_mv_tmp_idx_idx1 ON ofec_totals_presidential_mv USING btree (idx);


SET search_path = real_efile, pg_catalog;

--
-- Name: brin_index; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX brin_index ON reps USING btree ("timestamp");


--
-- Name: contributor_employer_text_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX contributor_employer_text_idx ON sa7 USING gin (contributor_employer_text);


--
-- Name: contributor_name_text_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX contributor_name_text_idx ON sa7 USING gin (contributor_name_text);


--
-- Name: contributor_occupation_text_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX contributor_occupation_text_idx ON sa7 USING gin (contributor_occupation_text);


--
-- Name: f3_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3_comid_idx ON f3 USING btree (comid);


--
-- Name: f3_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3_create_dt_idx ON f3 USING btree (create_dt);


--
-- Name: f3_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3_repid_idx ON f3 USING btree (repid);


--
-- Name: f3p_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3p_comid_idx ON f3p USING btree (comid);


--
-- Name: f3p_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3p_create_dt_idx ON f3p USING btree (create_dt);


--
-- Name: f3p_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3p_repid_idx ON f3p USING btree (repid);


--
-- Name: f3x_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3x_comid_idx ON f3x USING btree (comid);


--
-- Name: f3x_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f3x_create_dt_idx ON f3x USING btree (create_dt);


--
-- Name: f57_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f57_comid_idx ON f57 USING btree (comid);


--
-- Name: f57_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f57_create_dt_idx ON f57 USING btree (create_dt);


--
-- Name: f57_exp_date_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f57_exp_date_idx ON f57 USING btree (exp_date DESC);


--
-- Name: f57_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX f57_repid_idx ON f57 USING btree (repid);


--
-- Name: real_efile_f3_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_f3_comid_idx ON f3 USING btree (comid);


--
-- Name: real_efile_f3_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_f3_create_dt_idx ON f3 USING btree (create_dt);


--
-- Name: real_efile_f3p_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_f3p_comid_idx ON f3p USING btree (comid);


--
-- Name: real_efile_f3p_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_f3p_create_dt_idx ON f3p USING btree (create_dt);


--
-- Name: real_efile_reps_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_reps_comid_idx ON reps USING btree (comid);


--
-- Name: real_efile_sa7_amount_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_sa7_amount_idx ON sa7 USING btree (amount);


--
-- Name: real_efile_sa7_date_con_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_sa7_date_con_idx ON sa7 USING btree (date_con);


--
-- Name: real_efile_sa7_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_sa7_repid_idx ON sa7 USING btree (repid);


--
-- Name: real_efile_sb4_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX real_efile_sb4_repid_idx ON sb4 USING btree (repid);


--
-- Name: reps_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX reps_create_dt_idx ON reps USING brin (create_dt);


--
-- Name: reps_filed_date_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX reps_filed_date_idx ON reps USING brin (filed_date);


--
-- Name: reps_timestamp_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX reps_timestamp_idx ON reps USING brin ("timestamp");


--
-- Name: sb4_amount_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_amount_idx ON sb4 USING btree (amount);


--
-- Name: sb4_comid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_comid_idx ON sb4 USING btree (comid);


--
-- Name: sb4_date_dis_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_date_dis_idx ON sb4 USING btree (date_dis);


--
-- Name: sb4_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_repid_idx ON sb4 USING btree (repid);


--
-- Name: sb4_state_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_state_idx ON sb4 USING btree (state);


--
-- Name: sb4_transdesc_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX sb4_transdesc_idx ON sb4 USING btree (transdesc);


--
-- Name: summary_create_dt_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX summary_create_dt_idx ON summary USING btree (create_dt);


--
-- Name: summary_repid_idx; Type: INDEX; Schema: real_efile; Owner: fec
--

CREATE INDEX summary_repid_idx ON summary USING btree (repid);


SET search_path = staging, pg_catalog;

--
-- Name: idx_operations_log_pg_date; Type: INDEX; Schema: staging; Owner: fec
--

CREATE INDEX idx_operations_log_pg_date ON operations_log USING btree (pg_date);
