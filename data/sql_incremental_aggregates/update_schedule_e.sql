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

create or replace function ofec_sched_e_update_from_f57() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where sub_id = any(select sub_id from fec_vsum_f57_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip,tran_id, filing_form,
        schedule_type, image_num, file_num, link_id, orig_sub_id, sub_id, pg_date,
        timestamp, pdf_url, is_notice, payee_name_text)
    select f57.filer_cmte_id,
        f57.pye_nm,
        f57.pye_l_nm,
        f57.pye_f_nm,
        f57.pye_m_nm,
        f57.pye_prefix,
        f57.pye_suffix,
        f57.pye_st1,
        f57.pye_st2,
        f57.pye_city,
        f57.pye_st,
        f57.pye_zip,
        f57.entity_tp,
        f57.entity_tp_desc,
        f57.catg_cd,
        f57.catg_cd_desc,
        f57.s_o_cand_id,
        f57.s_o_cand_nm,
        f57.s_o_cand_f_nm,
        f57.s_o_cand_l_nm,
        f57.s_o_cand_m_nm,
        f57.s_o_cand_prefix,
        f57.s_o_cand_suffix,
        f57.s_o_cand_office,
        f57.s_o_cand_office_desc,
        f57.s_o_cand_office_st,
        f57.s_o_cand_office_state_desc,
        f57.s_o_cand_office_district,
        f57.s_o_ind,
        f57.s_o_ind_desc,
        f57.election_tp,
        f57.fec_election_tp_desc,
        f57.cal_ytd_ofc_sought,
        f57.exp_amt,
        f57.exp_dt,
        f57.exp_tp,
        f57.exp_tp_desc,
        f57.conduit_cmte_id,
        f57.conduit_cmte_nm,
        f57.conduit_cmte_st1,
        f57.conduit_cmte_st2,
        f57.conduit_cmte_city,
        f57.conduit_cmte_st,
        f57.conduit_cmte_zip,
        f57.tran_id,
        f57.filing_form,
        f57.schedule_type,
        f57.image_num,
        f57.file_num,
        f57.link_id,
        f57.orig_sub_id,
        f57.sub_id,
        f57.pg_date,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(f57.image_num) as pdf_url,
        False,
        to_tsvector(f57.pye_nm)
    from fec_vsum_f57_queue_new f57;
end
$$ language plpgsql;

create or replace function ofec_sched_e_notice_update_from_f24() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where link_id = any(select sub_id from ofec_nml_24_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, memo_cd, memo_cd_desc, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, memo_text, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
        tran_id, filing_form, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, pg_date,
        rpt_tp, rpt_yr, election_cycle, timestamp, pdf_url, is_notice, payee_name_text)
    select se.cmte_id,
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
        se.memo_cd,
        se.memo_cd_desc,
        se.s_o_ind,
        se.s_o_ind_desc,
        se.election_tp,
        se.fec_election_tp_desc,
        se.cal_ytd_ofc_sought,
        se.exp_amt,
        se.exp_dt,
        se.exp_tp,
        se.exp_tp_desc,
        se.memo_text,
        se.conduit_cmte_id,
        se.conduit_cmte_nm,
        se.conduit_cmte_st1,
        se.conduit_cmte_st2,
        se.conduit_cmte_city,
        se.conduit_cmte_st,
        se.conduit_cmte_zip,
        se.amndt_ind AS action_cd,
        se.amndt_ind_desc AS action_cd_desc,
            CASE
                WHEN "substring"(se.sub_id::character varying::text, 1, 1) = '4'::text THEN se.tran_id
                ELSE NULL::character varying
            END AS tran_id,
        'F24' AS filing_form,
        'SE' AS schedule_type,
        se.form_tp_desc AS schedule_type_desc,
        se.image_num,
        se.file_num,
        se.link_id,
        se.orig_sub_id,
        se.sub_id,
        se.pg_date,
        f24.rpt_tp,
        f24.rpt_yr,
        f24.rpt_yr + mod(f24.rpt_yr, 2::numeric) AS cycle,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(se.image_num) as pdf_url,
        True,
        to_tsvector(se.pye_nm)
    from ofec_nml_24_queue_new f24, disclosure.nml_sched_e se
    where se.link_id = f24.sub_id and f24.delete_ind is null and se.delete_ind is null and se.amndt_ind::text <> 'D'::text;
end
$$ language plpgsql;

