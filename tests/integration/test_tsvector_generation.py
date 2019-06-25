import codecs
import pytest
import json
import random
import string
import re

import manage

from tests import common
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
            "Steven O'Reilly": ["Steven O'Reilly", "Steven O' Reilly", "Steven O Reilly", "O'Reilly"]
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'recipient_nm': n,
                    'sub_id': 9999999999999999990 + i,
                    'filing_form': 'F3'
                }
                insert = "INSERT INTO disclosure.fec_fitem_sched_b " + \
                    "(recipient_nm, sub_id, filing_form) " + \
                    " VALUES (%(recipient_nm)s, %(sub_id)s, %(filing_form)s)"
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = "SELECT * from disclosure.fec_fitem_sched_b " + \
                "WHERE recipient_name_text @@ to_tsquery('" + parse_fulltext(key) + "');"
            results = connection.execute(select).fetchall()
            recipient_nm_list = [name[2] for name in results]
            #the only result not returned is the "bad" last element
            self.assertEquals(set(names[key]) - set(recipient_nm_list), {names[key][-1]})
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
            "Steven O'Reilly": ["Steven O'Reilly", "Steven O' Reilly", "Steven O Reilly", "O'Reilly"]
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_nm': n,
                    'sub_id': 9999999999999999990 + i,
                    'filing_form': 'F3'
                }
                insert = "INSERT INTO disclosure.fec_fitem_sched_a " + \
                    "(contbr_nm, sub_id, filing_form) " + \
                    " VALUES (%(contbr_nm)s, %(sub_id)s, %(filing_form)s)"
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = "SELECT * from disclosure.fec_fitem_sched_a " + \
                "WHERE contributor_name_text @@ to_tsquery('" + parse_fulltext(key) + "');"
            results = connection.execute(select).fetchall()
            contbr_nm_list = [name[3] for name in results]
            #the only result not returned is the "bad" last element
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
            "Steven O'Reilly": ["Steven O'Reilly", "Steven O' Reilly", "Steven O Reilly", "O'Reilly"]
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_employer': n,
                    'sub_id': 9999999999999999980 + i,
                    'filing_form': 'F3'
                }
                insert = "INSERT INTO disclosure.fec_fitem_sched_a " + \
                    "(contbr_employer, sub_id, filing_form) " + \
                    " VALUES (%(contbr_employer)s, %(sub_id)s, %(filing_form)s)"
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = "SELECT * from disclosure.fec_fitem_sched_a " + \
                "WHERE contributor_employer_text @@ to_tsquery('" + parse_fulltext(key) + "');"
            results = connection.execute(select).fetchall()
            contbr_employer_list = [name[16] for name in results]
            #the only result not returned is the "bad" last element
            self.assertEquals(set(names[key]) - set(contbr_employer_list), {names[key][-1]})
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
            "Steven O'Reilly": ["Steven O'Reilly", "Steven O' Reilly", "Steven O Reilly", "O'Reilly"]
        }
        i = 0
        for key in names:
            for n in names[key]:
                i += 1
                data = {
                    'contbr_occupation': n,
                    'sub_id': 9999999999999999970 + i,
                    'filing_form': 'F3'
                }
                insert = "INSERT INTO disclosure.fec_fitem_sched_a " + \
                    "(contbr_occupation, sub_id, filing_form) " + \
                    " VALUES (%(contbr_occupation)s, %(sub_id)s, %(filing_form)s)"
                connection.execute(insert, data)
            manage.refresh_materialized(concurrent=False)
            select = "SELECT * from disclosure.fec_fitem_sched_a " + \
                "WHERE contributor_occupation_text @@ to_tsquery('" + parse_fulltext(key) + "');"
            results = connection.execute(select).fetchall()
            contbr_occupation_list = [name[17] for name in results]
            #the only result not returned is the "bad" last element
            self.assertEquals(set(names[key]) - set(contbr_occupation_list), {names[key][-1]})
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
        for name in names_good.union(names_bad):
            i += 1
            data = {
                'pye_nm': name,
                'sub_id': 9999999999999999970 + i,
                'filing_form': 'F3'
            }
            insert = "INSERT INTO disclosure.fec_fitem_sched_f " + \
                "(pye_nm, sub_id, filing_form) " + \
                   " VALUES (%(pye_nm)s, %(sub_id)s, %(filing_form)s)"
            connection.execute(insert, data)
        manage.refresh_materialized(concurrent=False)
        select = "SELECT * from disclosure.fec_fitem_sched_f " + \
            "WHERE payee_name_text @@ to_tsquery('" + parse_fulltext(name) + "');"
        print('select')
        print(select)
        results = connection.execute(select).fetchall()
        print('results')
        print(results)
        pye_nm_list = {n[14] for n in results}
        #assert all good names in result set
        assert(names_good.issubset(pye_nm_list))
        #assert no bad names in result set
        assert(names_bad.isdisjoint(pye_nm_list))
        connection.close()
