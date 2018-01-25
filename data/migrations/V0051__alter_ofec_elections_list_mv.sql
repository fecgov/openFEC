SET search_path = public, pg_catalog;

DROP MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv_TMP;

CREATE MATERIALIZED VIEW ofec_elections_list_mv_TMP AS

WITH incumbents AS (
--So we don't show duplicate elections
    SELECT DISTINCT ON (
            race_pk) --sometimes more than one incumbent
        race_pk,
        cand_id,
        cand_name,
        lst_updt_dt
    FROM disclosure.cand_valid_fec_yr
    WHERE cand_ici = 'I'
    --Where there are multiple entries, choose the most recent
    ORDER BY race_pk, lst_updt_dt DESC
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
    row_number() OVER () AS idx,
    CAST (election_yr AS INTEGER),
    CASE office WHEN 'P' THEN 0 WHEN 'S' THEN 1 ELSE 2 END AS sort_order,
    office,
    state,
    district,
    cycle,
    cand_id AS incumbent_id,
    cand_name AS incumbent_name
FROM filtered_race
LEFT JOIN incumbents
    ON filtered_race.race_pk = incumbents.race_pk
ORDER BY district ASC
;

ALTER TABLE ofec_elections_list_mv_TMP OWNER TO fec;
GRANT ALL ON TABLE ofec_elections_list_mv_TMP TO fec;
GRANT SELECT ON TABLE ofec_elections_list_mv_TMP TO fec_read;
GRANT SELECT ON TABLE ofec_elections_list_mv_TMP TO openfec_read;

CREATE INDEX ON ofec_elections_list_mv_TMP(idx);
CREATE INDEX ON ofec_elections_list_mv_TMP(election_yr);
CREATE INDEX ON ofec_elections_list_mv_TMP(office);
CREATE INDEX ON ofec_elections_list_mv_TMP(state);
CREATE INDEX ON ofec_elections_list_mv_TMP(district);
CREATE INDEX ON ofec_elections_list_mv_TMP(cycle);
CREATE INDEX ON ofec_elections_list_mv_TMP(incumbent_id);
CREATE INDEX ON ofec_elections_list_mv_TMP(incumbent_name);

--------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv_TMP RENAME TO ofec_elections_list_mv;

SELECT rename_indexes('ofec_elections_list_mv');
