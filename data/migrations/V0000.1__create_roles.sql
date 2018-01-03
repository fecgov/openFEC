-- Create the roles needed in the DB if they do not already exist
-- Unfortunately, Postgres lacks a "CREATE ROLE IF NOT EXISTS ..."

DO
$body$
DECLARE
    v_role text;
    k_roles text[] = '{
        "aomur_usr",
         "fec",
         "fec_read",
         "openfec_read",
         "real_file"
}';
BEGIN
    FOREACH v_role IN ARRAY k_roles LOOP
        IF NOT EXISTS (
                SELECT *
                FROM pg_catalog.pg_roles
                WHERE  rolname = v_role) THEN
            EXECUTE FORMAT('CREATE ROLE %s', v_role);
        END IF;
    END LOOP;
END
$body$;
