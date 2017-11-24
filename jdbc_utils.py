import re
def to_jdbc_url(dbi_url):
    DB_URL_REGEX = re.compile(r'postgresql://(?P<username>[^:]*):?(?P<password>\S*)@(?P<host_port>\S*)$')
    match = DB_URL_REGEX.match(dbi_url)
    if match:
        jdbc_url = 'jdbc:postgresql://{}?user={}'.format(
            match.group('host_port'), match.group('username'))
        if match.group('password'):
            jdbc_url += '&password={}'.format(match.group('password'))
        return jdbc_url
