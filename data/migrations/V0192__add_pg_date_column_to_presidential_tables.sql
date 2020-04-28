/*
Add column pg_date to presidential tables.
This column will be added to all 3 cloud environment ahead of time at the same time since
The python program that load the data 
(which is the same program, just pass in different db as parameter) 
will run to all environments

However, the migration file still submitted to keep the version control.
*/

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_a_join_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_a_join_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_link_sum_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_link_sum_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_state_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_ca_cm_sched_state_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_f3p_totals_ca_cm_link_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_f3p_totals_ca_cm_link_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_ca_cm_link_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_ca_cm_link_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_f3p_totals_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_f3p_totals_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_form_3p_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_form_3p_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_sched_a_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_sched_a_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_sched_b_16 ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE disclosure.pres_nml_sched_b_20d ADD COLUMN pg_date timestamp without time zone DEFAULT now()');
    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

DO $$
BEGIN

    EXCEPTION 
             WHEN duplicate_column THEN 
                null;
             WHEN others THEN 
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


