"""Utilities for summarizing two-year itemized aggregates by election as
materialized views.
"""

import sqlalchemy as sa

from webservices.common import models
from webservices.common.models import db
from webservices.common.ddl import CreateView, DropView

linkage_table = models.CandidateCommitteeLink.__table__

duration = sa.case(
    [
        (linkage_table.c.committee_type == 'S', 6),
        (linkage_table.c.committee_type == 'P', 4),
    ],
    else_=2,
)

class ElectionAggregate(db.Model):
    __abstract__ = True
    parent_model = None

    committee_id = db.Column('cmte_id', db.String, primary_key=True)
    election_year = db.Column(db.Integer, primary_key=True)
    total = db.Column(db.Numeric(30, 2))
    count = db.Column(db.Integer)

    @classmethod
    def group_columns(cls, rows):
        return []

    @classmethod
    def extra_columns(cls, rows):
        return []

    @classmethod
    def rebuild(cls):
        name = '{}_tmp'.format(cls.__tablename__)
        DropView(name, materialized=True, if_exists=True).execute(db.engine)
        CreateView(name, cls.select_aggregate(), materialized=True).execute(db.engine)

    @classmethod
    def select_aggregate(cls):
        rows = cls.select_rows().cte('rows')
        columns = [
            rows.c.cmte_id,
            rows.c.election_year,
            sa.func.sum(rows.c.total).label('total'),
            sa.func.sum(rows.c.count).label('count'),
        ] + cls.group_columns(rows) + cls.extra_columns(rows)
        group_by = [
            rows.c.cmte_id,
            rows.c.election_year,
        ] + cls.group_columns(rows)
        return sa.select(columns).group_by(*group_by)

    @classmethod
    def select_rows(cls):
        table = cls.parent_model.__table__
        return sa.select(
            [table, linkage_table.c.election_year]
        ).select_from(
            sa.outerjoin(
                table,
                linkage_table,
                sa.and_(
                    table.c.cmte_id == linkage_table.c.committee_id,
                    table.c.cycle <= linkage_table.c.election_year,
                    table.c.cycle > duration,
                )
            )
        )

class ScheduleABySizeElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_size_election_mv'
    parent_model = models.ScheduleABySize

    size = db.Column(db.Integer, primary_key=True)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.size]

class ScheduleAByStateElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_state_election_mv'
    parent_model = models.ScheduleAByState

    state = db.Column(db.String, primary_key=True)
    state_full = db.Column(db.String, primary_key=True)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.state]

    @classmethod
    def extra_columns(cls, rows):
        return [sa.func.max(rows.c.state_full)]

class ScheduleAByZipElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_zip_election_mv'
    parent_model = models.ScheduleAByZip

    zip = db.Column(db.String, primary_key=True)
    state = db.Column(db.String)
    state_full = db.Column(db.String)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.zip]

    @classmethod
    def extra_columns(cls, rows):
        return [
            sa.func.max(rows.c.state),
            sa.func.max(rows.c.state_full),
        ]

class ScheduleAByOccupationElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_occupation_election_mv'
    parent_model = models.ScheduleAByOccupation

    employer = db.Column(db.String, primary_key=True)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.occupation]

class ScheduleAByEmployerElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_employer_election_mv'
    parent_model = models.ScheduleAByEmployer

    occupation = db.Column(db.String, primary_key=True)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.employer]

class ScheduleAByContributorElectionAggregate(ElectionAggregate):
    __tablename__ = 'ofec_sched_a_aggregate_contributor_election_mv'
    parent_model = models.ScheduleAByContributor

    contributor_id = db.Column('contbr_id', db.String, primary_key=True)
    contributor_name = db.Column('contbr_nm', db.String)

    @classmethod
    def group_columns(cls, rows):
        return [rows.c.contbr_id]

    @classmethod
    def extra_columns(cls, rows):
        return [sa.func.max(rows.c.contbr_nm)]
