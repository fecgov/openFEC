# "Source" this file (run `source set_env_vars.sh` or `. set_env_vars.sh`
export BRIDGE_USERNAME=FILL_ME_IN
export BRIDGE_MACHINE=$BRIDGE_USERNAME@FILL_IN_HOSTNAME
export FDW_HOST=FILL_ME_IN
export FDW_USERNAME=FILL_ME_IN
export WEBSERVICES_HOST=FILL_ME_IN
# the rest of these can be left unset unless you're setting up the schema
export PG_USERNAME=FILL_ME_IN
export PG_PASSWORD=FILL_ME_IN
#
export RDS_USERNAME=FILL_ME_IN
export RDS_PASSWORD=FILL_ME_IN
export RDS_HOST=FILL_ME_IN
export CFDM_SQLA_CONN=postgresql://$RDS_USERNAME:$RDS_PASSWORD@$RDS_HOST/cfdm
#
export ORACLE_SERVER_IP=FILL_ME_IN
export ORACLE_INSTANCE_NAME=FILL_ME_IN
export ORACLE_SERVER_LOC=//$ORACLE_SERVER_IP/$ORACLE_INSTANCE_NAME

