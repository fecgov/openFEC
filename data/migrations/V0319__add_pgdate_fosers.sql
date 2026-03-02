/*
This is for issue #6512. Add pg_date to table: documents_ocrtext, tiermapping.
*/

ALTER TABLE fosers.documents_ocrtext ADD column IF NOT EXISTS  pg_date timestamp without time zone DEFAULT now();

ALTER TABLE fosers.tiermapping ADD column IF NOT EXISTS  pg_date timestamp without time zone DEFAULT now();
