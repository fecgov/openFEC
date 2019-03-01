class Merge(object):

    @staticmethod
    def remove_empty_key(current):
        # https://github.com/loc-rdc/transfer_rep/issues/7
        current.pop("", None)

    @staticmethod
    def remove_dots_from_key(dic):
        # https://github.com/loc-rdc/transfer_rep/issues/15
        return {k.replace('.', ''): v for k, v in dic.items()}

    @staticmethod
    def set_field(master_row, slave, key, field_name):
        current_slave_value = slave.get(key)
        master_row.update({field_name: current_slave_value})

    @staticmethod
    def set_field_as_dict(master_row, slave, key, field_name):
        # The field is a nested object
        # it is important to set default to {} (do not set to None)
        # so that ES know it is not a regular field
        current_slave_value = slave.get(key, {})
        Merge.remove_empty_key(current_slave_value)
        master_row.update({field_name: Merge.remove_dots_from_key(current_slave_value)})

    @staticmethod
    def set_multiple_fields(master_row, slave, key, fields_set=None, defaults=None):
        """
        This is a mission critical function that should have the minimal time complexity

        :param master_row: a row from the master tables; usually a dict
        :param slave:  an additional table that adds fields to the master row
        :param key:  a key that gets the fields from the addtional table or slave table
        :param fields_set: a hash set that contains the fields that are required
        :return: None. The maseter_row itself will be modified

        """
        if fields_set is not None and not isinstance(fields_set, set):
            raise IOError("The fields_set must be a hash set")
        current_slave_value = slave.get(key, defaults)
        if fields_set is not None:
            # only set fields in fields_set
            if current_slave_value is not None:
                current_slave_value = {k: v for k, v in current_slave_value.items() if k in fields_set}
            else:
                current_slave_value = {k: None for k in fields_set}
        master_row.update(current_slave_value)
