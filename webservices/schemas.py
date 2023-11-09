import re
import functools

from collections import namedtuple

import marshmallow as ma
from marshmallow_sqlalchemy import SQLAlchemySchema, SQLAlchemyAutoSchema
from marshmallow_pagination import schemas as paging_schemas

from webservices import utils, decoders
from webservices.spec import spec
from webservices.common import models
from webservices import __API_VERSION__
from webservices.calendar import format_start_date, format_end_date
from marshmallow import post_dump

spec.components.schema('OffsetInfo', schema=paging_schemas.OffsetInfoSchema)
spec.components.schema('SeekInfo', schema=paging_schemas.SeekInfoSchema)

# A namedtuple used to help capture any additional columns that should be
# included with exported data:
# field: the field object definining the relationship on a model,e.g.,
#   models.ScheduleA.committee (an object)
# column: the column object found in the related model,e.g.,
#   models.CommitteeHistory.name (an object)
# label: the label to use for the column in the query that will appear in the
# header row of the output,e.g.,
#   'committee_name' (a string)
# position: the spot within the list of columns that this should be inserted
# at; defaults to -1 (end of the list),e.g.,
#   1 (an integer,in this case the second spot in a list)

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


class BaseSchema(SQLAlchemySchema):
    class Meta:
        sqla_session = models.db.session
        load_instance = True
        include_relationships = True
        include_fk = True

    def get_attribute(self, obj, attr, default):
        if '.' in attr:
            return super().get_attribute(obj, attr, default)
        return getattr(obj, attr, default)


class BaseAutoSchema(SQLAlchemyAutoSchema):
    def get_attribute(self, obj, attr, default):
        if '.' in attr:
            return super().get_attribute(obj, attr, default)
        return getattr(obj, attr, default)


class BaseEfileSchema(BaseAutoSchema):
    class Meta:
        sqla_session = models.db.session
        load_instance = True
        include_relationships = True
        include_fk = True

    summary_lines = ma.fields.Method("parse_summary_rows")
    report_year = ma.fields.Int()
    pdf_url = ma.fields.Str()
    csv_url = ma.fields.Str()
    fec_url = ma.fields.Str()
    document_description = ma.fields.Str()
    beginning_image_number = ma.fields.Str()
    most_recent_filing = ma.fields.Int()
    most_recent = ma.fields.Bool()
    amendment_chain = ma.fields.List(ma.fields.Int())
    amended_by = ma.fields.Int()
    is_amended = ma.fields.Bool()
    fec_file_id = ma.fields.Str()

    @post_dump
    def extract_summary_rows(self, obj, **kwargs):
        if obj.get('summary_lines'):
            for key, value in obj.get('summary_lines').items():
                # may be a way to pull these out using pandas?
                if key == 'nan':
                    continue
                obj[key] = value
            obj.pop('summary_lines')
        if obj.get('amendment'):
            obj.pop('amendment')
        return obj


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


class BaseF3PFilingSchema(BaseEfileSchema):
    class Meta(BaseEfileSchema.Meta):
        model = models.BaseF3PFiling
        exclude = ('total_disbursements', 'total_receipts')

    treasurer_name = ma.fields.Str()

    def parse_summary_rows(self, obj, **kwargs):
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
                    replace_a = re.sub(per, descriptions[int(row.line_number - 1)] + '_',
                                       keys[int(row.line_number - 1)][0]).replace(' ', '_')
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


class BaseF3FilingSchema(BaseEfileSchema):
    class Meta(BaseEfileSchema.Meta):
        model = models.BaseF3Filing

    candidate_name = ma.fields.Str()
    treasurer_name = ma.fields.Str()

    def parse_summary_rows(self, obj, **kwargs):
        descriptions = decoders.f3_description
        line_list = extract_columns(obj, decoders.f3_col_a, decoders.f3_col_b, descriptions)
        # final bit of data cleaning before json marshalling
        # If values are None,fall back to 0 to prevent errors
        if line_list:
            coh_cop_i = line_list.get('coh_cop_i') if line_list.get('coh_cop_i') else 0
            coh_cop_ii = line_list.get('coh_cop_ii') if line_list.get('coh_cop_ii') else 0
            cash = max(coh_cop_i, coh_cop_ii)
            line_list["cash_on_hand_end_period"] = cash
            # i and ii should always be the same but data can be wrong
            line_list.pop('coh_cop_ii')
            line_list.pop('coh_cop_i')
            coh_bop = line_list.get('coh_bop') if line_list.get('coh_bop') else 0
            cash_on_hand_beginning_period = (
                obj.cash_on_hand_beginning_period
                if obj.cash_on_hand_beginning_period
                else 0
            )
            cash = max(cash_on_hand_beginning_period, coh_bop)
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


class BaseF3XFilingSchema(BaseEfileSchema):
    class Meta(BaseEfileSchema.Meta):
        model = models.BaseF3XFiling

    def parse_summary_rows(self, obj, **kwargsj):
        descriptions = decoders.f3x_description
        line_list = extract_columns(obj, decoders.f3x_col_a, decoders.f3x_col_b, descriptions)
        if line_list:
            line_list['cash_on_hand_beginning_calendar_ytd'] = line_list.pop('coh_begin_calendar_yr')
            line_list['cash_on_hand_beginning_period'] = line_list.pop('coh_bop')
        return line_list


schema_map = {}
schema_map["BaseF3XFiling"] = BaseF3XFilingSchema
schema_map["BaseF3Filing"] = BaseF3FilingSchema
schema_map["BaseF3PFiling"] = BaseF3PFilingSchema


def register_schema(schema, definition_name=None):
    definition_name = definition_name or re.sub(r'Schema$', '', schema.__name__)
    spec.components.schema(definition_name, schema=schema)


def make_schema(model, class_name=None, fields=None, options=None, BaseSchema=BaseAutoSchema):
    class_name = class_name or '{0}Schema'.format(model.__name__)
    Meta = type(
        'Meta',
        (object,),
        utils.extend(
            {
                'model': model,
                'sqla_session': models.db.session,
                'load_instance': True,
                'include_relationships': True,
                'include_fk': True
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
        (mapped_schema,),
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
                'exclude': ('idx', 'committee',),
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
    @post_dump
    def _postprocess(self, data, **kwargs):
        ret = {'api_version': __API_VERSION__}
        ret.update(data)
        return ret


class BaseSearchSchema(ma.Schema):
    id = ma.fields.Str()
    name = ma.fields.Str()


class CandidateSearchBaseSchema(BaseSearchSchema):
    office_sought = ma.fields.Str()


class CommitteeSearchSchema(BaseSearchSchema):
    is_active = ma.fields.Boolean()


class CandidateSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        CandidateSearchBaseSchema,
        ref='#/definitions/CandidateSearch',
        many=True,
    )


class CommitteeSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        CommitteeSearchSchema,
        ref='#/definitions/CommitteeSearch',
        many=True,
    )


register_schema(CandidateSearchBaseSchema, 'CandidateSearchBaseSchema')
register_schema(CandidateSearchListSchema, 'CandidateSearchListSchema')
register_schema(CommitteeSearchSchema)
register_schema(CommitteeSearchListSchema)


class AuditCandidateSearchSchema(BaseSearchSchema):
    pass


class AuditCommitteeSearchSchema(BaseSearchSchema):
    pass


class AuditCandidateSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        AuditCandidateSearchSchema,
        ref='#/definitions/AuditCandidateSearch',
        many=True,
    )


class AuditCommitteeSearchListSchema(ApiSchema):
    results = ma.fields.Nested(
        AuditCommitteeSearchSchema,
        ref='#/definitions/AuditCommitteeSearch',
        many=True,
    )


register_schema(AuditCandidateSearchSchema)
register_schema(AuditCandidateSearchListSchema)
register_schema(AuditCommitteeSearchSchema)
register_schema(AuditCommitteeSearchListSchema)

augment_schemas(BaseF3PFilingSchema, BaseF3FilingSchema, BaseF3XFilingSchema)

# create pac sponsor candidate schema
PacSponsorCandidateschema = make_schema(
    models.PacSponsorCandidate,
    options={'exclude': ('idx', 'committee_id',)},
)
# End create pac sponsor candidate schema

# create principal committee schema
PrincipalCommitteeSchema = make_schema(
    models.Committee,
    class_name='PrincipalCommitteeSchema',
    options={'exclude': ('idx', 'treasurer_text', 'sponsor_candidate_list', 'sponsor_candidate_ids')},
)
# End create principal committee schema

