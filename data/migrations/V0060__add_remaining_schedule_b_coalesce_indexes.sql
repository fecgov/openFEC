-- Adds more expression-based indexes required to help improve schedule B
-- query performance.


-- 1977 - 1978
CREATE INDEX idx_ofec_sched_b_1977_1978_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1977_1978
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_image_num_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1977_1978_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1979 - 1980
CREATE INDEX idx_ofec_sched_b_1979_1980_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1979_1980
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_image_num_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1979_1980_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1981 - 1982
CREATE INDEX idx_ofec_sched_b_1981_1982_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1981_1982
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_image_num_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1981_1982_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1983 - 1984
CREATE INDEX idx_ofec_sched_b_1983_1984_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1983_1984
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_image_num_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1983_1984_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1985 - 1986
CREATE INDEX idx_ofec_sched_b_1985_1986_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1985_1986
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_image_num_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1985_1986_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1987 - 1988
CREATE INDEX idx_ofec_sched_b_1987_1988_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1987_1988
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_image_num_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1987_1988_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1989 - 1990
CREATE INDEX idx_ofec_sched_b_1989_1990_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1989_1990
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_image_num_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1989_1990_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1991 - 1992
CREATE INDEX idx_ofec_sched_b_1991_1992_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1991_1992
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_image_num_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1991_1992_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1993 - 1994
CREATE INDEX idx_ofec_sched_b_1993_1994_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1993_1994
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_image_num_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1993_1994_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1995 - 1996
CREATE INDEX idx_ofec_sched_b_1995_1996_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1995_1996
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_image_num_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1995_1996_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1997 - 1998
CREATE INDEX idx_ofec_sched_b_1997_1998_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1997_1998
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_image_num_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1997_1998_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 1999 - 2000
CREATE INDEX idx_ofec_sched_b_1999_2000_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_1999_2000
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_cmte_id_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_image_num_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_city_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_recipient_st_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_1999_2000_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2001 - 2002
CREATE INDEX idx_ofec_sched_b_2001_2002_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2001_2002
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_image_num_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2001_2002_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2003 - 2004
CREATE INDEX idx_ofec_sched_b_2003_2004_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2003_2004
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_image_num_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2003_2004_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2005 - 2006
CREATE INDEX idx_ofec_sched_b_2005_2006_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2005_2006
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_image_num_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2005_2006_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2007 - 2008
CREATE INDEX idx_ofec_sched_b_2007_2008_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2007_2008
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_image_num_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2007_2008_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2009 - 2010
CREATE INDEX idx_ofec_sched_b_2009_2010_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2009_2010
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_image_num_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2009_2010_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2011 - 2012
CREATE INDEX idx_ofec_sched_b_2011_2012_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2011_2012
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_image_num_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2011_2012_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2013 - 2014
CREATE INDEX idx_ofec_sched_b_2013_2014_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2013_2014
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_image_num_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2013_2014_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2015 - 2016
CREATE INDEX idx_ofec_sched_b_2015_2016_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2015_2016
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_image_num_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2015_2016_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);


-- 2017 - 2018
CREATE INDEX idx_ofec_sched_b_2017_2018_clean_recipient_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (clean_recipient_cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_coalesce_disb_dt_sub_id
  ON public.ofec_sched_b_2017_2018
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_cmte_id_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (cmte_id, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_disb_desc_text_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING gin
  (disbursement_description_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_image_num_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (image_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_recip_name_text_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING gin
  (recipient_name_text, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_city_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (recipient_city, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_recipient_st_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (recipient_st, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_rpt_yr_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (rpt_yr, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_amount_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (disb_amt, COALESCE (disb_dt, '9999-12-31'::date), sub_id);

CREATE INDEX idx_ofec_sched_b_2017_2018_sub_id_line_num_coalesce_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (line_num, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
