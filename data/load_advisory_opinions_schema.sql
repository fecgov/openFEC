CREATE SCHEMA aouser;




SET search_path = aouser, pg_catalog;

--
-- Name: ao; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE ao (
    ao_id integer NOT NULL,
    name character varying(120),
    req_date date,
    issue_date date,
    tags character varying(5),
    summary character varying(4000),
    stage numeric(1,0),
    status_is_new character(1),
    ao_no character varying(9),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: document; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE document (
    document_id integer NOT NULL,
    filename character varying(255),
    category character varying(255),
    document_date timestamp without time zone,
    fileimage bytea,
    ocrtext text,
    ao_id integer,
    description character varying(255),
    doc_order_id integer,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: entity; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE entity (
    entity_id integer NOT NULL,
    first_name character varying(30),
    last_name character varying(30),
    middle_name character varying(30),
    prefix character varying(10),
    suffix character varying(10),
    name character varying(90),
    type integer,
    type2 integer,
    type3 integer,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: entity_type; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE entity_type (
    entity_type_id integer NOT NULL,
    description character varying(255),
    flags character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);


-- Name: players; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE players (
    player_id integer NOT NULL,
    ao_id integer,
    role_id integer,
    entity_id integer,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: ao_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY ao
    ADD CONSTRAINT ao_pkey PRIMARY KEY (ao_id);

--
-- Name: document_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (document_id);


--
-- Name: entity_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);


--
-- Name: entity_type_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY entity_type
    ADD CONSTRAINT entity_type_pkey PRIMARY KEY (entity_type_id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: aouser; Owner: fec
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- Name: aos_with_parsed_numbers; Type: VIEW; Schema: aouser; Owner: fec
--
CREATE VIEW aos_with_parsed_numbers
AS
    SELECT
        ao_id,
        ao_no,
        regexp_replace(ao_no, '(\d+)-(\d+)', '\1')::int AS ao_year,
        regexp_replace(ao_no, '(\d+)-(\d+)', '\2')::int AS ao_serial,
        name,
        summary,
        req_date,
        issue_date
    FROM aouser.ao;
--
-- Data for Name: entity_type; Type: TABLE DATA; Schema: aouser; Owner: fec
--

INSERT INTO entity_type VALUES (0, NULL, NULL, '2017-01-04 17:18:57.682');
INSERT INTO entity_type VALUES (1, 'Federal candidate/candidate committee/officeholder', NULL, '2017-01-04 17:18:57.691');
INSERT INTO entity_type VALUES (2, 'Publicly funded candidates/committees', NULL, '2017-01-04 17:18:57.698');
INSERT INTO entity_type VALUES (3, 'Party committee, national', NULL, '2017-01-04 17:18:57.705');
INSERT INTO entity_type VALUES (4, 'Party committee, state or local', NULL, '2017-01-04 17:18:57.712');
INSERT INTO entity_type VALUES (5, 'Nonconnected political committee', NULL, '2017-01-04 17:18:57.72');
INSERT INTO entity_type VALUES (6, 'Separate segregated fund', NULL, '2017-01-04 17:18:57.729');
INSERT INTO entity_type VALUES (7, 'Labor Organization', NULL, '2017-01-04 17:18:57.736');
INSERT INTO entity_type VALUES (8, 'Trade Association', NULL, '2017-01-04 17:18:57.742');
INSERT INTO entity_type VALUES (9, 'Membership Organization, Cooperative, Corporation W/O Capital Stock', NULL, '2017-01-04 17:18:57.75');
INSERT INTO entity_type VALUES (10, 'Corporation (including LLCs electing corporate status)', NULL, '2017-01-04 17:18:57.759');
INSERT INTO entity_type VALUES (11, 'Partnership (including LLCs electing partnership status)', NULL, '2017-01-04 17:18:57.766');
INSERT INTO entity_type VALUES (12, 'Governmental entity', NULL, '2017-01-04 17:18:57.773');
INSERT INTO entity_type VALUES (13, 'Research/Public Interest/Educational Institution', NULL, '2017-01-04 17:18:57.78');
INSERT INTO entity_type VALUES (14, 'Law Firm', NULL, '2017-01-04 17:18:57.786');
INSERT INTO entity_type VALUES (15, 'Individual', NULL, '2017-01-04 17:18:57.793');
INSERT INTO entity_type VALUES (16, 'Other', NULL, '2017-01-04 17:18:57.8');
