import re
import logging

"""
MURs have citations referring to old USC Titles that were remapped in 2012.
We link to the current laws based on the original citations.
Source: http://uscode.house.gov/editorialreclassification/t52/Reclassifications_Title_52.html
"""

logger = logging.getLogger(__name__)

CITATIONS_MAP = {
    "431": "30101",
    "432": "30102",
    "433": "30103",
    "434": "30104",
    "437": "30105",
    "437c": "30106",
    "437d": "30107",
    "437f": "30108",
    "437g": "30109",
    "437h": "30110",
    "438": "30111",
    "438a": "30112",
    "439": "30113",
    "439a": "30114",
    "439c": "30115",
    "441a": "30116",
    "441a-1": "30117",
    "441b": "30118",
    "441c": "30119",
    "441d": "30120",
    "441e": "30121",
    "441f": "30122",
    "441g": "30123",
    "441h": "30124",
    "441i": "30125",
    "441k": "30126",
    "451": "30141",
    "452": "30142",
    "453": "30143",
    "454": "30144",
    "455": "30145",
    "457": "30146",
}

# The new section numbers are 5 digit numbers starting with 30. e.g., 30106
RECLASSIFIED_STATUTE_SECTION_REGEX = re.compile(r'30\d{3,}')

def reclassify_archived_mur_statutory_citation(title, section):
    """
    Archived MURs indicate the titles explicitly. They also cite titles other than 2,
    but not 52. If we can successfully reclassify title 2, we assume that they
    are title 52, otherwise we retain the original title.
    """
    MAPPED_TITLE = "52"
    if title == "2":
        mapped_section = CITATIONS_MAP.get(section)
        if mapped_section:
            logger.debug('Mapping archived MUR statute citation %s -> %s',
                        (title, section), (MAPPED_TITLE, mapped_section))
            return MAPPED_TITLE, mapped_section
        logger.debug('Unmapped 2 U.S.C citation: %s', (title, section))
    return title, section

def reclassify_current_mur_statutory_citation(section):
    """
    Current MURs do not indicate the titles explicitly; they have to be deduced
    from the section. Sometimes the sections have already been reclassified.
    If we can successfully reclassify them, or if they match the reclassified
    section pattern, we assign the title of 52, otherwise they are assumed to be
    title 2.
    """
    ORIGINAL_TITLE = "2"
    MAPPED_TITLE = "52"
    mapped_section = CITATIONS_MAP.get(section)
    if mapped_section:
        logger.debug('Mapping current MUR statute citation %s -> %s',
                    section, (MAPPED_TITLE, mapped_section))
        return ORIGINAL_TITLE, MAPPED_TITLE, mapped_section
    elif RECLASSIFIED_STATUTE_SECTION_REGEX.match(section):
        return MAPPED_TITLE, MAPPED_TITLE, section
    else:
        return ORIGINAL_TITLE, ORIGINAL_TITLE, section
