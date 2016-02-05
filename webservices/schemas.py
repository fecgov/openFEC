import re
import functools

import marshmallow as ma
from marshmallow_sqlalchemy import ModelSchema
from marshmallow_pagination import schemas as paging_schemas

from webservices import utils
from webservices.spec import spec
from webservices.common import models
from webservices import __API_VERSION__


spec.definition('OffsetInfo', schema=paging_schemas.OffsetInfoSchema)
spec.definition('SeekInfo', schema=paging_schemas.SeekInfoSchema)


class BaseSchema(ModelSchema):

    def get_attribute(self, attr, obj, default):
        if '.' in attr:
            return super().get_attribute(attr, obj, default)
        return getattr(obj, attr, default)


def register_schema(schema, definition_name=None):
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)
    spec.definition(definition_name, schema=schema)


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
        (BaseSchema, ),
        utils.extend({'Meta': Meta}, fields or {}),
    )


def make_page_schema(schema, page_type=paging_schemas.OffsetPageSchema, class_name=None,
                     definition_name=None):
    class_name = class_name or '{0}PageSchema'.format(re.sub(r'Schema$', '', schema.__name__))

    class Meta:
        results_schema_class = schema

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


make_committee_schema = functools.partial(
    make_schema,
    options={'exclude': ('idx', 'treasurer_text')},
)

augment_models(
    make_committee_schema,
    models.Committee,
    models.CommitteeHistory,
    models.CommitteeDetail,
)


make_candidate_schema = functools.partial(
    make_schema,
    options={'exclude': ('idx', 'principal_committees')},
)

augment_models(
    make_candidate_schema,
    models.Candidate,
    models.CandidateDetail,
    models.CandidateHistory,
)

CandidateSearchSchema = make_schema(
    models.Candidate,
    options={'exclude': ('idx', )},
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
        'beginning_image_number': ma.fields.Str(),
        'end_image_number': ma.fields.Str(),
    },
    options={'exclude': ('idx', 'committee')},
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

make_totals_schema = functools.partial(
    make_schema,
    fields={
        'pdf_url': ma.fields.Str(),
        'report_form': ma.fields.Str(),
        'committee_type': ma.fields.Str(attribute='committee.committee_type'),
        'last_cash_on_hand_end_period': ma.fields.Decimal(places=2),
        'last_beginning_image_number': ma.fields.Str(),
    },
)
augment_models(
    make_totals_schema,
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
        'contribution_receipt_amount': ma.fields.Decimal(places=2),
        'contributor_aggregate_ytd': ma.fields.Decimal(places=2),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={
        'exclude': (
            'memo_code',
            'contributor_name_text',
            'contributor_employer_text',
            'contributor_occupation_text',
        ),
    }
)
ScheduleAPageSchema = make_page_schema(ScheduleASchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleASchema)
register_schema(ScheduleAPageSchema)

augment_models(
    make_schema,
    models.ScheduleAByZip,
    models.ScheduleABySize,
    models.ScheduleAByState,
    models.ScheduleAByEmployer,
    models.ScheduleAByOccupation,
    models.ScheduleAByContributor,
    models.ScheduleBByRecipient,
    models.ScheduleBByRecipientID,
    models.ScheduleBByPurpose,
)

make_aggregate_schema = functools.partial(
    make_schema,
    fields={
        'committee_id': ma.fields.Str(),
        'candidate_id': ma.fields.Str(),
        'committee_name': ma.fields.Str(),
        'candidate_name': ma.fields.Str(),
    },
    options={'exclude': ('idx', 'committee', 'candidate')},
)

ScheduleEByCandidateSchema = make_aggregate_schema(models.ScheduleEByCandidate)
augment_schemas(ScheduleEByCandidateSchema)

CommunicationCostByCandidateSchema = make_aggregate_schema(models.CommunicationCostByCandidate)
augment_schemas(CommunicationCostByCandidateSchema)

ElectioneeringByCandidateSchema = make_aggregate_schema(models.ElectioneeringByCandidate)
augment_schemas(ElectioneeringByCandidateSchema)

ScheduleBSchema = make_schema(
    models.ScheduleB,
    fields={
        'pdf_url': ma.fields.Str(),
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'recipient_committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={
        'exclude': (
            'memo_code',
            'recipient_name_text',
            'disbursement_description_text'
        ),
    }
)
ScheduleBPageSchema = make_page_schema(ScheduleBSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleBSchema)
register_schema(ScheduleBPageSchema)

