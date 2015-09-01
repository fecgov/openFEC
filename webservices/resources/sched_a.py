import sqlalchemy as sa

from webservices import args
from webservices import docs
from webservices import spec
from webservices import utils
from webservices import filters
from webservices import schemas
from webservices import sorting
from webservices import exceptions
from webservices.common import counts
from webservices.common import models
from webservices.common.views import ItemizedResource


is_individual = sa.func.is_individual(
    models.ScheduleA.contribution_receipt_amount,
    models.ScheduleA.receipt_type,
    models.ScheduleA.line_number,
    models.ScheduleA.memo_code,
    models.ScheduleA.memo_text,
)


@spec.doc(
    tags=['schedules/schedule_a'],
    description=docs.SCHEDULE_A,
)
class ScheduleAView(ItemizedResource):

    model = models.ScheduleA

    @property
    def year_column(self):
        return self.model.report_year
    @property
    def index_column(self):
        return self.model.sched_a_sk
    @property
    def amount_column(self):
        return self.model.contribution_receipt_amount

    filter_multi_fields = [
        ('image_number', models.ScheduleA.image_number),
        ('committee_id', models.ScheduleA.committee_id),
        ('contributor_id', models.ScheduleA.contributor_id),
        ('contributor_city', models.ScheduleA.contributor_city),
        ('contributor_state', models.ScheduleA.contributor_state),
    ]
    filter_match_fields = [
        ('is_individual', is_individual),
    ]
    filter_range_fields = [
        (('min_date', 'max_date'), models.ScheduleA.contribution_receipt_date),
        (('min_amount', 'max_amount'), models.ScheduleA.contribution_receipt_amount),
        (('min_image_number', 'max_image_number'), models.ScheduleA.image_number),
    ]
    filter_fulltext_fields = [
        ('contributor_name', models.ScheduleASearch.contributor_name_text),
        ('contributor_employer', models.ScheduleASearch.contributor_employer_text),
        ('contributor_occupation', models.ScheduleASearch.contributor_occupation_text),
    ]
    query_options = [
        sa.orm.joinedload(models.ScheduleA.committee),
        sa.orm.joinedload(models.ScheduleA.contributor),
    ]

    @args.register_kwargs(args.itemized)
    @args.register_kwargs(args.schedule_a)
    @args.register_kwargs(args.make_seek_args())
    @args.register_kwargs(
        args.make_sort_args(
            validator=args.OptionValidator([
                'contribution_receipt_date',
                'contribution_receipt_amount',
                'contributor_aggregate_ytd',
            ]),
            multiple=False,
        )
    )
    @schemas.marshal_with(schemas.ScheduleAPageSchema())
    def get(self, **kwargs):
        if len(kwargs['committee_id']) > 5:
            raise exceptions.ApiError(
                'Can only specify up to five values for "committee_id".',
                status_code=422,
            )
        if len(kwargs['committee_id']) > 1:
            query, count = self.join_committee_queries(kwargs)
            return utils.fetch_seek_page(query, kwargs, self.index_column, count=count)
        return super(ScheduleAView, self).get(**kwargs)

    def build_query(self, **kwargs):
        query = super().build_query(**kwargs)
        query = filters.filter_contributor_type(query, self.model.entity_type, kwargs)
        return query

    def join_committee_queries(self, kwargs):
        queries = []
        total = 0
        for committee_id in kwargs['committee_id']:
            query, count = self.build_committee_query(kwargs, committee_id)
            queries.append(query.subquery().select())
            total += count
        query = models.db.session.query(
            models.ScheduleA
        ).select_entity_from(
            sa.union_all(*queries)
        )
        query = query.options(*self.query_options)
        return query, total

    def build_committee_query(self, kwargs, committee_id):
        query = self.build_query(_apply_options=False, **utils.extend(kwargs, {'committee_id': [committee_id]}))
        sort, hide_null, nulls_large = kwargs['sort'], kwargs['sort_hide_null'], kwargs['sort_nulls_large']
        query, _ = sorting.sort(query, sort, model=models.ScheduleA, hide_null=hide_null, nulls_large=nulls_large)
        page_query = utils.fetch_seek_page(query, kwargs, self.index_column, count=-1, eager=False).results
        count = counts.count_estimate(query, models.db.session, threshold=5000)
        return page_query, count

    def join_fulltext(self, query):
        return query.join(
            models.ScheduleASearch,
            models.ScheduleA.sched_a_sk == models.ScheduleASearch.sched_a_sk,
        )
