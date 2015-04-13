import marshmallow as ma

from webservices import paging
from webservices.spec import spec


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
