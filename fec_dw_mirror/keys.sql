ALTER TABLE mirror.dimcand ADD PRIMARY KEY (cand_sk);
CREATE UNIQUE INDEX ON dimcand (cand_id);
ALTER TABLE mirror.dimcmte ADD PRIMARY KEY (cmte_sk);
CREATE UNIQUE INDEX ON dimcmte (cmte_id);
ALTER TABLE mirror.sched_a ADD PRIMARY KEY (sched_a_sk);
ALTER TABLE mirror.sched_a ADD FOREIGN KEY (cmte_id) REFERENCES mirror.dimcmte (cmte_id);
ALTER TABLE mirror.sched_b ADD PRIMARY KEY (sched_b_sk);
delete from mirror.sched_b where recipient_cmte_id not in (select cmte_id from dimcmte);  -- DELETE 8347 of 100000 - WHY?
ALTER TABLE mirror.sched_b ADD FOREIGN KEY (recipient_cmte_id) REFERENCES mirror.dimcmte (cmte_id);
DELETE FROM mirror.sched_b WHERE cand_id NOT IN (SELECT cand_id FROM dimcand); -- DELETE 4436 - why?
ALTER TABLE mirror.sched_b ADD FOREIGN KEY (cand_id) REFERENCES mirror.dimcand (cand_id);
ALTER TABLE mirror.dimcmteproperties ADD PRIMARY KEY (cmteproperties_sk);
ALTER TABLE mirror.dimcmteproperties ADD FOREIGN KEY (cmte_sk) REFERENCES mirror.dimcmte (cmte_sk);
ALTER TABLE mirror.dimcandproperties ADD PRIMARY KEY (candproperties_sk);
ALTER TABLE mirror.dimcandproperties ADD FOREIGN KEY (cand_sk) REFERENCES mirror.dimcand (cand_sk);
