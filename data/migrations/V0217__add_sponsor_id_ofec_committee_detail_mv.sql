/*
This migration file is for #4587
1) Add column sponsor_candidate_id to ofec_committee_detail_mv
*/

-- ----------
-- ofec_committee_detail_mv
-- ----------
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_detail_mv_tmp;

CREATE MATERIALIZED VIEW public.ofec_committee_detail_mv_tmp AS
SELECT DISTINCT ON (ofec_committee_history_vw.committee_id) ofec_committee_history_vw.idx,
    ofec_committee_history_vw.cycle,
    ofec_committee_history_vw.committee_id,
    ofec_committee_history_vw.name,
    ofec_committee_history_vw.treasurer_name,
    ofec_committee_history_vw.treasurer_text,
    ofec_committee_history_vw.organization_type,
    ofec_committee_history_vw.organization_type_full,
    ofec_committee_history_vw.street_1,
    ofec_committee_history_vw.street_2,
    ofec_committee_history_vw.city,
    ofec_committee_history_vw.state,
    ofec_committee_history_vw.state_full,
    ofec_committee_history_vw.zip,
    ofec_committee_history_vw.treasurer_city,
    ofec_committee_history_vw.treasurer_name_1,
    ofec_committee_history_vw.treasurer_name_2,
    ofec_committee_history_vw.treasurer_name_middle,
    ofec_committee_history_vw.treasurer_phone,
    ofec_committee_history_vw.treasurer_name_prefix,
    ofec_committee_history_vw.treasurer_state,
    ofec_committee_history_vw.treasurer_street_1,
    ofec_committee_history_vw.treasurer_street_2,
    ofec_committee_history_vw.treasurer_name_suffix,
    ofec_committee_history_vw.treasurer_name_title,
    ofec_committee_history_vw.treasurer_zip,
    ofec_committee_history_vw.custodian_city,
    ofec_committee_history_vw.custodian_name_1,
    ofec_committee_history_vw.custodian_name_2,
    ofec_committee_history_vw.custodian_name_middle,
    ofec_committee_history_vw.custodian_name_full,
    ofec_committee_history_vw.custodian_phone,
    ofec_committee_history_vw.custodian_name_prefix,
    ofec_committee_history_vw.custodian_state,
    ofec_committee_history_vw.custodian_street_1,
    ofec_committee_history_vw.custodian_street_2,
    ofec_committee_history_vw.custodian_name_suffix,
    ofec_committee_history_vw.custodian_name_title,
    ofec_committee_history_vw.custodian_zip,
    ofec_committee_history_vw.email,
    ofec_committee_history_vw.fax,
    ofec_committee_history_vw.website,
    ofec_committee_history_vw.form_type,
    ofec_committee_history_vw.leadership_pac,
    ofec_committee_history_vw.lobbyist_registrant_pac,
    ofec_committee_history_vw.party_type,
    ofec_committee_history_vw.party_type_full,
    ofec_committee_history_vw.qualifying_date,
    ofec_committee_history_vw.first_file_date,
    ofec_committee_history_vw.last_file_date,
    ofec_committee_history_vw.last_f1_date,
    ofec_committee_history_vw.designation,
    ofec_committee_history_vw.designation_full,
    ofec_committee_history_vw.committee_type,
    ofec_committee_history_vw.committee_type_full,
    ofec_committee_history_vw.filing_frequency,
    ofec_committee_history_vw.party,
    ofec_committee_history_vw.party_full,
    ofec_committee_history_vw.cycles,
    ofec_committee_history_vw.candidate_ids,
    ofec_committee_history_vw.affiliated_committee_name,
    ofec_committee_history_vw.is_active,
    ofec_committee_history_vw.sponsor_candidate_ids
   FROM ofec_committee_history_vw
  ORDER BY ofec_committee_history_vw.committee_id, ofec_committee_history_vw.cycle DESC
WITH DATA;

--Permissions

ALTER TABLE public.ofec_committee_detail_mv_tmp OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_detail_mv_tmp TO fec;
GRANT SELECT ON TABLE public.ofec_committee_detail_mv_tmp TO fec_read;

--Indices

