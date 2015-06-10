import re
import http
import functools

import marshmallow as ma
from smore import swagger
from marshmallow_sqlalchemy import ModelSchema

from webservices import utils
from webservices import paging
from webservices.spec import spec
from webservices.common import models
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


def marshal_with(schema, code=http.client.OK, description=None, wrap=True):
    def wrapper(func):
        func.__apidoc__ = getattr(func, '__apidoc__', {})
        func.__apidoc__.setdefault('responses', {}).update({
            code: {
                'schema': _schema_or_ref(schema),
                'description': description or '',
            }
        })

        if wrap:
            @functools.wraps(func)
            def wrapped(*args, **kwargs):
                return schema.dump(func(*args, **kwargs)).data
            return wrapped
        return func

    return wrapper


def register_schema(schema, definition_name=None):
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)
    spec.definition(definition_name, schema=schema())


def make_schema(model, class_name=None, fields=None, options=None):
    class_name = class_name or '{0}Schema'.format(model.__name__)

    Meta = type(
        'Meta',
        (object, ),
        utils.extend(
            {
                'model': model,
                'sqla_session': models.db.session,
                'exclude': ('idx', ),
            },
            options or {},
        )
    )

    return type(
        class_name,
        (ModelSchema, ),
        utils.extend({'Meta': Meta}, fields or {}),
    )


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


class BaseSearchSchema(ma.Schema):
    id = ma.fields.String()
    name = ma.fields.String()


class CandidateSearchSchema(BaseSearchSchema):
    office_sought = ma.fields.String()


class CommitteeSearchSchema(BaseSearchSchema):
    pass


class CandidateSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        CandidateSearchSchema,
        ref='#/definitions/CandidateSearch',
        many=True,
    )


class CommitteeSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        CandidateSearchSchema,
        ref='#/definitions/CommtteeSearch',
        many=True,
    )


register_schema(CandidateSearchSchema)
register_schema(CandidateSearchListSchema)
register_schema(CommitteeSearchSchema)
register_schema(CommitteeSearchListSchema)


make_committee_schema = functools.partial(make_schema, options={'exclude': ('idx', 'committee_key')})
CommitteeSchema = make_committee_schema(models.Committee)
CommitteeHistorySchema = make_committee_schema(models.CommitteeHistory)
CommitteeDetailSchema = make_committee_schema(models.CommitteeDetail)

CommitteePageSchema = make_page_schema(CommitteeSchema)
CommitteeHistoryPageSchema = make_page_schema(CommitteeHistorySchema)
CommitteeDetailPageSchema = make_page_schema(CommitteeDetailSchema)

register_schema(CommitteeSchema)
register_schema(CommitteeHistorySchema)
register_schema(CommitteeDetailSchema)
register_schema(CommitteePageSchema)
register_schema(CommitteeHistoryPageSchema)
register_schema(CommitteeDetailPageSchema)


make_candidate_schema = functools.partial(make_schema, options={'exclude': ('idx', 'candidate_key')})
CandidateSchema = make_schema(
    models.Candidate,
    options={'exclude': ('idx', 'candidate_key', 'principal_committees')},
)
CandidateSearchSchema = make_candidate_schema(
    models.Candidate,
    fields={'principal_committees': ma.fields.Nested(CommitteeSchema, many=True)},
)
CandidateDetailSchema = make_candidate_schema(models.CandidateDetail)
CandidateHistorySchema = make_candidate_schema(models.CandidateHistory)

CandidatePageSchema = make_page_schema(CandidateSchema)
CandidateDetailPageSchema = make_page_schema(CandidateDetailSchema)
CandidateSearchPageSchema = make_page_schema(CandidateSearchSchema)
CandidateHistoryPageSchema = make_page_schema(CandidateHistorySchema)

register_schema(CandidateSchema)
register_schema(CandidateDetailSchema)
register_schema(CandidateSearchSchema)
register_schema(CandidateHistorySchema)

register_schema(CandidatePageSchema)
register_schema(CandidateSearchPageSchema)
register_schema(CandidateDetailPageSchema)
register_schema(CandidateHistoryPageSchema)


make_reports_schema = functools.partial(
    make_schema,
    fields={'pdf_url': ma.fields.Str()},
    options={'exclude': ('idx', 'report_key')},
)
CommitteeReportsSchema = make_reports_schema(
    models.CommitteeReportsPresidential,
    class_name='CommitteeReportsSchema',
    options={'exclude': [
        each.key for each in models.CommitteeReportsPresidential.__mapper__.iterate_properties
        if not hasattr(models.CommitteeReports, each.key)
    ] + ['idx', 'report_key']}
)

CommitteeReportsPresidentialSchema = make_reports_schema(models.CommitteeReportsPresidential)
CommitteeReportsHouseSenateSchema = make_reports_schema(models.CommitteeReportsHouseSenate)
CommitteeReportsPacPartySchema = make_reports_schema(models.CommitteeReportsPacParty)

CommitteeReportsPageSchema = make_page_schema(CommitteeReportsSchema)
CommitteeReportsPresidentialPageSchema = make_page_schema(CommitteeReportsPresidentialSchema)
CommitteeReportsHouseSenatePageSchema = make_page_schema(CommitteeReportsHouseSenateSchema)
CommitteeReportsPacPartyPageSchema = make_page_schema(CommitteeReportsPacPartySchema)

register_schema(CommitteeReportsSchema)
register_schema(CommitteeReportsPageSchema)


CommitteeTotalsSchema = make_schema(
    models.CommitteeTotalsPresidential,
    class_name='CommitteeTotalsSchema',
    options={'exclude': [
        each.key for each in models.CommitteeTotalsPresidential.__mapper__.iterate_properties
        if not hasattr(models.CommitteeTotals, each.key)
    ] + ['idx']}
)
CommitteeTotalsPresidentialSchema = make_schema(models.CommitteeTotalsPresidential)
CommitteeTotalsHouseSenateSchema = make_schema(models.CommitteeTotalsHouseSenate)
CommitteeTotalsPacPartySchema = make_schema(models.CommitteeTotalsPacParty)

CommitteeTotalsPageSchema = make_page_schema(CommitteeTotalsSchema)
CommitteeTotalsPresidentialPageSchema = make_page_schema(CommitteeTotalsPresidentialSchema)
CommitteeTotalsHouseSenatePageSchema = make_page_schema(CommitteeTotalsHouseSenateSchema)
CommitteeTotalsPacPartyPageSchema = make_page_schema(CommitteeTotalsPacPartySchema)

register_schema(CommitteeTotalsSchema)
register_schema(CommitteeTotalsPageSchema)
