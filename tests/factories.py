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
    candidate_key = factory.Sequence(lambda n: n)
    candidate_id = factory.Sequence(lambda n: 'id{0}'.format(n))


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
    committee_key = factory.Sequence(lambda n: n + 1)
    committee_id = factory.Sequence(lambda n: 'id{0}'.format(n))


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


class CandidateCommitteeLinkFactory(BaseFactory):
    class Meta:
        model = models.CandidateCommitteeLink


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
    sched_a_sk = factory.Sequence(lambda n: n)
    report_year = 2016


class ScheduleASearchFactory(BaseFactory):
    class Meta:
        model = models.ScheduleASearch
    sched_a_sk = factory.Sequence(lambda n: n)


class ScheduleBFactory(BaseFactory):
    class Meta:
        model = models.ScheduleB
    sched_b_sk = factory.Sequence(lambda n: n)
    report_year = 2016


class ScheduleBSearchFactory(BaseFactory):
    class Meta:
        model = models.ScheduleBSearch
    sched_b_sk = factory.Sequence(lambda n: n)
