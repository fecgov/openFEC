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

## Campaign finance for everyone
The Federal Election Commission (FEC) releases information to the public about money that’s raised and spent in federal elections — that’s elections for US president, Senate, and House of Representatives.

Are you interested in seeing how much money a candidate raised? Or spent? How much debt they took on? Who contributed to their campaign? The FEC is the authoritative source for that information.

betaFEC is a collaboration between [18F](http://18f.gsa.gov) and the FEC. It aims to make campaign finance information more accessible (and understandable) to all users.

## FEC repositories
We welcome you to explore, make suggestions, and contribute to our code.

This repository, [openFEC](https://github.com/18F/openfec), is home to betaFEC’s API.

### All repositories
- [FEC](https://github.com/18F/fec): a general discussion forum. We [compile feedback](https://github.com/18F/fec/issues) from betaFEC’s feedback widget here, and this is the best place to submit general feedback.
- [openFEC](https://github.com/18F/openfec): betaFEC’s API
- [swagger](https://github.com/18F/swagger-ui):this generates our interactive API documentation
- [openFEC-web-app](https://github.com/18f/openfec-web-app): the betaFEC web app for exploring campaign finance data
- [fec-style](https://github.com/18F/fec-style): shared styles and user interface components
- [fec-cms](https://github.com/18F/fec-cms): the content management system (CMS) for betaFEC
- [proxy](https://github.com/18F/fec-proxy): this is a light weight app that coordinates the paths between the web app and cms
- [swagger](https://github.com/18F/swagger-ui):this generates our interactive API documentation


## Get involved
We’re thrilled you want to get involved!
- Read our [contributing guidelines](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md). Then, [file an issue](https://github.com/18F/fec/issues) or submit an issue or pull request.
- [Send us an email](mailto:betafeedback@fec.gov).
- If you’re a developer, follow the installation instructions in the README.md page of each repository to run the apps on your computer.
- Check out our StoriesonBoard [FEC story map](https://18f.storiesonboard.com/m/fec) to get a sense of the user needs we'll be addressing in the future.

---

## Set up

Prior to running, ensure you have the following requirements installed:
<!--requirements-->
* virtualenv
* virtualenvwrapper
* python3.4
* pip
* nodejs
* npm
* PostgreSQL

<!--endrequirements-->

## Quick(ish) start

Clone this repository.

Create a python environment for your project. We use virtualenv and virtualenv wrapper, but feel free to create up your environment with your preferred set up.

You will need your python3 path to make sure you environment is pointing to the right python version. You can find that out by running:
```
which python3
```

To use virtualenv and virtualenv wrapper, in your terminal run:
```
mkvirtualenv open-fec-api --python </path-to-your-python3>
```

Subsequently, you will want to activate the environment every time you run the project with:
```
workon open-fec-api
```
### Install requirements

Use pip to install the requirements for the repo in your python3 environment:
```
pip install -r requirements.txt
```
#### Git hooks
This repo includes optional post-merge and post-checkout hooks to ensure that
dependencies are up to date. If enabled, these hooks will update Python
dependencies on checking out or merging changes to `requirements.txt`. To
enable the hooks, run:
```
invoke add_hooks
```
To disable, run:
```
invoke remove_hooks
```

### Creating a new test database
To run the API locally you will need a database, we provide a sql dump that has a small sample of data to get you running locally.

To create your own test database, make sure you have postgres and run:
```
createdb cfdm_test
pg_restore --dbname cfdm_test data/subset.dump
./manage.py update_all
```
(Don't worry if there are some user does not exist error messages)

FEC and 18F members can set the sql connection to one of the RDS boxes with:
```
export SQLACONN=<psql:address-to-box>
```

### Run locally

Run:
```
./manage.py runserver
```
The site can be found at [http://localhost:5000](http://localhost:5000)


We are always trying to improve our documentation, if you have suggestions or run into problems feel free to [file an issue](https://github.com/18F/openFEC/issues).


## Deployment

##### Likely only useful for 18F team members
To deploy to Cloud Foundry, run `invoke deploy`. The `deploy` task will attempt to detect the appropriate
Cloud Foundry space based the current branch; to override, pass the optional `--space` flag:

```
invoke deploy --space dev
```

The `deploy` task will use the `FEC_CF_USERNAME` and `FEC_CF_PASSWORD` environment variables to log in.
If these variables are not provided, you will be prompted for your Cloud Foundry credentials.

Credentials for Cloud Foundry applications are managed using user-provided services labeled as
"fec-creds-prod", "fec-creds-stage", and "fec-creds-dev". Services are used to share credentials across
blue and green versions of blue-green deploys, and between the API and the webapp. To set up a service:

```
cf target -s dev
cf cups fec-creds-dev -p '{"SQLA_CONN": "..."}'
```

To stand up a user-provided credential service that supports both the API and the webapp, ensure that
the following keys are set:

* SQLA_CONN
* FEC_WEB_USERNAME
* FEC_WEB_PASSWORD
* FEC_WEB_API_KEY
* FEC_WEB_API_KEY_PUBLIC
* NEW_RELIC_LICENSE_KEY

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

```
cf target [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]
```

##### Task queue

Periodic tasks, such as refreshing materialized views and updating incremental
aggregates, are scheduled using celery. We use redis as the celery message broker. To
work with celery and redis locally, install redis and start a redis server. By default,
we connect to redis at `redis://localhost:6379`; if redis is running at a different URL,
set the `FEC_REDIS_URL` environment variable. On Cloud Foundry, we use the redis28-swarm
service. The redis service can be created as follows:

```
cf create-service redis28-swarm standard fec-redis
```

##### Production stack

The OpenFEC API is a Flask application deployed using the gunicorn WSGI server behind
an nginx reverse proxy. Static files are compressed and served directly through nginx;
dynamic content is routed to the Flask application via `proxy_pass`. The entire application
is served through the [API Umbrella](https://apiumbrella.io), which handles API keys,
caching, and rate limiting.

##### Nightly updates

Incrementally-updated aggregates and materialized views are updated nightly; see
`webservices/tasks/refresh.py` for details. When the nightly update finishes, logs and error reports are emailed to the development team--specifically, to email addresses specified in `FEC_EMAIL_RECIPIENTS`.

##### Caching

All API responses are set to expire after one hour (`Cache-Control: public, max-age=3600`).
In production, the [API Umbrella](https://apiumbrella.io) will check this response header
and cache responses for the specified interval, such that repeated requests to a given
endpoint will only reach the Flask application once. This means that responses may be
stale for up to an hour following the nightly refresh of the materialized views.

##### API umbrella

The staging and production environments use the [API Umbrella](https://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_WHITELIST_IPS` flag to reject requests that are not routed
through the API Umbrella.

##### Git-flow and continuous deployment

We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed
through Travis CI accordingly.

###### To create a new feature:
* Developer creates a feature branch
```
git flow feature start my-feature
```

* Reviewer merges feature branch into develop and pushes to origin
* [auto] Develop is deployed to dev

###### To create a hotfix:
* Developer creates a hotfix branch
```
git flow hotfix start my-hotfix
```

* Reviewer merges hotfix branch into develop and master and pushes to origin
* [auto] Develop is deployed to dev
* [auto] Master is deployed to prod

###### To create a release:
* Developer creates a release branch and pushes to origin

```
git flow release start my-release
git flow release publish my-release
```

* [auto] Release is deployed to stage
* Review of staging
* Developer merges release branch into master and pushes to origin

```
git flow release finish my-release
```

* [auto] Master is deployed to prod

##### Data for development and staging environments

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

#### Other developer notes

Sorting fields include a compound index on on the filed to field and a unique field. Because in cases where there were large amounts of data that had the same value that was being evaluated for sort, the was not a stable sort view for results and the results users received were inconsistent, some records given more than once, others given multiple times.

## Testing

Make sure you have [created a new test database](#creating-a-new-test-database)

This repo uses [pytest](http://pytest.org/latest/).

Running the tests:
```
py.test
```

##### The test data subset

When adding new tables to the data, you will need to generate a new subset for testing. We use this nifty subsetting tool- [rdbms-subsetter](https://github.com/18F/rdbms-subsetter).

To build a new test subset, use the `build_test` invoke task:

```
invoke build_test <source> <dest>
```

where both `source` and `dest` are valid PostgreSQL connection strings.

To update the version-controlled test subset after rebuilding, run:

```
invoke dump <source> data/subset.dump
```

where `source` is the database containing the newly created test subset.


## Copyright and licensing
This project is in the public domain within the United States, and we waive worldwide copyright and related rights through [CC0 universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/). Read more on our license page.

A few restrictions limit the way you can use FEC data. For example, you can’t use contributor lists for commercial purposes or to solicit donations. Learn more on FEC.gov.
