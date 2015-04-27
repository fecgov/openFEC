import factory
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
