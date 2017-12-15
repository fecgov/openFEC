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


ALTER TABLE ao OWNER TO fec;

--
-- Name: aos_with_parsed_numbers; Type: VIEW; Schema: aouser; Owner: fec
--

CREATE VIEW aos_with_parsed_numbers AS
 SELECT ao.ao_id,
    ao.ao_no,
    (regexp_replace((ao.ao_no)::text, '(\d+)-(\d+)'::text, '\1'::text))::integer AS ao_year,
    (regexp_replace((ao.ao_no)::text, '(\d+)-(\d+)'::text, '\2'::text))::integer AS ao_serial,
    ao.name,
    ao.summary,
    ao.req_date,
    ao.issue_date,
    ao.pg_date
   FROM ao;


ALTER TABLE aos_with_parsed_numbers OWNER TO fec;

--
-- Name: doc_order; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE doc_order (
    doc_order_id integer NOT NULL,
    category character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE doc_order OWNER TO fec;

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


ALTER TABLE document OWNER TO fec;

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


ALTER TABLE entity OWNER TO fec;

--
-- Name: entity_type; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE entity_type (
    entity_type_id integer NOT NULL,
    description character varying(255),
    flags character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE entity_type OWNER TO fec;

--
-- Name: filtertab; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE filtertab (
    query_id integer NOT NULL,
    document text,
    ao_id integer,
    ctrl_flg character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE filtertab OWNER TO fec;

--
-- Name: markuptab; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE markuptab (
    query_id bigint,
    document text,
    id integer NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE markuptab OWNER TO fec;

--
-- Name: players; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE players (
    player_id integer NOT NULL,
    ao_id integer,
    role_id integer,
    entity_id integer,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE players OWNER TO fec;

--
-- Name: role; Type: TABLE; Schema: aouser; Owner: fec
--

CREATE TABLE role (
    role_id integer NOT NULL,
    description character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE role OWNER TO fec;
