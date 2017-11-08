JAVA_HOME=~/.java-buildpack/open_jdk_jre
CLASSPATH=~/flyway/lib/flyway-commandline-4.2.0.jar:~/flyway/lib/flyway-core-4.2.0.jar

host_port_db=`echo $DATABASE_URL | cut -f2 -d@`
user_password=`echo $DATABASE_URL | cut -f1 -d@ | cut -f3 -d/`
user=`echo $user_password | cut -f1 -d:`
password=`echo $user_password | cut -f2 -d:`
JDBC_URL="jdbc:postgresql://$host_port_db?user=$user&password=$password"

$JAVA_HOME/bin/java -cp $CLASSPATH org.flywaydb.commandline.Main -url=$JDBC_URL $*
