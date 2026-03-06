TRUNCATE analytics.skill_demand;
INSERT INTO analytics.skill_demand (skill_name,job_count) 
SELECT s.skill_name,count(s.skill_name) as skill_count FROM staging.job_skills js
join staging.skills as s on s.skill_id = js.skill_id
join staging.jobs as j on j.job_id = js.job_id
GROUP BY s.skill_name
order by skill_count desc;