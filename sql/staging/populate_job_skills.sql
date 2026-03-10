INSERT INTO staging.job_skills (job_id, skill_id)
SELECT j.job_id, s.skill_id
FROM staging.jobs j 
CROSS JOIN staging.skills as s
WHERE lower(coalesce(j.title,'')  || ' ' || COALESCE(j.description,'')) like '%'|| s.skill_name ||'%' 
and length(s.skill_name) >=3 
ON CONFLICT (job_id, skill_id) DO NOTHING