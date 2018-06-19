CREATE TABLE IF NOT EXISTS disclosure.entity_chart
(
 idx	numeric	
 ,month	numeric	NOT NULL
 ,year	numeric	NOT NULL
 ,cycle	numeric	NOT NULL
 ,end_date	numeric	
 ,total_candidate_receipts	numeric	
 ,total_candidate_disbursements	numeric	
 ,total_pac_receipts	numeric	
 ,total_pac_disbursements	numeric	
 ,total_party_receipts	numeric	
 ,total_party_disbursements	numeric	
 ,pg_date	timestamp without time zone DEFAULT now()
,CONSTRAINT entity_chart_pkey PRIMARY KEY (month,year,cycle)
)
WITH (OIDS=FALSE);
ALTER TABLE disclosure.entity_chart OWNER TO fec;
GRANT ALL ON TABLE disclosure.entity_chart TO fec;
GRANT SELECT ON TABLE disclosure.entity_chart TO fec_read;
