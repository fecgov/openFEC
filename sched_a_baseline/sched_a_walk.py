"""
this is a simple scipt to walk through a list sched_a endpopints made
for baseline performance testing

those endpoints currently not loading at all:

>>top committee type 'W' not loading with cycle141618:
https://api-stage.open.fec.gov/v1/schedules/schedule_a?
sort_hide_null=false&per_page=30&is_individual=true&two_year_transaction_period
=2016&two_year_transaction_period=2018&two_year_transaction_period=2014&
sort=-contribution_receipt_date&sort_nulls_last=false&api_key=DEMO_KEY&
recipient_committee_type=W

>>top line_num - this one need to be re-tested
https://api-stage.open.fec.gov/v1/schedules/schedule_a?
sort_hide_null=false&per_page=30&is_individual=true&
two_year_transaction_period=2016&two_year_transaction_period=2018
&two_year_transaction_period=2014&sort=-contribution_receipt_date
&sort_nulls_last=false&api_key=DEMO_KEY&line_number=F3X-11AI

>>self_employed not loading:
https://api-stage.open.fec.gov/v1/schedules/schedule_a?
sort_hide_null=false&per_page=30&is_individual=true&
two_year_transaction_period=2018&two_year_transaction_period=2014&
sort=-contribution_receipt_date&sort_nulls_last=false&api_key=DEMO_KEY&
contributor_employer=not employed



"""
import os
import click
import requests
from time import time




# testing some long walks and collect request fullfill time
def check_endpoints():
    names = []
    urls = []
    with open('sched_a.list','r') as f:
        all_lines = f.readlines()
        for line in all_lines:
            if line.startswith('>'):
                names.append(line.strip().replace('>', ''))
            else:
                urls.append(line.strip())
  
    for name, url in zip(names, urls):
        ts = time()
        r = requests.get(
            url
        )
        if r.status_code == 200:
            te = time()
            print('Request {} took:\n {} seconds'.format(name, round(te - ts, 2)) + '\n')
        else:
            print("******{}: not working. Status: {}".format(name, r.status_code))

if __name__ == "__main__":
    check_endpoints()
