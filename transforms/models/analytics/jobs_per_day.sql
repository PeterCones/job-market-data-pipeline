{{config(materialized = 'table')}}
SELECT
    j.posted_date,
    COUNT(j.job_id) AS job_count
FROM
    {{ ref('stg_jobs')}} j
GROUP BY
    j.posted_date
ORDER BY
    j.posted_date