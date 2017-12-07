CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_b_insert()
  RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.disbursement_description_text := to_tsvector(new.disb_desc);
	new.recipient_name_text := to_tsvector(new.recipient_nm) || to_tsvector(coalesce(new.clean_recipient_cmte_id, ''));
	new.disbursement_purpose_category := disbursement_purpose(new.disb_tp, new.disb_desc);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_b_insert()
  OWNER TO fec;
  
  
CREATE TRIGGER TRI_fec_fitem_sched_b
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  

CREATE TRIGGER TRI_fec_fitem_sched_b_1975_1976
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1975_1976
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1977_1978
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1977_1978
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1979_1980
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1979_1980
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1981_1982
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1981_1982
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1983_1984
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1983_1984
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1985_1986
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1985_1986
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1987_1988
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1987_1988
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1989_1990
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1989_1990
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1991_1992
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1991_1992
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1993_1994
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1993_1994
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_b_1995_1996
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1995_1996
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_1997_1998
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1997_1998
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_1999_2000
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_1999_2000
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2001_2002
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2001_2002
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2003_2004
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2003_2004
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2005_2006
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2005_2006
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2007_2008
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2007_2008
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2009_2010
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2009_2010
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2011_2012
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2011_2012
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2013_2014
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2013_2014
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_b_2015_2016
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2015_2016
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();
  

CREATE TRIGGER TRI_fec_fitem_sched_b_2017_2018
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_b_2017_2018
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_b_insert();

