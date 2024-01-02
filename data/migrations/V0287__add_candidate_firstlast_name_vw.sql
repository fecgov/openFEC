/*
This migration file is for #5347

1) Create candidate_firstlast_name_vw which includes parsed candidate name for each candidate each election year
*/

CREATE OR REPLACE VIEW public.candidate_firstlast_name_vw
AS
WITH f2 AS (
        SELECT nml_form_2.cand_id,
            nml_form_2.election_yr,
            nml_form_2.cand_prefix,
            nml_form_2.cand_nm_first,
            nml_form_2.cand_m_nm,
            nml_form_2.cand_nm_last,
            nml_form_2.cand_suffix,
            nml_form_2.cand_nm,
            (substr(nml_form_2.sub_id::text, 6, 4) || substr(nml_form_2.sub_id::text, 2, 2) || substr(nml_form_2.sub_id::text, 4, 2) || substr(nml_form_2.sub_id::text, 10))::numeric AS revised_sub_id
        FROM disclosure.nml_form_2
        WHERE nml_form_2.delete_ind IS NULL
        UNION
        SELECT nml_form_2z.cand_id,
            COALESCE(nml_form_2z.election_yr, nml_form_2z.rpt_yr + nml_form_2z.rpt_yr % 2::numeric) AS election_yr,
            nml_form_2z.cand_prefix,
            nml_form_2z.cand_nm_first,
            nml_form_2z.cand_m_nm,
            nml_form_2z.cand_nm_last,
            nml_form_2z.cand_suffix,
            nml_form_2z.cand_nm,
            (substr(nml_form_2z.sub_id::text, 6, 4) || substr(nml_form_2z.sub_id::text, 2, 2) || substr(nml_form_2z.sub_id::text, 4, 2) || substr(nml_form_2z.sub_id::text, 10))::numeric AS revised_sub_id
        FROM disclosure.nml_form_2z
        WHERE nml_form_2z.delete_ind IS NULL
        )
SELECT DISTINCT ON (f2.cand_id, f2.election_yr) f2.cand_id,
           f2.election_yr,
           f2.cand_prefix,
           f2.cand_nm_first,
           f2.cand_m_nm,
           f2.cand_nm_last,
           f2.cand_suffix
FROM f2
ORDER BY f2.cand_id, f2.election_yr, f2.revised_sub_id DESC;


ALTER TABLE public.candidate_firstlast_name_vw OWNER TO fec;
GRANT SELECT ON TABLE public.candidate_firstlast_name_vw TO fec_read;
