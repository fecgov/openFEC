# openFEC

**Develop**
[![Build Status](https://img.shields.io/travis/18F/openFEC/develop.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/develop.svg)](https://codecov.io/github/18F/openFEC)

**Master**
[![Build Status](https://img.shields.io/travis/18F/openFEC/master.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/master.svg)](https://codecov.io/github/18F/openFEC)
[![Code Climate](https://img.shields.io/codeclimate/github/18F/openFEC.svg)](https://codeclimate.com/github/18F/openFEC)
[![Dependencies](https://img.shields.io/gemnasium/18F/openFEC.svg)](https://gemnasium.com/18F/openFEC)

[![Valid Swagger](http://online.swagger.io/validator/?url=https://api.open.fec.gov/swagger)](https://api.open.fec.gov/swagger)

This is the first RESTful API for the Federal Election Commission. We're aiming to make campaign finance more accessible for journalists, academics, developers, and other transparency seekers. This is also fueling the campaign finance data in the upcoming [FEC website](https://github.com/18f/openfec-web-app). 

Our code is [licensed under CC0](https://github.com/18F/openFEC/blob/develop/LICENSE.md), but a few restrictions limit the way you can use FEC data. For example, you can’t use contributor lists for commercial purposes or to solicit donations. [Learn more on FEC.gov.](http://www.fec.gov/pages/brochures/saleuse.shtml)

**Note**: This project is still in alpha and not yet deployed. We're still investigating the best ways to present this data to the public.

## Outside Contributors

Hello! If you're interested in learning more about this project, check out some related repos and don't be afraid to ask us questions (general questions are usually posted in the [18F/FEC repo](https://github.com/18F/fec)).

If you'd like to contribute to our project, please check out our [openfec](https://github.com/18F/openfec) repo. We try to tag things that are easy to pick up without being entrenched in our project with a ["help wanted"](https://github.com/18F/openFEC/labels/help%20wanted%21) tag. Things in our [backlog](https://github.com/18F/openfec/milestones/Backlog) are usually also up for grabs, so let us know if you'd like to pick something up from there.

If you are interested in contributing, please check out our [contributing guidelines](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md), which we use to guide our development processes internally. You don't have to adhere to them to participate, but following them may help keep things from getting messy.

If you would like to be an FEC API beta tester, get an [API key](https://api.data.gov/signup/), check out the experimental [API](https://api.open.fec.gov/developers), and give us your feedback by filing issues.

## Our Repos

* [FEC](https://github.com/18F/fec) - A discussion forum for the project.
* [openFEC](https://github.com/18F/openfec) - Where the API work happens. We also use this as the central repo to create issues related to each sprint and our backlog. If you're interested in contributing, please look for ["help wanted"](https://github.com/18F/openFEC/labels/help%20wanted%21) tags or ask!
* [openFEC-web-app](https://github.com/18f/openfec-web-app) - Where the campaign finance web app work happens. Note that issues and discussion tend to happen in the other repos.
* [fec-alpha](https://github.com/18F/fec-alpha) - A place to explore and develop a new site for the Federal Election Commission.

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

    curl https://raw.githubusercontent.com/18F/openFEC/master/scripts/bootstrap/fec_bootstrap.sh | bash

This will clone both openFEC repos, set up virtual environments, and set some environment variables (that you supply) in ~/.fec_vars. It might be a good idea to source that file in your ~/.bashrc or ~/.zshrc.

NOTE: This will also sync _*this*_ repo. For bootstrapping, we recommend running the script prior to cloning the repo and letting the script handle that.

### Vagrant
There is also a Vagrantfile and provisioning shell script available. This will create an Ubuntu 14.04 virtual machine, provisioned with all the requirements to run the bootstrap script.

From scripts/bootstrap, simply:

    vagrant up
    vagrant ssh
    cp /vagrant/fec_bootstrap.sh fec_bootstrap.sh && ./fec_bootstrap.sh

### Running the apps using tmuxinator
Assuming you ran the bootstrap script, you can launch the API and the Web App with a single command:

    tmuxinator fec-local

The site can be found at [http://localhost:3000](http://localhost:3000) (or [http://localhost:3001](http://localhost:3001) if using Vagrant). Remember the username and password you created when running the script.

### Deployment

#### Likely only useful for 18Fers
To deploy to Cloud Foundry, run `invoke deploy`. The `deploy` task will attempt to detect the appropriate
Cloud Foundry space based the current branch; to override, pass the optional `--space` flag:

    invoke deploy --space dev

The `deploy` task will use the `FEC_CF_USERNAME` and `FEC_CF_PASSWORD` environment variables to log in.
If these variables are not provided, you will be prompted for your Cloud Foundry credentials.

Credentials for Cloud Foundry applications are managed using user-provided services labeled as
"fec-creds-prod", "fec-creds-stage", and "fec-creds-dev". Services are used to share credentials across
blue and green versions of blue-green deploys, and between the API and the webapp. To set up a service:

    cf target -s dev
    cf cups fec-creds-dev -p '{"SQLA_CONN": "..."}'

To stand up a user-provided credential service that supports both the API and the webapp, ensure that
the following keys are set:

* SQLA_CONN
* FEC_WEB_USERNAME
* FEC_WEB_PASSWORD
* FEC_WEB_API_KEY
* FEC_WEB_API_KEY_PUBLIC
* NEW_RELIC_LICENSE_KEY

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

    cf target [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]

#### Production stack

The OpenFEC API is a Flask application deployed using the gunicorn WSGI server behind
an nginx reverse proxy. Static files are compressed and served directly through nginx;
dynamic content is routed to the Flask application via `proxy_pass`. The entire application
is served through the [API Umbrella](http://apiumbrella.io), which handles API keys,
caching, and rate limiting.

#### Caching

All API responses are set to expire after one hour (`Cache-Control: public, max-age=3600`).
In production, the [API Umbrella](http://apiumbrella.io) will check this response header
and cache responses for the specified interval, such that repeated requests to a given
endpoint will only reach the Flask application once. This means that responses may be
stale for up to an hour following the nightly refresh of the materialized views.

#### API Umbrella

The staging and production environments use the [API Umbrella](http://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_WHITELIST_IPS` flag to reject requests that are not routed
through the API Umbrella.

#### Git-flow and continuous deployment

We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed
through Travis CI accordingly.

##### To create a new feature:
* Developer creates a feature branch

        git flow feature start my-feature

* Reviewer merges feature branch into develop and pushes to origin
* [auto] Develop is deployed to dev

##### To create a hotfix:
* Developer creates a hotfix branch

        git flow hotfix start my-hotfix

* Reviewer merges hotfix branch into develop and master and pushes to origin
* [auto] Develop is deployed to dev
* [auto] Master is deployed to prod

##### To create a release:
* Developer creates a release branch and pushes to origin

        git flow release start my-release
        git flow release publish my-release

* [auto] Release is deployed to stage
* Review of staging
* Developer merges release branch into master and pushes to origin

        git flow release finish my-release

* [auto] Master is deployed to prod

#### Data for development and staging environments

Note: The following can be automated using Boto or the AWS CLI if we continue on with this model and need
to update snapshots frequently.

The production and staging environments use RDS instances that receive streaming updates from the FEC database.
The development environment uses a separate RDS instance created from a snapshot of the production instance.
To update the development instance (e.g. when schemas change or new records are added):

* Create a new snapshot of the production data

        RDS :: Instances :: fec-goldengate-target :: Take DB Snapshot

* Restore the snapshot to a new development RDS

        RDS :: Snapshots :: <snapshot-name> :: Restore Snapshot

    * DB Instance Class: db.m3.medium
    * Multi-AZ Deployment: No
    * Storage Type: General Purpose
    * DB Instance Identifier: fec-goldengate-dev-YYYY-mm-dd
    * VPC: Not in VPC

* Add the new instance to the FEC security group

        RDS :: Instances :: <instance-name> :: Modify

    * Security Group: fec-open
    * Apply Immediately

* Configure DNS to point to new instance

        Route 53 :: Hosted Zones :: open.fec.gov :: goldengate-dev.open.fec.gov

    * Value: <instance-endpoint>
        * Example: fec-goldengate-dev-YYYY-mm-dd...rds.amazonaws.com

* Wait up to `TTL` seconds for DNS records to propagate
* Verify that new instance is reachable at goldengate-dev.open.fec.gov
* Delete previous development instance

**Important**: Verify that all newly created instances are tagged with the same client
as the production instance.

### Testing

#### Creating a new test database

    createdb cfdm_test
    pg_restore --dbname cfdm_test data/subset.dump
    ./manage.py update_all

#### Running the Tests

    nosetests

#### The Test Data Subset

This repo includes a small subset of the staging database (built 2015/08/12) at `data/subset.dump`. To use the test subset for local development:

    pg_restore --dbname <dest> data/subset.dump

To build a new test subset, use the `build_test` invoke task:

    invoke build_test <source> <dest>

where both `source` and `dest` are valid PostgreSQL connection strings.

To update the version-controlled test subset after rebuilding, run:

    invoke dump <source> data/subset.dump

where `source` is the database containing the newly created test subset.

### Git Hooks

This repo includes optional post-merge and post-checkout hooks to ensure that
dependencies are up to date. If enabled, these hooks will update Python
dependencies on checking out or merging changes to `requirements.txt`. To
enable the hooks, run

    invoke add_hooks

To disable, run

    invoke remove_hooks
