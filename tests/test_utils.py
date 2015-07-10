from tests import factories
from tests.common import ApiBaseTest

from webservices import utils
from webservices import sorting
from webservices.common import models


class TestSort(ApiBaseTest):

    def test_single_column(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate)
        self.assertEqual(query.all(), candidates)

    def test_single_column_reverse(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
        ]
        query, columns = sorting.sort(models.Candidate.query, '-district', model=models.Candidate)
        self.assertEqual(query.all(), candidates[::-1])

    def test_multi_column(self):
        candidates = [
            factories.CandidateFactory(district='01', party='DEM'),
            factories.CandidateFactory(district='01', party='REP'),
            factories.CandidateFactory(district='02', party='DEM'),
            factories.CandidateFactory(district='02', party='REP'),
        ]
        query, columns = sorting.sort(models.Candidate.query, ['district', 'party'], model=models.Candidate)
        self.assertEqual(query.all(), candidates)

    def test_hide_null(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(),
        ]
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate)
        self.assertEqual(query.all(), candidates)
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate, hide_null=True)
        self.assertEqual(query.all(), candidates[:2])


class TestFilter(ApiBaseTest):

    def setUp(self):
        super(TestFilter, self).setUp()
        self.receipts = [
            factories.ScheduleAFactory(line_number='11AI'),
            factories.ScheduleAFactory(line_number='17A'),
            factories.ScheduleAFactory(line_number='17C'),
            factories.ScheduleAFactory(line_number='11C'),
        ]

    def test_filter_contributor_type_individual(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.line_number,
            {'contributor_type': ['individual']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.line_number in ['11AI', '17A', '17C'])
        )

    def test_filter_contributor_type_committee(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.line_number,
            {'contributor_type': ['committee']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.line_number not in ['11AI', '17A', '17C'])
        )

    def test_filter_contributor_type_none(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.line_number,
            {'contributor_type': ['individual', 'committee']},
        )
        self.assertEqual(set(query.all()), set(self.receipts))
