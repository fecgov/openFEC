import datetime

import sqlalchemy as sa

import factory
from factory.alchemy import SQLAlchemyModelFactory

import sqlalchemy as sa

from webservices.rest import db
from webservices.common import models


class BaseFactory(SQLAlchemyModelFactory):
    class Meta:
        sqlalchemy_session = db.session


class CandidateSearchFactory(BaseFactory):
    class Meta:
        model = models.CandidateSearch
    id = factory.Sequence(lambda n: n)


class CommitteeSearchFactory(BaseFactory):
    class Meta:
        model = models.CommitteeSearch
    id = factory.Sequence(lambda n: n)


class BaseCandidateFactory(BaseFactory):
    candidate_id = factory.Sequence(lambda n: 'ID{0}'.format(n))


class CandidateFactory(BaseCandidateFactory):
    class Meta:
        model = models.Candidate
    election_years = [2012, 2014]


class CandidateDetailFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateDetail


class CandidateHistoryFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateHistory
    two_year_period = 2016
    candidate_inactive = False


class CandidateHistoryLatestFactory(CandidateHistoryFactory):
    class Meta:
        model = models.CandidateHistoryLatest


class CandidateElectionFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateElection


class CandidateTotalFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateTotal
    cycle = 2016


class BaseCommitteeFactory(BaseFactory):
    class Meta:
        model = models.CandidateFlags
    federal_funds_flag = False
    five_thousand_flag = True

class BaseCommitteeFactory(BaseFactory):
    committee_id = factory.Sequence(lambda n: 'ID{0}'.format(n))


class CommitteeFactory(BaseCommitteeFactory):
    class Meta:
        model = models.Committee


class CommitteeDetailFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeDetail


class CommitteeHistoryFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeHistory
    cycle = 2016


# Force linked factories to share sequence counters
for each in BaseCandidateFactory.__subclasses__():
    each._meta.counter_reference = BaseCandidateFactory

for each in BaseCommitteeFactory.__subclasses__():
    each._meta.counter_reference = BaseCommitteeFactory


class CandidateCommitteeLinkFactory(BaseFactory):
    class Meta:
        model = models.CandidateCommitteeLink
    linkage_id = factory.Sequence(lambda n: n)


class BaseTotalsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)
    cycle = 2016


class TotalsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsHouseSenate


class TotalsPresidentialFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPresidential


class TotalsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPacParty

class TotalsIEOnlyFactory(BaseFactory):
    class Meta:
        model = models.CommitteeTotalsIEOnly


class BaseReportsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)


class ReportsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsHouseSenate


class ReportsPresidentialFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPresidential


class ReportsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPacParty


class ReportsIEOnlyFactory(BaseFactory):
    class Meta:
        model = models.CommitteeReportsIEOnly


class ScheduleAFactory(BaseFactory):
    class Meta:
        model = models.ScheduleA
    load_date = datetime.datetime.utcnow()
    sched_a_sk = factory.Sequence(lambda n: n)
    sub_id = factory.Sequence(lambda n: n)
    report_year = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.contributor_name_text = sa.func.to_tsvector(obj.contributor_name)
        obj.contributor_employer_text = sa.func.to_tsvector(obj.contributor_employer)
        obj.contributor_occupation_text = sa.func.to_tsvector(obj.contributor_occupation)


class ScheduleBFactory(BaseFactory):
    class Meta:
        model = models.ScheduleB
    sched_b_sk = factory.Sequence(lambda n: n)
    load_date = datetime.datetime.utcnow()
    report_year = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.disbursement_description_text = sa.func.to_tsvector(obj.disbursement_description)


class ScheduleEFactory(BaseFactory):
    class Meta:
        model = models.ScheduleE
    sched_e_sk = factory.Sequence(lambda n: n)
    report_year = 2016

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.payee_name_text = sa.func.to_tsvector(obj.payee_name)


class FilingsFactory(BaseFactory):
    class Meta:
        model = models.Filings


class BaseAggregateFactory(BaseFactory):
    committee_id = factory.Sequence(lambda n: str(n))
    cycle = 2016


class ScheduleABySizeFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleABySize


class ScheduleAByStateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleAByState


class ScheduleAByEmployerFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleAByEmployer


class ScheduleBByPurposeFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleBByPurpose
    purpose = 'ADMINISTRATIVE'


class ScheduleEByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleEByCandidate
    candidate_id = factory.Sequence(lambda n: str(n))
    support_oppose_indicator = 'S'


class CommunicationCostByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.CommunicationCostByCandidate
    candidate_id = factory.Sequence(lambda n: str(n))
    support_oppose_indicator = 'S'


class ElectioneeringByCandidateFactory(BaseAggregateFactory):
    class Meta:
        model = models.ElectioneeringByCandidate
    candidate_id = factory.Sequence(lambda n: str(n))


class ReportTypeFactory(BaseFactory):
    class Meta:
        model = models.ReportType


class ReportDateFactory(BaseFactory):
    class Meta:
        model = models.ReportDate


class CalendarDateFactory(BaseFactory):
    class Meta:
        model = models.CalendarDate

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.summary_text = sa.func.to_tsvector(obj.summary)
        obj.description_text = sa.func.to_tsvector(obj.description)


class ElectionDateFactory(BaseFactory):
    class Meta:
        model = models.ElectionDate


class ElectionResultFactory(BaseFactory):
    class Meta:
        model = models.ElectionResult
    election_yr = 2016
    cand_office_st = 'US'
    cand_office_district = '00'


class CommunicationCostFactory(BaseFactory):
    class Meta:
        model = models.CommunicationCost
    idx = factory.Sequence(lambda n: n)


class ElectioneeringFactory(BaseFactory):
    class Meta:
        model = models.Electioneering
    idx = factory.Sequence(lambda n: n)
    election_type_raw = 'G'

    @factory.post_generation
    def update_fulltext(obj, create, extracted, **kwargs):
        obj.purpose_description_text = sa.func.to_tsvector(obj.purpose_description)
