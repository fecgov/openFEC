import functools

from marshmallow.compat import text_type

import sqlalchemy as sa

from webargs import ValidationError, fields, validate

from webservices import docs
from webservices.common.models import db
from webservices.config import SQL_CONFIG


def _validate_natural(value):
    if value < 0:
        raise ValidationError('Must be a natural number')


Natural = functools.partial(fields.Int, validate=_validate_natural)

per_page = Natural(
    missing=20, description='The number of results returned per page. Defaults to 20.'
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


election_full = fields.Bool(
    missing=False, description='Aggregate values over full election period'
)

paging = {
    'page': Natural(
        missing=1, description='For paginating through results, starting at page 1'
    ),
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
            raise ValidationError(
                'Cannot sort on value "{0}"'.format(value), status_code=422
            )


class IndexValidator(OptionValidator):
    """Ensure that value is an indexed column on the specified model.

    :param Base model: SQLALchemy model.
    :param list exclude: Optional list of columns to exclude.
    :param list extra: Optional list of extra columns to include.
    """

    def __init__(self, model, extra=None, exclude=None):
        self.model = model
        self.extra = extra or []
        self.exclude = exclude or []

    @property
    def values(self):
        inspector = sa.inspect(db.engine)
        column_map = {
            column.key: label for label, column in self.model.__mapper__.columns.items()
        }
        return [
            column_map[column['column_names'][0]]
            for column in inspector.get_indexes(
                self.model.__tablename__, self.model.__table__.schema
            )
            if not self._is_excluded(column_map.get(column['column_names'][0]))
        ] + self.extra

    def _is_excluded(self, value):
        return not value or value in self.exclude


class IndicesValidator(IndexValidator):
    def __call__(self, value):
        for sort_column in value:
            if sort_column.lstrip('-') not in self.values:
                raise ValidationError(
                    'Cannot sort on value "{0}"'.format(value), status_code=422
                )


def make_sort_args(
    default=None,
    validator=None,
    default_hide_null=False,
    default_reverse_nulls=True,
    default_nulls_only=False,
):
    return {
        'sort': fields.Str(
            missing=default,
            validate=validator,
            description='Provide a field to sort by. Use - for descending order.',
        ),
        'sort_hide_null': fields.Bool(
            missing=default_hide_null,
            description='Hide null values on sorted column(s).',
        ),
        'sort_null_only': fields.Bool(
            missing=default_nulls_only,
            description='Toggle that filters out all rows having sort column that is non-null',
        ),
    }


def make_multi_sort_args(
    default=None,
    validator=None,
    default_hide_null=False,
    default_reverse_nulls=True,
    default_nulls_only=False,
):
    args = make_sort_args(
        default, validator, default_hide_null, default_reverse_nulls, default_nulls_only
    )
    args['sort'] = fields.List(
        fields.Str,
        missing=default,
        validate=validator,
        required=False,
        allow_none=True,
        description='Provide a field to sort by. Use - for descending order.',
    )
    return args


def make_seek_args(field=fields.Int, description=None):
    return {
        'per_page': per_page,
        'last_index': field(
            missing=None,
            description=description or 'Index of last result from previous page',
        ),
    }


names = {
    'q': fields.List(
        fields.Str,
        required=True,
        description='Name (candidate or committee) to search for',
    )
}

query = {
    'q': fields.Str(required=False, description='Text to search legal documents for.'),
    'from_hit': fields.Int(
        required=False, description='Get results starting from this index.'
    ),
    'hits_returned': fields.Int(
        required=False, description='Number of results to return (max 10).'
    ),
    'type': fields.Str(required=False, description='Document type to refine search by'),
    'ao_no': fields.List(
        IStr, required=False, description='Force advisory opinion number'
    ),
    'ao_name': fields.List(
        IStr, required=False, description='Force advisory opinion name'
    ),
    'ao_min_issue_date': fields.Date(
        description="Earliest issue date of advisory opinion"
    ),
    'ao_max_issue_date': fields.Date(
        description="Latest issue date of advisory opinion"
    ),
    'ao_min_request_date': fields.Date(
        description="Earliest request date of advisory opinion"
    ),
    'ao_max_request_date': fields.Date(
        description="Latest request date of advisory opinion"
    ),
    'ao_category': fields.List(
        IStr(validate=validate.OneOf(['F', 'V', 'D', 'R', 'W', 'C', 'S'])),
        description="Category of the document",
    ),
    'ao_is_pending': fields.Bool(description="AO is pending"),
    'ao_status': fields.Str(description="Status of AO (pending, withdrawn, or final)"),
    'ao_requestor': fields.Str(description="The requestor of the advisory opinion"),
    'ao_requestor_type': fields.List(
        fields.Integer(validate=validate.OneOf(range(1, 17))),
        description="Code of the advisory opinion requestor type.",
    ),
    'ao_regulatory_citation': fields.List(
        IStr, required=False, description="Search for regulatory citations"
    ),
    'ao_statutory_citation': fields.List(
        IStr, required=False, description="Search for statutory citations"
    ),
    'ao_citation_require_all': fields.Bool(
        description="Require all citations to be in document (default behavior is any)"
    ),
    'ao_entity_name': fields.List(
        IStr,
        required=False,
        description='Search by name of commenter or representative',
    ),
    'mur_no': fields.List(
        IStr, required=False, description='Filter MURs by case number'
    ),
    'mur_respondents': fields.Str(
        IStr, required=False, description='Filter MURs by respondents'
    ),
    'mur_dispositions': fields.List(
        IStr, required=False, description='Filter MURs by dispositions'
    ),
    'mur_election_cycles': fields.Int(
        IStr, required=False, description='Filter MURs by election cycles'
    ),
    'mur_document_category': fields.List(
        IStr,
        required=False,
        description='Filter MURs by category of associated documents',
    ),
    'mur_min_open_date': fields.Date(
        required=False, description='Filter MURs by earliest date opened'
    ),
    'mur_max_open_date': fields.Date(
        required=False, description='Filter MURs by latest date opened'
    ),
    'mur_min_close_date': fields.Date(
        required=False, description='Filter MURs by earliest date closed'
    ),
    'mur_max_close_date': fields.Date(
        required=False, description='Filter MURs by latest date closed'
    ),
    'case_no': fields.List(
        IStr, required=False, description='Enforcement matter case number'
    ),
    'case_document_category': fields.List(
        IStr,
        required=False,
        description='Filter cases by category of associated documents',
    ),
    'case_respondents': fields.Str(
        IStr, required=False, description='Filter cases by respondents'
    ),
    'case_dispositions': fields.List(
        IStr, required=False, description='Filter cases by dispositions'
    ),
    'case_election_cycles': fields.Int(
        IStr, required=False, description='Filter cases by election cycles'
    ),
    'case_min_open_date': fields.Date(
        required=False, description='Filter cases by earliest date opened'
    ),
    'case_max_open_date': fields.Date(
        required=False, description='Filter cases by latest date opened'
    ),
    'case_min_close_date': fields.Date(
        required=False, description='Filter cases by earliest date closed'
    ),
    'case_max_close_date': fields.Date(
        required=False, description='Filter cases by latest date closed'
    ),
    'af_name': fields.List(
        IStr, required=False, description='Admin fine committee name'
    ),
    'af_committee_id': fields.Str(
        IStr, required=False, description='Admin fine committee ID'
    ),
    'af_report_year': fields.Str(
        IStr, required=False, description='Admin fine report year'
    ),
    'af_min_rtb_date': fields.Date(
        required=False, description='Filter cases by earliest Reason to Believe date'
    ),
    'af_max_rtb_date': fields.Date(
        required=False, description='Filter cases by latest Reason to Believe date'
    ),
    'af_rtb_fine_amount': fields.Int(
        IStr,
        required=False,
        description='Filter cases by Reason to Believe fine amount',
    ),
    'af_min_fd_date': fields.Date(
        required=False, description='Filter cases by earliest Final Determination date'
    ),
    'af_max_fd_date': fields.Date(
        required=False, description='Filter cases by latest Final Determination date'
    ),
    'af_fd_fine_amount': fields.Int(
        IStr,
        required=False,
        description='Filter cases by Final Determination fine amount',
    ),
}

candidate_detail = {
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])),
        description=docs.OFFICE,
    ),
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
    'federal_funds_flag': fields.Bool(description=docs.FEDERAL_FUNDS_FLAG),
    'has_raised_funds': fields.Bool(description=docs.HAS_RAISED_FUNDS),
    'name': fields.List(
        fields.Str,
        description='Name (candidate or committee) to search for. Alias for \'q\'.',
    ),
}

