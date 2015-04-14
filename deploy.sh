#!/bin/bash

# usage:
# ./deploy.sh space-name
# You must be logged into Cloud Foundry
# You must also follow the npm installation instructions here:
# https://github.com/18F/openFEC-web-app#installing
# if you haven't already set this up in your environment

if [ "$#" -ne 1 ]; then
  echo "Please pass in the name of the space you want to deploy to."
  echo "Run 'cf spaces' to see possible spaces."
  echo "Run 'cf apps' to see possible apps within your current space."
  exit 1
fi

echo "Building JS in openFEC-web-app..."
cd ../openFEC-web-app
npm run build

if [ $? -ne 0 ]; then
  echo "JS build failed."
  exit $?
fi

cd -
echo "Targeting Cloud Foundry space..."
cf target -o fec -s "$1"
echo
echo "Pushing to Cloud Foundry..."
echo " "
cf push -f "manifest_$1.yml"
exit $?
