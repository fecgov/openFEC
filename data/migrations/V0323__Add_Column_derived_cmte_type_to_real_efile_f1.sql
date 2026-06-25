/*
This migration file continues for #6640
-- alter table eal_efile.f1 add column derived_cmte_type character varying(1);
*/

DO $$
BEGIN
    EXECUTE format('alter table real_efile.f1 
	ADD COLUMN derived_cmte_type varchar(1)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

