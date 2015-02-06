import string

from flask.ext.restful import reqparse

from webservices.common.util import natural_number
from webservices.resources import Searchable, SingleResource
from .models import Total


class BaseTotalsResource(Total):
    """Common Base Class for Total Resources. Not a Mixin as the resources
    also inherit from a model"""

    # @todo split this into smaller functions; make less pointy
    def format(self, data_dict, page_data, year):
        args = self.parser.parse_args()
        fields = self.find_fields(args)
        data = data_dict    # match naming in migrated code

        results = []
        com = {}

        for committee in data:
            committee_id = committee['cmte_id']

            com[committee_id] = {}

            for api_name, fec_name in self.dim_mapping:
                if fec_name in committee:
                    com[committee_id][api_name] = committee[fec_name]
            reports = []

            bucket_map = (
                ('factpresidential_f3p', self.presidential_mapping,
                    'presidential'),
                ('factpacsandparties_f3x', self.pac_party_mapping,
                    'pac_party'),
                ('facthousesenate_f3', self.house_senate_mapping,
                    'house_senate'),
            )

            # loop through the specifics in the forms
            for bucket, mapping, kind in bucket_map:
                if bucket in committee:
                    for record in committee[bucket]:
                        if record != []:
                            details = {}
                            if fields == [] or '*' in fields or 'type' in fields:
                                details['type'] = kind

                            for api_name, fec_name in mapping:
                                if record.get(fec_name) is not None:
                                    details[api_name] = record[fec_name]

                            if 'dimreporttype' in record:
                                for api_name, fec_name in self.report_mapping:
                                    if fec_name in record['dimreporttype'][0]:
                                        details[api_name] = \
                                            record['dimreporttype'][0][fec_name]

                            if details != {}:
                                reports.append(details)

            if reports != []:
                com[committee_id]['reports'] = sorted(
                    reports, key=lambda k: k['report_year'], reverse=True)

            # add sums
            totals = {}
            totals_mappings = (
                ('hs_sums', self.house_senate_totals),
                ('p_sums', self.presidential_totals),
                ('pp_sums', self.pac_party_totals),
            )

            for name, mapping in totals_mappings:
                if name in committee and committee[name] != []:
                    for api_name, fec_name in mapping:
                        for t in committee[name]:
                            if fec_name in t and api_name != '*':
                                if t['two_yr_period_sk'] not in totals:
                                    totals[t['two_yr_period_sk']] = {}
                                totals[t['two_yr_period_sk']][api_name] = \
                                    t[fec_name]

            if totals != {}:
                com[committee_id]['totals'] = []
                for key in sorted(totals, key=totals.get, reverse=True):
                    com[committee_id]['totals'].append(totals[key])

            results.append(com[committee_id])
        return {'api_version': "0.2", 'pagination': page_data,
                'results': results}


class TotalResource(BaseTotalsResource, SingleResource):
    parser = reqparse.RequestParser()

    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'election_cycle',
        type=str,
        default=None,
        help='Limit results to a two-year election cycle'
    )


class TotalSearch(BaseTotalsResource, Searchable):
    parser = reqparse.RequestParser()

    field_name_map = {
        "committee_id": string.Template("cmte_id={'$arg'}"),
    }

    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )
    parser.add_argument(
        'page',
        type=natural_number,
        default=1,
        help='For paginating through results, starting at page 1'
    )
    parser.add_argument(
        'per_page',
        type=natural_number,
        default=20,
        help='The number of results returned per page. Defaults to 20.'
    )
    parser.add_argument(
        'committee_id',
        type=str,
        help='Committee ID that starts with a "C"'
    )
    parser.add_argument(
        'election_cycle',
        type=str,
        default=None,
        help='Limit results to a two-year election cycle'
    )
