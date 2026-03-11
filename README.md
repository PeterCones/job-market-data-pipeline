# 📊 Job Market Data Pipeline

An end-to-end data pipeline that ingests live job listings from the [Reed API](https://www.reed.co.uk/developers/jobseeker), transforms them across a layered PostgreSQL schema, and surfaces analytics on skill demand, salary benchmarking, and posting trends — refreshed automatically on a cron schedule.

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
│                     STAGING LAYER                               │
│                                                                 │
│   raw.reed_jobs  ──►  staging.jobs                              │
│                  ──►  staging.skills  (normalised)              │
│                  ──►  staging.job_skills  (junction table)      │
│                                                                 │
│   • Extracts & types fields from raw JSON                       │
│   • Deduplicates keeping latest ingested record                 │
│   • Normalises skills into relational model                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     ANALYTICS LAYER                             │
│                                                                 │
│   staging.*  ──►  analytics.skill_demand                        │
│             ──►  analytics.salary_by_location                   │
│             ──►  analytics.jobs_per_day                         │
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
| Transformation | SQL (raw → staging → analytics) |
| Orchestration | Bash + cron |
| Config | `.env` via `python-dotenv` |

---

## Project Structure

```
job-market-data-pipeline/
│
├── ingestion/
│   └── reed_ingest.py              # API ingestion script
│
├── sql/
│   ├── setup.sql                   # Creates raw, staging, and analytics schemas
│   │
│   ├── raw/
│   │   └── schema_raw.sql
│   │
│   ├── staging/
│   │   ├── schema_staging.sql
│   │   ├── transform_from_raw.sql
│   │   ├── populate_job_skills.sql
│   │   └── skills_data/
│   │       ├── insert_skills.sql
│   │       └── skills.csv
│   │
│   ├── analytics/
│   │   ├── schema_analytics.sql
│   │   ├── populate_skills_demand.sql
│   │   ├── populate_salary_by_location.sql
│   │   └── populate_jobs_per_day.sql
│   │
│   └── lookup_scripts/             # Ad-hoc query scripts for inspection/maintenance
│       ├── raw.sql
│       ├── staging.sql
│       ├── analytics.sql
│       └── clean_db.sql
│
├── run_pipeline.sh                 # Orchestration script (cron scheduled)
├── requirements.txt
├── .env.example                    # Environment variable template
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
# Create schemas, tables, and seed reference data
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/setup.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/raw/schema_raw.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/staging/schema_staging.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/analytics/schema_analytics.sql
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f sql/staging/skills_data/insert_skills.sql
```

### Running the Pipeline

```bash
# Run manually
bash run_pipeline.sh

# Or schedule with cron (example: run daily at 6am)
0 6 * * * /bin/bash /path/to/run_pipeline.sh >> /var/log/job-pipeline.log 2>&1
```

---

## Analytics Outputs

| Table | Description |
|---|---|
| `analytics.skill_demand` | Ranked count of skills mentioned across all job listings |
| `analytics.salary_by_location` | Average advertised salary by location |
| `analytics.jobs_per_day` | Volume of job postings by date |

---

## Keywords Tracked

```
data engineer · data analyst · junior software · python ·
software apprentice · sql · analytics engineer
```

---

## Future Improvements

- [ ] Add dbt for transformation layer with full lineage tracking
- [ ] Replace TRUNCATE/INSERT pattern with transactional swaps
- [ ] Add retry logic with exponential backoff to ingestion
- [ ] Extend to additional job boards (LinkedIn, Indeed)
- [ ] Build a dashboard layer (Metabase / Grafana)
- [ ] Containerise with Docker Compose for portability

---

## Author

**Oliver Lacey** — [LinkedIn](https://linkedin.com) · [GitHub](https://github.com/PeterCones)