#!/usr/bin/env bash

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
npm install
echo "Creating sample DB"
dropdb cfdm_test 2>/dev/null
createdb cfdm_test
psql -f data/subset.sql cfdm_test >/dev/null
echo "Refreshing DB"
python manage.py update_schemas
deactivate
cd ..

echo "Creating tmuxinator profile"
cp scripts/bootstrap/tmux/fec-local.yml ~./tmuxinator/fec-local.yml
sed -i '' 's|<CHANGE>|'`pwd`'|' ~./tmuxinator/fec-local.yml

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
echo "export FEC_WEB_TEST=true" > ~/.fec_vars
echo "export FEC_WEB_DEBUG=true" >> ~/.fec_vars
echo "export FEC_WEB_API_URL_PUBLIC=http://localhost:5001" >> ~/.fec_vars
source ~/.fec_vars
echo "Web app installed."
echo ""
echo ""
echo "------------------------------------------------------------------"
echo "Installation complete."
echo ""
echo "Remember to add 'source ~/.fec_vars' to your bashrc or zshrc."
echo ""
echo "To launch both apps, simply run:"
echo ""
echo "     $ tmuxinator fec-local"
echo ""
echo "The API will be running at localhost:5000 and the webapp will"
echo "be running at localhost:3000"
echo "------------------------------------------------------------------"
