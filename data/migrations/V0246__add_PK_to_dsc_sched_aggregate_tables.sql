/*
This is for issue #5110:

In addition to having unique value, all columns that made up the primary key requires can not be null).  Therefore a value need to used to represent null value.

dsc_sched_a_aggregate_employer
when is null, or upper (employer) = 'NULL', use 'NULL'

dsc_sched_a_aggregate_occupation
when is null, or upper (occupation) = 'NULL', use 'NULL'

dsc_sched_a_aggregate_size
size is a pre-determined value, no row is null

dsc_sched_a_aggregate_state
when is null, or ' ' or ' ' use ' '

dsc_sched_a_aggregate_zip
when is null, or upper (zip) = 'NULL', use 'NULL'

dsc_sched_b_aggregate_purpose_new
purpose is a pre-determined value, no row is null

dsc_sched_b_aggregate_recipient_id_new
already exclude rows with recipient_cmte_id is null, no need to handle null value.

dsc_sched_b_aggregate_recipient_new
when is null, or upper (recipient_nm) = 'NULL', use 'NULL'

The data update and primary key creation had already been performed to these tables in order to make DMS working in all PROD/STAGE/DEV databases.
However, official migration script is needed to add these to the version controlled base of the database structure.

-- -----------------------------------------------------
-- To verify the creation/existance of the primary key of the 'dsc_sched%_aggregate%' tables:

select tablename, indexname from pg_indexes
where schemaname = 'disclosure'
and tablename like 'dsc_sched%_aggregate%'
and indexname like '%pkey' order by 1, 2;

dsc_sched_a_aggregate_employer  dsc_sched_a_aggregate_employer_pkey
dsc_sched_a_aggregate_occupation    dsc_sched_a_aggregate_occupation_pkey
dsc_sched_a_aggregate_size  dsc_sched_a_aggregate_size_pkey
dsc_sched_a_aggregate_state dsc_sched_a_aggregate_state_pkey
dsc_sched_a_aggregate_zip   dsc_sched_a_aggregate_zip_pkey
dsc_sched_b_aggregate_purpose_new   dsc_sched_b_aggregate_purpose_new_pkey
dsc_sched_b_aggregate_recipient_id_new  dsc_sched_b_agg_recpnt_id_new_pkey
dsc_sched_b_aggregate_recipient_new dsc_sched_b_agg_recpnt_new_pkey

*/


-- -----------------------------------
-- dsc_sched_a_aggregate_employer
-- -----------------------------------
-- employer column with no value (null) had been updated to 'NULL'
update disclosure.dsc_sched_a_aggregate_employer set employer = 'NULL' where employer is null;

alter table disclosure.dsc_sched_a_aggregate_employer alter column employer set default 'NULL';

alter table disclosure.dsc_sched_a_aggregate_employer alter column employer set NOT NULL;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_employer add constraint dsc_sched_a_aggregate_employer_pkey primary key (cmte_id, cycle, employer);');
  
    EXCEPTION 
             WHEN invalid_table_definition THEN 
				null;
				--RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_employer drop constraint uq_sched_a_aggregate_employer_cmte_id_cycle_employer;');
  
    EXCEPTION 
             WHEN undefined_object THEN 
				null;
				--RAISE NOTICE 'undefined_object';
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
	


-- -----------------------------------
-- dsc_sched_a_aggregate_occupation
-- -----------------------------------

-- occupation column with no value (null) had been updated to 'NULL'
update disclosure.dsc_sched_a_aggregate_occupation set occupation = 'NULL' where occupation is null;

alter table disclosure.dsc_sched_a_aggregate_occupation alter column occupation set default 'NULL';

alter table disclosure.dsc_sched_a_aggregate_occupation alter column occupation set NOT NULL;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_occupation add constraint dsc_sched_a_aggregate_occupation_pkey primary key (cmte_id, cycle, occupation);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_occupation drop constraint uq_sched_a_aggregate_occupation_cmte_id_cycle_occupation;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
	

-- -----------------------------------
-- dsc_sched_a_aggregate_size
-- -----------------------------------

-- size is a pre-determined value, no row is null


