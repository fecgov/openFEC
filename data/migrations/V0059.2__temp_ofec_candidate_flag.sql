SET search_path = public, pg_catalog;

--
-- 1)Name: ofec_candidate_flag; Type: MATERIALIZED VIEW; Schema: public; Owner: fec
--

SET search_path = public, pg_catalog;



-- Materialized View: ofec_candidate_flag

REFRESH MATERIALIZED VIEW ofec_candidate_history_mv;

DROP MATERIALIZED VIEW IF EXISTS ofec_candidate_flag;
 
CREATE MATERIALIZED VIEW ofec_candidate_flag AS 
 SELECT row_number() OVER () AS idx,
    ofec_candidate_history_mv.candidate_id,
    array_agg(oct.has_raised_funds) @> ARRAY[true] AS has_raised_funds,
    array_agg(oct.federal_funds_flag) @> ARRAY[true] AS federal_funds_flag
   FROM ofec_candidate_history_mv
     LEFT JOIN ofec_candidate_totals_mv oct USING (candidate_id)
  GROUP BY ofec_candidate_history_mv.candidate_id
WITH DATA;

ALTER TABLE ofec_candidate_flag
  OWNER TO fec;
GRANT ALL ON TABLE ofec_candidate_flag TO fec;
GRANT SELECT ON TABLE ofec_candidate_flag TO fec_read;

-- Index: ofec_candidate_flag_tmp_candidate_id_idx1

-- DROP INDEX ofec_candidate_flag_tmp_candidate_id_idx1;

CREATE INDEX ofec_candidate_flag_tmp_candidate_id_idx1
  ON ofec_candidate_flag
  USING btree
  (candidate_id COLLATE pg_catalog."default");

-- Index: ofec_candidate_flag_tmp_federal_funds_flag_idx1

-- DROP INDEX ofec_candidate_flag_tmp_federal_funds_flag_idx1;

CREATE INDEX ofec_candidate_flag_tmp_federal_funds_flag_idx1
  ON ofec_candidate_flag
  USING btree
  (federal_funds_flag);

-- Index: ofec_candidate_flag_tmp_has_raised_funds_idx1

-- DROP INDEX ofec_candidate_flag_tmp_has_raised_funds_idx1;

CREATE INDEX ofec_candidate_flag_tmp_has_raised_funds_idx1
  ON ofec_candidate_flag
  USING btree
  (has_raised_funds);

-- Index: ofec_candidate_flag_tmp_idx_idx1

-- DROP INDEX ofec_candidate_flag_tmp_idx_idx1;

CREATE UNIQUE INDEX ofec_candidate_flag_tmp_idx_idx1
  ON ofec_candidate_flag
  USING btree
  (idx);

