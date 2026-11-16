# Stop Writing Unused Runs and User Accounts When a Sequence Redirects to the Activity Player

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-221

**Status**: **Closed**

## Overview

Opening a LARA sequence or activity URL only redirects to the Activity Player, but on the way through LARA still wrote runs (for a sequence, a sequence run and one run per activity) and, for portal-linked URLs, a LARA user account, none of which was ever read. This story stops those writes on both redirects and removes the code that only existed to support them.

At the time of the spec, the redirects wrote about 1,600 anonymous `runs` rows a day (about 584,000 a year), 95% from sequence links and 5% from activity links, and portal sign-in through the Geniventure "online course" link had created 2,029 LARA accounts since 2023-01-01 that own nothing. Visitors land on the same Activity Player page as before. LARA-222 deletes the rows already written; this story only stops new ones. It ships in LARA 2.22.0 (LARA-231), on staging before production.

## Requirements

### No writes on either redirect

- **R1.** `SequencesController#show` (`/sequences/:id`, `/sequences/:id/sequence_run/:sequence_run_key`) and `LightweightActivitiesController#show` (`/activities/:id`, `/activities/:id/:run_key`, `/sequences/:sid/activities/:id`, `/sequences/:sid/activities/:id/:run_key`) write no `sequence_runs`, `runs`, `collaboration_runs` or `users` rows (Devise's `trackable` update of a visitor signed in by a remember-me cookie, which every LARA page does, is outside this), for every request shape: anonymous, signed in, private sequence or activity, any run key or sequence run key, portal params, `domain`/`domain_uid`, and `collaborators_data_url`.
- **R2.** Neither `show` runs `ApplicationController#portal_login`: a URL with `domain`/`domain_uid` redirects straight to the Activity Player, no portal OAuth starts, no LARA user is created, and a signed-in visitor is not signed out.
- **R3.** Both actions keep authorizing `:read` and keep their redirect targets unchanged: for a sequence, `sequence=<api_v1_sequence_url>.json` and nothing else; for an activity, `activity=` or `sequence=` with `sequenceActivity=`, and `runKey=` when the path carries a run key, all merged into `ACTIVITY_PLAYER_URL`'s query.

### Behavior changes that follow (accepted)

- **R4.** These responses change, and each is the intended outcome, not a regression:
  - an unknown `sequence_run_key` redirects to the Activity Player (was 404);
  - portal params on an anonymous request redirect to the Activity Player (was 404);
  - a private sequence opened anonymously is still 403, but without writing rows first;
  - a private sequence opened with `domain`/`domain_uid` by a visitor who is not signed in to LARA is 403 (was: portal sign-in, then 302 for the owner or a project admin). LARA's own authoring links to a sequence's runtime go straight to the Activity Player (`SequenceHelper#sequence_runtime_url`), so only external links reach `show`, and the Activity Player loads `/api/v1/sequences/:id.json` without authorization in either case;
  - on the activity redirect, a `run_key` that matches no run, or matches a run of another activity or sequence, is passed to the Activity Player as `runKey` (was 404);
  - on the activity redirect, portal params redirect to the Activity Player for an anonymous visitor (was 404), for a signed-in one on `/sequences/:sid/activities/:id` (was 404), and for a signed-in one on `/activities/:id` without finding or creating a portal run first;
  - a `domain` that names no configured portal redirects to the Activity Player on both `show` actions (was a 500, "Can't find a portal");
  - the same private-content rules apply to a private activity: still 403, without writing first, and 403 for a `domain` link from a visitor not signed in;
  - a portal launch or `collaborators_data_url` on the activity redirect no longer creates a run with a `remote_endpoint`, so it no longer increments the activity's `portal_run_count`. No current traffic reaches it: none of the 49,379 runs written in the 30 days to 2026-08-31 has a `remote_endpoint`.
- **R5.** The `sequence_with_sequence_run_key`, `activity_with_run` and `sequence_activity_with_run` routes stay, so old links that carry a run key keep redirecting to the Activity Player.

### Remove what only the redirect's old rendering used

- **R6.** `find_or_create_sequence_run` is deleted, along with the `enable_js_logger` filter on sequence `show`. Activity `show` drops `set_run_key`, `set_sequence` and `enable_js_logger` from its filters; `set_activity` still 404s an activity id that the path's sequence does not contain.
- **R7.** The dead view `app/views/sequences/show.html.haml` is deleted with its view spec, and `app/assets/javascripts/activity-box-click.js` with its `//= require` in `runtime.js`. `spec/features/author_edits_sequence.rb`, which asserted the removed contract and never ran (no `_spec.rb` suffix), is deleted too. What only that view used goes with it: `LightweightActivityHelper#complete_badge_for`, `Sequence#time_to_complete` (with its model spec example), and the layout `app/views/layouts/sequence_run.html.erb`, which no controller had rendered since 2022.
- **R8.** Code that the deletion leaves with no caller is deleted:
  - `CreateCollaboration`'s sequence branch (`@sequence`, `add_sequence_runs`, `owners_sequence_run`) with its spec block, and `SequenceRun#disable_collaboration`;
  - the `portal_launchable` option: `set_run_key` takes no options and always raises `RecordNotFound` for portal params, and the wrappers `set_run_key_from_portal_launchable` and `set_run_key_to_false` give way to `before_action :set_run_key`;
  - what only a portal launch reached: the `disable_collaboration` call in `set_run_key`, `Run#disable_collaboration`, `CollaborationRun#disable`, and `Run.lookup`'s `portal` argument and branch, with the `run_spec` example for it;
  - the shared examples `"runnable resource launchable by the portal"` and `"runnable launched with portal parameters"`, which no spec included;
  - `SequenceRun.lookup_or_create`'s `portal` argument, its portal-only `raise`, its `update_platform_info` call and `SequenceRun`'s `include WithPlatformInfo`. It keeps matching only runs with no portal fields.

  `SequenceRun.lookup_or_create` itself and `Run.for_user_and_portal` stay: `Run.for_user_activity_and_sequence` and `CreateCollaboration` still call them.

### Tests

- **R9.** `spec/controllers/sequences_controller_spec.rb` and `spec/controllers/lightweight_activity_controller_spec.rb` cover R1 to R3 for each request shape in R1: no rows written (counted, not mocked), the Activity Player redirect, for `domain` that the visitor stays signed in and gets no OAuth redirect, and for a private sequence and a private activity opened through a `domain` link by a visitor not signed in that the answer is 403 with nothing written. Each test must fail under at least one of the two regressions (the run filter, or `portal_login`, running again on its `show`), and each regression must fail at least one test. *(Implemented with three examples beyond the plan, added in code review: the R6 sequence-membership 404 on activity `show`, `CreateCollaboration#call` returning the owner's run, and the counted tables shared from `spec/support/redirect_write_counts.rb`.)*

### Verification after deploy

- **R10.** On staging, opening `/sequences/<id>`, `/activities/<id>` and `/sequences/<sid>/activities/<id>` anonymously, and `/sequences/<id>?domain=<portal>&domain_uid=<uid>`, lands on the Activity Player with no new `sequence_runs`, `runs` or `users` rows. On production, compare 7-day counts before and after the release: anonymous `sequence_runs` and `runs` (`user_id IS NULL`) should fall to near zero, and new `users` with no authored content to about zero. What remains comes from the legacy page views, which still render the run they create. Bound each production count by a primary-key range rather than `created_at`, which `runs` does not index, and set `max_execution_time`: `runs` holds about 16.5 million rows. *(Not yet run: it happens after LARA 2.22.0 deploys. See Not Yet Implemented.)*

## Technical Notes

- The user accounts came from `ApplicationController#portal_login` (a global `before_action`), which runs before the run filter and creates a LARA user through `User.find_for_concord_portal_oauth`. Removing the run filter alone would have left the accounts being created, so both `show` actions skip `portal_login`.
- The Activity Player receives no LARA identity from either redirect and mints its own `uuidv4()` run key when it gets no `runKey`, so nothing on either side tied one visit to the next. It also handles `collaborators_data_url` itself, and the sequence redirect dropped that param.
- The legacy runtime (`interactive_pages#show`, `lightweight_activities#single_page`, `#summary`) still renders from the run it creates, so it keeps creating runs. Other code that names sequence runs (`LogoHelper`, the rest of `LightweightActivityHelper`, `interactive_pages/_show_completion`, the `.sequence-page` styles) belongs to that runtime.
- Production figures (about 1,600 anonymous runs a day, the 95/5 split, no `remote_endpoint` in 30 days, the `runs` row count and missing `created_at` index) come from the `student-data-deletion` trace, `docs/lara-legacy-data/README.md` and `public-traffic.md`, covering the 30 days to 2026-08-31; the 2,029 accounts since 2023-01-01 is the Jira description's figure.
- Rollback: redeploy the previous image (nothing migrates or changes the schema), or revert all five implementation commits newest first. Reverting the sequence-redirect commit alone after the collaboration commit makes every `/sequences/:id` raise `ArgumentError`.

## Out of Scope

- Deleting rows and accounts already written: LARA-222.
- The legacy runtime views, helpers and styles other actions still render.
- `ApplicationController#portal_login` for any action other than the two `show` actions.
- The legacy runtime actions that render from their run (`interactive_pages#show`, `lightweight_activities#single_page`, `#summary`, `#preview`, `#resubmit_answers`): they keep creating runs, because they use them. Retiring them is a follow-up story: redirect those URLs to the matching Activity Player page and delete the runtime. Measured for that story: about 760 lines of views only the runtime renders (15 files), about 3,500 lines of JavaScript only `runtime.js` loads (19 files), roughly 500 to 700 lines of Ruby plus specs, and separately about 5,800 lines of runtime stylesheets (about 45 files) that no layout or manifest has loaded since April 2023.
- Activity Player behavior, including how it identifies a visitor who arrives with no `token`.

## Not Yet Implemented

- The post-deploy checks in R10: they run on staging and then production once LARA 2.22.0 deploys. Staging reads `MAX(id)` of `sequence_runs`, `runs` and `users` with a one-off ECS task (cluster `staging`, task definition `authoring-lara-staging-App`, `rails runner`), and production compares 7-day counts bounded by primary-key range.

## Decisions

### How to stop the user accounts, given the ticket names only the run filter
**Context**: The ticket proposes stopping `find_or_create_sequence_run`, but the accounts are created by `portal_login`, which runs first.
**Options considered**:
- A) Remove only the run filter and leave the accounts to a follow-up
- B) Change `portal_login` globally
- C) Skip `portal_login` on both `show` actions

