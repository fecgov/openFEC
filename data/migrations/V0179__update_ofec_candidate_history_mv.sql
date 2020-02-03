/*
The main driver for materialized view ofec_candidate_history_mv is disclosure.cand_valid_fec_yr, which has the correlation of fec_election_yr and cand_election_yr.  
The original problem we discovered was that the fec_election_yr and cand_election_yr correlation are incorrect in a quite a few data

-- 
The first major change of ofec_candidate_history_mv was documented in migration file V0135/V0137 (to solve issue #3736)

The calculation here for the election_year is similar to the election_yr_to_be_included column in ofec_cand_cmte_linkage table, but not exactly the same.  
The purpose of election_yr_to_be_included is to calculated the election_cycle the cycle financial data belongs to and an odd year will be rounded up and folded into its even year cycle.  
Here the election_year is for the election year, an odd election year need to be preserved, separated from its even year cycle.
The calculation is based on the fec_election_yr, the cand_election_yr, the cycle length (6, 4, 2), the next_election 
Simple and straight foward rules first, followed by more complicated rules.  

NOTE: there are some cand_id (219 out of 40152) that has one election_yr's data does not fit the fec_election_yr and candidate_election_yr and can not fit in any of the following rule. 
cycles,
election_years,
election_districts,
active_through
were still based on the original cand_election_yr from disclosure.cand_valid_fec_yr
so the interface will not be impacted.
Only candidate_election_year information is updated 


-- In this issue (#4156)
In previous version, we assume the overall cand_election_id in disclosure.cand_valid_fec_yr for a candidate is correct, 
  just the correlation on fec_election_yr and cand_election_yr are often mismatched due to the way this table is populated.
  
However, in this issue, cand_election_yr is missing for H6MD08549 (and some other candidate), that caused the calculation of cand_election_yr missing 2018, 
  also the election_years (which was based on the original cand_election_yr in disclosure.cand_valid_fec_yr) also missing 2018

So, in this version of ofec_candidate_history_mv
One additional rule (#82) had been added to consult nml_form_2/2z when data in disclosure.cand_valid_fec_yr itself is ambiguous to deduct the correlated cand_election_yr
the election_years, election_districts, active_through also are calculated using the calculated cand_election_yr

Note:  there are 34 candidates with no reliable calculated cand_election_yr that fits any of the rule.  In these cases, the original cand_election_yr are used instead.

Note:  There are several tables that has cand_election_yr.  However, they are not completely consistent with each other and none are completely correct. 
Since disclosure.cand_valid_fec_yr is the one with the correlation of fec_election_yr and cand_election_yr and is the base of this MV, we tried to keep data as close to this table as possible.
only consult nml_form_2/2Z if necessary.

*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_candidate_history_mv_tmp AS 
WITH
f2_cand_election_yr AS
(select cand_id, election_yr AS f2_election_yr 
	from 
	(select cand_id, election_yr
	from disclosure.nml_form_2
	union
	select cand_id, coalesce(election_yr, rpt_yr+rpt_yr%2) as election_yr
	from disclosure.nml_form_2z
	) f2
	group by cand_id, election_yr
), cycle_data_available AS (
	select max(fec_election_yr) max_cycle_available
	,min(fec_election_yr) min_cycle_available
	from disclosure.cand_valid_fec_yr
), election_yr AS (
    SELECT cand_id,
    cand_election_yr
    FROM disclosure.cand_valid_fec_yr
    GROUP BY cand_id, cand_election_yr
), cand_election_yrs AS (
    SELECT election_yr.cand_id,
    election_yr.cand_election_yr,
    lead(election_yr.cand_election_yr) OVER (PARTITION BY election_yr.cand_id ORDER BY election_yr.cand_election_yr) AS next_election
    FROM election_yr
)
, calculate_cand_elec_yr as (
	SELECT cand.cand_valid_yr_id,
		cand.cand_id,
		cand.fec_election_yr,
		cand.cand_election_yr,
		cand.cand_status,
		cand.cand_ici,
		cand.cand_office,
		cand.cand_office_st,
		cand.cand_office_district,
		cand.cand_pty_affiliation,
		cand.cand_name,
		cand.cand_st1,
		cand.cand_st2,
		cand.cand_city,
		cand.cand_state,
		cand.cand_zip,
		cand.race_pk,
		cand.lst_updt_dt,
		cand.latest_receipt_dt,
		cand.user_id_entered,
		cand.date_entered,
		cand.user_id_changed,
		cand.date_changed,
		cand.ref_cand_pk,
		cand.ref_lst_updt_dt,
		cycle_data_available.max_cycle_available,
		cycle_data_available.min_cycle_available,
	CASE
		-- #1
		-- when the cand_election_yr is greater than the max cycle data available, can not calculate based on fec_election_cycle, just take the value as it is
		WHEN cand.cand_election_yr > cycle_data_available.max_cycle_available THEN cand.cand_election_yr
		-- #2
		-- when the cand_election_yr is earlier than the min cycle data available, can not calculate based on fec_election_cycle, just take the value as it is
		WHEN cand.cand_election_yr < cycle_data_available.min_cycle_available THEN cand.cand_election_yr
		-- #3
		WHEN cand.cand_election_yr = cand.fec_election_yr THEN cand.cand_election_yr
		-- #4
		-- handle odd year House here since it is simple.  P and S need more consideration and are handled in the following rules.
		WHEN cand.cand_election_yr%2 = 1 and substr(cand.cand_id::text, 1, 1) = 'H' THEN
		    CASE 
		    WHEN cand.fec_election_yr <= cand.cand_election_yr+cand.cand_election_yr%2 then cand.cand_election_yr
		    ELSE NULL
		    END
		-- #5 
		-- when this is the last election this candidate has, and the fec_election_yr falls in this candidate election cycle. 
		WHEN yrs.next_election IS NULL THEN
		    CASE
		    WHEN cand.fec_election_yr <= yrs.cand_election_yr+yrs.cand_election_yr%2 AND (yrs.cand_election_yr-cand.fec_election_yr < candidate_election_duration (cand.cand_id)) 
		    THEN yrs.cand_election_yr
		    ELSE NULL::numeric
		    END
		-- #6
		-- this is a special case of #7
		WHEN cand.fec_election_yr > cand.cand_election_yr AND yrs.next_election%2 =1 and cand.fec_election_yr < yrs.next_election AND cand.fec_election_yr <= (yrs.next_election+yrs.next_election%2 - candidate_election_duration (cand.cand_id)) 
		THEN null
		-- #7
		-- when fec_election_yr is between previous cand_election and next_election, and fec_election_cycle is within the duration of the next_election cycle
		WHEN cand.fec_election_yr > cand.cand_election_yr AND cand.fec_election_yr < yrs.next_election AND cand.fec_election_yr > (yrs.next_election - candidate_election_duration (cand.cand_id)) 
		THEN yrs.next_election
		-- #81
		-- when fec_election_yr is after previous cand_election, but NOT within the duration of the next_election cycle (previous cand_election and the next_election has gaps)
		WHEN cand.fec_election_yr > cand.cand_election_yr AND cand.fec_election_yr < (yrs.next_election - candidate_election_duration (cand.cand_id)) 
		THEN NULL::numeric
		-- #82
		-- when fec_election_yr is after previous cand_election, and fec_election_yr is the same as the duration, but not fit #3 above, 
		--  it means the cand_election_yr in cand_valid_fec_yr is not correct.  Need to check nml_form_2/2z to see if this is a real election yr for this candidate 
		WHEN cand.fec_election_yr > cand.cand_election_yr AND cand.fec_election_yr = (yrs.next_election - candidate_election_duration (cand.cand_id)) 
		THEN f2.f2_election_yr::numeric
		-- #9
		-- fec_election_yr are within THIS election_cycle
		WHEN cand.fec_election_yr < cand.cand_election_yr AND (yrs.cand_election_yr-cand.fec_election_yr < candidate_election_duration (cand.cand_id)) 
		THEN yrs.cand_election_yr
		-- 
	ELSE NULL::numeric
	END::numeric(4,0) AS election_year
	, yrs.next_election
	FROM disclosure.cand_valid_fec_yr cand
	LEFT JOIN cand_election_yrs yrs ON cand.cand_id = yrs.cand_id AND cand.cand_election_yr = yrs.cand_election_yr
	LEFT JOIN f2_cand_election_yr f2 ON cand.cand_id = f2.cand_id AND cand.fec_election_yr = (f2.f2_election_yr+f2.f2_election_yr%2)
	, cycle_data_available
	ORDER BY cand_id, fec_election_yr
)
, fec_yr AS (
	SELECT distinct on (cand_id, fec_election_yr, election_year) 
	cand_valid_yr_id,
	cand_id,
	fec_election_yr,
	cand_election_yr,
	cand_status,
	cand_ici,
	cand_office,
	cand_office_st,
	cand_office_district,
	cand_pty_affiliation,
	cand_name,
	cand_st1,
	cand_st2,
	cand_city,
	cand_state,
	cand_zip,
	race_pk,
	lst_updt_dt,
	latest_receipt_dt,
	user_id_entered,
	date_entered,
	user_id_changed,
	date_changed,
	ref_cand_pk,
	ref_lst_updt_dt,
	max_cycle_available,
	min_cycle_available,
	election_year
FROM calculate_cand_elec_yr
ORDER BY cand_id, fec_election_yr, election_year
), districts AS (
	SELECT dedup.cand_id,
	array_agg(dedup.cand_office_district)::text[] AS election_districts
	FROM 
	( 
		SELECT DISTINCT ON (fec_yr_1.cand_id, fec_yr_1.election_year) 
		fec_yr_1.cand_id,
		fec_yr_1.cand_office_district,
		fec_yr_1.election_year
		FROM fec_yr fec_yr_1
		where fec_yr_1.election_year is not null
		ORDER BY fec_yr_1.cand_id, fec_yr_1.election_year, fec_yr_1.fec_election_yr
	) dedup  
	GROUP BY dedup.cand_id
), districts_alt AS (
	SELECT dedup.cand_id,
	array_agg(dedup.cand_office_district)::text[] AS election_districts
	FROM 
	( 
		SELECT DISTINCT ON (fec_yr_1.cand_id, fec_yr_1.cand_election_yr) 
		fec_yr_1.cand_id,
		fec_yr_1.cand_election_yr,
		fec_yr_1.cand_office_district
		FROM fec_yr fec_yr_1
		ORDER BY fec_yr_1.cand_id, fec_yr_1.cand_election_yr, fec_yr_1.fec_election_yr
	) dedup  
	GROUP BY dedup.cand_id
), cycles AS (
	SELECT fec_yr_1.cand_id,
	coalesce(max(election_year), max(cand_election_yr)) as active_through,
	--
	coalesce(array_agg(DISTINCT fec_yr_1.election_year) FILTER (WHERE fec_yr_1.election_year IS NOT NULL)::integer[],array_agg(DISTINCT fec_yr_1.cand_election_yr)::integer[])  as election_years,
	coalesce(array_agg(DISTINCT fec_yr_1.election_year+fec_yr_1.election_year%2) FILTER (WHERE fec_yr_1.election_year IS NOT NULL)::integer[], array_agg(DISTINCT fec_yr_1.cand_election_yr+fec_yr_1.cand_election_yr%2)::integer[]) as rounded_election_years,	
	array_agg(distinct fec_yr_1.fec_election_yr)::integer[] AS cycles,
	max(distinct fec_yr_1.fec_election_yr) AS max_cycle
	FROM fec_yr fec_yr_1
	GROUP BY fec_yr_1.cand_id
), dates AS (
-- financial reports such as F3 and F3P should be filed under cmte_id, not cand_id, however, there are some reports are filed under cand_id in the past.  therefore last_file_date and last_f2_date may not be the same
	SELECT f_rpt_or_form_sub.cand_cmte_id AS cand_id,
	min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
	max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
	max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE f_rpt_or_form_sub.form_tp::text = 'F2'::text) AS last_f2_date
	FROM disclosure.f_rpt_or_form_sub
	where substr(cand_cmte_id, 1, 1) in ('S','H','P')
	GROUP BY f_rpt_or_form_sub.cand_cmte_id
), 
-- this is for fec_cycles that will be included in calculation of candidate financial activities (election_yr_to_be_included is not null)
fec_cycles_in_election AS (
	SELECT cand_id,
	array_agg(distinct fec_election_yr)::integer[] AS fec_cycles_in_election
	FROM public.ofec_cand_cmte_linkage_vw
	WHERE election_yr_to_be_included is not null
	and cmte_dsgn in ('P', 'A')
	GROUP BY cand_id
)
SELECT row_number() OVER () AS idx,
    fec_yr.lst_updt_dt AS load_date,
    fec_yr.fec_election_yr AS two_year_period,
    fec_yr.election_year AS candidate_election_year,
    fec_yr.cand_id AS candidate_id,
    fec_yr.cand_name AS name,
    fec_yr.cand_state AS address_state,
    fec_yr.cand_city AS address_city,
    fec_yr.cand_st1 AS address_street_1,
    fec_yr.cand_st2 AS address_street_2,
    fec_yr.cand_zip AS address_zip,
    fec_yr.cand_ici AS incumbent_challenge,
    expand_candidate_incumbent(fec_yr.cand_ici::text) AS incumbent_challenge_full,
    fec_yr.cand_status AS candidate_status,
    inactive.cand_id IS NOT NULL AS candidate_inactive,
    fec_yr.cand_office AS office,
    expand_office(fec_yr.cand_office::text) AS office_full,
    fec_yr.cand_office_st AS state,
    fec_yr.cand_office_district AS district,
    fec_yr.cand_office_district::integer AS district_number,
    fec_yr.cand_pty_affiliation AS party,
    clean_party(ref_party.pty_desc::text) AS party_full,
    cycles.cycles,
    dates.first_file_date::text::date AS first_file_date,
    dates.last_file_date::text::date AS last_file_date,
    dates.last_f2_date::text::date AS last_f2_date,
    cycles.election_years,
    coalesce(districts.election_districts, districts_alt.election_districts) as election_districts,
    cycles.active_through,
    fec_cycles_in_election.fec_cycles_in_election,
    cycles.rounded_election_years
FROM fec_yr
LEFT JOIN cycles USING (cand_id)
LEFT JOIN districts USING (cand_id)
LEFT JOIN districts_alt USING (cand_id)
LEFT JOIN dates USING (cand_id)
LEFT JOIN fec_cycles_in_election USING (cand_id)
LEFT JOIN disclosure.cand_inactive inactive ON fec_yr.cand_id = inactive.cand_id AND fec_yr.election_year = inactive.election_yr
LEFT JOIN staging.ref_pty ref_party ON fec_yr.cand_pty_affiliation::text = ref_party.pty_cd::text
WHERE cycles.max_cycle >= 1979::numeric AND NOT (fec_yr.cand_id::text IN 
( SELECT DISTINCT unverified_filers_vw.cmte_id
   FROM unverified_filers_vw
  WHERE unverified_filers_vw.cmte_id::text ~ similar_escape('(P|S|H)%'::text, NULL::text)))
WITH DATA;

-- permissions:
ALTER TABLE public.ofec_candidate_history_mv_tmp
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_candidate_history_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_candidate_history_mv_tmp TO fec_read;



-- indexes:
CREATE INDEX idx_ofec_candidate_history_mv_tmp_1st_file_dt
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (first_file_date);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cand_id
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cycle
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (two_year_period);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_cycle_cand_id
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (two_year_period, candidate_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_dstrct
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (district COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_dstrct_nbr
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (district_number);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_load_dt
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (load_date);

CREATE INDEX idx_ofec_candidate_history_mv_tmp_office
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (office COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_candidate_history_mv_tmp_state
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (state COLLATE pg_catalog."default");

CREATE UNIQUE INDEX idx_ofec_candidate_history_mv_tmp_idx
  ON public.ofec_candidate_history_mv_tmp
  USING btree
  (idx);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_candidate_history_vw AS 
SELECT * FROM public.ofec_candidate_history_mv_tmp;
-- ---------------
-- drop the original materialized view:
DROP MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv;

-- rename the tmp MV to be real mv:
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_candidate_history_mv_tmp RENAME TO ofec_candidate_history_mv;

-- rename indexes:
ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_1st_file_dt RENAME TO idx_ofec_candidate_history_mv_1st_file_dt;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_cand_id RENAME TO idx_ofec_candidate_history_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_cycle RENAME TO idx_ofec_candidate_history_mv_cycle;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_cycle_cand_id RENAME TO idx_ofec_candidate_history_mv_cycle_cand_id;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_dstrct RENAME TO idx_ofec_candidate_history_mv_dstrct;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_dstrct_nbr RENAME TO idx_ofec_candidate_history_mv_dstrct_nbr;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_load_dt RENAME TO idx_ofec_candidate_history_mv_load_dt; 

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_office RENAME TO idx_ofec_candidate_history_mv_office;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_state RENAME TO idx_ofec_candidate_history_mv_state;

ALTER INDEX IF EXISTS idx_ofec_candidate_history_mv_tmp_idx RENAME TO idx_ofec_candidate_history_mv_idx;
