--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: aouser; Type: SCHEMA; Schema: -; Owner: fec
--

CREATE SCHEMA aouser;


SET search_path = aouser, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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


