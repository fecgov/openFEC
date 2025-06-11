import codecs
import pytest
import json

import manage
from tests.common import BaseTestCase
from webservices import __API_VERSION__
from webservices.api_setup import api
from webservices.common.models import db
from webservices.resources.committees import CommitteeHistoryProfileView
from sqlalchemy import text


@pytest.mark.usefixtures("migrate_db")
class CommitteeTestCase(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = self.application.test_request_context()
        self.request_context.push()
        self.connection = db.engine.connect()

    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEqual(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def tearDown(self):
        self.clear_test_data()
        self.connection.close()
        db.session.remove()

    committee_data = [
        {
            'valid_fec_yr_id': 10,
            'cmte_id': 'C00000001',
            'fec_election_yr': 2020,
            'cmte_tp': 'P',
            'cmte_dsgn': 'P',
            'date_entered': 'now()',
        },
    ]

    cand_cmte_linkage = [
        {
            'linkage_id': 10,
            'cand_id': 'P01',
            'fec_election_yr': 2020,
            'cand_election_yr': 2020,
            'cmte_id': 'C00000001',
            'cmte_count_cand_yr': 1,
            'cmte_tp': 'P',
            'cmte_dsgn': 'P',
            'linkage_type': 'P',
            'date_entered': 'now()',
        },
    ]

    f_rpt_or_form_sub_data = [
        {
            'cand_cmte_id': 'C00000001',
            'receipt_dt': 20160610,
            'form_tp': 'F1',
            'rpt_yr': 2015,
            'sub_id': 1001,
        },
        {
            'cand_cmte_id': 'C00000001',
            'receipt_dt': 20170310,
            'form_tp': 'F3',
            'rpt_yr': 2017,
            'sub_id': 1002,
        },
        {
            'cand_cmte_id': 'C00000001',
            'receipt_dt': 20170510,
            'form_tp': 'F3',
            'rpt_yr': None,
            'sub_id': 1003,
        },
        {
            'cand_cmte_id': 'C00000001',
            'receipt_dt': 20190310,
            'form_tp': 'F3',
            'rpt_yr': 2019,
            'sub_id': 1004,
        },
    ]

    def test_nulls_in_committee_history(self):
        self.insert_cmte_valid(self.committee_data)
        self.insert_cand_cmte_linkage(self.cand_cmte_linkage)
        self.insert_f_rpt_or_form_sub(self.f_rpt_or_form_sub_data)
        manage.refresh_materialized(concurrent=False)

        params_cmte = {
            'committee_id': 'C00000001',
        }

        committee_api = self._results(
            api.url_for(CommitteeHistoryProfileView, **params_cmte)
        )
        self.check_nulls_in_array_column(committee_api, array_column='cycles')
        self.check_nulls_in_array_column(
            committee_api, array_column='cycles_has_activity'
        )
        self.check_nulls_in_array_column(
            committee_api, array_column='cycles_has_financial'
        )

    def check_nulls_in_array_column(self, api_result, array_column):
        self.assertEqual(len(api_result), 1)
        self.assertEqual(api_result[0]['committee_id'], 'C00000001')

        for each in api_result[0][array_column]:
            has_null = 1 if each is None else 0

        self.assertEqual(has_null, 0)

    def insert_cmte_valid(self, committee_data):
        sql_insert = (
            "INSERT INTO disclosure.cmte_valid_fec_yr"
            "(valid_fec_yr_id, cmte_id, fec_election_yr, cmte_tp, cmte_dsgn, date_entered)"
            "VALUES (:valid_fec_yr_id, :cmte_id, :fec_election_yr, :cmte_tp, "
            ":cmte_dsgn, :date_entered)"
        )
        with self.connection.begin():
            self.connection.execute(text(sql_insert), committee_data)

    def insert_cand_cmte_linkage(self, linkage_data):
        sql_insert = (
            "INSERT INTO disclosure.cand_cmte_linkage "
            "(linkage_id, cand_id, fec_election_yr, cand_election_yr, "
            "cmte_id, cmte_count_cand_yr, cmte_tp, cmte_dsgn, linkage_type, date_entered) "
            "VALUES (:linkage_id, :cand_id, "
            ":fec_election_yr, :cand_election_yr, :cmte_id, :cmte_count_cand_yr, "
            ":cmte_tp, :cmte_dsgn, :linkage_type, :date_entered)"
        )
        with self.connection.begin():
            self.connection.execute(text(sql_insert), linkage_data)

    def insert_f_rpt_or_form_sub(self, f_rpt_or_form_sub_data):
        sql_insert = (
            "INSERT INTO disclosure.f_rpt_or_form_sub "
            "(cand_cmte_id,receipt_dt,form_tp,rpt_yr,sub_id) "
            "VALUES (:cand_cmte_id, :receipt_dt, :form_tp, :rpt_yr, :sub_id)"
        )
        with self.connection.begin():
            self.connection.execute(text(sql_insert), f_rpt_or_form_sub_data)

    def clear_test_data(self):
        tables = ["cmte_valid_fec_yr", "cand_cmte_linkage", "f_rpt_or_form_sub"]
        with self.connection.begin():
            for table in tables:
                self.connection.execute(text("DELETE FROM disclosure.{}".format(table)))