candidate_list = {
    'q': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'min_first_file_date': fields.Date(
        description='Selects all candidates whose first filing was received by the FEC after this date'
    ),
    'max_first_file_date': fields.Date(
        description='Selects all candidates whose first filing was received by the FEC before this date'
    ),
}

candidate_history = {'election_full': election_full}

committee = {
    'year': fields.List(fields.Int, description=docs.COMMITTEE_YEAR),
    'cycle': fields.List(fields.Int, description=docs.COMMITTEE_CYCLE),
    'filing_frequency': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'M', 'N', 'Q', 'T', 'W', '-A', '-T'])),
        description=docs.FILING_FREQUENCY,
    ),
    'designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description=docs.DESIGNATION,
    ),
    'organization_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description=docs.ORGANIZATION_TYPE,
    ),
    'committee_type': fields.List(
        IStr(
            validate=validate.OneOf(
                [
                    '',
                    'C',
                    'D',
                    'E',
                    'H',
                    'I',
                    'N',
                    'O',
                    'P',
                    'Q',
                    'S',
                    'U',
                    'V',
                    'W',
                    'X',
                    'Y',
                    'Z',
                ]
            )
        ),
        description=docs.COMMITTEE_TYPE,
    ),
}

committee_list = {
    'q': fields.List(fields.Str, description=docs.COMMITTEE_NAME),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'state': fields.List(IStr, description=docs.STATE_GENERIC),
    'party': fields.List(IStr, description=docs.PARTY),
    'min_first_file_date': fields.Date(
        description='Filter for committees whose first filing was received on or after this date'
    ),
    'max_first_file_date': fields.Date(
        description='Filter for committees whose first filing was received on or before this date'
    ),
    'min_last_f1_date': fields.Date(
        description='Filter for committees whose latest Form 1 was received on or after this date'
    ),
    'max_last_f1_date': fields.Date(
        description='Filter for committees whose latest Form 1 was received on or before this date'
    ),
    'treasurer_name': fields.List(fields.Str, description=docs.TREASURER_NAME),
}

