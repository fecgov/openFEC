from webservices import docs, utils

from .base import db

from sqlalchemy.ext.hybrid import hybrid_property


class Filings(db.Model):
    __tablename__ = 'ofec_filings_mv'

    committee_id = db.Column(db.String, index=True, doc=docs.COMMITTEE_ID)
    committee = utils.related_committee_history('committee_id', cycle_label='report_year')
    committee_name = db.Column(db.String, doc=docs.COMMITTEE_NAME)
    candidate_id = db.Column(db.String, index=True, doc=docs.CANDIDATE_ID)
    candidate_name = db.Column(db.String, doc=docs.CANDIDATE_NAME)
    cycle = db.Column(db.Integer, doc=docs.RECORD_CYCLE)
    sub_id = db.Column(db.BigInteger, index=True, primary_key=True)
    coverage_start_date = db.Column(db.Date, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column(db.Date, doc=docs.COVERAGE_END_DATE)
    receipt_date = db.Column(db.Date, index=True, doc=docs.RECEIPT_DATE)
    election_year = db.Column(db.Integer, doc=docs.ELECTION_YEAR)
    form_type = db.Column(db.String, index=True, doc=docs.FORM_TYPE)
    report_year = db.Column(db.Integer, index=True, doc=docs.REPORT_YEAR)
    report_type = db.Column(db.String, index=True, doc=docs.REPORT_TYPE)
    document_type = db.Column(db.String, index=True, doc=docs.DOCUMENT_TYPE)
    document_type_full = db.Column(db.String, doc=docs.DOCUMENT_TYPE)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    beginning_image_number = db.Column(db.BigInteger, index=True, doc=docs.BEGINNING_IMAGE_NUMBER)
    ending_image_number = db.Column(db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    pages = db.Column(db.Integer, doc='Number of pages in the document')
    total_receipts = db.Column(db.Numeric(30, 2))
    total_individual_contributions = db.Column(db.Numeric(30, 2))
    net_donations = db.Column(db.Numeric(30, 2))
    total_disbursements = db.Column(db.Numeric(30, 2))
    total_independent_expenditures = db.Column(db.Numeric(30, 2))
    total_communication_cost = db.Column(db.Numeric(30, 2))
    cash_on_hand_beginning_period = db.Column(db.Numeric(30, 2), doc=docs.CASH_ON_HAND_BEGIN_PERIOD)
    cash_on_hand_end_period = db.Column(db.Numeric(30, 2), doc=docs.CASH_ON_HAND_END_PERIOD)
    debts_owed_by_committee = db.Column(db.Numeric(30, 2), doc=docs.DEBTS_OWED_BY_COMMITTEE)
    debts_owed_to_committee = db.Column(db.Numeric(30, 2), doc=docs.DEBTS_OWED_TO_COMMITTEE)
    house_personal_funds = db.Column(db.Numeric(30, 2))
    senate_personal_funds = db.Column(db.Numeric(30, 2))
    opposition_personal_funds = db.Column(db.Numeric(30, 2))
    treasurer_name = db.Column(db.String, doc=docs.TREASURER_NAME)
    file_number = db.Column(db.BigInteger)
    previous_file_number = db.Column(db.BigInteger)
    primary_general_indicator = db.Column(db.String, index=True)
    report_type_full = db.Column(db.String, doc=docs.REPORT_TYPE)
    request_type = db.Column(db.String)
    amendment_indicator = db.Column(db.String, index=True)
    update_date = db.Column(db.Date)
    pdf_url = db.Column(db.String)

    @property
    def document_description(self):
        return utils.document_description(
            self.report_year,
            self.report_type_full,
            self.document_type_full,
            self.form_type,
        )


class EFilings(db.Model):
    __tablename__ = 'real_efile_reps'

    file_number = db.Column('repid', db.BigInteger, index=True, primary_key=True, doc=docs.FILE_NUMBER)
    form_type = db.Column('form', db.String, doc=docs.FORM_TYPE)
    committee_id = db.Column('comid', db.String, index=True, doc=docs.COMMITTEE_ID)
    committee_name = db.Column('com_name', db.String, doc=docs.COMMITTEE_NAME)
    # this will be a date time
    receipt_date = db.Column('filed_date', db.Date, index=True, doc=docs.RECEIPT_DATE)
    # add docs, confirm this is the receipt time
    load_timestamp = db.Column('create_dt', db.DateTime, doc="This is the load date and will be deprecated when we have the receipt date time")
    coverage_start_date = db.Column('from_date', db.Date, doc=docs.COVERAGE_START_DATE)
    coverage_end_date = db.Column('through_date', db.Date, doc=docs.COVERAGE_END_DATE)
    beginning_image_number = db.Column('starting', db.BigInteger, doc=docs.BEGINNING_IMAGE_NUMBER)
    ending_image_number = db.Column('ending', db.BigInteger, doc=docs.ENDING_IMAGE_NUMBER)
    report_type = db.Column('rptcode', db.String, doc=docs.REPORT_TYPE)
    # double check amendment interpretation
    amended_by = db.Column('superceded', db.BigInteger, doc=docs.AMENDED_BY)
    amends_file = db.Column('previd', db.BigInteger, doc=docs.AMENDS_FILE)
    amendment_number = db.Column('rptnum', db.Integer, doc=docs.AMENDMENT_NUMBER)

    @property
    def is_amended(self):
        if self.superceded is not None:
            return True
        return False


# TODO: add index on committee id and filed_date
    #  version -- this is the efiling version and I don't think we need this - let's document in API for now, see if there are objections

class BaseFilingSummary(db.Model):
    __tablename__ = 'real_efile_summary'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    line_number = db.Column('lineno', db.Integer, primary_key=True)
    column_a = db.Column('cola', db.Float)
    column_b = db.Column('colb', db.Float)

class BaseFiling(db.Model):
    __abstract__ = True
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    committee_id = db.Column('comid', db.String, index=True, doc=docs.COMMITTEE_ID)
    coverage_start_date = db.Column('from_date', db.Date)
    coverage_end_date = db.Column('through_date', db.Date)
    rpt_pgi = db.Column('rptpgi', db.String, doc=docs.ELECTION_TYPE)
    report_type = db.Column('rptcode', db.String)
    image_number = db.Column('imageno', db.Integer)
    street_1 = db.Column('str1', db.String)
    street_2 = db.Column('str2', db.String)
    city = db.Column(db.String)
    state = db.Column(db.String)
    zip = db.Column(db.String)
    election_date = db.Column('el_date', db.Date)
    election_state = db.Column('el_state', db.String)
    create_date = db.Column('create_dt', db.Date)
    sign_date = db.Column(db.Date)


class BaseF3PFiling(BaseFiling):
    __tablename__ = 'real_efile_f3p'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)

    treasurer_last_name = db.Column('lname', db.String)
    treasurer_middle_name = db.Column('mname', db.String)
    treasurer_first_name = db.Column('fname', db.String)
    prefix = db.Column(db.String)
    suffix = db.Column(db.String)
    committee_name = db.Column('c_name', db.String, index=True, doc=docs.CANDIDATE_NAME)
    street_1 = db.Column('c_str1', db.String)
    street_2 = db.Column('c_str2', db.String)
    city = db.Column('c_city', db.String)
    state = db.Column('c_state', db.String)
    zip = db.Column('c_zip', db.String)
    total_receipts = db.Column('tot_rec', db.Float)
    total_disbursements = db.Column('tot_dis', db.Float)
    cash_on_hand_beginning_period = db.Column('cash', db.Float)
    cash_on_hand_end_period = db.Column('cash_close', db.Float)
    debts_owed_to_committee = db.Column('debts_to', db.Float)
    operating_expenditures = db.Column('expe', db.Float)
    net_contributions = db.Column('net_con', db.Float)
    net_operating_expenditures = db.Column('net_op', db.Float)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    sub_total_sum = db.Column('sub', db.String)

    @hybrid_property
    def treasurer_name(self):
        name = name_generator(self.treasurer_first_name,
                              ' ',
                              self.treasurer_middle_name,
                              ' ',
                              self.treasurer_last_name
                              )

        name = (
            name
            if name
            else None
        )
        return name

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3PFiling.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
    )

