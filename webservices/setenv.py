"""Parse credentials stored in user-provided services, and print commands to
export to the environment to the console. Invoked directly in `Procfile`.
"""

import os
import json


def main():
    services = json.loads(os.getenv('VCAP_SERVICES', '{}'))
    for ups in services.get('user-provided', []):
        for key, value in ups.get('credentials', {}).items():
            print('export {key}={value};'.format(**locals()))


if __name__ == '__main__':
    main()