committee_history = {'election_full': election_full}

filings = {
    'committee_type': fields.Str(description=docs.COMMITTEE_TYPE),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'is_amended': fields.Bool(description='Filing has been amended'),
    'most_recent': fields.Bool(
        description='Filing is either new or is the most-recently filed amendment'
    ),
    'report_type': fields.List(IStr, description=docs.REPORT_TYPE),
    'request_type': fields.List(IStr, description=docs.REQUEST_TYPE),
    'document_type': fields.List(IStr, description=docs.DOC_TYPE),
    'beginning_image_number': fields.List(
        fields.Str, description=docs.BEGINNING_IMAGE_NUMBER
    ),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'min_receipt_date': fields.Date(
        description='Selects all items received by FEC after this date'
    ),
    'max_receipt_date': fields.Date(
        description='Selects all items received by FEC before this date'
    ),
    'form_type': fields.List(IStr, description=docs.FORM_TYPE),
    'state': fields.List(IStr, description=docs.STATE),
    'district': fields.List(IStr, description=docs.DISTRICT),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])),
        description=docs.OFFICE,
    ),
    'party': fields.List(IStr, description=docs.PARTY),
    'filer_type': fields.Str(
        validate=validate.OneOf(['e-file', 'paper']), description=docs.MEANS_FILED
    ),
    'file_number': fields.List(fields.Int, description=docs.FILE_NUMBER),
    'primary_general_indicator': fields.List(
        IStr, description='Primary, general or special election indicator'
    ),
    'amendment_indicator': fields.List(
        IStr(validate=validate.OneOf(['', 'N', 'A', 'T', 'C', 'M', 'S'])),
        description=docs.AMENDMENT_INDICATOR,
    ),
}