**Decision**: C. A would leave the story's title false, and B would change sign-in for every authoring page.

---

### How much dead code to delete with the filter
**Context**: Removing the filter orphans the view, its JavaScript and a chain of helpers and portal-launch code.
**Options considered**:
- A) Delete only the filter
- B) Delete the filter, the view, its spec and JS, and whatever that leaves with no caller
- C) Also delete the legacy runtime helpers and styles

**Decision**: B (R6 to R8). A leaves a view that cannot render and an orphaned collaboration branch; C reaches into views other actions still render.

---

### Whether the 404-to-302 and sign-in-to-403 changes need product sign-off
**Context**: Several responses change (R4).
**Options considered**:
- A) Keep the old 404s and sign-in behavior
- B) Accept the changes and record them in R4

**Decision**: B. The 404s guarded a lookup whose result was discarded, and the private-content 403 needs an external portal link to private content, which LARA's own links never produce.

---

### Whether to include the activity redirect, which writes runs the same way
**Context**: The ticket names only sequences; standalone activities produce about 5% of anonymous runs.
**Options considered**:
- A) Sequences only
- B) Include activity `show`

**Decision** (Doug): B, regardless of its 5% share. The legacy page views, which render their runs, stay out of scope; R10 measures what remains.

---

### Stage 8 cross-reference gaps
**Context**: Cross-referencing the two specs left three gaps.
**Options considered**:
- A) Test the private-content 403s, or leave them untested
- B) Rename `CreateCollaboration`'s `material` argument to `activity`, or keep it
- C) Retire the legacy page views here, or record them as a follow-up

