#!/usr/bin/env bash



## Install tmux and tmuxinator if necessary
#if [ ! $(which tmux) ] 2>/dev/null; then
#    echo "Installing tmux"
#fi
#
#if [ ! $(which tmuxinator) ] 2>/dev/null; then
#    echo "Installing tmuxinator"
#fi
#
## Install virtualenv if necessary
#if [ ! $(which virtualenv) ] 2>/dev/null; then
#    echo "Installing virtualenv"
#fi
#
## Install virtualenvwrapper if necessary
#if [ ! $(which virtualenvwrapper.sh) ] 2>/dev/null; then
#    echo "Installing virtualenvwrapper"
#fi
source `which virtualenvwrapper.sh`

# Set up openFEC API
echo "Setting up API"
echo "Cloning repo"
git clone https://github.com/18F/openFEC.git
echo "Creating virtualenv"
cd openFEC
mkvirtualenv openFEC -p `which python3.4`
workon openFEC
echo "Installing requirements"
pip install -r requirements.txt
echo "Creating sample DB"
dropdb cfdm_test 2>/dev/null
createdb cfdm_test
psql -f data/cfdm_test.pgdump.sql cfdm_test >/dev/null
echo "Refreshing DB"
python manage.py refresh_db
deactivate
cd ..

# Set up openFEC Web App
echo "Done with API, setting up web app"
echo "Cloning repo"
git clone https://github.com/18F/openFEC-web-app.git
echo "Creating virtualenv"
cd openFEC-web-app
mkvirtualenv openFEC-web-app -p `which python3.4`
workon openFEC-web-app
echo "Installing requirements"
pip install -r requirements.txt
npm config set python `which python2.7`
npm install -g browserify
npm install
npm run build
echo "Web app uses basic auth. Create username and password:"
read -p "Name: " name
read -p "Pass: " pass
echo "export FEC_WEB_USERNAME=$name" > ~/.fec_vars
echo "export FEC_WEB_PASSWORD=$pass" >> ~/.fec_vars
source ~/.fec_vars
echo "Web app installed."
echo ""
echo ""
echo "------------------------------------------------------------------"
echo "Installation complete."
echo ""
echo "Remember to add 'source ~/.fec_vars' to your bashrc or zshrc."
echo ""
echo "From the openFEC directory, run:"
echo ""
echo "    $ python run_api.py"
echo ""
echo "to start the API server at http://localhost:3000."
echo "From the openFEC-web-app directory, run:"
echo ""
echo "    $ python __init__.py"
echo ""
echo "to start the web app at http://localhost:5000"
echo "------------------------------------------------------------------"
