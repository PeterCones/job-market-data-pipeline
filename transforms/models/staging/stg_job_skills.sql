{{ config(materialized='table') }}

SELECT
    job_id,
    skill_id
FROM staging.job_skills