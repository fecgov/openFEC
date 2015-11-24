import datetime

import factory
from factory.alchemy import SQLAlchemyModelFactory

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


class ScheduleBFactory(BaseFactory):
    class Meta:
        model = models.ScheduleB
    sched_b_sk = factory.Sequence(lambda n: n)
    load_date = datetime.datetime.utcnow()
    report_year = 2016


class ScheduleEFactory(BaseFactory):
    class Meta:
        model = models.ScheduleE
    sched_e_sk = factory.Sequence(lambda n: n)
    report_year = 2016


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


class ScheduleAByContributorFactory(BaseAggregateFactory):
    class Meta:
        model = models.ScheduleAByContributor
    contributor_id = factory.Sequence(lambda n: str(n))
    year = 2015


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


class ReportingDatesFactory(BaseFactory):
    class Meta:
        model = models.ReportingDates


class ElectionDatesFactory(BaseFactory):
    class Meta:
        model = models.ElectionDates


class ElectionResultFactory(BaseFactory):
    class Meta:
        model = models.ElectionResult
    election_yr = 2016
    cand_office_st = 'US'
    cand_office_district = '00'
