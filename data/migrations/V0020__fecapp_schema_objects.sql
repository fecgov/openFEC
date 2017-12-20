SET search_path = fecapp, pg_catalog;

--
-- Name: cal_category; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE cal_category (
    cal_category_id integer NOT NULL,
    category_name character varying(150) NOT NULL,
    active character varying(1) NOT NULL,
    order_number integer NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    sec_user_id_update numeric(12,0) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cal_category OWNER TO fec;

--
-- Name: cal_category_subcat; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE cal_category_subcat (
    cal_category_id integer NOT NULL,
    cal_category_id_subcat integer NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cal_category_subcat OWNER TO fec;

--
-- Name: cal_event; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE cal_event (
    cal_event_id integer NOT NULL,
    event_name character varying(150) NOT NULL,
    description character varying(500),
    location character varying(200),
    url character varying(250),
    start_date timestamp without time zone NOT NULL,
    use_time character varying(1) NOT NULL,
    end_date timestamp without time zone,
    cal_event_status_id numeric NOT NULL,
    priority numeric(1,0) NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    sec_user_id_update numeric(12,0) NOT NULL,
    update_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cal_event OWNER TO fec;

--
-- Name: cal_event_category; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE cal_event_category (
    cal_event_id integer NOT NULL,
    cal_category_id integer NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    create_date timestamp without time zone NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cal_event_category OWNER TO fec;

--
-- Name: cal_event_status; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE cal_event_status (
    cal_event_status_id integer NOT NULL,
    cal_event_status_desc character varying(30) NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE cal_event_status OWNER TO fec;

--
-- Name: trc_election; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE trc_election (
    trc_election_id integer NOT NULL,
    election_state character varying(2),
    election_district character varying(3),
    election_party character varying(3),
    office_sought character varying(1),
    election_date date,
    election_notes character varying(250),
    sec_user_id_update numeric(12,0) NOT NULL,
    sec_user_id_create numeric(12,0) NOT NULL,
    trc_election_type_id character varying(3) NOT NULL,
    trc_election_status_id integer NOT NULL,
    update_date timestamp without time zone,
    create_date timestamp without time zone,
    election_yr numeric(4,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE trc_election OWNER TO fec;

--
-- Name: trc_election_dates; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE trc_election_dates (
    trc_election_id integer NOT NULL,
    election_date date,
    close_of_books date,
    rc_date date,
    filing_date date,
    f48hour_start date,
    f48hour_end date,
    notice_mail_date date,
    losergram_mail_date date,
    ec_start date,
    ec_end date,
    ie_48hour_start date,
    ie_48hour_end date,
    ie_24hour_start date,
    ie_24hour_end date,
    cc_start date,
    cc_end date,
    election_date2 date,
    ballot_deadline date,
    primary_voter_reg_start date,
    primary_voter_reg_end date,
    general_voter_reg_start date,
    general_voter_reg_end date,
    date_special_election_set date,
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    election_party character varying(3),
    display_flag character varying(1),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE trc_election_dates OWNER TO fec;

--
-- Name: trc_election_status; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE trc_election_status (
    name character varying(50) NOT NULL,
    trc_election_status_id bigint NOT NULL,
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE trc_election_status OWNER TO fec;

--
-- Name: trc_election_type; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE trc_election_type (
    trc_election_type_id character varying(3) NOT NULL,
    election_desc character varying(30),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE trc_election_type OWNER TO fec;

--
-- Name: trc_report_due_date; Type: TABLE; Schema: fecapp; Owner: fec
--

CREATE TABLE trc_report_due_date (
    trc_report_due_date_id numeric(12,0) NOT NULL,
    report_year numeric(4,0),
    report_type character varying(6),
    due_date date,
    trc_election_id integer,
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    sec_user_id_create numeric(12,0),
    sec_user_id_update numeric(12,0),
    pg_date timestamp without time zone DEFAULT now()
);


ALTER TABLE trc_report_due_date OWNER TO fec;