efilings = {
    'file_number': fields.List(fields.Int, description=docs.FILE_NUMBER),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'min_receipt_date': fields.DateTime(
        description='Selects all items received by FEC after this date or datetime'
    ),
    'max_receipt_date': fields.DateTime(
        description='Selects all items received by FEC before this date or datetime'
    ),
}

reports = {
    'year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'beginning_image_number': fields.List(
        fields.Str, description=docs.BEGINNING_IMAGE_NUMBER
    ),
    'report_type': fields.List(fields.Str, description=docs.REPORT_TYPE_W_EXCLUDE),
    'is_amended': fields.Bool(description='Report has been amended'),
    'most_recent': fields.Bool(
        description='Report is either new or is the most-recently filed amendment'
    ),
    'filer_type': fields.Str(
        validate=validate.OneOf(['e-file', 'paper']), description=docs.MEANS_FILED
    ),
    'min_disbursements_amount': Currency(description=docs.MIN_FILTER),
    'max_disbursements_amount': Currency(description=docs.MAX_FILTER),
    'min_receipts_amount': Currency(description=docs.MIN_FILTER),
    'max_receipts_amount': Currency(description=docs.MAX_FILTER),
    'min_receipt_date': fields.DateTime(
        description='Selects all items received by FEC after this date or datetime'
    ),
    'max_receipt_date': fields.DateTime(
        description='Selects all items received by FEC before this date or datetime'
    ),
    'min_cash_on_hand_end_period_amount': Currency(description=docs.MIN_FILTER),
    'max_cash_on_hand_end_period_amount': Currency(description=docs.MAX_FILTER),
    'min_debts_owed_amount': Currency(description=docs.MIN_FILTER),
    'max_debts_owed_expenditures': Currency(description=docs.MAX_FILTER),
    'min_independent_expenditures': Currency(description=docs.MIN_FILTER),
    'max_independent_expenditures': Currency(description=docs.MAX_FILTER),
    'min_party_coordinated_expenditures': Currency(description=docs.MIN_FILTER),
    'max_party_coordinated_expenditures': Currency(description=docs.MAX_FILTER),
    'min_total_contributions': Currency(description=docs.MIN_FILTER),
    'max_total_contributions': Currency(description=docs.MAX_FILTER),
    'type': fields.List(fields.Str, description=docs.COMMITTEE_TYPE),
    'candidate_id': fields.Str(description=docs.CANDIDATE_ID),
    'committee_id': fields.List(fields.Str, description=docs.COMMITTEE_ID),
    'amendment_indicator': fields.List(
        IStr(validate=validate.OneOf(['', 'N', 'A', 'T', 'C', 'M', 'S'])),
        description=docs.AMENDMENT_INDICATOR,
    ),
}

committee_reports = {
    'year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'beginning_image_number': fields.List(
        fields.Str, description=docs.BEGINNING_IMAGE_NUMBER
    ),
    'report_type': fields.List(fields.Str, description=docs.REPORT_TYPE_W_EXCLUDE),
    'is_amended': fields.Bool(description='Report has been amended'),
    'min_disbursements_amount': Currency(description=docs.MIN_FILTER),
    'max_disbursements_amount': Currency(description=docs.MAX_FILTER),
    'min_receipts_amount': Currency(description=docs.MIN_FILTER),
    'max_receipts_amount': Currency(description=docs.MAX_FILTER),
    'min_cash_on_hand_end_period_amount': Currency(description=docs.MIN_FILTER),
    'max_cash_on_hand_end_period_amount': Currency(description=docs.MAX_FILTER),
    'min_debts_owed_amount': Currency(description=docs.MIN_FILTER),
    'max_debts_owed_expenditures': Currency(description=docs.MAX_FILTER),
    'min_independent_expenditures': Currency(description=docs.MIN_FILTER),
    'max_independent_expenditures': Currency(description=docs.MAX_FILTER),
    'min_party_coordinated_expenditures': Currency(description=docs.MIN_FILTER),
    'max_party_coordinated_expenditures': Currency(description=docs.MAX_FILTER),
    'min_total_contributions': Currency(description=docs.MIN_FILTER),
    'max_total_contributions': Currency(description=docs.MAX_FILTER),
    'type': fields.List(fields.Str, description=docs.COMMITTEE_TYPE),
    'candidate_id': fields.Str(description=docs.CANDIDATE_ID),
}

