from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship, backref

from webservices import decoders

from .base import db

class ReportNames(db.Model):
    __tablename__ = 'dimreporttype'

    rpt_tp = db.Column(db.String, ForeignKey('ReportingDates.report_type'), index=True, primary_key=True)
    rpt_tp_desc = db.Column(db.String, index=True)


class ReportingDates(db.Model):
    __tablename__ = 'trc_report_due_date'

    trc_report_due_date_id = db.Column(db.BigInteger, primary_key=True)
    report_year = db.Column(db.Integer, index=True)
    report_type = db.Column(db.String, ForeignKey(ReportNames.rpt_tp), index=True)
    due_date = db.Column(db.Date, index=True)
    create_date = db.Column(db.Date, index=True)
    update_date = db.Column(db.Date, index=True)

    report = db.relationship(
        'ReportNames',
        primaryjoin='''and_(
            foreign(ReportingDates.report_type) == ReportNames.rpt_tp,
        )'''
    )

    @property
    def report_type_full(self):
        return self.report.rpt_tp_desc


class ElectionDates(db.Model):
    __tablename__ = 'trc_election'

    trc_election_id = db.Column(db.BigInteger, primary_key=True)
    election_state = db.Column(db.String, index=True)
    election_district = db.Column(db.Integer, index=True)
    election_party = db.Column(db.String, index=True)
    office_sought = db.Column(db.String, index=True)
    election_date = db.Column(db.Date, index=True)
    election_notes = db.Column(db.String, index=True)
    trc_election_type_id = db.Column(db.String, index=True)
    trc_election_status_id = db.Column(db.String, index=True)
    update_date = db.Column(db.Date, index=True)
    create_date = db.Column(db.Date, index=True)
    election_year = db.Column('election_yr', db.Integer, index=True)
    pg_date = db.Column(db.Date, index=True)

    @property
    def election_type_full(self):
        return decoders.election_types.get(self.trc_election_type_id)


class ElectionClassDate(db.Model):
    __tablename__ = 'ofec_election_dates'

    race_pk = db.Column(db.Integer, primary_key=True)
    office = db.Column(db.String, index=True)
    office_desc = db.Column(db.String)
    state = db.Column(db.String, index=True)
    state_desc = db.Column(db.String)
    district = db.Column(db.Integer, index=True)
    election_year = db.Column('election_yr', db.Integer, index=True)
    open_seat_flag = db.Column('open_seat_flg', db.String)
    create_date = db.Column(db.Date)
    election_type_id = db.Column(db.String)
    cycle_start_date = db.Column('cycle_start_dt', db.Date)
    cycle_end_date = db.Column('cycle_end_dt', db.Date)
    election_date = db.Column('election_dt', db.Date)
    senate_class = db.Column(db.Integer, index=True)
