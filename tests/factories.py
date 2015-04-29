import factory
from factory.alchemy import SQLAlchemyOptions
from factory.alchemy import SQLAlchemyModelFactory

from webservices.rest import db
from webservices.common import models


class BaseFactory(SQLAlchemyModelFactory):
    class Meta:
        sqlalchemy_session = db.session


class NameSearchFactory(BaseFactory):
    class Meta:
        model = models.NameSearch
    cand_id = factory.Sequence(lambda n: n)
    cmte_id = factory.Sequence(lambda n: n)


class CandidateSearchFactory(BaseFactory):
    class Meta:
        model = models.CandidateSearch
    cand_sk = factory.Sequence(lambda n: n)


class PairedOptions(SQLAlchemyOptions):
    def _build_default_options(self):
        return super()._build_default_options() + [
            factory.base.OptionDefault('paired_factory', None, inherit=True),
        ]


class PairedFactory(BaseFactory):

    _options_class = PairedOptions

    class Meta:
        exclude = ('pair', )

    pair = True

    @classmethod
    def _generate(cls, create, attrs):
        ret = super()._generate(create, attrs)
        if attrs.pop('pair', True) and create:
            paired_factory = cls._meta.paired_factory()
            ret._paired = paired_factory(pair=False, **{
                key: value for key, value in attrs.items()
                if key in set(paired_factory._meta.model.__table__.columns.keys())
            })
        return ret


class BaseCandidateFactory(BaseFactory):
    candidate_key = factory.Sequence(lambda n: n)
    candidate_id = factory.Sequence(lambda n: 'id{0}'.format(n))


class CandidateFactory(PairedFactory, BaseCandidateFactory):
    class Meta:
        model = models.Candidate
        paired_factory = lambda: CandidateDetailFactory

    election_years = [2012, 2014]


class CandidateDetailFactory(PairedFactory, BaseCandidateFactory):
    class Meta:
        model = models.CandidateDetail
        paired_factory = lambda: CandidateFactory


class CandidateHistoryFactory(BaseCandidateFactory):
    class Meta:
        model = models.CandidateHistory
    candidate_key = factory.Sequence(lambda n: n)
    candidate_id = factory.Sequence(lambda n: 'id{0}'.format(n))


class BaseCommitteeFactory(PairedFactory):
    committee_key = factory.Sequence(lambda n: n + 1)
    committee_id = factory.Sequence(lambda n: 'id{0}'.format(n))


class CommitteeFactory(BaseCommitteeFactory):
    class Meta:
        model = models.Committee
        paired_factory = lambda: CommitteeDetailFactory


class CommitteeDetailFactory(BaseCommitteeFactory):
    class Meta:
        model = models.CommitteeDetail
        paired_factory = lambda: CommitteeFactory


class CandidateCommitteeLinkFactory(BaseFactory):
    class Meta:
        model = models.CandidateCommitteeLink


class BaseTotalsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)


class TotalsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsHouseOrSenate


class TotalsPresidentialFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPresidential


class TotalsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeTotalsPacOrParty


class BaseReportsFactory(BaseFactory):
    committee_id = factory.LazyAttribute(lambda o: CommitteeFactory().committee_id)


class ReportsHouseSenateFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsHouseOrSenate


class ReportsPresidentialFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPresidential


class ReportsPacPartyFactory(BaseTotalsFactory):
    class Meta:
        model = models.CommitteeReportsPacOrParty