totals = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'type': fields.Str(description=docs.COMMITTEE_TYPE),
    'designation': fields.Str(description=docs.DESIGNATION),
}

totals_all = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_type_full': fields.Str(description=docs.COMMITTEE_TYPE),
    'committee_designation_full': fields.Str(description=docs.DESIGNATION),
    'committee_id': fields.Str(description=docs.COMMITTEE_ID),
}

candidate_committee_totals = {
    'full_election': fields.Bool(description='Get totals for full election period.')
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
    'line_number': fields.Str(
        description='Filter for form and line number using the following format: '
        '`FORM-LINENUMBER`.  For example an argument such as `F3X-16` would filter'
        ' down to all entries from form `F3X` line number `16`.'
    ),
}

reporting_dates = {
    'min_due_date': fields.Date(description='Date the report is due'),
    'max_due_date': fields.Date(description='Date the report is due'),
    'report_year': fields.List(fields.Int, description='Year of report'),
    'report_type': fields.List(fields.Str, description=docs.REPORT_TYPE),
    'min_create_date': fields.Date(
        description='Date this record was added to the system'
    ),
    'max_create_date': fields.Date(
        description='Date this record was added to the system'
    ),
    'min_update_date': fields.Date(description='Date this record was last updated'),
    'max_update_date': fields.Date(description='Date this record was last updated'),
}

election_dates = {
    'election_state': fields.List(
        fields.Str, description='State or territory of the office sought'
    ),
    'election_district': fields.List(
        fields.Str, description='House district of the office sought, if applicable.'
    ),
    'election_party': fields.List(fields.Str, description='Party, if applicable.'),
    'office_sought': fields.List(
        fields.Str(validate=validate.OneOf(['H', 'S', 'P'])),
        description='House, Senate or presidential office',
    ),
    'min_election_date': fields.Date(description='Date of election'),
    'max_election_date': fields.Date(description='Date of election'),
    'election_type_id': fields.List(fields.Str, description='Election type'),
    'min_update_date': fields.Date(description='Date this record was last updated'),
    'max_update_date': fields.Date(description='Date this record was last updated'),
    'min_create_date': fields.Date(
        description='Date this record was added to the system'
    ),
    'max_create_date': fields.Date(
        description='Date this record was added to the system'
    ),
    'election_year': fields.List(fields.Str, description='Year of election'),
    'min_primary_general_date': fields.Date(
        description='Date of primary or general election'
    ),
    'max_primary_general_date': fields.Date(
        description='Date of primary or general election'
    ),
}

calendar_dates = {
    'calendar_category_id': fields.List(fields.Int, description=docs.CATEGORY),
    'description': fields.List(IStr, description=docs.CAL_DESCRIPTION),
    'summary': fields.List(IStr, description=docs.SUMMARY),
    'min_start_date': fields.DateTime(description='The minimum start date and time'),
    'min_end_date': fields.DateTime(description='The minimum end date and time'),
    'max_start_date': fields.DateTime(description='The maximum start date and time'),
    'max_end_date': fields.DateTime(description='The maximum end date and time'),
    'event_id': fields.Int(description=docs.EVENT_ID),
}

schedule_a = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
    'contributor_name': fields.List(fields.Str, description=docs.CONTRIBUTOR_NAME),
    'contributor_city': fields.List(IStr, description=docs.CONTRIBUTOR_CITY),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'contributor_zip': fields.List(IStr, description=docs.CONTRIBUTOR_ZIP),
    'contributor_employer': fields.List(
        fields.Str, description=docs.CONTRIBUTOR_EMPLOYER
    ),
    'contributor_occupation': fields.List(
        fields.Str, description=docs.CONTRIBUTOR_OCCUPATION
    ),
    'last_contribution_receipt_date': fields.Date(
        missing=None,
        description='When sorting by `contribution_receipt_date`, this is populated with the `contribution_receipt_date` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'last_contribution_receipt_amount': fields.Float(
        missing=None,
        description='When sorting by `contribution_receipt_amount`, this is populated with the `contribution_receipt_amount` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'last_contributor_aggregate_ytd': fields.Float(
        missing=None,
        description='When sorting by `contributor_aggregate_ytd`, this is populated with the `contributor_aggregate_ytd` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'is_individual': fields.Bool(missing=None, description=docs.IS_INDIVIDUAL),
    'contributor_type': fields.List(
        fields.Str(validate=validate.OneOf(['individual', 'committee'])),
        description='Filters individual or committee contributions based on line number',
    ),
    'two_year_transaction_period': fields.Int(
        description=docs.TWO_YEAR_TRANSACTION_PERIOD,
        required=True,
        missing=SQL_CONFIG['CYCLE_END_YEAR_ITEMIZED'],
    ),
}

