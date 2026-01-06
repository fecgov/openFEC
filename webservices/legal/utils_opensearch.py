import logging
import json
import time
import datetime
import certifi
import webservices.legal.constants as constants


from webservices.legal.mappings import rm_mapping, ao_mapping, arch_mur_mapping, case_mapping
from webservices.env import env
from webservices.tasks.utils import get_bucket

from opensearchpy import OpenSearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth
from json import JSONEncoder

logger = logging.getLogger(__name__)
# To debug, uncomment the line below:
# logger.setLevel(logging.DEBUG)

# SEARCH_ALIAS is used for legal/search endpoint
# RM_SEARCH_ALIAS is used for rulemaking/search endpoint
# XXXX_ALIAS is used for load data to XXXX_INDEX on OpenSearch
INDEX_DICT = {
    constants.CASE_INDEX: (case_mapping.CASE_MAPPING, constants.CASE_ALIAS,
                           constants.SEARCH_ALIAS, constants.CASE_SWAP_INDEX,
                           constants.CASE_REPO, constants.CASE_SNAPSHOT),
    constants.AO_INDEX: (ao_mapping.AO_MAPPING, constants.AO_ALIAS,
                         constants.SEARCH_ALIAS, constants.AO_SWAP_INDEX,
                         constants.AO_REPO, constants.AO_SNAPSHOT),
    constants.ARCH_MUR_INDEX: (arch_mur_mapping.ARCH_MUR_MAPPING, constants.ARCH_MUR_ALIAS, constants.SEARCH_ALIAS,
                               constants.ARCH_MUR_SWAP_INDEX,
                               constants.ARCH_MUR_REPO, constants.ARCH_MUR_SNAPSHOT),
    constants.CASE_SWAP_INDEX: (case_mapping.CASE_MAPPING, "", "", "", "", ""),
    constants.AO_SWAP_INDEX: (ao_mapping.AO_MAPPING, "", "", "", "", ""),
    constants.ARCH_MUR_SWAP_INDEX: (arch_mur_mapping.ARCH_MUR_MAPPING, "", "", "", "", ""),
    constants.RM_INDEX: (rm_mapping.RM_MAPPING, constants.RM_ALIAS,
                         constants.RM_SEARCH_ALIAS, constants.RM_SWAP_INDEX,
                         constants.RM_REPO, constants.RM_SNAPSHOT),
}

TEST_INDEX_DICT = {
        constants.TEST_CASE_INDEX: (case_mapping.CASE_MAPPING,
                                    constants.TEST_CASE_ALIAS, constants.TEST_SEARCH_ALIAS),
        constants.TEST_AO_INDEX: (ao_mapping.AO_MAPPING, constants.TEST_AO_ALIAS,
                                  constants.TEST_SEARCH_ALIAS),
        constants.TEST_ARCH_MUR_INDEX: (arch_mur_mapping.ARCH_MUR_MAPPING,
                                        constants.TEST_ARCH_MUR_ALIAS, constants.TEST_SEARCH_ALIAS),
        constants.TEST_RM_INDEX: (rm_mapping.RM_MAPPING, constants.TEST_RM_ALIAS, constants.TEST_RM_SEARCH_ALIAS)
}


def get_service_instance(service_instance_name):
    return env.get_service(name=service_instance_name)


def get_service_instance_credentials(service_instance):
    return service_instance.credentials


def create_eregs_link(part, section):
    url_part_section = part
    if section:
        url_part_section += "-" + section
    return "/regulations/{}/CURRENT".format(url_part_section)


def upload_citations(statutory_citations, regulatory_citations, index, doc_type, opensearch_client):
    try:
        for citation in statutory_citations:
            entry = {
                "type": "citations",
                "citation_text": citation,
                "citation_type": "statute",
                "doc_type": doc_type,
            }
            opensearch_client.index(index, entry, id=doc_type + "_" + citation)

        for citation in regulatory_citations:
            entry = {
                "type": "citations",
                "citation_text": citation,
                "citation_type": "regulation",
                "doc_type": doc_type,
            }
            opensearch_client.index(index, entry, id=doc_type + "_" + citation)
    except Exception:
        logger.error("An error occurred while uploading {} citations".format(doc_type))