def name_generator(*args):
    name = ''
    for field in args:
        temp_name = (
            field
            if field
            else ''
        )
        name += temp_name

    ret_name = ''
    for string in name.split(' '):
        ret_name += string.lower().capitalize() + ' '
    return ret_name.strip()

class BaseF3Filing(BaseFiling):
    __tablename__ = 'real_efile_f3'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)
    candidate_last_name = db.Column('can_lname', db.String)
    candidate_first_name = db.Column('can_fname', db.String)
    candidate_middle_name = db.Column('can_mname', db.String)
    candidate_prefix = db.Column('can_prefix', db.String)
    candidate_suffix = db.Column('can_suffix', db.String)
    f3z1 = db.Column(db.Integer)
    primary_election = db.Column('act_pri', db.String)
    general_election = db.Column('act_gen', db.String)
    special_election = db.Column('act_spe', db.String)
    runoff_election = db.Column('act_run', db.String)
    district = db.Column('eld', db.Integer)
    amended_address = db.Column('amend_addr', db.String)

    @hybrid_property
    def candidate_name(self):
        name = name_generator(
                              self.candidate_first_name,
                              '',
                              self.candidate_middle_name,
                              '',
                              self.candidate_last_name
                              )
        name = (
            name
            if name
            else None
        )
        return name

    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3Filing.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
    )

class BaseF3XFiling(BaseFiling):
    __tablename__ = 'real_efile_f3x'
    file_number = db.Column('repid', db.Integer, index=True, primary_key=True)

    committee_name = db.Column('com_name', db.String, index=True, doc=docs.COMMITTEE_NAME)
    sign_date = db.Column('date_signed', db.Date)
    amend_address = db.Column('amend_addr', db.String)
    qual = db.Column(db.String)


    summary_lines = db.relationship(
        'BaseFilingSummary',
        primaryjoin='''and_(
                BaseF3XFiling.file_number == BaseFilingSummary.file_number,
            )''',
        foreign_keys=file_number,
        uselist=True,
    )