schedule_a_e_file = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    # 'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
    'contributor_name': fields.List(fields.Str, description=docs.CONTRIBUTOR_NAME),
    'contributor_city': fields.List(IStr, description=docs.CONTRIBUTOR_CITY),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'contributor_employer': fields.List(
        fields.Str, description=docs.CONTRIBUTOR_EMPLOYER
    ),
    'contributor_occupation': fields.List(
        fields.Str, description=docs.CONTRIBUTOR_OCCUPATION
    ),
}

schedule_a_by_size = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'size': fields.List(
        fields.Int(validate=validate.OneOf([0, 200, 500, 1000, 2000])),
        description=docs.SIZE,
    ),
}

schedule_a_by_state = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'state': fields.List(IStr, description='State of contributor'),
    'hide_null': fields.Bool(
        missing=False, description='Exclude values with missing state'
    ),
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
    'recipient_committee_id': fields.List(
        IStr,
        description='The FEC identifier should be represented here if the contributor is registered with the FEC.',
    ),
    'recipient_name': fields.List(fields.Str, description='Name of recipient'),
    'disbursement_description': fields.List(
        fields.Str, description='Description of disbursement'
    ),
    'recipient_city': fields.List(IStr, description='City of recipient'),
    'recipient_state': fields.List(IStr, description='State of recipient'),
    'disbursement_purpose_category': fields.List(
        IStr, description='Disbursement purpose category'
    ),
    'last_disbursement_date': fields.Date(
        missing=None,
        description='When sorting by `disbursement_date`, this is populated with the `disbursement_date` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'last_disbursement_amount': fields.Float(
        missing=None,
        description='When sorting by `disbursement_amount`, this is populated with the `disbursement_amount` of the last result.  However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'two_year_transaction_period': fields.Int(
        description=docs.TWO_YEAR_TRANSACTION_PERIOD,
        required=True,
        missing=SQL_CONFIG['CYCLE_END_YEAR_ITEMIZED'],
    ),
}

schedule_b_efile = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    # 'recipient_committee_id': fields.List(IStr, description='The FEC identifier should be represented here if the contributor is registered with the FEC.'),
    # 'recipient_name': fields.List(fields.Str, description='Name of recipient'),
    'disbursement_description': fields.List(
        fields.Str, description='Description of disbursement'
    ),
    'image_number': fields.List(
        fields.Str,
        description='The image number of the page where the schedule item is reported',
    ),
    'recipient_city': fields.List(IStr, description='City of recipient'),
    'recipient_state': fields.List(IStr, description='State of recipient'),
    'max_date': fields.Date(
        missing=None,
        description='When sorting by `disbursement_date`, this is populated with the `disbursement_date` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'min_date': fields.Date(
        missing=None,
        description='When sorting by `disbursement_date`, this is populated with the `disbursement_date` of the last result. However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'min_amount': Currency(description='Filter for all amounts less than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
}

schedule_b_by_purpose = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'purpose': fields.List(fields.Str, description='Disbursement purpose category'),
}

schedule_c = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_name': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'loaner_name': fields.List(fields.Str, description=docs.LOAN_SOURCE),
    'min_payment_to_date': fields.Int(description='Minimum payment to date'),
    'max_payment_to_date': fields.Int(description='Maximum payment to date'),
}

