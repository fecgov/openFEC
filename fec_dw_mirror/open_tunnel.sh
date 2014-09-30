
echo 1. Get your public key added to $BRIDGE_MACHINE
echo 2. Edit set_env_vars.sh and run it
echo 3. Run this script & leave it running in another window
echo 4. Connect with psql -h 127.0.0.1 -p 63333 cfdm $BRIDGE_USERNAME
echo 5. Within psql, SET search_path=mirror;
echo 6. Profit! 

echo "ssh -L 63333:localhost:63333 $BRIDGE_MACHINE ssh -L 63333:localhost:5432 -i /home/$BRIDGE_USERNAME/.ssh/peered.pem -N $FDW_USERNAME@$FDW_HOST"
ssh -L 63333:localhost:63333 $BRIDGE_MACHINE ssh -L 63333:localhost:5432 -i /home/$BRIDGE_USERNAME/.ssh/peered.pem -N $FDW_USERNAME@$FDW_HOST