def check_filter_exists(kwargs, filter):
    if kwargs.get(filter):
        for val in kwargs.get(filter):
            if len(val) > 0:
                return True
        return False
    else:
        return False


# To display the open_date and close_date of JSON format inside object "mur"
class DateTimeEncoder(JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (datetime.date, datetime.datetime)):
            return obj.isoformat()


def create_opensearch_client():
    try:
        opensearch_service = get_service_instance(constants.ES_SERVICE_INSTANCE_NAME)
        if opensearch_service:
            credentials = opensearch_service.credentials
            #  create "http_auth".
            host = credentials["host"]
            access_key = credentials["access_key"]
            secret_key = credentials["secret_key"]
            aws_auth = AWS4Auth(access_key, secret_key, constants.REGION, constants.AWS_ES_SERVICE)

            #  create opensearch client through "http_auth"
            opensearch_client = OpenSearch(
                hosts=[{"host": host, "port": constants.PORT}],
                http_auth=aws_auth,
                use_ssl=True,
                verify_certs=True,
                ca_certs=certifi.where(),
                connection_class=RequestsHttpConnection,
                timeout=40,
                max_retries=10,
                retry_on_timeout=True,
            )
        else:
            # create local opensearch client
            url = "http://localhost:9200"
            opensearch_client = OpenSearch(
                url,
                timeout=30,
                max_retries=10,
                retry_on_timeout=True,
            )
        return opensearch_client
    except Exception as err:
        logger.error("An error occurred trying to create OpenSearch client.{0}".format(err))


def create_index(index_name=None):
    """
    Creating an index for storing legal or rulemaking data on OpenSearch based on 'INDEX_DICT'.
    - 'INDEX_DICT' description:
    1) CASE_INDEX includes DOCUMENT_TYPE=('statutes','murs','adrs','admin_fines')
    'murs' means current mur only.
    2) AO_INDEX includes DOCUMENT_TYPE=('advisory_opinions')
    3) ARCH_MUR_INDEX includes DOCUMENT_TYPE=('murs'), archived mur only
    4) RM_INDEX includes DOCUMENT_TYPE=('rulemaking')?

    -Two aliases will be created under each index: XXXX_ALIAS and SEARCH_ALIAS or RM_SEARCH_ALIAS
    a) XXXX_ALIAS is used for load data to XXXX_INDEX on OpenSearch
    b) SEARCH_ALIAS is used for '/legal/search/' endpoint
    c) RM_SEARCH_ALIAS is used for '/rulemaking/search/' endpoint

    -How to call this function in python code:
    a) create_index(CASE_INDEX)
    b) create_index(AO_INDEX)
    c) create_index(ARCH_MUR_INDEX)
    d) create_index(RM_INDEX)

    -How to run command from terminal:
    a) python cli.py create_index case_index
    b) python cli.py create_index ao_index
    c) python cli.py create_index arch_mur_index
    d) python cli.py create_index rm_index

    -How to call task command:
    a) cf run-task api --command "python cli.py create_index" -m 2G --name create_case_index
    b) cf run-task api --command "python cli.py create_index ao_index" -m 2G --name create_ao_index
    c) cf run-task api --command "python cli.py create_index arch_mur_index" -m 2G --name create_arch_mur_index
    d) cf run-task api --command "python cli.py create_index rm_index" -m 2G --name create_rm_index

    -This function won't allow to create any other index that is not in 'INDEX_DICT'.
    """
    body = {}
    aliases = {}
    body.update({"settings": constants.ANALYZER_SETTING})

    if index_name in INDEX_DICT.keys():
        # Before creating index, delete this index and corresponding aliases first.
        delete_index(index_name)

        mapping, alias1, alias2 = INDEX_DICT.get(index_name)[:3]
        body.update({"mappings": mapping})

        if alias1 and alias2:
            aliases.update({alias1: {}})
            aliases.update({alias2: {}})
            body.update({"aliases": aliases})

        opensearch_client = create_opensearch_client()
        logger.info(" Creating index '{0}'...".format(index_name))
        opensearch_client.indices.create(
            index=index_name,
            body=body,
        )
        logger.info(" The index '{0}' is created successfully.".format(index_name))
        if alias1 and alias2:
            logger.info(" The aliases for index '{0}': {1}, {2} are created successfully.".format(
                index_name,
                alias1,
                alias2))
    else:
        logger.error(" Invalid index '{0}'.".format(index_name))


