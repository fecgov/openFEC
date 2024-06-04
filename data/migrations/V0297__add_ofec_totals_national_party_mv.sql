/*
This migration file is for #5787

1) Create ofec_totals_national_party_mv 
*/

DROP MATERIALIZED VIEW IF EXISTS public.ofec_totals_national_party_mv;

CREATE MATERIALIZED VIEW IF NOT EXISTS public.ofec_totals_national_party_mv
AS
WITH cmte_list AS (
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_a_national_party_vw
        UNION
        SELECT DISTINCT cmte_id, cmte_nm, two_year_transaction_period
        FROM ofec_sched_b_national_party_vw
    ), 
    sa_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period, 
               sum(contb_receipt_amt) AS contribution
        FROM ofec_sched_a_national_party_vw
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    ), 
    sb_total AS (
        SELECT cmte_id, cmte_nm, two_year_transaction_period,
               sum(disb_amt) AS disbursement
        FROM ofec_sched_b_national_party_vw
        WHERE upper(party_account) <> 'UNKNOWN'
        GROUP BY cmte_id, cmte_nm, two_year_transaction_period
    )
    SELECT l.cmte_id, l.cmte_nm, l.two_year_transaction_period,
        (SELECT sa_total.contribution
           FROM sa_total
          WHERE sa_total.cmte_id = l.cmte_id 
            AND sa_total.two_year_transaction_period = l.two_year_transaction_period) AS contribution,
        (SELECT sb_total.disbursement
           FROM sb_total
          WHERE sb_total.cmte_id = l.cmte_id
            AND sb_total.two_year_transaction_period = l.two_year_transaction_period) AS disbursement
   FROM cmte_list l
WITH DATA;


ALTER TABLE IF EXISTS public.ofec_totals_national_party_mv OWNER TO fec;

GRANT ALL ON TABLE public.ofec_totals_national_party_mv TO fec;
GRANT SELECT ON TABLE public.ofec_totals_national_party_mv TO fec_read;

CREATE UNIQUE INDEX idx_ofec_totals_national_party_mv_cmteid_cycle
    ON public.ofec_totals_national_party_mv USING btree
    (cmte_id, two_year_transaction_period);
