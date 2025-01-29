/*
This is for issue #6100
The tables were already created so we will not miss any incoming data.
However, official migration script is need to add these to the version controlled base of the database structure.
*/
-- -----------------------------------------------------
-- create table disclosure.fec_fitem_sched_a_2025_2026
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE TABLE disclosure.fec_fitem_sched_a_2025_2026
(
  CONSTRAINT fec_fitem_sched_a_2025_2026_pkey PRIMARY KEY (sub_id),
  CONSTRAINT check_two_year_transaction_period CHECK (two_year_transaction_period = ANY (ARRAY[2025, 2026]::numeric[]))
)
INHERITS (disclosure.fec_fitem_sched_a)
WITH (
  OIDS=FALSE
)');
    EXCEPTION
             WHEN duplicate_table THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


DO $$
BEGIN
    EXECUTE format('CREATE TRIGGER tri_fec_fitem_sched_a_2025_2026
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2025_2026
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert()');
    EXCEPTION
             WHEN duplicate_object THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;



ALTER TABLE disclosure.fec_fitem_sched_a_2025_2026
  OWNER TO fec;
GRANT ALL ON TABLE disclosure.fec_fitem_sched_a_2025_2026 TO fec;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_a_2025_2026 TO fec_read;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_a_2025_2026 TO openfec_read;



-- -----------------------------------------------------
-- create table disclosure.fec_fitem_sched_b_2025_2026
-- -----------------------------------------------------
DO $$
BEGIN
        EXECUTE format('CREATE TABLE disclosure.fec_fitem_sched_b_2025_2026
(
  CONSTRAINT fec_fitem_sched_b_2025_2026_pkey PRIMARY KEY (sub_id),
  CONSTRAINT check_two_year_transaction_period CHECK (two_year_transaction_period = ANY (ARRAY[2025, 2026]::numeric[]))
)
INHERITS (disclosure.fec_fitem_sched_b)
WITH (
  OIDS=FALSE
)');
    EXCEPTION
             WHEN duplicate_table THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

DO $$
BEGIN
    EXECUTE format('CREATE TRIGGER tri_fec_fitem_sched_b_2025_2026
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2025_2026
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert()');
    EXCEPTION
             WHEN duplicate_object THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;



ALTER TABLE disclosure.fec_fitem_sched_b_2025_2026
  OWNER TO fec;
GRANT ALL ON TABLE disclosure.fec_fitem_sched_b_2025_2026 TO fec;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_b_2025_2026 TO fec_read;
GRANT SELECT ON TABLE disclosure.fec_fitem_sched_b_2025_2026 TO openfec_read;


-- -----------------------------------------------------
-- Add indexes to disclosure.fec_fitem_sched_a_2025_2026
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('select disclosure.finalize_itemized_schedule_a_tables (2026, 2026)');


        EXCEPTION
             WHEN duplicate_table THEN
        null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

-- -----------------------------------------------------
-- Add indexes to disclosure.fec_fitem_sched_b_2025_2026
-- -----------------------------------------------------
DO $$
BEGIN
    EXECUTE format('select disclosure.finalize_itemized_schedule_b_tables (2026, 2026)');


        EXCEPTION
             WHEN duplicate_table THEN
        null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


/*
select substring(indexname, 23)
from pg_indexes
where tablename like 'fec_fitem_sched_a_2023_2024'
except
select substring(indexname, 23)
from pg_indexes
where tablename like 'fec_fitem_sched_a_2025_2026'
order by 1

select substring(indexname, 23)
from pg_indexes
where tablename like 'fec_fitem_sched_b_2023_2024'
except
select substring(indexname, 23)
from pg_indexes
where tablename like 'fec_fitem_sched_b_2025_2026'
order by 1
*/