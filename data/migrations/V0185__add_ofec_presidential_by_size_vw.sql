/*
used for Endpoint: /presidential/contributions/by_size/
*/

-- Function: public.size_range
CREATE OR REPLACE FUNCTION public.size_range(size_range_id numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE size_range_id
            WHEN 1 THEN 0
            WHEN 2 THEN 200
            WHEN 3 THEN 500
            WHEN 4 THEN 1000
            WHEN 5 THEN 2000
            ELSE 0
        END;
    END
$$;

ALTER FUNCTION public.size_range(size_range_id numeric) OWNER TO fec;


-- DROP VIEW public.ofec_presidential_by_size_vw;
-- View: public.ofec_presidential_by_size_vw

CREATE OR REPLACE VIEW public.ofec_presidential_by_size_vw AS 
  SELECT row_number() OVER () AS idx, *
  FROM (
    SELECT 
      cand_id as candidate_id,
      contb_range_id as size_range_id,
      size_range(contb_range_id) AS size,      
      contb_receipt_amt AS contribution_receipt_amount,
      2020 AS election_year
    FROM
      disclosure.pres_ca_cm_sched_link_sum_20d
    UNION
    SELECT 
      cand_id as candidate_id,
      contb_range_id as size_range_id,
      size_range(contb_range_id) AS size,      
      contb_receipt_amt AS contribution_receipt_amount,
      2016 AS election_year
    FROM
      disclosure.pres_ca_cm_sched_link_sum_16
  )
  AS multi_election_year_size
  ORDER BY election_year,size_range_id;

ALTER TABLE public.ofec_presidential_by_size_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_presidential_by_size_vw TO fec;
GRANT SELECT ON TABLE public.ofec_presidential_by_size_vw TO fec_read;
