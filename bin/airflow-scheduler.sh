export AIRFLOW_HOME=$HOME
export PYTHONPATH=$HOME:$PYTHONPATH
airflow resetdb --yes
airflow scheduler