def delete_index(index_name):
    """
    Delete an index, the argument 'index_name' is required
    -How to call this function in python code:
    a) opensearch_delete_index(CASE_INDEX)
    b) opensearch_delete_index(AO_INDEX)
    c) opensearch_delete_index(ARCH_MUR_INDEX)
    d) opensearch_delete_index(RM_INDEX)

    -How to run from terminal:
    a) python cli.py opensearch_delete_index case_index
    b) python cli.py opensearch_delete_index ao_index
    c) python cli.py opensearch_delete_index arch_mur_index
    d) python cli.py opensearch_delete_index rm_index

    -How to call task command in cf:
    a) cf run-task api --command "python cli.py delete_index case_index" -m 2G --name delete_case_index
    b) cf run-task api --command "python cli.py delete_index ao_index" -m 2G --name delete_ao_index
    c) cf run-task api --command "python cli.py delete_index arch_mur_index" -m 2G --name delete_arch_mur_index
    d) cf run-task api --command "python cli.py delete_index rm_index" -m 2G --name delete_rm_index
    """
    opensearch_client = create_opensearch_client()
    logger.info(" Checking if index '{0}' already exist...".format(index_name))
    if opensearch_client.indices.exists(index=index_name):
        try:
            logger.info(" Deleting index '{0}'...".format(index_name))
            opensearch_client.indices.delete(index_name)
            # sleep 60 seconds (1 min)
            time.sleep(60)
            logger.info(" The index '{0}' is deleted successfully.".format(index_name))
        except Exception:
            pass
    else:
        logger.error(" The index '{0}' is not found.".format(index_name))


def display_index_alias():
    """
    Display all indices and aliases on OpenSearch.
    -How to run from terminal:
    'python cli.py opensearch_display_index_alias'

    -How to call task command:
    cf run-task api --command "python cli.py display_index_alias" -m 2G --name display_index_alias
    """
    opensearch_client = create_opensearch_client()
    indices = opensearch_client.cat.indices(format="JSON")
    logger.info(" All indices = " + json.dumps(indices, indent=3))

    for row in indices:
        logger.info(" The aliases under index '{0}': \n{1}".format(
            row["index"],
            json.dumps(opensearch_client.indices.get_alias(index=row["index"]), indent=3)))


def display_mapping(index_name=None):
    """
    Display the index mapping.
    -How to run from terminal:
    a) python cli.py opensearch_display_mapping case_index
    b) python cli.py opensearch_display_mapping ao_index
    c) python cli.py opensearch_display_mapping arch_mur_index
    d) python cli.py opensearch_display_mapping rm_index

    -How to call task command:
    a) cf run-task api --command "python cli.py display_mapping case_index" -m 2G --name display_case_index_mapping
    b) cf run-task api --command "python cli.py display_mapping ao_index" -m 2G --name display_ao_index_mapping
    c) cf run-task api --command "python cli.py display_mapping arch_mur_index" -m 2G
    --name display_arch_mur_index_mapping
    d) cf run-task api --command "python cli.py display_mapping rm_index" -m 2G --name display_rm_index_mapping
    """
    opensearch_client = create_opensearch_client()
    logger.info(" The mapping for index '{0}': \n{1}".format(
        index_name,
        json.dumps(opensearch_client.indices.get_mapping(index=index_name), indent=3)))


def create_test_indices():

    INDEX_DICT.update(TEST_INDEX_DICT)

    for index_name in TEST_INDEX_DICT:
        create_index(index_name)
        INDEX_DICT.pop(index_name)


