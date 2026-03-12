# 📊 Job Market Data Pipeline

An end-to-end data pipeline that ingests live job listings from the [Reed API](https://www.reed.co.uk/developers/jobseeker), transforms them through a layered PostgreSQL schema using dbt, and surfaces analytics on skill demand, salary benchmarking, and posting trends — refreshed automatically on a cron schedule.

> This project was initially built with raw SQL scripts and subsequently refactored using dbt to introduce automated testing, data lineage tracking, and a scalable transformation layer.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATION                            │
│              run_pipeline.sh  (cron scheduled)                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     INGESTION LAYER                             │
│                                                                 │
│   Reed Jobs API  ──►  reed_ingest.py  ──►  raw.reed_jobs        │
│                                                                 │
│   • Paginates across 7 job keyword searches                     │
│   • Stores full JSON response per job                           │
│   • Deduplicates on job_id (ON CONFLICT DO NOTHING)             │
│   • Rate-limited with 0.3s sleep between requests               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     TRANSFORMATION LAYER  (dbt)                 │
│                                                                 │
│   raw.reed_jobs  ──►  stg_jobs          (cleaned, typed)        │
│                  ──►  stg_job_skills    (skill matching)        │
│                  ──►  skills            (seed reference data)   │
│                                                                 │
│   • Extracts & casts fields from raw JSON                       │
│   • Deduplicates keeping latest ingested record                 │
│   • Matches skills to jobs via CROSS JOIN pattern               │
│   • Full lineage tracked via dbt ref() dependencies            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ANALYTICS LAYER  (dbt)                      │
│                                                                 │
│   staging.*  ──►  analytics.skill_demand                        │
│              ──►  analytics.salary_by_location                  │
│              ──►  analytics.jobs_per_day                        │
│                                                                 │
│   • Aggregated, query-ready mart tables                         │
│   • Rebuilt on each pipeline run                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ingestion | Python, `requests`, `psycopg2` |
| Database | PostgreSQL |
| Transformation | dbt (staging + analytics models, seed data) |
| Testing | dbt tests (`not_null`, `unique`, `accepted_values`) |
| Orchestration | Bash + cron |
| Config | `.env` via `python-dotenv` |

---

## Project Structure

```
job-market-data-pipeline/
│
├── ingestion/
│   └── reed_ingest.py              # Reed API ingestion script
│
├── transforms/                     # dbt project
│   ├── models/
│   │   ├── staging/
│   │   │   ├── stg_jobs.sql        # Cleans & casts raw JSON fields
│   │   │   └── stg_job_skills.sql  # Matches skills to jobs
│   │   └── analytics/
│   │       ├── skill_demand.sql
│   │       ├── salary_by_location.sql
│   │       └── jobs_per_day.sql
│   ├── seeds/
│   │   └── skills.csv              # Reference list of 60 tracked skills
│   ├── tests/                      # Custom dbt tests
│   └── dbt_project.yml
│
├── legacy_sql/                     # Original SQL scripts (pre-dbt refactor)
│   ├── transform_from_raw.sql
│   ├── populate_job_skills.sql
│   ├── populate_skills_demand.sql
│   ├── populate_salary_by_location.sql
│   ├── populate_jobs_per_day.sql
│   └── insert_skills.sql
│
├── sql/
│   ├── setup.sql                   # Creates raw, staging, analytics schemas
│   ├── raw/schema_raw.sql
│   ├── staging/schema_staging.sql
│   ├── analytics/schema_analytics.sql
│   └── lookup_scripts/             # Ad-hoc inspection & maintenance queries
│
├── run_pipeline.sh                 # Orchestration script (cron scheduled)
├── requirements.txt
├── .env.example
└── README.md
```

---

## Setup

### Prerequisites

- Python 3.10+
- PostgreSQL
- A [Reed API key](https://www.reed.co.uk/developers/jobseeker)

### Installation

```bash
# Clone the repo
git clone https://github.com/PeterCones/job-market-data-pipeline.git
cd job-market-data-pipeline

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env with your Reed API key and DB credentials
```

### Database Setup

```bash
# Create schemas and tables
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/setup.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/raw/schema_raw.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/staging/schema_staging.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/analytics/schema_analytics.sql
```

### dbt Setup

```bash
cd transforms

# Seed reference data (skills list)
dbt seed

# Run all models
dbt run

# Run tests
dbt test

# View documentation
dbt docs generate && dbt docs serve
```

### Running the Full Pipeline

```bash
# Run manually
bash run_pipeline.sh

# Or schedule with cron (example: run daily at 6am)
0 6 * * * /bin/bash /path/to/run_pipeline.sh
```

---

## dbt Models

### Staging

| Model | Description |
|---|---|
| `stg_jobs` | Extracts and casts fields from raw JSON in `raw.reed_jobs`. Deduplicates on `job_id`, keeping the most recently ingested record. |
| `stg_job_skills` | Matches jobs to skills via a `CROSS JOIN` against the skills seed, filtering on keyword presence in title and description. |

### Analytics

| Model | Description |
|---|---|
| `skill_demand` | Ranked count of skills mentioned across all job listings |
| `salary_by_location` | Average advertised salary grouped by location |
| `jobs_per_day` | Volume of job postings by date |

### Seeds

| Seed | Description |
|---|---|
| `skills` | Reference list of 60 tracked skills including languages, tools, platforms, and concepts |

---

## Keywords Tracked

```
data engineer · data analyst · junior software · python ·
software apprentice · sql · analytics engineer
```

---

## Skills Tracked (sample)

```
python · sql · dbt · airflow · spark · kafka · docker · kubernetes ·
aws · azure · gcp · snowflake · databricks · bigquery · tableau ·
power bi · tensorflow · pytorch · pandas · scikit-learn · ...
```

60 skills tracked in total — see [`transforms/seeds/skills.csv`](transforms/seeds/skills.csv) for the full list.

---

## Legacy SQL

The `legacy_sql/` directory contains the original SQL scripts written before the dbt refactor. These are retained for reference to illustrate the evolution of the project from manual SQL orchestration to a fully managed dbt transformation layer.

---

## Future Improvements

- [ ] Add retry logic with exponential backoff to ingestion
- [ ] Containerise with Docker Compose for portability
- [ ] Extend to additional job boards (LinkedIn, Indeed)
- [ ] Build a dashboard layer (Metabase / Grafana)
- [ ] Add dbt sources with freshness checks on `raw.reed_jobs`

---

## Author

**Oliver Lacey** - [LinkedIn](https://www.linkedin.com/in/oliver-l-6175951aa) · [GitHub](https://github.com/PeterCones)
