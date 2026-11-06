-- Member dimension for the cryptocurrency analysis project.
-- Run from the repository root:
-- psql -d your_database_name -f sql/01_members_schema.sql

CREATE TABLE IF NOT EXISTS members (
    member_id VARCHAR(20) PRIMARY KEY,
    first_name TEXT NOT NULL,
    region TEXT
);

-- psql client-side import. The members.csv file is in the repository root.
\copy members (member_id, first_name, region) FROM 'members.csv' WITH (FORMAT csv, HEADER true);
