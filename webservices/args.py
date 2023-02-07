import functools
import sqlalchemy as sa

from marshmallow.compat import text_type
from webargs import fields, validate

from webservices import docs
from webservices import exceptions
from webservices.common.models import db


def _validate_natural(value):
    if value <= 0:
        raise exceptions.ApiError(
            'Must be greater than zero',
            status_code=422
        )


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
            raise exceptions.ApiError(
                'District must be a number',
                status_code=422)
        if value < 0:
            raise exceptions.ApiError(
                'District must be a natural number',
                status_code=422)

    def _deserialize(self, value, attr, data):
        return '{0:0>2}'.format(value)


class ImageNumber(fields.Str):

    def _validate(self, value):
        super()._validate(value)
        try:
            value = int(value)
        except (TypeError, ValueError):
            raise exceptions.ApiError(
                exceptions.IMAGE_NUMBER_ERROR,
                status_code=422)
        if value < 0:
            raise exceptions.ApiError(
                exceptions.IMAGE_NUMBER_ERROR,
                status_code=422)


class Keyword(fields.Str):

    def _validate(self, value):
        VALID_KEYWORD_LENGTH = 3
        super()._validate(value)
        if len(value) < VALID_KEYWORD_LENGTH:  # noqa
            raise exceptions.ApiError(
                exceptions.KEYWORD_LENGTH_ERROR,
                status_code=422,
            )


election_full = fields.Bool(missing=True, description=docs.ELECTION_FULL)

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
            raise exceptions.ApiError(
                'Cannot sort on value "{0}". Instead choose one of: "{1}"'.format(
                    value, '", "'.join(self.values)
                ),
                status_code=422,
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
            column.key: label
            for label, column in self.model.__mapper__.columns.items()
        }
        return [
            column_map[column['column_names'][0]]
            for column in inspector.get_indexes(
                self.model.__tablename__,
                self.model.__table__.schema,
            )
            if not self._is_excluded(column_map.get(column['column_names'][0]))
        ] + self.extra

    def _is_excluded(self, value):
        return not value or value in self.exclude


class IndicesValidator(IndexValidator):

    def __call__(self, value):
        for sort_column in value:
            if sort_column.lstrip('-') not in self.values:
                raise exceptions.ApiError(
                    'Cannot sort on value "{0}"'.format(sort_column),
                    status_code=422,
                )


def make_sort_args(default=None, validator=None, default_hide_null=False,
        default_nulls_only=False, default_sort_nulls_last=False, show_nulls_last_arg=True,
        additional_description=''):
    args = {
        'sort': fields.Str(
            missing=default,
            validate=validator,
            description='Provide a field to sort by. Use `-` for descending order.\n{}'.format(
                additional_description
            ),
        ),
        'sort_hide_null': fields.Bool(
            missing=default_hide_null,
            description='Hide null values on sorted column(s).'
        ),
        'sort_null_only': fields.Bool(
            missing=default_nulls_only,
            description='Toggle that filters out all rows having sort column that is non-null'
        ),

    }
    if show_nulls_last_arg:
        args['sort_nulls_last'] = fields.Bool(
            missing=default_sort_nulls_last,
            description='Toggle that sorts null values last'
        )
    return args


def make_multi_sort_args(default=None, validator=None, default_hide_null=False,
        default_nulls_only=False, default_sort_nulls_last=False):
    args = make_sort_args(default, validator, default_hide_null, default_nulls_only, default_sort_nulls_last)
    args['sort'] = fields.List(fields.Str, missing=default, validate=validator, required=False, allow_none=True,
        description=docs.SORT)
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
    'q': fields.List(fields.Str, required=True, description='Name (candidate or committee) to search for'),
}


