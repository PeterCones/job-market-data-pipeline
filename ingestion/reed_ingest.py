import psycopg2 as pg2
import requests
import json
import time
import math
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

api_key = os.getenv("REED_API_KEY")
db_name = os.getenv("DB_NAME")
user = os.getenv("DB_USER")
pswd = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")

url = "https://www.reed.co.uk/api/1.0/search"

# Establish connection to db
try:
    conn = pg2.connect(
        database=db_name,
        user=user,
        password=pswd,
        host=host
    )
    cur = conn.cursor()
    print("Database connected successfully")
except Exception as e:
    print(f"Database connection failed: {e}")
    exit()

# keyword list to iterate over
keywords = [
    "data engineer",
    "data analyst",
    "machine learning",
    "python",
    "sql",
    "analytics engineer",
]

results_per_page = 100

for keyword in keywords:
    print(f"\n--- Searching for: {keyword} ---")

    # Initial discovery request
    params = {
        "keywords": keyword,
        "datePosted": "LastTwoWeeks",
        "resultsToTake": results_per_page,
        "page": 1,
    }

    response = requests.get(url, params=params, auth=(api_key, ""))

    if response.status_code != 200:
        print(f"API Error: {response.status_code} for keyword '{keyword}', skipping")
        continue

    data = response.json()

    total_results = data["totalResults"]
    total_pages = math.ceil(total_results / results_per_page)

    print(f"Total results: {total_results}")
    print(f"Total pages: {total_pages}")

    # loop over total pages & ingest to db
    for page in range(1, total_pages + 1):

        params = {
            "keywords": keyword,
            "datePosted": "LastTwoWeeks",
            "resultsToTake": results_per_page,
            "page": page,
        }

        response = requests.get(url, params=params, auth=(api_key, ""))

        if response.status_code != 200:
            print(f"API Error: {response.status_code}")
            break

        data = response.json()
        jobs = data.get("results", [])

        print(f"Ingesting page {page} with {len(jobs)} jobs")

        for job in jobs:

            job_id = job["jobId"]

            cur.execute(
                """
                INSERT INTO raw.reed_jobs (job_id, source, job_data)
                VALUES (%s, %s, %s)
                ON CONFLICT (job_id) DO NOTHING
                """,
                (job_id, "reed", json.dumps(job)),
            )
        conn.commit()
        time.sleep(0.3)

cur.close()
conn.close()