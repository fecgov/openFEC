/*
This is to solve issue #3787
Add column org_tp, cmte_dsgn to fec_fitem_sched_b and fec_fitem_sched_a tables.
These columns will be added to all 3 cloud environment ahead of time at the same time since
1. the java program that load the data (which is the same program, just pass in different db as parameter) will run to all environments
2. the update statement to backfill this column for existing rows and indexes creation are very time and resource consuming so need to be performed at off-peak hour
However, the migration file still submitted to keep the version flow.
*/
-- -----------------------------------------------------
-- Add org_tp, cmte_dsgn columns to disclosure.fec_fitem_sched_b
-- -----------------------------------------------------
-- Add column
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_b ADD COLUMN org_tp varchar(1)');
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_b ADD COLUMN cmte_dsgn varchar(1)');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


-- -----------------------------------------------------
-- Add org_tp, cmte_dsgn columns to disclosure.fec_fitem_sched_a
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_a ADD COLUMN org_tp varchar(1)');
    EXECUTE format('ALTER TABLE disclosure.fec_fitem_sched_a ADD COLUMN cmte_dsgn varchar(1)');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;





-- -----------------------------------------------------
-- -----------------------------------------------------
-- Add index on org_tp and cmte_dsgn columns to disclosure.fec_fitem_sched_b
-- -----------------------------------------------------
-- -----------------------------------------------------
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1975_1976
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1977_1978
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1979_1980
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1981_1982
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1983_1984
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1985_1986
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1987_1988
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1989_1990
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1991_1992
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1993_1994
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1995_1996
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1997_1998
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_1999_2000
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2001_2002
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2001_2002;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2003_2004
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2003_2004;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2005_2006
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2005_2006;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2007_2008
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2007_2008;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2009_2010
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2009_2010;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2011_2012
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2011_2012;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2013_2014
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2013_2014;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2015_2016
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2015_2016;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2017_2018
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2017_2018;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_b_2019_2020
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_b_2019_2020_org_tp_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2019_2020 USING btree (org_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2019_2020_org_tp_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2019_2020 USING btree (org_tp COLLATE pg_catalog."default",  disb_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_b_2019_2020_cmte_dsgn_colsc_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2019_2020 USING btree (cmte_dsgn COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_b_2019_2020_cmte_dsgn_disb_amt_sub_id ON disclosure.fec_fitem_sched_b_2019_2020 USING btree (cmte_dsgn COLLATE pg_catalog."default",  disb_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_b_2019_2020;





-- -----------------------------------------------------
-- -----------------------------------------------------
-- Add index on org_tp and cmte_dsgn column to disclosure.fec_fitem_sched_a
-- -----------------------------------------------------
-- -----------------------------------------------------
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1975_1976
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1975_1976;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1977_1978
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1977_1978;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1979_1980
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1979_1980;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1981_1982
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1981_1982;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1983_1984
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1983_1984;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1985_1986
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1985_1986;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1987_1988
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1987_1988;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1989_1990
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1989_1990;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1991_1992
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1991_1992;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1993_1994
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1993_1994;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1995_1996
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1995_1996;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1997_1998
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1997_1998;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_1999_2000
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_1999_2000;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2001_2002
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2001_2002;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2003_2004
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2003_2004;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2005_2006
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2005_2006;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2007_2008
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2007_2008;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2009_2010
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2009_2010;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2011_2012
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2011_2012;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2013_2014
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2013_2014;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2015_2016
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2015_2016;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2017_2018
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2017_2018;
-- -------------------------------
-- -------------------------------
--   fec_fitem_sched_a_2019_2020
-- -------------------------------
-- -------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE INDEX idx_sched_a_2019_2020_org_tp_dt_sub_id ON disclosure.fec_fitem_sched_a_2019_2020 USING btree (org_tp COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2019_2020_org_tp_amt_sub_id ON disclosure.fec_fitem_sched_a_2019_2020 USING btree (org_tp COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');


        EXECUTE format('CREATE INDEX idx_sched_a_2019_2020_cmte_dsgn_dt_sub_id ON disclosure.fec_fitem_sched_a_2019_2020 USING btree (cmte_dsgn COLLATE pg_catalog."default", contb_receipt_dt, sub_id);');
        EXECUTE format('CREATE INDEX idx_sched_a_2019_2020_cmte_dsgn_amt_sub_id ON disclosure.fec_fitem_sched_a_2019_2020 USING btree (cmte_dsgn COLLATE pg_catalog."default",  contb_receipt_amt, sub_id);');
EXCEPTION
        WHEN duplicate_table THEN
                null;
        WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- VACUUM ANALYZE disclosure.fec_fitem_sched_a_2019_2020;


-- -----------------------------------------------------
-- -----------------------------------------------------
-- Update the following function as approprieate (which can be used to create indexes for the correspoinging fec_sched_a_xxxx_yyyy/fec_sched_b_xxxx_yyyy) for future new tables
-- -----------------------------------------------------
-- -----------------------------------------------------
-- -------------------------------
-- -------------------------------
-- Update FUNCTION disclosure.finalize_itemized_schedule_b_tables to include the new indexes
-- -------------------------------
-- -------------------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_b_tables(
    start_year numeric,
    end_year numeric,
    p_use_tmp boolean DEFAULT false,
    p_create_primary_key boolean DEFAULT false)
  RETURNS void AS
$BODY$

DECLARE

    child_table_name TEXT;
    
    child_index_root TEXT;

    index_name_suffix TEXT default '';

BEGIN


    FOR cycle in start_year..end_year BY 2 LOOP

        child_table_name = format('disclosure.fec_fitem_sched_b_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_b_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('disclosure.fec_fitem_sched_b_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;


    -- coalesce disb_dt
        EXECUTE format('CREATE INDEX %s_cln_rcpt_cmte_id_colsc_disb_dt_sub_id%s ON %s USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_st_colsc_disb_dt_sub_id%s ON %s USING btree (recipient_st COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_city_colsc_disb_dt_sub_id%s ON %s USING btree (recipient_city COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_colsc_disb_dt_sub_id%s ON %s USING btree (cmte_id COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_desc_text_colsc_disb_dt_sub_id%s ON %s USING gin (disbursement_description_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_colsc_disb_dt_sub_id%s ON %s USING btree (image_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_name_text_colsc_disb_dt_sub_id%s ON %s USING gin (recipient_name_text, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr_colsc_disb_dt_sub_id%s ON %s USING btree (rpt_yr, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_colsc_disb_dt_sub_id%s ON %s USING btree (line_num COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_amt_colsc_disb_dt_sub_id%s ON %s USING btree (disb_amt, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_colsc_disb_dt_sub_id%s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_colsc_disb_dt_sub_id%s ON %s USING btree ((COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_org_tp_colsc_disb_dt_sub_id%s ON %s USING btree (org_tp, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_dsgn_colsc_disb_dt_sub_id%s ON %s USING btree (cmte_dsgn, (COALESCE(disb_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_amt
        EXECUTE format('CREATE INDEX %s_cln_rcpt_cmte_id_disb_amt_sub_id%s ON %s USING btree (clean_recipient_cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_st_disb_amt_sub_id%s ON %s  USING btree (recipient_st COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_city_disb_amt_sub_id%s ON %s USING btree (recipient_city COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_disb_amt_sub_id%s ON %s USING btree (cmte_id COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_desc_text_disb_amt_sub_id%s ON %s USING gin (disbursement_description_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_disb_amt_sub_id%s ON %s USING btree (image_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rcpt_name_text_disb_amt_sub_id%s ON %s USING gin (recipient_name_text, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr_disb_amt_sub_id%s ON %s USING btree (rpt_yr, disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_disb_amt_sub_id%s ON %s USING btree (line_num COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_disb_amt_sub_id%s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_disb_amt_sub_id%s ON %s USING btree (disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_org_tp_disb_amt_sub_id%s ON %s USING btree (org_tp,  disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_dsgn_disb_amt_sub_id%s ON %s USING btree (cmte_dsgn,  disb_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    -- disb_dt
        EXECUTE format('CREATE INDEX %s_disb_dt%s ON %s USING btree (disb_dt)', child_index_root, index_name_suffix, child_table_name);



        IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %s', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_b_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;


-- -------------------------------
-- -------------------------------
-- Update FUNCTION disclosure.finalize_itemized_schedule_a_tables to include the new indexes
-- -------------------------------
-- -------------------------------
CREATE OR REPLACE FUNCTION disclosure.finalize_itemized_schedule_a_tables(
    start_year numeric,
    end_year numeric,
    p_use_tmp boolean DEFAULT false,
    p_create_primary_key boolean DEFAULT false)
  RETURNS void AS
$BODY$

DECLARE

    child_table_name TEXT;
    child_index_root TEXT;
    index_name_suffix TEXT default '';

BEGIN


    FOR cycle in start_year..end_year BY 2 LOOP

        child_table_name = format('disclosure.fec_fitem_sched_a_%s_%s', cycle - 1, cycle);
        
    child_index_root = format('idx_sched_a_%s_%s', cycle - 1, cycle);


        IF p_use_tmp THEN

            child_table_name = format('disclosure.fec_fitem_sched_a_%s_%s_tmp', cycle - 1, cycle);

            index_name_suffix = '_tmp';


        END IF;

    -- contb_receipt_amt
        EXECUTE format('CREATE INDEX %s_clean_contbr_id_amt_sub_id %s ON %s USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_city_amt_sub_id %s ON %s USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_st_amt_sub_id %s ON %s USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_amt_sub_id %s ON %s USING btree (image_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_amt_sub_id %s ON %s USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_amt_sub_id %s ON %s USING btree (line_num COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_occ_text_amt_sub_id %s ON %s USING gin (contributor_occupation_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_dt_amt_sub_id %s ON %s USING btree (contb_receipt_dt, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_two_year_period_amt_sub_id %s ON %s USING btree (two_year_transaction_period, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_emp_text_amt_sub_id %s ON %s USING gin (contributor_employer_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_name_text_amt_sub_id %s ON %s USING gin (contributor_name_text, contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_rcpt_amt_sub_id %s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_org_tp_amt_sub_id%s ON  %s USING btree (org_tp,  contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_dsgn_amt_sub_id%s ON %s USING btree (cmte_dsgn,  contb_receipt_amt, sub_id)', child_index_root, index_name_suffix, child_table_name);

    -- contb_receipt_dt
        EXECUTE format('CREATE INDEX %s_clean_contbr_id_dt_sub_id %s ON %s USING btree (clean_contbr_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_city_dt_sub_id %s ON %s USING btree (contbr_city COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contbr_st_dt_sub_id %s ON %s USING btree (contbr_st COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_image_num_dt_sub_id %s ON %s USING btree (image_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_id_dt_sub_id %s ON %s USING btree (cmte_id COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_line_num_dt_sub_id %s ON %s USING btree (line_num COLLATE pg_catalog."default", contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_amt_dt_sub_id %s ON %s USING btree (contb_receipt_amt, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_two_year_period_dt_sub_id %s ON %s USING btree (two_year_transaction_period, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_occ_text_dt_sub_id %s ON %s USING gin (contributor_occupation_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_emp_text_dt_sub_id %s ON %s USING gin (contributor_employer_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_contrib_name_text_dt_sub_id %s ON %s USING gin (contributor_name_text, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_tp_colsc_rcpt_dt_sub_id %s ON %s USING btree (cmte_tp COLLATE pg_catalog."default", (COALESCE(contb_receipt_dt, ''9999-12-31''::date::timestamp without time zone)), sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_org_tp_dt_sub_id%s ON %s USING btree (org_tp, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_cmte_dsgn_dt_sub_id%s ON %s USING btree (cmte_dsgn, contb_receipt_dt, sub_id)', child_index_root, index_name_suffix, child_table_name);
    --
        EXECUTE format('CREATE INDEX %s_contbr_zip %s ON %s USING gin (contbr_zip COLLATE pg_catalog."default" gin_trgm_ops)', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_entity_tp %s ON %s USING btree (entity_tp COLLATE pg_catalog."default")', child_index_root, index_name_suffix, child_table_name);
        EXECUTE format('CREATE INDEX %s_rpt_yr %s ON %s USING btree (rpt_yr)', child_index_root, index_name_suffix, child_table_name);

    IF p_create_primary_key THEN

            EXECUTE format('ALTER TABLE %s ADD CONSTRAINT %s_pkey PRIMARY KEY (sub_id)', child_table_name, child_table_name);

        END IF;


        EXECUTE format('ANALYZE %s', child_table_name);

    END LOOP;

END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.finalize_itemized_schedule_a_tables(numeric, numeric, boolean, boolean)
  OWNER TO fec;

