from tests import factories
from tests.common import ApiBaseTest

from webservices import filters
from webservices.common import models
from webservices.resources.dates import CalendarDatesView
from webservices.resources.committees import CommitteeList


class TestFilterMatch(ApiBaseTest):
    filter_match_fields = [
        ('filer_type', models.CommitteeReports.means_filed),
    ]

    def setUp(self):
        super(TestFilterMatch, self).setUp()
        self.dates = [
            factories.CalendarDateFactory(
                event_id=123,
                calendar_category_id=1,
                summary='July Quarterly Report Due',
            ),
            factories.CalendarDateFactory(
                event_id=321, calendar_category_id=1, summary='TX Primary Runoff'
            ),
            factories.CalendarDateFactory(
                event_id=111, calendar_category_id=2, summary='EC Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=222, calendar_category_id=2, summary='IE Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=333, calendar_category_id=3, summary='Executive Session'
            ),
            factories.CalendarDateFactory(calendar_category_id=3, summary='Missing ID'),
        ]
        self.reports = [
            factories.ReportsHouseSenateFactory(means_filed='e-file'),
            factories.ReportsHouseSenateFactory(means_filed='paper'),
            factories.ReportsHouseSenateFactory(),
        ]

    def test_filter_match(self):
        # Filter for a single integer value
        query_dates = filters.filter_match(
            models.CalendarDate.query,
            {'event_id': 123},
            CalendarDatesView.filter_match_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(each for each in self.dates if each.event_id == 123),
        )

        # Filter for a single string value
        query_reports = filters.filter_match(
            models.CommitteeReportsHouseSenate.query,
            {'filer_type': 'e-file'},
            self.filter_match_fields,
        )
        self.assertEqual(
            set(query_reports.all()),
            set(each for each in self.reports if each.means_filed == 'e-file'),
        )

    def test_filter_match_exclude(self):
        # Exclude a single integer value
        query_dates = filters.filter_match(
            models.CalendarDate.query,
            {'event_id': -321},
            CalendarDatesView.filter_match_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(
                each
                for each in self.dates
                if each.event_id != 321 or each.event_id is None
            ),
        )

        # Exclude a single string value
        query_reports = filters.filter_match(
            models.CommitteeReportsHouseSenate.query,
            {'filer_type': '-paper'},
            self.filter_match_fields,
        )
        self.assertEqual(
            set(query_reports.all()),
            set(each for each in self.reports if each.means_filed != 'paper'),
        )


class TestFilterMulti(ApiBaseTest):
    def setUp(self):
        super(TestFilterMulti, self).setUp()
        self.dates = [
            factories.CalendarDateFactory(
                event_id=123,
                calendar_category_id=1,
                summary='July Quarterly Report Due',
            ),
            factories.CalendarDateFactory(
                event_id=321, calendar_category_id=1, summary='TX Primary Runoff'
            ),
            factories.CalendarDateFactory(
                event_id=111, calendar_category_id=2, summary='EC Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=222, calendar_category_id=2, summary='IE Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=333, calendar_category_id=3, summary='Executive Session'
            ),
            factories.CalendarDateFactory(calendar_category_id=3, summary='Missing ID'),
        ]
        self.committees = [
            factories.CommitteeFactory(name='Candidate 1 for Prez', designation='P'),
            factories.CommitteeFactory(name='Candidate 2 for Prez', designation='P'),
            factories.CommitteeFactory(name='B-type committee', designation='B'),
            factories.CommitteeFactory(name='U-type committee', designation='U'),
            factories.CommitteeFactory(name='None-type committee'),
        ]

    def test_filter_multi(self):
        # Filter for multiple integer values
        query_dates = filters.filter_multi(
            models.CalendarDate.query,
            {'calendar_category_id': [1, 3]},
            CalendarDatesView.filter_multi_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(each for each in self.dates if each.calendar_category_id in [1, 3]),
        )

        # Filter for multiple string values
        query_committees = filters.filter_multi(
            models.Committee.query,
            {'designation': ['P', 'U']},
            CommitteeList.filter_multi_fields,
        )
        self.assertEqual(
            set(query_committees.all()),
            set(each for each in self.committees if each.designation in ['P', 'U']),
        )

    def test_filter_multi_exclude(self):
        # Exclude multiple integer values
        query_dates = filters.filter_multi(
            models.CalendarDate.query,
            {'calendar_category_id': [-1, -3]},
            CalendarDatesView.filter_multi_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(each for each in self.dates if each.calendar_category_id not in [1, 3]),
        )

        # Exclude multiple string values
        query_committees = filters.filter_multi(
            models.Committee.query,
            {'designation': ['-P', '-U']},
            CommitteeList.filter_multi_fields,
        )
        self.assertEqual(
            set(query_committees.all()),
            set(
                each
                for each in self.committees
                if each.designation not in ['P', 'U'] or each.designation is None
            ),
        )

    def test_filter_multi_combo(self):
        # Exclude/include multiple integer values
        query_dates = filters.filter_multi(
            models.CalendarDate.query,
            {'calendar_category_id': [-1, 3]},
            CalendarDatesView.filter_multi_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(
                each
                for each in self.dates
                if each.calendar_category_id not in [1]
                and each.calendar_category_id in [3]
            ),
        )

        # Exclude/include multiple string values
        query_committees = filters.filter_multi(
            models.Committee.query,
            {'designation': ['-P', 'U']},
            CommitteeList.filter_multi_fields,
        )
        self.assertEqual(
            set(query_committees.all()),
            set(
                each
                for each in self.committees
                if each.designation not in ['P'] and each.designation in ['U']
            ),
        )


