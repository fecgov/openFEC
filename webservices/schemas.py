import re
import http
import functools

import marshmallow as ma
from smore import swagger

from webservices import paging
from webservices.spec import spec
from webservices import __API_VERSION__


def _get_class(value):
    return value if isinstance(value, type) else type(value)


def _format_ref(ref):
    return {'$ref': '#/definitions/{0}'.format(ref)}


def _schema_or_ref(schema):
    schema_class = _get_class(schema)
    ref = next(
        (
            ref_name
            for ref_schema, ref_name in spec.plugins['smore.ext.marshmallow']['refs'].items()
            if schema_class is _get_class(ref_schema)
        ),
        None,
    )
    return _format_ref(ref) if ref else swagger.schema2jsonschema(schema)


def marshal_with(schema, code=http.client.OK, description=None):
    def wrapper(func):
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.setdefault('responses', {}).update({
            code: {
                'schema': _schema_or_ref(schema),
                'description': description or '',
            }
        })

        @functools.wraps(func)
        def wrapped(*args, **kwargs):
            return schema.dump(func(*args, **kwargs)).data
        return wrapped
    return wrapper


def register_schema(schema, definition_name=None):
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)
    spec.definition(definition_name, schema=schema())


def make_page_schema(schema, class_name=None, definition_name=None):
    class_name = class_name or '{0}PageSchema'.format(re.sub(r'Schema$', '', schema.__name__))
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)

    class Meta:
        results_schema_class = schema
        results_schema_options = {'ref': '#/definitions/{0}'.format(definition_name)}

    return type(
        class_name,
        (paging.PageSchema, ApiSchema),
        {'Meta': Meta},
    )


class ApiSchema(ma.Schema):
    def _postprocess(self, data, many, obj):
        ret = {'api_version': __API_VERSION__}
        ret.update(data)
        return ret


class NameSearchSchema(ma.Schema):
    candidate_id = ma.fields.String()
    committee_id = ma.fields.String()
    name = ma.fields.String()
    office_sought = ma.fields.String()


class NameSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        NameSearchSchema,
        ref='#/definitions/NameSearch',
        many=True,
    )


register_schema(NameSearchSchema)
register_schema(NameSearchListSchema)


class CandidateSchema(ma.Schema):
    candidate_id = ma.fields.String()
    cycles = ma.fields.List(ma.fields.Integer())
    candidate_status_full = ma.fields.String()
    candidate_status = ma.fields.String()
    district = ma.fields.String()
    incumbent_challenge_full = ma.fields.String()
    incumbent_challenge = ma.fields.String()
    office_full = ma.fields.String()
    office = ma.fields.String()
    party_full = ma.fields.String()
    party = ma.fields.String()
    state = ma.fields.String()
    name = ma.fields.String()


class CandidateListSchema(CandidateSchema):
    active_through = ma.fields.Integer()
    election_years = ma.fields.List(ma.fields.Integer())


class CandidateDetailSchema(CandidateListSchema):
    expire_date = ma.fields.DateTime()
    load_date = ma.fields.DateTime()
    form_type = ma.fields.String()
    address_city = ma.fields.String()
    address_state = ma.fields.String()
    address_street_1 = ma.fields.String()
    address_street_2 = ma.fields.String()
    address_zip = ma.fields.String()
    candidate_inactive = ma.fields.String()


class CandidateHistorySchema(CandidateSchema):
    two_year_period = ma.fields.Integer()
    expire_date = ma.fields.String()
    load_date = ma.fields.String()
    form_type = ma.fields.String()
    address_city = ma.fields.String()
    address_state = ma.fields.String()
    address_street_1 = ma.fields.String()
    address_street_2 = ma.fields.String()
    address_zip = ma.fields.String()
    candidate_inactive = ma.fields.String()


CandidateListPageSchema = make_page_schema(CandidateListSchema)
CandidateDetailPageSchema = make_page_schema(CandidateDetailSchema)
CandidateHistoryPageSchema = make_page_schema(CandidateHistorySchema)

register_schema(CandidateListSchema)
register_schema(CandidateDetailSchema)
register_schema(CandidateHistorySchema)
register_schema(CandidateListPageSchema)
register_schema(CandidateDetailPageSchema)
register_schema(CandidateHistoryPageSchema)


