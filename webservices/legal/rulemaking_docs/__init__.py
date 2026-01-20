import logging
import sys

from .rulemaking import load_rulemaking

logging.basicConfig(level=logging.INFO, stream=sys.stdout)
# TODO (clucas) verify if this is working as intended
logger = logging.getLogger("opensearch")
logger.setLevel("WARN")
logger = logging.getLogger("botocore")


def reload_rulemaking():
    load_rulemaking()
