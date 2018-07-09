--create entity_chart_vw

DROP VIEW IF EXISTS public.entity_chart_vw;
 
CREATE OR REPLACE VIEW public.entity_chart_vw AS
  SELECT entity_chart.idx,
         entity_chart.cycle,
         entity_chart.month,
         entity_chart.year,
         to_date(entity_chart.end_date::text, 'YYYYMMDD'::text) AS end_date,
         entity_chart.total_candidate_receipts AS cumulative_candidate_receipts,
         entity_chart.total_candidate_disbursements AS cumulative_candidate_disbursements,
         entity_chart.total_pac_receipts AS cumulative_pac_receipts,
         entity_chart.total_pac_disbursements AS cumulative_pac_disbursements,
         entity_chart.total_party_receipts AS cumulative_party_receipts,
         entity_chart.total_party_disbursements AS cumulative_party_disbursements
  FROM disclosure.entity_chart;


ALTER TABLE public.entity_chart_vw OWNER TO fec;

GRANT ALL ON TABLE public.entity_chart_vw TO fec;

GRANT SELECT ON TABLE public.entity_chart_vw TO fec_read;
