import re
import functools
import json

from collections import namedtuple

import marshmallow as ma
from marshmallow_sqlalchemy import ModelSchema
from marshmallow_pagination import schemas as paging_schemas

from webservices import utils, decoders
from webservices.spec import spec
from webservices.common import models
from webservices.common.models import db
from webservices import __API_VERSION__
from webservices.calendar import format_start_date, format_end_date
from marshmallow import pre_dump, post_dump
from sqlalchemy import func
import sqlalchemy as sa


spec.definition('OffsetInfo', schema=paging_schemas.OffsetInfoSchema)
spec.definition('SeekInfo', schema=paging_schemas.SeekInfoSchema)

# A namedtuple used to help capture any additional columns that should be
# included with exported data:
# field: the field object definining the relationship on a model, e.g.,
#   models.ScheduleA.committee (an object)
# column: the column object found in the related model, e.g.,
#   models.CommitteeHistory.name (an object)
# label: the label to use for the column in the query that will appear in the
# header row of the output, e.g.,
#   'committee_name' (a string)
# position: the spot within the list of columns that this should be inserted
# at; defaults to -1 (end of the list), e.g.,
#   1 (an integer, in this case the second spot in a list)

# Usage:  Define a custom attribute in a schema's Meta options object called
# 'relationships' and set to a list of one or more relationships.
#
# Note:  There is no clean way to provide default values for a namedtuple at
# the moment. This wrapper is modeled after the following post:
# https://ceasarjames.wordpress.com/2012/03/19/how-to-use-default-arguments-with-namedtuple/
class Relationship(namedtuple('Relationship', 'field column label position')):
    def __new__(cls, field, column, label, position=-1):
        return super(Relationship, cls).__new__(
            cls,
            field,
            column,
            label,
            position
        )

class BaseSchema(ModelSchema):

    def get_attribute(self, attr, obj, default):
        if '.' in attr:
            return super().get_attribute(attr, obj, default)
        return getattr(obj, attr, default)

class BaseEfileSchema(BaseSchema):
    summary_lines = ma.fields.Method("parse_summary_rows")
    report_year = ma.fields.Int()
    pdf_url = ma.fields.Str()
    #csv_url = ma.fields.Str()
    fec_url = ma.fields.Str()
    document_description = ma.fields.Str()
    beginning_image_number = ma.fields.Str()

    @post_dump
    def extract_summary_rows(self, obj):
        if obj.get('summary_lines'):
            for key, value in obj.get('summary_lines').items():
                #may be a way to pull these out using pandas?
                if key == 'nan':
                    continue
                obj[key] = value
            obj.pop('summary_lines')


def extract_columns(obj, column_a, column_b, descriptions):
    line_list = {}
    keys = zip(column_a, column_b)
    keys = list(keys)
    per = re.compile('(.+?(?=per))')
    ytd = re.compile('(.+?(?=ytd))')
    if obj.summary_lines:
        for row in obj.summary_lines:
            replace_a = re.sub(per, descriptions[int(row.line_number - 1)] + '_',
                               str(keys[int(row.line_number - 1)][0])).replace(' ', '_')
            replace_b = re.sub(ytd, descriptions[int(row.line_number - 1)] + '_',
                               str(keys[int(row.line_number - 1)][1])).replace(' ', '_')
            replace_a = make_period_string(replace_a)
            line_list[replace_a] = row.column_a
            line_list[replace_b] = row.column_b
        return line_list

def make_period_string(per_string=None):
    if per_string[-4:] == '_per':
        per_string += 'iod'
    return per_string


class EFilingF3PSchema(BaseEfileSchema):
    treasurer_name = ma.fields.Str()

    def parse_summary_rows(self, obj):
        line_list = {}
        state_map = {}

        keys = zip(decoders.f3p_col_a, decoders.f3p_col_b)
        per = re.compile('(.+?(?=per))')
        ytd = re.compile('(.+?(?=ytd))')

        descriptions = decoders.f3p_description
        keys = list(keys)
        if obj.summary_lines:

            for row in obj.summary_lines:
                if row.line_number >= 33 and row.line_number < 87:
                    state_map[keys[int(row.line_number - 1)][0]] = row.column_a
                    state_map[keys[int(row.line_number - 1)][1]] = row.column_b
                else:
                    replace_a = re.sub(per, descriptions[int(row.line_number - 1)] + '_', keys[int(row.line_number - 1)][0]).replace(' ', '_')
                    replace_b = re.sub(ytd, descriptions[int(row.line_number - 1)] + '_',
                                       str(keys[int(row.line_number - 1)][1])).replace(' ', '_')
                    replace_a = make_period_string(replace_a)
                    line_list[replace_a] = row.column_a
                    line_list[replace_b] = row.column_b
            line_list["state_allocations"] = state_map
            if not line_list.get('total_disbursements_per'):
                line_list['total_disbursements_per'] = float("-inf")

            cash = max(line_list.get('total_disbursements_per'), obj.total_disbursements)
            line_list['total_disbursements_per'] = cash
            if not line_list.get('total_receipts_per'):
                line_list['total_receipts_per'] = float("-inf")
            cash = max(line_list.get('total_receipts_per'), obj.total_receipts)
            line_list['total_receipts_per'] = cash
            return line_list

