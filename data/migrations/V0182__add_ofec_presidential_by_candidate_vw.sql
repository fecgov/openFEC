/*

View for https://github.com/fecgov/openFEC/issues/4170
Adds presidential contributions by candidate, state and national totals
Endpoint: /presidential/contributions/by_candidate/

*/

-- Function: public.expand_party

CREATE OR REPLACE FUNCTION public.expand_party(initial text) RETURNS text
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN CASE initial
            WHEN '(L)' THEN 'LIB'
            WHEN '(I)' THEN 'IND'
            WHEN '(D)' THEN 'DEM'
            WHEN '(R)' THEN 'REP'
            WHEN '(G)' THEN 'GRE'
            ELSE initial
        END;
    END
$$;

ALTER FUNCTION public.expand_party(initial text) OWNER TO fec;

-- View: public.ofec_presidential_by_candidate_vw

CREATE OR REPLACE VIEW public.ofec_presidential_by_candidate_vw AS
SELECT row_number() OVER () AS idx, *
FROM (
    -- 2020 totals
    -- US (national) totals
    SELECT DISTINCT
    cand_id AS candidate_id,
    SUBSTR(cand_nm, 0, STRPOS(cand_nm,',')) AS candidate_last_name,
    cand_pty_affiliation AS candidate_party_affiliation,
    ((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + COALESCE(fed_funds_per,0)) AS net_receipts,
    ROUND(((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + coalesce(fed_funds_per,0))/1000000,1) AS rounded_net_receipts,
    'US' AS contributor_state,
    2020 AS election_year
    FROM disclosure.pres_f3p_totals_ca_cm_link_20d
    UNION
    -- per-state totals
    SELECT DISTINCT
    cand_id AS candidate_id,
    cand_nm AS candidate_last_name,
    -- state table has one-letter parties
    expand_party(cand_pty_affiliation) AS candidate_party_affiliation,
    SUM(net_receipts_state) AS net_receipts,
    ROUND(SUM(net_receipts_state )/1000000,1) AS rounded_net_receipts, --per state
    contbr_st AS contributor_state,
    2020 AS election_year
    FROM disclosure.pres_ca_cm_sched_state_20d
    GROUP BY candidate_id,candidate_party_affiliation,candidate_last_name, contributor_state
    UNION
    -- 2016 totals
    -- US (national) totals
    SELECT DISTINCT
    cand_id AS candidate_id,
    SUBSTR(cand_nm, 0, STRPOS(cand_nm,',')) AS candidate_last_name,
    cand_pty_affiliation AS candidate_party_affiliation,
    ((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + COALESCE(fed_funds_per,0)) AS net_receipts,
    ROUND(((indv_contb_per - ref_indv_contb_per) +
        (pol_pty_cmte_contb_per - ref_pol_pty_cmte_contb_per) +
        (other_pol_cmte_contb_per - ref_other_pol_cmte_contb_per) +
        cand_contb_per + tranf_from_affilated_cmte_per +
        (loans_received_from_cand_per - repymts_loans_made_by_cand_per) +
        (other_loans_received_per - repymts_other_loans_per) + other_receipts_per
        + coalesce(fed_funds_per,0))/1000000,1) AS rounded_net_receipts,
    'US' AS contributor_state,
    2016 AS election_year
    FROM disclosure.pres_f3p_totals_ca_cm_link_16
    UNION
    -- per-state totals
    SELECT DISTINCT
    cand_id AS candidate_id,
    cand_nm AS candidate_last_name,
    expand_party(cand_pty_affiliation) AS candidate_party_affiliation,
    SUM(net_receipts_state) AS net_receipts,
    ROUND(SUM(net_receipts_state )/1000000,1) AS rounded_net_receipts, --per state
    contbr_st AS contributor_state,
    2016 AS election_year
    FROM disclosure.pres_ca_cm_sched_state_16
    GROUP BY candidate_id,candidate_party_affiliation,candidate_last_name, contributor_state
    ORDER BY election_year, contributor_state, net_receipts DESC)
AS combined;

ALTER TABLE public.ofec_presidential_by_candidate_vw
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_presidential_by_candidate_vw TO fec;
GRANT SELECT ON TABLE public.ofec_presidential_by_candidate_vw TO fec_read;
