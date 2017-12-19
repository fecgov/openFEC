SET search_path = rohan, pg_catalog;

--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: rohan; Owner: fec
--

CREATE SEQUENCE auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth_user_id_seq OWNER TO fec;

--
-- Name: row_count_seq; Type: SEQUENCE; Schema: rohan; Owner: fec
--

CREATE SEQUENCE row_count_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE row_count_seq OWNER TO fec;

--
-- Name: rj_row_count; Type: TABLE; Schema: rohan; Owner: fec
--

CREATE TABLE rj_row_count (
    row_id integer DEFAULT nextval('row_count_seq'::regclass) NOT NULL,
    create_date date DEFAULT now(),
    ora_schema character varying,
    ora_table character varying,
    ora_count integer,
    pg_schema character varying,
    pg_table character varying,
    pg_count integer,
    diff integer
);


ALTER TABLE rj_row_count OWNER TO fec;

--
-- Name: rj_user; Type: TABLE; Schema: rohan; Owner: fec
--

CREATE TABLE rj_user (
    uid integer DEFAULT nextval('auth_user_id_seq'::regclass) NOT NULL,
    username character varying(150),
    password character varying(128),
    email character varying(255)
);


ALTER TABLE rj_user OWNER TO fec;
