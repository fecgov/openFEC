**Develop**
[![CircleCI](https://circleci.com/gh/18F/openFEC.svg?style=svg)](https://circleci.com/gh/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/develop.svg)](https://codecov.io/github/18F/openFEC)

**Master**
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/master.svg)](https://codecov.io/github/18F/openFEC)
[![Code Climate](https://img.shields.io/codeclimate/github/18F/openFEC.svg)](https://codeclimate.com/github/18F/openFEC)
[![Dependencies](https://img.shields.io/gemnasium/18F/openFEC.svg)](https://gemnasium.com/18F/openFEC)

![Swagger validation badge](https://online.swagger.io/validator?url=https://api.open.fec.gov/swagger)

## About this project
The Federal Election Commission (FEC) releases information to the public about money that's raised and spent in federal elections — that's elections for US President, Senate, and House of Representatives.

Are you interested in seeing how much money a candidate raised? Or spent? How much debt they took on? Who contributed to their campaign? The FEC is the authoritative source for that information.

The new FEC.gov is a collaboration between [18F](https://18f.gsa.gov) and the FEC. It aims to make campaign finance information more accessible (and understandable) to all users.


## This repository, [openFEC](https://github.com/18F/openfec), is home to the FEC’s API
All FEC repositories:
- [FEC](https://github.com/18F/fec): a general discussion forum. We [compile feedback](https://github.com/18F/fec/issues) from the FEC.gov feedback widget here, and this is the best place to submit general feedback.
- [openFEC](https://github.com/18F/openfec): the first RESTful API for the Federal Election Commission
- [swagger-ui](https://github.com/18F/swagger-ui): forked repo that generates our interactive API documentation
- [fec-cms](https://github.com/18F/fec-cms): this project's content management system (CMS)
- [fec-proxy](https://github.com/18F/fec-proxy): this is a lightweight app that coordinates the paths between the web app and CMS


## Get involved
We welcome you to explore, make suggestions, and contribute to our code.
- Read our [contributing guidelines](https://github.com/18F/openfec/blob/master/CONTRIBUTING.md). Then, [file an issue](https://github.com/18F/fec/issues) or submit a pull request.
- If you'd rather send us an email, [we're thrilled to hear from you](mailto:betafeedback@fec.gov)!
- Follow our Set up instructions to run the apps on your computer.

---


## Set up
We are always trying to improve our documentation. If you have suggestions or run into problems please [file an issue](https://github.com/18F/openFEC/issues)!

### Project prerequisites
1. Ensure you have the following requirements installed:

    * Python (the latest 3.5 release, which includes `pip` and and a built-in version of `virtualenv` called `venv`).
    * The latest long term support (LTS) or stable release of Node.js (which includes npm)
    * PostgreSQL (the latest 9.6 release).
         * Read a [Mac OSX tutorial](https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/)
         * Read a [Windows tutorial](http://www.postgresqltutorial.com/install-postgresql/)
         * Read a [Linux tutorial](https://www.postgresql.org/docs/9.4/static/installation.html) (or follow your OS package manager)
    * Elastic Search 2.4 (instructions [here](https://www.elastic.co/guide/en/elasticsearch/reference/2.4/_installation.html)

2. Set up your Node environment—  learn how to do this with our [Javascript Ecosystem Guide](https://github.com/18F/dev-environment-standardization/blob/18f-pages/pages/languages/javascript.md).

3. Set up your Python environment— learn how to do this with our [Python Ecosystem Guide](https://github.com/18F/dev-environment-standardization/blob/18f-pages/pages/languages/python.md).

4. Clone this repository.

### Project dependencies

#### Install project requirements

Use `pip` to install the Python dependencies:

```
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

Use `npm` to install JavaScript dependencies:

```
nvm use --lts
npm install -g swagger-tools
npm install
npm run build
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
Before you can run this project locally, you'll need a development database and a test database.

To create these databases, run:

```
createdb cfdm_test
createdb cfdm_unit_test
```

Load our sample data into the development database (`cfdm_test`) by running:

```
pg_restore --dbname cfdm_test --no-acl --no-owner data/subset.dump
./manage.py update_all
```

Ignore `user does not exist` error messages. Everything will still work!

Next you'll need to load some documents into elastic search in order to create the search index.
To load statutes into elasticsearch, run:

```
python manage.py index_statutes
```

#### Connecting to a RDS DB instance instead of local DB

*Note: FEC and 18F members can set the SQL connection to one of the RDS boxes with:*

```
export SQLA_CONN=<psql:address-to-box>
```

Warning: never perform 'update all' when pointing to an RDS box via the SQLA_CON
N env var

*Note: An additional setting for connecting to and utilizing mirrors/replica boxes can also be set with:*

```
export SQLA_FOLLOWERS=<psql:address-to-replica-box-1>[,<psql:address-to-replica-box-2>,...]
```

*Note: This is a comma separated (with no spaces) string that contains one or more connection strings to any replicas/mirrors that are setup.*

*Reach out to a team member to get the actual addresses for all of these connections.*

#### Set other environment variables
1. Run:

   ```
   export FEC_WEB_DEBUG=true
   ```

   This shows error details and more verbose request logging.

2. Run:

   ```
   export FEC_API_URL=http://localhost:5000
   export FEC_CMS_URL=http://localhost:8000
   ```

   These are the default URLs to the other local FEC applications. For complete set-up instructions, explore our documentation for [fec-cms](https://github.com/18F/fec-cms/blob/develop/README.md).

   *Note: If you modify your local environment to run these applications at a different address, be sure to update these environment variables to match.*

3. If you do not login to CloudFoundry with SSO (single sign-on), run:

   ```
   export FEC_WEB_USERNAME=<username_of_your_choosing>
   export FEC_WEB_PASSWORD=<password_of_your_choosing>
   ```

   Create these account credentials to gain full access to the application. You can set them to any username and password of your choosing.

   *Note: 18F team members should not set these environment variables. 18F and FEC team members will also have additional environment variables to set up. Please reach out to a team member for detailed information.*

4. If you are using database replicas/mirrors you can also restrict connections to them to be asynchronous tasks only by running:

   ```
   export SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS=enabled
   ```

#### Run locally
Follow these steps every time you want to work on this project locally.

1. If you are using the legal search portion of the site, you will need Elastic Search running.
Navigate to the installation folder (eg., `elasticsearch-1.7.5`) and run:

```
cd bin
./elasticsearch
```

2. Start the web server:

   ```
   ./manage.py runserver
   ```

3. View your local version of the site at [http://localhost:5000](http://localhost:5000).

#### Task queue
We use [Celery](http://www.celeryproject.org/) to schedule periodic tasks— for example, refreshing materialized views and updating incremental aggregates. We use [Redis](https://redis.io/) as the Celery message broker.

To work with Celery and Redis locally, install Redis and start a Redis server. By default,
we connect to Redis at `redis://localhost:6379`; if Redis is running at a different URL,
set the `FEC_REDIS_URL` environment variable.

*Note: Both the API and Celery worker must have access to the relevant environment variables and services (PostgreSQL, S3).*

Running Redis and Celery locally:

```
redis-server
celery worker --app webservices.tasks
```

## Testing
This repo uses [pytest](https://docs.pytest.org/en/latest/).

If the test database server is *not* the default local Postgres instance, indicate it using:

```
export SQLA_TEST_CONN=<psql:address-to-box>
```

Running the tests:

```
py.test
```

#### The test data subset
If you add new tables to the data, you'll need to generate a new subset for testing. We use this nifty subsetting tool: [rdbms-subsetter](https://github.com/18F/rdbms-subsetter).

To build a new test subset, first delete and recreate the test database:

```
dropdb cfdm_test
createdb cfdm_test
```

Now use the `build_test` invoke task to populate the new database with the new subset:

```
invoke build_test <source> postgresql://:@/cfdm_test
```

where `source` is a valid PostgreSQL connection string.
To update the version-controlled test subset after rebuilding, run:

```
invoke dump postgresql://:@/cfdm_test data/subset.dump
```

## Deployment (18F and FEC team only)

### Deployment prerequisites
If you haven't used Cloud Foundry in other projects, you'll need to install the Cloud Foundry CLI and the autopilot plugin.

#### Deploy
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

### Deployment steps
To deploy to Cloud Foundry, run:

```
invoke deploy
```

[Learn more about Invoke](http://www.pyinvoke.org/).

The `deploy` task will detect the appropriate Cloud Foundry space based the current branch. You can override this with the optional `--space` flag. For example:

```
invoke deploy --space dev
```

This command will explicitly target the `dev` space.

#### Setting up a service
On Cloud Foundry, we use the redis32
service. The Redis service can be created as follows:

```
cf create-service redis32 standard-ha fec-redis
```

#### Setting up credentials
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
* NEW_RELIC_LICENSE_KEY
* WRITE_AUTHORIZED_TOKENS

Deploys of a single app can be performed manually by targeting the env/space, and specifying the corresponding manifest, as well as the app you want, like so:

```
cf target -o [dev|stage|prod] && cf push -f manifest_<[dev|stage|prod]>.yml [api|web]
```

*Note: Performing a deploy in this manner will result in a brief period of downtime.*

#### Running commands remotely
There may be a time when you need to run a command remotely, e.g., a management command to update database schemas. Cloud Foundry currently doesn't support a way of connecting to an app that is running directly, so you need to deploy a one-off app specifically for running commands instead.

To accomplish this, follow these steps:

1. Make sure you're pointing to the correct target space:

   ```
   cf target -o fec -s <dev | stage | prod>
   ```

2. Create a new app manifest for this one-off app (choose whatever file name you wish, ending with the `.yml` extension):

   ```
   cf create-app-manifest api -p <one-off-app-manifest-filename.yml>
   ```

3. Open the newly created one-off app manifest file and **add/modify** the following YAML properties to it (be sure to maintain all of the other existing properties):

   ```
   name: one-off-app-name
   command: "<your command here, e.g., python manage.py update_all> && sleep infinity"
   no-route: true
   ```

   *Note: the* `&& sleep infinity` *part is needed as the end of the command you specify so that Cloud Foundry doesn't attempt to redeploy the app once the command finishes.*

4. Using the same app name you just specified in the custom manifest file, push your application to Cloud Foundry:

   ```
   cf push <one-off-app-name> -f <one-off-app-manifest-filename.yml>
   ```

Once the app is pushed, you can also tail the logs to make see when the command finishes:

```
cf logs <one-off-app-name>
```

When the command you want to run finishes, be sure to stop and delete the app to free resources in Cloud Foundry:

```
cf stop <one-off-app-name>
cf delete <one-off-app-name>
```

One other thing you may want to consider doing is adding explicit log statements or an email notification to whatever command you are running so that you know for sure when the command finishes (or errors out). However, please do not check in these custom modifications.

*Note: We hope to have a better way of accomplishing this in the future.*

### SSH
*Likely only useful for 18F FEC team members*

You can SSH directly into the running app container to help troubleshoot or inspect things with the instance(s).  Run the following command:

```bash
cf ssh <app name>
```

Where *<app name>* is the name of the application instance you want to connect to.  Once you are logged into the remote secure shell, you'll also want to run this command to setup the shell environment correctly:

```bash
. /home/vcap/app/bin/cf_env_setup.sh
```

More information about using SSH with cloud.dov can be found in the [cloud.gov SSH documentation](https://cloud.gov/docs/apps/using-ssh/#cf-ssh).

### Create a changelog
If you're preparing a release to production, you should also create a changelog. The preferred way to do this is using the [changelog generator](https://github.com/skywinder/github-changelog-generator).

Once installed, run:

```
github_changelog_generator --since-tag <last public-relase> --t <your-gh-token>
```

When this finishes, commit the log to the release.


## Git-flow and continuous deployment
We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed through Travis CI accordingly.

### Creating a new feature
* Developer creates a feature branch and pushes to `origin`:

    ```
    git flow feature start my-feature
    git push origin feature/my-feature
    ```

* Reviewer merges feature branch into `develop` via GitHub
* [auto] `develop` is deployed to `dev`

### Creating a hotfix
* Developer creates a hotfix branch:

    ```
    git flow hotfix start my-hotfix
    ```

* Reviewer merges hotfix branch into `develop` and `master` and pushes to `origin`:

    ```
    git flow hotfix finish my-hotfix
    git checkout master
    git push origin master --follow-tags
    git checkout develop
    git push origin develop
    ```

* `develop` is deployed to `dev`
* `master` is deployed to `prod`

### Creating a release
* Developer creates a release branch and pushes to `origin`:

    ```
    git flow release start my-release
    git push origin release/my-release
    ```

* [auto] `release/my-release` is deployed to `stage`
* Review of staging
* Issue a pull request to master
* Check if there are any SQL files changed. Depending on where the changes are, you may need to run migrations. Ask the person who made the change what, if anything, you need to run.
* Developer merges release branch into `master` (and backmerges into `develop`) and pushes to origin:

    ```
    git config --global push.followTags true
    git flow release finish my-release
    ```
    You'll need to save several merge messages, and add a tag message which is named the name of the release (eg., public-beta-20170118).
    ```
    git checkout develop
    git push origin develop
    ```
    Watch the develop build on travis and make sure it passes. Now you are ready to push to prod (:tada:).

    ```
    git checkout master
    git push origin master --follow-tags
    ```
   Watch travis to make sure it passes, then test the production site manually to make sure everything looks ok.

* `master` is deployed to `prod`
* `develop` is deployed to `dev`


## Additional developer notes
This section covers a few topics we think might help developers after setup.

### API umbrella
The staging and production environments use the [API Umbrella](https://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_WHITELIST_IPS` flag to reject requests that are not routed
through the API Umbrella.

### Caching
All API responses are set to expire after one hour (`Cache-Control: public, max-age=3600`).
In production, the [API Umbrella](https://apiumbrella.io) will check this response header
and cache responses for the specified interval, such that repeated requests to a given
endpoint will only reach the Flask application once. This means that responses may be
stale for up to an hour following the nightly refresh of the materialized views.

### Data for development and staging environments
The production and staging environments use relational database service (RDS) instances that receive streaming updates from the FEC database. The development environment uses a separate RDS instance created from a snapshot of the production instance.

### Nightly updates
Incrementally-updated aggregates and materialized views are updated nightly; see
`webservices/tasks/refresh.py` for details. When the nightly update finishes, logs and error reports are emailed to the development team--specifically, to email addresses specified in `FEC_EMAIL_RECIPIENTS`.

### Loading legal documents
There are individual management commands for loading individual legal documents. More information is available by invoking each of these commands with a `--help` option. These commands can be run as [tasks](https://docs.cloudfoundry.org/devguide/using-tasks.html) on `cloud.gov`, e.g.,
```
cf run-task api  "python manage.py index_statutes" -m 2G --name index-statutes
```
The progress of these tasks can be monitored using, e.g.,
```
cf logs api | grep reinit-legal
```


#### Loading statutes
```
python manage.py index_statutes
```

#### Loading regulations
```
python manage.py index_regulations
```
This command requires that the environment variable `FEC_EREGS_API` is set to the API endpoint of a valid `eregs` instance.

#### Loading advisory opinions
```
python manage.py load_advisory_opinions [-f FROM_AO_NO]
```

#### Loading current MURs
```
python manage.py load_current_murs [-f FROM_MUR_NO]
```

#### Loading all legal documents for the 1st time
```
python manage.py reinitialize_all_legal_docs
```

#### Loading all legal documents with no downtime
```
python manage.py refresh_legal_docs_zero_downtime
```
This command is typically used when there is a schema change. A staging index is built
and populated in the background. When ready, the staging index is moved to the production index with no downtime.


### Production stack
The OpenFEC API is a Flask application deployed using the gunicorn WSGI server behind
an nginx reverse proxy. Static files are compressed and served directly through nginx;
dynamic content is routed to the Flask application via `proxy_pass`. The entire application
is served through the [API Umbrella](https://apiumbrella.io), which handles API keys,
caching, and rate limiting.

### Sorting fields
Sorting fields include a compound index on on the filed to sort and a unique field. Because in cases where there were large amounts of data that had the same value that was being evaluated for sort, the was not a stable sort view for results and the results users received were inconsistent, some records given more than once, others given multiple times.

### Database mirrors/replicas
Database mirrors/replicas are supported by the API if the `SQLA_FOLLOWERS` is set to one or more valid connection strings.  By default, setting this environment variable will shift all `read` operations to any mirrors/replicas that are available (and randomly choose one to target per request if there are more than one).

You can optionally choose to restrict traffic that goes to the mirrors/replicas to be the asynchronous tasks only by setting the `SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS` environment variable to something that will evaluate to `True` in Python (simply using `True` as the value is fine).  If you do this, you can also restrict which tasks are supported on the mirrors/replicas.  Supported tasks are configured by adding their fully qualified names to the `app.config['SQLALCHEMY_FOLLOWER_TASKS']` list in order to whitelist them.  By default, only the `download` task is enabled.