CommitteeSchema = make_schema(
    models.Committee,
    fields={
        'sponsor_candidate_list': ma.fields.Nested(PacSponsorCandidateschema, many=True),
        'first_f1_date': ma.fields.Date(),
        'first_file_date': ma.fields.Date(),
        'last_f1_date': ma.fields.Date(),
        'last_file_date': ma.fields.Date()
    },
    options={'exclude': ('idx', 'treasurer_text',)},
)
CommitteePageSchema = make_page_schema(CommitteeSchema)
register_schema(CommitteeSchema)
register_schema(CommitteePageSchema)

# create JFC committee schema
JFCCommitteeSchema = make_schema(
    models.JFCCommittee,
    class_name='JFCCommitteeSchema',
    options={'exclude': ('idx', 'committee_id',  'most_recent_filing_flag',)},
    )
# End create JFC committee schema

make_committees_schema = functools.partial(
    make_schema,
    fields={
        'jfc_committee': ma.fields.Nested(JFCCommitteeSchema, many=True),
    },
    options={'exclude': ('idx', 'treasurer_text',)},
)

augment_models(
    make_committees_schema,
    models.CommitteeHistory,
    models.CommitteeDetail,
    models.CommitteeHistoryProfile,
)


make_candidate_schema = functools.partial(
    make_schema,
    fields={
        'federal_funds_flag': ma.fields.Boolean(attribute='flags.federal_funds_flag'),
        'has_raised_funds': ma.fields.Boolean(attribute='flags.has_raised_funds'),
    },
    options={'exclude': ('idx', 'principal_committees', 'flags')},
)

augment_models(
    make_candidate_schema,
    models.Candidate
)

candidate_detail_schema = make_schema(
    models.CandidateDetail,
    fields={
        'federal_funds_flag': ma.fields.Boolean(attribute='flags.federal_funds_flag'),
        'has_raised_funds': ma.fields.Boolean(attribute='flags.has_raised_funds'),
    },
    options={'exclude': ('idx',)},
)

augment_schemas(candidate_detail_schema)

# built these schemas without make_candidate_schema,as it was filtering out the flags
make_candidate_total_schema = make_schema(
    models.CandidateTotal,
    fields={
        'receipts': ma.fields.Float(),
        'disbursements': ma.fields.Float(),
        'individual_itemized_contributions': ma.fields.Float(),
        'transfers_from_other_authorized_committee': ma.fields.Float(),
        'other_political_committee_contributions': ma.fields.Float()
    }
)

augment_schemas(make_candidate_total_schema)

make_candidate_history_schema = make_schema(
    models.CandidateHistory,
    options={'exclude': ('idx',)}
)

augment_schemas(make_candidate_history_schema)

augment_models(
    make_schema,
    models.CandidateFlags
)


class CandidateHistoryTotalSchema(schemas['CandidateHistorySchema'],
                                  schemas['CandidateTotalSchema'],
                                  schemas['CandidateFlagsSchema']):
    pass


augment_schemas(CandidateHistoryTotalSchema)

CandidateSearchSchema = make_schema(
    models.Candidate,
    fields={
        'principal_committees': ma.fields.Nested('PrincipalCommitteeSchema', many=True),
        'federal_funds_flag': ma.fields.Boolean(attribute='flags.federal_funds_flag'),
        'has_raised_funds': ma.fields.Boolean(attribute='flags.has_raised_funds'),
    },
    options={'exclude': ('idx', 'flags')},
)
CandidateSearchPageSchema = make_page_schema(CandidateSearchSchema)
register_schema(CandidateSearchSchema, 'CandidateSearch')
register_schema(CandidateSearchPageSchema, 'CandidateSearchPage')

committee_fields = {
        'pdf_url': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'report_form': ma.fields.Str(),
        'document_description': ma.fields.Str(),
        'committee_type': ma.fields.Str(attribute='committee.committee_type'),
        'beginning_image_number': ma.fields.Str(),
        'end_image_number': ma.fields.Str(),
        'fec_file_id': ma.fields.Str(),
        'total_receipts_period': ma.fields.Float(),
        'total_disbursements_ytd': ma.fields.Float(),
        'total_disbursements_period': ma.fields.Float(),
        'total_contributions_ytd': ma.fields.Float(),
        'total_contributions_period': ma.fields.Float(),
        'refunded_political_party_committee_contributions_ytd': ma.fields.Float(),
        'total_contribution_refunds_period': ma.fields.Float(),
        'total_contribution_refunds_ytd': ma.fields.Float(),
        'refunded_individual_contributions_period': ma.fields.Float(),
        'refunded_individual_contributions_ytd': ma.fields.Float(),
        'refunded_other_political_committee_contributions_period': ma.fields.Float(),
        'refunded_other_political_committee_contributions_ytd': ma.fields.Float(),
        'refunded_political_party_committee_contributions_period': ma.fields.Float(),
        'previous_file_number': ma.fields.Float(),
        'most_recent_file_number': ma.fields.Float(),
        'cash_on_hand_beginning_period': ma.fields.Float(),
        'cash_on_hand_end_period': ma.fields.Float(),
        'debts_owed_by_committee': ma.fields.Float(),
        'debts_owed_to_committee': ma.fields.Float(),
        'other_disbursements_period': ma.fields.Float(),
        'other_disbursements_ytd': ma.fields.Float(),
        'other_political_committee_contributions_period': ma.fields.Float(),
        'other_political_committee_contributions_ytd': ma.fields.Float(),
        'political_party_committee_contributions_period': ma.fields.Float(),
        'political_party_committee_contributions_ytd': ma.fields.Float()
    }

committee_reports_presidential_schema = make_schema(
        models.CommitteeReportsPresidential,
        fields=utils.extend(
            committee_fields,
            {
                'candidate_contribution_period': ma.fields.Float(),
                'candidate_contribution_ytd': ma.fields.Float(),
                'exempt_legal_accounting_disbursement_period': ma.fields.Float(),
                'exempt_legal_accounting_disbursement_ytd': ma.fields.Float(),
                'expenditure_subject_to_limits': ma.fields.Float(),
                'federal_funds_period': ma.fields.Float(),
                'federal_funds_ytd': ma.fields.Float(),
                'fundraising_disbursements_period': ma.fields.Float(),
                'fundraising_disbursements_ytd': ma.fields.Float(),
                'items_on_hand_liquidated': ma.fields.Float(),
                'loans_received_from_candidate_period': ma.fields.Float(),
                'loans_received_from_candidate_ytd': ma.fields.Float(),
                'offsets_to_fundraising_expenditures_ytd': ma.fields.Float(),
                'offsets_to_fundraising_expenditures_period': ma.fields.Float(),
                'offsets_to_legal_accounting_period': ma.fields.Float(),
                'offsets_to_legal_accounting_ytd': ma.fields.Float(),
                'operating_expenditures_period': ma.fields.Float(),
                'operating_expenditures_ytd': ma.fields.Float(),
                'other_loans_received_period': ma.fields.Float(),
                'other_loans_received_ytd': ma.fields.Float(),
                'other_receipts_period': ma.fields.Float(),
                'other_receipts_ytd': ma.fields.Float(),
                'repayments_loans_made_by_candidate_period': ma.fields.Float(),
                'repayments_loans_made_candidate_ytd': ma.fields.Float(),
                'repayments_other_loans_period': ma.fields.Float(),
                'repayments_other_loans_ytd': ma.fields.Float(),
                'subtotal_summary_period': ma.fields.Float(),
                'total_loan_repayments_made_period': ma.fields.Float(),
                'total_loan_repayments_made_ytd': ma.fields.Float(),
                'total_loans_received_period': ma.fields.Float(),
                'total_loans_received_ytd': ma.fields.Float(),
                'total_offsets_to_operating_expenditures_period': ma.fields.Float(),
                'total_offsets_to_operating_expenditures_ytd': ma.fields.Float(),
                'total_period': ma.fields.Float(),
                'total_ytd': ma.fields.Float(),
                'transfers_from_affiliated_committee_period': ma.fields.Float(),
                'transfers_from_affiliated_committee_ytd': ma.fields.Float(),
                'transfers_to_other_authorized_committee_period': ma.fields.Float(),
                'transfers_to_other_authorized_committee_ytd': ma.fields.Float(),
                'net_contributions_cycle_to_date': ma.fields.Float(),
                'net_operating_expenditures_cycle_to_date': ma.fields.Float()
            }),
        options={'exclude': ('idx', 'committee', 'filer_name_text')}
)

augment_schemas(committee_reports_presidential_schema)

