import re
def to_jdbc_url(dbi_url):
    DB_URL_REGEX = re.compile(r'(?P<host_port>\S*)$')
    match = DB_URL_REGEX.match(dbi_url)
    if match:
        jdbc_url = 'jdbc:postgresql://{}/fec'.format(match.group('host_port'))
        return jdbc_url
    return None
