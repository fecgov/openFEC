#!/usr/bin/env bash

sudo apt-get install git python3-dev python-pip postgresql libpq-dev -y

pip install virtualenv
pip install virtualenvwrapper

sudo su vagrant <<'EOF'
curl https://raw.githubusercontent.com/creationix/nvm/v0.24.1/install.sh | bash
export NVM_DIR="/home/vagrant/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
source ~/.bashrc
nvm install v0.11.16
nvm alias default 0.11.16
mkdir ~/.virtualenvs
echo "export WORKON_HOME=~/.virtualenvs" >> ~/.bashrc
echo "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv" >> ~/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bashrc
sudo -u postgres createuser -s vagrant
gem install tmuxinator
EOF
