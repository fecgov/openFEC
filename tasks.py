import git
from invoke import run
from invoke import task


DEFAULT_FRACTION = 0.015
FULL_TABLES = [
    'dimdates',
    'dimparty',
    'dimyears',
    'dimoffice',
    'dimreporttype',
]
EXCLUDE_TABLES = [
    '*_mv',
    '*_tmp',
    '*_old',
    'sched_a',
    'sched_b',
    'ofec_two_year_periods',
]
# Include Nancy Pelosi and John Boehner for debugging purposes
FORCE_INCLUDE = [
    ('dimcand', 10024584),
    ('dimcand', 10034937),
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
def fetch_subset(source, dest, fraction=DEFAULT_FRACTION):
    cmd = 'rdbms-subsetter {source} {dest} {fraction}'.format(**locals())
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


def _detect_space(branch=None, yes=False):
    """Detect space from active git branch.

    :param str branch: Optional branch name override
    :param bool yes: Skip confirmation
    :returns: Space name if space is detected and confirmed, else `None`
    """
    repo = git.Repo('.')
    # Fail gracefully if `branch` is not provided and repo is in detached
    # `HEAD` mode
    try:
        branch = branch or repo.active_branch.name
    except TypeError:
        return None
    space = _resolve_rule(repo, branch)
    if space is None:
        print(
            'No space detected from repo {repo}; '
            'skipping deploy'.format(**locals())
        )
        return None
    print('Detected space {space} from repo {repo}'.format(**locals()))
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
    'dev': [('cf.18f.us', 'fec-dev-api')],
    'stage': [('cf.18f.us', 'fec-stage-api')],
    'prod': [('cf.18f.us', 'fec-prod-api')],
}


@task
def deploy(space=None, branch=None, yes=False):
    """Deploy app to Cloud Foundry. Log in using credentials stored in
    `FEC_CF_USERNAME` and `FEC_CF_PASSWORD`; push to either `space` or the space
    detected from the name and tags of the current branch. Note: Must pass `space`
    or `branch` if repo is in detached HEAD mode, e.g. when running on Travis.
    """
    # Detect space
    space = space or _detect_space(branch, yes)
    if space is None:
        return

    # Log in
    args = (
        ('--a', 'https://api.18f.gov'),
        ('--u', '$FEC_CF_USERNAME'),
        ('--p', '$FEC_CF_PASSWORD'),
        ('--o', 'fec'),
        ('--s', space),
    )
    run('cf login {0}'.format(' '.join(' '.join(arg) for arg in args)), echo=True)

    old, new = _detect_apps('api-a', 'api-b')

    # Push
    push = run('cf push {0} -f manifest_{1}.yml'.format(new, space), echo=True, warn=True)
    if push.failed:
        print('Error pushing app {0}'.format(new))
        run('cf stop {0}'.format(new), echo=True)
        return

    # Remap
    for route, host in SPACE_URLS[space]:
        opts = route
        if host:
            opts += ' -n {0}'.format(host)
        run('cf map-route {0} {1}'.format(new, opts), echo=True)
        run('cf unmap-route {0} {1}'.format(old, opts), echo=True, warn=True)

    run('cf stop {0}'.format(old), echo=True, warn=True)
