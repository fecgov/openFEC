-- Issus #3045 is to switch to use fecp-driven sched_b tables
-- creating all these indexes during release time will take LONG time and also cause performance problems .
-- Since tables are not being used before switch, indexes had been built during non-peak hour.  
-- However, migration file is still submitted to keep the track of the integrity of the migration process.
-- suppress a particular error reporting (error: 42P07 creating indexes if they already exist without error out)
-- Using create index if not exists will also generate a LOT of warning message.

-- fec_fitem_sched_b tables prior to election cycle 2002 do not have as many data and also are less queried.  No need for indexes except primary key
-- but for consistency, and also for possible future feature of multiple-cycle queries, indexes still added for election cycle 1976 to 2002

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1975_1976
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_dt ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1977_1978
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_dt ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1979_1980
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_dt ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1981_1982
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_dt ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1983_1984
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_dt ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1985_1986
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_dt ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1987_1988
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_dt ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1989_1990
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_dt ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1991_1992
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_dt ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1993_1994
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_dt ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1995_1996
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_dt ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1997_1998
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_dt ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1999_2000
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_dt ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2001_2002
-- -------------------------------
-- -------------------------------
-- coalesce disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (disbursement_description_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (recipient_name_text, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (rpt_yr, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_amt, (COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)), sub_id);
-- disb_amt
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (disbursement_description_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (recipient_name_text, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (rpt_yr, disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_amt, sub_id);
-- disb_dt
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_dt ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_dt);
ANALYZE disclosure.fec_fitem_sched_b_2001_2002;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2003_2004
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_dt ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2003_2004;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2005_2006
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_dt ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2005_2006;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2007_2008
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_dt ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2007_2008;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2009_2010
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_dt ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2009_2010;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2011_2012
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_dt ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2011_2012;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2013_2014
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_dt ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2013_2014;

-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2015_2016
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_dt ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ANALYZE disclosure.fec_fitem_sched_b_2015_2016;


-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2017_2018
-- -------------------------------
-- -------------------------------
-- -----------------
-- coalesce disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cln_rcpt_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_st_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018  USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_city_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_id_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_desc_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_image_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_name_text_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rpt_yr_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_line_num_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_amt_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



-- -----------------
-- disb_amt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cln_rcpt_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_st_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_city_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_id_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_desc_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (disbursement_description_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_image_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rcpt_name_text_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (recipient_name_text, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rpt_yr_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (rpt_yr, disb_amt, sub_id);');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_line_num_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_amt, sub_id);');

  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------
-- disb_dt
-- -----------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_dt ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;



ANALYZE disclosure.fec_fitem_sched_b_2017_2018;
