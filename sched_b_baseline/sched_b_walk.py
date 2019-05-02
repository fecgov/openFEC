"""
this is a simple scipt to walk through a list sched_b endpopints
"""
import os
import click
import requests
from time import time




# testing some long walks and collect request fullfill time
def check_endpoints():
    names = []
    urls = []
    with open('sched_b.list','r') as f:
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
