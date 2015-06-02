import logging
import functools

from smore import swagger
from flask.ext.restful import abort

import webargs
from webargs import Arg
from webargs.core import text_type
from webargs.flaskparser import FlaskParser


logger = logging.getLogger(__name__)


class FlaskRestParser(FlaskParser):

    def handle_error(self, error):
        logger.error(error)
        status_code = getattr(error, 'status_code', 400)
        data = getattr(error, 'data', {})
        abort(status_code, message=text_type(error), **data)


parser = FlaskRestParser()


def register_kwargs(arg_dict):
    def wrapper(func):
        params = swagger.args2parameters(arg_dict, default_in='query')
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.setdefault('parameters', []).extend(params)
        return parser.use_kwargs(arg_dict)(func)
    return wrapper


def _validate_natural(value):
    if value < 0:
        raise webargs.ValidationError('Must be a natural number')
Natural = functools.partial(Arg, int, validate=_validate_natural)


paging = {
    'page': Natural(default=1, description='For paginating through results, starting at page 1'),
    'per_page': Natural(default=20, description='The number of results returned per page. Defaults to 20.'),
}


def make_sort_args(default=None):
    return {
        'sort': Arg(str, multiple=True, default=default),
    }


def one_of(value, options):
    if value not in options:
        raise webargs.ValidationError('Value "{0}" not in "{1}"'.format(value, options))


names = {
    'q': Arg(str, required=True, description='Name (candidate or committee) to search for'),
    'type': Arg(
        str,
        use=lambda v: v.lower(),
        validate=functools.partial(one_of, options=['candidate', 'committee']),
        description='Resource type to search for. May be "candidate" or "committee"; if '
        'not specified, search both resources.',
    ),
}


candidate_detail = {
    'cycle': Arg(int, multiple=True, description='Filter records to only those that were applicable to a given election cycle'),
    'office': Arg(str, multiple=True, description='Governmental office candidate runs for'),
    'state': Arg(str, multiple=True, description='U.S. State candidate is registered in'),
    'party': Arg(str, multiple=True, description='Three letter code for the party under which a candidate ran for office'),
    'year': Arg(str, dest='election_year', description='See records pertaining to a particular year.'),
    'district': Arg(str, multiple=True, description='Two digit district number'),
    'candidate_status': Arg(str, multiple=True, description='One letter code explaining if the candidate is a present, future or past candidate'),
    'incumbent_challenge': Arg(str, multiple=True, description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'),
}

candidate_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'candidate_id': Arg(str, multiple=True, description="Candidate's FEC ID"),
    'fec_id': Arg(str, description="Candidate's FEC ID"),
    'name': Arg(str, description="Candidate's name (full or partial)"),
}

committee = {
    'year': Arg(int, multiple=True, description='A year that the committee was active- (after original registration date but before expiration date.)'),
    'cycle': Arg(int, multiple=True, description='An election cycle that the committee was active- (after original registration date but before expiration date.)'),
    'designation': Arg(str, multiple=True, description='The one-letter designation code of the organization'),
    'organization_type': Arg(str, multiple=True, description='The one-letter code for the kind for organization'),
    'committee_type': Arg(str, multiple=True, description='The one-letter type code of the organization'),
}

committee_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'committee_id': Arg(str, multiple=True, description="Committee's FEC ID"),
    'candidate_id': Arg(str, multiple=True, description="Candidate's FEC ID"),
    'state': Arg(str, multiple=True, description='Two digit U.S. State committee is registered in'),
    'name': Arg(str, description="Committee's name (full or partial)"),
    'party': Arg(str, multiple=True, description='Three letter code for party'),
}


reports = {
    'year': Arg(int, multiple=True, description='Year in which a candidate runs for office'),
    'cycle': Arg(int, multiple=True, description='Two-year election cycle in which a candidate runs for office'),
    'report_type': Arg(str, multiple=True, description='Report type; prefix with "-" to exclude'),
}


totals = {
    'cycle': Arg(int, multiple=True, description='Two-year election cycle in which a candidate runs for office'),
}