alter table disclosure.dsc_sched_a_aggregate_size alter column size set NOT NULL;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_size add constraint dsc_sched_a_aggregate_size_pkey primary key (cmte_id, cycle, size);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;

             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_size drop constraint uq_dsc_sched_a_aggregate_size_cmte_id_cycle_size;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


-- -----------------------------------
-- dsc_sched_a_aggregate_state
-- -----------------------------------

-- state column's data type is varchar(2), can not use string 'NULL'
-- state column with no value (null) had been updated to '  '
update disclosure.dsc_sched_a_aggregate_state set state = '  ' where state is null;

alter table disclosure.dsc_sched_a_aggregate_state alter column state set default '  ';

alter table disclosure.dsc_sched_a_aggregate_state alter column state set NOT NULL;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_state add constraint dsc_sched_a_aggregate_state_pkey primary key (cmte_id, cycle, state);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_state drop constraint uq_dsc_sched_a_aggregate_state_cmte_id_cycle_state;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
	

-- -----------------------------------
-- dsc_sched_a_aggregate_zip
-- -----------------------------------

-- zip column with no value (null) had been updated to 'NULL'
update disclosure.dsc_sched_a_aggregate_zip set zip = 'NULL' where zip is null;

alter table disclosure.dsc_sched_a_aggregate_zip alter column zip set default 'NULL';

alter table disclosure.dsc_sched_a_aggregate_zip alter column zip set NOT NULL;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_zip add constraint dsc_sched_a_aggregate_zip_pkey primary key (cmte_id, cycle, zip);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_a_aggregate_zip drop constraint uq_dsc_sched_a_aggregate_zip_cmte_id_cycle_zip;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


-- -----------------------------------
-- dsc_sched_b_aggregate_purpose_new
-- -----------------------------------
-- purpose is a pre-determined value, no row is null

alter table disclosure.dsc_sched_b_aggregate_purpose_new alter column purpose set NOT NULL;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_purpose_new add constraint dsc_sched_b_aggregate_purpose_new_pkey primary key (cmte_id, cycle, purpose);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_purpose_new drop constraint uq_dsc_sched_b_agg_purpose_new_cmte_id_cycle_purpose_new;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;





-- -----------------------------------
-- dsc_sched_b_aggregate_recipient_id_new
-- -----------------------------------
alter table disclosure.dsc_sched_b_aggregate_recipient_id_new alter column recipient_cmte_id set default 'NULL';

alter table disclosure.dsc_sched_b_aggregate_recipient_id_new alter column recipient_cmte_id set NOT NULL;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_recipient_id_new add constraint dsc_sched_b_agg_recpnt_id_new_pkey primary key (cmte_id, cycle, RECIPIENT_cmte_id);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_recipient_id_new drop constraint uq_sched_b_agg_recpnt_id_cmte_id_cycle_recpnt_cmte_id;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
	
-- -----------------------------------
-- dsc_sched_b_aggregate_recipient_new
-- -----------------------------------

-- RECIPIENT_NM column with no value (null) had been updated to 'NULL'
update disclosure.dsc_sched_b_aggregate_recipient_new set RECIPIENT_NM = 'NULL' where RECIPIENT_NM is null;

alter table disclosure.dsc_sched_b_aggregate_recipient_new alter column RECIPIENT_NM set default 'NULL';

alter table disclosure.dsc_sched_b_aggregate_recipient_new alter column RECIPIENT_NM set NOT NULL;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_recipient_new add constraint dsc_sched_b_agg_recpnt_new_pkey primary key (cmte_id, cycle, RECIPIENT_NM);');

    EXCEPTION
             WHEN invalid_table_definition THEN
            null;
            --RAISE NOTICE 'invalid_table_definition';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

--
DO $$
BEGIN
    EXECUTE format('alter table disclosure.dsc_sched_b_aggregate_recipient_new drop constraint uq_dsc_sched_b_agg_recpnt_new_cmte_id_cycle_recpnt_new;');

    EXCEPTION
             WHEN undefined_object THEN
            null;
            --RAISE NOTICE 'undefined_object';
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
	
