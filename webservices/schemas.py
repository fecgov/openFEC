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


def make_page_schema(schema, page_type=paging.OffsetPageSchema, class_name=None,
                     definition_name=None):
    class_name = class_name or '{0}PageSchema'.format(re.sub(r'Schema$', '', schema.__name__))
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)

    class Meta:
        results_schema_class = schema
        results_schema_options = {'ref': '#/definitions/{0}'.format(definition_name)}

    return type(
        class_name,
        (page_type, ApiSchema),
        {'Meta': Meta},
    )


schemas = {}

def augment_schemas(*schemas, namespace=schemas):
    for schema in schemas:
        page_schema = make_page_schema(schema)
        register_schema(schema)
        register_schema(page_schema)
        namespace.update({
            schema.__name__: schema,
            page_schema.__name__: page_schema,
        })

def augment_models(factory, *models, namespace=schemas):
    for model in models:
        schema = factory(model)
        augment_schemas(schema, namespace=namespace)

class ApiSchema(ma.Schema):
    def _postprocess(self, data, many, obj):
        ret = {'api_version': __API_VERSION__}
        ret.update(data)
        return ret


class BaseSearchSchema(ma.Schema):
    id = ma.fields.Str()
    name = ma.fields.Str()


class CandidateSearchSchema(BaseSearchSchema):
    office_sought = ma.fields.Str()


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
        ref='#/definitions/CommitteeSearch',
        many=True,
    )


register_schema(CandidateSearchSchema)
register_schema(CandidateSearchListSchema)
register_schema(CommitteeSearchSchema)
register_schema(CommitteeSearchListSchema)


make_committee_schema = functools.partial(make_schema, options={'exclude': ('idx', 'committee_key')})

augment_models(
    make_committee_schema,
    models.Committee,
    models.CommitteeHistory,
    models.CommitteeDetail,
)


make_candidate_schema = functools.partial(
    make_schema,
    options={'exclude': ('idx', 'candidate_key', 'principal_committees')},
)

augment_models(
    make_candidate_schema,
    models.Candidate,
    models.CandidateDetail,
    models.CandidateHistory,
)

CandidateSearchSchema = make_schema(
    models.Candidate,
    options={'exclude': ('idx', 'candidate_key')},
    fields={'principal_committees': ma.fields.Nested(schemas['CommitteeSchema'], many=True)},
)
CandidateSearchPageSchema = make_page_schema(CandidateSearchSchema)
register_schema(CandidateSearchSchema)
register_schema(CandidateSearchPageSchema)


make_reports_schema = functools.partial(
    make_schema,
    fields={
        'pdf_url': ma.fields.Str(),
        'report_form': ma.fields.Str(),
        'committee_type': ma.fields.Str(attribute='committee.committee_type'),
    },
    options={'exclude': ('idx', 'report_key', 'committee')},
)

augment_models(
    make_reports_schema,
    models.CommitteeReportsPresidential,
    models.CommitteeReportsHouseSenate,
    models.CommitteeReportsPacParty,
    models.CommitteeReportsIEOnly,
)

reports_schemas = (
    schemas['CommitteeReportsPresidentialSchema'],
    schemas['CommitteeReportsHouseSenateSchema'],
    schemas['CommitteeReportsPacPartySchema'],
    schemas['CommitteeReportsIEOnlySchema'],
)
CommitteeReportsSchema = type('CommitteeReportsSchema', reports_schemas, {})
CommitteeReportsPageSchema = make_page_schema(CommitteeReportsSchema)

augment_models(
    make_schema,
    models.CommitteeTotalsPresidential,
    models.CommitteeTotalsHouseSenate,
    models.CommitteeTotalsPacParty,
    models.CommitteeTotalsIEOnly,
)

register_schema(CommitteeReportsSchema)
register_schema(CommitteeReportsPageSchema)

totals_schemas = (
    schemas['CommitteeTotalsPresidentialSchema'],
    schemas['CommitteeTotalsHouseSenateSchema'],
    schemas['CommitteeTotalsPacPartySchema'],
    schemas['CommitteeTotalsIEOnlySchema'],
)
CommitteeTotalsSchema = type('CommitteeTotalsSchema', totals_schemas, {})
CommitteeTotalsPageSchema = make_page_schema(CommitteeTotalsSchema)

register_schema(CommitteeTotalsSchema)
register_schema(CommitteeTotalsPageSchema)

ScheduleASchema = make_schema(
    models.ScheduleA,
    fields={
        'pdf_url': ma.fields.Str(),
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'contributor': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'contributor_receipt_amount': ma.fields.Decimal(places=2),
        'contributor_aggregate_ytd': ma.fields.Decimal(places=2),
    },
    options={
        'exclude': ('memo_code', ),
    }
)
ScheduleAPageSchema = make_page_schema(ScheduleASchema, page_type=paging.SeekPageSchema)
register_schema(ScheduleASchema)
register_schema(ScheduleAPageSchema)

make_aggregate_schema = functools.partial(
    make_schema,
    fields={
        'total': ma.fields.Decimal(places=2),
    }
)

augment_models(
    make_aggregate_schema,
    models.ScheduleAByZip,
    models.ScheduleABySize,
    models.ScheduleAByState,
    models.ScheduleAByEmployer,
    models.ScheduleAByOccupation,
    models.ScheduleAByContributor,
)

ScheduleBSchema = make_schema(
    models.ScheduleB,
    fields={
        'pdf_url': ma.fields.Str(),
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'recipient_committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'disbursement_amount': ma.fields.Decimal(places=2),
        'semi_annual_bundled_refund': ma.fields.Decimal(places=2),
    },
    options={
        'exclude': ('memo_code', ),
    }
)
ScheduleBPageSchema = make_page_schema(ScheduleBSchema, page_type=paging.SeekPageSchema)
register_schema(ScheduleBSchema)
register_schema(ScheduleBPageSchema)


FilingsSchema = make_schema(
    models.Filings,
    fields={
        'pdf_url': ma.fields.Str(),
    },
)
augment_schemas(FilingsSchema)

# Copy schemas generated by helper methods to module namespace
globals().update(schemas)
