import json
import os
import subprocess
import git
import sys

from invoke import task, exceptions
from jdbc_utils import get_jdbc_credentials, to_jdbc_url, remove_credentials


DEFAULT_FRACTION = 0.5
FULL_TABLES = [
    'cand_inactive',
]
EXCLUDE_TABLES = [
    '*_mv',
    '*_tmp',
    '*_old',
    'sched_b2',
    'sched_e2',
    'pacronyms',
    'ofec_*',
    'dimcandproperties',
    'f_rpt_or_form_sub',
]

# Include records used in integration tests
FORCE_INCLUDE = [
    ('dimcand', 10025229),  # Nancy Pelosi
    ('dimcand', 10012694),  # John Boehner
    ('dimcmte', 10031117),  # Raul Grijalva (committee)
]


@task
def fetch_schemas(ctx, source, dest):
    cmd = 'pg_dump {0} --format c --schema-only --no-acl --no-owner'.format(source)
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    ctx.run(cmd, echo=True)


@task
def fetch_full(ctx, source, dest):
    cmd = 'pg_dump {0} --format c --no-acl --no-owner'.format(source)
    for table in FULL_TABLES:
        cmd += ' --table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    ctx.run(cmd, echo=True)


@task
def fetch_subset(ctx, source, dest, fraction=DEFAULT_FRACTION, log=True):
    cmd = 'rdbms-subsetter {source} {dest} {fraction}'.format(**locals())
    if log:
        cmd += ' --logarithmic'
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    for table, key in FORCE_INCLUDE:
        cmd += ' --force {0}:{1}'.format(table, key)
    cmd += ' --config data/subset-config.json'
    cmd += ' --yes'
    ctx.run(cmd, echo=True)


@task
def build_test(ctx, source, dest, fraction=DEFAULT_FRACTION, log=True):
    fetch_full(ctx, source, dest)
    fetch_schemas(ctx, source, dest)
    fetch_subset(ctx, source, dest, fraction=fraction, log=log)


@task
def dump(ctx, source, dest):
    cmd = 'pg_dump {source} --format c --no-acl --no-owner -f {dest}'.format(**locals())
    for table in EXCLUDE_TABLES:
        cmd += ' --exclude-table {0}'.format(table)
    ctx.run(cmd, echo=True)


@task
def add_hooks(ctx):

    ctx.run('ln -s ../../bin/post-merge .git/hooks/post-merge')
    ctx.run('ln -s ../../bin/post-checkout .git/hooks/post-checkout')


@task
def remove_hooks(ctx):
    ctx.run('rm .git/hooks/post-merge')
    ctx.run('rm .git/hooks/post-checkout')


def _detect_prod(repo, branch):
    """Deploy to production if master is checked out and tagged."""
    if branch != 'master':
        return False
    try:
        # Equivalent to `git describe --tags --exact-match`
        repo.git().describe('--tags', '--exact-match')
        return True
    except git.exc.GitCommandError:
        return False


def _resolve_rule(repo, branch):
    """Get space associated with first matching rule."""
    for space, rule in DEPLOY_RULES:
        if rule(repo, branch):
            return space
    return None


def _detect_branch(repo):
    try:
        return repo.active_branch.name
    except TypeError:
        return None


def _detect_space(repo, branch=None, yes=False):
    """Detect space from active git branch.

    :param str branch: Optional branch name override
    :param bool yes: Skip confirmation
    :returns: Space name if space is detected and confirmed, else `None`
    """
    space = _resolve_rule(repo, branch)
    if space is None:
        print('No space detected')
        return None
    print('Detected space {space}'.format(**locals()))
    if not yes:
        run = input(
            'Deploy to space {space} (enter "yes" to deploy)? > '.format(**locals())
        )
        if run.lower() not in ['y', 'yes']:
            return None
    return space


DEPLOY_RULES = (
    ('prod', _detect_prod),
    ('stage', lambda _, branch: branch.startswith('release')),
    ('dev', lambda _, branch: branch == 'develop'),
)


SPACE_URLS = {
    'dev': [('app.cloud.gov', 'fec-dev-api')],
    'stage': [('app.cloud.gov', 'fec-stage-api')],
    'prod': [('app.cloud.gov', 'fec-prod-api')],
}