def switch_alias(original_index=None, original_alias=None, swapping_index=None):
    """
    1) After create swapping_index(=XXXX_SWAP_INDEX)
    2) Switch the original_alias to point to swapping_index instead of original_index.

    -How to call this function in Python code:
    a) switch_alias(index_name, original_alias, swapping_index)
    """
    original_index = original_index or constants.CASE_INDEX
    original_alias = original_alias or INDEX_DICT.get(original_index)[1]
    swapping_index = swapping_index or INDEX_DICT.get(original_index)[3]

    opensearch_client = create_opensearch_client()
    # 1) Remove original_alias from original_index
    logger.info(" Removing original alias '{0}' from original index '{1}'...".format(
        original_alias, original_index)
    )
    try:
        opensearch_client.indices.update_aliases(
            body={
                "actions": [
                    {"remove": {"index": original_index, "alias": original_alias}},
                ]
            }
        )
        logger.info(" Removed original alias '{0}' from original index '{1}' successfully.".format(
            original_alias, original_index)
        )
    except Exception:
        pass

    # 2) Switch original_alias to swapping_index
    logger.info(" Switching original alias '{0}' to swapping index '{1}'...".format(
        original_alias, swapping_index)
    )
    opensearch_client.indices.update_aliases(
        body={
            "actions": [
                {"add": {"index": swapping_index, "alias": original_alias}},
            ]
        }
    )
    logger.info(" Switched original alias '{0}' to swapping index '{1}' successfully.".format(
        original_alias, swapping_index)
    )


def restore_from_swapping_index(index_name=None):
    """
    1. Swith the SEARCH_ALIAS to point to XXXX_SWAP_INDEX instead of index_name(original_index).
    2. Re-create original_index (XXXX_INDEX)
    3. Remove XXXX_ALIAS and SEARCH_ALIAS that point new empty XXXX_INDEX
    4. Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    5. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    6. Delete XXXX_SWAP_INDEX

    -How to call this function in Python code:
    a) restore_from_swapping_index(index_name)
    """
    index_name = index_name or constants.CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    opensearch_client = create_opensearch_client()

    # 1) Swith the SEARCH_ALIAS to point to XXXX_SWAP_INDEX instead of index_name(original_index).
    switch_alias(index_name, constants.SEARCH_ALIAS, swapping_index)

    # 2) Re-create original_index (XXXX_INDEX)
    create_index(index_name)

    # 3) Remove XXXX_ALIAS and SEARCH_ALIAS that point new empty XXXX_INDEX now
    opensearch_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": index_name, "alias": INDEX_DICT.get(index_name)[1]}},
                {"remove": {"index": index_name, "alias": constants.SEARCH_ALIAS}},
            ]
        }
    )
    logger.info(" Remove aliases '{0}' and '{1}' that point to empty '{2}' successfully.".format(
        INDEX_DICT.get(index_name)[1], constants.SEARCH_ALIAS, index_name)
    )

    # 4) Re-index XXXX_INDEX based on XXXX_SWAP_INDEX
    try:
        logger.info(" Reindexing all documents from index '{0}' to index '{1}'...".format(
            swapping_index, index_name)
        )
        body = {
            "source": {"index": swapping_index},
            "dest": {"index": index_name}
        }
        opensearch_client.reindex(
            body=body,
            wait_for_completion=True,
            request_timeout=1500
        )
    except Exception as e:
        logger.error(" Reindex exception error = {0}".format(e.args))

    # sleep 30 second (0.5 min)
    time.sleep(30)
    logger.info(" Reindexed all documents from index '{0}' to index '{1}' successfully.".format(
        swapping_index, index_name)
    )
    switch_aliases_to_original_index(index_name)


