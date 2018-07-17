/*
Resolves #3706

Drop ofec_election_result_mv - removing elections/won until we can determine a better data source

*/

SET search_path = public;

DROP MATERIALIZED VIEW IF EXISTS ofec_election_result_mv
