-- SELECT job_id,title,description from staging.jobs
-- WHERE lower(COALESCE(title,'') || ' ' || COALESCE(description,'')) 
-- LIKE '%' || (SELECT skill_name FROM staging.skills where skill_id = 1) ||'%';

-- SELECT j.job_id, s.skill_id
-- FROM staging.jobs j 
-- CROSS JOIN staging.skills as s
-- WHERE lower(coalesce(j.title,'')  || ' ' || COALESCE(j.description,'')) like '%'|| s.skill_name ||'%' 
-- and length(s.skill_name) >=3 


-- SELECT s.skill_name, COUNT(*) AS match_count
-- FROM staging.job_skills js
-- JOIN staging.skills s
--   ON js.skill_id = s.skill_id
-- GROUP BY s.skill_name
-- ORDER BY match_count DESC;



select * from staging.jobs