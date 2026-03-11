#!/bin/bash

set -a
source /DevDrive/git/job-market-data-pipeline/.env
set +a

echo "Starting pipeline..."

# activate venv
source /DevDrive/git/job-market-data-pipeline/.venv/bin/activate

# run ingestion
python /DevDrive/git/job-market-data-pipeline/ingestion/reed_ingest.py

# run dbt transforms

cd /DevDrive/git/job-market-data-pipeline/transforms
dbt run && dbt test >> /DevDrive/git/job-market-data-pipeline/transforms/logs/dbt_run.log 2>&1

echo "Pipeline complete."