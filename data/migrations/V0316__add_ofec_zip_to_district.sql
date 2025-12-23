/*
For issue # 6401, # 6402
Add new table ofec_zip_to_district. This table holds Zip Code to Congressional District data from 2012 to 2026
Data are imported separately from excel file 
*/

CREATE TABLE IF NOT EXISTS public.ofec_zip_to_district
(
    election_year integer NOT NULL,
    zip_code character varying(5) NOT NULL,
    state character varying(2) NOT NULL,
    district character varying(2) NOT NULL,
    state_full character varying(24) NOT NULL,
    state_fips character varying(2) NOT NULL,
    apportionment_census_geographies integer,
    source character varying(90),
    update_date timestamp without time zone DEFAULT now(),
    CONSTRAINT ofec_zip_to_district_pkey PRIMARY KEY (election_year, zip_code, state, district)
);

ALTER TABLE IF EXISTS public.ofec_zip_to_district OWNER to fec;

REVOKE ALL ON TABLE public.ofec_zip_to_district FROM fec_read;

GRANT ALL ON TABLE public.ofec_zip_to_district TO fec;

GRANT SELECT ON TABLE public.ofec_zip_to_district TO fec_read;
