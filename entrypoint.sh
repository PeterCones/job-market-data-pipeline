#!/bin/bash
set -e

echo "🚀 Starting Job Market Pipeline..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL..."
until pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME"; do
  echo "PostgreSQL not ready yet — retrying in 3s..."
  sleep 3
done
echo "✅ PostgreSQL is ready."

# Run database setup if schemas don't exist
echo "🗄️  Setting up database schemas..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;
EOF

# Create raw table if it doesn't exist
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS raw.reed_jobs (
    job_id INT PRIMARY KEY,
    source TEXT,
    job_data JSONB,
    ingested_at TIMESTAMP DEFAULT NOW()
);
EOF

# Run dbt seed (loads skills reference data)
echo "🌱 Seeding dbt reference data..."
cd /app/transforms
dbt seed --profiles-dir /root/.dbt

# Run pipeline once immediately on startup
echo "⚙️  Running initial pipeline..."
cd /app
bash run_pipeline.sh

# Start cron in foreground to keep container running
echo "⏰ Starting cron scheduler..."
cron && tail -f /var/log/pipeline.log