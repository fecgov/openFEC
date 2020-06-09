/* added index */

--real_efile.sa7--
CREATE INDEX IF NOT EXISTS idx_real_efile_sa7_comid_date_con
    ON real_efile.sa7 USING btree
    (comid DESC NULLS LAST, date_con DESC NULLS LAST);
    

--real_efille.sb4--
CREATE INDEX IF NOT EXISTS idx_real_efile_sb4_comid_date_dis 
    ON real_efile.sb4 USING btree
    (comid DESC NULLS LAST, date_dis DESC NULLS LAST);