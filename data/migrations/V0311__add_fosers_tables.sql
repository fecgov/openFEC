--
-- Name: fosers; Type: SCHEMA; Schema: -; Owner: fec
--

CREATE SCHEMA IF NOT EXISTS fosers;

ALTER SCHEMA fosers OWNER TO fec;

GRANT ALL ON SCHEMA fosers TO public;

SET search_path = fosers, pg_catalog;

-- Create fosers tables
CREATE TABLE IF NOT EXISTS calendar
(
    id integer NOT NULL,
    rm_id integer,
    event_name character varying(4000),
    eventdt date,
    event_key integer,
    sync_status character varying(20),
    CONSTRAINT calendar_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS calendar OWNER to fec;

REVOKE ALL ON TABLE calendar FROM fec_read;

GRANT ALL ON TABLE calendar TO fec;

GRANT SELECT ON TABLE calendar TO fec_read;

----
CREATE TABLE IF NOT EXISTS cfr_index_refresh_log
(
    id integer NOT NULL,
    rm_number character varying(32),
    published_on timestamp without time zone,
    index_synced timestamp without time zone,
    CONSTRAINT cfr_index_refresh_log_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS cfr_index_refresh_log OWNER to fec;

REVOKE ALL ON TABLE cfr_index_refresh_log FROM fec_read;

GRANT ALL ON TABLE cfr_index_refresh_log TO fec;

GRANT SELECT ON TABLE cfr_index_refresh_log TO fec_read;

----
CREATE TABLE IF NOT EXISTS cfrdocuments
(
    id integer NOT NULL,
    rm_id integer,
    filename character varying(255),
    category integer,
    description character varying(4000),
    contents bytea,
    date1 date,
    is_key_document integer,
    type_id integer,
    sync_status character varying(20),
    CONSTRAINT cfrdocuments_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS cfrdocuments OWNER to fec;

REVOKE ALL ON TABLE cfrdocuments FROM fec_read;

GRANT ALL ON TABLE cfrdocuments TO fec;

GRANT SELECT ON TABLE cfrdocuments TO fec_read;

----
CREATE TABLE IF NOT EXISTS citations
(
    id integer NOT NULL,
    rm_id integer,
    statutory_cite character varying(255),
    regulatory_cite character varying(255),
    sync_status character varying(20),
    CONSTRAINT citations_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS citations OWNER to fec;

REVOKE ALL ON TABLE citations FROM fec_read;

GRANT ALL ON TABLE citations TO fec;

GRANT SELECT ON TABLE citations TO fec_read;

----
CREATE TABLE IF NOT EXISTS commissioners
(
    id integer NOT NULL,
    vote_id integer NOT NULL,
    name character varying(255),
    vote character varying(25),
    sync_status character varying(20),
    CONSTRAINT commissioners_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS commissioners OWNER to fec;

REVOKE ALL ON TABLE commissioners FROM fec_read;

GRANT ALL ON TABLE commissioners TO fec;

GRANT SELECT ON TABLE commissioners TO fec_read;

----
CREATE TABLE IF NOT EXISTS documentplayers
(
    rm_id integer NOT NULL,
    participant_id integer NOT NULL,
    document_id integer NOT NULL,
    sync_status character varying(20),
    CONSTRAINT documentplayers_pkey PRIMARY KEY (sync_status, document_id, participant_id, rm_id)
);

ALTER TABLE IF EXISTS documentplayers OWNER to fec;

REVOKE ALL ON TABLE documentplayers FROM fec_read;

GRANT ALL ON TABLE documentplayers TO fec;

GRANT SELECT ON TABLE documentplayers TO fec_read;

---
CREATE TABLE IF NOT EXISTS documents
(
    id integer NOT NULL,
    rm_id integer,
    filename character varying(255),
    category integer,
    description character varying(4000),
    contents bytea,
    date1 date,
    is_key_document integer,
    type_id integer,
    sync_status character varying(20),
    sort_order integer,
    CONSTRAINT documents_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS documents OWNER to fec;

REVOKE ALL ON TABLE documents FROM fec_read;

GRANT ALL ON TABLE documents TO fec;

GRANT SELECT ON TABLE documents TO fec_read;

----
CREATE TABLE IF NOT EXISTS documents_ocrtext
(
    id integer NOT NULL,
    ocrtext text,
    CONSTRAINT documents_ocrtext_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS documents_ocrtext OWNER to fec;

REVOKE ALL ON TABLE documents_ocrtext FROM fec_read;

GRANT ALL ON TABLE documents_ocrtext TO fec;

GRANT SELECT ON TABLE documents_ocrtext TO fec_read;

----
CREATE TABLE IF NOT EXISTS filtertab
(
    query_id integer NOT NULL,
    document text,
    CONSTRAINT filtertab_pkey PRIMARY KEY (query_id)
);

ALTER TABLE IF EXISTS filtertab OWNER to fec;

REVOKE ALL ON TABLE filtertab FROM fec_read;

GRANT ALL ON TABLE filtertab TO fec;

GRANT SELECT ON TABLE filtertab TO fec_read;

-----
CREATE TABLE IF NOT EXISTS index_refresh_log
(
    id integer NOT NULL,
    rm_number character varying(32),
    published_on timestamp without time zone,
    index_synced timestamp without time zone,
    CONSTRAINT index_refresh_log_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS index_refresh_log OWNER to fec;

REVOKE ALL ON TABLE index_refresh_log FROM fec_read;

GRANT ALL ON TABLE index_refresh_log TO fec;

GRANT SELECT ON TABLE index_refresh_log TO fec_read;

-----
CREATE TABLE IF NOT EXISTS markuptab
(
    query_id integer NOT NULL,
    document text,
    doc_id integer NOT NULL DEFAULT 0,
    display_text character varying(1650),
    CONSTRAINT markuptab_pkey PRIMARY KEY (query_id, doc_id)
);

ALTER TABLE IF EXISTS markuptab OWNER to fec;

REVOKE ALL ON TABLE markuptab FROM fec_read;

GRANT ALL ON TABLE markuptab TO fec;

GRANT SELECT ON TABLE markuptab TO fec_read;

------
CREATE TABLE IF NOT EXISTS participants
(
    id integer NOT NULL,
    rm_id integer,
    name character varying(255),
    role character varying(255),
    sync_status character varying(20),
    CONSTRAINT participants_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS participants OWNER to fec;

REVOKE ALL ON TABLE participants FROM fec_read;

GRANT ALL ON TABLE participants TO fec;

GRANT SELECT ON TABLE participants TO fec_read;

-----
CREATE TABLE IF NOT EXISTS rulemaster
(
    id integer NOT NULL,
    rm_number character varying(32),
    title character varying(255),
    description character varying(4000),
    comment_open_date date,
    comment_close_date timestamp without time zone,
    sync_status character varying(20),
    last_updated timestamp without time zone,
    admin_close_date timestamp without time zone,
    CONSTRAINT rulemaster_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS rulemaster OWNER to fec;

REVOKE ALL ON TABLE rulemaster FROM fec_read;

GRANT ALL ON TABLE rulemaster TO fec;

GRANT SELECT ON TABLE rulemaster TO fec_read;

-----
CREATE TABLE IF NOT EXISTS temp_doc
(
    id integer NOT NULL,
    rm_id integer,
    filename character varying(255),
    category integer,
    description character varying(4000),
    contents bytea,
    date1 date,
    is_key_document integer,
    type_id integer,
    sync_status character varying(20),
    sort_order integer,
    CONSTRAINT temp_doc_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS temp_doc OWNER to fec;

REVOKE ALL ON TABLE temp_doc FROM fec_read;

GRANT ALL ON TABLE temp_doc TO fec;

GRANT SELECT ON TABLE temp_doc TO fec_read;

------
CREATE TABLE IF NOT EXISTS temp_ocrtext
(
    query_id integer NOT NULL,
    document text,
    case_id integer,
    CONSTRAINT temp_ocrtext_pkey PRIMARY KEY (query_id)
);

ALTER TABLE IF EXISTS temp_ocrtext OWNER to fec;

REVOKE ALL ON TABLE temp_ocrtext FROM fec_read;

GRANT ALL ON TABLE temp_ocrtext TO fec;

GRANT SELECT ON TABLE temp_ocrtext TO fec_read;

------
CREATE TABLE IF NOT EXISTS tiermapping
(
    level1 integer NOT NULL,
    level2 integer NOT NULL,
    type_id integer NOT NULL,
    description character varying(255),
    CONSTRAINT tiermapping_pkey PRIMARY KEY (type_id, level2, level1)
);

ALTER TABLE IF EXISTS tiermapping OWNER to fec;

REVOKE ALL ON TABLE tiermapping FROM fec_read;

GRANT ALL ON TABLE tiermapping TO fec;

GRANT SELECT ON TABLE tiermapping TO fec_read;

------
CREATE TABLE IF NOT EXISTS votes
(
    id integer NOT NULL,
    rm_id integer NOT NULL,
    agenda character varying(4000),
    agenda_date timestamp without time zone,
    vote_date timestamp without time zone,
    sync_status character varying(20),
    CONSTRAINT votes_pkey PRIMARY KEY (id)
);

ALTER TABLE IF EXISTS votes OWNER to fec;

REVOKE ALL ON TABLE votes FROM fec_read;

GRANT ALL ON TABLE votes TO fec;

GRANT SELECT ON TABLE votes TO fec_read;
