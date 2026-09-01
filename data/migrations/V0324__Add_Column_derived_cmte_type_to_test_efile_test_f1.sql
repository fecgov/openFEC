/*
This migration file is for ticket #6660
-- add column derived_cmte_type character varying(1) to table test_efile.test_f1;
*/

DO $$
BEGIN
    EXECUTE format('alter table test_efile.test_f1 
	ADD COLUMN derived_cmte_type varchar(1)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;