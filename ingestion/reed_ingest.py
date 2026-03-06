import psycopg2 as pg2
import requests
import json
from dotenv import load_dotenv
import os

# Environment vars
load_dotenv()
api_key = os.getenv("REED_API_KEY")
db_name = os.getenv("DB_NAME")
user = os.getenv("DB_USER")
pswd = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
url = "https://www.reed.co.uk/api/1.0/search?postedBy=14&location=cheshire&distancefromlocation=25&maximumSalary=45000"


# api call with error catching
try:
    response = requests.get(url, auth=(api_key,''), timeout=10)
    response.raise_for_status()
    payload = response.json()
    jobs = payload.get('results',[])
    print("Data retrieval successful")
    print(f"{len(jobs)} jobs retrieved from API")
except requests.exceptions.RequestException as e:
    print(f"A network exception has occurred:  {e}")
except ValueError:
    print("Invalid JSON data.")
    
# Establish connection to db

try:
    conn = pg2.connect(
        database= db_name,
        user = user,
        password = pswd,
        host = host,
    )
    print("Database connected successfully")
except Exception as e:
    print(f"Database connection failed: {e}")
    exit()

# Insert data into SQL
cur = conn.cursor()
if jobs:
    for job in jobs:
        cur.execute(
            """
            INSERT INTO raw.reed_jobs (job_id,source,job_data)
            VALUES(%s,%s, %s)
            ON CONFLICT (job_id) DO NOTHING
            """, (job.get('jobId'),'reed',json.dumps(job),)
        )
    conn.commit()
    cur.close()
    print("Jobs inserted successfully.")
else:
    print("No jobs found in the payload.")

conn.close()