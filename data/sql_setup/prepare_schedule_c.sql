-- Create trigger to maintain Schedule C search columns
ALTER VIEW fec_vsum_sched_c_vw DROP COLUMN if EXISTS candidate_name_text;
ALTER VIEW fec_vsum_sched_c_vw DROP COLUMN if EXISTS loan_source_name_text;

ALTER VIEW fec_vsum_sched_c_vw add column candidate_name_text tsvector;
ALTER VIEW fec_vsum_sched_c_vw add column loan_source_name_text tsvector;

UPDATE fec_vsum_sched_c_vw SET candidate_name_text = to_tsvector(cand_nm);
UPDATE fec_vsum_sched_c_vw SET loan_source_name_text = to_tsvector(loan_src_nm);

CREATE OR REPLACE FUNCTION ofec_sched_c_update() RETURNS trigger AS $$
begin
  new.loan_source_name_text := to_tsvector(new.loan_src_nm);
  new.candidate_name_text := to_tsvector(new.cand_nm);
  return new;
end
$$ LANGUAGE plpgsql;

drop trigger if exists ofec_sched_c_queue_trigger on fec_vsum_sched_c_vw;
create trigger ofec_sched_c_queue_trigger before insert or update
    on fec_vsum_sched_c_vw for each row execute procedure ofec_sched_c_update()
;
