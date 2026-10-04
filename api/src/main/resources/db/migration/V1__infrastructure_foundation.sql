-- Flyway owns schema creation. JobRunr owns/version-controls its tables in jobs.
CREATE SCHEMA jobs;
COMMENT ON SCHEMA jobs IS 'JobRunr-managed durable job tables; no learner data';
