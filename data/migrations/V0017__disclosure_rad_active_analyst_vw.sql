SET search_path = disclosure, pg_catalog;

--
-- Name: rad_active_analyst_vw; Type: VIEW; Schema: disclosure; Owner: fec
--

CREATE VIEW rad_active_analyst_vw AS
 SELECT an.anlyst_id,
    an.valid_id AS anlyst_short_id,
    an.firstname,
    an.lastname,
    t.anlyst_title_desc AS anlyst_title,
    concat('202-694-', an.telephone_ext) AS anlyst_phone,
    an.email AS anlyst_email,
        CASE
            WHEN (an.branch_id = (1)::numeric) THEN 'Authorized'::text
            WHEN (an.branch_id = (2)::numeric) THEN 'Party/Non Pary'::text
            ELSE NULL::text
        END AS anlyst_branch
   FROM rad_pri_user.rad_anlyst an,
    rad_pri_user.rad_lkp_anlyst_title t
  WHERE ((an.status_id = (1)::numeric) AND (an.anlyst_id <> (999)::numeric) AND (an.anlyst_title_seq = t.anlyst_title_seq));


ALTER TABLE rad_active_analyst_vw OWNER TO fec;
