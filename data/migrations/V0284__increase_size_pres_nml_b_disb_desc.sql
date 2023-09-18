/*
This migration file solve issue #5554

Increase the size of disb_desc column in disclosure.pres_nml_sched_b_xx tables
from varchar(40) to varchar(100).

*/

DO $$
DECLARE
    execute_flg integer;
BEGIN
    execute 'SELECT count(*)
    FROM pg_attribute a
    JOIN pg_class t on a.attrelid = t.oid
    JOIN pg_namespace s on t.relnamespace = s.oid
    WHERE a.attnum > 0 
    AND NOT a.attisdropped
    and relname like ''pres_nml_sched_b%''
    and a.attname = ''disb_desc''
    and pg_catalog.format_type(a.atttypid, a.atttypmod) = ''character varying(40)''
    and s.nspname = ''disclosure'''
    into execute_flg;
    

    if execute_flg = 5 then
    
	    alter table disclosure.pres_nml_sched_b_08d 
		alter column disb_desc type varchar(100);

	    alter table disclosure.pres_nml_sched_b_12d
		alter column disb_desc type varchar(100);

	    alter table disclosure.pres_nml_sched_b_16 
		alter column disb_desc type varchar(100);

	    alter table disclosure.pres_nml_sched_b_20d 
		alter column disb_desc type varchar(100);

	    alter table disclosure.pres_nml_sched_b_24d 
		alter column disb_desc type varchar(100);
    
    else
	    null;
    end if;

EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


/*
	SELECT relname as table_name, a.attname as column_name, format_type(a.atttypid, a.atttypmod) as data_type
		FROM pg_attribute a
		JOIN pg_class t on a.attrelid = t.oid
		JOIN pg_namespace s on t.relnamespace = s.oid
		WHERE a.attnum > 0 
		AND NOT a.attisdropped
		and relname like 'pres_nml_sched_b%'
		and a.attname = 'disb_desc'
		and s.nspname = 'disclosure'
	order by relname;
		
*/
