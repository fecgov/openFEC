import re

def get_jdbc_credentials(dbi_url):
    """Extract username and password from connection string"""
    DB_URL_REGEX = re.compile(r'postgresql://(?P<username>[^:]*):?(?P<password>\S*)@(?P<host_port>\S*)$')
    match = DB_URL_REGEX.match(dbi_url)
    if match:
        jdbc_url = 'jdbc:postgresql://{}'.format(
            match.group('host_port'))
        username = match.group('username')
        password = match.group('password')
        return jdbc_url, username, password
    return None, None, None

def to_jdbc_url(dbi_url):
    """Reformat PostgreSQL uri to JDBC uri"""
    jdbc_url, username, password = get_jdbc_credentials(dbi_url)
    if jdbc_url:
        jdbc_url = '{}?user={}'.format(jdbc_url, username)
        if password:
            jdbc_url += '&password={}'.format(password)
        return jdbc_url
    return None


def remove_credentials(error):
    """Remove credentials from PostgreSQL erorrs, preserve the error codes."""
    code_lookup = {
        '08001': 'Connection attempt failed',
        '28P01': 'Password authentication failed',
    }
    message = "PostgreSQL error"
    match = re.search(r'.*(SQL State  : )+(?P<error>[a-zA-Z0-9]{0,5})', error)
    if match:
        error_code = match.group('error')
        message += ' {}: {}'.format(error_code, code_lookup.get(error_code, "Unrecognized code. See PostgreSQL docs."))
    return message
