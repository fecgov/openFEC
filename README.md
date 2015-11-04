## Campaign finance for everyone
The Federal Election Commission (FEC) releases information to the public about money that’s raised and spent in federal elections — that’s elections for US president, Senate, and House of Representatives. 

Are you interested in seeing how much money a candidate raised? Or spent? How much debt they took on? Who contributed to their campaign? The FEC is the authoritative source for that information.

betaFEC is a collaboration between [18F](http://18f.gsa.gov) and the FEC. It aims to make campaign finance information more accessible (and understandable) to all users. 

This repository houses betaFEC's API.

## FEC repositories 
We welcome you to explore our FEC repositories, make suggestions, and contribute to our code. Our repositories are:

- [FEC](https://github.com/18F/fec): a general discussion forum. We [compile feedback](https://github.com/18F/fec/issues) from betaFEC’s feedback widget here, and this is the best place to submit general feedback.
- [openFEC](https://github.com/18F/openfec): betaFEC’s API
- [openFEC-web-app](https://github.com/18f/openfec-web-app): the betaFEC web app for exploring campaign finance data
- [fec-style](https://github.com/18F/fec-style): shared styles and user interface components
- [fec-cms](https://github.com/18F/fec-cms): the content management system (CMS) for betaFEC

## How you can help
We’re thrilled you want to get involved! Here are some suggestions:
- Check out our [contributing guidelines](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md). Then, [file an issue](https://github.com/18F/fec/issues) or submit a pull request.
- [Send us an email](mailto:betafeedback@fec.gov).
- If you’re a developer, follow the installation instructions in the README.md page of each repository to run the apps on your computer. 

## Copyright and licensing
This project is in the public domain within the United States, and we waive worldwide copyright and related rights through [CC0 universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/). Read more on our license page.

A few restrictions limit the way you can use FEC data. For example, you can’t use contributor lists for commercial purposes or to solicit donations. Learn more on FEC.gov.

---

**Develop**
[![Build Status](https://img.shields.io/travis/18F/openFEC/develop.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/develop.svg)](https://codecov.io/github/18F/openFEC)

**Master**
[![Build Status](https://img.shields.io/travis/18F/openFEC/master.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/master.svg)](https://codecov.io/github/18F/openFEC)
[![Code Climate](https://img.shields.io/codeclimate/github/18F/openFEC.svg)](https://codeclimate.com/github/18F/openFEC)
[![Dependencies](https://img.shields.io/gemnasium/18F/openFEC.svg)](https://gemnasium.com/18F/openFEC)
[![Code Issues](https://www.quantifiedcode.com/api/v1/project/d3b2c96b3781466081d418fd50762726/badge.svg)](https://www.quantifiedcode.com/app/project/d3b2c96b3781466081d418fd50762726)

[![Valid Swagger](http://online.swagger.io/validator/?url=https://api.open.fec.gov/swagger)](https://api.open.fec.gov/swagger)

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

#### Likely only useful for 18F team members
To deploy to Cloud Foundry, run `invoke deploy`. The `deploy` task will attempt to detect the appropriate
Cloud Foundry space based the current branch; to override, pass the optional `--space` flag:

    $ invoke deploy --space dev

The `deploy` task will use the `FEC_CF_USERNAME` and `FEC_CF_PASSWORD` environment variables to log in.
If these variables are not provided, you will be prompted for your Cloud Foundry credentials.

Credentials for Cloud Foundry applications are managed using user-provided services labeled as
"fec-creds-prod", "fec-creds-stage", and "fec-creds-dev". Services are used to share credentials across
blue and green versions of blue-green deploys, and between the API and the webapp. To set up a service:

    $ cf target -s dev
    $ cf cups fec-creds-dev -p '{"SQLA_CONN": "..."}'

To stand up a user-provided credential service that supports both the API and the webapp, ensure that
the following keys are set:

* SQLA_CONN
* FEC_WEB_USERNAME
* FEC_WEB_PASSWORD
* FEC_WEB_API_KEY
* FEC_WEB_API_KEY_PUBLIC
* NEW_RELIC_LICENSE_KEY

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

    $ cf target [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]

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

#### API umbrella

The staging and production environments use the [API Umbrella](http://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_WHITELIST_IPS` flag to reject requests that are not routed
through the API Umbrella.

#### Git-flow and continuous deployment

We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed
through Travis CI accordingly.

##### To create a new feature:
* Developer creates a feature branch

        $ git flow feature start my-feature

* Reviewer merges feature branch into develop and pushes to origin
* [auto] Develop is deployed to dev

##### To create a hotfix:
* Developer creates a hotfix branch

        $ git flow hotfix start my-hotfix

* Reviewer merges hotfix branch into develop and master and pushes to origin
* [auto] Develop is deployed to dev
* [auto] Master is deployed to prod

##### To create a release:
* Developer creates a release branch and pushes to origin

        $ git flow release start my-release
        $ git flow release publish my-release

* [auto] Release is deployed to stage
* Review of staging
* Developer merges release branch into master and pushes to origin

        $ git flow release finish my-release

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

    $ createdb cfdm_test
    $ pg_restore --dbname cfdm_test data/subset.dump
    $ ./manage.py update_all

#### Running the tests

    $ nosetests

#### The test data subset

This repo includes a small subset of the staging database (built 2015/08/12) at `data/subset.dump`. To use the test subset for local development:

    $ pg_restore --dbname <dest> data/subset.dump

To build a new test subset, use the `build_test` invoke task:

    $ invoke build_test <source> <dest>

where both `source` and `dest` are valid PostgreSQL connection strings.

To update the version-controlled test subset after rebuilding, run:

    $ invoke dump <source> data/subset.dump

where `source` is the database containing the newly created test subset.

### Git hooks

This repo includes optional post-merge and post-checkout hooks to ensure that
dependencies are up to date. If enabled, these hooks will update Python
dependencies on checking out or merging changes to `requirements.txt`. To
enable the hooks, run

    $ invoke add_hooks

To disable, run

    $ invoke remove_hooks
