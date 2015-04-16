import functools

import webargs
from smore import swagger

from webargs import Arg
from webargs.flaskparser import use_kwargs


def register_kwargs(arg_dict):
    def wrapper(func):
        params = swagger.args2parameters(arg_dict, default_in='query')
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.setdefault('parameters', []).extend(params)
        return use_kwargs(arg_dict)(func)
    return wrapper


def _validate_natural(value):
    if value < 0:
        raise webargs.ValidationError('Must be a natural number')
Natural = functools.partial(Arg, int, validate=_validate_natural)

paging = {
    'page': Natural(default=1, description='For paginating through results, starting at page 1'),
    'per_page': Natural(default=20, description='The number of results returned per page. Defaults to 20.'),
}


names = {
    'q': Arg(str, required=True, description='Name (candidate or committee) to search for'),
}


candidate_detail = {
    'office': Arg(str, description='Governmental office candidate runs for'),
    'state': Arg(str, description='U.S. State candidate is registered in'),
    'party': Arg(str, description='Three letter code for the party under which a candidate ran for office'),
    'year': Arg(str, dest='election_year', description='See records pertaining to a particular year.'),
    'district': Arg(str, description='Two digit district number'),
    'candidate_status': Arg(str, description='One letter code explaining if the candidate is a present, future or past candidate'),
    'incumbent_challenge': Arg(str, description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'),
}

candidate_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'candidate_id': Arg(str, description="Candidate's FEC ID"),
    'fec_id': Arg(str, description="Candidate's FEC ID"),
    'name': Arg(str, description="Candidate's name (full or partial)"),
}

committee = {
    'year': Arg(str, default=None, description='A year that the committee was active- (after original registration date but before expiration date.)'),
    'designation': Arg(str, description='The one-letter designation code of the organization'),
    'organization_type': Arg(str, description='The one-letter code for the kind for organization'),
    'committee_type': Arg(str, description='The one-letter type code of the organization'),
}

committee_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'committee_id': Arg(str, description="Committee's FEC ID"),
    'candidate_id': Arg(str, description="Candidate's FEC ID"),
    'state': Arg(str, description='Two digit U.S. State committee is registered in'),
    'name': Arg(str, description="Committee's name (full or partial)"),
    'party': Arg(str, description='Three letter code for party'),
}


reports = {
    'year': Arg(str, default='*', dest='cycle', description='Year in which a candidate runs for office'),
    'fields': Arg(str, description='Choose the fields that are displayed'),
}


totals = {
    'year': Arg(str, default='*', dest='cycle', description='Year in which a candidate runs for office'),
    'fields': Arg(str, description='Choose the fields that are displayed'),
}
