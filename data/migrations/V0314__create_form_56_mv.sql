/*
This migration file is for issue #5361. 
It creates a new view and materialized view pair for the H4 endpoint
*/
DROP MATERIALIZED VIEW IF EXISTS public.ofec_form_56_mv;

CREATE MATERIALIZED VIEW public.ofec_form_56_mv AS
SELECT f56.entity_tp AS entity_type,
f56.entity_tp_desc AS entity,
f56.conbtr_city AS contributor_city,
f56.contbr_st1 AS contributor_street_1,
f56.contbr_st2 AS contributor_street_2,
f56.contbr_st AS contributor_state,
f56.contbr_zip AS contributor_zip,
f56.contb_dt AS contribution_receipt_date,
f56.contb_amt AS contribution_amount,
f56.action_cd AS amendment_indicator,
f56.action_cd_desc AS amendment_indicator_desc,
f56.tran_id AS transaction_id,
f56.schedule_type AS schedule_type,
f56.schedule_type_desc AS schedule_type_full,
f56.image_num AS image_number,
f56.file_num AS file_number,
f56.link_id AS link_id,
f56.orig_sub_id AS original_sub_id,
f56.sub_id AS sub_id,
f56.filing_form AS filing_form,
f56.rpt_tp AS report_type,
f56.rpt_yr AS report_year,
f56.election_cycle AS election_cycle,
f56.pg_date AS load_date,
f56.contbr_nm AS contributor_name,
f56.contbr_employer AS contributor_employer,
f56.contbr_occupation AS contributor_occupation,
to_tsvector(parse_fulltext(f56.contbr_nm)) as contributor_name_text,
to_tsvector(parse_fulltext(f56.contbr_employer)) as contributor_employer_text,
to_tsvector(parse_fulltext(f56.contbr_occupation)) as contributor_occupation_text
FROM disclosure.fec_fitem_f56 f56;

-- grant correct ownership/permission
ALTER TABLE public.ofec_form_56_mv
  OWNER TO fec;
GRANT ALL ON TABLE public.ofec_form_56_mv TO fec;
GRANT SELECT ON TABLE public.ofec_form_56_mv TO fec_read;

-- create index on the ofec_form_56_mv (should support sort by contribution_receipt_date, & contribution_amount)
CREATE UNIQUE INDEX idx_ofec_form_56_mv_date_amount_sub ON public.ofec_form_56_mv USING btree (contribution_receipt_date, contribution_amount, sub_id);

CREATE INDEX idx_ofec_form_56_mv_entity_type ON public.ofec_form_56_mv USING btree (entity_type);

CREATE INDEX idx_ofec_form_56_mv_contributor_city ON public.ofec_form_56_mv USING btree (contributor_city);

CREATE INDEX idx_ofec_form_56_mv_contributor_state ON public.ofec_form_56_mv USING btree (contributor_state);

CREATE INDEX idx_ofec_form_56_mv_contributor_zip ON public.ofec_form_56_mv USING btree (contributor_zip);

CREATE INDEX idx_ofec_form_56_mv_contribution_receipt_date ON public.ofec_form_56_mv USING btree (contribution_receipt_date);

CREATE INDEX idx_ofec_form_56_mv_contribution_amount ON public.ofec_form_56_mv USING btree (contribution_amount);

CREATE INDEX idx_ofec_form_56_mv_image_number ON public.ofec_form_56_mv USING btree (image_number);

CREATE INDEX idx_ofec_form_56_mv_sub_id ON public.ofec_form_56_mv USING btree (sub_id);

CREATE INDEX idx_ofec_form_56_mv_report_year ON public.ofec_form_56_mv USING btree (report_year);

CREATE INDEX idx_ofec_form_56_mv_election_cycle ON public.ofec_form_56_mv USING btree (election_cycle);

CREATE INDEX idx_ofec_form_56_mv_report_type ON public.ofec_form_56_mv USING btree (report_type);

CREATE INDEX idx_ofec_form_56_mv_contributor_name_text ON public.ofec_form_56_mv USING btree (contributor_name_text);

CREATE INDEX idx_ofec_form_56_mv_contributor_employer_text ON public.ofec_form_56_mv USING gin (contributor_employer_text);

CREATE INDEX idx_ofec_form_56_mv_contributor_occupation_text ON public.ofec_form_56_mv USING gin (contributor_occupation_text);