class CommitteeSchema(ma.Schema):
    committee_id = ma.fields.String()
    name = ma.fields.String()
    designation_full = ma.fields.String()
    designation = ma.fields.String()
    treasurer_name = ma.fields.String()
    organization_type_full = ma.fields.String()
    organization_type = ma.fields.String()
    state = ma.fields.String()
    party_full = ma.fields.String()
    party = ma.fields.String()
    committee_type_full = ma.fields.String()
    committee_type = ma.fields.String()
    expire_date = ma.fields.DateTime()
    first_file_date = ma.fields.DateTime()
    last_file_date = ma.fields.DateTime()
    original_registration_date = ma.fields.String()


class CommitteeDetailSchema(CommitteeSchema):
    filing_frequency = ma.fields.String()
    email = ma.fields.String()
    fax = ma.fields.String()
    website = ma.fields.String()
    form_type = ma.fields.String()
    leadership_pac = ma.fields.String()
    load_date = ma.fields.String()
    lobbyist_registrant_pac = ma.fields.String()
    party_type = ma.fields.String()
    party_type_full = ma.fields.String()
    qualifying_date = ma.fields.String()
    street_1 = ma.fields.String()
    street_2 = ma.fields.String()
    city = ma.fields.String()
    state_full = ma.fields.String()
    zip = ma.fields.String()
    treasurer_city = ma.fields.String()
    treasurer_name_1 = ma.fields.String()
    treasurer_name_2 = ma.fields.String()
    treasurer_name_middle = ma.fields.String()
    treasurer_name_prefix = ma.fields.String()
    treasurer_phone = ma.fields.String()
    treasurer_state = ma.fields.String()
    treasurer_street_1 = ma.fields.String()
    treasurer_street_2 = ma.fields.String()
    treasurer_name_suffix = ma.fields.String()
    treasurer_name_title = ma.fields.String()
    treasurer_zip = ma.fields.String()
    custodian_city = ma.fields.String()
    custodian_name_1 = ma.fields.String()
    custodian_name_2 = ma.fields.String()
    custodian_name_middle = ma.fields.String()
    custodian_name_full = ma.fields.String()
    custodian_phone = ma.fields.String()
    custodian_name_prefix = ma.fields.String()
    custodian_state = ma.fields.String()
    custodian_street_1 = ma.fields.String()
    custodian_street_2 = ma.fields.String()
    custodian_name_suffix = ma.fields.String()
    custodian_name_title = ma.fields.String()
    custodian_zip = ma.fields.String()


CommitteePageSchema = make_page_schema(CommitteeSchema)
CommitteeDetailPageSchema = make_page_schema(CommitteeDetailSchema)

register_schema(CommitteeSchema)
register_schema(CommitteeDetailSchema)
register_schema(CommitteePageSchema)
register_schema(CommitteeDetailPageSchema)


class ReportsSchema(ma.Schema):
    beginning_image_number = ma.fields.Integer()
    cash_on_hand_beginning_period = ma.fields.Integer()
    cash_on_hand_end_period = ma.fields.Integer()
    committee_id = ma.fields.String()
    coverage_end_date = ma.fields.DateTime()
    coverage_start_date = ma.fields.DateTime,
    cycle = ma.fields.Integer()
    debts_owed_by_committee = ma.fields.Integer()
    debts_owed_to_committee = ma.fields.Integer()
    end_image_number = ma.fields.Integer()
    expire_date = ma.fields.DateTime,
    other_disbursements_period = ma.fields.Integer()
    other_disbursements_ytd = ma.fields.Integer()
    other_political_committee_contributions_period = ma.fields.Integer()
    other_political_committee_contributions_ytd = ma.fields.Integer()
    political_party_committee_contributions_period = ma.fields.Integer()
    political_party_committee_contributions_ytd = ma.fields.Integer()
    offsets_to_operating_expenditures_period = ma.fields.Integer()
    offsets_to_operating_expenditures_ytd = ma.fields.Integer()
    report_type = ma.fields.String()
    report_type_full = ma.fields.String()
    report_year = ma.fields.Integer()
    total_contribution_refunds_period = ma.fields.Integer()
    total_contribution_refunds_ytd = ma.fields.Integer()
    total_contributions_period = ma.fields.Integer()
    total_contributions_ytd = ma.fields.Integer()
    total_disbursements_period = ma.fields.Integer()
    total_disbursements_ytd = ma.fields.Integer()
    total_receipts_period = ma.fields.Integer()
    total_receipts_ytd = ma.fields.Integer()


