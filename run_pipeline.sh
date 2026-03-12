#!/bin/bash
set -e
 
echo "Starting pipeline..."
 
# Run ingestion
python /app/ingestion/reed_ingest.py
 
# Run dbt transforms and tests
cd /app/transforms
dbt run && dbt test
 
echo "Pipeline complete."