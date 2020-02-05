/*
used for Endpoint: /presidential/contributions/by_state/
*/
-- DROP VIEW public.ofec_presidential_by_state_vw;
-- View: public.ofec_presidential_by_state_vw

CREATE OR REPLACE VIEW public.ofec_presidential_by_state_vw AS 
  SELECT row_number() OVER () AS idx, *
  FROM (
    SELECT 
      cand_id as candidate_id,
      contbr_st as contribution_state,
      contb_receipt_amt as contribution_receipt_amount,
      2020 AS election_year
    FROM
      disclosure.pres_ca_cm_sched_a_join_20d
    WHERE
      contbr_st IN('CA', 'NY', 'TX', 'FL', 'IL', 'VA', 'MA', 'DC', 'NJ', 'MD', 'PA', 'WA', 'CT', 'GA', 'CO', 'OH', 'AZ', 'NC', 'MI', 'TN', 'NM', 'MO', 'MN', 'OR', 'UT', 'WI', 'NV', 'SC', 'IN', 'OK', 'LA', 'AL', 'KY', 'AR', 'NH', 'IA', 'KS', 'HI', 'ME', 'MS', 'RI', 'DE', 'VT', 'ID', 'NE', 'MT', 'WV',  'AK', 'WY', 'SD', 'ND') 
    AND ZIP_3 ='NA'
    UNION
    SELECT 
      cand_id as candidate_id,
      contbr_st as contribution_state,
      contb_receipt_amt as contribution_receipt_amount,
      2016 AS election_year
    FROM
      disclosure.pres_ca_cm_sched_a_join_16
    WHERE
      contbr_st IN('CA', 'NY', 'TX', 'FL', 'IL', 'VA', 'MA', 'DC', 'NJ', 'MD', 'PA', 'WA', 'CT', 'GA', 'CO', 'OH', 'AZ', 'NC', 'MI', 'TN', 'NM', 'MO', 'MN', 'OR', 'UT', 'WI', 'NV', 'SC', 'IN', 'OK', 'LA', 'AL', 'KY', 'AR', 'NH', 'IA', 'KS', 'HI', 'ME', 'MS', 'RI', 'DE', 'VT', 'ID', 'NE', 'MT', 'WV',  'AK', 'WY', 'SD', 'ND') 
    AND ZIP_3 ='NA'
  )
  AS multi_election_year_contribution
  ORDER BY election_year,contribution_receipt_amount desc;

ALTER TABLE public.ofec_presidential_by_state_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_presidential_by_state_vw TO fec;
GRANT SELECT ON TABLE public.ofec_presidential_by_state_vw TO fec_read;
