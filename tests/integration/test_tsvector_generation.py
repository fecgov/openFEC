import codecs
import pytest
import json

import manage

from tests import common
from webservices.rest import api
from webservices.resources.sched_a import ScheduleAView
from webservices.resources.sched_a import ScheduleAEfileView
from webservices.resources.sched_b import ScheduleBView
from webservices import rest, __API_VERSION__
from webservices.rest import db
from webservices.utils import parse_fulltext


@pytest.mark.usefixtures("migrate_db")
class TriggerTestCase(common.BaseTestCase):
    def setUp(self):
        super().setUp()
        self.longMessage = True
        self.maxDiff = None
        self.request_context = rest.app.test_request_context()
        self.request_context.push()
        self.connection = rest.db.engine.connect()

    def _response(self, qry):
        response = self.app.get(qry)
        self.assertEquals(response.status_code, 200)
        result = json.loads(codecs.decode(response.data))
        self.assertNotEqual(result, [], "Empty response!")
        self.assertEqual(result['api_version'], __API_VERSION__)
        return result

    def _results(self, qry):
        response = self._response(qry)
        return response['results']

    def test_schedule_b_exclude(self):
        '''
        Test that for each set of names, searching by the parsed key returns all but the last result.
        This is a test of adding extra information to reduce undesired returns
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            "Test.com": ['Test.com', 'Test com', 'Test .com', 'Test'],
            "Steven O'Reilly": [
                "Steven O'Reilly",
                "Steven O' Reilly",
                "Steven O Reilly",
                "O'Reilly",
            ],
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'recipient_nm': n,
                    'sub_id': 9999999999999999990 + i,
                    'filing_form': 'F3',
                }
                insert = (
                    "INSERT INTO disclosure.fec_fitem_sched_b "
                    + "(recipient_nm, sub_id, filing_form) "
                    + " VALUES (%(recipient_nm)s, %(sub_id)s, %(filing_form)s)"
                )
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = (
                "SELECT * from disclosure.fec_fitem_sched_b "
                + "WHERE recipient_name_text @@ to_tsquery('"
                + parse_fulltext(key)
                + "');"
            )
            results = connection.execute(select).fetchall()
            recipient_nm_list = [name[2] for name in results]
            # the only result not returned is the "bad" last element
            self.assertEquals(
                set(names[key]) - set(recipient_nm_list), {names[key][-1]}
            )
        connection.close()

    def test_schedule_a_contributor_name_text(self):
        '''
        Test to see that contbr_nm insert is parsed correctly and retrieved as
        expected from ts_vector column contributor_name_text
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            "Test.com": ['Test.com', 'Test com', 'Test .com', 'Test'],
            "Steven O'Reilly": [
                "Steven O'Reilly",
                "Steven O' Reilly",
                "Steven O Reilly",
                "O'Reilly",
            ],
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_nm': n,
                    'sub_id': 9999999999999999990 + i,
                    'filing_form': 'F3',
                }
                insert = (
                    "INSERT INTO disclosure.fec_fitem_sched_a "
                    + "(contbr_nm, sub_id, filing_form) "
                    + " VALUES (%(contbr_nm)s, %(sub_id)s, %(filing_form)s)"
                )
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = (
                "SELECT * from disclosure.fec_fitem_sched_a "
                + "WHERE contributor_name_text @@ to_tsquery('"
                + parse_fulltext(key)
                + "');"
            )
            results = connection.execute(select).fetchall()
            contbr_nm_list = [name[3] for name in results]
            # the only result not returned is the "bad" last element
            self.assertEquals(set(names[key]) - set(contbr_nm_list), {names[key][-1]})
        connection.close()

    def test_schedule_a_contributor_employer_text(self):
        '''
        Test to see that contbr_employer insert is parsed correctly and retrieved as
        expected from ts_vector column contributor_employer_text
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            "Test.com": ['Test.com', 'Test com', 'Test .com', 'Test'],
            "Steven O'Reilly": [
                "Steven O'Reilly",
                "Steven O' Reilly",
                "Steven O Reilly",
                "O'Reilly",
            ],
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_employer': n,
                    'sub_id': 9999999999999999980 + i,
                    'filing_form': 'F3',
                }
                insert = (
                    "INSERT INTO disclosure.fec_fitem_sched_a "
                    + "(contbr_employer, sub_id, filing_form) "
                    + " VALUES (%(contbr_employer)s, %(sub_id)s, %(filing_form)s)"
                )
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = (
                "SELECT * from disclosure.fec_fitem_sched_a "
                + "WHERE contributor_employer_text @@ to_tsquery('"
                + parse_fulltext(key)
                + "');"
            )
            results = connection.execute(select).fetchall()
            contbr_employer_list = [name[16] for name in results]
            # the only result not returned is the "bad" last element
            self.assertEquals(
                set(names[key]) - set(contbr_employer_list), {names[key][-1]}
            )
        connection.close()

    def test_schedule_a_contributor_occupation_text(self):
        '''
        Test to see that contbr_occupation insert is parsed correctly and retrieved as
        expected from ts_vector column contributor_occupation_text
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            "Test.com": ['Test.com', 'Test com', 'Test .com', 'Test'],
            "Steven O'Reilly": [
                "Steven O'Reilly",
                "Steven O' Reilly",
                "Steven O Reilly",
                "O'Reilly",
            ],
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_occupation': n,
                    'sub_id': 9999999999999999970 + i,
                    'filing_form': 'F3',
                }
                insert = (
                    "INSERT INTO disclosure.fec_fitem_sched_a "
                    + "(contbr_occupation, sub_id, filing_form) "
                    + " VALUES (%(contbr_occupation)s, %(sub_id)s, %(filing_form)s)"
                )
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = (
                "SELECT * from disclosure.fec_fitem_sched_a "
                + "WHERE contributor_occupation_text @@ to_tsquery('"
                + parse_fulltext(key)
                + "');"
            )
            results = connection.execute(select).fetchall()
            contbr_occupation_list = [name[17] for name in results]
            # the only result not returned is the "bad" last element
            self.assertEquals(
                set(names[key]) - set(contbr_occupation_list), {names[key][-1]}
            )
        connection.close()

    def test_schedule_c_loan_source_name_text(self):
        '''
        Test to see that loan_src_nm insert is parsed correctly and retrieved as
        expected from ts_vector column loan_source_name_text
        '''
        connection = db.engine.connect()
        name = "O'Reilly"
        names_good = {'O Reilly', "O'Reilly", 'O.Reilly', 'O-Reilly'}
        names_bad = {'O', "O'Hare", "Reilly"}
        i = 0
        for n in names_good.union(names_bad):
            i += 1
            data = {
                'loan_src_nm': n,
                'sub_id': 9999999999999999970 + i,
                'filing_form': 'F3',
            }
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_c "
                + "(loan_src_nm, sub_id, filing_form) "
                + " VALUES (%(loan_src_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_c "
            + "WHERE loan_source_name_text @@ to_tsquery('"
            + parse_fulltext(name)
            + "');"
        )
        results = connection.execute(select).fetchall()
        loan_src_nm_list = {na[7] for na in results}
        # assert all good names in result set
        assert names_good.issubset(loan_src_nm_list)
        # assert no bad names in result set
        assert names_bad.isdisjoint(loan_src_nm_list)
        connection.close()

    def test_schedule_c_candidate_name_text(self):
        '''
        Test to see that cand_nm insert is parsed correctly and retrieved as
        expected from ts_vector column candidate_name_text
        '''
        connection = db.engine.connect()
        name = "O'Reilly"
        names_good = {'O Reilly', "O'Reilly", 'O.Reilly', 'O-Reilly'}
        names_bad = {'O', "O'Hare", "Reilly"}
        i = 0
        for n in names_good.union(names_bad):
            i += 1
            data = {
                'cand_nm': n,
                'sub_id': 9999999999999999960 + i,
                'filing_form': 'F3',
            }
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_c "
                + "(cand_nm, sub_id, filing_form) "
                + " VALUES (%(cand_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_c "
            + "WHERE candidate_name_text @@ to_tsquery('"
            + parse_fulltext(name)
            + "');"
        )
        results = connection.execute(select).fetchall()
        cand_nm_list = {na[32] for na in results}
        # assert all good names in result set
        assert names_good.issubset(cand_nm_list)
        # assert no bad names in result set
        assert names_bad.isdisjoint(cand_nm_list)
        connection.close()

    def test_schedule_d_creditor_debtor_name_text(self):
        '''
        Test to see that cred_dbtr_nm is parsed correctly and retrieved as
        expected from ts_vector column creditor_debtor_name_text
        '''
        connection = db.engine.connect()
        name = "O'Reilly"
        names_good = {'O Reilly', "O'Reilly", 'O.Reilly', 'O-Reilly'}
        names_bad = {'O', "O'Hare", "Reilly"}
        i = 0
        for n in names_good.union(names_bad):
            i += 1
            data = {
                'cred_dbtr_nm': n,
                'sub_id': 9999999999999999970 + i,
                'filing_form': 'F3',
            }
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_d "
                + "(cred_dbtr_nm, sub_id, filing_form) "
                + " VALUES (%(cred_dbtr_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_d "
            + "WHERE creditor_debtor_name_text @@ to_tsquery('"
            + parse_fulltext(name)
            + "');"
        )
        results = connection.execute(select).fetchall()
        cred_dbtr_nm_list = {na[3] for na in results}
        # assert all good names in result set
        assert names_good.issubset(cred_dbtr_nm_list)
        # assert no bad names in result set
        assert names_bad.isdisjoint(cred_dbtr_nm_list)
        connection.close()

    def test_schedule_f_payee_name_text(self):
        '''
        Test to see that pye_nm is parsed correctly and retrieved as
        expected from ts_vector column payee_name_text
        '''
        connection = db.engine.connect()
        name = "O'Reilly"
        names_good = {'O Reilly', "O'Reilly", 'O.Reilly', 'O-Reilly'}
        names_bad = {'O', "O'Hare", "Reilly"}
        i = 0
        for n in names_good.union(names_bad):
            i += 1
            data = {'pye_nm': n, 'sub_id': 9999999999999999970 + i, 'filing_form': 'F3'}
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_f "
                + "(pye_nm, sub_id, filing_form) "
                + " VALUES (%(pye_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_f "
            + "WHERE payee_name_text @@ to_tsquery('"
            + parse_fulltext(name)
            + "');"
        )
        results = connection.execute(select).fetchall()
        pye_nm_list = {na[14] for na in results}
        # assert all good names in result set
        assert names_good.issubset(pye_nm_list)
        # assert no bad names in result set
        assert names_bad.isdisjoint(pye_nm_list)
        connection.close()

    def test_schedule_f_payee_name_text_accent(self):
        '''
        Test to see that pye_nm is parsed correctly and retrieved as
        expected from ts_vector column payee_name_text
        '''
        connection = db.engine.connect()
        names = {'ÁCCENTED NAME', 'ACCENTED NAME'}
        i = 0
        for n in names:
            i += 1
            data = {'pye_nm': n, 'sub_id': 9999999998999999970 + i, 'filing_form': 'F3'}
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_f "
                + "(pye_nm, sub_id, filing_form) "
                + " VALUES (%(pye_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_f "
            + "WHERE payee_name_text @@ to_tsquery('"
            + parse_fulltext('ÁCCENTED NAME')
            + "');"
        )
        results = connection.execute(select).fetchall()
        pye_nm_list = {na[14] for na in results}
        assert names.issubset(pye_nm_list)
        select = (
            "SELECT * from disclosure.fec_fitem_sched_f "
            + "WHERE payee_name_text @@ to_tsquery('"
            + parse_fulltext('ACCENTED NAME')
            + "');"
        )
        results = connection.execute(select).fetchall()
        pye_nm_list = {na[14] for na in results}
        assert names.issubset(pye_nm_list)
        connection.close()

    def test_accent_insensitive_sched_a(self):
        '''
        Test to see that both accented and unaccented data are returned
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            'Tést.com',
            'Test com',
            'Test .com',
            'test.com',
            'TEST.COM',
            'Test.com',
        }
        i = 0
        for n in names:
            i += 1
            data = {
                'contbr_employer': n,
                'sub_id': 9999999959999999980 + i,
                'filing_form': 'F3',
            }
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_a "
                + "(contbr_employer, sub_id, filing_form) "
                + " VALUES (%(contbr_employer)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='Test.com')
        )
        contbr_employer_list = {r['contributor_employer'] for r in results}
        assert names.issubset(contbr_employer_list)
        results = self._results(
            api.url_for(ScheduleAView, contributor_employer='Tést.com')
        )
        contbr_employer_list = {r['contributor_employer'] for r in results}
        assert names.issubset(contbr_employer_list)
        connection.close()

    def test_accent_insensitive_sched_b(self):
        '''
        Test to see that both accented and unaccented data are returned
        '''
        connection = db.engine.connect()
        # each list value in the dict below has 3 "good" names, one "bad" name
        names = {
            'ést-lou',
            'Est lou',
            'ést lóu',
            'EST LOU',
            'est lou',
            '@@@est      lou---@',
        }
        i = 0
        for n in names:
            i += 1
            data = {
                'recipient_nm': n,
                'sub_id': 9999999999995699990 + i,
                'filing_form': 'F3',
            }
            insert = (
                "INSERT INTO disclosure.fec_fitem_sched_b "
                + "(recipient_nm, sub_id, filing_form) "
                + " VALUES (%(recipient_nm)s, %(sub_id)s, %(filing_form)s)"
            )
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        results = self._results(
            api.url_for(ScheduleBView, contributor_employer='ést-lou')
        )
        print('results = ', results)
        contbr_employer_list = {r['recipient_name'] for r in results}
        assert names.issubset(contbr_employer_list)
        results = self._results(
            api.url_for(ScheduleBView, contributor_employer='est lou')
        )
        contbr_employer_list = {r['recipient_name'] for r in results}
        assert names.issubset(contbr_employer_list)
        connection.close()

    def real_efile_sa7(self):
        """
        Test tsvector trigger for real_efile.sa7
        --contributor_name_text
        --contributor_employer_text
        --contributor_occupation_text
        """
        connection = db.engine.connect()
        data = {
            'repid': {111111111111, 222222222222, 333333333333},
            'tran_id': {'4', '5', '6'},
            'fname': {'Oscar', 'The', 'Mr.'},
            'mname': {'The', '', ''},
            'name': {'Grouch', 'Count', 'Rogers'},
            'indemp': {'The Street', 'The Street', 'The Neighborhood'},
            'indocc': {'Lead Grouch', 'Vampire/Educator', 'Neighbor'},
        }
        insert = (
            "INSERT INTO real_efile_sa7 "
            + "(repid, tran_id, fname, mname, name, indemp, indocc) "
            + "VALUES (%(repid)s, %(tran_id)s, %(fname)s, %(mname)s, %(name)s, %(indemp)s, %(indocc)s)"
        )
        connection.executemany(insert, data)
        manage.refresh_materialized(concurrent=False)
        results = self._results(
            api.url_for(ScheduleAEfileView, contributor_employer='Neighborhood')
        )
        employer_set = {r['contributor_employer'] for r in results}
        assert {'The Neighborhood'}.issubset(employer_set)
        name_set = {r['contributor_name'] for r in results}
        assert {'Mr.'}.issubset(name_set)
        occupation_set = {r['contributor_occupation'] for r in results}
        assert {'Educator'}.issubset(occupation_set)
        connection.close()
