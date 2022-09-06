#!/bin/bash

# This is a convenience script to setup the app container environment to match
# what was uploaded with the buildpack when you SSH into an app container.
# This must be run if you want to interact with the application and run
# anything as you'd expect, e.g., ./cli.py showmigrations for a Python app
# built with Django.

# This script is built using the commands and information outlined here:
# https://docs.cloudfoundry.org/devguide/deploy-apps/ssh-apps.html#ssh-env

# Setup the necessary environment variables
export HOME=/home/vcap/app
export TMPDIR=/home/vcap/tmp

# Source the setup files
if [ -d /home/vcap/app/.profile.d/ ]; then
    for f in /home/vcap/app/.profile.d/*.sh; do source "$f"; done;
fi

if [ -f /home/vcap/app/.profile ]; then
    source /home/vcap/app/.profile;
fi

# Return to the main app directory
cd $HOME
