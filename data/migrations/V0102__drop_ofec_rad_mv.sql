/*

Addresses issue #3333: Add assignment_update_date to /rad-analyst/

- Drop materialized view `ofec_rad_mv`
--Drop function `fix_party_spelling`
- Replace view `rad_cmte_analyst_search_vw` with `ofec_rad_analyst_vw`
    - Move schema to `public`
    - Need to drop it because we're adding columns (idx, assignment_update)
    - Update column names to match `ofec_rad_mv`

*/

SET search_path = public;

DROP MATERIALIZED VIEW ofec_rad_mv;

DROP FUNCTION IF EXISTS fix_party_spelling(branch text);

----

SET search_path = disclosure, pg_catalog;

DROP VIEW rad_cmte_analyst_search_vw;

---

SET search_path = public;

CREATE VIEW ofec_rad_analyst_vw AS
    SELECT row_number() OVER () AS idx,
        ra.cmte_id AS committee_id,
        cv.cmte_nm AS committee_name,
        an.anlyst_id AS analyst_id,
        (an.valid_id::numeric) AS analyst_short_id,
        CASE
            WHEN an.branch_id = 1 THEN 'Authorized'
            WHEN an.branch_id = 2 THEN 'Party/Non Party'
            ELSE NULL::text
        END AS rad_branch,
        an.firstname AS first_name,
        an.lastname AS last_name,
        to_tsvector((((an.firstname)::text || ' '::text) || (an.lastname)::text)) AS name_txt,
        an.telephone_ext,
        t.anlyst_title_desc AS analyst_title,
        an.email AS analyst_email,
        ra.last_rp_change_dt AS assignment_update
    FROM rad_pri_user.rad_anlyst an
    JOIN rad_pri_user.rad_assgn ra
        ON an.anlyst_id = ra.anlyst_id
    JOIN disclosure.cmte_valid_fec_yr cv
        ON ra.cmte_id = cv.cmte_id
    JOIN rad_pri_user.rad_lkp_anlyst_title t
        ON an.anlyst_title_seq = t.anlyst_title_seq
    WHERE an.status_id = 1
        AND an.anlyst_id <> 999
        AND cv.fec_election_yr = get_cycle(date_part('year', current_date)::integer);

ALTER TABLE ofec_rad_analyst_vw OWNER TO fec;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO fec_read;
GRANT SELECT ON TABLE ofec_rad_analyst_vw TO openfec_read;
