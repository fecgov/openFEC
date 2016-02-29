from airflow import DAG
from airflow.operators import SubDagOperator

from webservices.flow import default_args, script_path

from webservices.flow.itemized import itemized_dag
from webservices.flow.views import views_dag
from webservices.flow.bucket import bucket_dag

dag = DAG(
    'refresh',
    default_args=default_args,
    template_searchpath=script_path,
    schedule_interval='0 9 * * *',
)

itemized = SubDagOperator(
    task_id='itemized',
    subdag=itemized_dag,
    dag=dag,
)

views = SubDagOperator(
    task_id='views',
    subdag=views_dag,
    dag=dag,
)
views.set_upstream(itemized)

bucket = SubDagOperator(
    task_id='bucket',
    subdag=bucket_dag,
    dag=dag,
)
bucket.set_upstream(views)
