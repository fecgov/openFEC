--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ofec_nicknames; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE ofec_nicknames (
    index bigint,
    candidate_id text,
    nickname text
);



--
-- Data for Name: ofec_nicknames; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY ofec_nicknames (index, candidate_id, nickname) FROM stdin;
0	P60007168	bernie sanders
1	S4VT00033	bernie sanders
2	H8VT01016	bernie sanders
3	P00003392	hilary clinton
4	S0NY00188	hilary clinton
\.


--
-- Name: ix_ofec_nicknames_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ofec_nicknames_index ON ofec_nicknames USING btree (index);


--
-- PostgreSQL database dump complete
--

