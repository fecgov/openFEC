/*
Currently, we have the following schema in database fec
('public','fecmur','aouser','auditsearch','disclosure','fecapp','staging','rad_pri_user','real_efile','real_pfile')

1. fec should be the owner of all tables, views, and MVs in these schemas and has full privilege of these objects.
2. fec_read should have SELECT and only SELECT privilege of all these fec owned tables, views, and MVs
3. aomur_usr has SELECT, INSERT, UPDATE, DELETE to all tables, views, and MVs in schemas fecmur and aouser
4, real_file has SELECT, INSERT, UPDATE, DELETE to all tables, views, and MVs in schemas real_efile and real_pfile
5. openfec_read is an old role, all members in this role had been granted fec_read role.  openfec_read will not be mainttained at this moment.  Considering drop it in the future.
*/

-- The owner of public.ofec_sched_e had been set to fec_api by mistake.
ALTER TABLE public.ofec_sched_e OWNER TO fec;

-- ec_read missing the read permission to this table
GRANT SELECT ON TABLE public.ofec_sched_e TO fec_read;

-- fec_read missing the read permission to these two views
GRANT SELECT ON TABLE aouser.aos_with_parsed_numbers TO fec_read; 
GRANT SELECT ON TABLE fecmur.cases_with_parsed_case_serial_numbers TO fec_read;

--aomur_usr missing the read permission to this two views
GRANT SELECT ON TABLE aouser.aos_with_parsed_numbers TO aomur_usr;
GRANT SELECT ON TABLE fecmur.cases_with_parsed_case_serial_numbers TO aomur_usr;

-- real_file missing SELECT, UPDATE, INSERT, DELETE permission to the following tables
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE real_pfile.f3pz1 TO real_file;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE real_pfile.f3pz2 TO real_file;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE real_pfile.f3z1 TO real_file;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE real_pfile.f3z2 TO real_file;
