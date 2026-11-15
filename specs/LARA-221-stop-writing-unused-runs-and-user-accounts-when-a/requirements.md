# Stop Writing Unused Runs and User Accounts When a Sequence Redirects to the Activity Player

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-221
**Repo**: https://github.com/concord-consortium/lara
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

Opening a LARA sequence or activity URL now only redirects to the Activity Player, but on the way through LARA still writes runs (for a sequence, a sequence run and one run per activity) and, for portal-linked URLs, a LARA user account, none of which is ever read. This story stops those writes on both redirects and removes the code that only existed to support them.

## Project Owner Overview

LARA is no longer the runtime for sequences or activities: `/sequences/:id` and `/activities/:id` hand the visitor to the Activity Player, which stores student work in the report service. Leftovers from when LARA rendered them itself still run first. They write about 1,600 anonymous `runs` rows a day (about 584,000 a year) that nothing reads, 95% of them from sequence links and 5% from activity links; and they sign teachers who follow the Geniventure "online course" link into LARA through the portal, which has created 2,029 LARA accounts since 2023-01-01 that own nothing. That is growth in the database LARA-222 is about to clean up.

After this story, visitors land on the same Activity Player page as today, with no LARA writes and no portal sign-in on the way. LARA-222 deletes the rows already written; this story only stops new ones. It ships in LARA 2.22.0 (LARA-231), on staging before production.

## Background

`SequencesController#show` authorizes `:read` and redirects to `ACTIVITY_PLAYER_URL` with only `?sequence=<api_v1_sequence_url>.json`. Two filters run before it:

1. **`ApplicationController#portal_login`** (a global `before_action`). When the URL carries `domain` (the Geniventure link sends `domain` and `domain_uid`), it signs out any visitor whose authentications do not match, strips both params, and redirects to the portal OAuth path with the stripped URL as `origin`. The callback reaches `User.find_for_concord_portal_oauth`, which creates a LARA user for a first-time portal user, and then returns to `/sequences/:id`.
2. **`SequencesController#find_or_create_sequence_run`** (`before_action ... only: [:show]`). It has three branches:
   - `sequence_run_key` param (route `/sequences/:id/sequence_run/:sequence_run_key`): looks the run up with `first!`, so an unknown key is a 404.
   - `collaborators_data_url` param: `CreateCollaboration#call`, which fetches the collaborator list from the portal, creates a `CollaborationRun`, creates LARA users for unknown collaborator emails, and creates a sequence run with runs for each collaborator.
   - Otherwise: `SequenceRun.lookup_or_create`, which raises `RecordNotFound` (404) for portal params without a signed-in user, reuses an existing sequence run for a signed-in user, and **always creates a new one for an anonymous visitor**, then `make_or_update_runs` creates one `Run` per activity. With portal params it also calls `SequenceRun#disable_collaboration`.

`@sequence_run` is used only by `app/views/sequences/show.html.haml`, which `show` never renders. The redirect carries no run key, and the Activity Player mints its own `uuidv4()` run key when it gets no `runKey` (`activity-player/src/portal-api.ts`, `runKey = uuidv4()` in the anonymous path), so nothing on either side ties one visit to the next. The Activity Player also handles `collaborators_data_url` itself (`activity-player/src/portal-api.ts`), and LARA's redirect drops that param, so the collaboration LARA builds is never seen by the runtime.

The account creation is **not** caused by the run filter: it happens in `portal_login`, before `find_or_create_sequence_run` runs. Removing the run filter alone leaves the accounts being created (confirmed below), so stopping them needs `show` to skip `portal_login` as well.