committee_reports_hs_schema = make_schema(
    models.CommitteeReportsHouseSenate,
    fields=utils.extend(
        committee_fields,
        {
            'aggregate_amount_personal_contributions_general': ma.fields.Float(),
            'aggregate_contributions_personal_funds_primary': ma.fields.Float(),
            'all_other_loans_period': ma.fields.Float(),
            'all_other_loans_ytd': ma.fields.Float(),
            'candidate_contribution_period': ma.fields.Float(),
            'candidate_contribution_ytd': ma.fields.Float(),
            'gross_receipt_authorized_committee_general': ma.fields.Float(),  # missing
            'gross_receipt_authorized_committee_primary': ma.fields.Float(),  # missing
            'gross_receipt_minus_personal_contribution_general': ma.fields.Float(),
            'gross_receipt_minus_personal_contributions_primary': ma.fields.Float(),
            'loan_repayments_candidate_loans_period': ma.fields.Float(),
            'loan_repayments_candidate_loans_ytd': ma.fields.Float(),
            'loan_repayments_other_loans_period': ma.fields.Float(),
            'loan_repayments_other_loans_ytd': ma.fields.Float(),
            'loans_made_by_candidate_period': ma.fields.Float(),
            'loans_made_by_candidate_ytd': ma.fields.Float(),
            'net_contributions_ytd': ma.fields.Float(),
            'net_contributions_period': ma.fields.Float(),
            'net_operating_expenditures_period': ma.fields.Float(),
            'net_operating_expenditures_ytd': ma.fields.Float(),
            'operating_expenditures_period': ma.fields.Float(),
            'operating_expenditures_ytd': ma.fields.Float(),
            'other_receipts_period': ma.fields.Float(),
            'other_receipts_ytd': ma.fields.Float(),
            'refunds_total_contributions_col_total_ytd': ma.fields.Float(),
            'subtotal_period': ma.fields.Float(),
            'total_contribution_refunds_col_total_period': ma.fields.Float(),
            'total_contributions_column_total_period': ma.fields.Float(),  # missing
            'total_loan_repayments_made_period': ma.fields.Float(),
            'total_loan_repayments_made_ytd': ma.fields.Float(),
            'total_loans_received_period': ma.fields.Float(),
            'total_loans_received_ytd': ma.fields.Float(),
            'total_offsets_to_operating_expenditures_period': ma.fields.Float(),
            'total_offsets_to_operating_expenditures_ytd': ma.fields.Float(),
            'total_operating_expenditures_period': ma.fields.Float(),
            'total_operating_expenditures_ytd': ma.fields.Float(),
            'transfers_from_other_authorized_committee_period': ma.fields.Float(),
            'transfers_from_other_authorized_committee_ytd': ma.fields.Float(),
            'transfers_to_other_authorized_committee_period': ma.fields.Float(),
            'transfers_to_other_authorized_committee_ytd': ma.fields.Float(),
        }),
    options={'exclude': ('idx', 'committee', 'filer_name_text')}
    )

augment_schemas(committee_reports_hs_schema)

committee_reports_pac_schema = make_schema(
        models.CommitteeReportsPacParty,
        fields=utils.extend(
            committee_fields,
            {
                'all_loans_received_period': ma.fields.Float(),
                'all_loans_received_ytd': ma.fields.Float(),
                'allocated_federal_election_levin_share_period': ma.fields.Float(),
                'cash_on_hand_beginning_calendar_ytd': ma.fields.Float(),
                'cash_on_hand_close_ytd': ma.fields.Float(),
                'coordinated_expenditures_by_party_committee_period': ma.fields.Float(),
                'coordinated_expenditures_by_party_committee_ytd': ma.fields.Float(),
                'fed_candidate_committee_contribution_refunds_ytd': ma.fields.Float(),
                'fed_candidate_committee_contributions_period': ma.fields.Float(),
                'fed_candidate_committee_contributions_ytd': ma.fields.Float(),
                'fed_candidate_contribution_refunds_period': ma.fields.Float(),
                'independent_expenditures_period': ma.fields.Float(),
                'independent_expenditures_ytd': ma.fields.Float(),
                'loan_repayments_made_period': ma.fields.Float(),
                'loan_repayments_made_ytd': ma.fields.Float(),
                'loan_repayments_received_period': ma.fields.Float(),
                'loan_repayments_received_ytd': ma.fields.Float(),
                'loans_made_period': ma.fields.Float(),
                'loans_made_ytd': ma.fields.Float(),
                'net_contributions_period': ma.fields.Float(),
                'net_contributions_ytd': ma.fields.Float(),
                'net_operating_expenditures_period': ma.fields.Float(),
                'net_operating_expenditures_ytd': ma.fields.Float(),
                'non_allocated_fed_election_activity_period': ma.fields.Float(),
                'non_allocated_fed_election_activity_ytd': ma.fields.Float(),
                'nonfed_share_allocated_disbursements_period': ma.fields.Float(),
                'other_fed_operating_expenditures_period': ma.fields.Float(),
                'other_fed_operating_expenditures_ytd': ma.fields.Float(),
                'other_fed_receipts_period': ma.fields.Float(),
                'other_fed_receipts_ytd': ma.fields.Float(),
                'shared_fed_activity_nonfed_ytd': ma.fields.Float(),
                'shared_fed_activity_period': ma.fields.Float(),
                'shared_fed_activity_ytd': ma.fields.Float(),
                'shared_fed_operating_expenditures_period': ma.fields.Float(),
                'shared_fed_operating_expenditures_ytd': ma.fields.Float(),
                'shared_nonfed_operating_expenditures_period': ma.fields.Float(),
                'shared_nonfed_operating_expenditures_ytd': ma.fields.Float(),
                'subtotal_summary_page_period': ma.fields.Float(),
                'subtotal_summary_ytd': ma.fields.Float(),
                'total_fed_disbursements_period': ma.fields.Float(),
                'total_fed_disbursements_ytd': ma.fields.Float(),
                'total_fed_election_activity_period': ma.fields.Float(),
                'total_fed_election_activity_ytd': ma.fields.Float(),
                'total_fed_operating_expenditures_period': ma.fields.Float(),
                'total_fed_operating_expenditures_ytd': ma.fields.Float(),
                'total_fed_receipts_period': ma.fields.Float(),
                'total_fed_receipts_ytd': ma.fields.Float(),
                'total_nonfed_transfers_period': ma.fields.Float(),
                'total_nonfed_transfers_ytd': ma.fields.Float(),
                'total_operating_expenditures_period': ma.fields.Float(),
                'total_operating_expenditures_ytd': ma.fields.Float(),
                'transfers_from_affiliated_party_period': ma.fields.Float(),
                'transfers_from_affiliated_party_ytd': ma.fields.Float(),
                'transfers_from_nonfed_account_period': ma.fields.Float(),
                'transfers_from_nonfed_account_ytd': ma.fields.Float(),
                'transfers_from_nonfed_levin_period': ma.fields.Float(),
                'transfers_from_nonfed_levin_ytd': ma.fields.Float(),
                'transfers_to_affiliated_committee_period': ma.fields.Float(),
                'transfers_to_affilitated_committees_ytd': ma.fields.Float()
            }),
        options={'exclude': ('idx', 'committee', 'filer_name_text')}
)

augment_schemas(committee_reports_pac_schema)

committee_reports_ie_schema = make_schema(
    models.CommitteeReportsIEOnly,
    fields={
        'pdf_url': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'report_form': ma.fields.Str(),
        'document_description': ma.fields.Str(),
        'committee_type': ma.fields.Str(attribute='committee.committee_type'),
        'beginning_image_number': ma.fields.Str(),
        'end_image_number': ma.fields.Str(),
        'fec_file_id': ma.fields.Str(),
        'independent_contributions_period': ma.fields.Float(),
        'independent_expenditures_period': ma.fields.Float()
    },
    options={'exclude': ('idx', 'spender_name_text')},
)

augment_schemas(committee_reports_ie_schema)

reports_schemas = (
    schemas['CommitteeReportsPresidentialSchema'],
    schemas['CommitteeReportsHouseSenateSchema'],
    schemas['CommitteeReportsPacPartySchema'],
    schemas['CommitteeReportsIEOnlySchema'],
)
CommitteeReportsSchema = type('CommitteeReportsSchema', reports_schemas, {})
CommitteeReportsPageSchema = make_page_schema(CommitteeReportsSchema)

register_schema(CommitteeReportsSchema)
register_schema(CommitteeReportsPageSchema)

