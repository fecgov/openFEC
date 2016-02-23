import os

import git
from invoke import run
from invoke import task
from slacker import Slacker

from webservices.env import env


DEFAULT_FRACTION = 0.5
FULL_TABLES = [
    'dimdates',
    'dimparty',
    'dimreporttype',
    'cand_inactive',
]
EXCLUDE_TABLES = [
    '*_tmp',
    '*_old',
    'sched_b2',
    'sched_e2',
    'pacronyms',
    'ofec_*',
    'dimcandproperties',
    'f_rpt_or_form_sub',
    'f_item_receipt_or_exp',
]
# Include records used in integration tests
FORCE_INCLUDE = [
    ('dimcand', 10025229),  # Nancy Pelosi
    ('dimcand', 10012694),  # John Boehner
    ('dimcmte', 10031117),  # Raul Grijalva (committee)
]


@task
def fetch_schemas(source, dest):
    cmd = 'pg_dump {0} --format c --schema-only --no-acl --no-owner'.format(source)
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    run(cmd, echo=True)


@task
def fetch_full(source, dest):
    cmd = 'pg_dump {0} --format c --no-acl --no-owner'.format(source)
    for table in FULL_TABLES:
        cmd += ' --table {0}'.format(table)
    cmd += ' | pg_restore --dbname {0} --no-acl --no-owner'.format(dest)
    run(cmd, echo=True)


@task
def fetch_subset(source, dest, fraction=DEFAULT_FRACTION, log=True):
    cmd = 'rdbms-subsetter {source} {dest} {fraction}'.format(**locals())
    if log:
        cmd += ' --logarithmic'
    for table in (FULL_TABLES + EXCLUDE_TABLES):
        cmd += ' --exclude-table {0}'.format(table)
    for table, key in FORCE_INCLUDE:
        cmd += ' --force {0}:{1}'.format(table, key)
    cmd += ' --config data/subset-config.json'
    cmd += ' --yes'
    run(cmd, echo=True)


@task
def clear_triggers(dest):
    """Clear all triggers in database `dest`.
    """
    cmd = 'psql -f data/functions/strip_triggers.sql {dest}'.format(**locals())
    run(cmd, echo=True)


@task
def build_test(source, dest, fraction=DEFAULT_FRACTION, log=True):
    fetch_full(source, dest)
    fetch_schemas(source, dest)
    clear_triggers(dest)
    fetch_subset(source, dest, fraction=fraction, log=log)


@task
def dump(source, dest):
    cmd = 'pg_dump {source} --format c --no-acl --no-owner -f {dest}'.format(**locals())
    for table in EXCLUDE_TABLES:
        cmd += ' --exclude-table {0}'.format(table)
    run(cmd, echo=True)


@task
def add_hooks():
    run('ln -s ../../bin/post-merge .git/hooks/post-merge')
    run('ln -s ../../bin/post-checkout .git/hooks/post-checkout')


@task
def remove_hooks():
    run('rm .git/hooks/post-merge')
    run('rm .git/hooks/post-checkout')


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


def _detect_apps(blue, green):
    """Detect old and new apps for blue-green deploy."""
    status = run('cf app {0}'.format(blue), echo=True, warn=True)
    if status.ok and 'started' in status.stdout:
        return (blue, green)
    return (green, blue)


SPACE_URLS = {
    'dev': [('18f.gov', 'fec-dev-api')],
    'stage': [('18f.gov', 'fec-stage-api')],
    'prod': [('18f.gov', 'fec-prod-api')],
}


@task
def deploy(space=None, branch=None, yes=False):
    """Deploy app to Cloud Foundry. Log in using credentials stored in
    `FEC_CF_USERNAME` and `FEC_CF_PASSWORD`; push to either `space` or the space
    detected from the name and tags of the current branch. Note: Must pass `space`
    or `branch` if repo is in detached HEAD mode, e.g. when running on Travis.
    """
    # Detect space
    repo = git.Repo('.')
    branch = branch or _detect_branch(repo)
    space = space or _detect_space(repo, branch, yes)
    if space is None:
        return

    # Log in
    args = (
        ('--a', 'https://api.cloud.gov'),
        ('--u', '$FEC_CF_USERNAME'),
        ('--p', '$FEC_CF_PASSWORD'),
        ('--o', 'fec'),
        ('--s', space),
    )
    run('cf login {0}'.format(' '.join(' '.join(arg) for arg in args)), echo=True)

    old, new = _detect_apps('api-a', 'api-b')

    # Set deploy variables
    run('cf set-env {0} DEPLOY_BRANCH "{1}"'.format(new, branch))
    run('cf set-env {0} DEPLOY_USER "{1}"'.format(new, os.getenv('USER')))

    # Push
    push = run('cf push {0} -f manifest_{1}.yml'.format(new, space), echo=True, warn=True)
    if push.failed:
        print('Error pushing app {0}'.format(new))
        run('cf stop {0}'.format(new), echo=True)
        return

    # Unset deploy variables
    run('cf unset-env {0} DEPLOY_BRANCH'.format(new))
    run('cf unset-env {0} DEPLOY_USER'.format(new))

    # Remap
    for route, host in SPACE_URLS[space]:
        opts = route
        if host:
            opts += ' -n {0}'.format(host)
        run('cf map-route {0} {1}'.format(new, opts), echo=True)
        run('cf unmap-route {0} {1}'.format(old, opts), echo=True, warn=True)

    run('cf stop {0}'.format(old), echo=True, warn=True)

    # Deploy worker applications
    run('cf push celery-beat -f manifest_{0}.yml'.format(space))
    run('cf push celery-worker -f manifest_{0}.yml'.format(space))

@task
def notify():
    slack = Slacker(env.get_credential('FEC_SLACK_TOKEN'))
    slack.chat.post_message(
        env.get_credential('FEC_SLACK_CHANNEL', '#fec'),
        'deploying branch {branch} of app {name} to space {space} by {user}'.format(
            name=env.name,
            space=env.space,
            user=os.getenv('DEPLOY_USER'),
            branch=os.getenv('DEPLOY_BRANCH'),
        ),
        username=env.get_credential('FEC_SLACK_BOT', 'fec-bot'),
    )