class EFilingF3Schema(BaseEfileSchema):
    candidate_name = ma.fields.Str()
    treasurer_name = ma.fields.Str()

    def parse_summary_rows(self, obj):
        descriptions = decoders.f3_description
        line_list = extract_columns(obj, decoders.f3_col_a, decoders.f3_col_b, descriptions)
        #final bit of data cleaning before json marshalling
        cash = max(line_list.get('coh_cop_i'), line_list.get('coh_cop_ii'))
        line_list["cash_on_hand_end_period"] = cash
        line_list.pop('coh_cop_ii')  # maybe  a api exception if i and ii are different?
        line_list.pop('coh_cop_i')
        cash = max(obj.cash_on_hand_beginning_period, line_list.get('coh_bop'))
        obj.cash_on_hand_beginning_period = None
        line_list.pop('coh_bop')
        line_list["cash_on_hand_beginning_period"] = cash
        cash = max(line_list.get('total_disbursements_per_i'), line_list.get('total_disbursements_per_ii'))
        line_list["total_disbursements_period"] = cash
        line_list.pop('total_disbursements_per_i')
        line_list.pop('total_disbursements_per_ii')
        cash = max(line_list.get('total_receipts_per_i'), line_list.get('ttl_receipts_ii'))
        line_list["total_receipts_period"] = cash
        line_list.pop('total_receipts_per_i')
        line_list.pop('ttl_receipts_ii')
        return line_list

class EFilingF3XSchema(BaseEfileSchema):
    def parse_summary_rows(self, obj):
        descriptions = decoders.f3x_description
        line_list = extract_columns(obj, decoders.f3x_col_a, decoders.f3x_col_b, descriptions)
        line_list['cash_on_hand_beginning_calendar_ytd'] = line_list.pop('coh_begin_calendar_yr')
        line_list['cash_on_hand_beginning_period'] = line_list.pop('coh_bop')
        return line_list

