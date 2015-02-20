import string

from flask.ext.restful import reqparse

from webservices.resources import SingleResource
from .formatter import BaseCommitteeResource


class CommitteeResource(BaseCommitteeResource, SingleResource):

    parser = reqparse.RequestParser()
    parser.add_argument(
        'fields',
        type=str,
        help='Choose the fields that are displayed'
    )

