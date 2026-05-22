# Design: Add `multiple_answers` to report structure; gate `authored_state` to MC only

**Date:** 2026-05-22
**Status:** Draft for review

## Background

LARA publishes activity structure to a Firestore-backed report-service via `SendToReportServiceJob`. The serializer at [base_interactive.rb:65-94](../../../app/models/base_interactive.rb#L65-L94) includes a parsed `authored_state` Hash for every interactive. That causes two problems:

1. **Publish failures from Firestore constraints.** Interactives whose authored state contains nested arrays trip Firestore's `"Property array contains an invalid nested entity"` error (gRPC code 3). The job retries 5 times and then disappears (`destroy_failed_jobs = true`). Confirmed live cause: the Blockly question-interactive, whose `customBlocks[].config.options` is `[[label, value], ...]`. Other interactives may have similar shapes.
2. **Document size.** For the failing activity 14277, `authored_state` is 94.5% of the 82.7 KiB structure document. A sequence rolls up its activities into one Firestore doc, putting long Blockly-heavy sequences at credible risk of breaching the 1 MB document limit.

An audit across `concord-consortium` repositories found that the only consumer of `authored_state` in report-service structure documents is `portal-report`, and only for one field: `authoredState.multipleAnswers` on multiple-choice questions. Portal-report has already been updated to read a top-level `multipleAnswers` first, falling back to `authoredState.multipleAnswers`.

## Goals

- Eliminate Firestore publish failures caused by interactive-defined authored-state shapes LARA does not control.
- Substantially reduce the structure-document footprint.
- Preserve the one piece of data portal-report needs (`multipleAnswers` for MC).
- Improve failure observability so the next problem of this kind is diagnosable from logs alone.

## Non-goals

- Removing `authored_state` from MC structure-doc output. That follow-up is gated on portal-report's new reader being rolled out and any further audit (see Phase 2).
- Changing how `authored_state` is exposed through other LARA APIs (e.g., `/api/v1/activities/:id.json`).
- Changing `Delayed::Worker.destroy_failed_jobs` or `max_attempts`. Tracked separately.

## Changes

### 1. `BaseInteractive#report_service_hash` — gate `authored_state`, add `multiple_answers`

File: [app/models/base_interactive.rb](../../../app/models/base_interactive.rb#L65-L94)

- Include `authored_state` in the result **only** when `metadata[:questionType] == "multiple_choice"`. For all other types (the default `iframe_interactive`, `open_response`, `image_question`, etc.), omit the key entirely.
- When the question is multiple choice, additionally emit `multiple_answers:` at the top level, sourced from `metadata[:multipleAnswers]`. If the metadata does not include the key (value is `nil`), the `multiple_answers` key is not emitted.

### 2. `Embeddable::MultipleChoice#report_service_hash` — add `multiple_answers`

File: [app/models/embeddable/multiple_choice.rb](../../../app/models/embeddable/multiple_choice.rb#L115-L128)

- Emit `multiple_answers:` sourced from the `multi_answer` DB column. The column is schema-nullable but in production all rows are non-null with a default of `false`; follow the same conditional pattern as above (omit when nil) for consistency.

This path's `report_service_hash` does not currently include `authored_state`, so no removal is needed here.

### 3. `SendToReportServiceJob` — include response details in failure

File: [app/models/send_to_report_service_job.rb](../../../app/models/send_to_report_service_job.rb#L42-L46)

- When `result["success"]` is not truthy, raise `FailedToSendToReportService` with a message that includes the HTTP status code and a truncated response body (cap at e.g. 500 chars). This populates Delayed::Job's `last_error` and the worker container's stdout/CloudWatch with enough context to diagnose future failures without needing to manually reproduce the request.
- No change to retry count, deletion policy, or DB-side failure persistence in this phase.

### 4. Tests

- `base_interactive_spec` (or equivalent): verify the output omits `authored_state` for non-MC types, includes it for MC, and emits `multiple_answers` from metadata when present (and omits otherwise).
- `multiple_choice_spec`: verify `multiple_answers` is emitted from the `multi_answer` column when set, and omitted (not `nil`) when the column is `nil`.
- `send_to_report_service_job_spec`: simulate a failed HTTParty response and assert the raised exception's message includes the response code and a body excerpt.

## Naming

Structure-doc keys use snake_case throughout (`authored_state`, `question_number`, `sub_type`), so the new field is `multiple_answers`. Portal-report's existing snake_case→camelCase read transform surfaces it as `multipleAnswers` on the JS side.

## Effect on existing data

Forward-only by default. Existing Firestore documents continue to carry the unchanged `authored_state` until each activity is republished. To clear the backlog (including activities whose jobs already expired through 5 retries), this change also ships:

### 5. Rake task: backlog clear

A new task in [lib/tasks/reporting.rake](../../../lib/tasks/reporting.rake), e.g. `reporting:republish_to_report_service`, that:

- Iterates `LightweightActivity.where("publication_hash IS NOT NULL")` and `Sequence.where("publication_hash IS NOT NULL")` in batches.
- For each, **enqueues** `SendToReportServiceJob` (the same code path as the natural `after_update` callback), rather than synchronously calling `ResourceSender#send` as the existing `reporting:publish_structures` task does.

Rationale for enqueue-not-send:

- The job's existing `payload_hash == last_report_service_hash` check makes re-runs cheap no-ops for already-published activities, so we can safely run across the full eligible set without skipping logic in the task itself.
- The job updates `last_report_service_hash` on success; the existing immediate-send rake task does not, leaving LARA's view of "what's published" perpetually stale.
- Failures retry through the worker under the new logging (change #3), giving us visibility into anything still broken.

`publication_hash IS NOT NULL` is the same filter the existing `reporting:publish_structures[portal]` task uses ([reporting.rake:42](../../../lib/tasks/reporting.rake#L42)) as the proxy for "ever portal-published". It excludes activities that have only existed in authoring and were never given to learners — those should not be blindly republished.

## Phase 2 (future, not in this change)

After portal-report's new reader is rolled out and verified in production, drop `authored_state` from MC output as well. At that point `BaseInteractive#report_service_hash` no longer emits the key under any condition, and the field can also be removed from any structure-doc consumer documentation.
