import pytest
from webservices.utils import create_es_client


@pytest.fixture(scope="module")
def es_client():
    # Setup Elasticsearch client
    client = create_es_client()
    yield client


@pytest.fixture(scope="module", autouse=True)
def setup_index(es_client):
    # Setup the index for tests
    index_name = "test_index"

    # Create index
    es_client.indices.create(index=index_name)

    yield index_name

    # Teardown the index after tests
    es_client.indices.delete(index=index_name)


def test_index_document(es_client, setup_index):
    index_name = setup_index
    document = {"title": "Test Document", "content": "This is a test."}

    response = es_client.index(index_name, document)

    assert response['result'] == 'created'
    assert response['_index'] == index_name
