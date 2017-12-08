import os
import json

import git
from invoke import task
# from slacker import Slacker

from webservices.env import env
from jdbc_utils import to_jdbc_url


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
# FORCE_INCLUDE = [
#     ('dimcand', 10025229),  # Nancy Pelosi
#     ('dimcand', 10012694),  # John Boehner
#     ('dimcmte', 10031117),  # Raul Grijalva (committee)
# ]


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
def deploy(ctx, space=None, branch=None, login=None, yes=False):
    """Deploy app to Cloud Foundry. Log in using credentials stored per environment
    like `FEC_CF_USERNAME_DEV` and `FEC_CF_PASSWORD_DEV`; push to either `space` or t
    he space detected from the name and tags of the current branch. Note: Must pass `space`
    or `branch` if repo is in detached HEAD mode, e.g. when running on Travis.
    """
    # Detect space
    repo = git.Repo('.')
    branch = branch or _detect_branch(repo)
    space = space or _detect_space(repo, branch, yes)
    if space is None:
        return

    # Set api
    api = 'https://api.fr.cloud.gov'
    ctx.run('cf api {0}'.format(api), echo=True)

    # Log in if necessary
    if login == 'True':
        login_command = 'cf auth "$FEC_CF_USERNAME_{0}" "$FEC_CF_PASSWORD_{0}"'.format(space.upper())
        ctx.run(login_command, echo=True)

    # Target space
    ctx.run('cf target -o fec-beta-fec -s {0}'.format(space), echo=True)

    run_migrations(ctx, space)

    # Set deploy variables
    with open('.cfmeta', 'w') as fp:
        json.dump({'user': os.getenv('USER'), 'branch': branch}, fp)

    # Deploy API and worker applications
    for app in ('api', 'celery-worker', 'celery-beat'):
        deployed = ctx.run('cf app {0}'.format(app), echo=True, warn=True)
        cmd = 'zero-downtime-push' if deployed.ok else 'push'
        ctx.run('cf {cmd} {app} -f manifests/manifest_{file}_{space}.yml'.format(
            cmd=cmd,
            app=app,
            file=app.replace('-','_'),
            space=space
        ), echo=True)


@task
def notify(ctx):
    try:
        meta = json.load(open('.cfmeta'))
    except OSError:
        meta = {}
    slack = Slacker(env.get_credential('FEC_SLACK_TOKEN'))
    slack.chat.post_message(
        env.get_credential('FEC_SLACK_CHANNEL', '#fec'),
        'deploying branch {branch} of app {name} to space {space} by {user}'.format(
            name=env.name,
            space=env.space,
            user=meta.get('user'),
            branch=meta.get('branch'),
        ),
        username=env.get_credential('FEC_SLACK_BOT', 'fec-bot'),
    )

def run_migrations(ctx, space):
    print("\nMigrating database...")
    jdbc_url = to_jdbc_url(os.getenv('FEC_MIGRATOR_SQLA_CONN_{0}'.format(space.upper())))
    ctx.run('flyway migrate -q -url="{0}" -locations=filesystem:data/migrations'.format(jdbc_url))
    print("Database migrated\n")