class ReportsPresidentialSchema(ReportsSchema):
    candidate_contribution_period = ma.fields.Integer()
    candidate_contribution_ytd = ma.fields.Integer()
    exempt_legal_accounting_disbursement_period = ma.fields.Integer()
    exempt_legal_accounting_disbursement_ytd = ma.fields.Integer()
    expentiture_subject_to_limits = ma.fields.Integer()
    federal_funds_period = ma.fields.Integer()
    federal_funds_ytd = ma.fields.Integer()
    fundraising_disbursements_period = ma.fields.Integer()
    fundraising_disbursements_ytd = ma.fields.Integer()
    individual_contributions_period = ma.fields.Integer()
    individual_contributions_ytd = ma.fields.Integer()
    items_on_hand_liquidated = ma.fields.Integer()
    loans_received_from_candidate_period = ma.fields.Integer()
    loans_received_from_candidate_ytd = ma.fields.Integer()
    net_contribution_summary_period = ma.fields.Integer()
    net_operating_expenses_summary_period = ma.fields.Integer()
    offsets_to_fundraising_exp_ytd = ma.fields.Integer()
    offsets_to_fundraising_expenses_period = ma.fields.Integer()
    offsets_to_legal_accounting_period = ma.fields.Integer()
    offsets_to_legal_accounting_ytd = ma.fields.Integer()
    operating_expenditures_period = ma.fields.Integer()
    operating_expenditures_ytd = ma.fields.Integer()
    other_loans_received_period = ma.fields.Integer()
    other_loans_received_ytd = ma.fields.Integer()
    other_receipts_period = ma.fields.Integer()
    other_receipts_ytd = ma.fields.Integer()
    refunded_individual_contributions_ytd = ma.fields.Integer()
    refunded_other_political_committee_contributions_period = ma.fields.Integer()
    refunded_other_political_committee_contributions_ytd = ma.fields.Integer()
    refunded_political_party_committee_contributions_period = ma.fields.Integer()
    refunded_political_party_committee_contributions_ytd = ma.fields.Integer()
    refunds_individual_contributions_period = ma.fields.Integer()
    repayments_loans_made_by_candidate_period = ma.fields.Integer()
    repayments_loans_made_candidate_ytd = ma.fields.Integer()
    repayments_other_loans_period = ma.fields.Integer()
    repayments_other_loans_ytd = ma.fields.Integer()
    subtotal_summary_period = ma.fields.Integer()
    total_disbursements_summary_period = ma.fields.Integer()
    total_loan_repayments_made_period = ma.fields.Integer()
    total_loan_repayments_made_ytd = ma.fields.Integer()
    total_loans_received_period = ma.fields.Integer()
    total_loans_received_ytd = ma.fields.Integer()
    total_offsets_to_operating_expenditures_period = ma.fields.Integer()
    total_offsets_to_operating_expenditures_ytd = ma.fields.Integer()
    total_period = ma.fields.Integer()
    total_receipts_summary_period = ma.fields.Integer()
    total_ytd = ma.fields.Integer()
    transfer_from_affiliated_committee_period = ma.fields.Integer()
    transfer_from_affiliated_committee_ytd = ma.fields.Integer()
    transfer_to_other_authorized_committee_period = ma.fields.Integer()
    transfer_to_other_authorized_committee_ytd = ma.fields.Integer()


