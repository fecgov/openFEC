import logging
import functools

from smore import swagger
from flask.ext.restful import abort
from dateutil.parser import parse as parse_date

import webargs
from webargs import Arg
from webargs.core import text_type
from webargs.flaskparser import FlaskParser

from webservices import docs


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
        'sort': Arg(str, multiple=True, description='Provide a field to sort by. Use - for descending order.', default=default),
    }


def one_of(value, options):
    if value not in options:
        raise webargs.ValidationError('Value "{0}" not in "{1}"'.format(value, options))


names = {
    'q': Arg(str, required=True, description='Name (candidate or committee) to search for'),
}


candidate_detail = {
    'cycle': Arg(int, multiple=True, description='Filter records to only those that were applicable to a given election cycle'),
    'office': Arg(str, multiple=True, enum=['', 'H', 'S', 'P'], description='Governmental office candidate runs for: House, Senate or President.'),
    'state': Arg(str, multiple=True, description='U.S. State candidate or territory where a candidate runs for office.'),
    'party': Arg(str, multiple=True, description='Three letter code for the party under which a candidate ran for office'),
    'year': Arg(str, dest='election_year', description='See records pertaining to a particular year.'),
    'district': Arg(str, multiple=True, description='Two digit district number'),
    'candidate_status': Arg(str, multiple=True, enum=['', 'C', 'F', 'N', 'P'], description='One letter code explaining if the candidate is:\n\
        - C present candidate\n\
        - F future candidate\n\
        - N not yet a candidate\n\
        - P prior candidate\n\
        '),
    'incumbent_challenge': Arg(str, multiple=True, enum=['', 'I', 'C', 'O'], description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'),
}

candidate_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'candidate_id': Arg(str, multiple=True, description=docs.CANDIDATE_ID),
    'name': Arg(str, description="Candidate's name (full or partial)"),
}

committee = {
    'year': Arg(int, multiple=True, description='A year that the committee was active- (after original registration date but before expiration date.)'),
    'cycle': Arg(int, multiple=True, description='A two-year election cycle that the committee was active- (after original registration date but before expiration date.)'),
    'designation': Arg(
        str, multiple=True, enum=['', 'A', 'J', 'P', 'U', 'B', 'D'],
        description='The one-letter designation code of the organization:\n\
         - A authorized by a candidate\n\
         - J joint fundraising committee\n\
         - P principal campaign committee of a candidate\n\
         - U unauthorized\n\
         - B lobbyist/registrant PAC\n\
         - D leadership PAC\n\
        '
    ),
    'organization_type': Arg(str, multiple=True, enum=['', 'C', 'L', 'M', 'T', 'V', 'W'],
        description='The one-letter code for the kind for organization:\n\
        - C corporation\n\
        - L labor organization\n\
        - M membership organization\n\
        - T trade association\n\
        - V cooperative\n\
        - W corporation without capital stock\n\
        '),
    'committee_type': Arg(str, multiple=True, enum=['', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y', 'Z'],
        description='The one-letter type code of the organization:\n\
        - C communication cost\n\
        - D delegate\n\
        - E electioneering communication\n\
        - H House\n\
        - I independent expenditor (person or group)\n\
        - N PAC - nonqualified\n\
        - O independent expenditure-only (super PACs)\n\
        - P presidential\n\
        - Q PAC - qualified\n\
        - S Senate\n\
        - U single candidate independent expenditure\n\
        - V PAC with non-contribution account, nonqualified\n\
        - W PAC with non-contribution account, qualified\n\
        - X party, nonqualified\n\
        - Y party, qualified\n\
        - Z national party nonfederal account\n\
    '),
}

committee_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'committee_id': Arg(str, multiple=True, description=docs.COMMITTEE_ID),
    'candidate_id': Arg(str, multiple=True, description=docs.CANDIDATE_ID),
    'name': Arg(str, description="Candidate's name (full or partial)"),
    'state': Arg(str, multiple=True, description='Two-character U.S. state or territory in which the committee is registered.'),
    'name': Arg(str, description="Committee's name (full or partial)"),
    'party': Arg(str, multiple=True, description='Three-letter code for the party. For example: DEM=Democrat REP=Republican'),
    'min_first_file_date': Arg(parse_date, description='Earliest date of original registration (mm/dd/yyyy)'),
    'max_first_file_date': Arg(parse_date, description='Latest date of original registration (mm/dd/yyyy)'),
}


reports = {
    'year': Arg(int, multiple=True, description='Year in which a candidate runs for office'),
    'cycle': Arg(int, multiple=True, description='Two-year election cycle in which a candidate runs for office'),
    'beginning_image_number': Arg(int, multiple=True, description='Unique identifier for the electronic or paper report. If report is amended, it will show the most recent report.'),
    'report_type': Arg(str, multiple=True, description='Report type; prefix with "-" to exclude'),
}


totals = {
    'cycle': Arg(int, multiple=True, description='Two-year election cycle in which a candidate runs for office'),
}
