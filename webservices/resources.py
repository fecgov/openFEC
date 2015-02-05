import copy
from datetime import datetime
import logging
import time

from flask.ext import restful
from flask.ext.restful import reqparse
import htsql
import sqlalchemy as sa

from db import db_conn, htsql_conn, as_dicts


# this is shared by search and single resource
class FindFieldsMixin(object):
    def find_fields(self, args):
        if not args.get('fields'):
                return []
        else:
            return args['fields'].split(',')


# defaulting to the last 4 years so there is always the last presidential, we
# could make this 6 to ensure coverage of sitting senators.
def default_year():
    year = datetime.now().year
    years = [str(y) for y in range(year, year-4, -1)]
    return ','.join(years)


def natural_number(n):
    result = int(n)
    if result < 1:
        raise reqparse.ArgumentTypeError(
            'Must be a number greater than or equal to 1')
    return result


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


class Searchable(restful.Resource, FindFieldsMixin):

    fulltext_qry = """SELECT {name_stem}_sk
                      FROM   dim{name_stem}_fulltext
                      WHERE  fulltxt @@ to_tsquery(:findme)
                      ORDER BY ts_rank_cd(fulltxt, to_tsquery(:findme)) desc"""

    def get(self):
        speedlogger = logging.getLogger('speed')
        overall_start_time = time.time()
        speedlogger.info('--------------------------------------------------')
        args = self.parser.parse_args(strict=True)
        elements = []
        page_num = 1
        show_fields = copy.copy(self.default_fields)
        field_list = self.find_fields(args)

        # queries need year to link the data
        year = args.get('year', default_year())

        for arg in args:
            if args[arg]:
                if arg == 'q':
                    qry = self.fulltext_qry.format(
                        name_stem=self.table_name_stem)
                    qry = sa.sql.text(qry)
                    speedlogger.info('\nfulltext query: \n%s' % qry)
                    start_time = time.time()
                    findme = ' & '.join(args['q'].split())
                    fts_result = db_conn().execute(qry,
                                                   findme=findme).fetchall()
                    speedlogger.info('fulltext query time: %f' %
                                     (time.time() - start_time))
                    if not fts_result:
                        return []
                    elements.append(
                        "%s_sk={%s}" %
                        (self.table_name_stem,
                         ",".join(str(id[0]) for id in fts_result)))
                elif arg == 'page':
                    page_num = args[arg]
                elif arg == 'per_page':
                    per_page = args[arg]
                elif arg == 'fields':
                    # going through the different kinds of mappings and fields
                    for maps, field_name in self.maps_fields:
                        show_fields[field_name] = ''
                        # looking at each field the user requested
                        for field in field_list:
                            # for each mapping, see if there is a field match.
                            # If so, add it to the field list
                            for m in maps:
                                if m[0] == field:
                                    show_fields[field_name] += m[1] + ','
                else:
                    if arg in self.field_name_map:
                        element = self.field_name_map[arg].substitute(
                            arg=args[arg].upper().replace(',', "','"))
                        elements.append(element)

        qry = self.query_text(show_fields)

        if elements:
            qry += "?" + "&".join(elements)
            count_qry = "/count(%s?%s)" % (self.viewable_table_name,
                                           "&".join(elements))
            # Committee endpoint is not year sensitive yet, so we don't want
            # to limit it yet. Otherwise, the candidate's won't show if they
            # are not in the default year.
            if year != '*' and (str(self.endpoint) == 'candidateresource'
                                or str(self.endpoint) == 'candidatesearch'):
                qry = qry.replace(
                    'dimcandoffice',
                    '(dimcandoffice?cand_election_yr={%s})' % year)
                count_qry = count_qry.replace(
                    'dimcandoffice',
                    '(dimcandoffice?cand_election_yr={%s})' % year)
        else:
            count_qry = "/count(%s)" % self.viewable_table_name
            print count_qry

        offset = per_page * (page_num-1)
        qry = "/(%s).limit(%d,%d)" % (qry, per_page, offset)

        print("\n%s\n" % (qry))

        speedlogger.info('\n\nHTSQL query: \n%s' % qry)
        start_time = time.time()
        data = htsql_conn().produce(qry)
        speedlogger.info('HTSQL query time: %f' % (time.time() - start_time))

        count = htsql_conn().produce(count_qry)

        data_dict = as_dicts(data)

        # page info
        data_count = int(count[0])
        pages = data_count/per_page
        if data_count % per_page != 0:
            pages += 1
        if data_count < per_page:
            per_page = data_count

        page_data = {'per_page': per_page, 'page': page_num, 'pages': pages,
                     'count': data_count}

        speedlogger.info('\noverall time: %f' %
                         (time.time() - overall_start_time))

        return self.format(data_dict, page_data, year)

    def format(self, data_dict, page_data, year):
        return {'api_version': "0.2", 'pagination': page_data,
                'results': data_dict}