# for endpoint: /legal/search/ (resources/legal.py/UniversalSearch)
legal_universal_search = {
    'q': fields.Str(required=False, description=docs.TEXT_SEARCH),
    'from_hit': fields.Int(required=False, description=docs.FROM_HIT),
    'hits_returned': fields.Int(required=False, description=docs.HITS_RETURNED),
    'type': fields.Str(required=False, description=docs.LEGAL_DOC_TYPE),

    'ao_no': fields.List(IStr, required=False, description=docs.AO_NUMBER),
    'ao_name': fields.List(IStr, required=False, description=docs.AO_NAME),
    'ao_min_issue_date': fields.Date(description=docs.AO_MIN_ISSUE_DATE),
    'ao_max_issue_date': fields.Date(description=docs.AO_MAX_ISSUE_DATE),
    'ao_min_request_date': fields.Date(description=docs.AO_MIN_REQUEST_DATE),
    'ao_max_request_date': fields.Date(description=docs.AO_MAX_REQUEST_DATE),
    'ao_category': fields.List(IStr(validate=validate.OneOf(['F', 'V', 'D', 'R', 'W', 'C', 'S'])),
                                    description=docs.AO_CATEGORY),
    'ao_is_pending': fields.Bool(description=docs.AO_IS_PENDING),
    'ao_status': fields.Str(description=docs.AO_STATUS),
    'ao_requestor': fields.Str(description=docs.AO_REQUESTOR),
    'ao_requestor_type': fields.List(fields.Integer(validate=validate.OneOf(range(1, 17))),
                                            description=docs.AO_REQUESTOR_TYPE),
    'ao_regulatory_citation': fields.List(IStr, required=False, description=docs.REGULATORY_CITATION),
    'ao_statutory_citation': fields.List(IStr, required=False, description=docs.STATUTORY_CITATION),
    'ao_citation_require_all': fields.Bool(description=docs.CITATION_REQUIRE_ALL),
    'ao_entity_name': fields.List(IStr, required=False, description=docs.AO_ENTITY_NAME),

    'case_no': fields.List(IStr, required=False, description=docs.CASE_NO),
    'case_respondents': fields.Str(IStr, required=False, description=docs.CASE_RESPONDONTS),
    'case_dispositions': fields.List(IStr, required=False, description=docs.CASE_DISPOSTIONS),
    'case_election_cycles': fields.Int(IStr, required=False, description=docs.CASE_ELECTION_CYCLES),
    'case_min_open_date': fields.Date(required=False, description=docs.CASE_MIN_OPEN_DATE),
    'case_max_open_date': fields.Date(required=False, description=docs.CASE_MAX_OPEN_DATE),
    'case_min_close_date': fields.Date(required=False, description=docs.CASE_MIN_CLOSE_DATE),
    'case_max_close_date': fields.Date(required=False, description=docs.CASE_MAX_CLOSE_DATE),
    'case_regulatory_citation': fields.List(IStr, required=False, description=docs.REGULATORY_CITATION),
    'case_statutory_citation': fields.List(IStr, required=False, description=docs.STATUTORY_CITATION),
    'case_citation_require_all': fields.Bool(description=docs.CITATION_REQUIRE_ALL),

    # case_doc_category_id is the key of case_document_category
    'case_doc_category_id': fields.List(IStr(validate=validate.OneOf(['1', '2', '3', '4', '5', '6'])),
                                    description=docs.CASE_DOCUMENT_CATEGORY_DESCRIPTION),

    'mur_type': fields.Str(required=False, description=docs.MUR_TYPE),

    'af_name': fields.List(IStr, required=False, description=docs.AF_NAME),
    'af_committee_id': fields.Str(IStr, required=False, description=docs.AF_COMMITTEE_ID),
    'af_report_year': fields.Str(IStr, required=False, description=docs.AF_REPORT_YEAR),
    'af_min_rtb_date': fields.Date(required=False, description=docs.AF_MIN_RTB_DATE),
    'af_max_rtb_date': fields.Date(required=False, description=docs.AF_MAX_RTB_DATE),
    'af_rtb_fine_amount': fields.Int(IStr, required=False, description=docs.AF_RTB_FINE_AMOUNT),
    'af_min_fd_date': fields.Date(required=False, description=docs.AF_MIN_FD_DATE),
    'af_max_fd_date': fields.Date(required=False, description=docs.AF_MAX_FD_DATE),
    'af_fd_fine_amount': fields.Int(IStr, required=False, description=docs.AF_FD_FINE_AMOUNT),
    'sort':fields.Str(IStr, required=False, description=docs.SORT),
}

candidate_detail = {
    'cycle': fields.List(fields.Int, description=docs.CANDIDATE_CYCLE),
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
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
    'federal_funds_flag': fields.Bool(description=docs.FEDERAL_FUNDS_FLAG),
    'has_raised_funds': fields.Bool(description=docs.HAS_RAISED_FUNDS),
    'name': fields.List(fields.Str, description='Name (candidate or committee) to search for. Alias for \'q\'.'),
}

candidate_list = {
    'q': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'min_first_file_date': fields.Date(description=docs.CANDIDATE_MIN_FIRST_FILE_DATE),
    'max_first_file_date': fields.Date(description=docs.CANDIDATE_MAX_FIRST_FILE_DATE),
    'is_active_candidate': fields.Bool(description=docs.ACTIVE_CANDIDATE),
}

candidate_history = {
    'election_full': election_full,
}

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
        IStr(validate=validate.OneOf([
            '', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q',
            'S', 'U', 'V', 'W', 'X', 'Y', 'Z'])),
        description=docs.COMMITTEE_TYPE,
    ),
}

