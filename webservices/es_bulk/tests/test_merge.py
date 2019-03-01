import unittest
from ddt import ddt, data, unpack

from processors.merge import Merge
from processors.normalization import int2bool

@ddt
class TestMerge(unittest.TestCase):

    @data(
    ({'k1':'v1', '':''},{'k1':'v1'})
    )
    @unpack
    def test_remove_empty_key(self,input_dic,expected_results):
        Merge.remove_empty_key(input_dic)
        assert input_dic == expected_results

    @data(
    ({'key.with.dot':'v'},{'keywithdot':'v'})
    )
    @unpack
    def test_remove_dots_from_key(self, input_dic, expected_results):
        assert expected_results == Merge.remove_dots_from_key(input_dic)

    @data(
    ({'k1':'v1','k2':'v2'},{'v1':1,'v2':[1]},'v1','tags', 1),
    ({'k1':'v1','k2':'v3'},{'v1':[1,2,3],'v2':[1]},'v3','tags',None),
    ({'k1':'v1','k2':'v3'},{'v1':[1,2,3],'v2':[1]},'v3','tags',None),
    )
    @unpack
    def test_set_value(self, master, slave, key, field_name, result):
        Merge.set_field(master, slave, key, field_name)
        assert master[field_name] == result
        #assert result == master

    @data(
    (1, True),
    (0, False),
    (b'\x01', True),
    (b'\x00', False),
    (10, 10)
    )
    @unpack
    def test_int2bool(self, input, output):
        assert output == int2bool(input)

    @data(
    ({'k1':'v1', 'merge_key':'v2'},
     {'v2':{'merge_key':'v2', 'k4':'v4'}, 'v3':{'merge_key':'v3','k4':'v5'}},
     'v2',
     set(('k4',)),
     {'k1':'v1', 'merge_key':'v2', 'k4':'v4'}),
     ({'k1':'v1', 'merge_key':'v2'},
      {'v5':{'merge_key':'v5', 'k4':'v4'}, 'v3':{'merge_key':'v3','k4':'v5'}},
      'v2',
      set(('k4',)),
      {'k1':'v1', 'merge_key':'v2', 'k4':None})
    )
    @unpack
    def test_set_multiple_fields(self, master_row, slave, key, f_set, result):
        Merge.set_multiple_fields(master_row, slave, key, fields_set=f_set)
        assert master_row == result

    @data(
    ({'k1':'v1', 'merge_key':'v2'},
     {'v2':{'k1':['a','b'],'k2':['m']}, 'v3':{}},
     'v2',
     'f_name',
     {'k1':'v1', 'merge_key':'v2', 'f_name':{'k1':['a','b'],'k2':['m']}}),
    ({'k1':'v1', 'merge_key':'v2'},
     {'v1':{'k1':['a','b'],'k2':['m']}, 'v3':{}},
     'v2',
     'f_name',
     {'k1':'v1', 'merge_key':'v2', 'f_name':{}}))
    @unpack
    def test_set_field_as_dict(self, master_row, slave, key, field_name, result):
        Merge.set_field_as_dict(master_row, slave, key, field_name)
        assert result == master_row


if __name__ == '__main__':
    unittest.main()
