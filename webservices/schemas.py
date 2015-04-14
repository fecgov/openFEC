import http
import functools

import marshmallow as ma
from smore import swagger

from webservices import paging
from webservices.spec import spec


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
    ret = _format_ref(ref) if ref else swagger.schema2jsonschema(schema)
    return {'schema': ret}


def marshal_with(schema, code=http.client.OK):
    def wrapper(func):
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.setdefault('responses', {}).update({code: _schema_or_ref(schema)})

        @functools.wraps(func)
        def wrapped(*args, **kwargs):
            return schema.dump(func(*args, **kwargs)).data
        return wrapped
    return wrapper


class ApiSchema(ma.Schema):
    def _postprocess(self, data, many, obj):
        ret = {'api_version': '0.2'}
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


class CandidatePageSchema(paging.PageSchema, ApiSchema):
    class Meta:
        results_schema_class = CandidateSchema


class CandidateDetailPageSchema(paging.PageSchema, ApiSchema):
    class Meta:
        results_schema_class = CandidateDetailSchema


spec.definition('Candidate', schema=CandidatePageSchema())
spec.definition('CandidateDetail', schema=CandidateDetailPageSchema())
