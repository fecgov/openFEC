-- Install any required extensions into PostgreSQL
-- NOTE:  These must be supported in the Amazon RDS environment.  Please see
-- http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.FeatureSupport.Extensions
-- for more details and look in the table for the corresponding PostgreSQL
-- version being run.

CREATE EXTENSION IF NOT EXISTS hstore;
