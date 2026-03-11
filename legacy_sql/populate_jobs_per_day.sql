TRUNCATE analytics.jobs_per_day;
INSERT INTO analytics.jobs_per_day (date, jobs_posted)
select 
posted_date, 
count(job_id) 
from staging.jobs
group by posted_date
order by posted_date