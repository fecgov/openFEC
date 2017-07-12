-- A simple union to pull in the f5 filers.
-- Real_efile_se has a few more columns, so had to account for that
-- (pcf info, notary, etc).

DROP VIEW IF EXISTS real_efile_se_f57_vw;

CREATE VIEW real_efile_se_f57_vw AS
    SELECT
        repid,
        NULL AS line_num,
        rel_lineno,
        comid,
        entity,
        lname,
        fname,
        mname,
        prefix,
        suffix,
        str1,
        str2,
        city,
        state,
        zip,
        exp_desc,
        exp_date,
        amount,
        so_canid,
        so_can_name,
        so_can_fname,
        so_can_mname,
        so_can_prefix,
        so_can_suffix,
        so_can_off,
        so_can_state,
        so_can_dist,
        other_comid,
        other_canid,
        can_name,
        can_off,
        can_state,
        can_dist,
        other_name,
        other_str1,
        other_str2,
        other_city,
        other_state,
        other_zip,
        supop,
        NULL AS pcf_lname,
        NULL AS pcf_fname,
        NULL AS pcf_mname,
        NULL AS pcf_prefix,
        NULL AS pcf_suffix,
        NULL AS sign_date,
        NULL AS not_date,
        NULL AS expire_date,
        NULL AS not_lanme,
        NULL AS not_fname,
        NULL AS not_mname,
        NULL AS not_prefix,
        NULL AS not_suffix,
        amend,
        tran_id,
        NULL AS memo_code,
        NULL AS memo_text,
        NULL AS br_tran_id,
        NULL AS br_sname,
        item_elect_cd,
        item_elect_oth,
        cat_code,
        trans_code,
        ytd,
        imageno,
        create_dt,
        NULL AS dissem_dt
    FROM real_efile.f57
    UNION ALL
    SELECT * FROM real_efile_se;

-- Create additional indexes
CREATE INDEX IF NOT EXISTS f57_comid_idx ON real_efile.f57 (comid);
CREATE INDEX IF NOT EXISTS f57_create_dt_idx ON real_efile.f57 (create_dt);
CREATE INDEX IF NOT EXISTS f57_exp_date_idx ON real_efile.f57 (exp_date DESC);
CREATE INDEX IF NOT EXISTS f57_repid_idx ON real_efile.f57 (repid);
