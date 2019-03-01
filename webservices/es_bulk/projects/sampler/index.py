from dataloaders.dataloader_zerodowntime import DataLoaderZeroDownTime
from utils.common import get_mappings
from reporting import Reporting
from documents.yml_documents import YmlDataProvider
from documents.yml_documents import YmlDocuments
import os

def build(settings):
    # prepare the dependencies
    yml_data_provider = YmlDataProvider(server=settings.SAMPLER_DB_HOST,
                                        database=settings.SAMPLER_DATABASE,
                                        username=settings.SAMPLER_DB_USER,
                                        password=settings.SAMPLER_DB_PASSWORD)

    docs = YmlDocuments(yml_data_provider,
            os.path.join(os.path.dirname(__file__), 'sampler.yml'))
    reporting = Reporting(data_loader=DataLoaderZeroDownTime(es_ip=settings.ES_URL))
    mappings = get_mappings(os.path.join(os.path.dirname(__file__),
        'mappings/sampler_index.json'))
    print("*******mappings:{}".format(mappings))
    reporting.index(index="schedual_a",
                    mappings=mappings,
                    documents=docs,
                    key_field='sub_id')
