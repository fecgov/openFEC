/*
This is for issue #5134:
Adding two new columns to real_efile.F1 and real_pfile.F1 tables in Aurora postgresql databases

ALTER TABLE real_efile.F1 ADD COLUMN super_pac_lobbyist varchar(1), add column hybrid_pac_lobbyist varchar(1);
ALTER TABLE real_pfile.F1 ADD COLUMN super_pac_lobbyist varchar(1), add column hybrid_pac_lobbyist varchar(1);

The columns had already been added to these tables
so contractor can insert data in all PROD/STAGE/DEV databases.
However, official migration script is needed to add these to the version controlled base of the database structure.
*/

DO $$
BEGIN
    EXECUTE format('ALTER TABLE real_efile.F1 ADD COLUMN super_pac_lobbyist varchar(1), add column hybrid_pac_lobbyist varchar(1)');
    EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

DO $$
BEGIN
    EXECUTE format('ALTER TABLE real_pfile.F1 ADD COLUMN super_pac_lobbyist varchar(1), add column hybrid_pac_lobbyist varchar(1)');
    EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;
      
