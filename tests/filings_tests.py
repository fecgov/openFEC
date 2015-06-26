import json
import datetime

from webservices import utils
from webservices.rest import api
from webservices.resources.filings import FilingsView

from tests import factories
from .common import ApiBaseTest


class TestFilings(ApiBaseTest):

    def test_committee_filing(self):
        """ Check basic fields return with a specified committee """
        committee_id = 'C8675309'
        filing = factories.FilingsFactory(
            committee_id = committee_id,
        )

        results = self._results(api.url_for(FilingsView, committee_id=committee_id))
        self.assertEqual(results[0]['committee_id'], committee_id)