CREATE INDEX idx_ofec_committee_detail_mv_tmp_candidate_ids
    ON public.ofec_committee_detail_mv_tmp USING gin
    (candidate_ids);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_committee_id
    ON public.ofec_committee_detail_mv_tmp USING btree
    (committee_id);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_committee_type
    ON public.ofec_committee_detail_mv_tmp USING btree
    (committee_type);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_committee_type_full
    ON public.ofec_committee_detail_mv_tmp USING btree
    (committee_type_full);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_cycles
    ON public.ofec_committee_detail_mv_tmp USING gin
    (cycles);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_cycles_candidate_ids
    ON public.ofec_committee_detail_mv_tmp USING gin
    (cycles, candidate_ids);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_designation
    ON public.ofec_committee_detail_mv_tmp USING btree
    (designation);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_designation_full
    ON public.ofec_committee_detail_mv_tmp USING btree
    (designation_full);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_first_file_date
    ON public.ofec_committee_detail_mv_tmp USING btree
    (first_file_date);
CREATE UNIQUE INDEX idx_ofec_committee_detail_mv_tmp_idx
    ON public.ofec_committee_detail_mv_tmp USING btree
    (idx);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_last_file_date
    ON public.ofec_committee_detail_mv_tmp USING btree
    (last_file_date);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_name
    ON public.ofec_committee_detail_mv_tmp USING btree
    (name);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_organization_type
    ON public.ofec_committee_detail_mv_tmp USING btree
    (organization_type);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_organization_type_full
    ON public.ofec_committee_detail_mv_tmp USING btree
    (organization_type_full);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_party
    ON public.ofec_committee_detail_mv_tmp USING btree
    (party);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_party_full
    ON public.ofec_committee_detail_mv_tmp USING btree
    (party_full);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_state
    ON public.ofec_committee_detail_mv_tmp USING btree
    (state);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_treasurer_name
    ON public.ofec_committee_detail_mv_tmp USING btree
    (treasurer_name);
CREATE INDEX idx_ofec_committee_detail_mv_tmp_treasurer_text
    ON public.ofec_committee_detail_mv_tmp USING gin
    (treasurer_text);

-- ---------
CREATE OR REPLACE VIEW public.ofec_committee_detail_vw AS
SELECT * FROM public.ofec_committee_detail_mv_tmp;

ALTER TABLE public.ofec_committee_detail_vw OWNER TO fec;
GRANT ALL ON TABLE public.ofec_committee_detail_vw TO fec;
GRANT SELECT ON TABLE public.ofec_committee_detail_vw TO fec_read;

--rename
DROP MATERIALIZED VIEW IF EXISTS public.ofec_committee_detail_mv;
ALTER MATERIALIZED VIEW IF EXISTS public.ofec_committee_detail_mv_tmp RENAME TO ofec_committee_detail_mv;
-- ----------
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_idx RENAME TO idx_ofec_committee_detail_mv_idx;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_candidate_ids RENAME TO idx_ofec_committee_detail_mv_candidate_ids;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_committee_id RENAME TO idx_ofec_committee_detail_mv_committee_id;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_committee_type_full RENAME TO idx_ofec_committee_detail_mv_committee_type_full;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_committee_type RENAME TO idx_ofec_committee_detail_mv_committee_type;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_cycles_candidate_ids RENAME TO idx_ofec_committee_detail_mv_cycles_candidate_ids;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_cycles RENAME TO idx_ofec_committee_detail_mv_cycles;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_designation_full RENAME TO idx_ofec_committee_detail_mv_designation_full;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_designation RENAME TO idx_ofec_committee_detail_mv_designation;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_first_file_date RENAME TO idx_ofec_committee_detail_mv_first_file_date;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_last_file_date RENAME TO idx_ofec_committee_detail_mv_last_file_date;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_name RENAME TO idx_ofec_committee_detail_mv_name;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_organization_type_full RENAME TO idx_ofec_committee_detail_mv_organization_type_full;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_organization_type RENAME TO idx_ofec_committee_detail_mv_organization_type;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_party_full RENAME TO idx_ofec_committee_detail_mv_party_full;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_party RENAME TO idx_ofec_committee_detail_mv_party;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_state RENAME TO idx_ofec_committee_detail_mv_state;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_treasurer_name RENAME TO idx_ofec_committee_detail_mv_treasurer_name;
ALTER INDEX public.idx_ofec_committee_detail_mv_tmp_treasurer_text RENAME TO idx_ofec_committee_detail_mv_treasurer_text;
