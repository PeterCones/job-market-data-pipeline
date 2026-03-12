{{config(materialized = 'table')}}
SELECT
    DISTINCT j.job_id,
    s.skill_id
FROM
    {{ref('stg_jobs')}} j
    CROSS JOIN {{ref('skills')}} s
WHERE
    lower(
        coalesce(j.title, '') || ' ' || coalesce(j.description, '')
    ) like '%' || s.skill_name || '%'
    and length(s.skill_name) >= 3