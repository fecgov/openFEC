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
    """
    For PostgreSQL login errors, strip out everything except error code and description.
    This prevents usernames from being printed.
    For other Flyway-specific errors, go ahead leave them intact.
    """
    login_related_error_codes = {
        '08000': 'connection_exception',
        '08001': 'sqlclient_unable_to_establish_sqlconnection',
        '08003': 'connection_does_not_exist',
        '08004': 'sqlserver_rejected_establishment_of_sqlconnection',
        '08006': 'connection_failure',
        '08007': 'transaction_resolution_unknown',
        '08P01': 'protocol_violation',
        '28000': 'invalid_authorization_specificiation',
        '28P01': 'invalid_password',
        '3D000': 'invalid_catalog_name',
        '42000': 'syntax_error_or_access_rule_violation',
        '42501': 'insufficient_privilege',
        '42601': 'syntax_error'
    }
    match = re.search(r'.*(SQL State  : )+(?P<error>[a-zA-Z0-9]{0,5})', error)
    if match:
        error_code = match.group('error')
        return 'PostgreSQL error code {}: {}'.format(
            error_code, login_related_error_codes.get(error_code, error))
    else:
        return error
