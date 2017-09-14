-- Boilerplate
\set ECHO none
\set QUIET 1
-- Turn off echo and keep things quiet.

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

SET client_min_messages TO WARNING;


-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true
\set QUIET 1

BEGIN;
-- Load pgTAP
\i pgtap.sql

-- Load our tables
\i ../../data/functions/utils.sql 
\i ../../data/sql_incremental_aggregates/prepare_schedule_a_aggregate_employer.sql

CREATE SCHEMA test_functions;
-- Load tests
\i functions/utils.sql
\i sql_incremental_aggregates/prepare_schedule_a_aggregate_employer.sql

SELECT * FROM runtests('test_functions', '.*');
ROLLBACK;
