import logging
import functools

import sqlalchemy as sa
from dateutil.parser import parse as parse_date

import webargs
from webargs import Arg
from webargs.core import text_type
from webargs.flaskparser import FlaskParser

from webservices import docs
from webservices import exceptions
from webservices.common.models import db


logger = logging.getLogger(__name__)


class FlaskRestParser(FlaskParser):

    def handle_error(self, error):
        logger.error(error)
        message = text_type(error)
        status_code = getattr(error, 'status_code', 400)
        payload = getattr(error, 'data', {})
        raise exceptions.ApiError(message, status_code, payload)


parser = FlaskRestParser()


def _validate_natural(value):
    if value < 0:
        raise webargs.ValidationError('Must be a natural number')
Natural = functools.partial(Arg, int, validate=_validate_natural)


def _validate_per_page(value):
    _validate_natural(value)
    if value > 100:
        raise webargs.ValidationError('Parameter "per_page" must be <= 100')


per_page = Natural(
    default=20,
    validate=_validate_per_page,
    description='The number of results returned per page. Defaults to 20.',
)


Currency = functools.partial(Arg, float, use=lambda v: v.lstrip('$').replace(',', ''))
IString = functools.partial(Arg, str, use=lambda v: v.upper())


bool_map = {
    'true': True,
    'false': False,
}
Bool = functools.partial(Arg, bool, use=lambda v: bool_map.get(v.lower()))


class Date(webargs.Arg):
    """Special `Arg` that handles dates and throw an appropriate error for non-date inputs.
    TODO(jmcarp): Find or build a better solution
    """
    def _validate(self, name, value):
        try:
            return parse_date(value)
        except (ValueError, TypeError, OverflowError):
            raise webargs.ValidationError('Expected date for {0}; got "{1}"'.format(name, value))


def _parse_district(value):
    try:
        value = int(value)
    except (TypeError, ValueError):
        raise webargs.ValidationError('District must be a number')
    if value < 0:
        raise webargs.ValidationError('District must be a natural number')
    return '{0:0>2}'.format(value)
District = functools.partial(Arg, str, use=_parse_district, description='Two-digit district number')


paging = {
    'page': Natural(default=1, description='For paginating through results, starting at page 1'),
    'per_page': per_page,
}


class OptionValidator(object):
    """Ensure that value is one of acceptable options.

    :param list values: Valid options.
    """
    def __init__(self, values):
        self.values = values

    def __call__(self, value):
        if value .lstrip('-') not in self.values:
            raise exceptions.ApiError('Cannot sort on value "{0}"'.format(value), status_code=422)


class IndexValidator(OptionValidator):
    """Ensure that value is an indexed column on the specified model.

    :param Base model: SQLALchemy model.
    :param list exclude: Optional list of columns to exclude.
    """
    def __init__(self, model, extra=None, exclude=None):
        self.model = model
        self.extra = extra or []
        self.exclude = exclude or []

    @property
    def values(self):
        inspector = sa.inspect(db.engine)
        column_map = {
            column.key: label
            for label, column in self.model.__mapper__.columns.items()
        }
        return [
            column_map[column['column_names'][0]]
            for column in inspector.get_indexes(self.model.__tablename__)
            if not self._is_excluded(column_map.get(column['column_names'][0]))
        ] + self.extra

    def _is_excluded(self, value):
        return not value or value in self.exclude


def make_sort_args(default=None, multiple=True, validator=None, default_hide_null=False, default_nulls_large=True):
    return {
        'sort': Arg(
            str,
            multiple=multiple,
            description='Provide a field to sort by. Use - for descending order.',
            default=default,
            validate=validator,
        ),
        'sort_hide_null': Bool(
            default=default_hide_null,
            description='Hide null values on sorted column(s).'
        ),
        'sort_nulls_large': Bool(
            default=default_nulls_large,
            description='Treat null values as large on sorted column(s)',
        )
    }

