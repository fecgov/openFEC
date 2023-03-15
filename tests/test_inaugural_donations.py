from tests import factories
from tests.common import ApiBaseTest, assert_dicts_subset

from webservices.rest import api
from webservices.resources.totals import InauguralDonationsView


class TestInauguralDonations(ApiBaseTest):

    def setUp(self):
        super().setUp()

        factories.TotalsInauguralDonationsFactory(
            committee_id='C00001',
            contributor_name='Walmart',
            cycle=2015,
            total_donation=1000
        )

        factories.TotalsInauguralDonationsFactory(
            committee_id='C00002',
            contributor_name='Target',
            cycle=2016,
            total_donation=4000
        )
        factories.TotalsInauguralDonationsFactory(
            committee_id='C00003',
            contributor_name='Jason',
            cycle=2020,
            total_donation=3000
        )

        factories.TotalsInauguralDonationsFactory(
            committee_id='C00004',
            contributor_name='Bass Pro Shop',
            cycle=2023,
            total_donation=6000
        )

        factories.TotalsInauguralDonationsFactory(
            committee_id='C00005',
            contributor_name='Petsmart',
            cycle=2023,
            total_donation=6000
        )
    def test_base(self):
        results = self._results(api.url_for(InauguralDonationsView))

        assert len(results) == 5

    def test_filter_by_committee(self):
        results = self._results(api.url_for(InauguralDonationsView,
                                            committee_id='C00003'))

        assert len(results) == 1

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00003',
                'contributor_name': 'Jason',
                'cycle': 2020,
                'total_donation': 3000
            }
        )

    def test_filter_by_cycle(self):
        results = self._results(api.url_for(InauguralDonationsView,
                                            cycle=2016))

        assert len(results) == 1

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00002',
                'contributor_name': 'Target',
                'cycle': 2016,
                'total_donation': 4000
            }
        )

    def test_multi_filter(self):
        results = self._results(api.url_for(InauguralDonationsView,
                                            cycle=2023, committee_id='C00005'))

        assert len(results) == 1

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00005',
                'contributor_name': 'Petsmart',
                'cycle': 2023,
                'total_donation': 6000
            }
        )

    def test_sort_by_committee(self):
        results = self._results(api.url_for(InauguralDonationsView, sort="-committee_id"))

        assert len(results) == 5

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00005',
                'contributor_name': 'Petsmart',
                'cycle': 2023,
                'total_donation': 6000
            },
        )
        assert_dicts_subset(
            results[1],
            {
                'committee_id': 'C00004',
                'contributor_name': 'Bass Pro Shop',
                'cycle': 2023,
                'total_donation': 6000
            }
        )
        assert_dicts_subset(
            results[2],
            {
                'committee_id': 'C00003',
                'contributor_name': 'Jason',
                'cycle': 2020,
                'total_donation': 3000
            }
        )
        assert_dicts_subset(
            results[3],
            {
                'committee_id': 'C00002',
                'contributor_name': 'Target',
                'cycle': 2016,
                'total_donation': 4000
            }
        )
        assert_dicts_subset(
            results[4],
            {
                'committee_id': 'C00001',
                'contributor_name': 'Walmart',
                'cycle': 2015,
                'total_donation': 1000
            }
        )

    def test_sort_by_donor(self):
        results = self._results(api.url_for(InauguralDonationsView, sort="contributor_name"))

        assert len(results) == 5

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00004',
                'contributor_name': 'Bass Pro Shop',
                'cycle': 2023,
                'total_donation': 6000
            }
        )
        assert_dicts_subset(
            results[1],
            {
                'committee_id': 'C00003',
                'contributor_name': 'Jason',
                'cycle': 2020,
                'total_donation': 3000
            }
        )
        assert_dicts_subset(
            results[2],
            {
                'committee_id': 'C00005',
                'contributor_name': 'Petsmart',
                'cycle': 2023,
                'total_donation': 6000
            },
        )
        assert_dicts_subset(
            results[3],
            {
                'committee_id': 'C00002',
                'contributor_name': 'Target',
                'cycle': 2016,
                'total_donation': 4000
            }
        )
        assert_dicts_subset(
            results[4],
            {
                'committee_id': 'C00001',
                'contributor_name': 'Walmart',
                'cycle': 2015,
                'total_donation': 1000
            }
        )

    def test_sort_by_cycle(self):
        results = self._results(api.url_for(InauguralDonationsView, sort=["cycle", "-contributor_name"]))

        assert len(results) == 5

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00001',
                'contributor_name': 'Walmart',
                'cycle': 2015,
                'total_donation': 1000
            }
        )
        assert_dicts_subset(
            results[1],
            {
                'committee_id': 'C00002',
                'contributor_name': 'Target',
                'cycle': 2016,
                'total_donation': 4000
            }
        )
        assert_dicts_subset(
            results[2],
            {
                'committee_id': 'C00003',
                'contributor_name': 'Jason',
                'cycle': 2020,
                'total_donation': 3000
            }
        )
        assert_dicts_subset(
            results[3],
            {
                'committee_id': 'C00005',
                'contributor_name': 'Petsmart',
                'cycle': 2023,
                'total_donation': 6000
            },
        )
        assert_dicts_subset(
            results[4],
            {
                'committee_id': 'C00004',
                'contributor_name': 'Bass Pro Shop',
                'cycle': 2023,
                'total_donation': 6000
            }
        )

    def test_sort_by_donation(self):
        results = self._results(api.url_for(InauguralDonationsView, sort=["-total_donation", "-committee_id"]))

        assert len(results) == 5

        assert_dicts_subset(
            results[0],
            {
                'committee_id': 'C00005',
                'contributor_name': 'Petsmart',
                'cycle': 2023,
                'total_donation': 6000
            },
        )
        assert_dicts_subset(
            results[1],
            {
                'committee_id': 'C00004',
                'contributor_name': 'Bass Pro Shop',
                'cycle': 2023,
                'total_donation': 6000
            }
        )
        assert_dicts_subset(
            results[2],
            {
                'committee_id': 'C00002',
                'contributor_name': 'Target',
                'cycle': 2016,
                'total_donation': 4000
            }
        )
        assert_dicts_subset(
            results[3],
            {
                'committee_id': 'C00003',
                'contributor_name': 'Jason',
                'cycle': 2020,
                'total_donation': 3000
            }
        )
        assert_dicts_subset(
            results[4],
            {
                'committee_id': 'C00001',
                'contributor_name': 'Walmart',
                'cycle': 2015,
                'total_donation': 1000
            }
        )