class ReportsHouseSenateSchema(ReportsSchema):
    aggregate_amount_personal_contributions_general = ma.fields.Integer()
    aggregate_contributions_personal_funds_primary = ma.fields.Integer()
    all_other_loans_period = ma.fields.Integer()
    all_other_loans_ytd = ma.fields.Integer()
    candidate_contribution_period = ma.fields.Integer()
    candidate_contribution_ytd = ma.fields.Integer()
    gross_receipt_authorized_committee_general = ma.fields.Integer()
    gross_receipt_authorized_committee_primary = ma.fields.Integer()
    gross_receipt_minus_personal_contribution_general = ma.fields.Integer()
    gross_receipt_minus_personal_contributions_primary = ma.fields.Integer()
    individual_itemized_contributions_period = ma.fields.Integer()
    individual_unitemized_contributions_period = ma.fields.Integer()
    loan_repayments_candidate_loans_period = ma.fields.Integer()
    loan_repayments_candidate_loans_ytd = ma.fields.Integer()
    loan_repayments_other_loans_period = ma.fields.Integer()
    loan_repayments_other_loans_ytd = ma.fields.Integer()
    loans_made_by_candidate_period = ma.fields.Integer()
    loans_made_by_candidate_ytd = ma.fields.Integer()
    net_contributions_period = ma.fields.Integer()
    net_contributions_ytd = ma.fields.Integer()
    net_operating_expenditures_period = ma.fields.Integer()
    net_operating_expenditures_ytd = ma.fields.Integer()
    operating_expenditures_period = ma.fields.Integer()
    operating_expenditures_ytd = ma.fields.Integer()
    other_receipts_period = ma.fields.Integer()
    other_receipts_ytd = ma.fields.Integer()
    refunds_individual_contributions_period = ma.fields.Integer()
    refunds_individual_contributions_ytd = ma.fields.Integer()
    refunds_other_political_committee_contributions_period = ma.fields.Integer()
    refunds_other_political_committee_contributions_ytd = ma.fields.Integer()
    refunds_political_party_committee_contributions_period = ma.fields.Integer()
    refunds_political_party_committee_contributions_ytd = ma.fields.Integer()
    refunds_total_contributions_col_total_ytd = ma.fields.Integer()
    subtotal_period = ma.fields.Integer()
    total_contribution_refunds_col_total_period = ma.fields.Integer()
    total_contributions_column_total_period = ma.fields.Integer()
    total_individual_contributions_period = ma.fields.Integer()
    total_individual_contributions_ytd = ma.fields.Integer()
    total_individual_itemized_contributions_ytd = ma.fields.Integer()
    total_individual_unitemized_contributions_ytd = ma.fields.Integer()
    total_loan_repayments_period = ma.fields.Integer()
    total_loan_repayments_ytd = ma.fields.Integer()
    total_loans_period = ma.fields.Integer()
    total_loans_ytd = ma.fields.Integer()
    total_operating_expenditures_period = ma.fields.Integer()
    total_operating_expenditures_ytd = ma.fields.Integer()
    total_receipts = ma.fields.Integer()
    transfers_from_other_authorized_committee_period = ma.fields.Integer()
    transfers_from_other_authorized_committee_ytd = ma.fields.Integer()
    transfers_to_other_authorized_committee_period = ma.fields.Integer()
    transfers_to_other_authorized_committee_ytd = ma.fields.Integer()


