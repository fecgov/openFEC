SET search_path = public, pg_catalog;

--
-- Name: operations_log; Type: VIEW; Schema: staging; Owner: fec
--

CREATE OR REPLACE VIEW fec_operations_log_vw AS 
 SELECT o.sub_id,
    o.status_num,
    o.cand_cmte_id,
    o.beg_image_num,
    o.end_image_num,
    COALESCE(f.form_tp, regexp_replace(o.form_tp, 'A|N|T', '')) AS form_tp,
    f.rpt_yr,
    f.amndt_ind,
    o.rpt_tp,
    o.scan_dt,
    o.pass_1_entry_dt,
    o.pass_1_verified_dt,
    o.pass_3_coding_dt,
    o.pass_3_entry_done_dt,
    o.receipt_dt,
    o.beginning_coverage_dt,
    o.ending_coverage_dt,
    o.file_num,
    o.prev_file_num
   FROM staging.operations_log o
     LEFT JOIN disclosure.f_rpt_or_form_sub f ON o.sub_id = f.sub_id
    WHERE o.form_tp NOT IN ('RFAI', 'ICI', 'F1Z', 'F2Z') 
    AND o.beg_image_num IS NOT NULL 
    AND o.status_num IN (0, 1);

ALTER TABLE fec_operations_log_vw OWNER TO fec;
GRANT ALL ON TABLE fec_operations_log_vw TO fec;
GRANT SELECT ON TABLE fec_operations_log_vw TO fec_read;

