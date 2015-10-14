import functools

import sqlalchemy as sa

from webargs import fields, validate, ValidationError
from marshmallow.compat import text_type

from webservices import docs
from webservices.common.models import db


def _validate_natural(value):
    if value < 0:
        raise ValidationError('Must be a natural number')

Natural = functools.partial(fields.Int, validate=_validate_natural)

def _validate_per_page(value):
    _validate_natural(value)
    if value > 100:
        raise ValidationError('Must be less than 100')

per_page = Natural(
    missing=20,
    validate=_validate_per_page,
    description='The number of results returned per page. Defaults to 20.',
)

class Currency(fields.Decimal):

    def __init__(self, places=2, **kwargs):
        super().__init__(places=places, **kwargs)

    def _validated(self, value):
        if isinstance(value, text_type):
            value = value.lstrip('$').replace(',', '')
        return super()._validated(value)

class IStr(fields.Str):

    def _deserialize(self, value, attr, data):
        return super()._deserialize(value, attr, data).upper()

class District(fields.Str):

    def _validate(self, value):
        super()._validate(value)
        try:
            value = int(value)
        except (TypeError, ValueError):
            raise ValidationError('District must be a number')
        if value < 0:
            raise ValidationError('District must be a natural number')

    def _deserialize(self, value, attr, data):
        return '{0:0>2}'.format(value)

paging = {
    'page': Natural(missing=1, description='For paginating through results, starting at page 1'),
    'per_page': per_page,
}

class OptionValidator(object):
    """Ensure that value is one of acceptable options.

    :param list values: Valid options.
    """
    def __init__(self, values):
        self.values = values

    def __call__(self, value):
        if value.lstrip('-') not in self.values:
            raise ValidationError('Cannot sort on value "{0}"'.format(value), status_code=422)

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
    description = 'Provide a field to sort by. Use - for descending order.'
    if multiple:
        sort_field = fields.List(
            fields.Str(validate=validator),
            missing=default,
            description=description,
        )
    else:
        sort_field = fields.Str(
            missing=default,
            validate=validator,
            description=description,
        )
    return {
        'sort': sort_field,
        'sort_hide_null': fields.Bool(
            missing=default_hide_null,
            description='Hide null values on sorted column(s).'
        ),
        'sort_nulls_large': fields.Bool(
            missing=default_nulls_large,
            description='Treat null values as large on sorted column(s)',
        )
    }

def make_seek_args(field=fields.Int, description=None):
    return {
        'per_page': per_page,
        'last_index': field(
            missing=None,
            description=description or 'Index of last result from previous page',
        ),
    }

names = {
    'q': fields.Str(required=True, description='Name (candidate or committee) to search for'),
}

candidate_detail = {
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'office': fields.List(fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])), description='Governmental office candidate runs for: House, Senate or President.'),
    'state': fields.List(IStr, description='U.S. State candidate or territory where a candidate runs for office.'),
    'party': fields.List(IStr, description='Three letter code for the party under which a candidate ran for office'),
    'year': fields.Str(attribute='year', description='See records pertaining to a particular election year. The list of election years is based on a candidate filing a statement of candidacy (F2) for that year.'),
    'district': fields.List(District),
    'candidate_status': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'F', 'N', 'P'])),
        description='One letter code explaining if the candidate is:\n\
        - C present candidate\n\
        - F future candidate\n\
        - N not yet a candidate\n\
        - P prior candidate\n\
        '
    ),
    'incumbent_challenge': fields.List(
        IStr(validate=validate.OneOf(['', 'I', 'C', 'O'])),
        description='One letter code explaining if the candidate is an incumbent, a challenger, or if the seat is open.'
    ),
}

candidate_list = {
    'q': fields.Str(description='Text to search all fields for'),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'name': fields.Str(description="Candidate's name (full or partial)"),
}

