#!/bin/bash

set -a
source /DevDrive/git/job-market-data-pipeline/.env
set +a

echo "Starting pipeline..."

# activate venv
source /DevDrive/git/job-market-data-pipeline/.venv/bin/activate

# run ingestion
python /DevDrive/git/job-market-data-pipeline/ingestion/reed_ingest.py

# run SQL transforms

psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f /DevDrive/git/job-market-data-pipeline/sql/staging/transform_from_raw.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f /DevDrive/git/job-market-data-pipeline/sql/staging/populate_job_skills.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f /DevDrive/git/job-market-data-pipeline/sql/analytics/populate_skills_demand.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f /DevDrive/git/job-market-data-pipeline/sql/analytics/populate_jobs_per_day.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f /DevDrive/git/job-market-data-pipeline/sql/analytics/populate_salary_by_location.sql

echo "Pipeline complete."