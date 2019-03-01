import socket
from uuid import getnode as get_mac

TEST_ES_HOST = "localhost:9200"

TEST_DB_HOST = "localhost"
TEST_DB_USER = 'root'
# password is set in Vagrant provision script vagrant/centos/root_setup.sh
TEST_DB_PASSWORD = 'R00t_passwd!'


if get_mac() == 229665869398274: # Only apply to Chao's computer
    TEST_DB_PASSWORD = "pig"

elif socket.gethostname() == 'admins-air.loctest.gov': #qiang's air
    TEST_DB_PASSWORD = open('/Users/sunshine168/.mysql_pwd').read().strip()
