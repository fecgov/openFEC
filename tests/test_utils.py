import unittest

from flask import request
from webargs import flaskparser

from tests import factories
from tests.common import ApiBaseTest

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


class TestArgs(unittest.TestCase):

    def test_currency(self):
        with rest.app.test_request_context('?dollars=$24.50'):
            parsed = flaskparser.parser.parse({'dollars': args.Currency()}, request)
            self.assertEqual(parsed, {'dollars': 24.50})