class ReportsPacPartySchema(ReportsSchema):
    all_loans_received_period = ma.fields.Integer()
    all_loans_received_ytd = ma.fields.Integer()
    allocated_federal_election_levin_share_period = ma.fields.Integer()
    calendar_ytd = ma.fields.Integer()
    cash_on_hand_beginning_calendar_ytd = ma.fields.Integer()
    cash_on_hand_close_ytd = ma.fields.Integer()
    coordinated_expenditures_by_party_committee_period = ma.fields.Integer()
    coordinated_expenditures_by_party_committee_ytd = ma.fields.Integer()
    fed_candidate_committee_contribution_refunds_ytd = ma.fields.Integer()
    fed_candidate_committee_contributions_period = ma.fields.Integer()
    fed_candidate_committee_contributions_ytd = ma.fields.Integer()
    fed_candidate_contribution_refunds_period = ma.fields.Integer()
    independent_expenditures_period = ma.fields.Integer()
    independent_expenditures_ytd = ma.fields.Integer()
    individual_contribution_refunds_period = ma.fields.Integer()
    individual_contribution_refunds_ytd = ma.fields.Integer()
    individual_itemized_contributions_period = ma.fields.Integer()
    individual_itemized_contributions_ytd = ma.fields.Integer()
    individual_unitemized_contributions_period = ma.fields.Integer()
    individual_unitemized_contributions_ytd = ma.fields.Integer()
    loan_repayments_made_period = ma.fields.Integer()
    loan_repayments_made_ytd = ma.fields.Integer()
    loan_repayments_received_period = ma.fields.Integer()
    loan_repayments_received_ytd = ma.fields.Integer()
    loans_made_period = ma.fields.Integer()
    loans_made_ytd = ma.fields.Integer()
    net_contributions_period = ma.fields.Integer()
    net_contributions_ytd = ma.fields.Integer()
    net_operating_expenditures_period = ma.fields.Integer()
    net_operating_expenditures_ytd = ma.fields.Integer()
    non_allocated_fed_election_activity_period = ma.fields.Integer()
    non_allocated_fed_election_activity_ytd = ma.fields.Integer()
    nonfed_share_allocated_disbursements_period = ma.fields.Integer()
    other_fed_operating_expenditures_period = ma.fields.Integer()
    other_fed_operating_expenditures_ytd = ma.fields.Integer()
    other_fed_receipts_period = ma.fields.Integer()
    other_fed_receipts_ytd = ma.fields.Integer()
    other_political_committee_contribution_refunds_period = ma.fields.Integer()
    other_political_committee_contribution_refunds_ytd = ma.fields.Integer()
    political_party_committee_contribution_refunds_period = ma.fields.Integer()
    political_party_committee_contribution_refunds_ytd = ma.fields.Integer()
    shared_fed_activity_nonfed_ytd = ma.fields.Integer()
    shared_fed_activity_period = ma.fields.Integer()
    shared_fed_activity_ytd = ma.fields.Integer()
    shared_fed_operating_expenditures_period = ma.fields.Integer()
    shared_fed_operating_expenditures_ytd = ma.fields.Integer()
    shared_nonfed_operating_expenditures_ytd = ma.fields.Integer()
    subtotal_summary_page_period = ma.fields.Integer()
    subtotal_summary_ytd = ma.fields.Integer()
    total_disbursements_summary_page_period = ma.fields.Integer()
    total_disbursements_summary_page_ytd = ma.fields.Integer()
    total_fed_disbursements_period = ma.fields.Integer()
    total_fed_disbursements_ytd = ma.fields.Integer()
    total_fed_elect_activity_period = ma.fields.Integer()
    total_fed_election_activity_ytd = ma.fields.Integer()
    total_fed_operating_expenditures_period = ma.fields.Integer()
    total_fed_operating_expenditures_ytd = ma.fields.Integer()
    total_fed_receipts_period = ma.fields.Integer()
    total_fed_receipts_ytd = ma.fields.Integer()
    total_individual_contributions = ma.fields.Integer()
    total_individual_contributions_ytd = ma.fields.Integer()
    total_nonfed_transfers_period = ma.fields.Integer()
    total_nonfed_transfers_ytd = ma.fields.Integer()
    total_operating_expenditures_period = ma.fields.Integer()
    total_operating_expenditures_ytd = ma.fields.Integer()
    total_receipts_summary_page_period = ma.fields.Integer()
    total_receipts_summary_page_ytd = ma.fields.Integer()
    transfers_from_affiliated_party_period = ma.fields.Integer()
    transfers_from_affiliated_party_ytd = ma.fields.Integer()
    transfers_from_nonfed_account_period = ma.fields.Integer()
    transfers_from_nonfed_account_ytd = ma.fields.Integer()
    transfers_from_nonfed_levin_period = ma.fields.Integer()
    transfers_from_nonfed_levin_ytd = ma.fields.Integer()
    transfers_to_affiliated_committee_period = ma.fields.Integer()
    transfers_to_affilitated_committees_ytd = ma.fields.Integer()


ReportsPresidentialPageSchema = make_page_schema(ReportsPresidentialSchema)
ReportsHouseSenatePageSchema = make_page_schema(ReportsHouseSenateSchema)
ReportsPacPartyPageSchema = make_page_schema(ReportsPacPartySchema)


