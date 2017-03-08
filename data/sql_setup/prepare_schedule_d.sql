-- Create trigger to maintain Schedule C search columns
ALTER TABLE disclosure.nml_sched_d DROP COLUMN if EXISTS creditor_debtor_name_text;

ALTER TABLE disclosure.nml_sched_d add column creditor_debtor_name_text tsvector;


UPDATE disclosure.nml_sched_d SET creditor_debtor_name_text = to_tsvector(cred_dbtr_nm);

CREATE OR REPLACE FUNCTION ofec_sched_d_update() RETURNS trigger AS $$
begin
  new.creditor_debtor_name_text := to_tsvector(new.cred_dbtr_nm);
  return new;
end
$$ LANGUAGE plpgsql;

drop trigger if exists ofec_sched_d_queue_trigger on disclosure.nml_sched_d;
create trigger ofec_sched_d_queue_trigger before insert or update
    on disclosure.nml_sched_d for each row execute procedure ofec_sched_d_update()
;
