
-- RAW
CREATE TABLE raw.reed_jobs (
    job_id TEXT PRIMARY KEY,
    source TEXT,
    job_data JSONB,
    ingested_at TIMESTAMP DEFAULT NOW()
);

-- Staging
CREATE TABLE staging.jobs (
    job_id TEXT PRIMARY KEY,
    title TEXT,
    company_name TEXT,
    location TEXT,
    salary_min INT,
    salary_max INT,
    description TEXT,
    posted_date DATE,
    expiration_date DATE,
    job_url TEXT
);

CREATE TABLE staging.skills (
    skill_id SERIAL PRIMARY KEY,
    Skill_name TEXT UNIQUE
)

CREATE TABLE staging.job_skills (
    job_id TEXT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id)
);

ALTER TABLE staging.job_skills
ADD CONSTRAINT job_skills_unique
UNIQUE (job_id, skill_id);