def make_seek_args(type=int, description=None):
    return {
        'per_page': per_page,
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
    'cycle': Arg(int, multiple=True, description=docs.CANDIDATE_CYCLE),
    'office': Arg(str, multiple=True, enum=['', 'H', 'S', 'P'], description='Governmental office candidate runs for: House, Senate or President.'),
    'state': IString(multiple=True, description='U.S. State candidate or territory where a candidate runs for office.'),
    'party': IString(multiple=True, description='Three letter code for the party under which a candidate ran for office'),
    'year': Arg(str, dest='election_year', description='See records pertaining to a particular election year.'),
    'district': District(multiple=True),
    'candidate_status': IString(multiple=True, enum=['', 'C', 'F', 'N', 'P'], description='One letter code explaining if the candidate is:\n\
        - C present candidate\n\
        - F future candidate\n\
        - N not yet a candidate\n\
        - P prior candidate\n\
        '),
    'incumbent_challenge': IString(multiple=True, enum=['', 'I', 'C', 'O'], description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'),
}

candidate_list = {
    'q': Arg(str, description='Text to search all fields for'),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
    'name': Arg(str, description="Candidate's name (full or partial)"),
}

committee = {
    'year': Arg(int, multiple=True, description='A year that the committee was active- (After original registration date but before expiration date.)'),
    'cycle': Arg(int, multiple=True, description=docs.COMMITTEE_CYCLE),
    'designation': IString(
        multiple=True, enum=['', 'A', 'J', 'P', 'U', 'B', 'D'],
        description='The one-letter designation code of the organization:\n\
         - A authorized by a candidate\n\
         - J joint fundraising committee\n\
         - P principal campaign committee of a candidate\n\
         - U unauthorized\n\
         - B lobbyist/registrant PAC\n\
         - D leadership PAC\n\
        '
    ),
    'organization_type': IString(multiple=True, enum=['', 'C', 'L', 'M', 'T', 'V', 'W'],
        description='The one-letter code for the kind for organization:\n\
        - C corporation\n\
        - L labor organization\n\
        - M membership organization\n\
        - T trade association\n\
        - V cooperative\n\
        - W corporation without capital stock\n\
        '),
    'committee_type': IString(multiple=True, enum=['', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y', 'Z'],
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
    'committee_id': IString(multiple=True, description=docs.COMMITTEE_ID),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
    'name': Arg(str, description="Candidate's name (full or partial)"),
    'state': IString(multiple=True, description='Two-character U.S. state or territory in which the committee is registered.'),
    'name': Arg(str, description="Committee's name (full or partial)"),
    'party': IString(multiple=True, description='Three-letter code for the party. For example: DEM=Democrat REP=Republican'),
    'min_first_file_date': Date(description='Minimum date of the first form filed by the committee.'),
    'max_first_file_date': Date(description='Maximum date of the first form filed by the committee.'),
}

filings = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'report_type': IString(multiple=True, description='Report type'),
    'document_type': IString(multiple=True, description=docs.DOC_TYPE),
    'beginning_image_number': Arg(int, multiple=True, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_year': Arg(int, multiple=True, description=docs.REPORT_YEAR),
    'min_receipt_date': Date(description='Minimum day the filing was received by the FEC'),
    'max_receipt_date': Date(description='Maximum day the filing was received by the FEC'),
    'form_type': IString(multiple=True, description='Form type'),
    'primary_general_indicator': IString(multiple=True, description='Primary General or Special election indicator.'),
    'amendment_indicator': IString(multiple=True, description='''
        -N   new\n\
        -A   amendment\n\
        -T   terminated\n\
        -C   consolidated\n\
        -M   multi-candidate\n\
        -S   secondary\n\

    Null might be new or amendment.   If amendment indicator is null and the filings is the first or first in a chain treat it as if it was a new.  If it is not the first or first in a chain then treat the filing as an amendment.
    '''),
}


reports = {
    'year': Arg(int, multiple=True, description='Year in which a candidate runs for office'),
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'beginning_image_number': Arg(int, multiple=True, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_type': Arg(str, multiple=True, description='Report type; prefix with "-" to exclude'),
}


totals = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
}


itemized = {
    # TODO(jmcarp) Request integer image numbers from FEC and update argument types
    'image_number': Arg(
        str,
        multiple=True,
        description='The image number of the page where the schedule item is reported',
    ),
    'min_image_number': Arg(str),
    'max_image_number': Arg(str),
    'min_amount': Currency(description='Filter for all amounts greater than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
    'min_date': Date(description='Minimum date'),
    'max_date': Date(description='Maximum date'),
}

reporting_dates = {
    'due_date': Date(multiple=True, description='Date the filing is done.'),
    'report_year': Arg(int, multiple=True, description='Year of report.'),
    'report_type': Arg(str, multiple=True, description='Type of report.'),
    'create_date': Date(multiple=True, description='Date this record was added to the system.'),
    'update_date': Date(multiple=True, description='Date this record was last updated.'),
    'upcoming': Bool(default=False, description='Only show future due dates for each type of report.'),
}

election_dates = {
    'election_state': Arg(str, multiple=True, description='State of the office sought.'),
    'election_district': Arg(str, multiple=True,
        description='House district of the office sought, if applicable.'),
    'election_party': Arg(str, multiple=True, description='Party, if applicable.'),
    'office_sought': Arg(str, multiple=True, enum=['H', 'S', 'P'], description='House, Senate or presidential office'),
    'election_date': Date(multiple=True, description='Date of election.'),
    'trc_election_type_id': Arg(str, multiple=True, description='Election type'),
    'trc_election_status_id': Arg(str, multiple=True, description=''),
    'update_date': Date(multiple=True, description='Date this record was last updated.'),
    'create_date': Date(multiple=True, description='Date this record was added to the system.'),
    'election_yr': Arg(str, multiple=True, description='Year of election.'),
    'pg_date': Date(multiple=True, description='Date'),
    'upcoming': Bool(default=False, description='Only show future due dates for each type of report.'),
}

schedule_a = {
    'committee_id': IString(multiple=True, description=docs.COMMITTEE_ID),
    'contributor_id': IString(multiple=True, description='The FEC identifier should be represented here the contributor is registered with the FEC.'),
    'contributor_name': Arg(str, description='Name of contributor.'),
    'contributor_city': IString(multiple=True, description='City of contributor'),
    'contributor_state': IString(multiple=True, description='State of contributor'),
    'contributor_employer': Arg(str, description='Employer of contributor, filers need to make an effort to gather this information'),
    'contributor_occupation': Arg(str, description='Occupation of contributor, filers need to make an effort to gather this information'),
    'last_contribution_receipt_date': Date(),
    'last_contribution_receipt_amount': Arg(float),
    'last_contributor_aggregate_ytd': Arg(float),
    'is_individual': Bool(default=None, description='Restrict to non-earmarked individual contributions'),
    'contributor_type': Arg(
        str,
        multiple=True,
        validate=lambda v: v in ['individual', 'committee'],
        description='Filters individual or committee contributions based on line number.'
    ),
}


schedule_a_by_size = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'size': Arg(int, multiple=True, enum=[0, 200, 500, 1000, 2000], description=docs.SIZE),
}


schedule_a_by_state = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'state': IString(multiple=True, description='State of contributor'),
    'hide_null': Bool(default=False, description='Exclude values with missing state'),
}


schedule_a_by_zip = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'zip': Arg(str, multiple=True, description='Zip code'),
    'state': IString(multiple=True, description='State of contributor'),
}


schedule_a_by_employer = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'employer': IString(multiple=True, description='Employer'),
}


