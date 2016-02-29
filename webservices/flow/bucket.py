from airflow import DAG
from airflow.operators import PythonOperator

from webservices.flow import default_args
from webservices.tasks import download

bucket_dag = DAG(
    'refresh.bucket',
    default_args=default_args,
    schedule_interval='0 9 * * *',
)

clear_bucket = PythonOperator(
    task_id='clear_bucket',
    python_callable=download.clear_bucket,
    dag=bucket_dag,
)
