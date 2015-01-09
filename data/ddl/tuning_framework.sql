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