schema_map = {}
schema_map["BaseF3XFiling"] = EFilingF3XSchema
schema_map["BaseF3Filing"] = EFilingF3Schema
schema_map["BaseF3PFiling"] = EFilingF3PSchema


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
    mapped_schema = (
        BaseSchema
        if not schema_map.get(model.__name__)
        else schema_map.get(model.__name__)

    )
    return type(
        class_name,
        (mapped_schema, ),
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

def augment_itemized_aggregate_models(factory, committee_model, *models, namespace=schemas):
    for model in models:
        schema = factory(
            model,
            options={
                'exclude': ('committee',),
                'relationships': [
                    Relationship(
                        model.committee,
                        committee_model.name,
                        'committee_name',
                        1
                    ),
                ],
            }
        )
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

make_efiling_schema = functools.partial(
    make_schema,
    options={'exclude': ('idx', 'total_disbursements', 'total_receipts' )},
    fields={
        'pdf_url': ma.fields.Str(),
        'report_year': ma.fields.Int(),
    }
)


make_committee_schema = functools.partial(
    make_schema,
    options={'exclude': ('idx', 'treasurer_text')},
)

augment_models(
    make_efiling_schema,
    models.BaseF3PFiling,
    models.BaseF3XFiling,
    models.BaseF3Filing,
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
    fields={
        'federal_funds_flag': ma.fields.Boolean(attribute='flags.federal_funds_flag'),
        'has_raised_funds': ma.fields.Boolean(attribute='flags.has_raised_funds'),
    }
)


augment_models(
    make_candidate_schema,
    models.Candidate,
    models.CandidateDetail,

)
#built these schemas without make_candidate_schema, as it was filtering out the flags
augment_models(
    make_schema,
    models.CandidateHistory,
    models.CandidateTotal,
    models.CandidateFlags

)
class CandidateHistoryTotalSchema(schemas['CandidateHistorySchema'], schemas['CandidateTotalSchema'],schemas['CandidateFlagsSchema']):
    pass

CandidateHistoryTotalPageSchema = make_page_schema(CandidateHistoryTotalSchema)


CandidateSearchSchema = make_schema(
    models.Candidate,
    options={'exclude': ('idx', 'flags')},
    fields={
        'principal_committees': ma.fields.Nested(schemas['CommitteeSchema'], many=True),
        'federal_funds_flag': ma.fields.Boolean(attribute='flags.federal_funds_flag'),
        'has_raised_funds': ma.fields.Boolean(attribute='flags.has_raised_funds'),
    },
)
CandidateSearchPageSchema = make_page_schema(CandidateSearchSchema)
register_schema(CandidateSearchSchema)
register_schema(CandidateSearchPageSchema)


make_reports_schema = functools.partial(
    make_schema,
    fields={
        'pdf_url': ma.fields.Str(),
        #'csv_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'report_form': ma.fields.Str(),
        'document_description': ma.fields.Str(),
        'committee_type': ma.fields.Str(attribute='committee.committee_type'),
        'committee_name': ma.fields.Str(attribute='committee.name'),
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
        #'committee_type': ma.fields.Str(attribute='committee.committee_type'),
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
    models.CommitteeTotalsParty,
    models.CommitteeTotalsPac
)

register_schema(CommitteeReportsSchema)
register_schema(CommitteeReportsPageSchema)

totals_schemas = (
    schemas['CommitteeTotalsPresidentialSchema'],
    schemas['CommitteeTotalsHouseSenateSchema'],
    schemas['CommitteeTotalsPacPartySchema'],
    schemas['CommitteeTotalsIEOnlySchema'],
    schemas['CommitteeTotalsPartySchema'],
    schemas['CommitteeTotalsPacSchema']

)
CommitteeTotalsSchema = type('CommitteeTotalsSchema', totals_schemas, {})
CommitteeTotalsPageSchema = make_page_schema(CommitteeTotalsSchema)

register_schema(CommitteeTotalsSchema)
register_schema(CommitteeTotalsPageSchema)

ScheduleASchema = make_schema(
    models.ScheduleA,
    fields={
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
            'contributor_name_text',
            'contributor_employer_text',
            'contributor_occupation_text',
        ),
        'relationships': [
            Relationship(
                models.ScheduleA.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)

ScheduleAPageSchema = make_page_schema(ScheduleASchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleASchema)
register_schema(ScheduleAPageSchema)

ScheduleCSchema = make_schema(
    models.ScheduleC,
    fields={
        'sub_id': ma.fields.Str(),
        'pdf_url': ma.fields.Str(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),

    },
    options={
        'exclude': (
            'loan_source_name_text',
            'candidate_name_text',
        )
    },
)
ScheduleCPageSchema = make_page_schema(
    ScheduleCSchema,
)
ScheduleBByRecipientIDSchema = make_schema(
    models.ScheduleBByRecipientID,
    fields={
        'committee_name': ma.fields.Str(),
        'recipient_name': ma.fields.Str(),
    },
    options={
        'exclude': ('committee', 'recipient')
    },
)

augment_schemas(ScheduleBByRecipientIDSchema)

augment_itemized_aggregate_models(
    make_schema,
    models.CommitteeHistory,
    models.ScheduleAByZip,
    models.ScheduleABySize,
    models.ScheduleAByState,
    models.ScheduleAByEmployer,
    models.ScheduleAByOccupation,
    models.ScheduleBByRecipient,
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

ScheduleDSchema = make_schema(
    models.ScheduleD,
    fields={
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'pdf_url': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={

    },
)
ScheduleDPageSchema = make_page_schema(
    ScheduleDSchema
)

ScheduleFSchema = make_schema(
    models.ScheduleF,
    fields={
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'subordinate_committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'pdf_url': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={

    },
)
ScheduleFPageSchema = make_page_schema(
    ScheduleFSchema
)

CommunicationCostByCandidateSchema = make_aggregate_schema(models.CommunicationCostByCandidate)
augment_schemas(CommunicationCostByCandidateSchema)

ElectioneeringByCandidateSchema = make_aggregate_schema(models.ElectioneeringByCandidate)
augment_schemas(ElectioneeringByCandidateSchema)

ScheduleBSchema = make_schema(
    models.ScheduleB,
    fields={
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'recipient_committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={
        'exclude': (
            'recipient_name_text',
            'disbursement_description_text'
        ),
        'relationships': [
            Relationship(
                models.ScheduleB.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)
ScheduleBPageSchema = make_page_schema(ScheduleBSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleBSchema)
register_schema(ScheduleBPageSchema)

ScheduleESchema = make_schema(
    models.ScheduleE,
    fields={
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
            'payee_name_text',
        ),
        'relationships': [
            Relationship(
                models.ScheduleE.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)
ScheduleEPageSchema = make_page_schema(ScheduleESchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleESchema)
register_schema(ScheduleEPageSchema)

CommunicationCostSchema = make_schema(
    models.CommunicationCost,
)
CommunicationCostPageSchema = make_page_schema(CommunicationCostSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(CommunicationCostSchema)
register_schema(CommunicationCostPageSchema)

ElectioneeringSchema = make_schema(
    models.Electioneering,
    fields={'election_type': ma.fields.Str()},
    options={'exclude': ('idx', 'purpose_description_text', 'election_type_raw')},
)
ElectioneeringPageSchema = make_page_schema(ElectioneeringSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ElectioneeringSchema)
register_schema(ElectioneeringPageSchema)

FilingsSchema = make_schema(
    models.Filings,
    fields={
        'document_description': ma.fields.Str(),
        'beginning_image_number': ma.fields.Str(),
        'ending_image_number': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        #'csv_url': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
    },
    options={'exclude': ('committee', )},
)
augment_schemas(FilingsSchema)

EFilingsSchema = make_schema(
    models.EFilings,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'ending_image_number': ma.fields.Str(),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        #'csv_url': ma.fields.Str(),
        'is_amended': ma.fields.Boolean(),
        'document_description': ma.fields.Str(),
    },
    options={'exclude': ('report',)},
)
augment_schemas(EFilingsSchema)

ItemizedScheduleEfilingsSchema = make_schema(
    models.ScheduleEEfile,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'is_notice':ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'payee_name': ma.fields.Str(),
        #'csv_url': ma.fields.Str(),
    },
    #options={'exclude': ('e_filing',)},

)

augment_schemas(ItemizedScheduleEfilingsSchema)

ReportTypeSchema = make_schema(models.ReportType)
register_schema(ReportTypeSchema)

ReportingDatesSchema = make_schema(
    models.ReportDate,
    fields={
        'report_type': ma.fields.Str(),
        'report_type_full': ma.fields.Str(),
    },
    options={'exclude': ('trc_report_due_date_id', 'report')},
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
        'start_date': ma.fields.Function(format_start_date),
        'end_date': ma.fields.Function(format_end_date),
    },
    options={
        'exclude': (
            'summary_text', 'description_text'
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

class TotalsCommitteeSchema(schemas['CommitteeHistorySchema']):
    receipts = ma.fields.Decimal(places=2)
    disbursements = ma.fields.Decimal(places=2)
    cash_on_hand_end_period = ma.fields.Decimal(places=2)
    debts_owed_by_committee = ma.fields.Decimal(places=2)
    independent_expenditures = ma.fields.Decimal(places=2)

augment_schemas(
    ScheduleABySizeCandidateSchema,
    ScheduleAByStateCandidateSchema,
    TotalsCommitteeSchema,
)

RadAnalystSchema = make_schema(
    models.RadAnalyst,
    options={'exclude': ('idx', 'name_txt')},
)
RadAnalystPageSchema = make_page_schema(RadAnalystSchema)
register_schema(RadAnalystSchema)
register_schema(RadAnalystPageSchema)

EntityReceiptDisbursementTotalsSchema = make_schema(
    models.EntityReceiptDisbursementTotals,
    options={'exclude': ('idx','month', 'year')},
    fields={'date': ma.fields.Date(doc='The cumulative total for this month.')},
)
EntityReceiptDisbursementTotalsPageSchema = make_page_schema(EntityReceiptDisbursementTotalsSchema)
register_schema(EntityReceiptDisbursementTotalsSchema)
register_schema(EntityReceiptDisbursementTotalsPageSchema)

ScheduleAByStateRecipientTotalsSchema = make_schema(
    models.ScheduleAByStateRecipientTotals,
    options={'exclude': ('idx',)}
)
ScheduleAByStateRecipientTotalsPageSchema = make_page_schema(
    ScheduleAByStateRecipientTotalsSchema
)
register_schema(ScheduleAByStateRecipientTotalsSchema)
register_schema(ScheduleAByStateRecipientTotalsPageSchema)

# Copy schemas generated by helper methods to module namespace
globals().update(schemas)
