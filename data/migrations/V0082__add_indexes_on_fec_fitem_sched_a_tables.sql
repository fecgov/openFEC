-- Issus #3088 is to switch to use fecp-driven sched_a tables
-- creating all these indexes during release time will take LONG time and also cause performance problems .
-- Since tables are not being used before switch, indexes had been built during non-peak hour.  
-- However, migration file is still submitted to keep the track of the integrity of the migration process.
-- suppress a particular error reporting (error: 42P07 creating indexes if they already exist without error out)
-- Using create index if not exists will also generate a LOT of warning message.

-- fec_fitem_sched_a tables prior to election cycle 1998 do not have as many data and also are less queried.  No need for indexes except primary key
-- but for consistency, and also for possible future feature of multiple-cycle queries, indexes still added for election cycle 1976 to 2000

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1975_1976
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_contbr_zip ON disclosure.fec_fitem_sched_a_1975_1976 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_entity_tp ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1975_1976_rpt_yr ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1977_1978
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_contbr_zip ON disclosure.fec_fitem_sched_a_1977_1978 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_entity_tp ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1977_1978_rpt_yr ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1979_1980
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_contbr_zip ON disclosure.fec_fitem_sched_a_1979_1980 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_entity_tp ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1979_1980_rpt_yr ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1981_1982
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_contbr_zip ON disclosure.fec_fitem_sched_a_1981_1982 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_entity_tp ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1981_1982_rpt_yr ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1983_1984
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_contbr_zip ON disclosure.fec_fitem_sched_a_1983_1984 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_entity_tp ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1983_1984_rpt_yr ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1985_1986
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_contbr_zip ON disclosure.fec_fitem_sched_a_1985_1986 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_entity_tp ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1985_1986_rpt_yr ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1987_1988
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_contbr_zip ON disclosure.fec_fitem_sched_a_1987_1988 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_entity_tp ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1987_1988_rpt_yr ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1989_1990
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_contbr_zip ON disclosure.fec_fitem_sched_a_1989_1990 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_entity_tp ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1989_1990_rpt_yr ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1991_1992
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_contbr_zip ON disclosure.fec_fitem_sched_a_1991_1992 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_entity_tp ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1991_1992_rpt_yr ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1993_1994
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_contbr_zip ON disclosure.fec_fitem_sched_a_1993_1994 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_entity_tp ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1993_1994_rpt_yr ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1995_1996
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_contbr_zip ON disclosure.fec_fitem_sched_a_1995_1996 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_entity_tp ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1995_1996_rpt_yr ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1997_1998
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_name_text, contb_receipt_amt, sub_id);
-- contb_receipt_dt
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contributor_name_text, contb_receipt_dt, sub_id);
--
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_contbr_zip ON disclosure.fec_fitem_sched_a_1997_1998 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_entity_tp ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (entity_tp COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_a_1997_1998_rpt_yr ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (rpt_yr);
ANALYZE disclosure.fec_fitem_sched_a_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1999_2000
-- -------------------------------
-- -------------------------------
-- contb_receipt_amt
DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- contb_receipt_dt
DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
--
DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_contbr_zip ON disclosure.fec_fitem_sched_a_1999_2000 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_entity_tp ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX IF NOT EXISTS idx_sched_a_1999_2000_rpt_yr ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ANALYZE disclosure.fec_fitem_sched_a_1999_2000;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2001_2002
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_contbr_zip ON disclosure.fec_fitem_sched_a_2001_2002 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_entity_tp ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_rpt_yr ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2001_2002;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2003_2004
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_contbr_zip ON disclosure.fec_fitem_sched_a_2003_2004 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_entity_tp ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_rpt_yr ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2003_2004;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2005_2006
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_contbr_zip ON disclosure.fec_fitem_sched_a_2005_2006 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_entity_tp ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_rpt_yr ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2005_2006;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2007_2008
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_contbr_zip ON disclosure.fec_fitem_sched_a_2007_2008 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_entity_tp ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_rpt_yr ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2007_2008;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2009_2010
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_contbr_zip ON disclosure.fec_fitem_sched_a_2009_2010 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_entity_tp ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_rpt_yr ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2009_2010;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2011_2012
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_contbr_zip ON disclosure.fec_fitem_sched_a_2011_2012 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_entity_tp ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_rpt_yr ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2011_2012;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2013_2014
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_contbr_zip ON disclosure.fec_fitem_sched_a_2013_2014 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_entity_tp ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_rpt_yr ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2013_2014;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2015_2016
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_contbr_zip ON disclosure.fec_fitem_sched_a_2015_2016 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_entity_tp ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_rpt_yr ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2015_2016;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2017_2018
-- -------------------------------
-- -------------------------------
-- -----------------
-- contb_receipt_amt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_clean_contbr_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contbr_city_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contbr_st_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_image_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_id_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_line_num_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_occ_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_occupation_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_dt_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contb_receipt_dt, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_two_year_period_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (two_year_transaction_period, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_emp_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_employer_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_name_text_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_name_text, contb_receipt_amt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- contb_receipt_dt
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_clean_contbr_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contbr_city_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contbr_st_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_image_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_id_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_line_num_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_amt_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (contb_receipt_amt, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_two_year_period_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (two_year_transaction_period, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_occ_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_occupation_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_emp_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_employer_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contrib_name_text_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contributor_name_text, contb_receipt_dt, sub_id);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- -----------------
DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_contbr_zip ON disclosure.fec_fitem_sched_a_2017_2018 USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_entity_tp ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (entity_tp COLLATE pg_catalog."default");');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
	EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_rpt_yr ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (rpt_yr);');

      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_a_2017_2018;
