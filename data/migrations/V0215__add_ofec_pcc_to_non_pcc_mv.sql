/*
This is to solve issue #4595
Ticket #4561 had documented most of the hisory of how the sql for this MV evolved.

To facilitate systematic tracking of the committees that convert from PCC to PAC mid cycle 

** dim_cmte_ie_inf:
The major table this tracking relying on is DISCLOSURE.DIM_CMTE_IE_INF (which is added in postgresql database with migration file V0212)
When a committee's cmte_tp or cmte_dsgn changed, there will be a new row added to DISCLOSURE.DIM_CMTE_IE_INF.  
There is no financial cycle (fec_election_yr) concept in the DISCLOSURE.DIM_CMTE_IE_INF, 
the fec_election_yr in this view is derived from the create_date column in the dim_cmte_ie_inf table. 

NOTE: revert back to rows created in earlier cycles (some revert back to rows entered more than 10 years ago)
no new rows created, just mst_rct_rcd_flg='Y' in the old record 
there is no way to trace it (revert back to row in the same cycle can be catched.)

The base concept is treat each financial cycle as a "window".  
If a cmte is a pcc at the beginning of the "window", and had been turned into a pac at the end of the "window", it will be included in this MV.

** ofec_cand_cmte_linkage_mv:
is used to link candidate and committee

** ofec_candidate_history_mv: 
is used to filter out the fec_election_yr that is not part of a election.

** ofec_totals_combined_mv:
is used to filter out committees that does not have financial activity (not filing report or money is 0)

According to Brad and Paul, 
Although money will dissociate from the candidate after convert to party, the PCC converted to Party (cmte_tp: X, Y) will be excluded as mid-cycle conversion. 
- A PCC is allowed to convert into PAC but not other type of committees,
- the specific language that is used on the web site is for PCC to PAC conversion.

** ofec_pcc_conversion_exclude table 
There are cases that data not consistent with reality 
for example, 
- last registered to run 2018.  But F2z shows registered for 2022
- in dim_cmte_ie_inf table, revert back to rows created in earlier cycles (some revert back to rows entered more than 10 years ago) 

*/
DROP VIEW IF EXISTS public.ofec_pcc_to_pac_vw;
DROP MATERIALIZED VIEW IF EXISTS public.ofec_pcc_to_pac_mv;

