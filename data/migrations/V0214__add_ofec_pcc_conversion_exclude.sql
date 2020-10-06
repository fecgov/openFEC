/*
This is to solve issue #4595
Ticket #4561 had documented most of the hisory of how the sql evolved.

** ofec_pcc_conversion_exclude table 
There are cases that data not consistent with reality that can not be captured by ofec_pcc_to_pac_mv
for example, 
- last registered to run 2018.  But F2z shows registered for 2022
- in dim_cmte_ie_inf table, revert back to rows created in earlier cycles (some revert back to rows entered more than 10 years ago) 
*/

DO $$
BEGIN
	EXECUTE format('create table public.ofec_pcc_conversion_exclude 
(cmte_id varchar(9)
,fec_election_yr numeric(4, 0)
,requester varchar(20)
,reason_for_exclude text
,pg_date timestamp without time zone default now()
,CONSTRAINT ofec_pcc_conversion_exclude_pkey PRIMARY KEY (cmte_id, fec_election_yr)
)
WITH (OIDS=FALSE)');
EXCEPTION 
WHEN duplicate_table THEN 
	null;
WHEN others THEN 
	RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;  
END$$;


ALTER TABLE public.ofec_pcc_conversion_exclude OWNER TO fec;
GRANT ALL ON TABLE public.ofec_pcc_conversion_exclude TO fec;
GRANT SELECT ON TABLE public.ofec_pcc_conversion_exclude TO fec_read;

