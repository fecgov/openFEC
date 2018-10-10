import sqlalchemy as sa
from tests import factories
from tests.common import ApiBaseTest
from webservices.rest import api
from webservices import rest
from webservices.resources.audit import (
    AuditCaseView,
    AuditCategoryView,
    AuditPrimaryCategoryView,
)
from webservices.resources.audit import (
    AuditCandidateNameSearch,
    AuditCommitteeNameSearch,
)
from webservices.schemas import (
    AuditCaseSchema,
    AuditCategorySchema,
    AuditPrimaryCategorySchema,
)


class TestAuditCase(ApiBaseTest):
    def test_combination_primarykey(self):
        factories.AuditCaseFactory()
        results = self._results(
            api.url_for(
                AuditCaseView,
                audit_case_id='2219',
                primary_category_id='3',
                sub_category_id='227',
            )
        )
        assert len(results) == 1
        assert results[0].keys() == AuditCaseSchema().fields.keys()


class TestAuditCategory(ApiBaseTest):
    def test_primarykey(self):
        factories.AuditCategoryFactory()
        results = self._results(api.url_for(AuditCategoryView, primary_category_id='3'))
        assert len(results) == 1
        assert results[0].keys() == AuditCategorySchema().fields.keys()


class TestAuditPrimaryCategory(ApiBaseTest):
    def test_primarykey(self):
        factories.AuditPrimaryCategoryFactory()
        results = self._results(
            api.url_for(AuditPrimaryCategoryView, primary_category_id='3')
        )
        assert len(results) == 1
        assert results[0].keys() == AuditPrimaryCategorySchema().fields.keys()


class TestAuditCandidateNameSearch(ApiBaseTest):
    def test_fulltext_match(self):
        factories.AuditCandidateSearchFactory(
            id='S2TX00312', fulltxt=sa.func.to_tsvector('CRUZ, RAFAEL EDWARD TED')
        )
        factories.AuditCandidateSearchFactory(
            id='H4TX02108', fulltxt=sa.func.to_tsvector('POE, TED')
        )
        factories.AuditCandidateSearchFactory(
            id='H4CA33119', fulltxt=sa.func.to_tsvector('LIEU, TED')
        )
        rest.db.session.flush()
        results = self._results(api.url_for(AuditCandidateNameSearch, q='TED'))
        self.assertEqual(len(results), 3)
        self.assertEqual(results[0]['id'], 'S2TX00312')


class TestAuditCommitteeNameSearch(ApiBaseTest):
    def test_fulltext_match(self):
        factories.AuditCommitteeSearchFactory(
            id='C00495622', fulltxt=sa.func.to_tsvector('GARY JOHNSON 2012 INC')
        )
        factories.AuditCommitteeSearchFactory(
            id='C00431205', fulltxt=sa.func.to_tsvector('JOHN EDWARDS FOR PRESIDENT')
        )
        factories.AuditCommitteeSearchFactory(
            id='C00396044',
            fulltxt=sa.func.to_tsvector('JOHN KENNEDY FOR US SENATE INC'),
        )
        factories.AuditCommitteeSearchFactory(
            id='C00366773', fulltxt=sa.func.to_tsvector('JOHN SULLIVAN FOR CONGRESS')
        )
        rest.db.session.flush()
        results = self._results(api.url_for(AuditCommitteeNameSearch, q='JOHN'))
        self.assertEqual(len(results), 4)
        self.assertEqual(results[0]['id'], 'C00495622')