**Decision** (Doug): the private-content 403s get a test per controller (R9); `CreateCollaboration` keeps `material` and its type check, losing only the sequence lines; the legacy page views are a follow-up story (Out of Scope).

---

### Visitors signed in by a remember-me cookie
**Context**: Devise's `trackable` updates the `users` row on any page for such a visitor, `show` included.
**Options considered**:
- A) Treat it as a write R1 forbids
- B) Exclude it from R1 explicitly

**Decision**: B. It happens on every LARA page and is not one of the writes this story targets; the row-count tests are unaffected.

---

### A `domain` naming no configured portal
**Context**: On master it raised "Can't find a portal", a 500 on both `show` actions.
**Options considered**:
- A) Preserve the error
- B) Let it redirect like any other request

**Decision**: B, recorded in R4. Skipping `portal_login` removes the lookup that raised.

---

### How to split the commits
**Context**: The change is about 815 lines, about 630 of them deletions.
**Options considered**:
- A) One commit
- B) One behavior commit per redirect with its tests, then three deletion-only commits

**Decision**: B. Keeping the deletions out of the behavior commits keeps those reviews short, and each deletion commit can be checked on its own. Roll back by image, or by reverting all five newest first, since the deletion commits depend on the behavior commits.

---

### Test shape for R9
**Context**: The tests must fail if the run filter or `portal_login` comes back on either `show`.
**Options considered**:
- A) Mock `SequenceRun.lookup_or_create` and `CreateCollaboration`
- B) Count rows over each request shape for both controllers

**Decision**: B. Counting catches any future write path, and mutation runs showed it fails for both regressions. The counted tables live once, in `spec/support/redirect_write_counts.rb`, so both controllers' specs count the same ones.

---

### Drop `SequenceRun.lookup_or_create`'s `portal` argument
**Context**: Once the sequence filter and `CreateCollaboration`'s sequence branch go, its only caller passes an empty `RemotePortal`.
**Options considered**:
- A) Keep the argument
- B) Drop the argument, its `raise`, `update_platform_info` and `include WithPlatformInfo`

**Decision** (Doug): B. The `raise` is unreachable, `remote_endpoint` and `remote_id` are always nil, and `update_platform_info({})` does nothing. It keeps matching `remote_endpoint: nil, remote_id: nil`, so a signed-in user is never handed a sequence run launched from a portal.

---

### Tests added during code review
**Context**: With `set_sequence` gone from activity `show`, `set_activity` is the only check that an activity belongs to the path's sequence; `CreateCollaboration#call` now returns `@owners_run` alone and nothing checked its return value.
**Options considered**:
- A) Leave both uncovered, as the plan did
- B) Add one example each

**Decision**: B. "refuses an activity the path's sequence does not contain" fails if `set_activity` falls back to `LightweightActivity.find`, and "should return the owner's run" fails if `call` returns another collaborator's run.
