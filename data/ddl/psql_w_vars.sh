psql -v rds_password="'$RDS_PASSWORD'" -v rds_host_loc="'$RDS_HOST'" -v oracle_server_loc="'$ORACLE_SERVER_LOC'" -v oracle_password="'$ORACLE_PASSWORD'" $@
