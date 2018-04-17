-- add these index to aid the efile raw data filters
-- Since we change the API use real_efile.sa7 table instead of real_efile_sa7 view
-- dropping the unused view public.real_efile_sa7 view

CREATE INDEX real_efile_sa7_state_idx
  ON real_efile.sa7
  USING btree
  (state);

CREATE INDEX real_efile_sa7_comid_state_idx
  ON real_efile.sa7
  USING btree
  (comid,state);
  
CREATE INDEX ofec_committee_history_mv_tmp_state_idx1
  ON public.ofec_committee_history_mv
  USING btree
  (state);
  
CREATE INDEX ofec_committee_history_mv_tmp_comid_state_idx1
  ON public.ofec_committee_history_mv
  USING btree
  (committee_id,state);  

drop view if exists public.real_efile_sa7;

