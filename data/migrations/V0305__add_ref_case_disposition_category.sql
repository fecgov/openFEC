/*
This is for issue #6041, Add a new table to ref case(MUR, ADR, AF) disposition category.
*/

CREATE TABLE IF NOT EXISTS fecmur.ref_case_disposition_category
 (
    category_id integer NOT NULL,
    category_name varchar(200) NOT NULL,
    display_category_name varchar(200) NOT NULL,
    doc_type varchar(8) NOT NULL,
    published_flg boolean DEFAULT true,
    upload_date timestamp without time zone DEFAULT now(),
    CONSTRAINT ref_category_pkey PRIMARY KEY (category_id)
);

ALTER TABLE IF EXISTS fecmur.ref_case_disposition_category OWNER to fec;

GRANT SELECT ON TABLE fecmur.ref_case_disposition_category TO aomur_usr;

GRANT ALL ON TABLE fecmur.ref_case_disposition_category TO fec;

GRANT SELECT ON TABLE fecmur.ref_case_disposition_category TO fec_read;