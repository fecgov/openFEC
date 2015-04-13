DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = 'webro') THEN

      CREATE ROLE webro;
   END IF;
END
$body$
;

alter default privileges in schema public
    grant select on tables to webro;
