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


class CandidateSchema(ma.Schema):
    candidate_id = ma.fields.String()
    candidate_status_full = ma.fields.String()
    candidate_status = ma.fields.String()
    district = ma.fields.String()
    active_through = ma.fields.Integer()
    election_years = ma.fields.List(ma.fields.Integer())
    incumbent_challenge_full = ma.fields.String()
    incumbent_challenge = ma.fields.String()
    office_full = ma.fields.String()
    office = ma.fields.String()
    party_full = ma.fields.String()
    party = ma.fields.String()
    state = ma.fields.String()
    name = ma.fields.String()


class CandidateDetailSchema(CandidateSchema):
    expire_date = ma.fields.DateTime()
    load_date = ma.fields.DateTime()
    form_type = ma.fields.String()
    address_city = ma.fields.String()
    address_state = ma.fields.String()
    address_street_1 = ma.fields.String()
    address_street_2 = ma.fields.String()
    address_zip = ma.fields.String()
    candidate_inactive = ma.fields.String()


CandidatePageSchema = make_page_schema(CandidateSchema)
CandidateDetailPageSchema = make_page_schema(CandidateDetailSchema)

register_schema(CandidateSchema)
register_schema(CandidateDetailSchema)
register_schema(CandidatePageSchema)
register_schema(CandidateDetailPageSchema)


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