`LightweightActivitiesController#show` (`/activities/:id`, `/activities/:id/:run_key`, `/sequences/:sid/activities/:id` and `/sequences/:sid/activities/:id/:run_key`) is the same shape. It authorizes `:read` and redirects to `ACTIVITY_PLAYER_URL` with `activity=` (or `sequence=` and `sequenceActivity=` when the path is under `/sequences/`) plus `runKey=` copied from the `run_key` path param, which it reads from `params`, not from a run. Before it run `portal_login`, `set_run_key_from_portal_launchable` (`ApplicationController#set_run_key`: `CreateCollaboration` for `collaborators_data_url`, otherwise `Run.lookup`, which validates a `run_key`, creates an anonymous run on every visit, reuses a signed-in user's run, and inside a sequence creates a sequence run with one run per activity), `set_sequence` (which only checks the run's sequence against `sequence_id`) and `enable_js_logger`. `show` on a standalone activity (no `sequence_id`) is the only caller that passes `portal_launchable: true`, which lets a signed-in portal launch (`returnUrl` and `externalId`) reach `Run.lookup`'s portal branch (`Run.for_user_and_portal` and `disable_collaboration`); every other `set_run_key` caller raises `RecordNotFound` for portal params first.

The legacy runtime is different: `interactive_pages#show`, `lightweight_activities#single_page` and `#summary` still render LARA pages (or the report) from the run they create, so their runs are read. They stay as they are.

Behavior confirmed on the current code with throwaway controller specs (sequence with 3 activities, rows counted as `[SequenceRun, Run, User, CollaborationRun]`):

| Request to `GET /sequences/:id` | Today |
|---|---|
| anonymous, twice | `[1,3,0,0]` then `[2,6,0,0]`, 302 to the AP each time |
| signed in, twice | `[1,3,·,0]` after both: one sequence run, reused |
| private sequence, anonymous | `[1,3,0,0]` written, **then** 403 (the filter runs before `authorize!`) |
| unknown `sequence_run_key` | 404 (`RecordNotFound`) |
| portal params (`returnUrl`, `externalId`), anonymous | 404 (`RecordNotFound`) |
| `domain` + `domain_uid` | 302 to `/users/auth/<portal>?origin=…` (OAuth), no AP redirect yet |
| `collaborators_data_url` | `CreateCollaboration#call` runs, then 302 to the AP |

For `/activities/:id`, two anonymous visits wrote 2 runs, and the same activity opened inside a sequence wrote a sequence run and a run per activity in it.

With the run filter replaced by `skip_before_action :portal_login, only: [:show]`, the same specs wrote no rows in any case and sent `domain` requests straight to the AP.

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
  - on the activity redirect, a `run_key` that matches no run, or matches a run of another activity or sequence, is passed to the Activity Player as `runKey` (was 404). LARA's check guarded nothing, because anyone can open the Activity Player with any `runKey` directly;
  - on the activity redirect, portal params redirect to the Activity Player for an anonymous visitor (was 404), for a signed-in one on `/sequences/:sid/activities/:id` (was 404, since `portal_launchable` is false inside a sequence), and for a signed-in one on `/activities/:id` without finding or creating a portal run first;
  - a `domain` that names no configured portal redirects to the Activity Player on both `show` actions (was a 500: `Concord::AuthPortal.strategy_name_for_url` raises "Can't find a portal");
  - the same private-content rules apply to a private activity: still 403, without writing first, and 403 for a `domain` link from a visitor not signed in;
  - a portal launch or `collaborators_data_url` on the activity redirect no longer creates a run with a `remote_endpoint`, so it no longer increments the activity's `portal_run_count` (`Run#update_activity_portal_run_count`), the "used by N learners" count the authoring editor shows (`LightweightActivity#active_runs`). No current traffic reaches it: none of the 49,379 runs written in the 30 days to 2026-08-31 has a `remote_endpoint` (the trace in Technical Notes).
- **R5.** The `sequence_with_sequence_run_key`, `activity_with_run` and `sequence_activity_with_run` routes stay, so old links that carry a run key keep redirecting to the Activity Player.

### Remove what only the redirect's old rendering used

