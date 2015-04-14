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
