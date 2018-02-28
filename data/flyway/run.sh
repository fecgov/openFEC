JDBC_URL=`echo $VCAP_SERVICES | jq -r '.["user-provided"][0]["credentials"]["JDBC_URL"]'`
/home/vcap/app/flyway/bin/flyway -n -locations=filesystem:/home/vcap/app/flyway/migrations -url="${JDBC_URL}" migrate && echo SUCCESS
