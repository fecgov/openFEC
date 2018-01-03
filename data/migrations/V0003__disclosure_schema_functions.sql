SET search_path = disclosure, pg_catalog;

--
-- Name: contribution_size(numeric); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION contribution_size(transaction_amt numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$

begin

    return case

        when abs(TRANSACTION_AMT ) <= 200 then 0

        when abs(TRANSACTION_AMT ) < 500 then 200

        when abs(TRANSACTION_AMT ) < 1000 then 500

        when abs(TRANSACTION_AMT ) < 2000 then 1000

        else 2000

    end;

end

$$;


ALTER FUNCTION disclosure.contribution_size(transaction_amt numeric) OWNER TO fec;

--
-- Name: disbursement_purpose(character varying, character varying); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION disbursement_purpose(transaction_tp character varying, purpose character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
    v_PURPOSE VARCHAR(200);
        cleaned varchar(200);
begin
    IF TRANSACTION_TP in ('24G') THEN
        v_PURPOSE := 'TRANSFERS';
    ELSIF TRANSACTION_TP in ('24K') THEN 
        v_PURPOSE := 'CONTRIBUTIONS';
    ELSIF TRANSACTION_TP in ('20C', '20F', '20G', '20R', '22J', '22K', '22L', '22U') THEN 
        v_PURPOSE := 'LOAN-REPAYMENTS';
        ELSIF TRANSACTION_TP in ('17R', '20Y', '21Y', '22R', '22Y', '22Z', '23Y', '28L', '40T', '40Y', '40Z', '41T', '41Y', '41Z', '42T', '42Y', '42Z') THEN 
            v_PURPOSE := 'REFUNDS';
        ELSE
            cleaned := regexp_replace(PURPOSE, '[^a-zA-Z0-9]+', ' ');
            IF cleaned ~* 'salary|overhead|rent|postage|office supplies|office equipment|furniture|ballot access fees|petition drive|party fee|legal fee|accounting fee' then 
                v_PURPOSE := 'ADMINISTRATIVE';
            ELSIF cleaned ~* 'travel reimbursement|commercial carrier ticket|reimbursement for use of private vehicle|advance payments? for corporate aircraft|lodging|meal' then 
                    v_PURPOSE := 'TRAVEL';
            ELSIF cleaned ~* 'direct mail|fundraising event|mailing list|consultant fee|call list|invitations including printing|catering|event space rental' then 
                    v_PURPOSE := 'FUNDRAISING';
            ELSIF cleaned ~* 'general public advertising|radio|television|print|related production costs|media' then 
                    v_PURPOSE := 'ADVERTISING';
            ELSIF cleaned ~* 'opinion poll' then 
                    v_PURPOSE := 'POLLING';
            ELSIF cleaned ~* 'button|bumper sticker|brochure|mass mailing|pen|poster|balloon' then 
                    v_PURPOSE := 'MATERIALS';
            ELSIF cleaned ~* 'candidate appearance|campaign rall(y|ies)|town meeting|phone bank|catering|get out the vote|canvassing|driving voters to polls' then 
                    v_PURPOSE := 'EVENTS';
            ELSIF cleaned ~* 'contributions? to federal candidate|contributions? to federal political committee|donations? to nonfederal candidate|donations? to nonfederal committee' then 
                    v_PURPOSE := 'CONTRIBUTIONS';
            ELSE 
                v_PURPOSE := 'OTHER';
            END IF;
        END IF;
        RETURN v_PURPOSE;
end
$$;


ALTER FUNCTION disclosure.disbursement_purpose(transaction_tp character varying, purpose character varying) OWNER TO fec;

--
-- Name: fec_fitem_sched_a_insert(); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION fec_fitem_sched_a_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.pdf_url := image_pdf_url(new.image_num);
    new.contributor_name_text := to_tsvector(new.contbr_nm) || to_tsvector(coalesce(new.clean_contbr_id, ''));
    new.contributor_employer_text := to_tsvector(new.contbr_employer);
    new.contributor_occupation_text := to_tsvector(new.contbr_occupation);
    new.is_individual := is_individual(new.contb_receipt_amt, new.receipt_tp, new.line_num, new.memo_cd, new.memo_text);
    new.line_number_label := expand_line_number(new.filing_form, new.line_num);
    return new;
end
$$;


ALTER FUNCTION disclosure.fec_fitem_sched_a_insert() OWNER TO fec;

--
-- Name: fec_fitem_sched_b_insert(); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION fec_fitem_sched_b_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.pdf_url := image_pdf_url(new.image_num);
    new.disbursement_description_text := to_tsvector(new.disb_desc);
    new.recipient_name_text := to_tsvector(new.recipient_nm) || to_tsvector(coalesce(new.clean_recipient_cmte_id, ''));
    new.disbursement_purpose_category := disbursement_purpose(new.disb_tp, new.disb_desc);
    new.line_number_label := expand_line_number(new.filing_form, new.line_num);
  return new;
end
$$;


ALTER FUNCTION disclosure.fec_fitem_sched_b_insert() OWNER TO fec;

--
-- Name: fec_fitem_sched_e_insert(); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION fec_fitem_sched_e_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.pdf_url := image_pdf_url(new.image_num);
  new.payee_name_text := to_tsvector(new.pye_nm);
  return new;
end
$$;


ALTER FUNCTION disclosure.fec_fitem_sched_e_insert() OWNER TO fec;

--
-- Name: get_first_receipt_dt(character varying, numeric); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION get_first_receipt_dt(pcand_cmte_id character varying, pfiler_tp numeric) RETURNS date
    LANGUAGE plpgsql
    AS $$

declare
    my_date date := null;
begin
    if  (pfiler_tp = 1) then
        select min(RECEIPT_DT) into my_date from DISCLOSURE.NML_FORM_1_1Z_VIEW where cmte_id=pcand_cmte_id;
    --
    else
        select min(RECEIPT_DT) into my_date from DISCLOSURE.NML_FORM_2_2Z_VIEW where cand_id=pcand_cmte_id;
    end if;
    --
    return my_date;
end;

$$;


ALTER FUNCTION disclosure.get_first_receipt_dt(pcand_cmte_id character varying, pfiler_tp numeric) OWNER TO fec;

--
-- Name: get_pcmte_nm(character varying, numeric); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION get_pcmte_nm(pcand_cmte_id character varying, pfiler_tp numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

declare 
    pCMTE_NM  varchar := null;
begin
    if (pfiler_tp = 1) then
            select CMTE_NM into pCMTE_NM from (select CMTE_NM, rank() over (partition by cmte_id order by FEC_ELECTION_YR desc) as rank_num from DISCLOSURE.CMTE_VALID_FEC_YR where cmte_id=pcand_cmte_id) as cmte_query where rank_num=1;
    --
    else
        select CAND_NAME  into pCMTE_NM from (select CAND_NAME, rank() over (partition by cand_id order by FEC_ELECTION_YR desc) as rank_num from DISCLOSURE.CAND_VALID_FEC_YR where cand_id=pcand_cmte_id) as cand_query where rank_num=1;
    end if;
    --
        return pCMTE_NM;
end;

$$;


ALTER FUNCTION disclosure.get_pcmte_nm(pcand_cmte_id character varying, pfiler_tp numeric) OWNER TO fec;

--
-- Name: is_individual(numeric, text, text, text, text); Type: FUNCTION; Schema: disclosure; Owner: fec
--

CREATE FUNCTION is_individual(transaction_amt numeric, transaction_tp text, line_num text, memo_cd text, memo_text text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$

begin

    return (

        -- is_coded_individual(TRANSACTION_TP)  
        coalesce(TRANSACTION_TP, ' ') in ('10', '15', '15E', '15J', '30', '30T', '31', '31T', '32', '10J', '11', '11J', '30J', '31J', '32T', '32J')
        OR 
        -- is_inferred_individual(TRANSACTION_AMT, LINE_NUM, MEMO_CD, MEMO_TEXT, OTHER_ID, CMTE_ID)
        (
            TRANSACTION_AMT < 200 
            and coalesce(LINE_NUM, ' ') in ('11AI', '12', '17', '17A', '18') 
            -- and is_earmark(MEMO_CD, MEMO_TEXT) = 0
            and MEMO_CD is NULL
        )
    );

end

$$;


ALTER FUNCTION disclosure.is_individual(transaction_amt numeric, transaction_tp text, line_num text, memo_cd text, memo_text text) OWNER TO fec;
