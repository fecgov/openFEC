CREATE OR REPLACE FUNCTION disclosure.fec_fitem_sched_a_insert()
  RETURNS trigger AS
$BODY$
begin
	new.pdf_url := image_pdf_url(new.image_num);
	new.contributor_name_text := to_tsvector(new.contbr_nm) || to_tsvector(coalesce(new.clean_contbr_id, ''));
	new.contributor_employer_text := to_tsvector(new.contbr_employer);
	new.contributor_occupation_text := to_tsvector(new.contbr_occupation);
	new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text);
	new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  
  	return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION disclosure.fec_fitem_sched_a_insert()
  OWNER TO fec;


  
CREATE TRIGGER TRI_fec_fitem_sched_a
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  

CREATE TRIGGER TRI_fec_fitem_sched_a_1975_1976
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1975_1976
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1977_1978
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1977_1978
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1979_1980
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1979_1980
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1981_1982
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1981_1982
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1983_1984
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1983_1984
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1985_1986
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1985_1986
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1987_1988
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1987_1988
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1989_1990
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1989_1990
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1991_1992
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1991_1992
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1993_1994
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1993_1994
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  
CREATE TRIGGER TRI_fec_fitem_sched_a_1995_1996
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1995_1996
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_1997_1998
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1997_1998
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_1999_2000
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_1999_2000
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2001_2002
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2001_2002
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2003_2004
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2003_2004
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2005_2006
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2005_2006
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2007_2008
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2007_2008
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2009_2010
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2009_2010
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2011_2012
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2011_2012
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2013_2014
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2013_2014
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  


CREATE TRIGGER TRI_fec_fitem_sched_a_2015_2016
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2015_2016
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();
  

CREATE TRIGGER TRI_fec_fitem_sched_a_2017_2018
  BEFORE INSERT
  ON disclosure.fec_fitem_sched_a_2017_2018
  FOR EACH ROW
  EXECUTE PROCEDURE disclosure.fec_fitem_sched_a_insert();

