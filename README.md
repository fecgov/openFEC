**Develop**
[![CircleCI](https://circleci.com/gh/fecgov/openFEC.svg?style=svg)](https://circleci.com/gh/fecgov/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/fecgov/openFEC/develop.svg)](https://codecov.io/github/fecgov/openFEC)

**Master**
[![Test Coverage](https://img.shields.io/codecov/c/github/fecgov/openFEC/master.svg)](https://codecov.io/github/fecgov/openFEC)

**package.json**
[![Known Vulnerabilities](https://snyk.io/test/github/fecgov/openFEC/badge.svg?targetFile=package.json)](https://snyk.io/test/github/fecgov/openFEC?targetFile=package.json)
**requirements.txt**
[![Known Vulnerabilities](https://snyk.io/test/github/fecgov/openFEC/badge.svg?targetFile=requirements.txt)](https://snyk.io/test/github/fecgov/openFEC?targetFile=requirements.txt)
**flyway**
[![Known Vulnerabilities](https://snyk.io/test/github/fecgov/openFEC/badge.svg?targetFile=data/flyway/build.gradle)](https://snyk.io/test/github/fecgov/openfec?targetFile=data/flyway/build.gradle)


## About this project
The Federal Election Commission (FEC) releases information to the public about money that's raised and spent in federal elections — that's elections for US President, Senate, and House of Representatives.

Are you interested in seeing how much money a candidate raised? Or spent? How much debt they took on? Who contributed to their campaign? The FEC is the authoritative source for that information.

The new FEC.gov aims to make campaign finance information more accessible (and understandable) to all users.


## This repository, [openFEC](https://github.com/fecgov/openfec), is home to the FEC’s API
All FEC repositories:
- [FEC](https://github.com/fecgov/fec): a general discussion forum. We [compile feedback](https://github.com/fecgiv/fec/issues) from the FEC.gov feedback widget here, and this is the best place to submit general feedback.
- [openFEC](https://github.com/fecgov/openfec): the first RESTful API for the Federal Election Commission
- [fec-cms](https://github.com/fecgov/fec-cms): this project's content management system (CMS)
- [fec-proxy](https://github.com/fecgov/fec-proxy): this is a lightweight app that coordinates the paths between the web app and CMS


## Get involved
We welcome you to explore, make suggestions, and contribute to our code.
- Read our [contributing guidelines](https://github.com/fecgov/openfec/blob/master/CONTRIBUTING.md). Then, [file an issue](https://github.com/fecgov/fec/issues) or submit a pull request.
- If you'd rather send us an email, [we're thrilled to hear from you](mailto:apiinfo@fec.gov)!
- Follow our Set up instructions to run the apps on your computer.

---


## Set up
We are always trying to improve our documentation. If you have suggestions or run into problems please [file an issue](https://github.com/fecgov/openFEC/issues)!

### Project prerequisites
1. Ensure you have the following requirements installed:

    * Python (the latest 3.9 release, which includes `pip` and a built-in version of `virtualenv` called `venv`).
    * The latest long term support (LTS) or stable release of Node.js (which includes npm)
    * PostgreSQL (the latest 13 release).
         * Read a [Mac OSX tutorial](https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/)
         * Read a [Windows tutorial](https://www.postgresqltutorial.com/install-postgresql/)
         * Read a [Linux tutorial](https://www.postgresql.org/docs/13/installation.html) (or follow your OS package manager)
    * Elastic Search 7.x (instructions [here](https://www.elastic.co/guide/en/elasticsearch/reference/7.x/_installation.html))
    * Flyway 9.10.1 ([download](https://flywaydb.org/documentation/usage/commandline/))
		* After downloading, open `flyway-9.10.1/conf/flyway.conf` and set
           the flyway environment variables `flyway.url` and
           `flyway.locations` as

		   ```
		   flyway.locations=filesystem:/Users/<user>/<project>/api/openFEC/data/migrations
		   flyway.url=jdbc:postgresql://localhost:5432/cfdm_test?user=<your local database username>&password=<your local database password>
		   ```

		   to enable connection to a local database (e.g., `cfdm_test` from [Create
           a test database](https://github.com/fecgov/openFEC#create-a-development-database), below) and specify the location of the database migration files (SQL)
    * See [Database migrations](https://github.com/fecgov/openFEC#database-migration) for more information on installing and configuring flyway

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

#### Create a test database
In order to run tests locally, you'll need a test database.

To create the test database, run:

```
createdb cfdm_unit_test
```

#### Create a development database
Before you can run this project locally, you'll need a development database.


To create the development database, run:

```
createdb cfdm_test
```

Set the environment variable SQLA_SAMPLE_DB_CONN to point to this database, using:

```
export SQLA_SAMPLE_DB_CONN="postgresql://<username>:<password>@localhost:<port - default is 5432>/cfdm_test"
```

Load our sample data into the development database (`cfdm_test`) by running:

```
invoke create_sample_db
```
This will run `flyway` migrations on the empty database to create the schema, and then load sample data into this database from `data/sample_db.sql`.

---

#### Connecting to a RDS DB instance instead of local DB

*Note: FEC members can set the SQL connection to one of the RDS boxes with:*

```
export SQLA_CONN=<psql:address-to-box>
```

Warning: never perform 'update all' when pointing to an RDS box via the SQLA_CONN env var

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

   These are the default URLs to the other local FEC applications. For complete set-up instructions, explore our documentation for [fec-cms](https://github.com/fecgov/fec-cms/blob/develop/README.md).

   *Note: If you modify your local environment to run these applications at a different address, be sure to update these environment variables to match.*

3. If you do not login to CloudFoundry with SSO (single sign-on), run:

   ```
   export FEC_WEB_USERNAME=<username_of_your_choosing>
   export FEC_WEB_PASSWORD=<password_of_your_choosing>
   ```

   Create these account credentials to gain full access to the application. You can set them to any username and password of your choosing.

   *Note: FEC team members will also have additional environment variables to set up. Please reach out to a team member for detailed information.*

4. If you are using database replicas/mirrors you can also restrict connections to them to be asynchronous tasks only by running:

   ```
   export SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS=enabled
   ```

#### Run locally
Follow these steps every time you want to work on this project locally.

1. Set the FLASK_APP environment variable to specify how to load the application. Flask is used when running the project locally, so you will want to turn the debugger on as well. If you'd like to run in  development mode (reloader will trigger whenever your code or imported modules change and debugger is on by default) you can set FLASK_ENV=development. Pyenv-dotenv should set these for you automatically by reading .flaskenv. 
   ```
   export FLASK_APP=webservices.rest
   export FLASK_DEBUG=1
   ```

2. If you are using the legal search portion of the site, you will need Elastic Search running.
Navigate to the installation folder (eg., `elasticsearch-7.4`) and run:

   ```
   cd bin
   ./elasticsearch
   ```

2. Start the web server:

   ```
   flask run
   ```
   or

   ```
   python cli.py run
   ```

3. View your local version of the site at [http://localhost:5000](http://localhost:5000).

#### Task queue
We use [Celery](https://www.celeryproject.org/) to schedule periodic tasks— for example, refreshing materialized views and updating incremental aggregates. We use [Redis](https://redis.io/) as the Celery message broker.

To work with Celery and Redis locally, install Redis and start a Redis server. By default,
we connect to Redis at `redis://localhost:6379`; if Redis is running at a different URL,
set the `FEC_REDIS_URL` environment variable.

*Note: Both the API and Celery worker must have access to the relevant environment variables and services (PostgreSQL, S3).*

Running Redis and Celery locally:

```
redis-server
celery --app webservices.tasks worker
celery --app webservices.tasks beat 
```

## Editing Swagger
We are using a customized 2.x version of swagger-ui to display our API developer documentation.

### Template and Swagger spec file
The base template for swagger-ui is located at `webservices/templates/swagger-ui.html`. The `{{ specs_url }}` template variable points to `http://localhost:5000/swagger` that is the swagger spec file for FEC specific model definitions and schema. Compiled and vendor assets are served from `static/swagger-ui/`.

### Custom Swagger setup and build
The swagger-ui package is within the `swagger-ui` directory. The `hbs` folder contains handlebars templates with customizations, as do the files contained in the `js` and `less` folders. However, the `js/swagger-client.js` is the base v2.1.32 swager-ui file.

All these files are then built and compiled via the `npm run build` command that runs Gulp tasks. Any modification should be done in the files in `swagger-ui` that will then be compiled and served in the `static/swagger-ui/` folder.

## Testing
This repo uses [pytest](https://docs.pytest.org/en/latest/).

If the test database server is *not* the default local Postgres instance, indicate it using:

```
export SQLA_TEST_CONN=<psql:address-to-box>
```

The connection URL has to strictly adhere to the structure `postgresql://<username>:<password>@<hostname>:<port>/<database_name>`. Note that the database_name should be specified explicitly, unlike URLs for SQLAlchemy connections.

Running the tests:

```
pytest
```

Running only the pep8 linting:

```
pytest --linting
```

Running the tests without pep8 linting:

```
pytest --no-linting
```

#### The test data subset
If you add new tables to the data, you'll need to generate a new subset for testing.

We have used this nifty subsetting tool: [rdbms-subsetter](https://github.com/18F/rdbms-subsetter). Though it may be easier to add some sample data manually.

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

## Deployment (FEC team only)

### Deployment prerequisites
If you haven't used Cloud Foundry in other projects, you'll need to install the Cloud Foundry CLI.

#### Deploy
Before deploying, install version 7 of the [Cloud Foundry CLI](https://docs.cloudfoundry.org/devguide/cf-cli/install-go-cli.html):

1. Read [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/cf-cli/install-go-cli.html) to install version 7 of the Cloud Foundry CLI.

2. Set environment variables used by the deploy script:

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

[Learn more about Invoke](https://www.pyinvoke.org/).

The `deploy` task will detect the appropriate Cloud Foundry space based the current branch. You can override this with the optional `--space` flag. For example:

```
invoke deploy --space dev
```

This command will explicitly target the `dev` space.

To run migrations with a manual deploy, run:

```
invoke deploy --space dev --migrate-database
```


#### Setting up a service
On Cloud Foundry, we use the aws-elasticache-redis
service. For more information about plan names, see the
[cloud.gov aws-elasticache-redis documentation](https://cloud.gov/docs/services/aws-elasticache/)

The Redis service can be created as follows:

```
cf create-service aws-elasticache-redis <plan_name> fec-elasticache-redis
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
   command: "<your command here, e.g., python cli.py refresh_materialized> && sleep infinity"
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
*Likely only useful for FEC team members*

You can SSH directly into the running app container to help troubleshoot or inspect things with the instance(s).  Run the following command:

```bash
cf ssh <app name>
```

Where *<app name>* is the name of the application instance you want to connect to.  Once you are logged into the remote secure shell, you'll also want to run this command to setup the shell environment correctly:

```bash
. /home/vcap/app/bin/cf_env_setup.sh
```

More information about using SSH with cloud.gov can be found in the [cloud.gov SSH documentation](https://cloud.gov/docs/apps/using-ssh/#cf-ssh).

### Create a changelog
If you're preparing a release to production, you should also create a changelog. The preferred way to do this is using the [changelog generator](https://github.com/skywinder/github-changelog-generator).

Once installed, run:

```
github_changelog_generator --since-tag <last public-relase> --t <your-gh-token>
```

When this finishes, commit the log to the release.


## Git-flow and continuous deployment
We use git-flow for naming and versioning conventions. Both the API and web app are continuously deployed through Circle CI accordingly.

### Creating a new feature
* Developer creates a feature branch and pushes to `origin`:

    ```
    git flow feature start my-feature
    git push origin feature/my-feature
    ```

* Reviewer merges feature branch into `develop` via GitHub
* [auto] `develop` is deployed to `dev`

### Creating a hotfix
* Developer makes sure their local master and develop branches are up to date:

   ```
   git checkout develop
   git pull
   git checkout master
   git pull
   ```

* Developer creates a hotfix branch, commits changes, and **makes a PR to the `master` branch**:

    ```
    git flow hotfix start my-hotfix
    git push origin hotfix/my-hotfix
    ```

* Reviewer merges hotfix branch into `develop` and `master` and pushes to `origin`:

    ```
    git flow hotfix finish my-hotfix
    git checkout develop
    git push origin develop
    ```

* `develop` is deployed to `dev`. Make sure the build passes before deploying to `master`.

    ```
    git checkout master
    git push origin master --follow-tags
    ```

* `master` is deployed to `prod`

### Creating a release
* Developer creates a release branch and pushes to `origin`:

    ```
    git flow release start my-release
    git push origin release/my-release
    ```

* [auto] `release/my-release` is deployed to `stage`
* Issue a pull request to master, tag reviewer(s)
* Review of staging
* Check if there are any SQL files changed. Depending on where the changes are, you may need to run migrations. Ask the person who made the change what, if anything, you need to run.
* Make sure your pull request has been approved
* Make sure local laptop copies of `master`, `develop`, and `release/[release name]` github branches are up-to-date by checking them out and using `git pull` for each branch.
* Rebuild candidate release branch, i.e., `release/public-YYYYMMDD`, in staging environment, and verify there are no errors and that build passes.
* Developer merges release branch into `master` (and backmerges into `develop`) and pushes to origin:

    ```
    git config --global push.followTags true
    git flow release finish my-release
    ```
    You'll need to save several merge messages, and add a tag message which is named the name of the release (eg., public-beta-20170118). Check to see what `git branch` returns. If it shows you are on `master`, ignore the next step for checking out and pushing to `develop`.
    ```
    git checkout develop
    git push origin develop
    ```
    Watch the develop build on Circle and make sure it passes. Now you are ready to push to prod (:tada:).

    ```
    git checkout master
    git log         # make sure tag for release is present
    git push origin master --follow-tags
    ```
   Watch Circle to make sure it passes, then test the production site manually to make sure everything looks ok.

* `master` is deployed to `prod`
* `develop` is deployed to `dev`


## Additional developer notes
This section covers a few topics we think might help developers after setup.

### API umbrella
The staging and production environments use the [API Umbrella](https://apiumbrella.io) for
rate limiting, authentication, caching, and HTTPS termination and redirection. Both
environments use the `FEC_API_USE_PROXY` flag to reject requests that are not routed
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
`webservices/tasks/refresh.py` for details. When the nightly update finishes, logs and error reports are slacked to the team.

### Refreshing materialized views (excluding nightly mv refresh job)
The materialized views are manually refreshed when something needs to be removed or updated on the website (data section) on-demand. 

* Log in to CloudFoundry ([Resource](https://docs.cloudfoundry.org/devguide/using-tasks.html))
* Select the ${cf_space} space
* Run this command:
    
    ```
    cf run-task api --command "python cli.py refresh_materialized" --name refresh_mv
    ```
* Check status of task:

    ```
    cf tasks api
    ```
* Open a terminal to tail the logs:

    ```
    cf logs api | grep "Refreshing"
    ```
* View logs using kibana

### Managing Elasticsearch
Reference Wiki [Elasticsearch 7.x.0 management instruction](https://github.com/fecgov/openFEC/wiki/Elasticsearch-7.x.0-management-instruction)

There are some management commands to manage (display, create, delete, restore...) repository, index and snapshot on Elasticsearch.
More information is available by invoking each of these commands with a `--help` option. These commands can be run as [cf tasks](https://docs.cloudfoundry.org/devguide/using-tasks.html) on `cloud.gov`, e.g.,
#### Display, Configure and Delete a repository
```
cf run-task api --command "python cli.py display_repositories" -m 2G --name display_repositories
```
```
cf run-task api --command "python cli.py configure_snapshot_repository <repo_name>" -m 4G --name configure_snapshot_repository
```
```
cf run-task api --command "python cli.py delete_repository <repo_name>" -m 4G --name delete_repository
```
#### Display, Create and Delete an index
We have three indexes for FEC legal documents, that are defined in INDEX_DICT
    1) CASE_INDEX includes DOCUMENT_TYPE=('statutes','regulations','murs','adrs','admin_fines')
    current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only

```
cf run-task api --command "python cli.py display_index_alias" -m 2G --name display_index_alias
```
```
cf run-task api --command "python cli.py create_index <index_name>" -m 2G --name create_index
```
```
cf run-task api --command "python cli.py delete_index <index_name>" -m 2G --name delete_index
```
```
cf run-task api --command "python cli.py display_mapping <index_name>" -m 2G --name display_mapping
```
#### When mapping change, update mapping and reload legal data with short downtime(<5 mins) by an index
```
cf run-task api --command "python cli.py update_mapping_and_reload_legal_data <index_name>" -m 4G --name update_mapping_and_reload_legal_data
```
This command is typically used when there is a schema change. A swapping index (XXXX_SWAP_INDEX) is built and populated in the background. When ready, the swapping index is moved to the current index (XXXX_INDEX) with short downtime)<5 mins>.

#### Initialize the legal documents with downtime (15mins ~ 2+ hours)by an index
```
cf run-task api --command "python cli.py initialize_legal_data <index_name>" -m 4G --name initialize_legal_data
```
This command is used to initialize the legal data with downtime (15mins ~ 2+ hours) by an index.

### Reload all legal data by specify 'index_name'(15mins ~ 2+ hours) without downtime.
```
cf run-task api --command "python cli.py reload_all_data_by_index ao_index" -m 4G --name reload_all_data_by_index_ao
```

### Upload individual legal documents
The progress of these tasks can be monitored using, e.g.,
```
cf logs api | grep <some key word>
```
#### Loading advisory opinions [beginning with FROM_AO_NO through newest AO]
```
cf run-task api --command "python cli.py load_advisory_opinions [FROM_AO_NO]" -m 4G --name load_advisory_opinions
```
#### Loading current MURs (type=murs and mur_type=current) [only one MUR_NO]
```
cf run-task api --command "python cli.py load_current_murs [MUR_NO]" -m 4G --name load_current_murs
```
#### Loading ADRs [only one ADR_NO]
```
cf run-task api --command "python cli.py load_adrs [ADR_NO]"  -m 4G --name load_adrs
```
#### Loading Admin Fines [only one AF_NO]
```
cf run-task api --command "python cli.py load_admin_fines [AF_NO]" --name load_admin_fines
```
#### Loading regulations
```
cf run-task api --command "python cli.py load_regulations" --name load_regulations
```
This command requires that the environment variable `FEC_EREGS_API` is set to the API endpoint of a valid `eregs` instance.
#### Loading statutes
```
cf run-task api --command "python cli.py load_statutes" --name load_statutes
```
#### Loading archived murs(type=murs and mur_type=archived)
(load one arch_mur):
```
cf run-task api --command "python cli.py load_archived_murs [MUR_NO]" --name upload_one_arch_mur
```
(load all arch_mur):
```
cf run-task api --command "python cli.py load_archived_murs" --name upload_arch_mur
```
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

You can optionally choose to restrict traffic that goes to the mirrors/replicas to be the asynchronous tasks only by setting the `SQLA_RESTRICT_FOLLOWER_TRAFFIC_TO_TASKS` environment variable to something that will evaluate to `True` in Python (simply using `True` as the value is fine).  If you do this, you can also restrict which tasks are supported on the mirrors/replicas.  Supported tasks are configured by adding their fully qualified names to the `app.config['SQLALCHEMY_FOLLOWER_TASKS']` list in order to allow them.  By default, only the `download` task is enabled.

### Database migration
`flyway` is the tool used for database migration.

#### Installing `flyway`
`flyway` is a Java application and requires a Java runtime environment (JRE) for execution.

It is recommended that you install the JRE separately using your package manager of choice, e.g., `Homebrew`, `apt`, etc, and download the version without the JRE e.g. `flyway-commandline-9.10.1.tar.gz` from [Flyway downloads](https://flywaydb.org/getstarted/download). This way, you have complete control over your Java version and can use the JRE for other applications like `Elasticsearch`. If you have trouble with a separate JRE or if not comfortable with managing a separate JRE, you can download the `flyway` archive that bundles the JRE based on the platform, e.g., `flyway-commandline-9.10.1-macosx-x64.tar.gz`, `flyway-commandline-9.10.1-linux-x64.tar.gz`, etc.

Expand the downloaded archive. Add `<target_directory>/flyway/flyway-9.10.1` to your `PATH` where `target_directory` is the directory in which the archive has been expanded.

#### How `flyway` works
All database schema modification code is checked into version control in the directory `data/migrations` in the form of SQL files that follow a strict naming convention - `V<version_number>__<descriptive_name>.sql`. `flyway` also maintains a table in the target database called `flyway_schema_history` which tracks the migration versions that have already been applied.

`flyway` supports the following commands:
- `info` compares the migration SQL files and the table `flyway_schema_history` and reports on migrations that have been applied and those that are pending.
- `migrate` compares the migration SQL files and the table `flyway_schema_history` and runs those migrations that are pending.
- `baseline` modifies the `flyway_schema_history` table to indicate that the database has already been migrated to a baseline version.
- `repair` repairs the `flyway_schema_history` table. Removes any failed migrations on databases.

For more information, see [Flyway documentation](https://flywaydb.org/documentation/).

#### Running tests
Tests that require the database will automatically run `flyway` migrations as long as `flyway` is in `PATH`.

#### Deployment from CircleCI
flyway is installed in `CircleCI`. During the deployment step, `CircleCI` invokes `flyway` to migrate the target database (depending on the target space). For this to work correctly, connection URLs for the target databases have to be stored as environment variables in CircleCI under the names `FEC_MIGRATOR_SQLA_CONN_DEV`, `FEC_MIGRATOR_SQLA_CONN_STAGE` and `FEC_MIGRATOR_SQLA_CONN_PROD`. The connection URL has to strictly adhere to the structure `postgresql://<username>:<password>@<hostname>:<port>/<database_name>`. Note that the database_name should be specified explicitly, unlike URLs for SQLAlchemy connections.

#### Running `flyway` manually
You may need to run `flyway` manually in order to test migrations locally, or to troubleshoot migrations in production. There are 2 required parameters:
- `-url` specifies the database URL. This is a JDBC URL of the form `jdbc:postgresql://<hostname>:<port>/<database>?user=<username>&password=<password>`.
- `-locations` specifies the directory where the migrations are stored. This is a value of the form `filesystem:<directory-path>`. In our case, if run from the project root, it would be `-locations=filesystem:data/migration`.
