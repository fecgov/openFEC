/*
This is for issue #6784
The tables were already modified so we will not miss any incoming data.
However, official migration script is need to add these to the version controlled base of the database structure.
*/

DO $$
BEGIN
    EXECUTE format('alter table real_efile.reps 
	ADD COLUMN EXCLUDE_IND  varchar(1),
	ADD COLUMN NOTES varchar(100),
	ADD COLUMN REP_CREATE_DATE  timestamp');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


