#!/usr/bin/env python
import sys

import xlrd
import lxml.html
import requests


LIBRARY = "http://www.fec.gov/general/library.shtml"


def lxmlize(url):
    req = requests.get(url)
    page = lxml.html.fromstring(req.content)
    page.make_links_absolute(url)
    return page


def scrape_xls(xls):
    book = xlrd.open_workbook(xls)
    print(book)


def scrape_html(page):
    for spreadsheet in page.xpath(
        "//a[contains(@href, 'federalelections') "
            "and contains(@href, '.xls')]/@href"
    ):
        print(spreadsheet)

    if False:
        yield


def save(data):
    for el in data:
        print(el)


def scrape():
    return scrape_xls("federalelections2012.xls")

    lib = lxmlize(LIBRARY)
    for page in set(lib.xpath("//a[contains(@href, 'federalelections')]/@href")):
        if page.endswith(".pdf"):
            continue  # XXX: Write a PDF parser
        save(scrape_html(lxmlize(page)))


if __name__ == "__main__":
    scrape(*sys.argv[1:])
