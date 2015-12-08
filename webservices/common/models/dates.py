import re

from webservices import decoders

from .base import db


class ReportType(db.Model):
    __tablename__ = 'dimreporttype'

    report_type = db.Column('rpt_tp', db.String, index=True, primary_key=True)
    report_type_full = db.Column('rpt_tp_desc', db.String, index=True)


class ReportDate(db.Model):
    __tablename__ = 'trc_report_due_date'

    trc_report_due_date_id = db.Column(db.BigInteger, primary_key=True)
    report_year = db.Column(db.Integer, index=True)
    report_type = db.Column(db.String, db.ForeignKey(ReportType.report_type), index=True)
    due_date = db.Column(db.Date, index=True)
    create_date = db.Column(db.Date, index=True)
    update_date = db.Column(db.Date, index=True)

    report = db.relationship(ReportType)

    @property
    def report_type_full(self):
        return clean_report_type(self.report.report_type_full)


REPORT_TYPE_CLEAN = re.compile(r'{[^)]*}')
def clean_report_type(report_type):
    return REPORT_TYPE_CLEAN.sub('', report_type).strip()


class ElectionDate(db.Model):
    __tablename__ = 'trc_election'

    trc_election_id = db.Column(db.BigInteger, primary_key=True)
    election_state = db.Column(db.String, index=True)
    election_district = db.Column(db.Integer, index=True)
    election_party = db.Column(db.String, index=True)
    office_sought = db.Column(db.String, index=True)
    election_date = db.Column(db.Date, index=True)
    election_notes = db.Column(db.String, index=True)
    election_type_id = db.Column('trc_election_type_id', db.String, index=True)
    update_date = db.Column(db.Date, index=True)
    create_date = db.Column(db.Date, index=True)
    election_year = db.Column('election_yr', db.Integer, index=True)
    primary_general_date = db.Column('pg_date', db.Date, index=True)
    # TODO: we might want to filter out the trc_election_status_id=2 since those are deleted. I want to confirm with the FEC.
    election_status_id = db.Column('trc_election_status_id', db.String, index=True)

    @property
    def active_election(self):
        if self.election_status_id == 1:
            return True
        else:
            return False


    @property
    def election_type_full(self):
        return decoders.election_types.get(self.election_type_id)


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