ScheduleESchema = make_schema(
    models.ScheduleE,
    fields={
        'pdf_url': ma.fields.Str(),
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'expenditure_amount': ma.fields.Decimal(places=2),
        'office_total_ytd': ma.fields.Decimal(places=2),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={
        'exclude': (
            'memo_code',
            'payee_name_text',
        ),
    }
)
ScheduleEPageSchema = make_page_schema(ScheduleESchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleESchema)
register_schema(ScheduleEPageSchema)

CommunicationCostSchema = make_schema(
    models.CommunicationCost,
    fields={'pdf_url': ma.fields.Str()},
    options={'exclude': ('idx', )},
)
CommunicationCostPageSchema = make_page_schema(CommunicationCostSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(CommunicationCostSchema)
register_schema(CommunicationCostPageSchema)

ElectioneeringSchema = make_schema(
    models.Electioneering,
    fields={
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'candidate': ma.fields.Nested(schemas['CandidateHistorySchema']),
        'pdf_url': ma.fields.Str(),
    },
    options={'exclude': ('idx', )},
)
ElectioneeringPageSchema = make_page_schema(ElectioneeringSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ElectioneeringSchema)
register_schema(ElectioneeringPageSchema)

FilingsSchema = make_schema(
    models.Filings,
    fields={
        'pdf_url': ma.fields.Str(),
        'document_description': ma.fields.Str(),
        'beginning_image_number': ma.fields.Str(),
        'ending_image_number': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={'exclude': ('committee', )},
)
augment_schemas(FilingsSchema)

ReportTypeSchema = make_schema(models.ReportType)
register_schema(ReportTypeSchema)

ReportingDatesSchema = make_schema(
    models.ReportDate,
    fields = {
        'report_type': ma.fields.Str(),
        'report_type_full': ma.fields.Str(),
    },
    options = {'exclude': ('trc_report_due_date_id', 'report')},
)
ReportingDatesPageSchema = make_page_schema(ReportingDatesSchema)
augment_schemas(ReportingDatesSchema)

ElectionDatesSchema = make_schema(
    models.ElectionDate,
    fields={
        'election_type_full': ma.fields.Str(),
        'active_election': ma.fields.Boolean(),
    },
    options={
        'exclude': ('trc_election_id', 'election_status_id'),
    },
)
ElectionDatesPageSchema = make_page_schema(ElectionDatesSchema)
augment_schemas(ElectionDatesSchema)

CalendarDateSchema = make_schema(
    models.CalendarDate,
    fields={
        'summary': ma.fields.Str(),
        'description': ma.fields.Str(),
    },
    options={
        'exclude': (
            'summary_text', 'description_text',
        )
    },
)
CalendarDatePageSchema = make_page_schema(CalendarDateSchema)
augment_schemas(CalendarDateSchema)


class ElectionSearchSchema(ma.Schema):
    state = ma.fields.Str()
    office = ma.fields.Str()
    district = ma.fields.Str()
    cycle = ma.fields.Int(attribute='two_year_period')
    incumbent_id = ma.fields.Str(attribute='cand_id')
    incumbent_name = ma.fields.Str(attribute='cand_name')
augment_schemas(ElectionSearchSchema)

class ElectionSummarySchema(ApiSchema):
    count = ma.fields.Int()
    receipts = ma.fields.Decimal(places=2)
    disbursements = ma.fields.Decimal(places=2)
    independent_expenditures = ma.fields.Decimal(places=2)
register_schema(ElectionSummarySchema)

class ElectionSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    candidate_name = ma.fields.Str()
    incumbent_challenge_full = ma.fields.Str()
    party_full = ma.fields.Str()
    committee_ids = ma.fields.List(ma.fields.Str)
    total_receipts = ma.fields.Decimal(places=2)
    total_disbursements = ma.fields.Decimal(places=2)
    cash_on_hand_end_period = ma.fields.Decimal(places=2)
    won = ma.fields.Boolean()
augment_schemas(ElectionSchema)

class ScheduleABySizeCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Decimal(places=2)
    size = ma.fields.Int()

class ScheduleAByStateCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Decimal(places=2)
    state = ma.fields.Str()
    state_full = ma.fields.Str()

class ScheduleAByContributorTypeCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Decimal(places=2)
    individual = ma.fields.Bool()

class TotalsCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    receipts = ma.fields.Decimal(places=2)
    disbursements = ma.fields.Decimal(places=2)
    cash_on_hand_end_period = ma.fields.Decimal(places=2)
    debts_owed_by_committee = ma.fields.Decimal(places=2)

augment_schemas(
    ScheduleABySizeCandidateSchema,
    ScheduleAByStateCandidateSchema,
    ScheduleAByContributorTypeCandidateSchema,
    TotalsCandidateSchema,
)

# Copy schemas generated by helper methods to module namespace
globals().update(schemas)
