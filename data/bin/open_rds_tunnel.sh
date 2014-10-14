echo 1. Get your public key added to $BRIDGE_MACHINE
echo 2. Edit set_env_vars.sh and run it
echo 3. Run this script & leave it running in another window
echo 4. Connect with psql -h 127.0.0.1 -p 63336 cfdm $BRIDGE_USERNAME
echo 5. Profit! 

ssh -L 63336:$RDS_HOST:5432 ec2-user@$BRIDGE_HOST -N
