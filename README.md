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


## About this project
The Federal Election Commission (FEC) releases information to the public about money that’s raised and spent in federal elections — that’s elections for US president, Senate, and House of Representatives.

Are you interested in seeing how much money a candidate raised? Or spent? How much debt they took on? Who contributed to their campaign? The FEC is the authoritative source for that information.

betaFEC is a collaboration between [18F](http://18f.gsa.gov) and the FEC. It aims to make campaign finance information more accessible (and understandable) to all users.

## This repository, [openFEC](https://github.com/18F/openfec), is home to betaFEC’s API
All FEC repositories:
- [FEC](https://github.com/18F/fec): a general discussion forum. We [compile feedback](https://github.com/18F/fec/issues) from betaFEC’s feedback widget here, and this is the best place to submit general feedback.
- [openFEC](https://github.com/18F/openfec): betaFEC’s API
- [swagger-ui](https://github.com/18F/swagger-ui): forked repo that generates our interactive API documentation
- [openFEC-web-app](https://github.com/18f/openfec-web-app): the web app for exploring campaign finance data
- [fec-style](https://github.com/18F/fec-style): shared styles and user interface components, including this project's glossary and feedback tools
- [fec-cms](https://github.com/18F/fec-cms): this project's content management system (CMS) 
- [proxy](https://github.com/18F/fec-proxy): this is a lightweight app that coordinates the paths between the web app and CMS


## Get involved
We welcome you to explore, make suggestions, and contribute to our code. 
- Read our [contributing guidelines](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md). Then, [file an issue](https://github.com/18F/fec/issues) or submit a pull request.
- If you'd rather send us an email, [we're thrilled to hear from you](mailto:betafeedback@fec.gov)!
- Follow our Set up instructions to run the apps on your computer.
- Check out our StoriesonBoard [FEC story map](https://18f.storiesonboard.com/m/fec) to get a sense of the user needs we'll be addressing in the future.

---

## Set up
We are always trying to improve our documentation. If you have suggestions or run into problems please [file an issue](https://github.com/18F/openFEC/issues)!


### Project prerequisites
1. Ensure you have the following requirements installed:

    * Python 3.4 (which includes pip and virtualenv)
    * The latest long term support (LTS) or stable release of Node.js (which includes npm)
    * PostgreSQL (the latest 9.4 release). 
         * Read a [Mac OSX tutorial](https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/) 
         * Read a [Windows tutorial](http://www.postgresqltutorial.com/install-postgresql/)
         * Read a [Linux tutorial](http://www.postgresql.org/docs/9.4/static/installation.html) (or follow your OS package manager)


2. Set up your Node environment—  learn how to do this with our [Javascript Ecosystem Guide](https://pages.18f.gov/dev-environment-standardization/languages/javascript/).

3. Set up your Python environment— learn how to do this with our [Python Ecosystem Guide](https://pages.18f.gov/dev-environment-standardization/languages/python/).

4. Clone this repository.

### Project dependencies

#### Install project requirements

Use pip to install the Python dependencies. 
```
pip install -r requirements.txt
pip install -r requirements-dev.txt
```
Use npm to install JavaScript dependencies:
```
npm install
```

##### Git hooks
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

#### Create local databases
Before you can run this project locally, you'll need an API database and a test database. 

To create your databases, run:
```
createdb cfdm_test
createdb cfdm_unit_test
```
Load our sample data into the development database (`cfdm_test`) by running:
```
pg_restore --dbname cfdm_test data/subset.dump
./manage.py update_all
```
Ignore `user does not exist` error messages. Everything will still work!

**Note**: *FEC and 18F members can set the SQL connection to one of the RDS boxes with:*
```
export SQLA_CONN=<psql:address-to-box>
```
*Reach out to a team member to get the actual addresses.* 


#### Set other environment variables

1. Run: 
```
export FEC_WEB_DEBUG=true
```
This shows error details and more verbose request logging. 

2: Run: 
```
export FEC_WEB_STYLE_URL=http://localhost:8080/css/styles.css
export FEC_WEB_API_URL='http://localhost:5000'
export FEC_CMS_URL='http://localhost:8000'
```
These are the default URLs to the other local FEC applications. For complete set-up instructions, explore our documentation for [fec-style](https://github.com/18F/fec-style/blob/master/README.md), [openFEC-webb-app](https://github.com/18F/openFEC-web-app/blob/develop/README.md), and [fec-cms](https://github.com/18F/fec-cms/blob/develop/README.rst).

Note: If you modify your local environment to run these applications at a different address, be sure to update these environment variables to match. 

3. Run: 
```
export FEC_WEB_USERNAME=<username_of_your_choosing>
export FEC_WEB_PASSWORD=<password_of_your_choosing>
```
Create these account credentials to gain full access to the application. You can set them to any username and password of your choosing.  
*Note: 18F and FEC team members will have additional environment variables to set up. Please reach out to a team member for detailed information.*


#### Run locally
Follow these steps every time you want to work on this project locally.

1. Run:
```
./manage.py runserver
```
2 .View your local version of the site at [http://localhost:5000](http://localhost:5000).

### Deployment (18F and FEC team members only)

#### Deployment prerequisites
If you haven't used Cloud Foundry in other projects, you'll need to install the Cloud Foundry CLI and the autopilot plugin.


##### Deploy

Before deploying, install the [Cloud Foundry CLI](https://docs.cloudfoundry.org/devguide/cf-cli/install-go-cli.html) and the [autopilot plugin](https://github.com/concourse/autopilot):

1. Read [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/cf-cli/install-go-cli.html) to install Cloud Foundry CLI.

2. Install autopilot by running:
```
cf install-plugin autopilot -r CF-Community
```
    [Learn more about autopilot](https://github.com/concourse/autopilot).

3. Set environment variables used by the deploy script:

```
export FEC_CF_USERNAME=<your_cf_username>
export FEC_CF_PASSWORD=<your_cf_password>
```

If these variables aren't set, you'll be prompted for your Cloud Foundry credentials when you deploy the app.


#### Deployment steps
1. To deploy to Cloud Foundry, run 

```
invoke deploy
```

[Learn more about Invoke](http://www.pyinvoke.org/).

The `deploy` task will detect the appropriate Cloud Foundry space based the current branch. You can override this with the optional `--space` flag. For example:

```
invoke deploy --space dev
```
This command will explicitly target the `dev` space.

##### Setting up a service (optional):

```
cf target -s dev
cf cups fec-creds-dev -p '{"SQLA_CONN": "..."}'
```

To stand up a user-provided credential service that supports both the API and the webapp, ensure that
the following keys are set:

* SQLA_CONN
* FEC_WEB_API_KEY
* FEC_WEB_API_KEY_PUBLIC
* FEC_GITHUB_TOKEN
* SENTRY_DSN
* SENTRY_PUBLIC_DSN
* NEW_RELIC_LICENSE_KEY

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

```
cf target -o [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]
```
*Note: Performing a deploy in this manner will result in a brief period of downtime.*

### Title here (other dev tasks)


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


Running redis and celery locally:

```
redis-server
celery worker --app webservices.tasks
```

Note: Both the API and celery worker must have access to the relevant environment variables and services (PostgreSQL, S3).

###### Production stack

The OpenFEC API is a Flask application deployed using the gunicorn WSGI server behind
an nginx reverse proxy. Static files are compressed and served directly through nginx;
dynamic content is routed to the Flask application via `proxy_pass`. The entire application
is served through the [API Umbrella](https://apiumbrella.io), which handles API keys,
caching, and rate limiting.

###### Nightly updates

Incrementally-updated aggregates and materialized views are updated nightly; see
`webservices/tasks/refresh.py` for details. When the nightly update finishes, logs and error reports are emailed to the development team--specifically, to email addresses specified in `FEC_EMAIL_RECIPIENTS`.

###### Caching

All API responses are set to expire after one hour (`Cache-Control: public, max-age=3600`).
In production, the [API Umbrella](https://apiumbrella.io) will check this response header
and cache responses for the specified interval, such that repeated requests to a given
endpoint will only reach the Flask application once. This means that responses may be
stale for up to an hour following the nightly refresh of the materialized views.

###### API umbrella

The staging and production environments use the [API Umbrella](https://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_WHITELIST_IPS` flag to reject requests that are not routed
through the API Umbrella.

###### Git-flow and continuous deployment

We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed
through Travis CI accordingly.

####### To create a new feature:
* Developer creates a feature branch
```
git flow feature start my-feature
```

* Reviewer merges feature branch into develop and pushes to origin
* [auto] Develop is deployed to dev

####### To create a hotfix:
* Developer creates a hotfix branch
```
git flow hotfix start my-hotfix
```

* Reviewer merges hotfix branch into develop and master and pushes to origin
* [auto] Develop is deployed to dev
* [auto] Master is deployed to prod

####### To create a release:
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

###### Data for development and staging environments

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

##### Other developer notes

Sorting fields include a compound index on on the filed to sort and a unique field. Because in cases where there were large amounts of data that had the same value that was being evaluated for sort, the was not a stable sort view for results and the results users received were inconsistent, some records given more than once, others given multiple times.

### Testing

Make sure you have [created a new test database](#creating-a-new-test-database).

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



