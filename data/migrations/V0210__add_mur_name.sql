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
	mur_name varchar(400),
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
    complainant_respondent_code varchar(40) ,
    complainant_respondent_name varchar(100) ,
    subject varchar(400) ,
    cite varchar(40) ,
    pdf_name varchar(20) ,
    pdf_size varchar(4) ,
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



-- ------------------------------------------
-- mur_arch.archived_murs
-- ------------------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE TABLE mur_arch.archived_murs AS
    WITH title AS (
        SELECT distinct cite, (regexp_matches(cite,''\d+\s''))[1]::numeric AS citation_title
          FROM mur_arch.mur_arch_xml
    )
    SELECT case_number AS mur_number, case_number::integer AS mur_id, n.mur_name AS mur_name,
           CASE WHEN open_date <> ''00/00/0000'' THEN open_date ::timestamp without time zone
                ELSE NULL
           END open_date,
           CASE WHEN close_date <> ''00/00/0000'' THEN close_date ::timestamp without time zone
                ELSE NULL
           END close_date,
           complainant_respondent_code, x.complainant_respondent_name, 
           x.cite, title.citation_title, pdf_name, pdf_size::numeric
      FROM mur_arch.mur_arch_xml x
      LEFT JOIN mur_arch.mur_name n ON (x.case_number = n.mur_no)
      LEFT JOIN title ON (x.cite = title.cite);');
EXCEPTION 
     WHEN duplicate_table THEN 
    null;
     WHEN others THEN 
    RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;
  

ALTER TABLE mur_arch.archived_murs OWNER to fec;
    
GRANT ALL ON TABLE mur_arch.archived_murs TO fec;

GRANT SELECT ON TABLE mur_arch.archived_murs TO fec_read;


-- Index: idx_all_murs_mur_id
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_archived_murs_mur_id ON mur_arch.archived_murs USING btree (mur_id);');       
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

-- Index: idx_all_murs_mur_number
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_archived_murs_mur_number ON mur_arch.archived_murs USING btree (mur_number);');       
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

-- ------------------------------------------
-- mur_arch.documents
-- ------------------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE TABLE mur_arch.documents
(
    mur_no varchar(20),
    pdf_text text ,
    mur_id integer,
    document_id integer,
    length integer,
    url varchar(40) 
)
WITH (OIDS=FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
    null;
     WHEN others THEN 
    RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE mur_arch.documents OWNER TO fec;
GRANT ALL ON TABLE mur_arch.documents TO fec;
GRANT SELECT ON TABLE mur_arch.documents TO fec_read;

-- Index: idx_documents_murid
DO $$
BEGIN
    EXECUTE format('CREATE INDEX idx_documents_murid ON mur_arch.documents 
    USING btree (mur_id);');       
EXCEPTION
    WHEN duplicate_table THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;



