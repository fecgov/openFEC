import unittest

from flask import request
from webargs import flaskparser

from tests import factories
from tests.common import ApiBaseTest

from webservices import utils
from webservices import args
from webservices import rest
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

    def test_nulls_large(self):
        candidates = [
            factories.CandidateFactory(district='01'),
            factories.CandidateFactory(district='02'),
            factories.CandidateFactory(),
        ]
        query, columns = sorting.sort(models.Candidate.query, 'district', model=models.Candidate, nulls_large=False)
        self.assertEqual(query.all(), candidates[-1:] + candidates[:2])
        query, columns = sorting.sort(models.Candidate.query, '-district', model=models.Candidate, nulls_large=False)
        self.assertEqual(query.all(), [candidates[1], candidates[0], candidates[2]])


class TestFilter(ApiBaseTest):

    def setUp(self):
        super(TestFilter, self).setUp()
        self.receipts = [
            factories.ScheduleAFactory(entity_type='IND'),
            factories.ScheduleAFactory(entity_type='CCM'),
            factories.ScheduleAFactory(entity_type='COM'),
            factories.ScheduleAFactory(entity_type='PAC'),
        ]

    def test_filter_contributor_type_individual(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type == 'IND')
        )

    def test_filter_contributor_type_committee(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['committee']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type != 'IND')
        )

    def test_filter_contributor_type_none(self):
        query = utils.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual', 'committee']},
        )
        self.assertEqual(set(query.all()), set(self.receipts))


class TestArgs(unittest.TestCase):

    def test_currency(self):
        with rest.app.test_request_context('?dollars=$24.50'):
            parsed = flaskparser.parser.parse({'dollars': args.Currency()}, request)
            self.assertEqual(parsed, {'dollars': 24.50})
