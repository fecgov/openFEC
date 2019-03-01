class Denormalization(object):
    """
    By default, all methods within the class return a dictionary
    """

    @staticmethod
    def get_all_values_for_distinctive_key(iterable, key):
        res = {}
        for row in iterable:
            current_key = row[key]
            current_value = row
            if current_key in res:
                raise IOError('The key {} has duplicates'.format(key))
            res[current_key] = current_value
        return res

    @staticmethod
    def hash_fields_for_distinctive_key(iterable, key):
        res = {}
        for row in iterable:
            current_key = row[key] #use merge key value as the new key for merge
            del row[key] #remove the merge key:value pair
            current_value = row
            if current_key in res:
                raise IOError('The key {} has duplicates'.format(key))
            res[current_key] = current_value
        return res

    @staticmethod
    def get_first_value_for_key(iterable, key, value):
        res = {}
        for row in iterable:
            current_key = row[key]
            current_value = row[value]
            if current_key in res:
                continue
            res[current_key] = current_value
        return res

    @staticmethod
    def get_values_for_key(iterable, key, value):
        """
        :return:  e.g.: {k1: [v1, v2], k2: [v3]}
        """
        res = {}
        for row in iterable:
            current_key = row[key]
            current_value = row[value]
            if current_key not in res:
                res[current_key] = [current_value]
            else:
                res[current_key] += [current_value]
        return res

    @staticmethod
    def merge_two_dicts_by_common_key(dict1, dict2, name1, name2):
        res = {}
        for k, v in dict1.items():
            if k in dict2:
                res[k] = {name1: v, name2: dict2[k]}
            else:
                res[k] = {name1: v, name2: None}
        for k, v in dict2.items():
            if k not in res:
                res[k] = {name1: None, name2: v}
        return res

    @staticmethod
    def get_dictionaries_for_key(iterable, key, name='name', value='value'):
        res = {}
        for row in iterable:
            current_key = row[key]
            current_name = row[name]
            current_value = row[value]
            if current_key not in res:
                res[current_key] = {current_name: [current_value]}
            elif current_name in res[current_key]:
                res[current_key][current_name] += [current_value]
            else:
                res[current_key].update({current_name: [current_value]})
        return res