class TotalsSchema(ma.Schema):
    committee_id = ma.fields.String()
    cycle = ma.fields.Integer()
    offsets_to_operating_expenditures = ma.fields.Integer()
    political_party_committee_contributions = ma.fields.Integer()
    other_disbursements = ma.fields.Integer()
    other_political_committee_contributions = ma.fields.Integer()
    operating_expenditures = ma.fields.Integer()
    disbursements = ma.fields.Integer()
    contributions = ma.fields.Integer()
    contribution_refunds = ma.fields.Integer()
    receipts = ma.fields.Integer()
    coverage_start_date = ma.fields.DateTime()
    coverage_end_date = ma.fields.DateTime()


class TotalsPresidentialSchema(TotalsSchema):
    all_loans_received = ma.fields.Integer()
    coordinated_expenditures_by_party_committee = ma.fields.Integer()
    fed_candidate_committee_contributions = ma.fields.Integer()
    fed_candidate_contribution_refunds = ma.fields.Integer()
    fed_disbursements = ma.fields.Integer()
    fed_elect_activity = ma.fields.Integer()
    fed_operating_expenditures = ma.fields.Integer()
    fed_receipts = ma.fields.Integer()
    independent_expenditures = ma.fields.Integer()
    individual_contribution_refunds = ma.fields.Integer()
    individual_itemized_contributions = ma.fields.Integer()
    individual_unitemized_contributions = ma.fields.Integer()
    loan_repayments_made = ma.fields.Integer()
    loan_repayments_received = ma.fields.Integer()
    loans_made = ma.fields.Integer()
    net_contributions = ma.fields.Integer()
    non_allocated_fed_election_activity = ma.fields.Integer()
    nonfed_transfers = ma.fields.Integer()
    other_fed_operating_expenditures = ma.fields.Integer()
    other_fed_receipts = ma.fields.Integer()
    shared_fed_activity = ma.fields.Integer()
    shared_fed_activity_nonfed = ma.fields.Integer()
    shared_fed_operating_expenditures = ma.fields.Integer()
    shared_nonfed_operating_expenditures = ma.fields.Integer()
    transfers_from_affiliated_party = ma.fields.Integer()
    transfers_from_nonfed_account = ma.fields.Integer()
    transfers_from_nonfed_levin = ma.fields.Integer()
    transfers_to_affiliated_committee = ma.fields.Integer()


class TotalsHouseSenateSchema(TotalsSchema):
    all_other_loans = ma.fields.Integer()
    candidate_contribution = ma.fields.Integer()
    individual_contributions = ma.fields.Integer()
    individual_itemized_contributions = ma.fields.Integer()
    individual_unitemized_contributions = ma.fields.Integer()
    loan_repayments = ma.fields.Integer()
    loan_repayments_candidate_loans = ma.fields.Integer()
    loan_repayments_other_loans = ma.fields.Integer()
    loans = ma.fields.Integer()
    loans_made_by_candidate = ma.fields.Integer()
    other_receipts = ma.fields.Integer()
    refunds_individual_contributions = ma.fields.Integer()
    refunds_other_political_committee_contributions = ma.fields.Integer()
    refunds_political_party_committee_contributions = ma.fields.Integer()
    transfers_from_other_authorized_committee = ma.fields.Integer()
    transfers_to_other_authorized_committee = ma.fields.Integer()


class TotalsPacPartySchema(TotalsSchema):
    candidate_contribution = ma.fields.Integer()
    exempt_legal_accounting_disbursement = ma.fields.Integer()
    individual_contributions = ma.fields.Integer()
    loan_repayments_made = ma.fields.Integer()
    loans_received_from_candidate = ma.fields.Integer()
    offsets_to_fundraising_expenses = ma.fields.Integer()
    offsets_to_legal_accounting = ma.fields.Integer()
    other_loans_received = ma.fields.Integer()
    other_receipts = ma.fields.Integer()
    refunded_individual_contributions = ma.fields.Integer()
    refunded_other_political_committee_contributions = ma.fields.Integer()
    refunded_political_party_committee_contributions = ma.fields.Integer()
    transfer_from_affiliated_committee = ma.fields.Integer()
    transfer_to_other_authorized_committee = ma.fields.Integer()


TotalsPresidentialPageSchema = make_page_schema(TotalsPresidentialSchema)
TotalsHouseSenatePageSchema = make_page_schema(TotalsHouseSenateSchema)
TotalsPacPartyPageSchema = make_page_schema(TotalsPacPartySchema)
