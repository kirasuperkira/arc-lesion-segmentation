# Requirements lifecycle and change procedure

See `requirements-lifecycle.drawio` for the visual diagram (open in
[draw.io](https://app.diagrams.net) or the draw.io VS Code extension).

## Stages

1. **Draft** — a requirement is captured, typically from a stakeholder
   interview (see `interview-feature.md` for an example).
2. **Review & approval** — the stakeholder(s) who requested it sign off on
   scope, goal, and success criteria before it enters the backlog.
3. **In backlog** — approved as a Feature or broken down into PBIs/User
   Stories with acceptance criteria (see `backlog.md`), prioritized against
   other work.
4. **In development** — actively being implemented.
5. **Done** — acceptance criteria have been verified (tests passing, manual
   check, or both).
6. **Archive** — no further changes expected; kept for traceability.

## Change procedure

A requirement can be changed at any point after Draft — most commonly after
Done, when new information surfaces (e.g. a stakeholder realizes an
additional field is needed, or a constraint changes).

1. **Initiation.** Anyone (developer, QA, stakeholder) can raise a change
   request. It must reference the original Feature/PBI and describe what
   changed and why.
2. **Impact assessment.** Whoever owns the affected item (typically the
   developer who implemented it, or the QA engineer who wrote its acceptance
   criteria) evaluates:
   - does this affect already-verified acceptance criteria?
   - does it require new database migrations / API contract changes?
   - is it backward-compatible, or does it break existing consumers?
3. **Re-approval.** The same stakeholder(s) who approved the original
   requirement re-sign-off on the change, with the impact assessment
   attached. This mirrors the original Review & approval step — a change is
   treated as a mini version of the same process, not skipped.
4. **Versioning.** The PBI/Feature description is updated in place with a
   short changelog note (date + what changed), rather than creating a
   disconnected duplicate item. If using Azure DevOps, this is a comment on
   the existing work item, not a new one — traceability to the original
   requirement must be preserved.
5. **Back to backlog.** The item re-enters the backlog, re-prioritized
   alongside other work — it does not jump the queue by default.
6. **Communication.** The team is notified (standup, PR description, or
   equivalent) that a previously "Done" item has changed, especially if it
   affects downstream consumers of the API or database schema.

## Example applied to this project

`db/schema.sql` originally defined `qa_readonly` as read-only. If, per the
"Future considerations" in `interview-feature.md`, write access is later
requested:
- Change request references PBI-4 (`backlog.md`) and the Feature.
- Impact assessment: requires a new database role, an audit trail, and new
  acceptance criteria — this is not a small tweak.
- Re-approval needed because it changes a security-relevant decision made
  during the original interview.
- Result: a new PBI-6 (already stubbed in `backlog.md` under "Future
  backlog") is scheduled, not a silent edit to PBI-4.
