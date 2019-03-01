import unittest
from ddt import ddt, data, unpack

import os, sys
path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, path)

from processors.denormalization import Denormalization

@ddt
class TestDenormalization(unittest.TestCase):

    @data(
    ([{'bag_id':'bi1', 'f1':'v1'},{'bag_id':'bi2', 'f1':'v2'}],
    'bag_id',
    {'bi1':{'bag_id':'bi1', 'f1':'v1'},'bi2':{'bag_id':'bi2', 'f1':'v2'}})
    )
    @unpack
    def test_get_all_values_for_distinctive_key(self, iterable, key, result):
        assert result == Denormalization.get_all_values_for_distinctive_key(iterable, key)

    @data(
    ([{'bag':'v1','tag':'t1'},{'bag':'v1','tag':'t2'},{'bag':'v2','tag':'t3'}],
    'bag',
    'tag',
    {'v1':['t1','t2'],'v2':['t3']})
    )
    @unpack
    def test_get_values_for_key(self, iterable, key, value, result):
        assert result == Denormalization.get_values_for_key(iterable, key, value)

    @data(
    ([{'bag':'b1','bi':'bi1'}, {'bag':'b1','bi':'bi2'}, {'bag':'b2','bi':'bi3'}],
    'bag',
    'bi',
    {'b1':'bi1','b2':'bi3'})
    )
    @unpack
    def test_get_first_value_for_key(self, iterable, key, value, result):
        assert result == Denormalization.get_first_value_for_key(iterable, key, value)

    @data(
    ([{'bag':'b1','name':'n1','value':'v1'},
    {'bag':'b1','name':'n2','value':'v2'},
    {'bag':'b1','name':'n1','value':'v3'},
    {'bag':'b2','name':'n3','value':'v4'}],
    'bag',
    'name',
    'value',
    {'b1':{'n1':['v1','v3'],'n2':['v2']},'b2':{'n3':['v4']}})
    )
    @unpack
    def test_get_dictionaries_for_key(self, iterable, key, name, value, result):
        assert result == Denormalization.get_dictionaries_for_key(iterable, key, name, value)

    @data((
    {'proj1':['id1','id2'],'proj2':['id3']},
    {'proj1':['n1','n2'],'proj3':['n3','n4']},
    'id',
    'name',
    {'proj1':{'id':['id1','id2'],'name':['n1','n2']},
    'proj2':{'id':['id3'],'name':None},
    'proj3':{'id':None,'name':['n3','n4']}}
    ))
    @unpack
    def test_merge_two_dicts_by_common_key(self, dict1, dict2, name1, name2, result):
        assert result == Denormalization.merge_two_dicts_by_common_key(dict1, dict2, name1, name2)


if __name__ == '__main__':
     unittest.main()
