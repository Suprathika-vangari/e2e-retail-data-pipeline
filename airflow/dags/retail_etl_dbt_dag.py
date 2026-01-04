from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    'owner': 'retail_de',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id='retail_etl_dbt_dag',
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    schedule_interval='0 2 * * *',
    catchup=False,
) as dag:

    dbt_seed = BashOperator(
        task_id='dbt_seed',
        bash_command='cd /opt/airflow/dbt_project && dbt seed --profiles-dir /opt/airflow/.dbt',
    )

    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/dbt_project && dbt run --profiles-dir /opt/airflow/.dbt',
    )

    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command='cd /opt/airflow/dbt_project && dbt test --profiles-dir /opt/airflow/.dbt',
    )

    dbt_seed >> dbt_run >> dbt_test
