-- View: public.ofec_pac_sponsor_candidate_per_cycle_vw
-- This view is created for ticket #4879.
-- This view includes historical data for leadership PAC committees and their sponsors



CREATE OR REPLACE VIEW public.ofec_pac_sponsor_candidate_per_cycle_vw
AS
SELECT row_number() OVER () AS idx,
    cmte.committee_id AS committee_id,
    cmte.cycle AS cycle,
    cand.candidate_id AS sponsor_candidate_id,
    cand.name AS sponsor_candidate_name
FROM ofec_committee_history_vw cmte
    LEFT JOIN ofec_candidate_history_vw cand
    ON (cand.candidate_id::text = ANY (cmte.sponsor_candidate_ids)
    AND cand.two_year_period = cmte.cycle)
WHERE cmte.sponsor_candidate_ids IS NOT NULL;

ALTER TABLE public.ofec_pac_sponsor_candidate_per_cycle_vw OWNER TO fec;

GRANT ALL ON TABLE public.ofec_pac_sponsor_candidate_per_cycle_vw TO fec;

GRANT SELECT ON TABLE public.ofec_pac_sponsor_candidate_per_cycle_vw TO fec_read;
