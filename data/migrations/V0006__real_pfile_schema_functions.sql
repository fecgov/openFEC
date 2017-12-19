SET search_path = real_pfile, pg_catalog;

--
-- Name: rollback_real_time_filings(bigint); Type: FUNCTION; Schema: real_pfile; Owner: fec
--

CREATE FUNCTION rollback_real_time_filings(p_repid bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare 
 cur_del CURSOR FOR
    SELECT  table_name
       FROM information_schema.tables
       WHERE  table_schema='real_pfile';
v_table text;
begin
   OPEN cur_del;  
 loop
  fetch cur_del into v_table;
   EXIT WHEN NOT FOUND;
  -- RAISE NOTICE 'delete from % where repid= %',v_table,p_repid;
    execute 'delete from real_pfile.'||v_table ||' where repid='||p_repid;
 end loop;
close cur_del; 
return 'SUCCESS';
end
$$;


ALTER FUNCTION real_pfile.rollback_real_time_filings(p_repid bigint) OWNER TO fec;

SET search_path = public, pg_catalog;