def switch_aliases_to_original_index(index_name=None):
    """
    1. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
    2. Delete XXXX_SWAP_INDEX

    -How to call this function in Python code:
    a) switch_aliases_to_original_index(index_name)
    """
    index_name = index_name or constants.CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    opensearch_client = create_opensearch_client()

    logger.info(" Moving aliases '{0}' and '{1}' to point to {2}...".format(
        INDEX_DICT.get(index_name)[1], constants.SEARCH_ALIAS, index_name)
    )
    opensearch_client.indices.update_aliases(
        body={
            "actions": [
                {"remove": {"index": swapping_index, "alias": INDEX_DICT.get(index_name)[1]}},
                {"remove": {"index": swapping_index, "alias": constants.SEARCH_ALIAS}},
                {"add": {"index": index_name, "alias": INDEX_DICT.get(index_name)[1]}},
                {"add": {"index": index_name, "alias": constants.SEARCH_ALIAS}},
            ]
        }
    )
    logger.info(" Moved aliases '{0}' and '{1}' to point to '{2}' successfully.".format(
        INDEX_DICT.get(index_name)[1], constants.SEARCH_ALIAS, index_name)
    )

    # sleep 60 second (1 min)
    time.sleep(60)

    logger.info(" Deleting index '{0}'...".format(swapping_index))
    opensearch_client.indices.delete(swapping_index)
    logger.info(" Deleted swapping index '{0}' successfully.".format(swapping_index))
    logger.info(" Task update_mapping_and_reload_legal_data on '{0}' has been completed successfully !!!".format(
        index_name)
    )
# =========== end index management =============


# =========== start repository management =============
def configure_snapshot_repository(repo_name=None):
    """
    Configure a s3 repository to store the snapshots, default repository_name = CASE_REPO
    This needs to get re-run when s3 credentials change for each api app deployment.

    How to call task command:
    ex1: cf run-task api --command "python cli.py configure_snapshot_repository case_repo" -m 2G
    --name configure_snapshot_repository
    ex2: cf run-task api --command "python cli.py configure_snapshot_repository ao_repo" -m 2G
    --name configure_snapshot_repository_ao
    ex3: cf run-task api --command "python cli.py configure_snapshot_repository arch_mur_repo" -m 2G
    --name configure_snapshot_repository_arch_mur
    """
    repo_name = repo_name or constants.CASE_REPO
    opensearch_client = create_opensearch_client()

    logger.info(" Configuring snapshot repository: {0}".format(repo_name))
    credentials = get_service_instance_credentials(get_service_instance(
        constants.S3_PRIVATE_SERVICE_INSTANCE_NAME))

    try:
        body = {
            "type": "s3",
            "settings": {
                "bucket": credentials["bucket"],
                "region": credentials["region"],
                "access_key": credentials["access_key_id"],
                "secret_key": credentials["secret_access_key"],
                "base_path": constants.S3_BACKUP_DIRECTORY,
                "role_arn": env.get_credential("ES_SNAPSHOT_ROLE_ARN"),
            },
        }
        opensearch_client.snapshot.create_repository(
            repository=repo_name,
            body=body,
        )
        logger.info(" Configured snapshot repository: {0} successfully.".format(repo_name))

    except Exception as err:
        logger.error(" Error occured in configure_snapshot_repository.{0}".format(err))


def delete_repository(repo_name):
    """
    Delete a s3 snapshot repository.

    How to call task command:
     ex1: cf run-task api --command "python cli.py delete_repository repository_name" -m 2G --name delete_repository
    """
    if repo_name:
        try:
            opensearch_client = create_opensearch_client()
            opensearch_client.snapshot.delete_repository(repository=repo_name)
            logger.info(" Deleted snapshot repository: {0} successfully.".format(repo_name))
        except Exception as err:
            logger.error(" Error occured in delete_repository.{0}".format(err))
    else:
        logger.error(" Please input a s3 repository name.")

    display_repositories()