create or replace function ofec_sched_e_f57_notice_update() returns void as $$
begin
    -- Drop all queued deletes
    delete from ofec_sched_e
    where sub_id = any(select sub_id from ofec_f57_queue_old)
    ;
    -- Insert all queued updates, unless a row with the same key exists in the
    -- delete queue with a later timestamp
    insert into ofec_sched_e (cmte_id, pye_nm, payee_l_nm, payee_f_nm, payee_m_nm, payee_prefix, payee_suffix,pye_st1, pye_st2, pye_city, pye_st,
        pye_zip, entity_tp, entity_tp_desc, catg_cd, catg_cd_desc, s_o_cand_id, s_o_cand_nm, s_o_cand_nm_first,
        s_o_cand_nm_last, s_o_cand_m_nm, s_o_cand_prefix, s_o_cand_suffix, s_o_cand_office, s_o_cand_office_desc,
        s_o_cand_office_st, s_o_cand_office_st_desc, s_o_cand_office_district, s_o_ind, s_o_ind_desc, election_tp,
        fec_election_tp_desc, cal_ytd_ofc_sought, exp_amt, exp_dt, exp_tp, exp_tp_desc, conduit_cmte_id, conduit_cmte_nm,
        conduit_cmte_st1, conduit_cmte_st2, conduit_cmte_city, conduit_cmte_st, conduit_cmte_zip, action_cd, action_cd_desc,
        tran_id, filing_form, schedule_type, schedule_type_desc, image_num, file_num, link_id, orig_sub_id, sub_id, pg_date,
        rpt_tp, rpt_yr, election_cycle, timestamp, pdf_url, is_notice, payee_name_text)
    select f57.filer_cmte_id,
        f57.pye_nm,
        f57.pye_l_nm,
        f57.pye_f_nm,
        f57.pye_m_nm,
        f57.pye_prefix,
        f57.pye_suffix,
        f57.pye_st1,
        f57.pye_st2,
        f57.pye_city,
        f57.pye_st,
        f57.pye_zip,
        f57.entity_tp,
        f57.entity_tp_desc,
        f57.catg_cd,
        f57.catg_cd_desc,
        f57.s_o_cand_id,
        f57.s_o_cand_nm,
        f57.s_o_cand_f_nm,
        f57.s_o_cand_l_nm,
        f57.s_o_cand_m_nm,
        f57.s_o_cand_prefix,
        f57.s_o_cand_suffix,
        f57.s_o_cand_office,
        f57.s_o_cand_office_desc,
        f57.s_o_cand_office_st,
        f57.s_o_cand_office_state_desc,
        f57.s_o_cand_office_district,
        f57.s_o_ind,
        f57.s_o_ind_desc,
        f57.election_tp,
        f57.fec_election_tp_desc,
        f57.cal_ytd_ofc_sought,
        f57.exp_amt,
        f57.exp_dt,
        f57.exp_tp,
        f57.exp_tp_desc,
        f57.conduit_cmte_id,
        f57.conduit_cmte_nm,
        f57.conduit_cmte_st1,
        f57.conduit_cmte_st2,
        f57.conduit_cmte_city,
        f57.conduit_cmte_st,
        f57.conduit_cmte_zip,
        f57.amndt_ind AS action_cd,
        f57.amndt_ind_desc AS action_cd_desc,
            CASE
                WHEN "substring"(f57.sub_id::character varying::text, 1, 1) = '4'::text THEN f57.tran_id
                ELSE NULL::character varying
            END AS tran_id,

        'F5' as filing_form,
        'SE-F57' AS schedule_type,
        f57.form_tp_desc AS schedule_type_desc,
        f57.image_num,
        f57.file_num,
        f57.link_id,
        f57.orig_sub_id,
        f57.sub_id,
        f57.pg_date,
        f5.rpt_tp,
        f5.rpt_yr,
        f5.rpt_yr + mod(f5.rpt_yr, 2::numeric) AS cycle,
        cast(null as timestamp) as TIMESTAMP,
        image_pdf_url(f57.image_num) as pdf_url,
        True,
        to_tsvector(f57.pye_nm)
    from ofec_f57_queue_new f57, disclosure.nml_form_5 f5
    where f57.link_id = f5.sub_id AND (f5.rpt_tp::text = ANY (ARRAY['24'::character varying, '48'::character varying]::text[])) AND f57.amndt_ind::text <> 'D'::text AND f57.delete_ind IS NULL AND f5.delete_ind IS NULL;
end
$$ language plpgsql;