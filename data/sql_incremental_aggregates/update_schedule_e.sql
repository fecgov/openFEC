create or replace function ofec_sched_e_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_sched_e_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (
        select
            new.*,
            image_pdf_url(new.image_num) as pdf_url,
            coalesce(new.rpt_tp, '') in ('24', '48') as is_notice,
            to_tsvector(new.pye_nm) as payee_name_text
        from ofec_sched_e_queue_new new
        left join ofec_sched_e_queue_old old on new.sub_id = old.sub_id and old.timestamp > new.timestamp
        where old.sub_id is null
        order by new.sub_id, new.timestamp desc
    );
end
$$ language plpgsql;


create or replace function ofec_sched_e_notice_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e_notice
    where sub_id = any(select sub_id from ofec_nml_sched_e_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (
        SELECT se.cmte_id,
        se.cmte_nm,
        se.pye_nm,
        se.payee_l_nm as pye_l_nm,
        se.payee_f_nm as pye_f_nm,
        se.payee_m_nm as pye_m_nm,
        se.payee_prefix as pye_prefix,
        se.payee_suffix as pye_suffix,
        se.pye_st1,
        se.pye_st2,
        se.pye_city,
        se.pye_st,
        se.pye_zip,
        se.entity_tp,
        se.entity_tp_desc,
        se.exp_desc,
        se.catg_cd,
        se.catg_cd_desc,
        se.s_o_cand_id,
        se.s_o_cand_nm,
        se.s_o_cand_nm_first,
        se.s_o_cand_nm_last,
        se.s_0_cand_m_nm AS s_o_cand_m_nm,
        se.s_0_cand_prefix AS s_o_cand_prefix,
        se.s_0_cand_suffix AS s_o_cand_suffix,
        se.s_o_cand_office,
        se.s_o_cand_office_desc,
        se.s_o_cand_office_st,
        se.s_o_cand_office_st_desc,
        se.s_o_cand_office_district,
        se.s_o_ind,
        se.s_o_ind_desc,
        se.election_tp,
        se.fec_election_tp_desc,
        se.cal_ytd_ofc_sought,
        se.dissem_dt,
        se.exp_amt,
        se.exp_dt,
        se.exp_tp,
        se.exp_tp_desc,
        se.memo_cd,
        se.memo_cd_desc,
        se.memo_text,
        se.conduit_cmte_id,
        se.conduit_cmte_nm,
        se.conduit_cmte_st1,
        se.conduit_cmte_st2,
        se.conduit_cmte_city,
        se.conduit_cmte_st,
        se.conduit_cmte_zip,
        se.indt_sign_nm,
        se.indt_sign_dt,
        se.notary_sign_nm,
        se.notary_sign_dt,
        se.notary_commission_exprtn_dt,
        se.filer_l_nm,
        se.filer_f_nm,
        se.filer_m_nm,
        se.filer_prefix,
        se.filer_suffix,
        se.amndt_ind AS action_cd,
        se.amndt_ind_desc AS action_cd_desc,
            CASE
                WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.tran_id
                ELSE NULL::character varying
            END AS tran_id,
            CASE
                WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_tran_id
                ELSE NULL::character varying
            END AS back_ref_tran_id,
            CASE
                WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.back_ref_sched_nm
                ELSE NULL::character varying
            END AS back_ref_sched_nm,
        'F24' AS filing_form,
        'SE' AS schedule_type,
        se.form_tp_desc AS schedule_type_desc,
        se.line_num,
        se.image_num,
        se.file_num,
        se.sub_id,
        se.link_id,
        se.orig_sub_id,
        f24.rpt_yr,
        f24.rpt_tp,
        f24.rpt_yr + mod(f24.rpt_yr, 2::numeric) AS cycle
       FROM ofec_nml_sched_e_queue_new se,
        ofec_sched_e_queue_new f24
       WHERE se.link_id = f24.sub_id AND f24.delete_ind IS NULL AND se.delete_ind IS NULL AND se.amndt_ind::text <> 'D'::text);
end
$$ language plpgsql;