import copy
from datetime import datetime
import logging
import time

from flask.ext import restful

from db import htsql_conn, as_dicts


# this is shared by search and single resource
class FindFieldsMixin(object):
    def find_fields(self, args):
        if not args.get('fields'):
                return []
        else:
            return args['fields'].split(',')


class SingleResource(restful.Resource, FindFieldsMixin):

    def get(self, id):
        show_fields = copy.copy(self.default_fields)
        overall_start_time = time.time()
        args = self.parser.parse_args()
        fields = self.find_fields(args)

        if fields:
            for maps, field_name in self.maps_fields:
                show_fields[field_name] = ''
                # looking at each field the user requested
                for field in fields:
                    # for each mapping, see if there is a field match. If so,
                    # add it to the field list
                    for m in maps:
                        if m[0] == field:
                            show_fields[field_name] += m[1] + ','

        year = args.get('year', default_year())

        qry = "/%s?%s_id='%s'" % (self.query_text(show_fields),
                                  self.table_name_stem, id)
        print(qry)

        speedlogger = logging.getLogger('speed')
        speedlogger.info('--------------------------------------------------')
        speedlogger.info('\nHTSQL query: \n%s' % qry)
        start_time = time.time()

        data = htsql_conn().produce(qry)

        speedlogger.info('HTSQL query time: %f' % (time.time() - start_time))

        data_dict = as_dicts(data)
        page_data = {'per_page': 1, 'page': 1, 'pages': 1, 'count': 1}

        speedlogger.info('\noverall time: %f' %
                         (time.time() - overall_start_time))

        return self.format(data_dict, page_data, year)

    def format(self, data_dict, page_data, year):
        return {'api_version': "0.2", 'pagination': page_data,
                'results': data_dict}
