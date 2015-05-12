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
def build_test(source, dest, fraction=DEFAULT_FRACTION):
    fetch_full(source, dest)
    fetch_schemas(source, dest)
    fetch_subset(source, dest, fraction=fraction)


@task
def dump(source, dest):
    cmd = 'pg_dump {source} --no-acl --no-owner -f {dest}'.format(**locals())
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


DEPLOY_RULES = (
    ('develop', 'dev'),
    ('master', 'stage'),
    ('release', 'prod'),

)
def _resolve_rule(branch):
    for pattern, space in DEPLOY_RULES:
        if pattern in branch:
            return space
    return None


@task
def deploy(space=None):
    """Deploy app to Cloud Foundry. Log in using credentials stored in
    `FEC_CF_USERNAME` and `FEC_CF_PASSWORD`; push to either `space` or the space
    detected from the name of the current branch.
    """
    # Optionally detect space
    if not space:
        repo = git.Repo('.')
        branch = repo.active_branch.name
        space = _resolve_rule(branch)
        if space is None:
            print(
                'No space detected from branch {branch}; '
                'skipping deploy'.format(**locals())
            )
            return
        print('Detected space {space} from branch {branch}'.format(**locals()))

    # Select API
    api = 'cf api https://api.18f.gov'
    run(api, echo=True)

    # Log in
    args = (
        ('--u', '$FEC_CF_USERNAME'),
        ('--p', '$FEC_CF_PASSWORD'),
        ('--o', 'fec'),
        ('--s', space),
    )
    login = 'cf login {0}'.format(' '.join(' '.join(arg) for arg in args))
    run(login, echo=True)

    # Push
    push = 'cf push -f manifest_{0}.yml'.format(space)
    run(push, echo=True)
