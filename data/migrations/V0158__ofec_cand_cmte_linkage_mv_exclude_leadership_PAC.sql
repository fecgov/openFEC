/*
This is to solve issue #3907
Also partially solve issue #3925
A new linkage type (leadership PAC and their sponsor candidates) had been added to the cand_cmte_linkage table. 
A federal office holder can sponsor a leadership PAC. But, that doesn't mean the person has to be running for re-election, so they might not be a candidate.
A candidate who is not an officeholder can also sponsor a leadership PAC.

We want to make sure that we do not include any of the financial activity of the leadership PAC in the financial summary of the candidate's campaign committees.
Therefore restriction is added to ofec_cand_cmte_linkage_mv  
to make sure leadership PAC (cmte_dsgn=D) is excluded in the calculation of candidate totals.

Since this mv is also used in addition to finacial activity, these D rows are included.  
However, the overall calculation on election_yr_to_be_included had excluded these rows 
  and election_yr_to_be_included column of these rows will be empty as well.

In addition, in the children MVs that involved in candidate financial summary calculation, only cmte_dsgn in ('P', 'A') rows are included, 
  further ensure these rows will not be included in the calculation of candidate financial summary.

Also added the rule to exclude the committees that are not candidate committtees 
but have cmte_dsgn in P/A (in the calulation of totals in children MVs) in the calculaltion of election_yr_to_be_included
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp;
CREATE MATERIALIZED VIEW ofec_cand_cmte_linkage_mv_tmp AS
WITH 
election_yr AS (
    SELECT cand_cmte_linkage.cand_id,
    cand_cmte_linkage.cand_election_yr AS orig_cand_election_yr,
    cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric AS cand_election_yr
    FROM disclosure.cand_cmte_linkage
    WHERE substr(cand_id::text, 1, 1) = cmte_tp::text
    -- OR (cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
    --
    AND coalesce(cmte_dsgn, '0') <> 'D' and coalesce(linkage_type, '0') <> 'D'
    GROUP BY cand_cmte_linkage.cand_id, cand_election_yr, (cand_cmte_linkage.cand_election_yr + cand_cmte_linkage.cand_election_yr % 2::numeric)
), cand_election_yrs AS (
    SELECT election_yr.cand_id,
    election_yr.orig_cand_election_yr,
    election_yr.cand_election_yr,
    lead(election_yr.cand_election_yr) OVER (PARTITION BY election_yr.cand_id ORDER BY election_yr.orig_cand_election_yr) AS next_election
    FROM election_yr
)
SELECT row_number() OVER () AS idx,
    link.linkage_id,
    link.cand_id,
    link.cand_election_yr,
    link.fec_election_yr,
    link.cmte_id,
    link.cmte_tp,
    link.cmte_dsgn,
    link.linkage_type,
    link.user_id_entered,
    link.date_entered,
    link.user_id_changed,
    link.date_changed,
    link.cmte_count_cand_yr,
    link.efile_paper_ind,
    link.pg_date,
    -- only candidate committees should have election_yr_to_be_included calculated
    CASE WHEN substr(link.cand_id::text, 1, 1) = link.cmte_tp::text THEN
      CASE
      -- #0 
            WHEN (link.cmte_dsgn = 'D' or linkage_type = 'D') THEN null      
      -- #1
            WHEN link.cand_election_yr = link.fec_election_yr THEN link.cand_election_yr
	    -- #2
    	-- handle odd year House here since it is simple.  P and S need more consideration and are handled in the following rules.
            WHEN link.cand_election_yr%2 = 1 and substr(link.cand_id::text, 1, 1) = 'H' THEN
              CASE 
              WHEN link.fec_election_yr <= link.cand_election_yr+link.cand_election_yr%2 then link.cand_election_yr+link.cand_election_yr%2
              ELSE NULL
              END
      -- #3
	    -- when this is the last election this candidate has, and the fec_election_yr falls in this candidate election cycle. 
            WHEN yrs.next_election IS NULL THEN
              CASE
              WHEN link.fec_election_yr <= yrs.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr < candidate_election_duration (link.cand_id))
              THEN yrs.cand_election_yr
              ELSE NULL::numeric
              END
	    -- #4
	    -- when fec_election_yr is between previous cand_election and next_election, and fec_election_cycle is within the duration of the next_election cycle
	    -- note: different from the calculation in candidate_history the next_election here is a rounded number so it need to include <
	          WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr > (yrs.next_election - candidate_election_duration (link.cand_id)) 
              AND ((link.cand_election_yr%2=1 AND link.fec_election_yr <= yrs.next_election) OR (link.cand_election_yr%2=0 AND link.fec_election_yr < yrs.next_election))
            THEN yrs.next_election
      -- #5
	    -- when fec_election_yr is after previous cand_election, but NOT within the duration of the next_election cycle (previous cand_election and the next_election has gaps)
            WHEN link.fec_election_yr > link.cand_election_yr AND link.fec_election_yr <= (yrs.next_election - candidate_election_duration (link.cand_id))
            THEN NULL::numeric
      -- #6                
	    -- fec_election_yr are within THIS election_cycle
            WHEN link.fec_election_yr < link.cand_election_yr AND (yrs.cand_election_yr-link.fec_election_yr < candidate_election_duration (link.cand_id))
            THEN yrs.cand_election_yr
        ELSE NULL::numeric
        END
    ELSE NULL::numeric
    END::numeric(4,0) AS election_yr_to_be_included
  FROM disclosure.cand_cmte_linkage link
     LEFT JOIN cand_election_yrs yrs ON link.cand_id::text = yrs.cand_id::text AND link.cand_election_yr = yrs.orig_cand_election_yr
  WHERE substr(link.cand_id::text, 1, 1) = link.cmte_tp::text OR (link.cmte_tp::text <> ALL (ARRAY['P'::character varying::text, 'S'::character varying::text, 'H'::character varying::text]))
  WITH DATA;

--Permissions
ALTER TABLE public.ofec_cand_cmte_linkage_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_cand_cmte_linkage_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_cand_cmte_linkage_mv_tmp TO fec_read;

--Indexes
CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cand_elec_yr
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cand_election_yr);

CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cand_id
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cand_id COLLATE pg_catalog."default");

CREATE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_cmte_id
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (cmte_id COLLATE pg_catalog."default");

CREATE UNIQUE INDEX idx_ofec_cand_cmte_linkage_mv_tmp_idx
  ON public.ofec_cand_cmte_linkage_mv_tmp
  USING btree
  (idx);

-- ---------------
CREATE OR REPLACE VIEW public.ofec_cand_cmte_linkage_vw AS 
SELECT * FROM public.ofec_cand_cmte_linkage_mv_tmp;
-- ---------------

-- drop old MV
DROP MATERIALIZED VIEW public.ofec_cand_cmte_linkage_mv;

-- rename _tmp mv to mv
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_cand_cmte_linkage_mv_tmp RENAME TO ofec_cand_cmte_linkage_mv;

-- rename indexes
ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_elec_yr RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_elec_yr;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cand_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cand_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_cmte_id RENAME TO idx_ofec_cand_cmte_linkage_mv_cmte_id;

ALTER INDEX IF EXISTS idx_ofec_cand_cmte_linkage_mv_tmp_idx RENAME TO idx_ofec_cand_cmte_linkage_mv_idx;