entity_fields = {
    'pdf_url': ma.fields.Str(),
    'report_form': ma.fields.Str(),
    'last_cash_on_hand_end_period': ma.fields.Float(),
    'last_beginning_image_number': ma.fields.Str(),
    'transaction_coverage_date': ma.fields.Date(
        attribute='transaction_coverage.transaction_coverage_date',
        default=None),
    'individual_contributions_percent': ma.fields.Float(),
    'party_and_other_committee_contributions_percent': ma.fields.Float(),
    'contributions_ie_and_party_expenditures_made_percent': ma.fields.Float(),
    'operating_expenditures_percent': ma.fields.Float(),
}
# All /totals/entity_type/except 'pac','party','pac-party'
make_totals_schema = functools.partial(
    make_schema,
    fields=utils.extend(
        entity_fields,
        {'cash_on_hand_beginning_period': ma.fields.Float()},
        {'all_other_loans': ma.fields.Float()},
        {'candidate_contribution': ma.fields.Float()},
        {'disbursements': ma.fields.Float()},
        {'individual_contributions': ma.fields.Float()},
        {'individual_itemized_contributions': ma.fields.Float()},
        {'individual_unitemized_contributions': ma.fields.Float()},
        {'last_cash_on_hand_end_period': ma.fields.Float()},
        {'last_debts_owed_by_committee': ma.fields.Float()},
        {'last_debts_owed_to_committee': ma.fields.Float()},
        {'loan_repayments': ma.fields.Float()},
        {'loan_repayments_candidate_loans': ma.fields.Float()},
        {'loan_repayments_other_loans': ma.fields.Float()},
        {'loans': ma.fields.Float()},
        {'loans_made_by_candidate': ma.fields.Float()},
        {'net_contributions': ma.fields.Float()},
        {'net_operating_expenditures': ma.fields.Float()},
        {'offsets_to_operating_expenditures': ma.fields.Float()},
        {'operating_expenditures': ma.fields.Float()},
        {'other_political_committee_contributions': ma.fields.Float()},
        {'other_receipts': ma.fields.Float()},
        {'political_party_committee_contributions': ma.fields.Float()},
        {'receipts': ma.fields.Float()},
        {'refunded_individual_contributions': ma.fields.Float()},
        {'refunded_other_political_committee_contributions': ma.fields.Float()},
        {'refunded_political_party_committee_contributions': ma.fields.Float()},
        {'transfers_from_other_authorized_committee': ma.fields.Float()},
        {'transfers_to_other_authorized_committee': ma.fields.Float()},
        {'other_disbursements': ma.fields.Float()},
        {'contribution_refunds': ma.fields.Float()},
        {'contributions': ma.fields.Float()},
    ), options={
        'exclude': (
            'transaction_coverage',
            'idx',
            'treasurer_text',
        )
    }
)
augment_models(
    make_totals_schema,
    models.CommitteeTotalsHouseSenate
)

make_totals_per_cycle_schema = functools.partial(
    make_schema,
    fields=utils.extend(
        entity_fields,
        {'cash_on_hand_beginning_period': ma.fields.Float()},
        {'all_other_loans': ma.fields.Float()},
        {'candidate_contribution': ma.fields.Float()},
        {'disbursements': ma.fields.Float()},
        {'individual_contributions': ma.fields.Float()},
        {'individual_itemized_contributions': ma.fields.Float()},
        {'individual_unitemized_contributions': ma.fields.Float()},
        {'last_cash_on_hand_end_period': ma.fields.Float()},
        {'last_debts_owed_by_committee': ma.fields.Float()},
        {'last_debts_owed_to_committee': ma.fields.Float()},
        {'loan_repayments': ma.fields.Float()},
        {'loan_repayments_candidate_loans': ma.fields.Float()},
        {'loan_repayments_other_loans': ma.fields.Float()},
        {'loans': ma.fields.Float()},
        {'loans_made_by_candidate': ma.fields.Float()},
        {'net_contributions': ma.fields.Float()},
        {'net_operating_expenditures': ma.fields.Float()},
        {'offsets_to_operating_expenditures': ma.fields.Float()},
        {'operating_expenditures': ma.fields.Float()},
        {'other_political_committee_contributions': ma.fields.Float()},
        {'other_receipts': ma.fields.Float()},
        {'political_party_committee_contributions': ma.fields.Float()},
        {'receipts': ma.fields.Float()},
        {'refunded_individual_contributions': ma.fields.Float()},
        {'refunded_other_political_committee_contributions': ma.fields.Float()},
        {'refunded_political_party_committee_contributions': ma.fields.Float()},
        {'transfers_from_other_authorized_committee': ma.fields.Float()},
        {'transfers_to_other_authorized_committee': ma.fields.Float()},
        {'other_disbursements': ma.fields.Float()},
        {'contribution_refunds': ma.fields.Float()},
        {'contributions': ma.fields.Float()},
        {'exempt_legal_accounting_disbursement': ma.fields.Float()},
        {'federal_funds': ma.fields.Float()},
        {'fundraising_disbursements': ma.fields.Float()},
        {'loan_repayments_made': ma.fields.Float()},
        {'loans_received': ma.fields.Float()},
        {'loans_received_from_candidate': ma.fields.Float()},
        {'offsets_to_fundraising_expenditures': ma.fields.Float()},
        {'offsets_to_legal_accounting': ma.fields.Float()},
        {'other_loans_received': ma.fields.Float()},
        {'repayments_loans_made_by_candidate': ma.fields.Float()},
        {'repayments_other_loans': ma.fields.Float()},
        {'total_offsets_to_operating_expenditures': ma.fields.Float()},
        {'transfers_from_affiliated_committee': ma.fields.Float()}
    ), options={
        'exclude': (
            'transaction_coverage',
            'idx',
            'treasurer_text',
        )
    }
)

augment_models(
    make_totals_per_cycle_schema,
    models.CommitteeTotalsPerCycle
)

make_committee_totals_ie_only = make_schema(
    models.CommitteeTotalsIEOnly,
    fields=utils.extend(
        entity_fields,
        {'total_independent_contributions': ma.fields.Float()},
        {'total_independent_expenditures': ma.fields.Float()}
    ), options={
        'exclude': (
            'transaction_coverage',
            'idx',
        )
    }
)

augment_schemas(make_committee_totals_ie_only)

# /totals/entity_type/ 'pac','party','pac-party'
make_pac_party_totals_schema = functools.partial(
    make_schema,
    fields=utils.extend(
        entity_fields,
        {'sponsor_candidate_list': ma.fields.Nested(PacSponsorCandidateschema, many=True)},
        {'all_loans_received': ma.fields.Float()},
        {'allocated_federal_election_levin_share': ma.fields.Float()},
        {'disbursements': ma.fields.Float()},
        {'convention_exp': ma.fields.Float()},
        {'coordinated_expenditures_by_party_committee': ma.fields.Float()},
        {'exp_prior_years_subject_limits': ma.fields.Float()},
        {'exp_subject_limits': ma.fields.Float()},
        {'fed_candidate_committee_contributions': ma.fields.Float()},
        {'fed_candidate_contribution_refunds': ma.fields.Float()},
        {'fed_disbursements': ma.fields.Float()},
        {'fed_election_activity': ma.fields.Float()},
        {'fed_operating_expenditures': ma.fields.Float()},
        {'fed_receipts': ma.fields.Float()},
        {'independent_expenditures': ma.fields.Float()},
        {'cash_on_hand_beginning_period': ma.fields.Float()},
        {'contribution_refunds': ma.fields.Float()},
        {'individual_contributions': ma.fields.Float()},
        {'individual_itemized_contributions': ma.fields.Float()},
        {'individual_unitemized_contributions': ma.fields.Float()},
        {'itemized_convention_exp': ma.fields.Float()},
        {'itemized_other_disb': ma.fields.Float()},
        {'itemized_other_income': ma.fields.Float()},
        {'itemized_other_refunds': ma.fields.Float()},
        {'itemized_refunds_relating_convention_exp': ma.fields.Float()},
        {'last_debts_owed_by_committee': ma.fields.Float()},
        {'last_debts_owed_to_committee': ma.fields.Float()},
        {'loan_repayments_made': ma.fields.Float()},
        {'loan_repayments_received': ma.fields.Float()},
        {'loans_and_loan_repayments_made': ma.fields.Float()},
        {'loans_and_loan_repayments_received': ma.fields.Float()},
        {'loans_made': ma.fields.Float()},
        {'net_contributions': ma.fields.Float()},
        {'net_operating_expenditures': ma.fields.Float()},
        {'non_allocated_fed_election_activity': ma.fields.Float()},
        {'offsets_to_operating_expenditures': ma.fields.Float()},
        {'operating_expenditures': ma.fields.Float()},
        {'other_disbursements': ma.fields.Float()},
        {'other_fed_operating_expenditures': ma.fields.Float()},
        {'other_fed_receipts': ma.fields.Float()},
        {'other_political_committee_contributions': ma.fields.Float()},
        {'other_refunds': ma.fields.Float()},
        {'political_party_committee_contributions': ma.fields.Float()},
        {'refunded_individual_contributions': ma.fields.Float()},
        {'refunded_other_political_committee_contributions': ma.fields.Float()},
        {'refunded_political_party_committee_contributions': ma.fields.Float()},
        {'refunds_relating_convention_exp': ma.fields.Float()},
        {'shared_fed_activity': ma.fields.Float()},
        {'shared_fed_activity_nonfed': ma.fields.Float()},
        {'shared_fed_operating_expenditures': ma.fields.Float()},
        {'shared_nonfed_operating_expenditures': ma.fields.Float()},
        {'total_exp_subject_limits': ma.fields.Float()},
        {'total_transfers': ma.fields.Float()},
        {'transfers_from_affiliated_party': ma.fields.Float()},
        {'transfers_from_nonfed_account': ma.fields.Float()},
        {'transfers_from_nonfed_levin': ma.fields.Float()},
        {'transfers_to_affiliated_committee': ma.fields.Float()},
        {'unitemized_convention_exp': ma.fields.Float()},
        {'unitemized_other_disb': ma.fields.Float()},
        {'unitemized_other_income': ma.fields.Float()},
        {'unitemized_other_refunds': ma.fields.Float()},
        {'unitemized_refunds_relating_convention_exp': ma.fields.Float()},
        {'contributions': ma.fields.Float()},
        {'federal_funds': ma.fields.Float()},
        {'receipts': ma.fields.Float()}
    ),
    options={'exclude': ('idx', 'treasurer_text', 'transaction_coverage')}
)
augment_models(
    make_pac_party_totals_schema,
    models.CommitteeTotalsPacParty,
)