schedule_e_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
    'support_oppose': IStr(
        missing=None,
        validate=validate.OneOf(['S', 'O']),
        description='Support or opposition',
    ),
}
# These arguments will evolve with updated filtering needs
schedule_d = {
    'min_payment_period': fields.Float(),
    'max_payment_period': fields.Float(),
    'min_amount_incurred': fields.Float(),
    'max_amount_incurred': fields.Float(),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'creditor_debtor_name': fields.List(fields.Str),
    'nature_of_debt': fields.Str(),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_f = {
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'payee_name': fields.List(fields.Str),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
}

communication_cost = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])), description='Support or opposition'
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
    'description': fields.Str('Disbursement description'),
}

electioneering_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
}

elections_list = {
    'state': fields.List(IStr, description=docs.STATE),
    'district': fields.List(District, description=docs.DISTRICT),
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'zip': fields.List(fields.Int, description=docs.ZIP_CODE),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['house', 'senate', 'president']))
    ),
}

elections = {
    'state': IStr(description=docs.STATE),
    'district': District(description=docs.DISTRICT),
    'cycle': fields.Int(required=True, description=docs.CANDIDATE_CYCLE),
    'office': fields.Str(
        required=True,
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
    'election_full': election_full,
}

state_election_office_info = {
    'state': IStr(required=True, description=docs.STATE_ELECTION_OFFICES_ADDRESS)
}

schedule_a_candidate_aggregate = {
    'candidate_id': fields.List(IStr, required=True, description=docs.CANDIDATE_ID),
    'cycle': fields.List(fields.Int, required=True, description=docs.RECORD_CYCLE),
    'election_full': election_full,
}

candidate_totals = {
    'q': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'election_year': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'office': fields.List(
        fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])),
        description='Governmental office candidate runs for: House, Senate or presidential',
    ),
    'election_full': election_full,
    'state': fields.List(IStr, description='State of candidate'),
    'district': fields.List(District, description='District of candidate'),
    'party': fields.List(IStr, description='Three-letter party code'),
    'min_receipts': Currency(description='Minimum aggregated receipts'),
    'max_receipts': Currency(description='Maximum aggregated receipts'),
    'min_disbursements': Currency(description='Minimum aggregated disbursements'),
    'max_disbursements': Currency(description='Maximum aggregated disbursements'),
    'min_cash_on_hand_end_period': Currency(description='Minimum cash on hand'),
    'max_cash_on_hand_end_period': Currency(description='Maximum cash on hand'),
    'min_debts_owed_by_committee': Currency(description='Minimum debt'),
    'max_debts_owed_by_committee': Currency(description='Maximum debt'),
    'federal_funds_flag': fields.Bool(description=docs.FEDERAL_FUNDS_FLAG),
    'has_raised_funds': fields.Bool(description=docs.HAS_RAISED_FUNDS),
}

totals_committee_aggregate = {
    'min_receipts': Currency(description='Minimum aggregated receipts'),
    'max_receipts': Currency(description='Maximum aggregated receipts'),
    'min_disbursements': Currency(description='Minimum aggregated disbursements'),
    'max_disbursements': Currency(description='Maximum aggregated disbursements'),
}

communication_cost_by_candidate = {
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
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
    'candidate_office': fields.List(
        fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])),
        description=docs.OFFICE,
    ),
    'candidate_party': fields.List(IStr, description=docs.PARTY),
    'candidate_office_state': fields.List(IStr, description=docs.STATE_GENERIC),
    'candidate_office_district': fields.List(District, description=docs.DISTRICT),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'filing_form': fields.List(IStr, description='Filing form'),
    'last_expenditure_date': fields.Date(
        missing=None,
        description='When sorting by `expenditure_date`,'
        'this is populated with the `expenditure_date` of the last result.'
        'However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'last_expenditure_amount': fields.Float(
        missing=None,
        description='When sorting by `expenditure_amount`,'
        'this is populated with the `expenditure_amount` of the last result.'
        'However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'last_office_total_ytd': fields.Float(
        missing=None,
        description='When sorting by `office_total_ytd`,'
        'this is populated with the `office_total_ytd` of the last result.'
        'However, you will need to pass the index of that last result to `last_index` to get the next page.',
    ),
    'payee_name': fields.List(
        fields.Str, description='Name of the entity that received the payment'
    ),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])), description='Support or opposition'
    ),
    'is_notice': fields.List(
        fields.Bool, description='Record filed as 24- or 48-hour notice'
    ),
}

