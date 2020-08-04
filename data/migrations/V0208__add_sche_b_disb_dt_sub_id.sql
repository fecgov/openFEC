/*
This migration file supports issue #4531
In order to add new index for performance (timeout), idx_sched_b_disb_dt_sub_id index added.
*/

-- -----------------------------------------------
-- idx_sched_b_<startYr_endYr>_disb_dt_sub_id
-- -----------------------------------------------

-- 1975_1976
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1975_1976_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1975_1976 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1977_1978
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1977_1978_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1977_1978 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1979_1980
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1979_1980_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1979_1980 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1981_1982
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1981_1982_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1981_1982 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1983_1984
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1983_1984_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1983_1984 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1985_1986
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1985_1986_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1985_1986 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1987_1988
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1987_1988_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1987_1988 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1989_1990
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1989_1990_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1989_1990 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1991_1992
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1991_1992_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1991_1992 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1993_1994
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1993_1994_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1993_1994 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1995_1996
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1995_1996_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1995_1996 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1997_1998
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1997_1998_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1997_1998 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1999_2000
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_1999_2000_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_1999_2000 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2001_2002
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2001_2002_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2001_2002 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2003_2004
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2003_2004_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2003_2004 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2005_2006
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2005_2006_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2005_2006 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2007_2008
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2007_2008_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2007_2008 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2009_2010
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2009_2010_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2009_2010 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2011_2012
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2011_2012_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2011_2012 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2013_2014
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2013_2014_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2013_2014 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2015_2016
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2015_2016_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2015_2016 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2017_2018
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2017_2018_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2017_2018 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2019_2020
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_b_2019_2020_disb_dt_sub_id ON disclosure.fec_fitem_sched_b_2019_2020 USING btree (disb_dt DESC NULLS FIRST, sub_id DESC NULLS FIRST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
