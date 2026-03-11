TRUNCATE analytics.salary_by_location;
INSERT INTO analytics.salary_by_location (location, avg_salary)
SELECT location, AVG(salary_max)::INT AS avg_salary
FROM staging.jobs
GROUP BY location
ORDER BY avg_salary DESC