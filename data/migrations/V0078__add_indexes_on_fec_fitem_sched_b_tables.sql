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
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_recipient_st ON disclosure.fec_fitem_sched_b_1975_1976  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_recipient_city ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_cmte_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_amt ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disbursement_description_text ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_image_num ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_recipient_name_tex ON disclosure.fec_fitem_sched_b_1975_1976 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_rpt_yr ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_line_num ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_disb_dt ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1975_1976_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1975_1976 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1977_1978
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_recipient_st ON disclosure.fec_fitem_sched_b_1977_1978  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_recipient_city ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_cmte_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_amt ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disbursement_description_text ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_image_num ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_recipient_name_tex ON disclosure.fec_fitem_sched_b_1977_1978 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_rpt_yr ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_line_num ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_disb_dt ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1977_1978_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1977_1978 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1979_1980
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_recipient_st ON disclosure.fec_fitem_sched_b_1979_1980  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_recipient_city ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_cmte_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_amt ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disbursement_description_text ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_image_num ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_recipient_name_tex ON disclosure.fec_fitem_sched_b_1979_1980 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_rpt_yr ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_line_num ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_disb_dt ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1979_1980_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1979_1980 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1981_1982
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_recipient_st ON disclosure.fec_fitem_sched_b_1981_1982  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_recipient_city ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_cmte_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_amt ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disbursement_description_text ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_image_num ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_recipient_name_tex ON disclosure.fec_fitem_sched_b_1981_1982 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_rpt_yr ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_line_num ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_disb_dt ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1981_1982_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1981_1982 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1983_1984
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_recipient_st ON disclosure.fec_fitem_sched_b_1983_1984  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_recipient_city ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_cmte_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_amt ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disbursement_description_text ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_image_num ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_recipient_name_tex ON disclosure.fec_fitem_sched_b_1983_1984 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_rpt_yr ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_line_num ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_disb_dt ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1983_1984_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1983_1984 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1985_1986
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_recipient_st ON disclosure.fec_fitem_sched_b_1985_1986  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_recipient_city ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_cmte_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_amt ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disbursement_description_text ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_image_num ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_recipient_name_tex ON disclosure.fec_fitem_sched_b_1985_1986 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_rpt_yr ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_line_num ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_disb_dt ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1985_1986_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1985_1986 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1987_1988
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_recipient_st ON disclosure.fec_fitem_sched_b_1987_1988  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_recipient_city ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_cmte_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_amt ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disbursement_description_text ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_image_num ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_recipient_name_tex ON disclosure.fec_fitem_sched_b_1987_1988 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_rpt_yr ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_line_num ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_disb_dt ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1987_1988_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1987_1988 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1989_1990
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_recipient_st ON disclosure.fec_fitem_sched_b_1989_1990  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_recipient_city ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_cmte_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_amt ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disbursement_description_text ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_image_num ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_recipient_name_tex ON disclosure.fec_fitem_sched_b_1989_1990 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_rpt_yr ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_line_num ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_disb_dt ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1989_1990_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1989_1990 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1991_1992
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_recipient_st ON disclosure.fec_fitem_sched_b_1991_1992  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_recipient_city ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_cmte_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_amt ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disbursement_description_text ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_image_num ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_recipient_name_tex ON disclosure.fec_fitem_sched_b_1991_1992 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_rpt_yr ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_line_num ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_disb_dt ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1991_1992_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1991_1992 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1993_1994
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_recipient_st ON disclosure.fec_fitem_sched_b_1993_1994  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_recipient_city ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_cmte_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_amt ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disbursement_description_text ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_image_num ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_recipient_name_tex ON disclosure.fec_fitem_sched_b_1993_1994 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_rpt_yr ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_line_num ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_disb_dt ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1993_1994_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1993_1994 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1995_1996
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_recipient_st ON disclosure.fec_fitem_sched_b_1995_1996  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_recipient_city ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_cmte_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_amt ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disbursement_description_text ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_image_num ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_recipient_name_tex ON disclosure.fec_fitem_sched_b_1995_1996 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_rpt_yr ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_line_num ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_disb_dt ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1995_1996_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1995_1996 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1997_1998
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_recipient_st ON disclosure.fec_fitem_sched_b_1997_1998  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_recipient_city ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_cmte_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_amt ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disbursement_description_text ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_image_num ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_recipient_name_tex ON disclosure.fec_fitem_sched_b_1997_1998 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_rpt_yr ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_line_num ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_disb_dt ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1997_1998_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1997_1998 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1999_2000
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_recipient_st ON disclosure.fec_fitem_sched_b_1999_2000  USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_recipient_city ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_cmte_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_amt ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disbursement_description_text ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_image_num ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_recipient_name_tex ON disclosure.fec_fitem_sched_b_1999_2000 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_rpt_yr ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_line_num ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_disb_dt ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_1999_2000_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_1999_2000 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2001_2002
-- -------------------------------
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_recipient_st ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (recipient_st COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_recipient_city ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (recipient_city COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_cmte_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_id COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_amt ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_amt);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disbursement_description_text ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (disbursement_description_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_image_num ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (image_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_recipient_name_text ON disclosure.fec_fitem_sched_b_2001_2002 USING gin (recipient_name_text);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_rpt_yr ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (rpt_yr);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_line_num ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (line_num COLLATE pg_catalog."default");
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_disb_dt ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_dt);
CREATE INDEX IF NOT EXISTS idx_sched_b_2001_2002_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2001_2002 USING btree ((COALESCE(disb_dt, '9999-12-31'::date::timestamp without time zone)));
ANALYZE disclosure.fec_fitem_sched_b_2001_2002;



-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2003_2004
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_recipient_st ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_recipient_city ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_amt ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disbursement_description_text ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_image_num ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_recipient_name_text ON disclosure.fec_fitem_sched_b_2003_2004 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_rpt_yr ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_line_num ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_dt ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2003_2004 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_recipient_st ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_recipient_city ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_amt ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disbursement_description_text ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_image_num ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_recipient_name_text ON disclosure.fec_fitem_sched_b_2005_2006 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_rpt_yr ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_line_num ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_dt ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2005_2006 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_recipient_st ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_recipient_city ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_amt ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disbursement_description_text ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_image_num ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_recipient_name_text ON disclosure.fec_fitem_sched_b_2007_2008 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_rpt_yr ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_line_num ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_dt ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2007_2008 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_recipient_st ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_recipient_city ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_amt ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disbursement_description_text ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_image_num ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_recipient_name_text ON disclosure.fec_fitem_sched_b_2009_2010 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_rpt_yr ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_line_num ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_dt ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2009_2010 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_recipient_st ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_recipient_city ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_amt ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disbursement_description_text ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_image_num ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_recipient_name_text ON disclosure.fec_fitem_sched_b_2011_2012 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_rpt_yr ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_line_num ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_dt ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2011_2012 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_recipient_st ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_recipient_city ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_amt ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disbursement_description_text ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_image_num ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_recipient_name_text ON disclosure.fec_fitem_sched_b_2013_2014 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_rpt_yr ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_line_num ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_dt ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2013_2014 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
ALTER index IF EXISTS disclosure.idx_sched_b_2015_2016_clean_recipient_recipient_st rename to idx_sched_b_2015_2016_recipient_st;

DO $$
BEGIN

    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

  
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_recipient_st ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_recipient_city ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_amt ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disbursement_description_text ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_image_num ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_recipient_name_text ON disclosure.fec_fitem_sched_b_2015_2016 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_rpt_yr ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_line_num ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_dt ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2015_2016 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

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
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_clean_recipient_cmte_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default");');
  
    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_recipient_st ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (recipient_st COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_recipient_city ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (recipient_city COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_id COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_amt ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_amt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disbursement_description_text ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (disbursement_description_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_image_num ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (image_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_recipient_name_text ON disclosure.fec_fitem_sched_b_2017_2018 USING gin (recipient_name_text);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_rpt_yr ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (rpt_yr);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_line_num ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (line_num COLLATE pg_catalog."default");');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_dt ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_dt);');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_coalesce_disb_dt ON disclosure.fec_fitem_sched_b_2017_2018 USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)));');

    EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ANALYZE disclosure.fec_fitem_sched_b_2017_2018;

  