@task
def deploy(ctx, space=None, branch=None, login=None, yes=False, migrate_database=False):
    """Deploy app to Cloud Foundry. Log in using credentials stored per environment
    like `FEC_CF_USERNAME_DEV` and `FEC_CF_PASSWORD_DEV`; push to either `space` or t
    he space detected from the name and tags of the current branch. Note: Must pass `space`
    or `branch` if repo is in detached HEAD mode, e.g. when running on Circle.
    To run migrations, pass the flag `--migrate-database`.
    """
    # Detect space
    repo = git.Repo('.')
    branch = branch or _detect_branch(repo)
    space = space or _detect_space(repo, branch, yes)
    if space is None:
        return

    if login == 'True':
        # Set api
        api = 'https://api.fr.cloud.gov'
        ctx.run('cf api {0}'.format(api), echo=True)
        # Authenticate
        login_command = 'cf auth "$FEC_CF_USERNAME_{0}" "$FEC_CF_PASSWORD_{0}"'.format(
            space.upper()
        )
        ctx.run(login_command, echo=True)

    # Target space
    ctx.run('cf target -o fec-beta-fec -s {0}'.format(space), echo=True)

    if not migrate_database:
        print("\nSkipping migrations. Database not migrated.\n")
    else:
        migration_env_var = 'FEC_MIGRATOR_SQLA_CONN_{0}'.format(space.upper())
        migration_conn = os.getenv(migration_env_var, '')
        jdbc_url, migration_user, migration_password = get_jdbc_credentials(
            migration_conn
        )

        if not all((jdbc_url, migration_user, migration_password)):
            print(
                "\nUnable to retrieve or parse {0}. "
                "Make sure the environmental variable is set and properly "
                "formatted.\n".format(
                    migration_env_var
                )
            )
            raise exceptions.Exit(1)

        print("\nMigrating database...")

        result = run_migrations(ctx, jdbc_url, migration_user, migration_password)
        if result.failed:
            print("Migration failed!")
            print(remove_credentials(result.stderr))
            raise exceptions.Exit(1)

        print("Database migrated.\n")

    # Set deploy variables
    with open('.cfmeta', 'w') as fp:
        json.dump({'user': os.getenv('USER'), 'branch': branch}, fp)

    # Deploy API and worker applications
    for app in ('api', 'celery-worker', 'celery-beat'):
        existing_deploy = ctx.run('cf app {0}'.format(app), echo=True, warn=True)
        print("\n")
        cmd = 'push --strategy rolling' if existing_deploy.ok else 'push'
        new_deploy = ctx.run('cf {cmd} {app} -f manifests/manifest_{file}_{space}.yml'.format(
            cmd=cmd,
            app=app,
            file=app.replace('-', '_'),
            space=space
        ), echo=True, warn=True)

        if not new_deploy.ok:
            print("Build failed!")
            # Check if there are active deployments
            app_guid = ctx.run('cf app {} --guid'.format(app), hide=True, warn=True)
            app_guid_formatted = app_guid.stdout.strip()
            status = ctx.run('cf curl "/v3/deployments?app_guids={}&status_values=ACTIVE"'.format(
                app_guid_formatted), hide=True, warn=True)
            active_deployments = json.loads(status.stdout).get("pagination").get("total_results")
            # Try to roll back
            if active_deployments > 0:
                print("Attempting to roll back any deployment in progress...")
                # Show the in-between state
                ctx.run('cf app {}'.format(app), echo=True, warn=True)
                cancel_deploy = ctx.run('cf cancel-deployment {}'.format(app), echo=True, warn=True)
                if cancel_deploy.ok:
                    print("Successfully cancelled deploy. Check logs.")
                else:
                    print("Unable to cancel deploy. Check logs.")

            return sys.exit(1)

        print("\nA new version of your application '{}' has been successfully pushed!".format(app))
        ctx.run('cf apps', echo=True, warn=True)

    # Needed for CircleCI
    return sys.exit(0)


@task
def create_sample_db(ctx):
    """
    Load schema and data into the empty database pointed to by $SQLA_SAMPLE_DB_CONN
    """

    print("Loading schema...")
    db_conn = os.getenv('SQLA_SAMPLE_DB_CONN')
    if not db_conn:
        print("Error: SQLA_SAMPLE_DB_CONN env var must be set")
        return
    jdbc_url = to_jdbc_url(db_conn)
    result = run_migrations(ctx, jdbc_url)
    if result.failed:
        print("Migration failed!")
        print(result)
        return
    print("Schema loaded")

    print("Loading sample data...")
    subprocess.check_call(
        ['psql', '-v', 'ON_ERROR_STOP=1', '-f', 'data/sample_db.sql', db_conn]
    )
    print("Sample data loaded")

    print("Refreshing materialized views...")
    os.environ["SQLA_CONN"] = db_conn  # SQLA_CONN is used by manage.py tasks
    subprocess.check_call(['python', 'cli.py', 'refresh_materialized'])
    print("Materialized views refreshed")


@task
def run_migrations(ctx, jdbc_url, migration_user=None, migration_password=None):
    command = 'flyway migrate -q -url="{0}" -locations=filesystem:data/migrations'.format(
        jdbc_url
    )
    if migration_user:
        command += ' -user="{}"'.format(migration_user)
    if migration_password:
        command += ' -password="{}"'.format(migration_password)
    response = ctx.run(
        command,
        hide=True,  # Hides error output which can contain credentials
        warn=True,  # Continues upon error; Doesn't display error
    )
    return response