def display_repositories():
    """
    Show all repositories.

    How to call task command:
    cf run-task api --command "python cli.py display_repositories" -m 2G --name display_repositories
    """

    opensearch_client = create_opensearch_client()
    result = opensearch_client.cat.repositories(
        format="JSON",
        v=True,
        s="id",
    )
    logger.info(" Repositories list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))

# =========== end repository management =============


# =========== start snapshot management =============

def create_opensearch_snapshot(index_name):
    """
    Create opensearch snapshot of specific XXXX_INDEX in XXXX_REPO.
    snapshot name likes: case_snapshot_202303091720, ao_snapshot_202303091728

    How to call task command:
    ex1: cf run-task api --command "python cli.py create_opensearch_snapshot case_index" -m 2G
    --name create_snapshot_case
    ex2: cf run-task api --command "python cli.py create_opensearch_snapshot ao_index" -m 2G
    --name create_snapshot_ao
    ex3: cf run-task api --command "python cli.py create_opensearch_snapshot arch_mur_index" -m 2G
    --name create_snapshot_arch_mur
    """
    index_name = index_name or constants.CASE_INDEX
    if index_name in INDEX_DICT.keys():
        repo_name = INDEX_DICT.get(index_name)[4]
        prefix_snapshot = INDEX_DICT.get(index_name)[5]
        index_name_list = [index_name]
        opensearch_client = create_opensearch_client()
        body = {
            "indices": index_name_list,
        }
        configure_snapshot_repository(repo_name)
        snapshot_name = "{0}_{1}".format(
            prefix_snapshot, datetime.datetime.today().strftime("%Y%m%d%H%M")
        )
        logger.info(" Creating snapshot {0} ...".format(snapshot_name))
        result = opensearch_client.snapshot.create(
            repository=repo_name,
            snapshot=snapshot_name,
            body=body,
            wait_for_completion=True,
        )
        result = result.get("snapshot")
        if result.get("state") == 'SUCCESS':
            logger.info(" The snapshot: {0} is created successfully.".format(snapshot_name))
        else:
            logger.error(" Unable to create snapshot: {0}".format(snapshot_name))
    else:
        logger.error(" Invalid index '{0}', no snapshot created.".format(index_name))


def delete_snapshot(repo_name, snapshot_name):
    """
    Delete a snapshot.

    How to call task command:
    ex1: cf run-task api --command "python cli.py delete_snapshot case_repo case_snapshot_202010272134" -m 2G
    --name delete_snapshot_case
    ex2: cf run-task api --command "python cli.py delete_snapshot ao_repo ao_snapshot_202010272132" -m 2G
    --name delete_snapshot_ao
    ex3: cf run-task api --command "python cli.py delete_snapshot arch_mur_repo arch_mur_snapshot_202010272132" -m 2G
    --name delete_snapshot_arch_mur
    """
    if repo_name and snapshot_name:
        configure_snapshot_repository(repo_name)
        try:
            logger.info(" Deleting snapshot {0} from {1} ...".format(snapshot_name, repo_name))
            opensearch_client = create_opensearch_client()
            opensearch_client.snapshot.delete(repository=repo_name, snapshot=snapshot_name)
            logger.info(" The snapshot {0} from {1} is deleted successfully.".format(snapshot_name, repo_name))
        except Exception as err:
            logger.error(" Error occured in delete_snapshot.{0}".format(err))
    else:
        logger.error(" Please provide both snapshot and repository names.")


def restore_opensearch_snapshot(repo_name=None, snapshot_name=None, index_name=None):
    """
    Restore legal data on opensearch from a snapshot in the event of catastrophic failure
    at the infrastructure layer or user error.
    This command restores 'index_name' snapshot only.

    -Delete index_name
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex1: cf run-task api --command "python cli.py restore_opensearch_snapshot case_repo
        case_snapshot_202010272132 case_index" -m 2G --name restore_opensearch_snapshot_case
    ex2: cf run-task api --command "python cli.py restore_opensearch_snapshot ao_repo ao_snapshot_202010272132 ao_index"
    -m 2G --name restore_opensearch_snapshot_ao
    ex3: cf run-task api --command "python cli.py restore_opensearch_snapshot arch_mur_repo
    arch_mur_snapshot_202010272132 arch_mur_index" -m 2G --name restore_opensearch_snapshot_arch_mur
    """
    opensearch_client = create_opensearch_client()

    repo_name = repo_name or constants.CASE_REPO
    configure_snapshot_repository(repo_name)

    index_name = index_name or constants.CASE_INDEX
    swapping_index = INDEX_DICT.get(index_name)[3]
    most_recent_snapshot_name = get_most_recent_snapshot(repo_name)
    snapshot_name = snapshot_name or most_recent_snapshot_name

    if opensearch_client.indices.exists(index_name):
        logger.info(
            " Found '{0}' index. Creating swapping index for zero-downtime restore".format(index_name)
        )
        # Create XXXX_SWAP_INDEX
        create_index(swapping_index)

        # Move the alias `XXXX_ALIAS` to point to `XXXX_SWAP_INDEX` instead of `XXXX_INDEX`
        switch_alias(index_name, INDEX_DICT.get(index_name)[1], swapping_index)

    delete_index(index_name)

    logger.info(" Retrieving snapshot: {0}".format(snapshot_name))
    body = {"indices": index_name}
    result = opensearch_client.snapshot.restore(
        repository=repo_name,
        snapshot=snapshot_name,
        body=body,
    )
    time.sleep(20)
    if result.get("accepted"):
        logger.info(" The snapshot: {0} is restored successfully.".format(snapshot_name))
        if opensearch_client.indices.exists(swapping_index):
            # 1. Switch aliases (XXXX_ALIAS,SEARCH_ALIAS) point back to XXXX_INDEX
            # 2. Delete XXXX_SWAP_INDEX
            switch_aliases_to_original_index(index_name)
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))
        logger.info(
            " You may want to try the most recent snapshot: {0}".format(
                most_recent_snapshot_name
            )
        )


