-- Extensions ODK Central needs. See "Setting up the database manually" in
-- getodk/central-backend/README.md.
-- Runs once on first init of the postgres:14 data volume.
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgrowlocks;
