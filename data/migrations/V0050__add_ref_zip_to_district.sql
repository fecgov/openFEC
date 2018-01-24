-- This table added with issue #2876

CREATE TABLE staging.ref_zip_to_district
(
 zip_district_id	numeric(17,0)	
 ,state_abbrevation	varchar(2)	NOT NULL
 ,state_name	varchar(24)	NOT NULL
 ,fips_state_code	varchar(2)	NOT NULL
 ,district	varchar(2)	NOT NULL
 ,zip_code	varchar(5)	NOT NULL
 ,active	varchar(1)	
 ,census_year	numeric(4,0)	NOT NULL
 ,redistricted_election_year	numeric(4,0)	NOT NULL
 ,update_date	timestamp	NOT NULL
 ,notes	varchar(200)	
 ,pg_date	timestamp without time zone DEFAULT now()
)
WITH (OIDS=FALSE);


ALTER TABLE staging.ref_zip_to_district OWNER TO fec;
GRANT ALL ON TABLE staging.ref_zip_to_district TO fec;
GRANT SELECT ON TABLE staging.ref_zip_to_district TO fec_read;
GRANT SELECT ON TABLE staging.ref_zip_to_district TO openfec_read;
