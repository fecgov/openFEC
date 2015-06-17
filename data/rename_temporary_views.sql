-- Remove suffix from names of all materialized views (defaults to '_tmp')
-- Note: This assumes that all temporary materialized views share a suffix

CREATE OR REPLACE FUNCTION rename_temporary_views(schema_arg TEXT DEFAULT 'public', suffix TEXT DEFAULT '_tmp')
RETURNS INT AS $$
  DECLARE
    view RECORD;
    view_name TEXT;
  BEGIN
    RAISE NOTICE 'Renaming temporary materialized views in schema %', schema_arg;
    FOR view IN SELECT matviewname FROM pg_matviews WHERE schemaname = schema_arg AND matviewname LIKE '%' || suffix
    LOOP
      RAISE NOTICE 'Renaming %.%', schema_arg, view.matviewname;
      view_name := replace(view.matviewname, suffix, '');
      EXECUTE 'DROP MATERIALIZED VIEW IF EXISTS ' || schema_arg || '.' || view_name || ' CASCADE';
      EXECUTE 'ALTER MATERIALIZED VIEW ' || schema_arg || '.' || view.matviewname || ' RENAME TO ' || view_name;
    END LOOP;
    RETURN 1;
  END
$$ LANGUAGE plpgsql;

SELECT rename_temporary_views();
