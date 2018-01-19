SET search_path = public, pg_catalog;

CREATE MATERIALIZED VIEW elections_list_mv AS

WITH incumbents AS (
--So we don't show duplicate elections
    SELECT
        cand_id,
        cand_name,
        race_pk,
        cand_ici
    FROM disclosure.cand_valid_fec_yr
    WHERE cand_ici = 'I'
    GROUP BY cand_id, cand_name, race_pk, cand_ici
), filtered_race AS (
-- Only one row per office/district/cycle
    SELECT DISTINCT ON (
            office,
            state,
            district,
            get_cycle(election_yr))
        office,
        state,
        district,
        election_yr,
        get_cycle(election_yr) AS cycle,
        race_pk
    FROM disclosure.dim_race_inf
        --to break a tie, show most recent?
        --ORDER BY get_cycle(election_yr) DESC
)
SELECT
    CAST (election_yr AS INTEGER),
    office,
    state,
    district,
    cycle,
    cand_id AS incumbent_id,
    cand_name AS incumbent_name,
    cand_ici AS candidate_status
FROM filtered_race
LEFT JOIN incumbents
    ON filtered_race.race_pk = incumbents.race_pk
;


ALTER TABLE elections_list_mv OWNER TO fec;

CREATE INDEX ON elections_list_mv(election_yr);
CREATE INDEX ON elections_list_mv(office);
CREATE INDEX ON elections_list_mv(state);
CREATE INDEX ON elections_list_mv(district);
CREATE INDEX ON elections_list_mv(cycle);
CREATE INDEX ON elections_list_mv(incumbent_id);
CREATE INDEX ON elections_list_mv(incumbent_name);
CREATE INDEX ON elections_list_mv(candidate_status);
