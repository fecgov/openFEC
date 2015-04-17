-- Refresh all materialized views; borrowed from
-- https://github.com/sorokine/RefreshAllMaterializedViews

CREATE OR REPLACE FUNCTION refresh_materialized(schema_arg TEXT DEFAULT 'public')
RETURNS INT AS $$
  DECLARE
    view RECORD;
  BEGIN
    RAISE NOTICE 'Refreshing materialized view in schema %', schema_arg;
    FOR view IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg
    LOOP
      RAISE NOTICE 'Refreshing %.%', schema_arg, view.matviewname;
      EXECUTE 'REFRESH MATERIALIZED VIEW ' || schema_arg || '.' || view.matviewname;
    END LOOP;
    RETURN 1;
  END
$$ LANGUAGE plpgsql;

SELECT refresh_materialized();
