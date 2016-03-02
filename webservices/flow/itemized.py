from airflow import DAG
from airflow.operators import PostgresOperator

from webservices.flow import default_args, schedule_interval

def make_dag():

    dag = DAG(
        'refresh.itemized',
        default_args=default_args,
        schedule_interval=schedule_interval,
    )

    update_aggregates = PostgresOperator(  # noqa
        task_id='update_aggregates',
        sql='select update_aggregates()',
        dag=dag,
    )

    return dag
