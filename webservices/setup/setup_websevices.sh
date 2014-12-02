wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
echo "deb http://nginx.org/packages/mainline/ubuntu/ precise nginx
deb-src http://nginx.org/packages/mainline/ubuntu/ precise nginx" > nginx.apt.list
cat /etc/apt/sources.list > sources.list
cat nginx.apt.list >> sources.list
sudo mv sources.list /etc/apt/
sudo apt-get update
sudo apt-get install -y postgresql-client python3-setuptools python3-dev python-setuptools python-dev 
sudo apt-get install -y libpq-dev libyaml-dev tmux git nginx
echo "deb http://nginx.org/packages/ubuntu/ precise nginx
deb-src http://nginx.org/packages/ubuntu/  nginx" > nginx.apt.list
sudo mv nginx.apt.list /etc/apt/sources.d/
sudo apt-get install -y nginx
sudo easy_install-2.7 virtualenv
sudo easy_install-3.4 virtualenv

export CURRENT_USER=`whoami`

sudo mkdir -p /usr/local/home/$CURRENT_USER
sudo chown $CURRENT_USER:$CURRENT_USER /usr/local/home/$CURRENT_USER
cd /usr/local/home/$CURRENT_USER
git clone https://github.com/18F/openFEC.git
cd openFEC
git checkout --track origin/setup_webserver
cd ..
git clone https://github.com/18F/tls-standards.git

sudo mkdir /opt/ve
sudo chown -R $CURRENT_USER:$CURRENT_USER /opt/ve
virtualenv-2.7 /opt/ve/fec2
. /opt/ve/fec2/bin/activate
pip install -r /usr/local/home/$CURRENT_USER/openFEC/webservices/requirements.txt

sudo mkdir /etc/nginx/vhosts
sudo cp /usr/local/home/$CURRENT_USER/openFEC/webservices/setup/nginx_conf_default_no_ssl /etc/nginx/vhosts/default.conf
sudo rm /etc/nginx/sites-available/default
sudo ln -s /etc/nginx/vhosts/default.conf /etc/nginx/sites-available/default
sudo rm /etc/nginx/nginx.conf
sudo ln -s /etc/nginx/vhosts/default.conf /etc/nginx/nginx.conf
sudo mkdir -p /etc/nginx/ssl/keys
sudo cp /usr/local/home/$CURRENT_USER/tls-standards/configuration/nginx/ssl.rules /etc/nginx/ssl/
sudo cp /usr/local/home/$CURRENT_USER/tls-standards/configuration/nginx/dhparam4096.pem /etc/nginx/ssl/
sudo cp /usr/local/home/$CURRENT_USER/tls-standards/sites/star.18f.us/star.18f.us-chain.crt /etc/nginx/ssl/keys/
sudo cp /usr/local/home/$CURRENT_USER/setup/star.18f.us.key /etc/nginx/ssl/keys/ # will fail, not checked in

cd /usr/local/home/$CURRENT_USER/openFEC
sudo service nginx restart 


sudo cp /usr/local/home/$CURRENT_USER/openFEC/webservices/setup/rest_server.conf /etc/init