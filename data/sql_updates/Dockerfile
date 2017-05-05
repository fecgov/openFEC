# Inspired by https://github.com/atupal/dockerfile.flask-uwsgi-nginx/blob/master/Dockerfile
# Base our image off the ubuntu docker container from Dockerhub
from ubuntu:14.04

# Update ubuntu filesystem with updates
run apt-get update

# Install python and easy_install from Ubuntu repos
run apt-get install -y build-essential python python-dev python-setuptools

# Install pip, and then use pip to install flask and uwsgi
run easy_install pip
run pip install uwsgi flask

# We are exposing a network port
expose 80

# uWSGI command that this container is running
cmd ["/usr/local/bin/uwsgi", "--http", ":80", "--wsgi-file", "/src/wsgi.py", "--py-autoreload", "1"]