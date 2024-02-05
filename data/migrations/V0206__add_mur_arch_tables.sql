-- ------------------------------------------
-- create schema mur_arch
-- ------------------------------------------
CREATE SCHEMA IF NOT EXISTS mur_arch
  AUTHORIZATION fec;

GRANT ALL ON SCHEMA mur_arch TO fec;
GRANT ALL ON SCHEMA mur_arch TO public;


-- ------------------------------------------
-- mur_arch.cite
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.cite
(
 title	varchar(20)	
 ,cite	varchar(40)	
 ,abbr	varchar(40)	
 ,year_of_cite	varchar(4)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,cite_id	varchar(5)	
 ,code	varchar(4)	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.cite OWNER TO fec;
GRANT ALL ON TABLE mur_arch.cite TO fec;
GRANT SELECT ON TABLE mur_arch.cite TO fec_read;


-- ------------------------------------------
-- mur_arch.mursub
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.mursub
(
 mur	varchar(8)	
 ,sub_id	varchar(8)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.mursub OWNER TO fec;
GRANT ALL ON TABLE mur_arch.mursub TO fec;
GRANT SELECT ON TABLE mur_arch.mursub TO fec_read;


-- ------------------------------------------
-- mur_arch.murrel
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murrel
(
 mur	varchar(5)	
 ,related_mur	varchar(5)	
 ,doe	timestamp	
 ,user_of_entry	varchar(20)	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murrel OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murrel TO fec;
GRANT SELECT ON TABLE mur_arch.murrel TO fec_read;

-- ------------------------------------------
-- mur_arch.murmst_bad
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murmst_bad
(
 mur	varchar(5)	
 ,code	varchar(4)	
 ,doe	timestamp	
 ,date_opened	timestamp	
 ,date_closed	timestamp	
 ,public_rec_dt	timestamp	
 ,in_proc	varchar(4)	
 ,iid	numeric	
 ,sign_off_dt	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murmst_bad OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murmst_bad TO fec;
GRANT SELECT ON TABLE mur_arch.murmst_bad TO fec_read;

-- ------------------------------------------
-- mur_arch.murmst
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murmst
(
 mur_num	numeric	
 ,alpha_mur_num	varchar(9)	
 ,code	varchar(4)	
 ,date_of_entry	varchar(12)	
 ,date_of_change	varchar(12)	
 ,date_open	varchar(12)	
 ,date_close	varchar(12)	
 ,pub_rec_date	varchar(12)	
 ,in_proc	varchar(4)	
 ,int_of_indent	numeric	
 ,sign_off_date	varchar(12)	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murmst OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murmst TO fec;
GRANT SELECT ON TABLE mur_arch.murmst TO fec_read;

-- ------------------------------------------
-- mur_arch.murflm
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murflm
(
 mur	varchar(5)	
 ,location	varchar(15)	
 ,pages	varchar(5)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murflm OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murflm TO fec;
GRANT SELECT ON TABLE mur_arch.murflm TO fec_read;

-- ------------------------------------------
-- mur_arch.murcom
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murcom
(
 mur	varchar(5)	
 ,code	varchar(5)	
 ,entity	varchar(200)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,name_id_not_used	varchar(20)	
 ,iid_not_used	varchar(10)	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murcom OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murcom TO fec;
GRANT SELECT ON TABLE mur_arch.murcom TO fec_read;

-- ------------------------------------------
-- mur_arch.murcit
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murcit
(
 mur	varchar(5)	
 ,cite_id	varchar(5)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murcit OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murcit TO fec;
GRANT SELECT ON TABLE mur_arch.murcit TO fec_read;

-- ------------------------------------------
-- mur_arch.subjct
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.subjct
(
 level_1	varchar(5)	
 ,level_2	varchar(5)	
 ,level_3	varchar(5)	
 ,level_4	varchar(5)	
 ,subject	varchar(100)	
 ,sub_iid	numeric	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.subjct OWNER TO fec;
GRANT ALL ON TABLE mur_arch.subjct TO fec;
GRANT SELECT ON TABLE mur_arch.subjct TO fec_read;

-- ------------------------------------------
-- mur_arch.murao
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.murao
(
 mur	varchar(10)	
 ,ao	varchar(10)	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.murao OWNER TO fec;
GRANT ALL ON TABLE mur_arch.murao TO fec;
GRANT SELECT ON TABLE mur_arch.murao TO fec_read;


-- ------------------------------------------
-- subjct_from_file
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.subjct_from_file
(
 level_1	varchar(5)	
 ,level_2	varchar(5)	
 ,level_3	varchar(5)	
 ,level_4	varchar(5)	
 ,subject	varchar(100)	
 ,sub_iid	numeric	
 ,mur	numeric	
 ,doe	timestamp	
 ,doc	timestamp	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE mur_arch.subjct_from_file OWNER TO fec;
GRANT ALL ON TABLE mur_arch.subjct_from_file TO fec;
GRANT SELECT ON TABLE mur_arch.subjct_from_file TO fec_read;
