/*
This migration file is for #4458
Add the following 5 columns to ofec_committee_history_mv:

convert_to_pac_flg,
pcc.first_cmte_nm as former_cmte_name,
pcc.cand_id as former_cand_id,
pcc.cand_name as former_cand_name,
pcc.candidate_election_year as former_cand_election_year
*/

-- ----------
-- ofec_pcc_to_pac_mv
-- same as in V0215 except using base table of ofec_totals_combined_mv to reduce MV inter dependency
-- ----------
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
Here we need to know if these committees file financial information, no matter which form they reported money from.  
Therefore get a cmte total per cycle.
** In issue #4458, ofec_committee_history_mv need to refers to ofec_pcc_to_pac_mv,
**  the complicated dependencies cause refresh sequences of MVs error out.
since we only need to if these committees file financial information or not, 
no need use whole ofec_totals_combined_vw.  Take the information from the base table of ofec_totals_combined_vw
using the same criteria.  Result had been compared to make sure it is the same.
*/
, TOTALS AS
(
    SELECT vsd.cmte_id AS committee_id,
    get_cycle(vsd.rpt_yr) AS cycle,
    sum(COALESCE(vsd.ttl_receipts, 0)) AS receipts,
    sum(COALESCE(vsd.ttl_disb, 0)) AS disbursements
    FROM disclosure.v_sum_and_det_sum_report vsd
    WHERE get_cycle(vsd.rpt_yr) >= 1979 AND (vsd.form_tp_cd::text <> 'F5'::text OR vsd.form_tp_cd::text = 'F5'::text AND (vsd.rpt_tp::text <> ALL (ARRAY['24'::character varying::text, '48'::character varying::text]))) AND (vsd.form_tp_cd::text <> ALL (ARRAY['F6'::text, 'SL'::text]))
    GROUP BY vsd.cmte_id, (get_cycle(vsd.rpt_yr))
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



-- ----------
-- ofec_committee_history_mv
-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_history_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_committee_history_mv_tmp AS
WITH cycles AS 
(
    SELECT cmte_valid_fec_yr.cmte_id,
    array_agg(cmte_valid_fec_yr.fec_election_yr) FILTER (WHERE cmte_valid_fec_yr.fec_election_yr is not NULL)::integer[] AS cycles,
    max(cmte_valid_fec_yr.fec_election_yr) AS max_cycle
    FROM disclosure.cmte_valid_fec_yr
    GROUP BY cmte_valid_fec_yr.cmte_id
), dates AS 
(
    SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
    min(f_rpt_or_form_sub.receipt_dt) AS first_file_date,
    max(f_rpt_or_form_sub.receipt_dt) AS last_file_date,
    max(f_rpt_or_form_sub.receipt_dt) FILTER (WHERE f_rpt_or_form_sub.form_tp::text = 'F1'::text) AS last_f1_date,
    max(get_cycle(f_rpt_or_form_sub.rpt_yr)) AS last_cycle_has_activity,
    array_agg(DISTINCT get_cycle(f_rpt_or_form_sub.rpt_yr)) FILTER (WHERE f_rpt_or_form_sub.rpt_yr is not NULL) AS cycles_has_activity
    FROM disclosure.f_rpt_or_form_sub
    GROUP BY f_rpt_or_form_sub.cand_cmte_id
), candidates AS 
(
    SELECT cand_cmte_linkage.cmte_id,
    array_agg(DISTINCT cand_cmte_linkage.cand_id)::text[] AS candidate_ids
    FROM disclosure.cand_cmte_linkage
    GROUP BY cand_cmte_linkage.cmte_id
), reports AS 
(
    SELECT f_rpt_or_form_sub.cand_cmte_id AS cmte_id,
    max(get_cycle(f_rpt_or_form_sub.rpt_yr)) AS last_cycle_has_financial,
    array_agg(DISTINCT get_cycle(f_rpt_or_form_sub.rpt_yr)) FILTER (WHERE f_rpt_or_form_sub.rpt_yr is not NULL) AS cycles_has_financial
    FROM disclosure.f_rpt_or_form_sub
    WHERE upper(f_rpt_or_form_sub.form_tp::text) = ANY (ARRAY['F3'::text, 'F3X'::text, 'F3P'::text, 'F3L'::text, 'F4'::text, 'F5'::text, 'F7'::text, 'F13'::text, 'F24'::text, 'F6'::text, 'F9'::text, 'F10'::text, 'F11'::text])
    GROUP BY f_rpt_or_form_sub.cand_cmte_id
), leadership_pac_linkage AS 
(
    SELECT cand_cmte_linkage_alternate.cmte_id, cand_cmte_linkage_alternate.fec_election_yr,
    array_agg(DISTINCT cand_cmte_linkage_alternate.cand_id)::text[] AS sponsor_candidate_ids
    FROM disclosure.cand_cmte_linkage_alternate
    WHERE linkage_type = 'D'
    GROUP BY cand_cmte_linkage_alternate.cmte_id, cand_cmte_linkage_alternate.fec_election_yr
)
SELECT DISTINCT ON (fec_yr.cmte_id, fec_yr.fec_election_yr) row_number() OVER () AS idx,
    fec_yr.fec_election_yr AS cycle,
    fec_yr.cmte_id AS committee_id,
    fec_yr.cmte_nm AS name,
    fec_yr.tres_nm AS treasurer_name,
    to_tsvector(parse_fulltext(fec_yr.tres_nm::text)::text) AS treasurer_text,
    f1.org_tp AS organization_type,
    expand_organization_type(f1.org_tp::text) AS organization_type_full,
    fec_yr.cmte_st1 AS street_1,
    fec_yr.cmte_st2 AS street_2,
    fec_yr.cmte_city AS city,
    fec_yr.cmte_st AS state,
    expand_state(fec_yr.cmte_st::text) AS state_full,
    fec_yr.cmte_zip AS zip,
    f1.tres_city AS treasurer_city,
    f1.tres_f_nm AS treasurer_name_1,
    f1.tres_l_nm AS treasurer_name_2,
    f1.tres_m_nm AS treasurer_name_middle,
    f1.tres_ph_num AS treasurer_phone,
    f1.tres_prefix AS treasurer_name_prefix,
    f1.tres_st AS treasurer_state,
    f1.tres_st1 AS treasurer_street_1,
    f1.tres_st2 AS treasurer_street_2,
    f1.tres_suffix AS treasurer_name_suffix,
    f1.tres_title AS treasurer_name_title,
    f1.tres_zip AS treasurer_zip,
    f1.cust_rec_city AS custodian_city,
    f1.cust_rec_f_nm AS custodian_name_1,
    f1.cust_rec_l_nm AS custodian_name_2,
    f1.cust_rec_m_nm AS custodian_name_middle,
    f1.cust_rec_nm AS custodian_name_full,
    f1.cust_rec_ph_num AS custodian_phone,
    f1.cust_rec_prefix AS custodian_name_prefix,
    f1.cust_rec_st AS custodian_state,
    f1.cust_rec_st1 AS custodian_street_1,
    f1.cust_rec_st2 AS custodian_street_2,
    f1.cust_rec_suffix AS custodian_name_suffix,
    f1.cust_rec_title AS custodian_name_title,
    f1.cust_rec_zip AS custodian_zip,
    fec_yr.cmte_email AS email,
    f1.cmte_fax AS fax,
    fec_yr.cmte_url AS website,
    f1.form_tp AS form_type,
    f1.leadership_pac,
    f1.lobbyist_registrant_pac,
    f1.cand_pty_tp AS party_type,
    f1.cand_pty_tp_desc AS party_type_full,
    f1.qual_dt AS qualifying_date,
    dates.first_file_date::text::date AS first_file_date,
    dates.last_file_date::text::date AS last_file_date,
    dates.last_f1_date::text::date AS last_f1_date,
    fec_yr.cmte_dsgn AS designation,
    expand_committee_designation(fec_yr.cmte_dsgn::text) AS designation_full,
    fec_yr.cmte_tp AS committee_type,
    expand_committee_type(fec_yr.cmte_tp::text) AS committee_type_full,
    fec_yr.cmte_filing_freq AS filing_frequency,
    fec_yr.cmte_pty_affiliation AS party,
    fec_yr.cmte_pty_affiliation_desc AS party_full,
    cycles.cycles,
    COALESCE(candidates.candidate_ids, '{}'::text[]) AS candidate_ids,
    f1.affiliated_cmte_nm AS affiliated_committee_name,
    reports.last_cycle_has_financial,
    reports.cycles_has_financial,
    dates.last_cycle_has_activity,
    dates.cycles_has_activity,
    is_committee_active(fec_yr.cmte_filing_freq) AS is_active,
    l.sponsor_candidate_ids,
  (case when pcc.cand_id is null then false else true end)::bool as convert_to_pac_flg,
  pcc.first_cmte_nm as former_cmte_name, 
  pcc.cand_id as former_cand_id, 
  pcc.cand_name as former_cand_name,
  pcc.candidate_election_year as former_cand_election_year  
FROM disclosure.cmte_valid_fec_yr fec_yr
LEFT JOIN fec_vsum_f1_vw f1 ON fec_yr.cmte_id::text = f1.cmte_id::text AND fec_yr.fec_election_yr >= f1.rpt_yr
LEFT JOIN cycles ON fec_yr.cmte_id::text = cycles.cmte_id::text
LEFT JOIN dates ON fec_yr.cmte_id::text = dates.cmte_id::text
LEFT JOIN candidates ON fec_yr.cmte_id::text = candidates.cmte_id::text
LEFT JOIN reports ON fec_yr.cmte_id::text = reports.cmte_id::text
LEFT JOIN leadership_pac_linkage l ON fec_yr.cmte_id::text = l.cmte_id::text AND fec_yr.fec_election_yr = l.fec_election_yr
LEFT JOIN ofec_pcc_to_pac_vw pcc on pcc.cmte_id = fec_yr.cmte_id and pcc.fec_election_yr = fec_yr.fec_election_yr
WHERE cycles.max_cycle >= 1979::numeric AND NOT (fec_yr.cmte_id::text IN ( SELECT DISTINCT unverified_filers_vw.cmte_id
        FROM unverified_filers_vw
        WHERE unverified_filers_vw.cmte_id::text ~~ 'C%'::text))
ORDER BY fec_yr.cmte_id, fec_yr.fec_election_yr DESC, f1.rpt_yr DESC
WITH DATA;

--Permissions

ALTER TABLE public.ofec_committee_history_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_history_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_committee_history_mv_tmp TO fec_read;

--Indices

CREATE UNIQUE INDEX idx_ofec_committee_history_mv_tmp_idx
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (idx);
CREATE INDEX idx_ofec_committee_history_mv_tmp_committee_id
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (committee_id);
CREATE INDEX idx_ofec_committee_history_mv_tmp_cycle_committee_id
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (cycle, committee_id);
CREATE INDEX idx_ofec_committee_history_mv_tmp_cycle
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (cycle);
CREATE INDEX idx_ofec_committee_history_mv_tmp_designation
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (designation);
CREATE INDEX idx_ofec_committee_history_mv_tmp_first_file_date
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (first_file_date);
CREATE INDEX idx_ofec_committee_history_mv_tmp_name
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (name);
CREATE INDEX idx_ofec_committee_history_mv_tmp_state
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (state);
CREATE INDEX idx_ofec_committee_history_mv_tmp_comid_state
 ON public.ofec_committee_history_mv_tmp
 USING btree
 (committee_id, state);


-- ---------
CREATE OR REPLACE VIEW public.ofec_committee_history_vw AS
SELECT * FROM public.ofec_committee_history_mv_tmp;

ALTER TABLE public.ofec_committee_history_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_history_vw TO fec;
GRANT SELECT ON TABLE public.ofec_committee_history_vw TO fec_read;

-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_history_mv;
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_committee_history_mv_tmp RENAME TO ofec_committee_history_mv;
-- ----------
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_idx RENAME TO idx_ofec_committee_history_mv_idx;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_committee_id RENAME TO idx_ofec_committee_history_mv_committee_id;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_cycle_committee_id RENAME TO idx_ofec_committee_history_mv_cycle_committee_id;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_cycle RENAME TO idx_ofec_committee_history_mv_cycle;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_designation RENAME TO idx_ofec_committee_history_mv_designation;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_first_file_date RENAME TO idx_ofec_committee_history_mv_first_file_date;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_name RENAME TO idx_ofec_committee_history_mv_name;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_state RENAME TO idx_ofec_committee_history_mv_state;
ALTER INDEX public.idx_ofec_committee_history_mv_tmp_comid_state RENAME TO idx_ofec_committee_history_mv_comid_state;