CREATE MATERIALIZED VIEW public.ofec_pcc_to_pac_mv
AS
with BASE_INFO as
(
	SELECT CMTE_PK, CMTE_ID, CMTE_NM, FILED_CMTE_TP, FILED_CMTE_DSGN, CREATE_DATE, 
	TO_CHAR(CREATE_DATE, 'YYYY')::numeric +MOD(TO_CHAR(CREATE_DATE, 'YYYY')::numeric , 2)::numeric (4, 0) as FEC_ELECTION_YR
	,SUBSTRING(CMTE_PK::varchar,10, 6) CREATE_TIME, MST_RCT_REC_FLG
	FROM DISCLOSURE.DIM_CMTE_IE_INF
	WHERE CREATE_DATE IS NOT NULL
	ORDER BY CMTE_ID, CREATE_DATE, CREATE_TIME
)
, first_record_per_cycle as 
(
	SELECT CMTE_PK, CMTE_ID, CMTE_NM, FILED_CMTE_TP, FILED_CMTE_DSGN, CREATE_DATE, CREATE_TIME, fec_election_yr, MST_RCT_REC_FLG
	,rank() over (partition by cmte_id, fec_election_yr order by create_date, CREATE_TIME) the_rank
	FROM BASE_INFO
)
, info_begin_cycle as
(
	select CMTE_PK, CMTE_ID
	,coalesce(lag(CMTE_NM) over (partition by cmte_id order by fec_election_yr),CMTE_NM)  as CMTE_NM
	,coalesce(lag(FILED_CMTE_TP) over (partition by cmte_id order by fec_election_yr),FILED_CMTE_TP)  as FILED_CMTE_TP
	,coalesce(lag(FILED_CMTE_DSGN) over (partition by cmte_id order by fec_election_yr),FILED_CMTE_DSGN)  as FILED_CMTE_DSGN
	,concat('1/1/',(fec_election_yr-1)::varchar)::timestamp as create_date
	,create_time
	,fec_election_yr, MST_RCT_REC_FLG
	from first_record_per_cycle
	where the_rank = 1
) 
, last_record_per_cycle as 
(
	SELECT CMTE_PK, CMTE_ID, CMTE_NM, FILED_CMTE_TP, FILED_CMTE_DSGN, CREATE_DATE, CREATE_TIME, fec_election_yr, MST_RCT_REC_FLG
	,rank() over (partition by cmte_id, fec_election_yr order by MST_RCT_REC_FLG desc, create_date desc, CREATE_TIME desc) the_rank
	FROM BASE_INFO
)
, info_end_cycle AS 
(
	SELECT CMTE_PK, CMTE_ID, CMTE_NM, FILED_CMTE_TP, FILED_CMTE_DSGN, CREATE_DATE, CREATE_TIME
	, fec_election_yr, MST_RCT_REC_FLG
	FROM last_record_per_cycle 
	where the_rank = 1
)
, CHANGE_CAPTURE AS 
(
	SELECT info_end_cycle.CMTE_ID 
	, info_begin_cycle.CMTE_NM AS FIRST_CMTE_NM
	, info_end_cycle.CMTE_NM AS LATEST_CMTE_NM
	, info_begin_cycle.FILED_CMTE_TP AS FIRST_CMTE_TP
	, info_end_cycle.FILED_CMTE_TP AS LATEST_CMTE_TP
	, info_begin_cycle.FILED_CMTE_DSGN AS FIRST_CMTE_DSGN
	, info_end_cycle.FILED_CMTE_DSGN AS LATEST_CMTE_DSGN
	, info_end_cycle.FEC_ELECTION_YR
	FROM info_end_cycle JOIN info_begin_cycle
	ON info_end_cycle.CMTE_ID = info_begin_cycle.CMTE_ID AND info_end_cycle.FEC_ELECTION_YR = info_begin_cycle.FEC_ELECTION_YR
	ORDER BY info_end_cycle.CMTE_ID, info_end_cycle.FEC_ELECTION_YR
)
/*
Some cand/cmte has special election that happened in the odd year,
followed by regular election in even year.  
For financial cycle purpose here, only care about the fec_election_yr.  
So only take one row per CAND_ID/CMTE_ID/FEC_ELECTION_YR
*/
, CAND_CMTE_LINKAGE AS
(
	SELECT CAND_ID, CMTE_ID, FEC_ELECTION_YR
	FROM ofec_cand_cmte_linkage_vw
	group by CAND_ID, CMTE_ID, FEC_ELECTION_YR
)
/*
some cmte filed different type of forms, either due to change of cmte_tp, or by mistakes
ofec_totals_combined_vw include form_type in ('F3', 'F3P', 'F3X').  
Here we need to know if this committees file financial information, no matter which form they reported money from.  
Therefore get a cmte total per cycle.
*/
, TOTALS AS
(
	SELECT COMMITTEE_ID, CYCLE, SUM(COALESCE(RECEIPTS, 0)) AS RECEIPTS, SUM(COALESCE(DISBURSEMENTS, 0)) AS DISBURSEMENTS
	FROM ofec_totals_combined_vw
	GROUP BY COMMITTEE_ID, CYCLE
)
SELECT CHANGE_CAPTURE.CMTE_ID
, CCL.CAND_ID
, cand_yr.name as cand_name
, cand_yr.candidate_election_year
, CHANGE_CAPTURE.FEC_ELECTION_YR
, CHANGE_CAPTURE.FIRST_CMTE_NM
, CHANGE_CAPTURE.LATEST_CMTE_NM
, CHANGE_CAPTURE.FIRST_CMTE_TP
, CHANGE_CAPTURE.FIRST_CMTE_DSGN
, CHANGE_CAPTURE.LATEST_CMTE_TP
, CHANGE_CAPTURE.LATEST_CMTE_DSGN
,totals.receipts, totals.disbursements
FROM CHANGE_CAPTURE
join CAND_CMTE_LINKAGE ccl 
on ccl.cmte_id = CHANGE_CAPTURE.cmte_id and ccl.fec_election_yr = CHANGE_CAPTURE.fec_election_yr
JOIN ofec_candidate_history_vw cand_yr
ON cand_yr.candidate_id  = ccl.cand_id and cand_yr.two_year_period = CHANGE_CAPTURE.fec_election_yr
LEFT JOIN totals ON totals.committee_id = CHANGE_CAPTURE.cmte_id and totals.cycle=CHANGE_CAPTURE.FEC_ELECTION_YR
WHERE
(
	((CHANGE_CAPTURE.FIRST_CMTE_TP IN ('H','P','S') and CHANGE_CAPTURE.FIRST_CMTE_DSGN IN ('P', 'A')) AND CHANGE_CAPTURE.LATEST_CMTE_TP NOT IN ('H','P','S'))
	OR (CHANGE_CAPTURE.FIRST_CMTE_DSGN IN ('P','A') AND CHANGE_CAPTURE.LATEST_CMTE_DSGN NOT IN ('P','A'))
)
and cand_yr.candidate_election_year is not null
and (COALESCE(receipts, 0) > 0 or COALESCE(disbursements, 0) > 0)
and (FIRST_CMTE_DSGN not IN ('J') AND LATEST_CMTE_DSGN NOT IN ('J'))
and LATEST_CMTE_TP NOT IN ('X','Y')
and (change_capture.cmte_id, change_capture.fec_election_yr) not in (select cmte_id, fec_election_yr from public.ofec_pcc_conversion_exclude)
ORDER BY CHANGE_CAPTURE.CMTE_ID, CHANGE_CAPTURE.FEC_ELECTION_YR;

alter table public.ofec_pcc_to_pac_mv owner to fec;
grant all on public.ofec_pcc_to_pac_mv to fec;
grant select on public.ofec_pcc_to_pac_mv to fec_read;

CREATE UNIQUE INDEX idx_ofec_pcc_to_pac_mv_cmte_id_fec_election_yr 
    ON public.ofec_pcc_to_pac_mv USING btree (cmte_id,fec_election_yr);

-- ------------------
CREATE OR REPLACE VIEW public.ofec_pcc_to_pac_vw 
AS select * from public.ofec_pcc_to_pac_mv;

alter table public.ofec_pcc_to_pac_vw owner to fec;
grant all on public.ofec_pcc_to_pac_vw to fec;
grant select on public.ofec_pcc_to_pac_vw to fec_read;

