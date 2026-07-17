-- =============================================================
-- ARC Lesion Segmentation — PostgreSQL schema
-- =============================================================
-- Run as a superuser / owner of the target database, e.g.:
--   psql -U postgres -d arc_lesion -f db/schema.sql
-- =============================================================

-- ---------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS processing_runs (
    id               SERIAL PRIMARY KEY,
    algorithm_version VARCHAR(50)  NOT NULL,
    started_at       TIMESTAMP    NOT NULL DEFAULT now(),
    finished_at      TIMESTAMP,
    status           VARCHAR(20)  NOT NULL DEFAULT 'completed'
        CHECK (status IN ('running', 'completed', 'failed'))
);

CREATE TABLE IF NOT EXISTS participants (
    id             SERIAL PRIMARY KEY,
    subject_code   VARCHAR(20)  NOT NULL UNIQUE,
    dice_score     NUMERIC(6, 4),
    lesion_volume_gt   INTEGER,
    lesion_volume_auto INTEGER,
    run_id         INTEGER REFERENCES processing_runs(id),
    processed_at   TIMESTAMP    NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_participants_dice_score
    ON participants (dice_score);

CREATE INDEX IF NOT EXISTS idx_participants_run_id
    ON participants (run_id);

-- ---------------------------------------------------------------
-- Roles & privileges
-- ---------------------------------------------------------------
-- qa_readonly: used by the API service and by external QA engineers.
-- Read-only on purpose — no INSERT / UPDATE / DELETE rights,
-- so the API can never mutate the dataset it exposes.
-- ---------------------------------------------------------------

DO
$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'qa_readonly') THEN
        CREATE ROLE qa_readonly LOGIN PASSWORD 'change_me_in_prod';
    END IF;
END
$$;

GRANT CONNECT ON DATABASE arc_lesion TO qa_readonly;
GRANT USAGE ON SCHEMA public TO qa_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO qa_readonly;

-- Make sure future tables are covered automatically as well.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO qa_readonly;
