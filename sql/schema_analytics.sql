-- Analytics
CREATE TABLE analytics.jobs_per_day (
    date DATE PRIMARY KEY,
    jobs_posted INT
);

CREATE TABLE analytics.skill_demand (
    skill_name TEXT,
    job_count INT
);

CREATE TABLE analytics.salary_by_location (
    location TEXT,
    avg_salary INT
);