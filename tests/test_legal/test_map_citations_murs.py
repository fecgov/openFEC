import unittest

from webservices.legal_docs import reclassify_statutory_citation


class TestGetCitations(unittest.TestCase):
    def test_reclassify_statutory_citation(self):
        # spot check a few cases from the csv
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '431'
        ) == ('52', '30101')
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '437g'
        ) == ('52', '30109')
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '2', '441a-1'
        ) == ('52', '30117')

        # and a fallback
        assert reclassify_statutory_citation.reclassify_statutory_citation(
            '99', '12345'
        ) == ('99', '12345')
