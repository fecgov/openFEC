-- Boilerplate
\set ECHO none
\set QUIET 1
-- Turn off echo and keep things quiet.

-- Format the output for nice TAP.
\pset format unaligned
\pset tuples_only true
\pset pager

-- Revert all changes on failure.
\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP true
\set QUIET 1

BEGIN;
-- Load pgTAP
\i pgtap.sql
-- Load tests

CREATE SCHEMA test_functions;

\i ../../data/functions/utils.sql 
\i functions/utils.sql

SELECT * FROM runtests('test_functions', '.*');
ROLLBACK;
