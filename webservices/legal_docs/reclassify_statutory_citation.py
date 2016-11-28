import logging
logger = logging.getLogger(__name__)


def reclassify_pre2012_citation(title, section):
    """
    MURs have citations referring to old USC Titles that were remapped in 2012.
    We link to the current laws based on the original citations.
    Source: http://uscode.house.gov/editorialreclassification/t52/Reclassifications_Title_52.html
    """

    citations_map = {
        "2:431": ("52", "30101"),
        "2:432": ("52", "30102"),
        "2:433": ("52", "30103"),
        "2:434": ("52", "30104"),
        "2:437": ("52", "30105"),
        "2:437c": ("52", "30106"),
        "2:437d": ("52", "30107"),
        "2:437f": ("52", "30108"),
        "2:437g": ("52", "30109"),
        "2:437h": ("52", "30110"),
        "2:438": ("52", "30111"),
        "2:438a": ("52", "30112"),
        "2:439": ("52", "30113"),
        "2:439a": ("52", "30114"),
        "2:439c": ("52", "30115"),
        "2:441a": ("52", "30116"),
        "2:441a-1": ("52", "30117"),
        "2:441b": ("52", "30118"),
        "2:441c": ("52", "30119"),
        "2:441d": ("52", "30120"),
        "2:441e": ("52", "30121"),
        "2:441f": ("52", "30122"),
        "2:441g": ("52", "30123"),
        "2:441h": ("52", "30124"),
        "2:441i": ("52", "30125"),
        "2:441k": ("52", "30126"),
        "2:451": ("52", "30141"),
        "2:452": ("52", "30142"),
        "2:453": ("52", "30143"),
        "2:454": ("52", "30144"),
        "2:455": ("52", "30145"),
        "2:457": ("52", "30146"),
    }

    # Fallback to title, section if no mapping exists
    citation = citations_map.get('%s:%s' % (title, section), (title, section))
    if (title, section) != citation:
        logger.info('Mapping archived MUR statute citation %s ->  %s' % ((title, section), citation))

    return citation
