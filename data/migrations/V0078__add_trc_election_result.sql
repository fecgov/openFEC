SET search_path = fecapp, pg_catalog;

CREATE TABLE trc_election_result (
  trc_election_result_id  bigint NOT NULL,
  cand_id                 character varying(9) NOT NULL,
  cand_nm                 character varying(90),
  cand_votes              numeric(12,0),
  votes_cert              numeric(12,0),
  win_loss_flag           character varying(1),
  source                  character varying(1),
  entry_date              timestamp without time zone,
  results_notes           character varying(250),
  trc_election_id         bigint NOT NULL,
  create_date             timestamp without time zone,
  update_date             timestamp without time zone,
  sec_user_id_create      numeric(12,0) NOT NULL,
  sec_user_id_update      numeric(12,0) NOT NULL,
  election_party          character varying(3),
  election_state          character varying(2),
  election_district       character varying(3),
  election_party_2        character varying(50),
  pg_date                 timestamp without time zone DEFAULT now()
);

--Permissions

ALTER TABLE trc_election_result OWNER TO fec;
GRANT SELECT ON TABLE trc_election_result TO fec_read;

--Index on primary key automatically created

--Constraints

ALTER TABLE ONLY trc_election_result
    ADD CONSTRAINT trc_election_result_pkey PRIMARY KEY (trc_election_result_id);
