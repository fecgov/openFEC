/*
Issue #4586

Migration file to create cand_cmte_linkage_alternate, leadership_pac_cand_cmte_link 
*/

-- ------------------------------------------
-- disclosure.cand_cmte_linkage_alternate
-- ------------------------------------------
DO $$
BEGIN
	EXECUTE format('CREATE TABLE disclosure.cand_cmte_linkage_alternate
(
    sub_id             numeric(19,0) NOT NULL,
    cand_id            varchar(9) NOT NULL,
    cand_election_yr   numeric(4,0) NOT NULL,
    fec_election_yr    numeric(4,0) NOT NULL,
    cmte_id            varchar(9),
    cmte_tp            varchar(1),
    cmte_dsgn          varchar(1),
    linkage_type       varchar(1) ,
    cmte_count_cand_yr numeric(2,0),
    efile_paper_ind    varchar(1),
    created_by         numeric(12,0)                    DEFAULT  1,
    created_date       timestamp without time zone      DEFAULT now(),
    updated_by         numeric(12,0)                    DEFAULT  1,
    updated_date       timestamp without time zone      DEFAULT now(),
    pg_date            timestamp without time zone      DEFAULT now(),
    CONSTRAINT cand_cmte_linkage_alternate_pkey PRIMARY KEY (sub_id)
)
WITH (OIDS = FALSE);');
EXCEPTION 
    WHEN duplicate_table THEN 
	null;
    WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.cand_cmte_linkage_alternate OWNER TO fec;
GRANT ALL ON TABLE disclosure.cand_cmte_linkage_alternate TO fec;
GRANT SELECT ON TABLE disclosure.cand_cmte_linkage_alternate TO fec_read;

--------------------------------------------------------------
--create view DISCLOSURE.LEADERSHIP_PAC_CAND_CMTE_LINK
--------------------------------------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE OR REPLACE VIEW disclosure.leadership_pac_cand_cmte_link 
    AS
    SELECT sub_id,
           cand_id,
           cand_election_yr,
           fec_election_yr,
           cmte_id,
           cmte_tp,
           cmte_dsgn,
           linkage_type,
           cmte_count_cand_yr,
           efile_paper_ind,
           created_by,
           created_date,
           updated_by,
           updated_date
    FROM disclosure.cand_cmte_linkage_alternate
    WHERE linkage_type = ''D'';'
    );
EXCEPTION 
    WHEN duplicate_table THEN 
    null;
    WHEN others THEN 
    RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

ALTER TABLE disclosure.leadership_pac_cand_cmte_link  OWNER TO fec;
GRANT ALL ON TABLE disclosure.leadership_pac_cand_cmte_link  TO fec;
GRANT SELECT ON TABLE disclosure.leadership_pac_cand_cmte_link  TO fec_read;
 
--------------------------------------------------------------
-- rename cloumn name in mur_arch.archived_murs
-- addon for mur_arch database work
--------------------------------------------------------------
DO $$
BEGIN
    EXECUTE format('ALTER TABLE mur_arch.archived_murs RENAME COLUMN cite TO citation');       
EXCEPTION
    WHEN undefined_column THEN
        null;
    WHEN others THEN
        RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


-------------------------------------------
-- create table mur_arch.documents_es_raw
-------------------------------------------
DO $$
BEGIN
    EXECUTE format('CREATE TABLE mur_arch.documents_es_raw
( 
    mur_no varchar(10),
    pdf_text text ,
    mur_id integer,
    document_id integer,
    length integer,
    url varchar(40) 
)
WITH (OIDS = FALSE);');
EXCEPTION 
     WHEN duplicate_table THEN 
    null;
     WHEN others THEN 
    RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;

