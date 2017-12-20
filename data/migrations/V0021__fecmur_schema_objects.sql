SET search_path = fecmur, pg_catalog;

--
-- Name: af_case; Type: TABLE; Schema: fecmur; Owner: fec
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


ALTER TABLE af_case OWNER TO fec;

--
-- Name: calendar; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE calendar (
    entity_id bigint,
    event_date timestamp without time zone,
    event_id bigint,
    case_id bigint
);


ALTER TABLE calendar OWNER TO fec;

--
-- Name: case; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE "case" (
    case_id bigint NOT NULL,
    case_no character varying(255),
    name character varying(255),
    case_type character varying(50),
    sol_earliest timestamp without time zone,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE "case" OWNER TO fec;

--
-- Name: case_subject; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE case_subject (
    case_id bigint NOT NULL,
    subject_id bigint NOT NULL,
    relatedsubject_id bigint NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE case_subject OWNER TO fec;

--
-- Name: cases_with_parsed_case_serial_numbers; Type: VIEW; Schema: fecmur; Owner: fec
--

CREATE VIEW cases_with_parsed_case_serial_numbers AS
 SELECT "case".case_id,
    "case".case_no,
    (regexp_replace(("case".case_no)::text, '(\d+).*'::text, '\1'::text))::integer AS case_serial,
    "case".name,
    "case".case_type,
    "case".pg_date
   FROM "case";


ALTER TABLE cases_with_parsed_case_serial_numbers OWNER TO fec;

--
-- Name: commission; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE commission (
    commission_id bigint NOT NULL,
    agenda_date timestamp without time zone,
    vote_date timestamp without time zone,
    action text,
    case_id bigint NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE commission OWNER TO fec;

--
-- Name: doc_order; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE doc_order (
    doc_order_id bigint NOT NULL,
    category character varying(255),
    case_type character varying(10),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE doc_order OWNER TO fec;

--
-- Name: document; Type: TABLE; Schema: fecmur; Owner: fec
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


ALTER TABLE document OWNER TO fec;

--
-- Name: document_chg; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE document_chg (
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


ALTER TABLE document_chg OWNER TO fec;

--
-- Name: electioncycle; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE electioncycle (
    case_id bigint,
    election_cycle integer NOT NULL,
    election_cycle_type character varying(50)
);


ALTER TABLE electioncycle OWNER TO fec;

--
-- Name: entity; Type: TABLE; Schema: fecmur; Owner: fec
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


ALTER TABLE entity OWNER TO fec;

--
-- Name: event; Type: TABLE; Schema: fecmur; Owner: fec
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


ALTER TABLE event OWNER TO fec;

--
-- Name: milind; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE milind (
    case_id bigint NOT NULL,
    case_no numeric NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE milind OWNER TO fec;

--
-- Name: non_monetary_term; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE non_monetary_term (
    term_id bigint NOT NULL,
    term_description character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE non_monetary_term OWNER TO fec;

--
-- Name: players; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE players (
    player_id bigint NOT NULL,
    entity_id bigint,
    case_id bigint,
    role_id bigint,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE players OWNER TO fec;

--
-- Name: relatedobjects; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE relatedobjects (
    master_key bigint,
    detail_key bigint,
    relation_id bigint
);


ALTER TABLE relatedobjects OWNER TO fec;

--
-- Name: relatedsubject; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE relatedsubject (
    subject_id bigint NOT NULL,
    relatedsubject_id bigint NOT NULL,
    description character varying(200),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE relatedsubject OWNER TO fec;

--
-- Name: relationtype; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE relationtype (
    relation_id bigint NOT NULL,
    description character varying(255),
    master_key_type character varying(255),
    detail_key_type character varying(255),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE relationtype OWNER TO fec;

--
-- Name: role; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE role (
    role_id numeric(10,0) NOT NULL,
    description character varying(255) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE role OWNER TO fec;

--
-- Name: settlement; Type: TABLE; Schema: fecmur; Owner: fec
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


ALTER TABLE settlement OWNER TO fec;

--
-- Name: stage_order; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE stage_order (
    stage_order_id bigint NOT NULL,
    stage character varying(50),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE stage_order OWNER TO fec;

--
-- Name: subject; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE subject (
    subject_id bigint NOT NULL,
    description character varying(200),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE subject OWNER TO fec;

--
-- Name: violations; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE violations (
    case_id bigint,
    entity_id bigint,
    stage character varying(50),
    statutory_citation character varying(255),
    regulatory_citation character varying(255)
);


ALTER TABLE violations OWNER TO fec;

--
-- Name: votes; Type: TABLE; Schema: fecmur; Owner: fec
--

CREATE TABLE votes (
    commission_id bigint,
    entity_id bigint,
    vote_type character varying(50),
    case_id bigint
);


ALTER TABLE votes OWNER TO fec;
