From 2bda39daf4536efb0e2885431c0d80dacd159bd5 Mon Sep 17 00:00:00 2001
From: Repo Update <you@example.com>
Date: Sat, 18 Jul 2026 00:18:58 +0000
Subject: [PATCH] Add product backlog: 5 PBIs with Given/When/Then acceptance
 criteria

Derived from the Feature in docs/requirements/interview-feature.md.
Covers single-participant lookup, aggregate stats, pagination,
read-only access control, and backup/restore recovery. Acceptance
criteria reflect what was actually verified against the implemented
api/ and db/ (e.g. avg_dice matches the CSV-derived 0.1704).

Also captures a future (unscheduled) PBI for write access, matching
the 'Future considerations' section of the Feature.
---
 docs/requirements/backlog.md | 114 +++++++++++++++++++++++++++++++++++
 1 file changed, 114 insertions(+)
 create mode 100644 docs/requirements/backlog.md

diff --git a/docs/requirements/backlog.md b/docs/requirements/backlog.md
new file mode 100644
index 0000000..65bae17
--- /dev/null
+++ b/docs/requirements/backlog.md
@@ -0,0 +1,114 @@
+# Product Backlog: HTTP API access to segmentation results
+
+Derived from the Feature described in `docs/requirements/interview-feature.md`.
+Each item below is implemented and verified (see `api/`, `db/`, `tests/`) —
+acceptance criteria are written as the definition of "done" that was actually
+checked, not aspirational.
+
+---
+
+### PBI-1: View a single participant's segmentation metrics
+
+**As an** ML engineer,
+**I want to** retrieve the Dice Score and lesion volumes for a specific
+participant by their subject code,
+**so that** I can quickly inspect or debug a single result without opening
+Octave or the raw CSV file.
+
+**Acceptance criteria:**
+- **Given** a participant with a known `subject_code` exists in the database,
+  **when** I send `GET /results/{subject_code}`,
+  **then** the response is `200 OK` and includes `dice_score`,
+  `lesion_volume_gt`, and `lesion_volume_auto`.
+- **Given** a `subject_code` that does not exist,
+  **when** I send `GET /results/{subject_code}`,
+  **then** the response is `404 Not Found` with an error message naming the
+  missing subject.
+- **Given** the endpoint is documented,
+  **when** I open `/docs`,
+  **then** `GET /results/{subject_code}` appears with its response schema.
+
+---
+
+### PBI-2: View aggregate statistics across the cohort
+
+**As an** ML engineer,
+**I want to** retrieve mean/min/max Dice Score and the total participant
+count for the whole processed cohort,
+**so that** I can monitor overall pipeline quality without recomputing
+statistics manually.
+
+**Acceptance criteria:**
+- **Given** the database contains processed participants,
+  **when** I send `GET /stats`,
+  **then** the response is `200 OK` and includes `participants_count`,
+  `avg_dice`, `min_dice`, and `max_dice`.
+- **Given** the values in `results/batch_results.csv`,
+  **when** I compare them to the `/stats` response after seeding,
+  **then** `avg_dice` matches the CSV-derived average (0.1704) within
+  rounding.
+
+---
+
+### PBI-3: Browse the full list of processed participants
+
+**As an** ML engineer,
+**I want to** list processed participants with pagination,
+**so that** I can page through results without loading the entire dataset
+at once.
+
+**Acceptance criteria:**
+- **Given** more participants exist than the requested `limit`,
+  **when** I send `GET /results?limit=5`,
+  **then** the response contains at most 5 items.
+- **Given** an invalid `limit` (0, negative, non-numeric, or above the
+  maximum of 500),
+  **when** I send the request,
+  **then** the response is `422 Unprocessable Entity`.
+
+---
+
+### PBI-4: Restrict API access to read-only
+
+**As a** QA engineer responsible for data integrity,
+**I want** the API to connect to the database with a role that only has
+`SELECT` privileges,
+**so that** a bug in the API can never accidentally modify or delete
+segmentation results while the algorithm is still being validated.
+
+**Acceptance criteria:**
+- **Given** the `qa_readonly` role defined in `db/schema.sql`,
+  **when** I inspect its grants,
+  **then** it has `SELECT` only — no `INSERT`, `UPDATE`, or `DELETE` on any
+  table.
+- **Given** the API is configured to connect as `qa_readonly`,
+  **when** any write operation is attempted against the database through
+  that connection,
+  **then** PostgreSQL rejects it with a permissions error.
+
+---
+
+### PBI-5: Recover the dataset from a backup
+
+**As a** QA/DevOps engineer,
+**I want** documented `backup.sh` / `restore.sh` scripts,
+**so that** the segmentation results dataset can be recovered after
+accidental data loss or a failed migration.
+
+**Acceptance criteria:**
+- **Given** a populated database,
+  **when** I run `db/backup.sh`,
+  **then** a timestamped `.dump` file is created under `db/backups/`.
+- **Given** a backup file and an empty or corrupted database,
+  **when** I run `db/restore.sh <file>`,
+  **then** the database is restored and `SELECT COUNT(*) FROM participants`
+  returns the original row count.
+
+---
+
+## Future backlog (not yet scheduled)
+
+- **PBI-6 (future):** Write-capable endpoint for flagging a participant's
+  result as "needs re-review" — requires a second, write-capable database
+  role and an audit trail (see "Future considerations" in
+  `docs/requirements/interview-feature.md`).
-- 
2.43.0