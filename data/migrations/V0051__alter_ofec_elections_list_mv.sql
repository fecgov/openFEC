SET search_path = public, pg_catalog;

DROP MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv_tmp;

CREATE MATERIALIZED VIEW ofec_elections_list_mv_tmp AS

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

ALTER TABLE ofec_elections_list_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE ofec_elections_list_mv_tmp TO fec;
GRANT SELECT ON TABLE ofec_elections_list_mv_tmp TO fec_read;
GRANT SELECT ON TABLE ofec_elections_list_mv_tmp TO openfec_read;

CREATE INDEX ON ofec_elections_list_mv_tmp(idx);
CREATE INDEX ON ofec_elections_list_mv_tmp(election_yr);
CREATE INDEX ON ofec_elections_list_mv_tmp(office);
CREATE INDEX ON ofec_elections_list_mv_tmp(state);
CREATE INDEX ON ofec_elections_list_mv_tmp(district);
CREATE INDEX ON ofec_elections_list_mv_tmp(cycle);
CREATE INDEX ON ofec_elections_list_mv_tmp(incumbent_id);
CREATE INDEX ON ofec_elections_list_mv_tmp(incumbent_name);

--------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv;

ALTER MATERIALIZED VIEW IF EXISTS ofec_elections_list_mv_tmp RENAME TO ofec_elections_list_mv;

SELECT rename_indexes('ofec_elections_list_mv');
