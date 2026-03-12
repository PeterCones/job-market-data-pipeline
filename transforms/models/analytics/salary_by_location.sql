{{config(materialized = 'table')}}
SELECT
    j.location,
    AVG(salary_max) :: INT AS avg_salary
FROM
    {{ref('stg_jobs')}} j
GROUP BY
    j.location
ORDER BY
    avg_salary DESC