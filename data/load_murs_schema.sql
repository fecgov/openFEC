--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fecmur; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA fecmur;


SET search_path = fecmur, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: af_case; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE af_case (
    case_id bigint NOT NULL,
    af_number_rad numeric,
    case_number character varying(30),
    committee_id character varying(30),
    report_year character varying(4),
    report_type character varying(6),
    rtb_action_date timestamp without time zone,
    rtb_fine_amount numeric,
    chal_receipt_date timestamp without time zone,
    chal_outcome_code_desc character varying(100),
    fd_date timestamp without time zone,
    fd_final_fine_amount numeric,
    check_amount numeric,
    treasury_date timestamp without time zone,
    treasury_amount numeric,
    petition_court_filing_date timestamp without time zone,
    petition_court_decision_date timestamp without time zone,
    action_date timestamp without time zone,
    af_category character varying(30),
    title character varying(1800),
    meeting_type character varying(100),
    action character varying(1800),
    vote_result character varying(10),
    commissioner_1 character varying(50),
    commissioner_1_vote character varying(20),
    commissioner_2 character varying(50),
    commissioner_2_vote character varying(20),
    commissioner_3 character varying(50),
    commissioner_3_vote character varying(20),
    commissioner_4 character varying(50),
    commissioner_4_vote character varying(20),
    commissioner_5 character varying(50),
    commissioner_5_vote character varying(20),
    commissioner_6 character varying(50),
    commissioner_6_vote character varying(20),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: calendar; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE calendar (
    entity_id bigint,
    event_date timestamp without time zone,
    event_id bigint,
    case_id bigint
);


--
-- Name: case; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE "case" (
    case_id bigint NOT NULL,
    case_no character varying(255),
    name character varying(255),
    case_type character varying(50),
    sol_earliest timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: case_subject; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE case_subject (
    case_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    relatedsubject_id bigint NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: commission; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE commission (
    commission_id bigint NOT NULL,
    agenda_date timestamp without time zone,
    vote_date timestamp without time zone,
    action text,
    case_id bigint NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: doc_order; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE doc_order (
    doc_order_id bigint NOT NULL,
    category character varying(255),
    case_type character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: document; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE document (
    document_id bigint NOT NULL,
    case_id bigint,
    filename character varying(255),
    category character varying(255),
    document_date timestamp without time zone,
    fileimage bytea,
    ocrtext text,
    description text,
    doc_order_id bigint,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: electioncycle; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE electioncycle (
    case_id bigint,
    election_cycle numeric NOT NULL,
    election_cycle_type character varying(50)
);


--
-- Name: entity; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE entity (
    entity_id bigint NOT NULL,
    first_name character varying(30),
    last_name character varying(255),
    middle_name character varying(30),
    prefix character varying(20),
    suffix character varying(20),
    type character varying(80),
    name character varying(255) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: event; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE event (
    event_id numeric(10,0) NOT NULL,
    parent_event numeric(10,0) NOT NULL,
    event_name character varying(500) NOT NULL,
    path character varying(500),
    is_key_date character(1),
    check_primary_respondent character(1),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: milind; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE milind (
    case_id bigint NOT NULL,
    case_no numeric NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: non_monetary_term; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE non_monetary_term (
    term_id bigint NOT NULL,
    term_description character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: players; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE players (
    player_id bigint NOT NULL,
    entity_id bigint,
    case_id bigint,
    role_id bigint,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: relatedobjects; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE relatedobjects (
    master_key bigint,
    detail_key bigint,
    relation_id bigint
);


--
-- Name: relatedsubject; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE relatedsubject (
    subject_id bigint NOT NULL,
    relatedsubject_id bigint NOT NULL,
    description character varying(200),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: relationtype; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE relationtype (
    relation_id bigint NOT NULL,
    description character varying(255),
    master_key_type character varying(255),
    detail_key_type character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: role; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE role (
    role_id numeric(10,0) NOT NULL,
    description character varying(255) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: settlement; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE settlement (
    settlement_id bigint NOT NULL,
    case_id bigint,
    initial_amount numeric(11,2),
    final_amount numeric(11,2),
    amount_received numeric(11,2),
    settlement_type character varying(50),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: stage_order; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE stage_order (
    stage_order_id bigint NOT NULL,
    stage character varying(50),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: subject; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE subject (
    subject_id bigint NOT NULL,
    description character varying(200),
    pg_date timestamp without time zone DEFAULT now()
);


--
-- Name: violations; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE violations (
    case_id bigint,
    entity_id bigint,
    stage character varying(50),
    statutory_citation character varying(255),
    regulatory_citation character varying(255)
);


--
-- Name: votes; Type: TABLE; Schema: fecmur; Owner: -
--

CREATE TABLE votes (
    commission_id bigint,
    entity_id bigint,
    vote_type character varying(50),
    case_id bigint
);


--
-- Name: af_case_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY af_case
    ADD CONSTRAINT af_case_pkey PRIMARY KEY (case_id);


--
-- Name: case_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY "case"
    ADD CONSTRAINT case_pkey PRIMARY KEY (case_id);


--
-- Name: case_subject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY case_subject
    ADD CONSTRAINT case_subject_pkey PRIMARY KEY (case_id, subject_id, relatedsubject_id);


--
-- Name: commission_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY commission
    ADD CONSTRAINT commission_pkey PRIMARY KEY (commission_id, case_id);


--
-- Name: doc_order_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY doc_order
    ADD CONSTRAINT doc_order_pkey PRIMARY KEY (doc_order_id);


--
-- Name: document_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (document_id);


--
-- Name: entity_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: milind_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY milind
    ADD CONSTRAINT milind_pkey PRIMARY KEY (case_id, case_no);


--
-- Name: non_monetary_term_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY non_monetary_term
    ADD CONSTRAINT non_monetary_term_pkey PRIMARY KEY (term_id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (player_id);


--
-- Name: relatedsubject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY relatedsubject
    ADD CONSTRAINT relatedsubject_pkey PRIMARY KEY (subject_id, relatedsubject_id);


--
-- Name: relationtype_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY relationtype
    ADD CONSTRAINT relationtype_pkey PRIMARY KEY (relation_id);


--
-- Name: role_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- Name: settlement_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY settlement
    ADD CONSTRAINT settlement_pkey PRIMARY KEY (settlement_id);


--
-- Name: stage_order_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY stage_order
    ADD CONSTRAINT stage_order_pkey PRIMARY KEY (stage_order_id);


--
-- Name: subject_pkey; Type: CONSTRAINT; Schema: fecmur; Owner: -
--

ALTER TABLE ONLY subject
    ADD CONSTRAINT subject_pkey PRIMARY KEY (subject_id);

--
-- Name: cases_with_parsed_case_serial_numbers; Type: VIEW; Schema: fecmur; Owner: fec
--
CREATE VIEW cases_with_parsed_case_serial_numbers
AS
    SELECT
        case_id,
        case_no,
        regexp_replace(case_no, '(\d+).*', '\1')::int AS case_serial,
        name,
        case_type,
        pg_date
    FROM fecmur.case
    WHERE case_type = 'MUR';
--
-- Data for Name: role; Type: TABLE DATA; Schema: fecmur; Owner: fec
--

INSERT INTO role VALUES (100199, 'Respondent''s Counsel', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100201, 'Law Firm', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100204, 'Representative', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100093, 'Respondent', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100094, 'Primary Respondent', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100095, 'Complainant', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100096, 'Respondent''s Counsel', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100111, 'Previous Respondent', '2016-08-26 12:12:37.559707');
INSERT INTO role VALUES (100122, 'Treasurer', '2016-08-26 12:12:37.559707');


--
-- Data for Name: subject; Type: TABLE DATA; Schema: fecmur; Owner: fec
--

INSERT INTO subject VALUES (1, 'Allocation', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (2, 'Committees', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (3, 'Contributions', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (4, 'Disclaimer', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (5, 'Disbursements', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (6, 'Electioneering', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (7, 'Expenditures', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (8, 'Express Advocacy', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (9, 'Foreign Nationals', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (10, 'Fraudulent misrepresentation', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (11, 'Issue Advocacy', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (12, 'Knowing and Willful', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (13, 'Loans', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (14, 'Non-federal', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (15, 'Other', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (16, 'Personal use', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (17, 'Presidential', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (18, 'Reporting', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (19, 'Soft Money', '2016-08-26 12:12:37.979847');
INSERT INTO subject VALUES (20, 'Solicitation', '2016-08-26 12:12:37.979847');

