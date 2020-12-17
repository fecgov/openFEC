import os

import cfenv


env = cfenv.AppEnv()

# print("env", env)
# print(dir(env))

# print("env.get_service(name='s3')", env.get_service(name="s3")
# print("env.get_service(label='s3')", env.get_service(label="s3")

# TODO: Move this to individual functions

# if env.get_credential('access_key_id'):
#     os.environ['AWS_ACCESS_KEY_ID'] = env.get_credential('access_key_id')
# if env.get_credential('secret_access_key'):
#     os.environ['AWS_SECRET_ACCESS_KEY'] = env.get_credential('secret_access_key')
# if env.get_credential('region'):
#     os.environ['AWS_DEFAULT_REGION'] = env.get_credential('region')

__all__ = ['env']
