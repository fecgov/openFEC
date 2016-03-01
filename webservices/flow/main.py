from airflow import DAG
from airflow.operators import SubDagOperator

from webservices.flow import default_args, script_path

from webservices.flow import itemized, views, bucket

dag = DAG(
    'refresh',
    default_args=default_args,
    template_searchpath=script_path,
    schedule_interval='0 9 * * *',
)

itemized = SubDagOperator(
    task_id='itemized',
    subdag=itemized.make_dag(),
    dag=dag,
)

views = SubDagOperator(
    task_id='views',
    subdag=views.make_dag(),
    dag=dag,
)
views.set_upstream(itemized)

bucket = SubDagOperator(
    task_id='bucket',
    subdag=bucket.make_dag(),
    dag=dag,
)
bucket.set_upstream(views)
