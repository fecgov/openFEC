import logging

import psycopg2
from psycopg2.extras import DictCursor
import yaml

from utils.decorators import timing

from processors.yml_merge import YmlMerger
from processors.normalization import normalize_datetime
from utils.decorators import timing

from documents import Documents

class YmlDataProvider(object):
    def __init__(self, server, username, password, database):
        self.server = server
        self.user = username
        self.password = password
        self.database = database

    @property
    def connection(self):
        return psycopg2.connect(host=self.server,
                               user=self.user,
                               password=self.password,
                               database=self.database,
                               cursor_factory=psycopg2.extras.RealDictCursor)
                            #    charset='utf8mb4')

    @timing
    def load_queries(self, config_yml):
        logger = logging.getLogger(__name__)

        #read yml file
        logger.info('core configured.')
        try:
            with open(config_yml, 'r') as my_yml:
                query_config = yaml.load(my_yml)
        except Exception as e:
            logger.error('errors with reading yml file: {}'.format(e.message))
        logger.info('reading yml file done successfully .')
        return query_config

    #@timing
    def pull_slaves(self, query_config):
        logger = logging.getLogger(__name__)
        slave_dic = {}
        if query_config['slave_queries'] and len(query_config['slave_queries']) != 0:
            logger.info('slave quereis: {}'.format(query_config['slave_queries']))
            for _q in query_config['slave_queries']:
                logger.info('*'*10+'running slave query'+'*'*10)
                logger.info('curr query: {}'.format(_q))
                logger.info('sql: {}'.format(query_config[_q]['sql']))
                with self.connection as cursor:
                    cursor.execute(query_config[_q]['sql'])
                    slave_dic[_q] = cursor.fetchall()
                logger.info('*'*10+'current query done.'+'*'*10)

        return slave_dic



class YmlDocuments(Documents):

    def __init__(self, yml_data_provider, yml_file):
        super().__init__()
        self.data_provider = yml_data_provider
        self.yml_file = yml_file

    @timing
    def get_document(self):
        logger = logging.getLogger(__name__)
        logger.info('\nmerging dataframes and generate document for indexing...')

        #master, slaves, query_config = self.data_provider.pull_data_by_yml(self.yml_file)
        query_config = self.data_provider.load_queries(self.yml_file)
        logger.info('\ntotal slave queries {}'.format(query_config['slave_queries']))
        #master_cursor = self.data_provider.pull_master(query_config)
        slaves = self.data_provider.pull_slaves(query_config)


        if slaves:
            slave_merger = YmlMerger()
            slave_merger.transform_slaves(slaves, query_config)

        #load master
        #with self.data_provider.connection as cursor:
        cursor = self.data_provider.connection.cursor()
        #cursor =  
        logger.info('master_query: {}'.format(query_config['master_query']))
        cursor.execute(query_config['master_query'])


        master_row = cursor.fetchone()
        while master_row:
            #for master_row in master:
            for slave in slaves:
                logger.debug('current slave: {}'.format(slave))
                slave_merger.merge_slave(master_row, slave, query_config)

            self.normalize_boolean(master_row)

            if 'hidden_fields' in query_config and len(query_config['hidden_fields'])!=0:
                master_row = self.remove_hidden_fields(master_row, set(query_config['hidden_fields']))
            #print('doc {} before date conversion:'.format(master_row))
            #self.normalize_datetime(master_row)
            #print(master_row)
            yield master_row

            master_row = cursor.fetchone()

            # #TODO: will use 1000 for now, update this later on based on testing
            # master = cursor.fetchmany(100)
            # while master:
            #     for master_row in master:
            #         for slave in slaves:
            #             logger.debug('current slave: {}'.format(slave))
            #             slave_merger.merge_slave(master_row, slave, query_config)
            #
            #         self.normalize_boolean(master_row)
            #
            #         if query_config['hidden_fields']:
            #             master_row = self.remove_hidden_fields(master_row, set(query_config['hidden_fields']))
            #
            #         normalize_datetime(master_row)
            #         yield master_row
            #
            #     master = cursor.fetchmany(100)
