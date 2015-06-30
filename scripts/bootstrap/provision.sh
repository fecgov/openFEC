#!/usr/bin/env bash

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update

sudo apt-get install git python3-dev python-pip postgresql libpq-dev -y

pip install virtualenv
pip install virtualenvwrapper

sudo su vagrant <<'EOF'
curl https://raw.githubusercontent.com/creationix/nvm/v0.24.1/install.sh | bash
export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
source ~/.bashrc
nvm install v0.12.2
nvm alias default 0.12.2
mkdir ~/.virtualenvs
echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
sudo -u postgres createuser -s vagrant
sudo gem install tmuxinator
EOF