totals_schemas = (
    schemas['CommitteeTotalsHouseSenateSchema'],
    schemas['CommitteeTotalsPacPartySchema'],
    schemas['CommitteeTotalsIEOnlySchema'],
    schemas['CommitteeTotalsPerCycleSchema']
)
CommitteeTotalsSchema = type('CommitteeTotalsSchema', totals_schemas, {})
CommitteeTotalsPageSchema = make_page_schema(CommitteeTotalsSchema)

register_schema(CommitteeTotalsSchema)
register_schema(CommitteeTotalsPageSchema)

# excluding street address to comply with FEC policy
ScheduleASchema = make_schema(
    models.ScheduleA,
    fields={
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'contributor': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'contribution_receipt_amount': ma.fields.Float(),
        'contributor_aggregate_ytd': ma.fields.Float(),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
        'report_year': ma.fields.Int(),
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
        'form_line_number': ma.fields.Str(),
    },
    options={'exclude': ('loan_source_name_text', 'candidate_name_text',)}
    )
ScheduleCPageSchema = make_page_schema(
    ScheduleCSchema,
)
# excluding street address to comply with FEC policy
ScheduleBByRecipientIDSchema = make_schema(
    models.ScheduleBByRecipientID,
    fields={
        'committee_name': ma.fields.Str(),
        'recipient_name': ma.fields.Str(),
        'total': ma.fields.Float(),
        'memo_total': ma.fields.Float()
    },
    options={'exclude': ('idx', 'committee', 'recipient')}
)
augment_schemas(ScheduleBByRecipientIDSchema)


# Schema/PageSchema for ScheduleBByRecipient
ScheduleBByRecipientSchema = make_schema(
    models.ScheduleBByRecipient,
    fields={
        'recipient_disbursement_percent': ma.fields.Float(),
        'committee_total_disbursements': ma.fields.Float(),
        'total': ma.fields.Float(),
        'memo_total': ma.fields.Float()
    },
    options={'exclude': ('idx', 'committee')}
)

ScheduleBByRecipientPageSchema = make_page_schema(ScheduleBByRecipientSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleBByRecipientSchema)
register_schema(ScheduleBByRecipientPageSchema)

augment_itemized_aggregate_models(
    make_schema,
    models.CommitteeHistory,
    models.ScheduleAByZip,
    models.ScheduleABySize,
    models.ScheduleAByState,
    models.ScheduleAByEmployer,
    models.ScheduleAByOccupation,
    models.ScheduleBByPurpose,
)

make_aggregate_schema = functools.partial(
    make_schema,
    fields={
        'committee_id': ma.fields.Str(),
        'candidate_id': ma.fields.Str(),
        'committee_name': ma.fields.Str(),
        'candidate_name': ma.fields.Str(),
        'total': ma.fields.Float()
    },
    options={'exclude': ('idx', 'committee', 'candidate')}
    )

ScheduleEByCandidateSchema = make_aggregate_schema(models.ScheduleEByCandidate)
augment_schemas(ScheduleEByCandidateSchema)

