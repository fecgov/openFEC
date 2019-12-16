import manage
from tests.common import get_test_jdbc_url
from webservices import rest

import pytest
import subprocess

# Browser testing
import json
import selenium.webdriver

@pytest.fixture(scope="session")
def migrate_db(request):
    reset_schema()
    run_migrations()
    manage.refresh_materialized(concurrent=False)

def run_migrations():
    subprocess.check_call(
        ['flyway', 'migrate', '-n', '-url={0}'.format(get_test_jdbc_url()), '-locations=filesystem:data/migrations'],)

def reset_schema():
    for schema in [
        "aouser",
        "auditsearch",
        "disclosure",
        "fecapp",
        "fecmur",
        "public",
        "rad_pri_user",
        "real_efile",
        "real_pfile",
        "rohan",
        "staging",
    ]:
        rest.db.engine.execute('drop schema if exists %s cascade;' % schema)
    rest.db.engine.execute('create schema public;')

@pytest.fixture
def browserConfig(scope='session'):

    config = json.loads('{"browser": "Firefox", "implicit_wait": 10}')
  
    # Assert values are acceptable
    assert config['browser'] in ['Firefox', 'Chrome', 'Headless Chrome']
    assert isinstance(config['implicit_wait'], int)
    assert config['implicit_wait'] > 0

    # Return config so it can be used as browserConfig
    return config

@pytest.fixture()
def browser(browserConfig):

    # Initialize the WebDriver instance
    if browserConfig['browser'] == 'Firefox':
        b = selenium.webdriver.Firefox()
    elif browserConfig['browser'] == 'Chrome':
        b = selenium.webdriver.Chrome()
    elif browserConfig['browser'] == 'Headless Chrome':
        opts = selenium.webdriver.ChromeOptions()
        opts.add_argument('headless')
        b = selenium.webdriver.Chrome(options=opts)
    else:
        raise Exception(f'Browser "{browserConfig["browser"]}" is not supported')

    # Make its calls wait for elements to appear
    b.implicitly_wait(browserConfig['implicit_wait'])

    # Return the WebDriver instance for the setup
    yield b

    # Quit the WebDriver instance for the cleanup
    b.quit()
