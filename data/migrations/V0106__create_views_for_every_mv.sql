CREATE OR REPLACE VIEW ofec_reports_presidential_vw AS SELECT * FROM ofec_reports_presidential_mv;
ALTER VIEW ofec_reports_presidential_vw OWNER TO fec;
GRANT SELECT ON ofec_reports_presidential_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_reports_house_senate_vw AS SELECT * FROM ofec_reports_house_senate_mv;
ALTER VIEW ofec_reports_house_senate_vw OWNER TO fec;
GRANT SELECT ON ofec_reports_house_senate_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_reports_pacs_parties_vw AS SELECT * FROM ofec_reports_pacs_parties_mv;
ALTER VIEW ofec_reports_pacs_parties_vw OWNER TO fec;
GRANT SELECT ON ofec_reports_pacs_parties_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_filings_all_vw AS SELECT * FROM ofec_filings_all_mv;
ALTER VIEW ofec_filings_all_vw OWNER TO fec;
GRANT SELECT ON ofec_filings_all_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_pacs_parties_vw AS SELECT * FROM ofec_totals_pacs_parties_mv;
ALTER VIEW ofec_totals_pacs_parties_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_pacs_parties_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_pacs_vw AS SELECT * FROM ofec_totals_pacs_mv;
ALTER VIEW ofec_totals_pacs_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_pacs_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_parties_vw AS SELECT * FROM ofec_totals_parties_mv;
ALTER VIEW ofec_totals_parties_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_parties_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_ie_only_vw AS SELECT * FROM ofec_totals_ie_only_mv;
ALTER VIEW ofec_totals_ie_only_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_ie_only_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_filings_vw AS SELECT * FROM ofec_filings_mv;
ALTER VIEW ofec_filings_vw OWNER TO fec;
GRANT SELECT ON ofec_filings_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_combined_vw AS SELECT * FROM ofec_totals_combined_mv;
ALTER VIEW ofec_totals_combined_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_combined_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_house_senate_vw AS SELECT * FROM ofec_totals_house_senate_mv;
ALTER VIEW ofec_totals_house_senate_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_house_senate_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_presidential_vw AS SELECT * FROM ofec_totals_presidential_mv;
ALTER VIEW ofec_totals_presidential_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_presidential_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_committee_fulltext_vw AS SELECT * FROM ofec_committee_fulltext_mv;
ALTER VIEW ofec_committee_fulltext_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_fulltext_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_a_aggregate_size_merged_vw AS SELECT * FROM ofec_sched_a_aggregate_size_merged_mv;
ALTER VIEW ofec_sched_a_aggregate_size_merged_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_a_aggregate_size_merged_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_entity_chart_vw AS SELECT * FROM ofec_entity_chart_mv;
ALTER VIEW ofec_entity_chart_vw OWNER TO fec;
GRANT SELECT ON ofec_entity_chart_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_report_pac_party_all_vw AS SELECT * FROM ofec_report_pac_party_all_mv;
ALTER VIEW ofec_report_pac_party_all_vw OWNER TO fec;
GRANT SELECT ON ofec_report_pac_party_all_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_fulltext_vw AS SELECT * FROM ofec_candidate_fulltext_mv;
ALTER VIEW ofec_candidate_fulltext_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_fulltext_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_totals_vw AS SELECT * FROM ofec_candidate_totals_mv;
ALTER VIEW ofec_candidate_totals_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_totals_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_flag_vw AS SELECT * FROM ofec_candidate_flag_mv;
ALTER VIEW ofec_candidate_flag_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_flag_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_totals_candidate_committees_vw AS SELECT * FROM ofec_totals_candidate_committees_mv;
ALTER VIEW ofec_totals_candidate_committees_vw OWNER TO fec;
GRANT SELECT ON ofec_totals_candidate_committees_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_house_senate_paper_amendments_vw AS SELECT * FROM ofec_house_senate_paper_amendments_mv;
ALTER VIEW ofec_house_senate_paper_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_house_senate_paper_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_committee_history_vw AS SELECT * FROM ofec_committee_history_mv;
ALTER VIEW ofec_committee_history_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_history_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_history_vw AS SELECT * FROM ofec_candidate_history_mv;
ALTER VIEW ofec_candidate_history_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_history_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_detail_vw AS SELECT * FROM ofec_candidate_detail_mv;
ALTER VIEW ofec_candidate_detail_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_detail_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_election_vw AS SELECT * FROM ofec_candidate_election_mv;
ALTER VIEW ofec_candidate_election_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_election_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_cand_cmte_linkage_vw AS SELECT * FROM ofec_cand_cmte_linkage_mv;
ALTER VIEW ofec_cand_cmte_linkage_vw OWNER TO fec;
GRANT SELECT ON ofec_cand_cmte_linkage_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_presidential_paper_amendments_vw AS SELECT * FROM ofec_presidential_paper_amendments_mv;
ALTER VIEW ofec_presidential_paper_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_presidential_paper_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_pac_party_paper_amendments_vw AS SELECT * FROM ofec_pac_party_paper_amendments_mv;
ALTER VIEW ofec_pac_party_paper_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_pac_party_paper_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_communication_cost_aggregate_candidate_vw AS SELECT * FROM ofec_communication_cost_aggregate_candidate_mv;
ALTER VIEW ofec_communication_cost_aggregate_candidate_vw OWNER TO fec;
GRANT SELECT ON ofec_communication_cost_aggregate_candidate_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_committee_detail_vw AS SELECT * FROM ofec_committee_detail_mv;
ALTER VIEW ofec_committee_detail_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_detail_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_electioneering_aggregate_candidate_vw AS SELECT * FROM ofec_electioneering_aggregate_candidate_mv;
ALTER VIEW ofec_electioneering_aggregate_candidate_vw OWNER TO fec;
GRANT SELECT ON ofec_electioneering_aggregate_candidate_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_electioneering_vw AS SELECT * FROM ofec_electioneering_mv;
ALTER VIEW ofec_electioneering_vw OWNER TO fec;
GRANT SELECT ON ofec_electioneering_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_communication_cost_vw AS SELECT * FROM ofec_communication_cost_mv;
ALTER VIEW ofec_communication_cost_vw OWNER TO fec;
GRANT SELECT ON ofec_communication_cost_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_house_senate_electronic_amendments_vw AS SELECT * FROM ofec_house_senate_electronic_amendments_mv;
ALTER VIEW ofec_house_senate_electronic_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_house_senate_electronic_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_presidential_electronic_amendments_vw AS SELECT * FROM ofec_presidential_electronic_amendments_mv;
ALTER VIEW ofec_presidential_electronic_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_presidential_electronic_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_pac_party_electronic_amendments_vw AS SELECT * FROM ofec_pac_party_electronic_amendments_mv;
ALTER VIEW ofec_pac_party_electronic_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_pac_party_electronic_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_reports_ie_only_vw AS SELECT * FROM ofec_reports_ie_only_mv;
ALTER VIEW ofec_reports_ie_only_vw OWNER TO fec;
GRANT SELECT ON ofec_reports_ie_only_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_e_aggregate_candidate_vw AS SELECT * FROM ofec_sched_e_aggregate_candidate_mv;
ALTER VIEW ofec_sched_e_aggregate_candidate_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_e_aggregate_candidate_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_c_vw AS SELECT * FROM ofec_sched_c_mv;
ALTER VIEW ofec_sched_c_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_c_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_f_vw AS SELECT * FROM ofec_sched_f_mv;
ALTER VIEW ofec_sched_f_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_f_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_elections_list_vw AS SELECT * FROM ofec_elections_list_mv;
ALTER VIEW ofec_elections_list_vw OWNER TO fec;
GRANT SELECT ON ofec_elections_list_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_fulltext_audit_vw AS SELECT * FROM ofec_candidate_fulltext_audit_mv;
ALTER VIEW ofec_candidate_fulltext_audit_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_fulltext_audit_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_audit_case_vw AS SELECT * FROM ofec_audit_case_mv;
ALTER VIEW ofec_audit_case_vw OWNER TO fec;
GRANT SELECT ON ofec_audit_case_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_audit_case_category_rel_vw AS SELECT * FROM ofec_audit_case_category_rel_mv;
ALTER VIEW ofec_audit_case_category_rel_vw OWNER TO fec;
GRANT SELECT ON ofec_audit_case_category_rel_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_audit_case_sub_category_rel_vw AS SELECT * FROM ofec_audit_case_sub_category_rel_mv;
ALTER VIEW ofec_audit_case_sub_category_rel_vw OWNER TO fec;
GRANT SELECT ON ofec_audit_case_sub_category_rel_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_committee_fulltext_audit_vw AS SELECT * FROM ofec_committee_fulltext_audit_mv;
ALTER VIEW ofec_committee_fulltext_audit_vw OWNER TO fec;
GRANT SELECT ON ofec_committee_fulltext_audit_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_a_aggregate_state_recipient_totals_vw AS SELECT * FROM ofec_sched_a_aggregate_state_recipient_totals_mv;
ALTER VIEW ofec_sched_a_aggregate_state_recipient_totals_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_a_aggregate_state_recipient_totals_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_candidate_history_with_future_election_vw AS SELECT * FROM ofec_candidate_history_with_future_election_mv;
ALTER VIEW ofec_candidate_history_with_future_election_vw OWNER TO fec;
GRANT SELECT ON ofec_candidate_history_with_future_election_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_agg_coverage_date_vw AS SELECT * FROM ofec_agg_coverage_date_mv;
ALTER VIEW ofec_agg_coverage_date_vw OWNER TO fec;
GRANT SELECT ON ofec_agg_coverage_date_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_sched_e_vw AS SELECT * FROM ofec_sched_e_mv;
ALTER VIEW ofec_sched_e_vw OWNER TO fec;
GRANT SELECT ON ofec_sched_e_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_amendments_vw AS SELECT * FROM ofec_amendments_mv;
ALTER VIEW ofec_amendments_vw OWNER TO fec;
GRANT SELECT ON ofec_amendments_vw TO fec_read;

CREATE OR REPLACE VIEW ofec_filings_amendments_all_vw AS SELECT * FROM ofec_filings_amendments_all_mv;
ALTER VIEW ofec_filings_amendments_all_vw OWNER TO fec;
GRANT SELECT ON ofec_filings_amendments_all_vw TO fec_read;
