import logging

from processors.merge import Merge
from processors.denormalization import Denormalization


# a helper class for holding transformed slave data and help merging
class YmlMerger(object):

    def __init__(self):
        self.slave_data = {} #holding transformed slave data
        self.slave_defaults = {} #holding default dictioanry for direct merge
        # map aggregation fields number to merge_op function call
        # merge funcations will be called by every doc generation, this
        # merge_op hashing can improve performance
        self.merge_op = {0:self.add_fields_direct,
                         1:self.add_field_by_list_aggregation,
                         2:self.add_field_by_key_value_aggregation}

    def transform_slaves(self, slaves, query_config):
        logger = logging.getLogger(__name__)
        logger.info('\ntransforming slaves...')

        for slave in slaves:
            logger.info('\ncurrent slave {}'.format(slave))
            aggregation_set = query_config[slave]['aggregation_fields']
            merge_key = query_config[slave]['merge_key']

            if aggregation_set == None or len(aggregation_set)==0:
                # for direct merge, populate the defult dic
                if len(slaves[slave]) != 0:
                    self.slave_defaults[slave] = {k:None for k in slaves[slave][0] if k != merge_key}

                if slave not in self.slave_data:#transform iterable
                    self.slave_data[slave] = Denormalization.hash_fields_for_distinctive_key(slaves[slave], merge_key)

            elif len(aggregation_set)==1:
                if slave not in self.slave_data:
                    self.slave_data[slave] = Denormalization.get_values_for_key(slaves[slave], merge_key, aggregation_set[0])

            elif len(aggregation_set) == 2:
                if slave not in self.slave_data:
                    self.slave_data[slave] = Denormalization.get_dictionaries_for_key(slaves[slave], merge_key, name=aggregation_set[0], value=aggregation_set[1])
            else:
                logger.info('transform operation not supported yet.')

        logger.info('\ntransforming done.')

    def merge_slave(self, master_row, slave, query_config):
        logger = logging.getLogger(__name__)
        aggregation_set = query_config[slave]['aggregation_fields']
        logger.debug('aggregation fields:{}'.format(aggregation_set))

        try:
            self.merge_op[len(aggregation_set)](master_row, slave, query_config)
        except Exception as e:
            logger.info('exception:{}'.format(e))
            logger.info('merge operation not supported yet.')


    def add_fields_direct(self, master_row, slave_name, query_config):
        merge_key = query_config[slave_name]['merge_key']
        Merge.set_multiple_fields(master_row,
                                  self.slave_data[slave_name],
                                  master_row[merge_key],
                                  defaults=self.slave_defaults[slave_name])

    def add_field_by_list_aggregation(self, master_row, slave_name, query_config):
        merge_key = query_config[slave_name]['merge_key']
        #slave_name will also be the field_name in the document
        #field_name = query_config[slave_name]['merge']['field_name']
        Merge.set_field(master_row, self.slave_data[slave_name], master_row[merge_key], slave_name)

    def add_field_by_key_value_aggregation(self, master_row, slave_name, query_config):
        merge_key = query_config[slave_name]['merge_key']
        #field_name = query_config[slave_name]['merge']['field_name']
        Merge.set_field_as_dict(master_row, self.slave_data[slave_name], master_row[merge_key], slave_name)
