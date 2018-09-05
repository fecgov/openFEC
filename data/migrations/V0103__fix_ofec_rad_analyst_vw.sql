/*

Rename assignment_update to assignment_update_date

*/

SET search_path = public;

ALTER TABLE ofec_rad_analyst_vw
RENAME COLUMN assignment_update to assignment_update_date
