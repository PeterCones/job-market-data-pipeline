-- Insert skills into staging.skills
COPY staging.skills(skill_id, skill_name)
FROM '/DevDrive/git/job-market-data-pipeline/sql/staging/skills_data/skills.csv'
DELIMITER ','
CSV HEADER;