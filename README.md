# openFEC

[![Build Status](https://travis-ci.org/18F/openFEC.svg?branch=master)](https://travis-ci.org/18F/openFEC)
[![Stories in Ready](https://badge.waffle.io/18F/openFEC.svg?label=ready&title=Ready)](http://waffle.io/18F/openFEC)

We are taking data from the Federal Election Commission and creating an API around it. We will be harmonizing/cleaning it up to make it easier for external developers to use and analyze as well as creating a web application to make some analyzation and comparison of the data easier.

**Note**: This project is still in alpha and not yet deployed. We're still investigating the best ways to present this data to the public.

## Outside Contributors

Hello! If you're interested in learning more about this project, check out some related repos and don't be afraid to ask us questions (general questions usually go here: [fec](https://github.com/18F/fec)).

If you'd like to contribute to our project, please check out our [openfec](https://github.com/18F/openfec) repo. We try to tag things that are easy to pick up without being entrenched in our project with a "help wanted" tag. Things in our [backlog](https://github.com/18F/openfec/milestones/Backlog) are usually also up for grabs, so let us know if you'd like to pick something up from there.

For those interested in contributing, please check out our [contributing guidelies](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md) we use to guide our development processes internally. You don't have to adhere to them to participate, but following them may help keep things from getting messy.

## Our Repos

* [fec](https://github.com/18F/fec) - A discussion forum where we can discuss the project.
* [openfec](https://github.com/18F/openfec) - Where the API work happens. We also use this as the central repo to create issues related to each sprint and our backlog here. If you're interested in contribution, please look for "help wanted" tags or ask!
* [openfec-web-app](https://github.com/18f/openfec-web-app) - Where the web app work happens. Note that issues and discussion tend to happen in the other repos.

## Installation

### Bootstrap
The easiest way to get started with working on openFEC is to run the [bootstrap script](https://raw.githubusercontent.com/18F/openFEC/master/scripts/bootstrap/fec_bootstrap.sh).

Prior to running, ensure you have the following requirements installed:
<!--requirements-->
* virtualenv
* virtualenvwrapper
* python3.4
* pip
* nodejs
* npm
* PostgreSQL
* tmuxinator

<!--endrequirements-->

Then, simply run:

    $ curl https://raw.githubusercontent.com/18F/openFEC/master/scripts/bootstrap/fec_bootstrap.sh | bash

This will clone both openFEC repos, set up virtual environments, and set some environment variables (that you supply) in ~/.fec_vars. It might be a good idea to source that file in your ~/.bashrc or ~/.zshrc.

NOTE: This will also sync _*this*_ repo. For bootstrapping, we recommend running the script prior to cloning the repo and letting the script handle that.

### Vagrant
There is also a Vagrantfile and provisioning shell script available. This will create an Ubuntu 14.04 virtual machine, provisioned with all the requirements to run the bootstrap script.

From scripts/bootstrap, simply:

    $ vagrant up
    $ vagrant ssh
    $ cp /vagrant/fec_bootstrap.sh fec_bootstrap.sh && ./fec_bootstrap.sh

### Running the apps using tmuxinator
Assuming you ran the bootstrap script, you can launch the API and the Web App with a single command:

    $ tmuxinator fec-local

The site can be found at [http://localhost:3000](http://localhost:3000) (or [http://localhost:3001](http://localhost:3001) if using Vagrant). Remember the username and password you created when running the script.

### Deployment
##### Likely only useful for 18Fers
If you want to deploy to one of our Cloud Foundry instances, use `deploy.sh`. It takes one argument, the Cloud Foundry space. Be sure to be in the root directory of the codebase, and you must already be logged in to CF with your user account.

The script will automatically target the correct manifest file for the environment/space you specify, and it will also deploy the web app at the same time as the API.

    $ ./deploy.sh [dev|stage|prod]

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

    $ cf target [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]

### Working with test data

This repo includes a small subset of the production database (built 2015/05/05) at `data/subset.sql`. To build a new test subset, use the `build_test` invoke task:

    $ invoke build_test <source> <dest>

where both `source` and `dest` are valid PostgreSQL connection strings.
