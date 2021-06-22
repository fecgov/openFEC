-- View: public.ofec_pac_sponsor_candidate_vw
-- This view is created for ticket #4870. 
-- This view includes leadership PAC committees and their sponsors

-- DROP VIEW public.ofec_pac_sponsor_candidate_vw;

CREATE OR REPLACE VIEW public.ofec_pac_sponsor_candidate_vw
AS
SELECT row_number() OVER () AS idx,
    cmte.committee_id AS committee_id,
    cand.candidate_id AS sponsor_candidate_id,
    cand.name AS sponsor_candidate_name
FROM ofec_committee_detail_vw cmte
    LEFT JOIN ofec_candidate_detail_vw cand ON cand.candidate_id::text = ANY (cmte.sponsor_candidate_ids)
WHERE cmte.sponsor_candidate_ids IS NOT NULL;

ALTER TABLE public.ofec_pac_sponsor_candidate_vw OWNER TO fec;

GRANT ALL ON TABLE public.ofec_pac_sponsor_candidate_vw TO fec;

GRANT SELECT ON TABLE public.ofec_pac_sponsor_candidate_vw TO fec_read;
