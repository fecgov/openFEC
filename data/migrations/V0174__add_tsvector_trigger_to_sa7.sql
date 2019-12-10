/* 
create trigger function and define one for real_efile.sa7 for 3 TSVECTOR columns
*/

-- -------------------------
-- -------------------------
-- CREATE TRIGGER FUNCTION
-- -------------------------
-- -------------------------


CREATE OR REPLACE FUNCTION real_efile.sa7_insert()
  RETURNS trigger AS
$BODY$
begin
  new.contributor_name_text := to_tsvector(concat(parse_fulltext(new.fname::text), ' ', parse_fulltext(new.mname::text), ' ', parse_fulltext(new.name::text)));
  new.contributor_employer_text := to_tsvector(parse_fulltext(new.indemp::text));
  new.contributor_occupation_text := to_tsvector(parse_fulltext(new.indocc::text));
  return new;
end
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION real_efile.sa7_insert()
  OWNER TO fec;


-- -------------------------
-- -------------------------
-- CREATE TRIGGER
-- -------------------------
-- -------------------------
DROP TRIGGER IF EXISTS tri_real_efile_sa7 ON real_efile.sa7;

CREATE TRIGGER tri_real_efile_sa7
  BEFORE INSERT
  ON real_efile.sa7
  FOR EACH ROW
  EXECUTE PROCEDURE real_efile.sa7_insert();
