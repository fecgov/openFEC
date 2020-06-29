/*
This migration file supports issue #4369
In order to add new index for performance (outage), is_individual_contbr_city_state index added.
*/

-- -----------------------------------------------
-- idx_sched_a_<startYr_endYr>_is_individual_contbr_city_state 
-- -----------------------------------------------
-- 1975_1976
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1975_1976_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1975_1976 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1977_1978
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1977_1978_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1977_1978 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1979_1980
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1979_1980_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1979_1980 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1981_1982
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1981_1982_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1981_1982 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1983_1984
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1983_1984_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1983_1984 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1985_1986
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1985_1986_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1985_1986 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1987_1988
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1987_1988_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1987_1988 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1989_1990
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1989_1990_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1989_1990 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1991_1992
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1991_1992_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1991_1992 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1993_1994
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1993_1994_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1993_1994 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1995_1996
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1995_1996_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1995_1996 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1997_1998
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1997_1998_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1997_1998 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 1999_2000
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_1999_2000_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_1999_2000 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2001_2002
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2001_2002_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2001_2002 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2003_2004
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2003_2004_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2003_2004 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2005_2006
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2005_2006_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2005_2006 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2007_2008
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2007_2008_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2007_2008 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2009_2010
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2009_2010_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2009_2010 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2011_2012
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2011_2012_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2011_2012 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2013_2014
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2013_2014_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2013_2014 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2015_2016
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2015_2016_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2015_2016 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2017_2018
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2017_2018_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2017_2018 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
-- 2019_2020
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_sched_a_2019_2020_is_individual_contbr_city_state ON disclosure.fec_fitem_sched_a_2019_2020 USING btree (is_individual ASC NULLS LAST, contbr_city ASC NULLS LAST, contbr_st ASC NULLS LAST, sub_id ASC NULLS LAST);');
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

