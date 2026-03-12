{{config(materialized = 'table')}}
SELECT
    DISTINCT ON (job_data ->> 'jobId') job_data ->> 'jobId' AS job_id,
    job_data ->> 'jobTitle' AS title,
    job_data ->> 'employerName' AS company_name,
    job_data ->> 'locationName' AS location,
    NULLIF(job_data ->> 'minimumSalary', '') :: float AS salary_min,
    NULLIF(job_data ->> 'maximumSalary', '') :: float AS salary_max,
    job_data ->> 'jobDescription' AS description,
    to_date(job_data ->> 'date', 'DD/MM/YYYY') AS posted_date,
    job_data ->> 'jobUrl' AS job_url,
    source
FROM
    raw.reed_jobs
ORDER BY
    job_data ->> 'jobId',
    ingested_at DESC