-- Drop duplicate comid, repid indexes

DROP INDEX IF EXISTS real_efile.real_efile_sb4_comid_idx;

DROP INDEX IF EXISTS real_efile.real_efile_sb4_repid_idx;

-- This index already exist in database. Original creation statment was in V0042 migration file. 
-- We had to delete 0042 migration file due to the incompatability of syntax to the new version of flyway which we have to upgrade to satisfy security vulnerability
-- flyway new version 9.1.2/CREATE INDEX CONCURRENTLY  

CREATE INDEX IF NOT EXISTS real_efile_sa7_comid_idx ON real_efile.sa7 USING btree (comid);
