-- RAW
CREATE TABLE raw.reed_jobs (
    job_id TEXT PRIMARY KEY,
    source TEXT,
    job_data JSONB,
    ingested_at TIMESTAMP DEFAULT NOW()
);

-- Alter job_id datatype to int
ALTER TABLE raw.reed_jobs
ALTER COLUMN job_id TYPE INT USING job_id::INT