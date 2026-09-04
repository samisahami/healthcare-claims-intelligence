from datetime import datetime

from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG(
    dag_id="healthcare_analytics",
    description="Orchestrates the healthcare claims analytics pipeline",
    start_date=datetime(2026, 1, 1),
    schedule=None,
    catchup=False,
    tags=["healthcare", "claims", "dbt"],
) as dag:

    generate_synthea = BashOperator(
        task_id="generate_synthea",
        bash_command="cd /Users/samisahami/healthcare-claims-intelligence && docker compose run --rm synthea",
    )   

    ingest_raw_data = BashOperator(
        task_id="ingest_raw_data",
        bash_command="cd /Users/samisahami/healthcare-claims-intelligence && docker compose run --rm ingestion",
    )

    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command="cd /Users/samisahami/healthcare-claims-intelligence && docker compose run --rm dbt build",
    )

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command="cd /Users/samisahami/healthcare-claims-intelligence && docker compose run --rm dbt snapshot",
    )

    generate_synthea >> ingest_raw_data >> dbt_build >> dbt_snapshot