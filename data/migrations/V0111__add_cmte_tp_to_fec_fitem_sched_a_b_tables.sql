DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_cmte_valid_fec_yr_cmte_id_fec_yr ON disclosure.cmte_valid_fec_yr USING btree (cmte_id, fec_election_yr)');
      	EXCEPTION 
             WHEN duplicate_table THEN 
				null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

--VACUUM ANALYZE disclosure.cmte_valid_fec_yr;


/*
Add column cmte_tp to fec_fitem_sched_b tables.
This column will be added to all 3 cloud environment ahead of time at the same time since
1. the java program that load the data (which is the same program, just pass in different db as parameter) will run to all environments
2. the update statement to fill in this column for existing rows is very time consuming and need to be performed at off-peak hour
However, the migration file still submitted to keep the version flow.
*/
-- -----------------------------------------------------
-- Add cmte_tp column to disclosure.fec_fitem_sched_b
-- -----------------------------------------------------
-- Add column
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_b ADD COLUMN cmte_tp varchar(1)');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------------------------------------------
-- Add cmte_tp column to disclosure.fec_fitem_sched_a
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_a ADD COLUMN cmte_tp varchar(1)');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------------------------------------------
-- Add index on cmte_tp column to disclosure.fec_fitem_sched_b
-- -----------------------------------------------------
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1975_1976
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1977_1978
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1979_1980
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1981_1982
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1983_1984
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1985_1986
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1987_1988
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1989_1990
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1991_1992
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1993_1994
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1995_1996
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1997_1998
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1999_2000
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2001_2002
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2001_2002;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2003_2004
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2003_2004;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2005_2006
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2005_2006;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2007_2008
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2007_2008;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2009_2010
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2009_2010;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2011_2012
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2011_2012;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2013_2014
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2013_2014;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2015_2016
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2015_2016;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2017_2018
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_b_2017_2018;



-- -----------------------------------------------------
-- Add index on cmte_tp column to disclosure.fec_fitem_sched_a
-- -----------------------------------------------------
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1975_1976
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1977_1978
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1979_1980
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1981_1982
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1983_1984
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1985_1986
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1987_1988
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1989_1990
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1991_1992
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1993_1994
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1995_1996
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1997_1998
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1999_2000
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2001_2002
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2001_2002;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2003_2004
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2003_2004;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2005_2006
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2005_2006;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2007_2008
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2007_2008;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2009_2010
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2009_2010;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2011_2012
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2011_2012;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2013_2014
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2013_2014;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2015_2016
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2015_2016;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2017_2018
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_tp_colsc_rcpt_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_tp_rcpt_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- ANALYZE disclosure.fec_fitem_sched_a_2017_2018;
