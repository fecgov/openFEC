from webservices import utils, decoders

from .base import db


class ReportingDates(db.Model):
    __tablename__ = 'trc_report_due_date'

    trc_report_due_date_id = db.Column(db.BigInteger, primary_key=True)
    report_year = db.Column(db.Integer, index=True)
    report_type = db.Column(db.String, index=True)
    due_date = db.Column(db.Date, index=True)
    create_date = db.Column(db.Date, index=True)
    update_date = db.Column(db.Date, index=True)


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