def restore_opensearch_snapshot_downtime(repo_name=None, snapshot_name=None, index_name=None):
    """
    Restore opensearch from snapshot with downtime

    -Delete index
    -Restore from opensearch snapshot
    -Default to most recent snapshot, optionally specify `snapshot_name`

    How to call task command:
    ex1: cf run-task api --command "python cli.py restore_opensearch_snapshot_downtime
    case_repo case_snapshot_202010272130 case_index" -m 2G --name restore_opensearch_snapshot_downtime_case
    ex2: cf run-task api --command "python cli.py restore_opensearch_snapshot_downtime
    ao_repo ao_snapshot_202010272130 ao_index" -m 2G --name restore_opensearch_snapshot_downtime_ao
    ex3: cf run-task api --command "python cli.py restore_opensearch_snapshot_downtime
    arch_mur_repo arch_mur_snapshot_202010272130 arch_mur_index" -m 2G
    --name restore_opensearch_snapshot_downtime_arch_mur
    """
    opensearch_client = create_opensearch_client()

    repo_name = repo_name or constants.CASE_REPO
    configure_snapshot_repository(repo_name)

    index_name = index_name or constants.CASE_INDEX

    if not snapshot_name:
        most_recent_snapshot_name = get_most_recent_snapshot(repo_name)
        snapshot_name = most_recent_snapshot_name

    delete_index(index_name)

    logger.info(" Restoring snapshot: '{0}'...".format(snapshot_name))
    body = {"indices": index_name}
    result = opensearch_client.snapshot.restore(
        repository=repo_name,
        snapshot=snapshot_name,
        body=body,
    )
    time.sleep(20)
    if result.get("accepted"):
        logger.info(" Restored snapshot: '{0}' successfully.".format(snapshot_name))
    else:
        logger.error(" Unable to restore snapshot: {0}".format(snapshot_name))


def get_most_recent_snapshot(repo_name=None):
    """
    Get the list of snapshots (sorted by date, ascending) and
    return most recent snapshot name
    """
    opensearch_client = create_opensearch_client()

    repo_name = repo_name or constants.CASE_REPO
    logger.info(" Retreiving the most recent snapshot...")
    snapshot_list = opensearch_client.snapshot.get(repository=repo_name, snapshot="*").get(
        "snapshots"
    )
    return snapshot_list.pop().get("snapshot")


def display_snapshots(repo_name=None):
    """
    Currently it shows all the snapshots in all the repo.
    The argument 'repo_name' won't affect,

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshots case_repo" -m 2G
    --name display_snapshots_case
    ex2: cf run-task api --command "python cli.py display_snapshots ao_repo" -m 2G
    --name display_snapshots_ao
    ex3: cf run-task api --command "python cli.py display_snapshots arch_mur_repo" -m 2G
    --name display_snapshots_arch_mur
    """
    opensearch_client = create_opensearch_client()

    repo_name = repo_name or constants.CASE_REPO
    repo_list = [repo_name]
    configure_snapshot_repository(repo_name)
    result = opensearch_client.cat.snapshots(
        repository=repo_list,
        format="JSON",
        v=True,
        s="id",
        h="id,repository,status,start_time,end_time,duration,indices"
    )
    logger.info(" Snapshot list=" + json.dumps(result, indent=3, cls=DateTimeEncoder))


