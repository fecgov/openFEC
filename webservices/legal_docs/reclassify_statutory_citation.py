import csv
import logging
logger = logging.getLogger(__name__)


def reclassify_pre2012_citation(title, section, archived_mur_citation_map={}):
    """
    MURs have citations referring to old USC Titles that were remapped in 2012.
    We link to the current laws based on the original citations.
    Source: http://uscode.house.gov/editorialreclassification/t52/Reclassifications_Title_52.html
    """

    def _load_citation_map(archived_mur_citation_map):
        # Cache the map
        if len(archived_mur_citation_map):
            return archived_mur_citation_map

        logger.info('Loading archived_mur_citation_map.csv')
        with open('data/mur_citation_map.csv') as csvfile:
            for row in csv.reader(csvfile):
                title, section = row[1].split(':', 2)
                archived_mur_citation_map[row[0]] = (title, section)
        return archived_mur_citation_map

    citations_map = _load_citation_map(archived_mur_citation_map)

    # Fallback to title, section if no mapping exists
    citation = citations_map.get('%s:%s' % (title, section), (title, section))
    if (title, section) != citation:
        logger.info('Mapping archived MUR statute citation %s ->  %s' % ((title, section), citation))

    return citation
