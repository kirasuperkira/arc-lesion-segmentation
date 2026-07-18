From ea8a2ef622274056633b91f78f61854372da459d Mon Sep 17 00:00:00 2001
From: Repo Update <you@example.com>
Date: Sat, 18 Jul 2026 00:13:16 +0000
Subject: [PATCH] Add requirements interview notes and Feature description

Feature: Add HTTP API access to automatic segmentation results.
Captures interview with the research lead on target users (ML
engineers/researchers), core use cases (per-participant lookup +
aggregate stats), and access rights (read-only for this iteration,
write access captured as a future consideration).
---
 docs/requirements/.gitkeep             |  0
 docs/requirements/interview-feature.md | 71 ++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)
 delete mode 100644 docs/requirements/.gitkeep
 create mode 100644 docs/requirements/interview-feature.md

diff --git a/docs/requirements/.gitkeep b/docs/requirements/.gitkeep
deleted file mode 100644
index e69de29..0000000
diff --git a/docs/requirements/interview-feature.md b/docs/requirements/interview-feature.md
new file mode 100644
index 0000000..3fc0f1c
--- /dev/null
+++ b/docs/requirements/interview-feature.md
@@ -0,0 +1,71 @@
+# Requirements interview: HTTP API for segmentation results
+
+**Date:** 2026-07-18
+**Interviewer (QA/BA role):** Claude
+**Interviewee (Research Lead role):** project owner
+
+## Interview notes
+
+**Q: Who are the primary users of the API exposing segmentation results?**
+A: ML engineers / researchers. They need programmatic access to per-participant
+metrics and aggregate statistics without having to open Octave or parse the raw
+CSV manually — e.g. to feed results into their own analysis notebooks or to
+monitor a batch run while it's in progress.
+
+**Q: What is the main problem the API needs to solve?**
+A: Both are equally important:
+- quick lookup of a single participant's result (debugging a specific subject,
+  checking why a Dice Score looks off)
+- aggregate statistics across the whole cohort (tracking overall pipeline
+  quality, comparing algorithm versions over time)
+
+**Q: How critical are access rights (read-only vs. read-write)?**
+A: Write access will be needed eventually — for example, to let a reviewer flag
+a participant's automatic mask as "needs re-review", or to trigger a new batch
+run remotely. For the current iteration, however, the API is read-only by
+design (see `qa_readonly` role in `db/schema.sql`): the dataset must not be
+mutated by accident while the team is still validating the segmentation
+algorithm itself. Write capability is captured below as a future extension,
+not a blocker for this Feature.
+
+## Feature
+
+**Title:** Add HTTP API access to automatic segmentation results
+
+**Description:**
+Researchers and ML engineers currently have no way to query segmentation
+results except by opening `results/batch_results.csv` manually or running
+Octave scripts. This Feature adds a small, read-only HTTP API that exposes
+per-participant metrics and cohort-wide aggregate statistics, backed by
+PostgreSQL instead of a flat CSV file.
+
+**Goal / business value:**
+Make segmentation results queryable and machine-readable without requiring
+GNU Octave, so results can be integrated into other tools (analysis
+notebooks, dashboards, CI checks) and so quality can be monitored without
+manual file inspection.
+
+**Success criteria:**
+- An ML engineer can retrieve the Dice Score and lesion volumes for any
+  processed participant via a single HTTP request.
+- An ML engineer can retrieve aggregate statistics (mean/min/max Dice Score,
+  participant count) for the whole cohort via a single HTTP request.
+- API responses are documented and browsable via Swagger (`/docs`).
+- The underlying dataset cannot be modified through the API (read-only by
+  design for this iteration).
+
+**Out of scope (for this iteration):**
+- The segmentation algorithm itself (`src/*.m`) is not modified.
+- Write/update endpoints (e.g. flagging a result, triggering a re-run) — see
+  "Future considerations" below.
+- Authentication/authorization beyond the database-level `qa_readonly` role.
+
+**Future considerations:**
+- A write-capable endpoint (e.g. `PATCH /results/{subject_code}/review_status`)
+  for reviewers to flag participants, once the algorithm is stable enough that
+  accidental data loss is a smaller risk than the current validation phase.
+- Would require a second, write-capable database role in addition to
+  `qa_readonly`, with its own audit trail.
+
+**Implementation status:** delivered — see `api/`, `db/schema.sql`,
+`docker-compose.yml`.
-- 
2.43.0