class TestFilterOther(ApiBaseTest):
    def setUp(self):
        super(TestFilterOther, self).setUp()
        self.receipts = [
            factories.ScheduleAFactory(entity_type=None),
            factories.ScheduleAFactory(entity_type='IND'),
            factories.ScheduleAFactory(entity_type='CCM'),
            factories.ScheduleAFactory(entity_type='COM'),
            factories.ScheduleAFactory(entity_type='PAC'),
        ]
        self.dates = [
            factories.CalendarDateFactory(
                event_id=123,
                calendar_category_id=1,
                summary='July Quarterly Report Due',
            ),
            factories.CalendarDateFactory(
                event_id=321, calendar_category_id=1, summary='TX Primary Runoff'
            ),
            factories.CalendarDateFactory(
                event_id=111, calendar_category_id=2, summary='EC Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=222, calendar_category_id=2, summary='IE Reporting Period'
            ),
            factories.CalendarDateFactory(
                event_id=333, calendar_category_id=3, summary='Executive Session'
            ),
        ]

    def test_filter_contributor_type_individual(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type == 'IND'),
        )

    def test_filter_contributor_type_committee(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['committee']},
        )
        self.assertEqual(
            set(query.all()),
            set(each for each in self.receipts if each.entity_type != 'IND'),
        )

    def test_filter_contributor_type_none(self):
        query = filters.filter_contributor_type(
            models.ScheduleA.query,
            models.ScheduleA.entity_type,
            {'contributor_type': ['individual', 'committee']},
        )
        self.assertEqual(set(query.all()), set(self.receipts))

    # Note: filter_fulltext is tested in test_itemized

    def test_filter_fulltext_exclude(self):
        query_dates = filters.filter_fulltext(
            models.CalendarDate.query,
            {'summary': ['Report', '-IE']},
            CalendarDatesView.filter_fulltext_fields,
        )
        self.assertEqual(
            set(query_dates.all()),
            set(
                each
                for each in self.dates
                if 'Report' in each.summary and 'IE' not in each.summary
            ),
        )


class TestFilterOverlap(ApiBaseTest):
    def setUp(self):
        super(TestFilterOverlap, self).setUp()
        self.committees = [
            factories.CommitteeFactory(committee_id='C001', sponsor_candidate_ids=['S001']),
            factories.CommitteeFactory(committee_id='C002', sponsor_candidate_ids=['H001']),
        ]

    def test_filter_overlap(self):
        """Test the filter that compares whether two arrays have elements in common."""
        query_committees = filters.filter_overlap(
            models.Committee.query,
            {'sponsor_candidate_id': ['H001']},
            CommitteeList.filter_overlap_fields,
        )
        self.assertEqual(
            set(query_committees.all()),
            set(each for each in self.committees if each.sponsor_candidate_ids == ['H001']),
        )

    def test_filter_overlap_exclude(self):
        query_committees = filters.filter_overlap(
            models.Committee.query,
            {'sponsor_candidate_id': ['-H001']},
            CommitteeList.filter_overlap_fields,
        )
        self.assertEqual(
            set(query_committees.all()),
            set(each for each in self.committees if each.sponsor_candidate_ids == ['S001']),
        )