committee_list = {
    'q': fields.List(fields.Str, description=docs.COMMITTEE_NAME),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'state': fields.List(IStr, description=docs.STATE_GENERIC),
    'party': fields.List(IStr, description=docs.PARTY),
    'min_first_file_date': fields.Date(description=docs.MIN_FIRST_FILE_DATE),
    'max_first_file_date': fields.Date(description=docs.MAX_FIRST_FILE_DATE),
    'min_first_f1_date': fields.Date(description=docs.MIN_FIRST_F1_DATE),
    'max_first_f1_date': fields.Date(description=docs.MAX_FIRST_F1_DATE),
    'min_last_f1_date': fields.Date(description=docs.MIN_LAST_F1_DATE),
    'max_last_f1_date': fields.Date(description=docs.MAX_LAST_F1_DATE),
    'treasurer_name': fields.List(fields.Str, description=docs.TREASURER_NAME),
    'sponsor_candidate_id': fields.List(IStr, description=docs.SPONSOR_CANDIDATE_ID),
}


committee_history = {
    'election_full': election_full,
    'designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description=docs.DESIGNATION,
    ),
}

filings = {
    'committee_type': fields.Str(description=docs.COMMITTEE_TYPE),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'is_amended': fields.Bool(description=docs.IS_AMENDED),
    'most_recent': fields.Bool(description=docs.MOST_RECENT),
    'report_type': fields.List(IStr, description=docs.REPORT_TYPE),
    'request_type': fields.List(IStr, description=docs.REQUEST_TYPE),
    'document_type': fields.List(IStr, description=docs.DOC_TYPE),
    'beginning_image_number': fields.List(ImageNumber, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'min_receipt_date': fields.Date(description=docs.MIN_RECEIPT_DATE),
    'max_receipt_date': fields.Date(description=docs.MAX_RECEIPT_DATE),
    'form_type': fields.List(IStr, description=docs.FORM_TYPE),
    'state': fields.List(IStr, description=docs.STATE),
    'district': fields.List(IStr, description=docs.DISTRICT),
    'office': fields.List(fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])), description=docs.OFFICE),
    'party': fields.List(IStr, description=docs.PARTY),
    'filer_type': fields.Str(
        validate=validate.OneOf(['e-file', 'paper']),
        description=docs.MEANS_FILED,
    ),
    'file_number': fields.List(fields.Int, description=docs.FILE_NUMBER),
    'primary_general_indicator': fields.List(IStr, description=docs.PRIMARY_GENERAL_INDICTOR),
    'amendment_indicator': fields.List(
        IStr(validate=validate.OneOf(['', 'N', 'A', 'T', 'C', 'M', 'S'])),
        description=docs.AMENDMENT_INDICATOR),
    'form_category': fields.List(IStr, description=docs.FORM_CATEGORY),
    'q_filer': fields.List(Keyword, description=docs.FILER_NAME_TEXT),
}

efilings = {
    'file_number': fields.List(fields.Int, description=docs.FILE_NUMBER),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'min_receipt_date': fields.Date(description=docs.MIN_RECEIPT_DATE),
    'max_receipt_date': fields.Date(description=docs.MAX_RECEIPT_DATE),
    'q_filer': fields.List(Keyword, description=docs.FILER_NAME_TEXT),
}

reports = {
    'year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'beginning_image_number': fields.List(ImageNumber, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_type': fields.List(fields.Str, description=docs.BASE_REPORT_TYPE_W_EXCLUDE),
    'is_amended': fields.Bool(description=docs.IS_AMENDED),
    'most_recent': fields.Bool(description=docs.MOST_RECENT),
    'filer_type': fields.Str(
        validate=validate.OneOf(['e-file', 'paper']),
        description=docs.MEANS_FILED,
    ),
    'min_disbursements_amount': Currency(description=docs.MIN_FILTER),
    'max_disbursements_amount': Currency(description=docs.MAX_FILTER),
    'min_receipts_amount': Currency(description=docs.MIN_FILTER),
    'max_receipts_amount': Currency(description=docs.MAX_FILTER),
    'max_receipt_date': fields.Date(description=docs.MAX_REPORT_RECEIPT_DATE),
    'min_receipt_date': fields.Date(description=docs.MIN_REPORT_RECEIPT_DATE),
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
    'committee_type': fields.List(fields.Str, description=docs.COMMITTEE_TYPE),
    'candidate_id': fields.Str(description=docs.CANDIDATE_ID),
    'committee_id': fields.List(fields.Str, description=docs.COMMITTEE_ID),
    'amendment_indicator': fields.List(
        IStr(validate=validate.OneOf(['', 'N', 'A', 'T', 'C', 'M', 'S'])),
        description=docs.AMENDMENT_INDICATOR),
    'q_filer': fields.List(Keyword, description=docs.FILER_NAME_TEXT),
    'q_spender': fields.List(Keyword, description=docs.SPENDER_NAME_TEXT),
}

committee_reports = {
    'year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'beginning_image_number': fields.List(ImageNumber, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_type': fields.List(fields.Str, description=docs.BASE_REPORT_TYPE_W_EXCLUDE),
    'is_amended': fields.Bool(description=docs.IS_AMENDED),
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

committee_totals = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
}

