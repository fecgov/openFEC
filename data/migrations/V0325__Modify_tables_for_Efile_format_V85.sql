/*
This is for issue #6334
The tables were already modified so we will not miss any incoming data.
However, official migration script is need to add these to the version controlled base of the database structure.
*/

-- Modify tables for new Efile_Format V8.5    
-- -----------------
-- Modify disclosure tables 
-- -----------------
-- Form_1S changes
DO $$
BEGIN
    EXECUTE format('Alter TABLE disclosure.nml_form_1s 
	ADD COLUMN JOINT_CMTE_TP_AS_FILED VARCHAR(1),
	ADD COLUMN JOINT_CMTE_TP VARCHAR(1)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;



-- Form_99_MISC changes
DO $$
BEGIN
    EXECUTE format('Alter TABLE disclosure.nml_form_99_misc 
	ADD COLUMN FILING_FREQ VARCHAR(1),
	ADD COLUMN PDF_ATTACHMENT_IND VARCHAR(1)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


-- Sched_C2 changes
DO $$
BEGIN
    EXECUTE format('Alter TABLE disclosure.nml_sched_c2 ALTER COLUMN GUAR_ENDR_NM TYPE VARCHAR(200)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

DO $$
BEGIN
    EXECUTE format('Alter TABLE DISCLOSURE.FEC_FITEM_SCHED_C2 ALTER COLUMN GUAR_ENDR_NM TYPE VARCHAR(200)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;



DO $$
BEGIN
    EXECUTE format('Alter TABLE disclosure.nml_sched_c2 
	ADD COLUMN GUAR_ENDR_ENTITY  VARCHAR(3),
	ADD COLUMN GUAR_ENDR_CMTE_ID VARCHAR(9)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


DO $$
BEGIN
    EXECUTE format('Alter TABLE DISCLOSURE.FEC_FITEM_SCHED_C2 
	ADD COLUMN GUAR_ENDR_ENTITY  VARCHAR(3),
	ADD COLUMN GUAR_ENDR_CMTE_ID VARCHAR(9)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;

-- -----------------
-- Modify real_efile tables 
-- -----------------
--F1S

DO $$
BEGIN
    EXECUTE format('ALTER TABLE REAL_EFILE.F1S 
	ADD column JFR_CMTE_TYPE VARCHAR(1), 
	ADD COLUMN  REL_LINENO numeric');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


--SC2(guarantors)
DO $$
BEGIN
    EXECUTE format('ALTER TABLE REAL_EFILE.GUARANTORS 
	ADD COLUMN GUARANTOR_ENTITY VARCHAR(3),
	ADD COLUMN  GUARANTOR_ORG_NAME VARCHAR(200),
	ADD COLUMN  GUARANTOR_CMTE_ID VARCHAR(9)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


--F99
DO $$
BEGIN
    EXECUTE format('ALTER TABLE REAL_EFILE.F99 
	ADD COLUMN FILING_FREQUENCY VARCHAR(1),
	ADD COLUMN  PDF_ATTACHMENT VARCHAR(1)');
EXCEPTION
             WHEN duplicate_column THEN
                null;
             WHEN others THEN
                RAISE NOTICE 'some other error: %, %',  sqlstate, sqlerrm;
END$$;