schedule_a_by_occupation = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'occupation': IString(multiple=True, description='Occupation'),
}


schedule_a_by_contributor = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'contributor_id': IString(multiple=True, description=docs.COMMITTEE_ID),
}


schedule_b_by_recipient = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'recipient_name': Arg(str, multiple=True, description='Recipient name'),
}


schedule_b_by_recipient_id = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'recipient_id': IString(multiple=True, description='Recipient Committee ID'),
}


schedule_b = {
    'committee_id': IString(multiple=True, description=docs.COMMITTEE_ID),
    'recipient_committee_id': IString(multiple=True, description='The FEC identifier should be represented here the contributor is registered with the FEC'),
    'recipient_name': Arg(str, description='Name of recipient'),
    'disbursement_description': Arg(str, description='Description of disbursement'),
    'recipient_city': IString(multiple=True, description='City of recipient'),
    'recipient_state': IString(multiple=True, description='State of recipient'),
    'last_disbursement_date': Date(description='Filter for records before this date'),
    'last_disbursement_amount': Arg(float, description='Filter for records'),
}

schedule_b_by_purpose = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'purpose': Arg(str, multiple=True, description='Disbursement purpose category'),
}


schedule_e_by_candidate = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
    'support_oppose': IString(
        default=None,
        enum=['S', 'O'],
        validate=lambda v: v.upper() in ['S', 'O'],
        description='Support or opposition'
    ),
}


electioneering_by_candidate = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
}


election_search = {
    'state': IString(multiple=True, description='U.S. State candidate or territory where a candidate runs for office.'),
    'district': District(multiple=True),
    'cycle': Arg(int, multiple=True, description=docs.CANDIDATE_CYCLE),
    'zip': Arg(int, multiple=True),
    'office': Arg(
        str,
        multiple=True,
        enum=['house', 'senate', 'president'],
        validate=lambda v: v.lower() in ['house', 'senate', 'president'],
    ),
}


elections = {
    'state': IString(description='U.S. State candidate or territory where a candidate runs for office.'),
    'district': District(),
    'cycle': Arg(int, description=docs.CANDIDATE_CYCLE),
    'office': Arg(
        str,
        enum=['house', 'senate', 'president'],
        validate=lambda v: v.lower() in ['house', 'senate', 'president'],
        description='Office sought, either President, House or Senate.',
    ),
}


schedule_a_candidate_aggregate = {
    'candidate_id': IString(multiple=True, required=True, description=docs.CANDIDATE_ID),
    'cycle': Arg(int, multiple=True, required=True, description=docs.RECORD_CYCLE),
}

communication_cost_by_candidate = {
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'support_oppose': IString(
        default=None,
        enum=['S', 'O'],
        validate=lambda v: v.upper() in ['S', 'O'],
        description='Support or opposition',
    ),
}


entities = {
    'committee_id': IString(multiple=True, description=docs.COMMITTEE_ID),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
}

schedule_e = {
    'cycle': Arg(int, multiple=True, description=docs.RECORD_CYCLE),
    'committee_id': IString(multiple=True, description=docs.COMMITTEE_ID),
    'candidate_id': IString(multiple=True, description=docs.CANDIDATE_ID),
    'last_expenditure_date': Date(description='For paging through schedule E data by date.'),
    'last_expenditure_amount': Arg(float, description='For paging through schedule E data by expenditure amount.'),
    'last_office_total_ytd': Arg(float, description='For paging through total year to date spent on an office'),
    'payee_name': Arg(str, description='Name of the entity that received the payment.'),
}
