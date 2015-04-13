# Start a psql session with OS-level environment variables 
# available within SQL as `:rds_host_loc`, etc.  
# Run this on data bridge machine
# for session that will connect to both FEC/Oracle and 18F/RDS.

psql -v rds_password="'$RDS_PASSWORD'" -v rds_host_loc="'$RDS_HOST'" -v oracle_server_loc="'$ORACLE_SERVER_LOC'" -v oracle_password="'$ORACLE_PASSWORD'" $@