totals_by_entity_type = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_designation': fields.List(fields.Str, description=docs.DESIGNATION),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'committee_type': fields.List(fields.Str, description=docs.COMMITTEE_TYPE),
    'committee_state': fields.List(IStr, description=docs.STATE_GENERIC),
    'filing_frequency': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'M', 'N', 'Q', 'T', 'W', '-A', '-T'])),
        description=docs.FILING_FREQUENCY,
    ),
    'treasurer_name': fields.List(fields.Str, description=docs.TREASURER_NAME),
    'min_disbursements': Currency(description=docs.MIN_FILTER),
    'max_disbursements': Currency(description=docs.MAX_FILTER),
    'min_receipts': Currency(description=docs.MIN_FILTER),
    'max_receipts': Currency(description=docs.MAX_FILTER),
    'min_last_cash_on_hand_end_period': Currency(description=docs.MIN_FILTER),
    'max_last_cash_on_hand_end_period': Currency(description=docs.MAX_FILTER),
    'min_last_debts_owed_by_committee': Currency(description=docs.MIN_FILTER),
    'max_last_debts_owed_by_committee': Currency(description=docs.MAX_FILTER),
    'sponsor_candidate_id': fields.List(IStr, description=docs.SPONSOR_CANDIDATE_ID),
    'organization_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description=docs.ORGANIZATION_TYPE,
    ),
    'min_first_f1_date': fields.Date(description=docs.MIN_FIRST_F1_DATE),
    'max_first_f1_date': fields.Date(description=docs.MAX_FIRST_F1_DATE),
}

candidate_totals_detail = {
    # no default value for election_full
    'election_full': fields.Bool(description=docs.ELECTION_FULL),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
}


itemized = {
    'image_number': fields.List(ImageNumber, description=docs.IMAGE_NUMBER),
    'min_image_number': ImageNumber(description=docs.MIN_IMAGE_NUMBER),
    'max_image_number': ImageNumber(description=docs.MAX_IMAGE_NUMBER),
    'min_amount': Currency(description='Filter for all amounts greater than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
    'min_date': fields.Date(description='Minimum date'),
    'max_date': fields.Date(description='Maximum date'),
    'line_number': fields.Str(description='Filter for form and line number using the following format: '
                                          '`FORM-LINENUMBER`.  For example an argument such as `F3X-16` would filter'
                                          ' down to all entries from form `F3X` line number `16`.')
}


# ====tag:dates -- endpoints [start]========
calendar_dates = {
    'calendar_category_id': fields.List(fields.Int, description=docs.CATEGORY),
    'description': fields.List(IStr, description=docs.CAL_DESCRIPTION),
    'summary': fields.List(IStr, description=docs.SUMMARY),
    'min_start_date': fields.Date(description=docs.MIN_START_DATE),
    'min_end_date': fields.Date(description=docs.MIN_END_DATE),
    'max_start_date': fields.Date(description=docs.MAX_START_DATE),
    'max_end_date': fields.Date(description=docs.MAX_END_DATE),
    'event_id': fields.Int(description=docs.EVENT_ID),
}

election_dates = {
    'election_state': fields.List(fields.Str, description=docs.ELECTION_STATE),
    'election_district': fields.List(fields.Str, description=docs.ELECTION_DISTRICT),
    'election_party': fields.List(fields.Str, description=docs.ELECTION_PARTY),
    'office_sought': fields.List(fields.Str(validate=validate.OneOf(['H', 'S', 'P'])), description=docs.OFFICE_SOUGHT),
    'min_election_date': fields.Date(description=docs.MIN_ELECTION_DATE),
    'max_election_date': fields.Date(description=docs.MAX_ELECTION_DATE),
    'election_type_id': fields.List(fields.Str, description=docs.ELECTION_TYPE_ID),
    'min_create_date': fields.Date(description=docs.MIN_CREATE_DATE),
    'max_create_date': fields.Date(description=docs.MAX_CREATE_DATE),
    'min_update_date': fields.Date(description=docs.MIN_UPDATE_DATE),
    'max_update_date': fields.Date(description=docs.MAX_UPDATE_DATE),
    'election_year': fields.List(fields.Str, description=docs.ELECTION_YEAR),
    'min_primary_general_date': fields.Date(description=docs.MIN_PRIMARY_GENERAL_DATE),
    'max_primary_general_date': fields.Date(description=docs.MAX_PRIMARY_GENERAL_DATE),
}

reporting_dates = {
    'min_due_date': fields.Date(description=docs.MIN_DUE_DATE),
    'max_due_date': fields.Date(description=docs.MAX_DUE_DATE),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'report_type': fields.List(fields.Str, description=docs.REPORT_TYPE),
    'min_create_date': fields.Date(description=docs.MIN_CREATE_DATE),
    'max_create_date': fields.Date(description=docs.MAX_CREATE_DATE),
    'min_update_date': fields.Date(description=docs.MIN_UPDATE_DATE),
    'max_update_date': fields.Date(description=docs.MAX_UPDATE_DATE),
}
# ====tag:dates -- endpoints [end]========

schedule_a = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
    'contributor_name': fields.List(fields.Str, description=docs.CONTRIBUTOR_NAME),
    'contributor_city': fields.List(IStr, description=docs.CONTRIBUTOR_CITY),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'contributor_zip': fields.List(IStr, description=docs.CONTRIBUTOR_ZIP),
    'contributor_employer': fields.List(fields.Str, description=docs.CONTRIBUTOR_EMPLOYER),
    'contributor_occupation': fields.List(fields.Str, description=docs.CONTRIBUTOR_OCCUPATION),
    'last_contribution_receipt_date': fields.Date(
        missing=None,
        description='When sorting by `contribution_receipt_date`, this is populated with the \
        `contribution_receipt_date` of the last result. However, you will need to pass the index \
        of that last result to `last_index` to get the next page.'
    ),
    'last_contribution_receipt_amount': fields.Float(
        missing=None,
        description='When sorting by `contribution_receipt_amount`, this is populated with the \
        `contribution_receipt_amount` of the last result. However, you will need to pass the index \
        of that last result to `last_index` to get the next page.'
    ),
    'is_individual': fields.Bool(missing=None, description=docs.IS_INDIVIDUAL),
    'contributor_type': fields.List(
        fields.Str(validate=validate.OneOf(['individual', 'committee'])),
        description='Filters individual or committee contributions based on line number'
    ),
    'two_year_transaction_period': fields.List(
        fields.Int,
        description=docs.TWO_YEAR_TRANSACTION_PERIOD,
    ),
    'recipient_committee_type': fields.List(
        IStr(validate=validate.OneOf([
            '', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q',
            'S', 'U', 'V', 'W', 'X', 'Y', 'Z'])),
        description=docs.COMMITTEE_TYPE,
    ),
    'recipient_committee_org_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description=docs.ORGANIZATION_TYPE,
    ),
    'recipient_committee_designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description=docs.DESIGNATION,
    ),
    'min_load_date': fields.Date(description=docs.MIN_LOAD_DATE),
    'max_load_date': fields.Date(description=docs.MAX_LOAD_DATE),
}