committee = {
    'year': fields.List(fields.Int, description='A year that the committee was active- (After original registration date but before expiration date.)'),
    'cycle': fields.List(fields.Int, description=docs.COMMITTEE_CYCLE),
    'designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description='The one-letter designation code of the organization:\n\
         - A authorized by a candidate\n\
         - J joint fundraising committee\n\
         - P principal campaign committee of a candidate\n\
         - U unauthorized\n\
         - B lobbyist/registrant PAC\n\
         - D leadership PAC\n\
        ',
    ),
    'organization_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description='The one-letter code for the kind for organization:\n\
        - C corporation\n\
        - L labor organization\n\
        - M membership organization\n\
        - T trade association\n\
        - V cooperative\n\
        - W corporation without capital stock\n\
        ',
    ),
    'committee_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y', 'Z'])),
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
        ',
    ),
}

committee_list = {
    'q': fields.Str(description='Text to search all fields for'),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'name': fields.Str(description="Candidate's name (full or partial)"),
    'state': fields.List(IStr, description='Two-character U.S. state or territory in which the committee is registered.'),
    'name': fields.Str(description="Committee's name (full or partial)"),
    'party': fields.List(IStr, description='Three-letter code for the party. For example: DEM=Democrat REP=Republican'),
    'min_first_file_date': fields.Date(description='Minimum date of the first form filed by the committee.'),
    'max_first_file_date': fields.Date(description='Maximum date of the first form filed by the committee.'),
}

filings = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'report_type': fields.List(IStr, description='Report type'),
    'document_type': fields.List(IStr, description=docs.DOC_TYPE),
    'beginning_image_number': fields.List(fields.Int, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'min_receipt_date': fields.Date(description='Minimum day the filing was received by the FEC'),
    'max_receipt_date': fields.Date(description='Maximum day the filing was received by the FEC'),
    'form_type': fields.List(IStr, description='Form type'),
    'primary_general_indicator': fields.List(IStr, description='Primary General or Special election indicator.'),
    'amendment_indicator': fields.List(
        IStr,
        description='''
        -N   new\n\
        -A   amendment\n\
        -T   terminated\n\
        -C   consolidated\n\
        -M   multi-candidate\n\
        -S   secondary\n\

        Null might be new or amendment.   If amendment indicator is null and the filings is the first or first in a chain treat it as if it was a new.  If it is not the first or first in a chain then treat the filing as an amendment.
        '''
    ),
}

reports = {
    'year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'beginning_image_number': fields.List(fields.Int, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_type': fields.List(fields.Str, description='Report type; prefix with "-" to exclude'),
}


totals = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
}


itemized = {
    # TODO(jmcarp) Request integer image numbers from FEC and update argument types
    'image_number': fields.List(
        fields.Str,
        description='The image number of the page where the schedule item is reported',
    ),
    'min_image_number': fields.Str(),
    'max_image_number': fields.Str(),
    'min_amount': Currency(description='Filter for all amounts greater than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
    'min_date': fields.Date(description='Minimum date'),
    'max_date': fields.Date(description='Maximum date'),
}

reporting_dates = {
    'due_date': fields.List(fields.Date, description='Date the filing is done.'),
    'report_year': fields.List(fields.Int, description='Year of report.'),
    'report_type': fields.List(fields.Str, description='Type of report.'),
    'create_date': fields.List(fields.Date, description='Date this record was added to the system.'),
    'update_date': fields.List(fields.Date, description='Date this record was last updated.'),
    'upcoming': fields.Bool(missing=False, description='Only show future due dates for each type of report.'),
}

election_dates = {
    'election_state': fields.List(fields.Str, description='State or territory of the office sought.'),
    'election_district': fields.List(fields.Str, description='House district of the office sought, if applicable.'),
    'election_party': fields.List(fields.Str, description='Party, if applicable.'),
    'office_sought': fields.List(fields.Str(validate=validate.OneOf(['H', 'S', 'P'])), description='House, Senate or presidential office'),
    'election_date': fields.List(fields.Date, description='Date of election.'),
    'trc_election_type_id': fields.List(fields.Str, description='Election type'),
    'trc_election_status_id': fields.List(fields.Str, description=''),
    'update_date': fields.List(fields.Date, description='Date this record was last updated.'),
    'create_date': fields.List(fields.Date, description='Date this record was added to the system.'),
    'election_year': fields.List(fields.Str, description='Year of election.'),
    'pg_date': fields.List(fields.Date, description='Date'),
    'upcoming': fields.Bool(missing=False, description='Only show future due dates for each type of report.'),
}

schedule_a = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'contributor_id': fields.List(IStr, description='The FEC identifier should be represented here the contributor is registered with the FEC.'),
    'contributor_name': fields.Str(description='Name of contributor.'),
    'contributor_city': fields.List(IStr, description='City of contributor'),
    'contributor_state': fields.List(IStr, description='State of contributor'),
    'contributor_employer': fields.Str(description='Employer of contributor, filers need to make an effort to gather this information'),
    'contributor_occupation': fields.Str(description='Occupation of contributor, filers need to make an effort to gather this information'),
    'last_contribution_receipt_date': fields.Date(missing=None),
    'last_contribution_receipt_amount': fields.Float(missing=None),
    'last_contributor_aggregate_ytd': fields.Float(missing=None),
    'is_individual': fields.Bool(missing=None, description='Restrict to non-earmarked individual contributions'),
    'contributor_type': fields.List(
        fields.Str(validate=validate.OneOf(['individual', 'committee'])),
        description='Filters individual or committee contributions based on line number.'
    ),
}

