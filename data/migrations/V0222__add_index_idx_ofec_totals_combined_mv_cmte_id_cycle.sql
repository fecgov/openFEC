CREATE INDEX  IF NOT EXISTS  idx_ofec_totals_combined_mv_cmte_id_cycle ON ofec_totals_combined_mv USING btree (committee_id DESC NULLS LAST, cycle DESC NULLS LAST);
