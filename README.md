**Develop**
[![Build Status](https://img.shields.io/travis/18F/openFEC/develop.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/develop.svg)](https://codecov.io/github/18F/openFEC)

**Master**
[![Build Status](https://img.shields.io/travis/18F/openFEC/master.svg)](https://travis-ci.org/18F/openFEC)
[![Test Coverage](https://img.shields.io/codecov/c/github/18F/openFEC/master.svg)](https://codecov.io/github/18F/openFEC)
[![Code Climate](https://img.shields.io/codeclimate/github/18F/openFEC.svg)](https://codeclimate.com/github/18F/openFEC)
[![Dependencies](https://img.shields.io/gemnasium/18F/openFEC.svg)](https://gemnasium.com/18F/openFEC)
[![Code Issues](https://www.quantifiedcode.com/api/v1/project/d3b2c96b3781466081d418fd50762726/badge.svg)](https://www.quantifiedcode.com/app/project/d3b2c96b3781466081d418fd50set o762726)

![](http://online.swagger.io/validator?url=https://api.open.fec.gov/swagger)

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

Use pip to install the Python dependencies:

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

*Note: FEC and 18F members can set the SQL connection to one of the RDS boxes with:*

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

2. Run:

   ```
   export FEC_WEB_STYLE_URL=http://localhost:8080/css/styles.css
   export FEC_WEB_API_URL=http://localhost:5000
   export FEC_CMS_URL=http://localhost:8000
   ```

   These are the default URLs to the other local FEC applications. For complete set-up instructions, explore our documentation for [fec-style](https://github.com/18F/fec-style/blob/master/README.md), [openFEC-webb-app](https://github.com/18F/openFEC-web-app/blob/develop/README.md), and [fec-cms](https://github.com/18F/fec-cms/blob/develop/README.rst).
   
   *Note: If you modify your local environment to run these applications at a different address, be sure to update these environment variables to match.* 

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

2. View your local version of the site at [http://localhost:5000](http://localhost:5000).

#### Task queue
We use [Celery](http://www.celeryproject.org/) to schedule periodic tasks— for example, refreshing materialized views and updating incremental aggregates. We use [Redis](http://redis.io/) as the Celery message broker. 

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
This repo uses [pytest](http://pytest.org/latest/).

Running the tests:

```
py.test
```

#### The test data subset
If you add new tables to the data, you'll need to generate a new subset for testing. We use this nifty subsetting tool: [rdbms-subsetter](https://github.com/18F/rdbms-subsetter).

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
On Cloud Foundry, we use the redis28-swarm
service. The Redis service can be created as follows:

```
cf create-service redis28-swarm standard fec-redis
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
* SENTRY_DSN
* SENTRY_PUBLIC_DSN
* NEW_RELIC_LICENSE_KEY

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
* Developer creates a feature branch:

    ```
    git flow feature start my-feature
    ```

* Reviewer merges feature branch into develop and pushes to origin
* [auto] Develop is deployed to dev

### Creating a hotfix
* Developer creates a hotfix branch:

    ```
    git flow hotfix start my-hotfix
    ```

* Reviewer merges hotfix branch into develop and master and pushes to origin
* [auto] Develop is deployed to dev
* [auto] Master is deployed to prod

### Creating a release
* Developer creates a release branch and pushes to origin:

    ```
    git flow release start my-release
    git flow release publish my-release
    ```

* [auto] Release is deployed to stage
* Review of staging
* Developer merges release branch into master and pushes to origin:

    ```
    git flow release finish my-release
    ```

* [auto] Master is deployed to prod


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

### Production stack
The OpenFEC API is a Flask application deployed using the gunicorn WSGI server behind
an nginx reverse proxy. Static files are compressed and served directly through nginx;
dynamic content is routed to the Flask application via `proxy_pass`. The entire application
is served through the [API Umbrella](https://apiumbrella.io), which handles API keys,
caching, and rate limiting.

### Sorting fields
Sorting fields include a compound index on on the filed to sort and a unique field. Because in cases where there were large amounts of data that had the same value that was being evaluated for sort, the was not a stable sort view for results and the results users received were inconsistent, some records given more than once, others given multiple times.
