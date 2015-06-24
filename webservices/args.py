import logging
import functools

import sqlalchemy as sa
from smore import swagger

import webargs
from webargs import Arg
from webargs.core import text_type
from webargs.flaskparser import FlaskParser

from webservices import docs
from webservices import exceptions
from webservices.common.models import db
from webservices.config import SQL_CONFIG


logger = logging.getLogger(__name__)


class FlaskRestParser(FlaskParser):

    def handle_error(self, error):
        logger.error(error)
        message = text_type(error)
        status_code = getattr(error, 'status_code', 400)
        payload = getattr(error, 'data', {})
        raise exceptions.ApiError(message, status_code, payload)


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


class OptionValidator(object):

    def __init__(self, values):
        self.values = values

    def __call__(self, value):
        if value .lstrip('-') not in self.values:
            raise exceptions.ApiError('Cannot sort on value "{0}"'.format(value))


class IndexValidator(OptionValidator):

    def __init__(self, model, include=None, exclude=None):
        self.model = model
        self.include = include or []
        self.exclude = exclude or []

    @property
    def values(self):
        if self.include:
            return self.include
        inspector = sa.inspect(db.engine)
        column_map = {
            column.key: label
            for label, column in self.model.__mapper__.columns.items()
        }
        return [
            column_map[column['column_names'][0]]
            for column in inspector.get_indexes(self.model.__tablename__)
            if not self._is_excluded(column_map.get(column['column_names'][0]))
        ]

    def _is_excluded(self, value):
        return not value or value in self.exclude


def make_sort_args(default=None, multiple=True, validator=None):
    return {
        'sort': Arg(
            str,
            multiple=multiple,
            description='Provide a field to sort by. Use - for descending order.',
            default=default,
            validate=validator,
        ),
    }


def make_seek_args(type=int, description=None):
    return {
        'per_page': Natural(default=20, description='The number of results returned per page. Defaults to 20.'),
        'last_index': Arg(
            type,
            description=description or 'Index of last result from previous page',
        ),
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
    'year': Arg(int, multiple=True, description='A year that the committee was active- (After original registration date but before expiration date.)'),
    'cycle': Arg(int, multiple=True, description='A 2-year election cycle that the committee was active- (after original registration date but before expiration date.)'),
    'designation': Arg(str, multiple=True, enum=['', 'A', 'J', 'P', 'U', 'B', 'D'],
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
        - C Communication Cost\n\
        - D Delegate\n\
        - E Electioneering Communication\n\
        - H House\n\
        - I Independent Expenditor (Person or Group)\n\
        - N PAC - Nonqualified\n\
        - O Independent Expenditure-Only (Super PACs)\n\
        - P Presidential\n\
        - Q PAC - Qualified\n\
        - S Senate\n\
        - U Single Candidate Independent Expenditure\n\
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
    'state': Arg(str, multiple=True, description='Two character U.S. state or territory that committee is registered in.'),
    'name': Arg(str, description="Committee's name (full or partial)"),
    'party': Arg(str, multiple=True, description='Three letter code for the party. For example: DEM=Democrat REP=Republican'),
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


itemized = {
    'report_year': Arg(
        int,
        multiple=True,
        validate=lambda value: value >= SQL_CONFIG['START_YEAR_ITEMIZED'],
    ),
    'image_number': Arg(int, multiple=True),
    'min_amount': Arg(float),
    'max_amount': Arg(float),
}

schedule_a = {
    'committee_id': Arg(str, multiple=True),
    'contributor_id': Arg(str, multiple=True),
    'contributor_name': Arg(str),
    'contributor_city': Arg(str, multiple=True),
    'contributor_state': Arg(str, multiple=True),
    'contributor_employer': Arg(str),
    'contributor_occupation': Arg(str),
}


schedule_b = {
    'committee_id': Arg(str, multiple=True),
    'recipient_committee_id': Arg(str, multiple=True),
    'recipient_name': Arg(str),
    'recipient_city': Arg(str, multiple=True),
    'recipient_state': Arg(str, multiple=True),
}
