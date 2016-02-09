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

per_page = Natural(
    missing=20,
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

election_full = fields.Bool(missing=False, description='Aggregate values over full election period')

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

def make_sort_args(default=None, validator=None, default_hide_null=False, default_nulls_large=True):
    return {
        'sort': fields.Str(
            missing=default,
            validate=validator,
            description='Provide a field to sort by. Use - for descending order.',
        ),
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
    'office': fields.List(fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])), description=docs.OFFICE),
    'state': fields.List(IStr, description=docs.STATE),
    'party': fields.List(IStr, description=docs.PARTY),
    'year': fields.Str(attribute='year', description=docs.YEAR),
    'district': fields.List(District, description=docs.DISTRICT),
    'candidate_status': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'F', 'N', 'P'])),
        description=docs.CANDIDATE_STATUS,
    ),
    'incumbent_challenge': fields.List(
        IStr(validate=validate.OneOf(['', 'I', 'C', 'O'])),
        description=docs.INCUMBENT_CHALLENGE,
    ),
}

candidate_list = {
    'q': fields.Str(description='Text to search all fields for'),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'name': fields.Str(description="Candidate's name (full or partial)"),
}

candidate_history = {
    'election_full': election_full,
}

committee = {
    'year': fields.List(fields.Int, description=docs.COMMITTEE_YEAR),
    'cycle': fields.List(fields.Int, description=docs.COMMITTEE_CYCLE),
    'designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description=docs.DESIGNATION,
    ),
    'organization_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description=docs.ORGANIZATION_TYPE,
    ),
    'committee_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q', 'S', 'U', 'V', 'W', 'X', 'Y', 'Z'])),
        description=docs.COMMITTEE_TYPE,
    ),
}

committee_list = {
    'q': fields.Str(description='Text to search all fields for'),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'state': fields.List(IStr, description=docs.STATE_GENERIC),
    'name': fields.Str(description=docs.COMMITTEE_NAME),
    'party': fields.List(IStr, description=docs.PARTY),
    'min_first_file_date': fields.Date(description='Selects all committees whose first filing was received by the FEC after this date'),
    'max_first_file_date': fields.Date(description='Selects all committees whose first filing was received by the FEC before this date'),
    'treasurer_name': fields.Str(description=docs.TREASURER_NAME),
}

committee_history = {
    'election_full': election_full,
}

filings = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'report_type': fields.List(IStr, description='Report type'),
    'document_type': fields.List(IStr, description=docs.DOC_TYPE),
    'beginning_image_number': fields.List(fields.Int, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'min_receipt_date': fields.Date(description='Selects all items received by FEC after this date'),
    'max_receipt_date': fields.Date(description='Selects all items received by FEC before this date'),
    'form_type': fields.List(IStr, description='Form type'),
    'primary_general_indicator': fields.List(IStr, description='Primary, general or special election indicator'),
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
    'is_amended': fields.Bool(description='Report has been amended'),
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
    'min_due_date': fields.Date(description='Date the report is due'),
    'max_due_date': fields.Date(description='Date the report is due'),
    'report_year': fields.List(fields.Int, description='Year of report'),
    'report_type': fields.List(fields.Str, description='Type of report'),
    'min_create_date': fields.Date(description='Date this record was added to the system'),
    'max_create_date': fields.Date(description='Date this record was added to the system'),
    'min_update_date': fields.Date(description='Date this record was last updated'),
    'max_update_date': fields.Date(description='Date this record was last updated'),
}

election_dates = {
    'election_state': fields.List(fields.Str, description='State or territory of the office sought'),
    'election_district': fields.List(fields.Str, description='House district of the office sought, if applicable.'),
    'election_party': fields.List(fields.Str, description='Party, if applicable.'),
    'office_sought': fields.List(fields.Str(validate=validate.OneOf(['H', 'S', 'P'])), description='House, Senate or presidential office'),
    'min_election_date': fields.Date(description='Date of election'),
    'max_election_date': fields.Date(description='Date of election'),
    'election_type_id': fields.List(fields.Str, description='Election type'),
    'min_update_date': fields.Date(description='Date this record was last updated'),
    'max_update_date': fields.Date(description='Date this record was last updated'),
    'min_create_date': fields.Date(description='Date this record was added to the system'),
    'max_create_date': fields.Date(description='Date this record was added to the system'),
    'election_year': fields.List(fields.Str, description='Year of election'),
    'min_primary_general_date': fields.Date(description='Date of primary or general election'),
    'max_primary_general_date': fields.Date(description='Date of primary or general election'),
}

class MappedList(fields.List):

    def __init__(self, cls_or_instance, mapping=None, **kwargs):
        super().__init__(cls_or_instance, **kwargs)
        self.mapping = mapping or {}

    def _deserialize(self, value, attr, data):
        ret = super()._deserialize(value, attr, data)
        return sum(
            [self.mapping.get(each, [each]) for each in ret],
            [],
        )

