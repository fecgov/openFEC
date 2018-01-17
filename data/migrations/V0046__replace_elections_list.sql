CREATE MATERIALIZED VIEW elections_list_mv AS

WITH incumbents AS (
--So we don't show duplicate elections
    SELECT
        cand_id,
        cand_name,
        race_pk
    FROM disclosure.cand_valid_fec_yr
    WHERE cand_ici = 'I'
    GROUP BY cand_id, cand_name, race_pk
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
        get_cycle(election_yr) as cycle,
        race_pk
    FROM disclosure.dim_race_inf
        --to break a tie, show most recent?
        --ORDER BY get_cycle(election_yr) DESC
)
SELECT
    election_yr,
    office AS cand_office,
    state AS cand_office_st,
    district AS cand_office_district,
    cycle AS fec_election_yr,
    cand_id,
    cand_name
FROM filtered_race
LEFT JOIN incumbents
    ON filtered_race.race_pk = incumbents.race_pk
;