/*
this migration file is for #4444. By change the column name, the endpoint will return all rows.
*/

alter table public.ofec_totals_pac_party_vw rename sub_id to idx;