ScheduleDSchema = make_schema(
    models.ScheduleD,
    fields={
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'pdf_url': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
        'form_line_number': ma.fields.Str(),
    },
    options={'exclude': ('creditor_debtor_name_text',)}
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
        'form_line_number': ma.fields.Str(),
    },
    options={'exclude': ('payee_name_text',)}
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
        'disbursement_amount': ma.fields.Float(),
    },
    options={
        'exclude': (
            'recipient_name_text',
            'disbursement_description_text',
            'recipient_street_1',
            'recipient_street_2',
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

ScheduleH4Schema = make_schema(
    models.ScheduleH4,
    fields={
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
        'cycle': ma.fields.Int(),
        'disbursement_amount': ma.fields.Float(),
        'federal_share': ma.fields.Float(),
        'nonfederal_share': ma.fields.Float(),
        'event_amount_year_to_date': ma.fields.Float(),
        'form_line_number': ma.fields.Str(),

    },
    options={
        'exclude': (
            'payee_name_text',
            'disbursement_purpose_text',
        ),
        'relationships': [
            Relationship(
                models.ScheduleH4.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)
ScheduleH4PageSchema = make_page_schema(ScheduleH4Schema, page_type=paging_schemas.SeekPageSchema)
register_schema(ScheduleH4Schema)
register_schema(ScheduleH4PageSchema)

ScheduleESchema = make_schema(
    models.ScheduleE,
    fields={
        'memoed_subtotal': ma.fields.Boolean(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'expenditure_amount': ma.fields.Float(),
        'office_total_ytd': ma.fields.Float(),
        'image_number': ma.fields.Str(),
        'original_sub_id': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
        'form_line_number': ma.fields.Str(),
    },
    options={
        'exclude': (
            'payee_name_text',
            'spender_name_text',
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

CommunicationCostSchema = make_schema(models.CommunicationCost, fields={'transaction_amount': ma.fields.Float()})
CommunicationCostPageSchema = make_page_schema(
    CommunicationCostSchema,
    page_type=paging_schemas.OffsetPageSchema
)
register_schema(CommunicationCostSchema)
register_schema(CommunicationCostPageSchema)

CCAggregatesSchema = make_schema(
    models.CommunicationCostByCandidate,
    fields={
        'committee_id': ma.fields.Str(),
        'candidate_id': ma.fields.Str(),
        'committee_name': ma.fields.Str(),
        'candidate_name': ma.fields.Str(),
        'cycle': ma.fields.Int(),
        'count': ma.fields.Int(),
        'total': ma.fields.Float(),
    },
    options={'exclude': ('idx',)}
)
CCAggregatesPageSchema = make_page_schema(CCAggregatesSchema)
register_schema(CCAggregatesSchema, 'CCAggregates')
register_schema(CCAggregatesPageSchema, 'CCAggregatesPage')

ElectioneeringSchema = make_schema(
    models.Electioneering,
    fields={'election_type': ma.fields.Str(),
            'number_of_candidates': ma.fields.Float(),
            'calculated_candidate_share': ma.fields.Float(),
            'disbursement_amount': ma.fields.Float(),
            },
    options={'exclude': ('idx', 'purpose_description_text', 'election_type_raw')}
)

ElectioneeringPageSchema = make_page_schema(ElectioneeringSchema, page_type=paging_schemas.SeekPageSchema)
register_schema(ElectioneeringSchema)
register_schema(ElectioneeringPageSchema)

ECAggregatesSchema = make_schema(
    models.ElectioneeringByCandidate,
    fields={
        'committee_id': ma.fields.Str(),
        'candidate_id': ma.fields.Str(),
        'committee_name': ma.fields.Str(),
        'candidate_name': ma.fields.Str(),
        'cycle': ma.fields.Int(),
        'count': ma.fields.Int(),
        'total': ma.fields.Float(),
    },
    options={'exclude': ('idx',)}
)
ECAggregatesPageSchema = make_page_schema(ECAggregatesSchema)
register_schema(ECAggregatesSchema, 'ECAggregates')
register_schema(ECAggregatesPageSchema, 'ECAggregatesPage')

BaseFilingsSchema = make_schema(
    models.Filings,
    fields={
        'document_description': ma.fields.Str(),
        'beginning_image_number': ma.fields.Str(),
        'ending_image_number': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'sub_id': ma.fields.Str(),
        'fec_file_id': ma.fields.Str(),
        'report_type_full': ma.fields.Str(),
        'amendment_chain': ma.fields.List(ma.fields.Int()),
        'total_receipts': ma.fields.Float(),
        'total_individual_contributions': ma.fields.Float(),
        'net_donations': ma.fields.Float(),
        'total_disbursements': ma.fields.Float(),
        'total_independent_expenditures': ma.fields.Float(),
        'total_communication_cost': ma.fields.Float(),
        'cash_on_hand_beginning_period': ma.fields.Float(),
        'cash_on_hand_end_period': ma.fields.Float(),
        'debts_owed_by_committee': ma.fields.Float(),
        'debts_owed_to_committee': ma.fields.Float(),
        'house_personal_funds': ma.fields.Float(),
        'senate_personal_funds': ma.fields.Float(),
        'opposition_personal_funds': ma.fields.Float()
    },
    options={'exclude': ('committee', 'filer_name_text', 'report_type_full_original', )}
)


class FilingsSchema(BaseFilingsSchema):
    @post_dump
    def remove_fec_url(self, obj, **kwargs):
        if not obj.get('fec_url'):
            obj.pop('fec_url')

        return obj


augment_schemas(FilingsSchema)

EfilingsAmendmentsSchema = make_schema(
    models.EfilingsAmendments,
    fields={
        'amendment_chain': ma.fields.List(ma.fields.Int()),
        'longest_chain': ma.fields.Float(),
        'most_recent_filing': ma.fields.Float(),
        'depth': ma.fields.Float(),
        'last': ma.fields.Float(),
        'previous_file_number': ma.fields.Float()
    }
)

augment_schemas(EfilingsAmendmentsSchema)

EFilingsSchema = make_schema(
    models.EFilings,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'ending_image_number': ma.fields.Str(),
        'html_url': ma.fields.Str(),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'is_amended': ma.fields.Boolean(),
        'document_description': ma.fields.Str(),
        'most_recent_filing': ma.fields.Int(),
        'most_recent': ma.fields.Bool(),
        'amendment_chain': ma.fields.List(ma.fields.Int()),
        'amended_by': ma.fields.Int(),
        'fec_file_id': ma.fields.Str(),
    },
    options={'exclude': ('report', 'amendment', 'superceded', 'report_type')}
)
augment_schemas(EFilingsSchema)

ItemizedScheduleBfilingsSchema = make_schema(
    models.ScheduleBEfile,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'filing': ma.fields.Nested(schemas['EFilingsSchema']),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'is_notice': ma.fields.Boolean(),
        'payee_name': ma.fields.Str(),
        'report_type': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'disbursement_amount': ma.fields.Float()
    },
    options={
        'relationships': [
            Relationship(
                models.ScheduleBEfile.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)
augment_schemas(ItemizedScheduleBfilingsSchema)

ItemizedScheduleEfilingsSchema = make_schema(
    models.ScheduleEEfile,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'filing': ma.fields.Nested(schemas['EFilingsSchema']),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'is_notice': ma.fields.Boolean(),
        'payee_name': ma.fields.Str(),
        'report_type': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
    },
    options={
        'exclude': ('cand_fulltxt',),
        'relationships': [
            Relationship(
                models.ScheduleEEfile.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)

augment_schemas(ItemizedScheduleEfilingsSchema)

ItemizedScheduleH4filingsSchema = make_schema(
    models.ScheduleH4Efile,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'filing': ma.fields.Nested(schemas['EFilingsSchema']),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'is_notice': ma.fields.Boolean(),
        'payee_name': ma.fields.Str(),
        'report_type': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'disbursement_amount': ma.fields.Float(),
        'fed_share': ma.fields.Float(),
        'event_amount_year_to_date': ma.fields.Float()
    },
    options={
        'relationships': [
            Relationship(
                models.ScheduleH4Efile.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)

augment_schemas(ItemizedScheduleH4filingsSchema)

ItemizedScheduleAfilingsSchema = make_schema(
    models.ScheduleAEfile,
    fields={
        'beginning_image_number': ma.fields.Str(),
        'committee': ma.fields.Nested(schemas['CommitteeHistorySchema']),
        'filing': ma.fields.Nested(schemas['EFilingsSchema']),
        'pdf_url': ma.fields.Str(),
        'fec_url': ma.fields.Str(),
        'report_type': ma.fields.Str(),
        'cycle': ma.fields.Int(),
        'contributor_name': ma.fields.Str(),
        'fec_election_type_desc': ma.fields.Str(),
        'csv_url': ma.fields.Str(),
        'contributor_aggregate_ytd': ma.fields.Float(),
        'contribution_receipt_amount': ma.fields.Float(),

    },
    options={
        'exclude': (
            'contributor_name_text',
            'contributor_employer_text',
            'contributor_occupation_text',
        ),
        'relationships': [
            Relationship(
                models.ScheduleAEfile.committee,
                models.CommitteeHistory.name,
                'committee_name',
                1
            ),
        ],
    }
)

augment_schemas(ItemizedScheduleAfilingsSchema)

ReportTypeSchema = make_schema(models.ReportType)
register_schema(ReportTypeSchema)

ReportingDatesSchema = make_schema(
    models.ReportDate,
    fields={
        'report_type': ma.fields.Str(),
        'report_type_full': ma.fields.Str(),
    },
    options={'exclude': ('trc_report_due_date_id', 'report')},
    class_name='ReportingDatesSchema'
)
augment_schemas(ReportingDatesSchema)

ElectionDatesSchema = make_schema(
    models.ElectionDate,
    fields={
        'election_type_full': ma.fields.Str(),
        'active_election': ma.fields.Boolean(),
    },
    options={'exclude': ('trc_election_id', 'election_status_id')},
    class_name='ElectionDatesSchema'

)
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
        'exclude': ('summary_text', 'description_text')}
)
augment_schemas(CalendarDateSchema)


class ElectionSearchSchema(ma.Schema):
    state = ma.fields.Str()
    office = ma.fields.Str()
    district = ma.fields.Str()
    candidate_status = ma.fields.Str()
    cycle = ma.fields.Int(attribute='two_year_period')
    incumbent_id = ma.fields.Str(attribute='cand_id')
    incumbent_name = ma.fields.Str(attribute='cand_name')


augment_schemas(ElectionSearchSchema)


class ElectionSummarySchema(ApiSchema):
    count = ma.fields.Int()
    receipts = ma.fields.Float()
    disbursements = ma.fields.Float()
    independent_expenditures = ma.fields.Float()


register_schema(ElectionSummarySchema)


class ElectionSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    candidate_name = ma.fields.Str()
    incumbent_challenge_full = ma.fields.Str()
    party_full = ma.fields.Str()
    committee_ids = ma.fields.List(ma.fields.Str)
    candidate_pcc_id = ma.fields.Str(doc="The candidate's primary campaign committee ID")
    candidate_pcc_name = ma.fields.Str(doc="The candidate's primary campaign committee name")
    total_receipts = ma.fields.Float()
    total_disbursements = ma.fields.Float()
    cash_on_hand_end_period = ma.fields.Float()
    candidate_election_year = ma.fields.Int()
    coverage_end_date = ma.fields.Date()


augment_schemas(ElectionSchema)


class ScheduleABySizeCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Float()
    size = ma.fields.Int()
    count = ma.fields.Int()


class ScheduleAByStateCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Float()
    state = ma.fields.Str()
    state_full = ma.fields.Str()
    count = ma.fields.Int()


class ScheduleAByContributorTypeCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Float()
    individual = ma.fields.Bool()


class TotalsCommitteeSchema(schemas['CommitteeHistorySchema']):
    receipts = ma.fields.Float()
    disbursements = ma.fields.Float()
    cash_on_hand_end_period = ma.fields.Float()
    debts_owed_by_committee = ma.fields.Float()
    independent_expenditures = ma.fields.Float()


augment_schemas(
    ScheduleABySizeCandidateSchema,
    ScheduleAByStateCandidateSchema,
    TotalsCommitteeSchema,
)

RadAnalystSchema = make_schema(
    models.RadAnalyst,
    fields={'analyst_id': ma.fields.Float(),
            'analyst_short_id': ma.fields.Float(),
            'telephone_ext': ma.fields.Float()
            },
    options={'exclude': ('idx', 'name_txt')}
)
RadAnalystPageSchema = make_page_schema(RadAnalystSchema)
register_schema(RadAnalystSchema)
register_schema(RadAnalystPageSchema)

EntityReceiptDisbursementTotalsSchema = make_schema(
    models.EntityReceiptDisbursementTotals,
    options={'exclude': ('idx', 'month', 'year')},
    fields={'end_date': ma.fields.Date(doc='The cumulative total for this month.')},
)
EntityReceiptDisbursementTotalsPageSchema = make_page_schema(EntityReceiptDisbursementTotalsSchema)
register_schema(EntityReceiptDisbursementTotalsSchema)
register_schema(EntityReceiptDisbursementTotalsPageSchema)

ScheduleAByStateRecipientTotalsSchema = make_schema(
    models.ScheduleAByStateRecipientTotals,
    fields={'total': ma.fields.Float()},
    options={'exclude': ('idx',)}
)
ScheduleAByStateRecipientTotalsPageSchema = make_page_schema(
    ScheduleAByStateRecipientTotalsSchema
)
register_schema(ScheduleAByStateRecipientTotalsSchema)
register_schema(ScheduleAByStateRecipientTotalsPageSchema)


# endpoint audit-primary-category
AuditPrimaryCategorySchema = make_schema(
    models.AuditPrimaryCategory,
    fields={
        'primary_category_id': ma.fields.Str(),
        'primary_category_name': ma.fields.Str(),
        'tier': ma.fields.Int(),
    },
    options={
        'exclude': ('tier',)
    },
    BaseSchema=BaseSchema
)

AuditPrimaryCategoryPageSchema = make_page_schema(AuditPrimaryCategorySchema)
register_schema(AuditPrimaryCategorySchema)
register_schema(AuditPrimaryCategoryPageSchema)

# endpoint audit-category(with nested sub category)
AuditCategoryRelationSchema = make_schema(
    models.AuditCategoryRelation,
    fields={
        'primary_category_id': ma.fields.Str(),
        'sub_category_id': ma.fields.Str(),
        'sub_category_name': ma.fields.Str(),
        'primary_category_name': ma.fields.Str(),
    },
    options={
        'exclude': ('primary_category_id', 'primary_category_name')
    },
    BaseSchema=BaseSchema
)

AuditCategoryRelationPageSchema = make_page_schema(AuditCategoryRelationSchema)
register_schema(AuditCategoryRelationSchema)
register_schema(AuditCategoryRelationPageSchema)

# endpoint audit-category
AuditCategorySchema = make_schema(
    models.AuditCategory,
    fields={
        'primary_category_id': ma.fields.Str(),
        'primary_category_name': ma.fields.Str(),
        'tier': ma.fields.Int(),
        'sub_category_list': ma.fields.Nested(AuditCategoryRelationSchema, many=True),
    },
    options={
        'exclude': ('tier',)
        # 'relationships': [
        #     Relationship(
        #         models.AuditCategory.sub_category_list,
        #         models.AuditCategoryRelation.primary_category_id,
        #         'primary_category_id',
        #         1
        #     ),
        # ],
    },
    BaseSchema=BaseSchema
)

AuditCategoryPageSchema = make_page_schema(AuditCategorySchema)
register_schema(AuditCategorySchema)
register_schema(AuditCategoryPageSchema)


# endpoint audit-case
AuditCaseSubCategorySchema = make_schema(
    models.AuditCaseSubCategory,
    fields={
        'primary_category_id': ma.fields.Str(),
        'audit_case_id': ma.fields.Str(),
        'sub_category_id': ma.fields.Str(),
        'sub_category_name': ma.fields.Str(),
    },
    options={
        'exclude': (
            'primary_category_id',
            'audit_case_id',
            'primary_category_name'
        )
    }
)

AuditCaseSubCategoryPageSchema = make_page_schema(AuditCaseSubCategorySchema)
register_schema(AuditCaseSubCategorySchema)
register_schema(AuditCaseSubCategoryPageSchema)


# endpoint audit-case(with nested sub_category)
AuditCaseCategoryRelationSchema = make_schema(
    models.AuditCaseCategoryRelation,
    fields={
        'audit_case_id': ma.fields.Str(),
        'primary_category_id': ma.fields.Str(),
        'primary_category_name': ma.fields.Str(),
        'sub_category_list': ma.fields.Nested(AuditCaseSubCategorySchema, many=True),
    },
    options={
        'exclude': (
            'audit_case_id',
        )}
)

AuditCaseCategoryRelationPageSchema = make_page_schema(AuditCaseCategoryRelationSchema)
register_schema(AuditCaseCategoryRelationSchema)
register_schema(AuditCaseCategoryRelationPageSchema)

# endpoint audit-case(with nested primary category)
AuditCaseSchema = make_schema(
    models.AuditCase,
    fields={
        'idx': ma.fields.Int(),
        'audit_case_id': ma.fields.Str(),
        'cycle': ma.fields.Int(),
        'committee_id': ma.fields.Str(),
        'committee_name': ma.fields.Str(),
        'committee_designation': ma.fields.Str(),
        'committee_type': ma.fields.Str(),
        'committee_description': ma.fields.Str(),
        'far_release_date': ma.fields.Date(),
        'audit_id': ma.fields.Integer(),
        'candidate_id': ma.fields.Str(),
        'candidate_name': ma.fields.Str(),
        'link_to_report': ma.fields.Str(),
        'primary_category_list': ma.fields.Nested(AuditCaseCategoryRelationSchema, many=True),
    },
    options={
        'exclude': ('idx',)},
    BaseSchema=BaseSchema
)
AuditCasePageSchema = make_page_schema(AuditCaseSchema)
register_schema(AuditCaseSchema)
register_schema(AuditCasePageSchema)

ElectionsListSchema = make_schema(
    models.ElectionsList,
    options={
        'exclude': (
            'idx',
            'sort_order',
            'incumbent_id',
            'incumbent_name')}
)

ElectionsListPageSchema = make_page_schema(ElectionsListSchema)
register_schema(ElectionsListSchema)
register_schema(ElectionsListPageSchema)

StateElectionOfficeInfoSchema = make_schema(models.StateElectionOfficeInfo)

StateElectionOfficeInfoPageSchema = make_page_schema(StateElectionOfficeInfoSchema)
register_schema(StateElectionOfficeInfoSchema)
register_schema(StateElectionOfficeInfoPageSchema)

OperationsLogSchema = make_schema(models.OperationsLog)

OperationsLogPageSchema = make_page_schema(OperationsLogSchema)
register_schema(OperationsLogSchema)
register_schema(OperationsLogPageSchema)


class TotalByOfficeSchema(ma.Schema):
    office = ma.fields.Str()
    election_year = ma.fields.Int()
    total_receipts = ma.fields.Float()
    total_disbursements = ma.fields.Float()
    total_individual_itemized_contributions = ma.fields.Float()
    total_transfers_from_other_authorized_committee = ma.fields.Float()
    total_other_political_committee_contributions = ma.fields.Float()


augment_schemas(TotalByOfficeSchema)


class TotalByOfficeByPartySchema(ma.Schema):
    office = ma.fields.Str()
    party = ma.fields.Str()
    election_year = ma.fields.Int()
    total_receipts = ma.fields.Float()
    total_disbursements = ma.fields.Float()


augment_schemas(TotalByOfficeByPartySchema)


class CandidateTotalAggregateSchema(ma.Schema):
    election_year = ma.fields.Int()
    office = ma.fields.Str()
    party = ma.fields.Str()
    total_receipts = ma.fields.Float()
    total_disbursements = ma.fields.Float()
    total_individual_itemized_contributions = ma.fields.Float()
    total_transfers_from_other_authorized_committee = ma.fields.Float()
    total_other_political_committee_contributions = ma.fields.Float()
    total_cash_on_hand_end_period = ma.fields.Float()
    total_debts_owed_by_committee = ma.fields.Float()
    state = ma.fields.Str()
    district = ma.fields.Str()
    district_number = ma.fields.Int()
    state_full = ma.fields.Str()


augment_schemas(CandidateTotalAggregateSchema)


class ECTotalsByCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    total = ma.fields.Float()


augment_schemas(ECTotalsByCandidateSchema)


class IETotalsByCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    support_oppose_indicator = ma.fields.Str()
    total = ma.fields.Float()


augment_schemas(IETotalsByCandidateSchema)


class CCTotalsByCandidateSchema(ma.Schema):
    candidate_id = ma.fields.Str()
    cycle = ma.fields.Int()
    support_oppose_indicator = ma.fields.Str()
    total = ma.fields.Float()


augment_schemas(CCTotalsByCandidateSchema)

# Presidential endpoints
# There may be a more efficient way to do this,but we're going for speed

# By candidate

PresidentialByCandidateSchema = make_schema(
    models.PresidentialByCandidate,
    fields={'net_receipts': ma.fields.Float(),
            'rounded_net_receipts': ma.fields.Float()},
    options={'exclude': ('idx',)}
)
PresidentialByCandidatePageSchema = make_page_schema(PresidentialByCandidateSchema)
register_schema(PresidentialByCandidateSchema)
register_schema(PresidentialByCandidatePageSchema)

# Financial Summary

PresidentialSummarySchema = make_schema(
    models.PresidentialSummary,
    fields={
                'net_receipts': ma.fields.Float(),
                'rounded_net_receipts': ma.fields.Float(),
                'individual_contributions_less_refunds': ma.fields.Float(),
                'pac_contributions_less_refunds': ma.fields.Float(),
                'party_contributions_less_refunds': ma.fields.Float(),
                'candidate_contributions_less_repayments': ma.fields.Float(),
                'disbursements_less_offsets': ma.fields.Float(),
                'operating_expenditures': ma.fields.Float(),
                'transfers_to_other_authorized_committees': ma.fields.Float(),
                'transfers_from_affiliated_committees': ma.fields.Float(),
                'fundraising_disbursements': ma.fields.Float(),
                'exempt_legal_accounting_disbursement': ma.fields.Float(),
                'total_loan_repayments_made': ma.fields.Float(),
                'repayments_loans_made_by_candidate': ma.fields.Float(),
                'repayments_other_loans': ma.fields.Float(),
                'other_disbursements': ma.fields.Float(),
                'offsets_to_operating_expenditures': ma.fields.Float(),
                'total_contribution_refunds': ma.fields.Float(),
                'debts_owed_by_committee': ma.fields.Float(),
                'federal_funds': ma.fields.Float(),
                'cash_on_hand_end': ma.fields.Float()
             },
    options={'exclude': ('idx',)}
)
PresidentialSummaryPageSchema = make_page_schema(PresidentialSummarySchema)
register_schema(PresidentialSummarySchema)
register_schema(PresidentialSummaryPageSchema)

# By size

PresidentialBySizeSchema = make_schema(
    models.PresidentialBySize,
    fields={'contribution_receipt_amount': ma.fields.Float()},
    options={'exclude': ('idx',)}
)
PresidentialBySizePageSchema = make_page_schema(PresidentialBySizeSchema)
register_schema(PresidentialBySizeSchema)
register_schema(PresidentialBySizePageSchema)

# By state

PresidentialByStateSchema = make_schema(
    models.PresidentialByState,
    fields={'contribution_receipt_amount': ma.fields.Float()},
    options={'exclude': ('idx',)},
)
PresidentialByStatePageSchema = make_page_schema(PresidentialByStateSchema)
register_schema(PresidentialByStateSchema)
register_schema(PresidentialByStatePageSchema)

# Coverage end date

PresidentialCoverageSchema = make_schema(
    models.PresidentialCoverage,
    options={'exclude': ('idx',)}
)
PresidentialCoveragePageSchema = make_page_schema(PresidentialCoverageSchema)
register_schema(PresidentialCoverageSchema)
register_schema(PresidentialCoveragePageSchema)

InauguralDonationsSchema = make_schema(
    models.InauguralDonations,
    fields={
        'total_donation': ma.fields.Float(),
        'cycle': ma.fields.Int()
    }
)
InauguralDonationsPageSchema = make_page_schema(InauguralDonationsSchema)
register_schema(InauguralDonationsSchema)
register_schema(InauguralDonationsPageSchema)


class CandidateTotalsDetailBaseSchema(BaseAutoSchema):
    class Meta:
        model = models.CandidateTotalsDetail
        sqla_session = models.db.session
        load_instance = True
        include_relationships = True
        include_fk = True

    last_cash_on_hand_end_period = ma.fields.Float()
    last_beginning_image_number = ma.fields.Str()
    receipts = ma.fields.Float()
    candidate_contribution = ma.fields.Float()
    offsets_to_operating_expenditures = ma.fields.Float()
    political_party_committee_contributions = ma.fields.Float()
    other_disbursements = ma.fields.Float()
    other_political_committee_contributions = ma.fields.Float()
    individual_itemized_contributions = ma.fields.Float()
    individual_unitemized_contributions = ma.fields.Float()
    disbursements = ma.fields.Float()
    contributions = ma.fields.Float()
    individual_contributions = ma.fields.Float()
    contribution_refunds = ma.fields.Float()
    operating_expenditures = ma.fields.Float()
    refunded_individual_contributions = ma.fields.Float()
    refunded_other_political_committee_contributions = ma.fields.Float()
    refunded_political_party_committee_contributions = ma.fields.Float()
    last_debts_owed_by_committee = ma.fields.Float()
    last_debts_owed_to_committee = ma.fields.Float()
    fundraising_disbursements = ma.fields.Float()
    exempt_legal_accounting_disbursement = ma.fields.Float()
    federal_funds = ma.fields.Float()
    offsets_to_fundraising_expenditures = ma.fields.Float()
    total_offsets_to_operating_expenditures = ma.fields.Float()
    offsets_to_legal_accounting = ma.fields.Float()
    net_operating_expenditures = ma.fields.Float()
    net_contributions = ma.fields.Float()
    last_net_contributions = ma.fields.Float()
    last_net_operating_expenditures = ma.fields.Float()
    other_receipts = ma.fields.Float()
    transfers_to_other_authorized_committee = ma.fields.Float()
    other_loans_received = ma.fields.Float()
    loan_repayments_made = ma.fields.Float()
    repayments_loans_made_by_candidate = ma.fields.Float()
    repayments_other_loans = ma.fields.Float()
    loans_received = ma.fields.Float()
    loans_received_from_candidate = ma.fields.Float()
    transfers_from_affiliated_committee = ma.fields.Float()


class CandidateTotalsDetailPresidentialSchema(CandidateTotalsDetailBaseSchema):
    class Meta(CandidateTotalsDetailBaseSchema.Meta):
        exclude = ('last_net_operating_expenditures', 'last_net_contributions')
    net_operating_expenditures = ma.fields.Float(attribute='last_net_operating_expenditures')
    net_contributions = ma.fields.Float(attribute='last_net_contributions')


class CandidateTotalsDetailHouseSenateSchema(CandidateTotalsDetailBaseSchema):
    class Meta(CandidateTotalsDetailBaseSchema.Meta):
        exclude = ('loans_received',
                   'repayments_other_loans',
                   'transfers_from_affiliated_committee',
                   'loans_received_from_candidate',
                   'loan_repayments_made',
                   'repayments_loans_made_by_candidate',
                   'other_loans_received')
    all_other_loans = ma.fields.Float(attribute='other_loans_received')
    loan_repayments = ma.fields.Float(attribute='loan_repayments_made')
    loan_repayments_candidate_loans = ma.fields.Float(attribute='repayments_loans_made_by_candidate')
    loan_repayments_other_loans = ma.fields.Float(attribute='repayments_other_loans')
    loans = ma.fields.Float(attribute='loans_received')
    loans_made_by_candidate = ma.fields.Float(attribute='loans_received_from_candidate')
    transfers_from_other_authorized_committee = ma.fields.Float(attribute='transfers_from_affiliated_committee')


CandidateTotalsDetailPresidentialPageSchema = make_page_schema(CandidateTotalsDetailPresidentialSchema)
CandidateTotalsDetailHouseSenatePageSchema = make_page_schema(CandidateTotalsDetailHouseSenateSchema)

register_schema(CandidateTotalsDetailPresidentialSchema)
register_schema(CandidateTotalsDetailHouseSenateSchema)

register_schema(CandidateTotalsDetailPresidentialPageSchema)
register_schema(CandidateTotalsDetailHouseSenatePageSchema)

# Copy schemas generated by helper methods to module namespace
globals().update(schemas)