schedule_e_efile = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'payee_name': fields.List(
        fields.Str, description='Name of the entity that received the payment'
    ),
    'candidate_name': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'image_number': fields.List(
        fields.Str,
        description='The image number of the page where the schedule item is reported',
    ),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])), description='Support or opposition'
    ),
    'min_expenditure_date': fields.Date(description=docs.EXPENDITURE_MAX_DATE),
    'max_expenditure_date': fields.Date(description=docs.EXPENDITURE_MIN_DATE),
    'min_expenditure_amount': fields.Date(description=docs.EXPENDITURE_MIN_AMOUNT),
    'max_expenditure_amount': fields.Date(description=docs.EXPENDITURE_MAX_AMOUNT),
}

rad_analyst = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'analyst_id': fields.List(fields.Int(), description='ID of RAD analyst'),
    'analyst_short_id': fields.List(
        fields.Int(), description='Short ID of RAD analyst'
    ),
    'telephone_ext': fields.List(
        fields.Int(), description='Telephone extension of RAD analyst'
    ),
    'name': fields.List(fields.Str, description='Name of RAD analyst'),
    'email': fields.List(fields.Str, description='Email of RAD analyst'),
    'title': fields.List(fields.Str, description='Title of RAD analyst'),
    'min_assignment_update_date': fields.Date(
        description='Filter results for assignment updates made after this date'
    ),
    'max_assignment_update_date': fields.Date(
        description='Filter results for assignment updates made before this date'
    ),
}

large_aggregates = {'cycle': fields.Int(required=True, description=docs.RECORD_CYCLE)}

schedule_a_by_state_recipient_totals = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'state': fields.List(IStr, description=docs.STATE_GENERIC),
    'committee_type': fields.List(
        IStr, description=docs.COMMITTEE_TYPE_STATE_AGGREGATE_TOTALS
    ),
}


# endpoint audit-primary-category
auditPrimaryCategory = {
    'primary_category_id': fields.List(
        fields.Str(), description=docs.PRIMARY_CATEGORY_ID
    ),
    'primary_category_name': fields.List(
        fields.Str, description=docs.PRIMARY_CATEGORY_NAME
    ),
}


# endpoint audit-category
auditCategory = {
    'primary_category_id': fields.List(
        fields.Str(), description=docs.PRIMARY_CATEGORY_ID
    ),
    'primary_category_name': fields.List(
        fields.Str, description=docs.PRIMARY_CATEGORY_NAME
    ),
}

# endpoint audit-case
auditCase = {
    'q': fields.List(fields.Str, description=docs.COMMITTEE_NAME),
    'qq': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'primary_category_id': fields.Str(
        missing='all', description=docs.PRIMARY_CATEGORY_ID
    ),
    'sub_category_id': fields.Str(missing='all', description=docs.SUB_CATEGORY_ID),
    'audit_case_id': fields.List(fields.Str(), description=docs.AUDIT_CASE_ID),
    'cycle': fields.List(fields.Int(), description=docs.CYCLE),
    'committee_id': fields.List(fields.Str(), description=docs.COMMITTEE_ID),
    'committee_type': fields.List(fields.Str(), description=docs.COMMITTEE_TYPE),
    'committee_designation': fields.Str(description=docs.COMMITTEE_DESCRIPTION),
    'audit_id': fields.List(fields.Int(), description=docs.AUDIT_ID),
    'candidate_id': fields.List(fields.Str(), description=docs.CANDIDATE_ID),
    'min_election_cycle': fields.Int(description=docs.CYCLE),
    'max_election_cycle': fields.Int(description=docs.CYCLE),
}

operations_log = {
    'candidate_committee_id': fields.List(IStr, description=docs.CAND_CMTE_ID),
    'report_type': fields.List(IStr, description=docs.REPORT_TYPE),
    'beginning_image_number': fields.List(
        fields.Str, description=docs.BEGINNING_IMAGE_NUMBER
    ),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'form_type': fields.List(IStr, description=docs.FORM_TYPE),
    'amendment_indicator': fields.List(IStr, description=docs.AMENDMENT_INDICATOR),
    'status_num': fields.List(
        fields.Str(validate=validate.OneOf(['0', '1'])), description=docs.STATUS_NUM
    ),
}