def display_snapshot_detail(repo_name=None, snapshot_name=None):
    """
    Returns all the snapshot detail (include uuid) in the repository.
    Currently it shows all the snapshots in all the repo.
    The argument 'repo_name' won't affect, snapshot_name can use '*' wild card.

    How to call task command:
    ex1: cf run-task api --command "python cli.py display_snapshot_detail case_repo case_snapshot_2023*"
    -m 2G --name display_snapshot_detail_case
    ex2: cf run-task api --command "python cli.py display_snapshot_detail ao_repo ao_snapshot_2023*"
    -m 2G --name display_snapshot_detail_ao
    ex3: cf run-task api --command "python cli.py display_snapshot_detail arch_mur_repo arch_mur*"
    -m 2G --name display_snapshot_detail_arch_mur
    """
    opensearch_client = create_opensearch_client()
    repo_name = repo_name or constants.CASE_REPO
    snapshot_name = snapshot_name or "*"
    configure_snapshot_repository(repo_name)
    result = opensearch_client.snapshot.get(
        repository=repo_name,
        snapshot=snapshot_name
    )
    logger.info(" Snapshot details =" + json.dumps(result, indent=3, cls=DateTimeEncoder))

    return result

# =========== end snapshot management =============


# =========== start es document management =============

def delete_doctype_from_es(index_name=None, doc_type=None):
    """
    Deletes all records with the given `doc_type` and `XXXX_INDEX` from OpenSearch
    Ex1-1: cf run-task api --command "python cli.py delete_doctype_from_es case_inde murs" -m 2G --name delete_murs
    Ex1-2: cf run-task api --command "python cli.py delete_doctype_from_es case_inde adrs" -m 2G --name delete_adrs
    Ex1-3: cf run-task api --command "python cli.py delete_doctype_from_es case_inde afs" -m 2G --name delete_afs
    Ex2: cf run-task api --command "python cli.py delete_doctype_from_es ao_index advisory_opinions" -m 2G
    --name delete_aos
    Ex3: cf run-task api --command "python cli.py delete_doctype_from_es arch_mur_index murs" -m 2G
    --name delete_arch_murs
    """
    body = {"query": {"match": {"type": doc_type}}}

    opensearch_client = create_opensearch_client()
    opensearch_client.delete_by_query(
        index=index_name,
        body=body,
    )
    logger.info(" Successfully deleted doc_type={} from index={} on OpenSearch.".format(
        doc_type, index_name))


def delete_single_doctype_from_es(index_name=None, doc_type=None, num_doc_id=None):
    """
    Deletes single record with the given `doc_type` , `doc_id` and `XXXX_INDEX` from OpenSearch

    Ex1: cf run-task api --command "python cli.py delete_single_doctype_from_es case_index
    murs mur_8003" -m 2G --name delete_one_mur
    Ex1-2: cf run-task api --command "python cli.py delete_single_doctype_from_es case_index
    adrs adr_1091" -m 2G --name delete_one_adr
    Ex1-3: cf run-task api --command "python cli.py delete_single_doctype_from_es case_index
    admin_fines af_4201" -m 2G --name delete_one_af
    Ex2:cf run-task api --command "python cli.py delete_single_doctype_from_es ao_index
    advisory_opinions advisory_opinions_2021-08" -m 2G --name delete_one_ao
    Ex3:cf run-task api --command "python cli.py delete_single_doctype_from_es arch_mur_index
    murs mur_99" -m 2G --name delete_one_arch_mur
    """
    body = {"query": {
        "bool": {
            "must": [
                {"match": {"type": doc_type}},
                {"match": {"doc_id": num_doc_id}}
            ]}}}

    opensearch_client = create_opensearch_client()
    opensearch_client.delete_by_query(
        index=index_name,
        body=body,
    )
    logger.info(" Successfully deleted doc_type={} and doc_id={} from index={} on OpenSearch.".format(
        doc_type, num_doc_id, index_name))


def delete_murs_from_s3():
    """
    Deletes all MUR documents from S3
    """
    bucket = get_bucket()
    for obj in bucket.objects.filter(Prefix="legal/murs"):
        obj.delete()
