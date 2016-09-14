-- Create trigger to maintain Schedule C search columns
ALTER TABLE fec_vsum_sched_c DROP COLUMN if EXISTS candidate_name_text;
ALTER TABLE fec_vsum_sched_c DROP COLUMN if EXISTS loan_source_name_text;

ALTER TABLE fec_vsum_sched_c add column candidate_name_text tsvector;
ALTER TABLE fec_vsum_sched_c add column loan_source_name_text tsvector;

UPDATE fec_vsum_sched_c SET candidate_name_text = to_tsvector(cand_nm);
UPDATE fec_vsum_sched_c SET loan_source_name_text = to_tsvector(cand_nm);

CREATE OR REPLACE FUNCTION ofec_sched_c_update() RETURNS trigger AS $$
begin
  new.loan_source_name_text := to_tsvector(new.loan_src_nm);
  new.candidate_name_text := to_tsvector(new.cand_nm);
  return new;
end
$$ LANGUAGE plpgsql;

drop trigger if exists ofec_sched_c_trigger on fec_vsum_sched_c;
create trigger ofec_sched_c_queue_trigger before insert or update
    on fec_vsum_sched_c for each row execute procedure ofec_sched_c_update()
;
