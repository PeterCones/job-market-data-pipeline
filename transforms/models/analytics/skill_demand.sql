-- analytics/skill_demand.sql
{{config(materialized = 'table')}}
SELECT
    s.skill_name,
    COUNT(*) AS job_count
FROM
    {{ref('stg_job_skills')}} js
    JOIN {{ref('skills')}} s ON s.skill_id = js.skill_id
    JOIN {{ref('stg_jobs')}} j ON j.job_id = js.job_id
GROUP BY
    s.skill_name
ORDER BY
    job_count DESC