schedule_a_e_file = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    # 'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
    'contributor_name': fields.List(fields.Str, description=docs.CONTRIBUTOR_NAME),
    'contributor_city': fields.List(IStr, description=docs.CONTRIBUTOR_CITY),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'contributor_employer': fields.List(fields.Str, description=docs.CONTRIBUTOR_EMPLOYER),
    'contributor_occupation': fields.List(fields.Str, description=docs.CONTRIBUTOR_OCCUPATION),

}

schedule_a_by_size = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'size': fields.List(fields.Int(validate=validate.OneOf([0, 200, 500, 1000, 2000])), description=docs.SIZE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_a_by_state = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'hide_null': fields.Bool(missing=False, description=docs.MISSING_STATE),
}

schedule_a_by_zip = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'zip': fields.List(fields.Str, description=docs.CONTRIBUTOR_ZIP),
    'state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_a_by_employer = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'employer': fields.List(IStr, description=docs.EMPLOYER),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_a_by_occupation = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'occupation': fields.List(IStr, description=docs.OCCUPATION),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_a_by_contributor = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'contributor_id': fields.List(IStr, description=docs.CONTRIBUTOR_ID),
}

schedule_b_by_purpose = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'purpose': fields.List(fields.Str, description=docs.DISBURSEMENT_PURPOSE_CATEGORY),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_b_by_recipient = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_name': fields.List(fields.Str, description=docs.RECIPIENT_NAME),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_b_by_recipient_id = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'recipient_id': fields.List(IStr, description=docs.RECIPIENT_ID),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

schedule_b = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'disbursement_description': fields.List(fields.Str, description=docs.DISBURSEMENT_DESCRIPTION),
    'disbursement_purpose_category': fields.List(IStr, description=docs.DISBURSEMENT_PURPOSE_CATEGORY),
    'last_disbursement_amount': fields.Float(missing=None, description=docs.LAST_DISBURSEMENT_AMOUNT),
    'last_disbursement_date': fields.Date(missing=None, description=docs.LAST_DISBURSEMENT_DATE),
    'recipient_city': fields.List(IStr, description=docs.RECIPIENT_CITY),
    'recipient_committee_id': fields.List(IStr, description=docs.RECIPIENT_COMMITTEE_ID),
    'recipient_name': fields.List(fields.Str, description=docs.RECIPIENT_NAME),
    'recipient_state': fields.List(IStr, description=docs.RECIPIENT_STATE),
    'spender_committee_designation': fields.List(
        IStr(validate=validate.OneOf(['', 'A', 'J', 'P', 'U', 'B', 'D'])),
        description=docs.DESIGNATION,
    ),
    'spender_committee_org_type': fields.List(
        IStr(validate=validate.OneOf(['', 'C', 'L', 'M', 'T', 'V', 'W'])),
        description=docs.ORGANIZATION_TYPE,
    ),
    'spender_committee_type': fields.List(
        IStr(validate=validate.OneOf([
            '', 'C', 'D', 'E', 'H', 'I', 'N', 'O', 'P', 'Q',
            'S', 'U', 'V', 'W', 'X', 'Y', 'Z'])),
        description=docs.COMMITTEE_TYPE,
    ),
    'two_year_transaction_period': fields.List(
        fields.Int,
        description=docs.TWO_YEAR_TRANSACTION_PERIOD,
    ),
}

