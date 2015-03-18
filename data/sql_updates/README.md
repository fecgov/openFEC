Every file in this directory will be called by the Flask app's manage.py refresh_views command, so make sure it is up to date, and anything that must be run in order must go in order in the same file.

This is an extremely simple "migrations" system, but we don't need anything more at this time, as all OpenFEC tables are only views and can be dropped and recreated at any time, in a matter of minutes. There is no data to be "migrated."
