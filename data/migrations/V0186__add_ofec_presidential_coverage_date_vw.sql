/*

View for https://github.com/fecgov/openFEC/issues/4178
Adds presidential coverage end date
Endpoint: /presidential/coverage_end_date/

*/

-- View: public.ofec_presidential_coverage_date_vw

CREATE OR REPLACE VIEW public.ofec_presidential_coverage_date_vw AS
SELECT
    row_number() OVER () AS idx, *
FROM (
    -- 2020 data
    SELECT
    cand_id AS candidate_id,
    max(cand_nm) AS candidate_name,
    to_char(max(cvg_end_dt), 'mm/dd/yyyy'):: timestamp without time zone as coverage_end_date,
    2020 as election_year
    FROM disclosure.pres_nml_form_3p_20d
    GROUP BY candidate_id
    UNION
    -- 2016 data
    SELECT
    cand_id AS candidate_id,
    max(cand_nm) AS candidate_name,
    to_char(max(cvg_end_dt), 'mm/dd/yyyy'):: timestamp without time zone as coverage_end_date,
    2016 as election_year
    FROM disclosure.pres_nml_form_3p_16
    GROUP BY candidate_id) AS combined
ORDER BY election_year, candidate_id DESC;

ALTER TABLE public.ofec_presidential_coverage_date_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_presidential_coverage_date_vw TO fec;
GRANT SELECT ON TABLE public.ofec_presidential_coverage_date_vw TO fec_read;