schedule_b_efile = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    # 'recipient_committee_id': fields.List(IStr, description='The FEC identifier should be represented here
    # if the contributor is registered with the FEC.'),
    # 'recipient_name': fields.List(fields.Str, description='Name of recipient'),
    'disbursement_description': fields.List(fields.Str, description='Description of disbursement'),
    'image_number': fields.List(ImageNumber, description=docs.IMAGE_NUMBER),
    'recipient_city': fields.List(IStr, description='City of recipient'),
    'recipient_state': fields.List(IStr, description='State of recipient'),
    'max_date': fields.Date(
        missing=None,
        description='When sorting by `disbursement_date`, this is populated with the \
        `disbursement_date` of the last result. However, you will need to pass the index \
        of that last result to `last_index` to get the next page.'
    ),
    'min_date': fields.Date(
        missing=None,
        description='When sorting by `disbursement_date`, this is populated with the \
        `disbursement_date` of the last result. However, you will need to pass the index \
        of that last result to `last_index` to get the next page.'
    ),
    'min_amount': Currency(description='Filter for all amounts less than a value.'),
    'max_amount': Currency(description='Filter for all amounts less than a value.'),
}


schedule_c = {
    # TODO(jmcarp) Request integer image numbers from FEC and update argument types
    'image_number': fields.List(ImageNumber, description=docs.IMAGE_NUMBER),
    'min_image_number': ImageNumber(description=docs.MIN_IMAGE_NUMBER),
    'max_image_number': ImageNumber(description=docs.MAX_IMAGE_NUMBER),
    'min_amount': Currency(description=docs.MIN_FILTER),
    'max_amount': Currency(description=docs.MAX_FILTER),
    'line_number': fields.Str(description=docs.LINE_NUMBER),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_name': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'loan_source_name': fields.List(fields.Str, description=docs.LOAN_SOURCE),
    'min_payment_to_date': fields.Int(description=docs.MIN_PAYMENT_DATE),
    'max_payment_to_date': fields.Int(description=docs.MAX_PAYMENT_DATE),
    'min_incurred_date': fields.Date(missing=None, description=docs.MIN_INCURRED_DATE),
    'max_incurred_date': fields.Date(missing=None, description=docs.MAX_INCURRED_DATE),
}

schedule_d = {
    'image_number': fields.List(ImageNumber, description=docs.IMAGE_NUMBER),
    'min_image_number': ImageNumber(description=docs.MIN_IMAGE_NUMBER),
    'max_image_number': ImageNumber(description=docs.MAX_IMAGE_NUMBER),
    'min_date': fields.Date(description='Minimum load date'),
    'max_date': fields.Date(description='Maximum load date'),
    'min_payment_period': fields.Float(),
    'max_payment_period': fields.Float(),
    'min_amount_incurred': fields.Float(),
    'max_amount_incurred': fields.Float(),
    'min_amount_outstanding_beginning': fields.Float(),
    'max_amount_outstanding_beginning': fields.Float(),
    'min_amount_outstanding_close': fields.Float(),
    'max_amount_outstanding_close': fields.Float(),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'creditor_debtor_name': fields.List(fields.Str),
    'nature_of_debt': fields.Str(),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}
schedule_e_by_candidate = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'office': fields.Str(
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
    'support_oppose': IStr(
        missing=None,
        validate=validate.OneOf(['S', 'O']),
        description=docs.SUPPORT_OPPOSE,
    ),
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
        IStr(validate=validate.OneOf(['S', 'O'])),
        description=docs.SUPPORT_OPPOSE,
    ),
}

CC_aggregates = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'support_oppose_indicator': IStr(
        missing=None,
        validate=validate.OneOf(['S', 'O']),
        description=docs.SUPPORT_OPPOSE,
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

EC_aggregates = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
}

elections_list = {
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
    'cycle': fields.Int(required=True, description=docs.CANDIDATE_CYCLE),
    'office': fields.Str(
        required=True,
        validate=validate.OneOf(['house', 'senate', 'president']),
        description=docs.OFFICE,
    ),
    'election_full': election_full,
}

