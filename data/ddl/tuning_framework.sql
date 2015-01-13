CREATE TABLE tuning_requirement (
  id             SERIAL PRIMARY KEY,
  txt            TEXT NOT NULL,
  type           TEXT NOT NULL,
  target_seconds NUMERIC,
  ticket         TEXT,
  status         TEXT NOT NULL DEFAULT 'untested' );

CREATE TABLE tuning_test (
  id             SERIAL PRIMARY KEY,
  dt             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  requirement_id INTEGER NOT NULL REFERENCES tuning_requirement (id),
  initial        BOOLEAN NOT NULL DEFAULT false,
  seconds        NUMERIC,
  error_msg      TEXT
  );

CREATE TABLE tuning_action (
  id             SERIAL PRIMARY KEY,
  dt             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
  domain         TEXT NOT NULL,
  condition      TEXT,
  measurement    TEXT,
  previous       TEXT,
  new            TEXT NOT NULL
  );

CREATE OR REPLACE VIEW tuning_history AS
SELECT r.ticket,
       t.dt,
       r.txt,
       r.target_seconds,
       t.seconds,
       t.error_msg
FROM   tuning_requirement r
JOIN   tuning_Test t ON (r.id = t.requirement_id)
UNION ALL
SELECT NULL::text AS ticket,
       a.dt,
       a.new AS txt,
       NULL::numeric AS target_seconds,
       NULL::numeric AS seconds,
       NULL::text AS error_msg
FROM   tuning_action a;

-- sample queries:
-- https://fec.18f.us/htsql/tuning_history.sort(dt)?txt='https://fec.18f.us/rest/total'|is_null(ticket)
-- https://fec.18f.us/htsql/tuning_history.sort(dt)?txt='https://fec.18f.us/rest/total/C00000620'|is_null(ticket)

GRANT SELECT, INSERT, UPDATE ON tuning_action, tuning_test, tuning_requirement TO webro;
GRANT ALL PRIVILEGES ON SEQUENCE tuning_requirement_id_seq TO webro;
GRANT ALL PRIVILEGES ON SEQUENCE tuning_test_id_seq TO webro;
GRANT ALL PRIVILEGES ON SEQUENCE tuning_action_id_seq TO webro;
GRANT SELECT ON tuning_history TO webro;