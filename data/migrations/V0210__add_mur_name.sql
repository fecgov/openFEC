-- ------------------------------------------
-- mur_arch.mur_name_csv
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.mur_name_csv
(
    mur_type varchar(50),
    matter_num varchar(50),
    name varchar(400),
    budget_category varchar(100)
)
WITH (OIDS = FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.mur_name_csv OWNER TO fec;
GRANT ALL ON TABLE mur_arch.mur_name_csv TO fec;
GRANT SELECT ON TABLE mur_arch.mur_name_csv TO fec_read;




-- ------------------------------------------
-- mur_arch.name
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.mur_name
(
	mur_no varchar(50),
	name varchar(400),
	mur_id integer,
	pg_date timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.mur_name OWNER TO fec;
GRANT ALL ON TABLE mur_arch.mur_name TO fec;
GRANT SELECT ON TABLE mur_arch.mur_name TO fec_read;


-- ------------------------------------------
-- mur_arch.mur_arch_xml
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE mur_arch.mur_arch_xml
(
    case_number varchar(20),
    open_date varchar(20) ,
    close_date varchar(20),
    code varchar(40) ,
    name varchar(100) ,
    subject varchar(400) ,
    cite varchar(40) ,
    pdf_name varchar(20) ,
    size varchar(4) ,
    pg_date timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
	null;
     WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.mur_arch_xml OWNER TO fec;
GRANT ALL ON TABLE mur_arch.mur_arch_xml TO fec;
GRANT SELECT ON TABLE mur_arch.mur_arch_xml TO fec_read;