state_election_office_info = {
    'state': IStr(required=True, description=docs.STATE_ELECTION_OFFICES_ADDRESS),
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
    'office': fields.List(fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])), description=docs.OFFICE),
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
    'is_active_candidate': fields.Bool(description=docs.ACTIVE_CANDIDATE),
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
    'candidate_office': fields.List(fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P'])),
        description=docs.OFFICE),
    'candidate_party': fields.List(IStr, description=docs.PARTY),
    'candidate_office_state': fields.List(IStr, description=docs.STATE_GENERIC),
    'candidate_office_district': fields.List(District, description=docs.DISTRICT),
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'filing_form': fields.List(IStr, description=docs.FORM_TYPE),
    'last_expenditure_date': fields.Date(missing=None,
        description=docs.LAST_EXPENDITURE_DATE),
    'last_expenditure_amount': fields.Float(missing=None,
        description=docs.LAST_EXPENDITURE_AMOUNT),
    'last_office_total_ytd': fields.Float(missing=None,
        description=docs.LAST_OFFICE_TOTAL_YTD),
    'payee_name': fields.List(fields.Str, description=docs.PAYEE_NAME),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])),
        description=docs.SUPPORT_OPPOSE_INDICATOR),
    'last_support_oppose_indicator': fields.Str(missing=None,
        description=docs.LAST_SUPPOSE_OPPOSE_INDICATOR),
    'is_notice': fields.List(fields.Bool, description=docs.IS_NOTICE),
    'min_dissemination_date': fields.Date(description=docs.DISSEMINATION_MIN_DATE),
    'max_dissemination_date': fields.Date(description=docs.DISSEMINATION_MAX_DATE),
    'min_filing_date': fields.Date(description=docs.MIN_FILED_DATE),
    'max_filing_date': fields.Date(description=docs.MAX_FILED_DATE),
    'most_recent': fields.Bool(description=docs.MOST_RECENT_IE),
    'q_spender': fields.List(Keyword, description=docs.SPENDER_NAME_TEXT),
}

schedule_e_efile = {
    'candidate_search': fields.List(fields.Str, description=docs.CANDIDATE_FULL_SEARCH),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'payee_name': fields.List(fields.Str, description=docs.PAYEE_NAME),
    'image_number': fields.List(ImageNumber, description=docs.IMAGE_NUMBER),
    'support_oppose_indicator': fields.List(
        IStr(validate=validate.OneOf(['S', 'O'])),
        description=docs.SUPPORT_OPPOSE_INDICATOR),
    'min_expenditure_date': fields.Date(description=docs.EXPENDITURE_MIN_DATE),
    'max_expenditure_date': fields.Date(description=docs.EXPENDITURE_MAX_DATE),
    'min_dissemination_date': fields.Date(description=docs.DISSEMINATION_MIN_DATE),
    'max_dissemination_date': fields.Date(description=docs.DISSEMINATION_MAX_DATE),
    'min_expenditure_amount': fields.Integer(description=docs.EXPENDITURE_MIN_AMOUNT),
    'max_expenditure_amount': fields.Integer(description=docs.EXPENDITURE_MAX_AMOUNT),
    'spender_name': fields.List(IStr, description=docs.COMMITTEE_NAME),
    'candidate_party': fields.List(IStr, description=docs.PARTY),
    'candidate_office': fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P']), description=docs.OFFICE),
    'candidate_office_state': fields.List(IStr, description=docs.STATE),
    'candidate_office_district': fields.List(IStr, description=docs.DISTRICT),
    'most_recent': fields.Bool(description=docs.MOST_RECENT_IE),
    'min_filed_date': fields.Date(description=docs.FILED_DATE),
    'max_filed_date': fields.Date(description=docs.FILED_DATE),
    'filing_form': fields.List(IStr, description=docs.FORM_TYPE),
    'is_notice': fields.Bool(description=docs.IS_NOTICE),
}

rad_analyst = {
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'analyst_id': fields.List(fields.Int(), description='ID of RAD analyst'),
    'analyst_short_id': fields.List(fields.Int(), description='Short ID of RAD analyst'),
    'telephone_ext': fields.List(fields.Int(), description='Telephone extension of RAD analyst'),
    'name': fields.List(fields.Str, description='Name of RAD analyst'),
    'email': fields.List(fields.Str, description='Email of RAD analyst'),
    'title': fields.List(fields.Str, description='Title of RAD analyst'),
    'min_assignment_update_date': fields.Date(description='Filter results for assignment updates made after this date'),
    'max_assignment_update_date': fields.Date(description='Filter results for assignment updates made before this date')
}

large_aggregates = {'cycle': fields.Int(required=True, description=docs.RECORD_CYCLE)}

schedule_a_by_state_recipient_totals = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'state': fields.List(IStr, description=docs.STATE_GENERIC),
    'committee_type': fields.List(
        IStr,
        description=docs.COMMITTEE_TYPE_STATE_AGGREGATE_TOTALS
    ),
}

