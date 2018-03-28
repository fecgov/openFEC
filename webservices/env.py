import os

import cfenv


env = cfenv.AppEnv()


if env.get_credential('access_key_id'):
    os.environ['AWS_ACCESS_KEY_ID'] = env.get_credential('access_key_id')
if env.get_credential('secret_access_key'):
    os.environ['AWS_SECRET_ACCESS_KEY'] = env.get_credential('secret_access_key')
if env.get_credential('region'):
    os.environ['AWS_DEFAULT_REGION'] = env.get_credential('region')

__all__ = ['env']
