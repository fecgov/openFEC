import logging
from webservices import utils
import json
import datetime
from json import JSONEncoder

logger = logging.getLogger(__name__)


class DateTimeEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()


def check_legal_doc():

    try:
        es_client = utils.create_es_client()

        logger.info("\n==================Legal doc info==================")
        logger.info("\n*** All indices: ***\n{0}".format(es_client.cat.indices()))

        if es_client.indices.exists(index="docs"):
            logger.info("\n*** alias under 'docs': ***\n{0}".format(
                json.dumps(es_client.indices.get_alias(index="docs"), indent=2)))

        if es_client.indices.exists(index="archived_murs"):
            logger.info("\n*** alias under 'archived_murs': ***\n{0}".format(
                json.dumps(es_client.indices.get_alias(index="archived_murs"), indent=2)))

        if es_client.indices.exists(index="docs"):
            logger.info("\n*** total count in 'docs': ***\n{0}".format(
                json.dumps(es_client.count(index="docs"), indent=2)))

        if es_client.indices.exists(index="archived_murs"):
            logger.info("\n*** total count in 'archived_murs': ***\n{0}".format(
                json.dumps(es_client.count(index="archived_murs"), indent=2)))

        if es_client.indices.exists(index="docs_search"):
            logger.info("\n*** total count in 'docs_search': ***\n{0}".format(
                json.dumps(es_client.count(index="docs_search"), indent=2)))

        if es_client.indices.exists(index="docs"):
            logger.info("\n*** mappings for 'docs':***\n{0}".format(
                json.dumps(es_client.indices.get_mapping(index="docs"), indent=2)))

        if es_client.indices.exists(index="archived_murs"):
            logger.info("\n*** mappings for 'archived_murs': ***\n{0}".format(
                json.dumps(es_client.indices.get_mapping(index="archived_murs"), indent=2)))

        logger.info("\n*** current mur_7212 data: ***\n{0}".format(
            json.dumps(es_client.get(index="docs", id="mur_7212"), indent=2, cls=DateTimeEncoder)))

        logger.info("\n*** af_12 data: ***\n{0}".format(
            json.dumps(es_client.get(index="docs", id="af_12"), indent=2, cls=DateTimeEncoder)))

        # logger.info("\n*** adr_008 data: ***\n{0}".format(
        #     json.dumps(es_client.get(index="docs", id="adr_008"), indent=2, cls=DateTimeEncoder)))

        # logger.info("\n*** ao 1975-01 data: ***\n{0}".format(
        #     json.dumps(es_client.get(index="docs", id="1975-01"), indent=2, cls=DateTimeEncoder)))

        # logger.info("\n*** archived mur_4 data: ***\n{0}".format(
        #     json.dumps(es_client.get(index="archived_murs", id="mur_4"), indent=2, cls=DateTimeEncoder)))

    except Exception as err:
        logger.error('An error occurred while running the get command.{0}'.format(err))
