INSERT INTO staging.jobs 
SELECT DISTINCT ON (job_data->>'jobId')
    job_data->>'jobId' AS job_id,
    job_data->>'jobTitle' AS title,
    job_data->>'employerName' AS company_name,
    job_data->>'locationName' AS location,
    (job_data->>'minimumSalary')::float AS salary_min,
    (job_data->>'maximumSalary')::float AS maximum_salary,
    job_data->>'jobDescription' AS description,
    (job_data->>'date')::DATE AS posted_date,
    (job_data->>'expirationDate')::DATE AS expiration_date,
    job_data->>'jobUrl' AS job_url
FROM raw.reed_jobs
ORDER BY job_data->>'jobId', ingested_at DESC;


