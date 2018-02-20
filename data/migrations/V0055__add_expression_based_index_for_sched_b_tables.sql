-- Adding expression based indexes on ofec_sched_b tables to address issue #2791


CREATE INDEX idx_ofec_sched_b_1977_1978_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1977_1978
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1979_1980_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1979_1980
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1981_1982_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1981_1982
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1983_1984_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1983_1984
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1985_1986_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1985_1986
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1987_1988_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1987_1988
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1989_1990_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1989_1990
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1991_1992_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1991_1992
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1993_1994_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1993_1994
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1995_1996_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1995_1996
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1997_1998_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1997_1998
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_1999_2000_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_1999_2000
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2001_2002_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2001_2002
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2003_2004_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2003_2004
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2005_2006_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2005_2006
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2007_2008_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2007_2008
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2009_2010_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2009_2010
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2011_2012_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2011_2012
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2013_2014_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2013_2014
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2015_2016_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2015_2016
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);
CREATE INDEX idx_ofec_sched_b_2017_2018_election_cycle_coalesce_disb_dt
  ON public.ofec_sched_b_2017_2018
  USING btree
  (two_year_transaction_period, COALESCE (disb_dt, '9999-12-31'::date), sub_id);