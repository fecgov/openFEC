import re

from webservices import decoders, docs

from .base import db


class ReportType(db.Model):
    __tablename__ = 'dimreporttype'

    report_type = db.Column('rpt_tp', db.String, index=True, primary_key=True, doc=docs.REPORT_TYPE)
    report_type_full = db.Column('rpt_tp_desc', db.String, index=True, doc=docs.REPORT_TYPE)


class ReportDate(db.Model):
    __tablename__ = 'trc_report_due_date'

    trc_report_due_date_id = db.Column(db.BigInteger, primary_key=True)
    report_year = db.Column(db.Integer, index=True, doc=docs.REPORT_YEAR)
    report_type = db.Column(db.String, db.ForeignKey(ReportType.report_type), index=True, doc=docs.REPORT_TYPE)
    due_date = db.Column(db.Date, index=True, doc=docs.DUE_DATE)
    create_date = db.Column(db.Date, index=True, doc=docs.CREATE_DATE)
    update_date = db.Column(db.Date, index=True, doc=docs.UPDATE_DATE)

    report = db.relationship(ReportType)

    @property
    def report_type_full(self):
        return clean_report_type(self.report.report_type_full)


REPORT_TYPE_CLEAN = re.compile(r'{[^)]*}')
def clean_report_type(report_type):
    return REPORT_TYPE_CLEAN.sub('', report_type).strip()


class ElectionDate(db.Model):
    __tablename__ = 'trc_election'

    trc_election_id = db.Column(db.Integer, primary_key=True)
    election_state = db.Column(db.String, index=True, doc=docs.STATE)
    election_district = db.Column(db.Integer, index=True, doc=docs.DISTRICT)
    election_party = db.Column(db.String, index=True, doc=docs.PARTY)
    office_sought = db.Column(db.String, index=True, doc=docs.OFFICE)
    election_date = db.Column(db.Date, index=True, doc=docs.ELECTION_DATE)
    election_notes = db.Column(db.String, index=True)
    election_type_id = db.Column('trc_election_type_id', db.String, index=True, doc=docs.election_TYPE)
    update_date = db.Column(db.DateTime, index=True, doc=docs.UPDATE_DATE)
    create_date = db.Column(db.DateTime, index=True, doc=docs.CREATE_DATE)
    election_year = db.Column('election_yr', db.Integer, index=True, doc=docs.ELECTION_YEAR)
    # I think this is mislabeled
    primary_general_date = db.Column('pg_date', db.Date, index=True)
    election_status_id = db.Column('trc_election_status_id', db.Integer, index=True, doc='Records are disregarded if election status is not 1. Those records are erroneous.')

    @property
    def election_type_full(self):
        return decoders.election_types.get(self.election_type_id, doc=docs.ELECTION_TYPE)


class ElectionClassDate(db.Model):
    __tablename__ = 'ofec_election_dates'

    race_pk = db.Column(db.Integer, primary_key=True)
    office = db.Column(db.String, index=True, doc=docs.OFFICE)
    office_desc = db.Column(db.String, doc=docs.OFFICE_FULL)
    state = db.Column(db.String, index=True, doc=docs.STATE)
    state_desc = db.Column(db.String, doc=docs.STATE)
    district = db.Column(db.Integer, index=True, doc=docs.DISTRICT)
    election_year = db.Column('election_yr', db.Integer, index=True, doc=docs.ELECTION_YEAR)
    open_seat_flag = db.Column('open_seat_flg', db.String, doc='Signifies if the contest has no incumbent running.')
    create_date = db.Column(db.Date, doc=docs.CREATE_DATE)
    election_type_id = db.Column(db.String, doc=docs.ELECTION_TYPE)
    #? double check this
    cycle_start_date = db.Column('cycle_start_dt', db.Date)
    cycle_end_date = db.Column('cycle_end_dt', db.Date)
    election_date = db.Column('election_dt', db.Date, doc=docs.ELECTION_DATE)
    senate_class = db.Column(db.Integer, index=True, doc=docs.SENATE_CLASS)
