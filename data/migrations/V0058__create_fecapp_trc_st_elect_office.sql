-- Add this table to supply phone number of the state election offices

CREATE TABLE fecapp.trc_st_elect_office
(
 state_access_type	varchar(60)	NOT NULL
 ,office_name	varchar(100)	
 ,address1	varchar(80)	
 ,address2	varchar(80)	
 ,city	varchar(30)	
 ,state	varchar(30)	
 ,zip_code	varchar(10)	
 ,url1	varchar(80)	
 ,url2	varchar(80)	
 ,email	varchar(80)	
 ,primary_phone	varchar(23)	
 ,phone2	varchar(15)	
 ,fax_number	varchar(20)	
 ,mailing_address1	varchar(80)	
 ,mailing_address2	varchar(80)	
 ,mailing_city	varchar(30)	
 ,mailing_state	varchar(30)	
 ,mailing_zipcode	varchar(10)	
 ,create_date	timestamp	
 ,update_date	timestamp	
 ,state_name	varchar(30)	
 ,st	varchar(2)	NOT NULL
 ,pg_date	timestamp without time zone DEFAULT now()
,CONSTRAINT trc_st_elect_office_pkey PRIMARY KEY (st,state_access_type)
)
WITH (OIDS=FALSE);
ALTER TABLE fecapp.trc_st_elect_office OWNER TO fec;
GRANT ALL ON TABLE fecapp.trc_st_elect_office TO fec;
GRANT SELECT ON TABLE fecapp.trc_st_elect_office TO fec_read;
