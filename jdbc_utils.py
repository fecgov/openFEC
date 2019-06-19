import re
def get_jdbc_credentials(dbi_url):
    DB_URL_REGEX = re.compile(r'postgresql://(?P<username>[^:]*):?(?P<password>\S*)@(?P<host_port>\S*)$')
    match = DB_URL_REGEX.match(dbi_url)
    if match:
        jdbc_url = 'jdbc:postgresql://{}'.format(
            match.group('host_port'))
        username = match.group('username')
        password = match.group('password')
        return (jdbc_url, username, password)
    return None


def remove_credentials(error):
    message = "ERROR:"
    if '(' in error:
        message = error.split('(')[0]
    return message