# endpoint audit-primary-category
auditPrimaryCategory = {
    'primary_category_id': fields.List(fields.Str(), description=docs.PRIMARY_CATEGORY_ID),
    'primary_category_name': fields.List(fields.Str, description=docs.PRIMARY_CATEGORY_NAME),
}


# endpoint audit-category
auditCategory = {
    'primary_category_id': fields.List(fields.Str(), description=docs.PRIMARY_CATEGORY_ID),
    'primary_category_name': fields.List(fields.Str, description=docs.PRIMARY_CATEGORY_NAME),
}

# endpoint audit-case
auditCase = {
    'q': fields.List(fields.Str, description=docs.COMMITTEE_NAME),
    'qq': fields.List(fields.Str, description=docs.CANDIDATE_NAME),
    'primary_category_id': fields.Str(missing='all', description=docs.PRIMARY_CATEGORY_ID),
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
    'beginning_image_number': fields.List(ImageNumber, description=docs.BEGINNING_IMAGE_NUMBER),
    'report_year': fields.List(fields.Int, description=docs.REPORT_YEAR),
    'form_type': fields.List(IStr, description=docs.FORM_TYPE),
    'amendment_indicator': fields.List(IStr, description=docs.AMENDMENT_INDICATOR),
    'status_num': fields.List(fields.Str(validate=validate.OneOf(['0', '1'])), description=docs.STATUS_NUM),
    'min_receipt_date': fields.Date(description=docs.MIN_RECEIPT_DATE),
    'max_receipt_date': fields.Date(description=docs.MAX_RECEIPT_DATE),
    'min_coverage_end_date': fields.Date(description=docs.MIN_COVERAGE_END_DATE),
    'max_coverage_end_date': fields.Date(description=docs.MAX_COVERAGE_END_DATE),
    'min_transaction_data_complete_date': fields.Date(description=docs.MIN_TRANSACTION_DATA_COMPLETE_DATE),
    'max_transaction_data_complete_date': fields.Date(description=docs.MAX_TRANSACTION_DATA_COMPLETE_DATE),
}


totals_by_office = {
    'election_year': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'office': fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P']), description=docs.OFFICE),
    'is_active_candidate': fields.Bool(description=docs.ACTIVE_CANDIDATE),
    'election_full': election_full,
    'min_election_cycle': fields.Int(description=docs.CYCLE),
    'max_election_cycle': fields.Int(description=docs.CYCLE),
}

totals_by_office_by_party = {
    'election_year': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'office': fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P']), description=docs.OFFICE),
    'is_active_candidate': fields.Bool(description=docs.ACTIVE_CANDIDATE),
    'election_full': election_full,
}

# for /candidates/totals/aggregates/ (candidate_aggregates.CandidateTotalAggregateView
candidate_total_aggregate = {
    'election_year': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'office': fields.Str(validate=validate.OneOf(['', 'H', 'S', 'P']), description=docs.OFFICE),
    'is_active_candidate': fields.Bool(description=docs.ACTIVE_CANDIDATE),
    'election_full': election_full,
    'min_election_cycle': fields.Int(description=docs.CYCLE),
    'max_election_cycle': fields.Int(description=docs.CYCLE),
    'state': fields.List(IStr, description=docs.STATE),
    'district': fields.List(District, description=docs.DISTRICT),
    'party': fields.Str(validate=validate.OneOf(['', 'DEM', 'REP', 'OTHER']), description=docs.PARTY),
    'aggregate_by': fields.Str(
        validate=validate.OneOf(['office', 'office-state', 'office-state-district', 'office-party']),
        description=docs.AGGREGATE_BY),
}

totals_by_candidate_other_costs_EC = {

    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'election_full': election_full,
}

schedule_e_totals_by_candidate_other_costs_IE = {

    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'election_full': election_full,
}

totals_by_candidate_other_costs_CC = {

    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID),
    'election_full': election_full,
}

schedule_h4 = {
    'cycle': fields.List(fields.Int, description=docs.RECORD_CYCLE),
    'committee_id': fields.List(IStr, description=docs.COMMITTEE_ID),
    'last_event_purpose_date': fields.Date(missing=None, description=docs.LAST_DISBURSEMENT_DATE),

}

presidential = {
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID_PRESIDENTIAL),
}

presidential_by_candidate = {
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
}

presidential_by_size = {
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
    'candidate_id': fields.List(IStr, description=docs.CANDIDATE_ID_PRESIDENTIAL),
    'size': fields.List(fields.Int(validate=validate.OneOf([0, 200, 500, 1000, 2000])), description=docs.SIZE),
}

presidential_by_candidate = {
    'election_year': fields.List(fields.Int, description=docs.ELECTION_YEAR),
    'contributor_state': fields.List(IStr, description=docs.CONTRIBUTOR_STATE),
}
