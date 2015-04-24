DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_roles
      WHERE  rolname = 'webro') THEN

      CREATE ROLE webro;
   END IF;
END
$body$
;

alter default privileges in schema public
    grant select on tables to webro;