schedule_a_by_size = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'size': fields.List(fields.Int(validate=validate.OneOf([0, 200, 500, 1000, 2000])), description=docs.SIZE),
}

schedule_a_by_state = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'state': fields.List(IStr, description='State of contributor'),
    'hide_null': fields.Bool(missing=False, description='Exclude values with missing state'),
}

schedule_a_by_zip = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'zip': fields.List(fields.Str, description='Zip code'),
    'state': fields.List(IStr, description='State of contributor'),
}

schedule_a_by_employer = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'employer': fields.List(IStr, description='Employer'),
}

schedule_a_by_occupation = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'occupation': fields.List(IStr, description='Occupation'),
}

schedule_a_by_contributor = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'contributor_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_b_by_recipient = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_name': fields.List(fields.Str, description='Recipient name'),
}

schedule_b_by_recipient_id = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_id': fields.List(IStr, description='Recipient Committee ID'),
}

schedule_b = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'recipient_committee_id': fields.List(IStr, description='The FEC identifier should be represented here the contributor is registered with the FEC'),
    'recipient_name': fields.Str(description='Name of recipient'),
    'disbursement_description': fields.Str(description='Description of disbursement'),
    'recipient_city': fields.List(IStr, description='City of recipient'),
    'recipient_state': fields.List(IStr, description='State of recipient'),
    'last_disbursement_date': fields.Date(missing=None, description='Filter for records before this date'),
    'last_disbursement_amount': fields.Float(missing=None, description='Filter for records'),
}

schedule_b_by_purpose = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'purpose': fields.List(fields.Str, description='Disbursement purpose category'),
}

schedule_e_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'support_oppose': IStr(
        missing=None,
        validate=validate.OneOf(['S', 'O']),
        description='Support or opposition'
    ),
}

electioneering_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
}

election_search = {
    'state': fields.List(IStr, description='U.S. State candidate or territory where a candidate runs for office.'),
    'district': fields.List(District),
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'zip': fields.List(fields.Int),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['house', 'senate', 'president'])),
    ),
}

elections = {
    'state': IStr(description='U.S. State candidate or territory where a candidate runs for office.'),
    'district': District(),
    'cycle': fields.Int(description=docs.CANDIDATE_CYCLE),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description='Office sought, either President, House or Senate.',
    ),
}

schedule_a_candidate_aggregate = {
    'candidate_id': fields.List(IStr, required=True, description=docs.CANDIDATE_ID),
    'cycle': fields.List(fields.Int, required=True, description=docs.RECORD_CYCLE),
}

communication_cost_by_candidate = {
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'support_oppose': IStr(
        missing=None,
        validate=validate.OneOf(['S', 'O']),
        description='Support or opposition',
    ),
}

entities = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
}

schedule_e = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'last_expenditure_date': fields.Date(missing=None, description='For paging through schedule E data by date.'),
    'last_expenditure_amount': fields.Float(missing=None, description='For paging through schedule E data by expenditure amount.'),
    'last_office_total_ytd': fields.Float(missing=None, description='For paging through total year to date spent on an office'),
    'payee_name': fields.Str(description='Name of the entity that received the payment.'),
}