- **R6.** `find_or_create_sequence_run` is deleted, along with the `enable_js_logger` filter on sequence `show`. Activity `show` drops `set_run_key`, `set_sequence` and `enable_js_logger` from its filters; `set_activity` still 404s an activity id that the path's sequence does not contain. The logger filter sets `gon.loggerConfig`, which reaches a page only when a view renders, and copies a `logging` param into `session[:logging]` for later LARA runtime pages; a visitor redirected from `show` goes to the Activity Player, which takes no logging setting from LARA's session.
- **R7.** The dead view `app/views/sequences/show.html.haml` is deleted with its view spec `spec/views/sequences/show.html.haml_spec.rb`, and `app/assets/javascripts/activity-box-click.js` (which targets only that view's markup and says so) is deleted with its `//= require` in `app/assets/javascripts/runtime.js`. `spec/features/author_edits_sequence.rb` is deleted too: it asserts that visiting `sequence_path` creates a sequence run with runs, the contract this story removes, and it has never run, because its name lacks the `_spec.rb` suffix RSpec's default pattern needs. What only that view used goes with it: `LightweightActivityHelper#complete_badge_for` and `Sequence#time_to_complete` (with its model spec example), and the layout `app/views/layouts/sequence_run.html.erb`, which no controller has rendered since sequence `show` began redirecting to the Activity Player in 2022.
- **R8.** Code that the deletion leaves with no caller is deleted:
  - `CreateCollaboration`'s sequence branch (`@sequence`, `add_sequence_runs`, `owners_sequence_run`) with its "when a sequence is provided as a material" spec block, and `SequenceRun#disable_collaboration`;
  - the `portal_launchable` option: `set_run_key` takes no options and always raises `RecordNotFound` for portal params, and the wrappers `set_run_key_from_portal_launchable` and `set_run_key_to_false` give way to `before_action :set_run_key`;
  - what only a portal launch reached: the `disable_collaboration` call in `set_run_key`, `Run#disable_collaboration`, `CollaborationRun#disable` (called only by the two `disable_collaboration` methods), and `Run.lookup`'s `portal` argument and branch, with the `run_spec` example for it;
  - the shared examples `"runnable resource launchable by the portal"` and `"runnable launched with portal parameters"` in `spec/support/shared_examples/runnable_resource.rb`, which no spec includes and which pin the portal-launch behavior removed here;
  - `SequenceRun.lookup_or_create`'s `portal` argument, which its one remaining caller (`Run.for_user_activity_and_sequence`) fills with an empty `RemotePortal`: the argument, its portal-only `raise`, its `update_platform_info` call and `SequenceRun`'s `include WithPlatformInfo`. It keeps matching only runs with no portal fields.

  `SequenceRun.lookup_or_create` itself and `Run.for_user_and_portal` stay: `Run.for_user_activity_and_sequence` and `CreateCollaboration` still call them.

### Tests

- **R9.** `spec/controllers/sequences_controller_spec.rb` and `spec/controllers/lightweight_activity_controller_spec.rb` cover R1 to R3 for each request shape in R1: no rows written (counted, not mocked), the AP redirect, for `domain` that the visitor stays signed in and gets no OAuth redirect, and for a private sequence and a private activity opened through a `domain` link by a visitor not signed in that the answer is 403 with nothing written (R4). Each test must fail under at least one of the two regressions (the run filter, or `portal_login`, running again on its `show`), and each regression must fail at least one test.

### Verification after deploy

- **R10.** On staging, opening `/sequences/<id>`, `/activities/<id>` and `/sequences/<sid>/activities/<id>` anonymously, and `/sequences/<id>?domain=<portal>&domain_uid=<uid>`, lands on the Activity Player with no new `sequence_runs`, `runs` or `users` rows (implementation.md's verify step says how to read them on staging). On production, compare 7-day counts before and after the release: anonymous `sequence_runs` and `runs` (`user_id IS NULL`) should fall to near zero, and new `users` with no authored content to about zero. What remains comes from the legacy page views (`/activities/:id/pages/:id`, `single_page`, `summary`), which still render the run they create; the traffic trace does not split the standalone 5% by path, so that remainder is measured here rather than predicted. Bound each production count by a primary-key range (the largest `id` at the window's start) rather than `created_at`, which `runs` does not index, and set `max_execution_time`: `runs` holds about 16.5 million rows (InnoDB estimate) on a `db.t3.medium`.

## Technical Notes

- `app/controllers/sequences_controller.rb`: the filters on lines 3 to 6, `show`, and `find_or_create_sequence_run`.
- `app/controllers/lightweight_activities_controller.rb`: the runtime filters at the top, `show`, `set_run_key_from_portal_launchable`.
- `app/controllers/interactive_pages_controller.rb`: `set_run_key_to_false`.
- `app/controllers/application_controller.rb`: `portal_login` (global `before_action`), `set_run_key`.
- `app/models/run.rb`: `lookup`, `disable_collaboration`.
- `app/models/collaboration_run.rb`: `disable`.
- `app/models/sequence_run.rb`: `lookup_or_create`, `make_or_update_runs`, `disable_collaboration`, `include WithPlatformInfo`.
- `app/services/create_collaboration.rb` and `spec/services/create_collaboration_spec.rb`: the activity branch stays and is still called from `ApplicationController#set_run_key` for the legacy page views.
- Other code that names sequence runs (`LogoHelper`, the rest of `LightweightActivityHelper`, `interactive_pages/_show_completion`, the `.sequence-page` styles) belongs to the legacy runtime views, which other actions still set `@sequence_run` for. It is out of scope here.
- Neither `show` has other filters that write: `set_sequence` reads, and the remaining global filters (`log_session_before/after`, `reject_old_browsers`, `set_locale`, `store_auto_publish_url`, `intialize_gon`) do not touch the database.
- Production figures (about 1,600 anonymous runs a day, 95% sequences and 5% standalone activities, 2,029 accounts, no `remote_endpoint` in 30 days, the `runs` row count, the missing `created_at` index) come from the `student-data-deletion` trace, `docs/lara-legacy-data/README.md` and `public-traffic.md`; the traffic figures cover the 30 days to 2026-08-31, and the 2,029 accounts since 2023-01-01 is the LARA-221 description's figure (the trace gives 2,029 as a running total).

## Out of Scope

- Deleting rows and accounts already written: LARA-222.
- The legacy runtime views, helpers and styles other actions still render (see Technical Notes).
- `ApplicationController#portal_login` for any action other than the two `show` actions.
- The legacy runtime actions that render from their run (`interactive_pages#show`, `lightweight_activities#single_page`, `#summary`, `#preview`, `#resubmit_answers`): they keep creating runs, because they use them. Retiring them is a follow-up story: redirect those URLs to the matching Activity Player page and delete the runtime. Measured for that story: about 760 lines of views only the runtime renders (15 files), about 3,500 lines of JavaScript only `runtime.js` loads (19 files), and roughly 500 to 700 lines of Ruby, plus specs. Separately, about 5,800 lines of runtime stylesheets (about 45 files) have been loaded by no layout or manifest since the runtime layout's theme stylesheet link was removed in April 2023, so those pages render without LARA's own CSS today. R10's post-deploy counts size the runs that remain.
- Activity Player behavior, including how it identifies a visitor who arrives with no `token`.

## Open Questions

### RESOLVED: Judgment call: how to stop the user accounts, given the ticket names only the run filter
**Decision**: skip `portal_login` on both `show` actions (R2). The accounts come from `portal_login`, which runs before the run filter, so removing the filter alone (deferring accounts to a follow-up) would leave the title false; changing `portal_login` globally would change sign-in for every authoring page.

### RESOLVED: Judgment call: how much dead code to delete with the filter
**Decision**: the filter, the view, its spec, the JS only that view uses, and what that leaves with no caller (R6 to R8). Deleting only the filter would leave a view that cannot render and an orphaned collaboration branch; deleting the legacy runtime helpers and styles reaches into views other actions still render.

### RESOLVED: Judgment call: whether the 404-to-302 and sign-in-to-403 changes need product sign-off
**Decision**: accept them and record them in R4. The 404s guarded a lookup whose result was discarded, and keeping them would keep code alive only to refuse requests the Activity Player serves; the private-content 403 needs an external portal link to a private sequence or activity, which LARA's own links never produce.

### RESOLVED: Whether to include the activity redirect, which writes runs the same way
**Decision** (Doug, stage 8): include it, regardless of its 5% share of anonymous runs (46,884 from sequences, 2,443 from standalone activities in the trace's 30 days). The legacy page views, which render their runs, stay out of scope; R10 measures what remains.

### RESOLVED: Stage 8 cross-reference gaps
**Decision** (Doug): the private-content 403s in R4 get a test per controller (R9); `CreateCollaboration` keeps its `material` argument and type check, losing only the sequence lines (R8); the legacy page views are a follow-up story (Out of Scope).

## Self-Review

Each finding was confirmed in the code (or by throwaway specs) before it was written, and all are fixed in place in the body above.

Before squash and rounds 1 to 3 (roles: senior Rails engineer, QA engineer, operator, data steward, security engineer, commit reviewer, test writer, requirements-only reader, caller-hunting maintainer, release engineer, cross-file consistency reviewer, cold PR reviewer, test-reliability engineer, Rails-semantics reviewer, observability reviewer): the never-run feature file joined R7's deletions; R10 counts by primary-key range with `max_execution_time`; R6 covers `session[:logging]`; R10 names the writers that remain; `complete_badge_for`, `Sequence#time_to_complete` and the `sequence_run` layout joined R7; R9 asks for each test to fail under at least one regression and each regression to fail at least one test; `CollaborationRun#disable` joined R8; R4 lists the `portal_run_count` side effect.

### Round 4

Roles: next engineer and spec editor, fresh implementer following implementation.md in commit order, verifier of the prose's figures and claims, staging tester.

- **Verifier**: the behavior table's private-sequence row said `[1,2,0,0]` under a caption of 3 activities; a throwaway spec on master writes `[1,3,0,0]` (and reproduces the anonymous and signed-in rows). Corrected.
- **Verifier**: R10 said `runs` holds about 119M rows; the trace's 119 million is all student-data tables together, and its row-count table gives `runs` about 16.5 million (InnoDB estimate). Corrected.
- **Verifier**: Technical Notes put the sequence filters on lines 2 to 5; on master they are lines 3 to 6. Corrected.
- **Verifier**: the production figures had no stated source; it is now stated once in Technical Notes (the trace for traffic and row counts, the Jira description for the 2,029 accounts since 2023-01-01).
- **Spec editor**: the Open Questions and Self-Review restated the body at length across five rounds; compressed to one decision line per question and one summary of the earlier rounds, with no decision dropped.

### Round 5

Roles: ticket auditor, existing-link user (with the Activity Player source), adversarial reviewer, rollback reviewer. Throwaway specs ran each request shape below on master and on the planned code; the planned code wrote nothing and redirected to the Activity Player in every case.

- **Adversarial**: a signed-in portal launch on `/sequences/:sid/activities/:id` was 404 on master (`set_run_key_from_portal_launchable` passes `portal_launchable` only without `sequence_id`), not the portal-run path R4 implied. R4 and the Background now say so.
- **Existing-link user**: a `domain` naming no configured portal raised `RuntimeError` ("Can't find a portal") on master, a 500 on both `show` actions; it now redirects. Added to R4.
- **Adversarial**: a visitor signed in by a remember-me cookie gets Devise's `trackable` update of their `users` row on any page, `show` included (`after_set_user except: :fetch`). R1 now excludes it explicitly; the row-count tests are unaffected.
- Checked and dropped: every "Proposed work" item, both "Check before removing" items (the `sequence_run_key` branch is a bare `first!` with no side effect; the `collaborators_data_url` branch is answered in the Background) and the ticket's Verification target (R10) are answered.
- Checked and dropped: the Geniventure link's `mode=teacher-edition`, `show_index` and `logging` reach the Activity Player neither before nor after (the sequence redirect builds only `sequence=`), so dropping them is no change; the Activity Player mints `uuidv4()` only when `runKey` is absent and reads `collaborators_data_url` only in its portal-JWT path (`activity-player/src/portal-api.ts`), as the Background says.
