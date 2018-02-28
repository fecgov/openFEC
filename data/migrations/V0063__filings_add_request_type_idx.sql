--Create index on new filter field request_type. Should this be COALLATED?

CREATE INDEX ofec_filings_all_mv_request_type_idx1
  ON public.ofec_filings_all_mv
  USING btree
  (request_type);