calendar_dates = {
    'category': MappedList(
        fields.Str,
        description=docs.CATEGORY,
        mapping={
            'report-Q': ['report-Q{}'.format(each) for each in range(1, 4)] + ['report-YE'],
            'report-M': ['report-M{}'.format(each) for each in range(2, 13)] + ['report-YE'],
            'report-E': [
                'report-{}'.format(each)
                for each in ['12C', '12G', '12GR', '12P', '12PR', '12R', '12S', '12SC', '12SG', '12SGR', '12SP', '12SPR', '30D', '30G', '30GR', '30P', '30R', '30S', '30SC', '30SG', '30SGR', '60D']
            ],
        },
    ),
    'description': fields.Str(description=docs.DESCRIPTION),
    'summary': fields.Str(description=docs.SUMMARY),
    'state': fields.List(fields.Str, description=docs.CAL_STATE),
    'min_start_date': fields.DateTime(description='The minimum start date and time'),
    'min_end_date': fields.DateTime(description='The minimum end date and time'),
    'max_start_date': fields.DateTime(description='The maximum start date and time'),
    'max_end_date': fields.DateTime(description='The maximum end date and time'),
    'event_id': fields.Int(description=docs.EVENT_ID),
}

schedule_a = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
    'contributor_name': fields.Str(description=docs.CONTRIBUTOR_NAME),
    'contributor_city': fields.List(IStr, description=docs.CONTRIBUTOR_CITY),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'contributor_employer': fields.Str(description=docs.CONTRIBUTOR_EMPLOYER),
    'contributor_occupation': fields.Str(description=docs.CONTRIBUTOR_OCCUPATION),
    'last_contribution_receipt_date': fields.Date(missing=None, description='When sorting by `contribution_receipt_date`, use the `contribution_receipt_date` of the last result and pass it here as `last_contribution_receipt_date` to page through Schedule A data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'last_contribution_receipt_amount': fields.Float(missing=None, description='When sorting by `contribution_receipt_amount`, use the `contribution_receipt_amount` of the last result and pass it here as `last_contribution_receipt_amount` to page through Schedule A data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'last_contributor_aggregate_ytd': fields.Float(missing=None, description='When sorting by `contributor_aggregate_ytd`, use the `contributor_aggregate_ytd` of the last result and pass it here as `last_contributor_aggregate_ytd` to page through Schedule A data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'is_individual': fields.Bool(missing=None, description=docs.IS_INDIVIDUAL),
    'contributor_type': fields.List(
        fields.Str(validate=validate.OneOf(['individual', 'committee'])),
        description='Filters individual or committee contributions based on line number'
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
    'employer': fields.List(IStr, description=docs.EMPLOYER),
}

schedule_a_by_occupation = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'occupation': fields.List(IStr, description=docs.OCCUPATION),
}

schedule_a_by_contributor = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
}

schedule_b_by_recipient = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_name': fields.List(fields.Str, description=docs.RECIPIENT_NAME),
}

schedule_b_by_recipient_id = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_id': fields.List(IStr, description=docs.RECIPIENT_ID),
}

schedule_b = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'recipient_committee_id': fields.List(IStr, description='The FEC identifier should be represented here if the contributor is registered with the FEC.'),
    'recipient_name': fields.Str(description='Name of recipient'),
    'disbursement_description': fields.Str(description='Description of disbursement'),
    'recipient_city': fields.List(IStr, description='City of recipient'),
    'recipient_state': fields.List(IStr, description='State of recipient'),
    'disbursement_purpose_category': fields.List(IStr, description='Disbursement purpose category'),
    'last_disbursement_date': fields.Date(missing=None, description='When sorting by `disbursement_date`, use the `disbursement_date` of the last result and pass it here as `last_disbursement_date` to page through Schedule B data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'last_disbursement_amount': fields.Float(missing=None, description='When sorting by `disbursement_amount`, use the `disbursement_amount` of the last result and pass it here as `last_disbursement_amount` to page through Schedule B data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
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

communication_cost = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])),
        description='Support or opposition',
    ),
}

electioneering = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'min_amount': Currency(description='Filter for all amounts greater than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
    'min_date': fields.Date(description='Minimum disbursement date'),
    'max_date': fields.Date(description='Maximum disbursement date'),
}

electioneering_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
}

election_search = {
    'state': fields.List(IStr, description=docs.STATE),
    'district': fields.List(District, description=docs.DISTRICT),
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'zip': fields.List(fields.Int, description=docs.ZIP_CODE),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['house', 'senate', 'president'])),
    ),
}

elections = {
    'state': IStr(description=docs.STATE),
    'district': District(description=docs.DISTRICT),
    'cycle': fields.Int(description=docs.CANDIDATE_CYCLE),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
    'election_full': election_full,
}

schedule_a_candidate_aggregate = {
    'candidate_id': fields.List(IStr, required=True, description=docs.CANDIDATE_ID),
    'cycle': fields.List(fields.Int, required=True, description=docs.RECORD_CYCLE),
    'election_full': election_full,
}

totals_candidate_aggregate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'election_full': election_full,
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
    'filing_form': fields.List(IStr, description='Filing form'),
    'last_expenditure_date': fields.Date(missing=None, description='When sorting by `expenditure_date`, use the `expenditure_date` of the last result and pass it here as `last_expenditure_date` to page through Schedule E data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'last_expenditure_amount': fields.Float(missing=None, description='When sorting by `expenditure_amount`, use the `expenditure_amount` of the last result and pass it here as `last_expenditure_amount` to page through Schedule E data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'last_office_total_ytd': fields.Float(missing=None, description='When sorting by `office_total_ytd`, use the `office_total_ytd` of the last result and pass it here as `last_office_total_ytd` to page through Schedule E data. You’ll also need to pass the index of that last result to `last_index` to get the next page.'),
    'payee_name': fields.Str(description='Name of the entity that received the payment'),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])),
        description='Support or opposition',
    ),
    'is_notice': fields.List(fields.Bool, description='Record filed as 24- or 48-hour notice'),
}
