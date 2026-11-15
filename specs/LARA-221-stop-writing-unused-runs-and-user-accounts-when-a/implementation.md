# Implementation Plan: Stop Writing Unused Runs and User Accounts When a Sequence Redirects to the Activity Player

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-221
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Five commits. The first two change behavior, one redirect each, and carry the tests; the other three only delete code those two leave unreachable. Each one leaves the suite green on its own. No dependency or lockfile changes. To roll back, redeploy the previous image (nothing here migrates or changes the schema) or revert all five, newest first: the deletion steps depend on the behavior steps, so reverting the sequence step alone after the collaboration step makes every `/sequences/:id` raise `ArgumentError` (`SequenceRun.lookup_or_create` given 3 arguments, expects 2).

### Stop the sequence redirect writing runs and signing visitors in

**Summary**: `SequencesController#show` stops running `find_or_create_sequence_run`, `enable_js_logger` and `ApplicationController#portal_login`, and the filter method is deleted. The `GET show` specs are rewritten to count rows for every request shape in R1. Covers R1 to R6 and R9 for sequences.

**Files affected**:
- `app/controllers/sequences_controller.rb`: filters at the top; delete `find_or_create_sequence_run`.
- `spec/controllers/sequences_controller_spec.rb`: replace the `describe "GET show"` block.

**Estimated diff size**: ~115 lines (3 added and 24 removed in the controller; 78 added and 13 removed in the spec).

Controller, top of the class:

```ruby
# before
  before_action :set_sequence, except: [:index, :new, :create]
  before_action :find_or_create_sequence_run, only: [:show]

  before_action :enable_js_logger, only: [:show]

  before_action :setup_abilities, only: [:new, :edit]

# after
  before_action :set_sequence, except: [:index, :new, :create]
  # show only redirects to the Activity Player, which receives no LARA identity,
  # so signing the visitor in through the portal would only create an unused user.
  skip_before_action :portal_login, only: [:show]

  before_action :setup_abilities, only: [:new, :edit]
```

Delete the private `find_or_create_sequence_run` method whole (the `sequence_run_key`, `collaborators_data_url` and `SequenceRun.lookup_or_create` branches). `show` itself is unchanged; `set_sequence` still runs for it.

Spec: replace the existing `describe "GET show"` block (its two examples, "assigns the requested sequence" and "redirects to the activity player", are subsumed) with:

```ruby
  describe "GET show" do
    let(:sequence) do
      FactoryBot.create(:sequence, publication_status: 'public', project: project, user: user).tap do |s|
        3.times { s.activities << FactoryBot.create(:public_activity) }
      end
    end
    let(:activity_player_url) do
      uri = URI.parse(ENV['ACTIVITY_PLAYER_URL'])
      query = Rack::Utils.parse_query(uri.query)
      query["sequence"] = "#{api_v1_sequence_url(sequence.id)}.json"
      uri.query = Rack::Utils.build_query(query)
      uri.to_s
    end

    def written_rows
      [SequenceRun.count, Run.count, CollaborationRun.count, User.count]
    end

    before(:each) do
      sign_out @user
      sequence
    end

    shared_examples "a redirect that writes nothing" do
      it "redirects to the Activity Player without writing runs or users" do
        expect { get :show, params: request_params }.not_to change { written_rows }
        expect(response).to redirect_to(activity_player_url)
      end
    end

    describe "when anonymous" do
      let(:request_params) { { id: sequence.id } }
      it_behaves_like "a redirect that writes nothing"
    end

    describe "when signed in" do
      before(:each) { sign_in user }
      let(:request_params) { { id: sequence.id } }
      it_behaves_like "a redirect that writes nothing"
    end

    describe "with a sequence run key that matches no run" do
      let(:request_params) { { id: sequence.id, sequence_run_key: "no-such-key" } }
      it_behaves_like "a redirect that writes nothing"
    end

    describe "with portal parameters while anonymous" do
      let(:request_params) { { id: sequence.id, returnUrl: "http://portal.example/return", externalId: "1" } }
      it_behaves_like "a redirect that writes nothing"
    end

    describe "with a collaborators_data_url" do
      let(:request_params) { { id: sequence.id, collaborators_data_url: "http://portal.example/collaborations/1" } }
      it_behaves_like "a redirect that writes nothing"
    end

    describe "with portal sign-in parameters" do
      let(:request_params) do
        { id: sequence.id, domain: Concord::AuthPortal.all.values.first.url, domain_uid: "42" }
      end
      it_behaves_like "a redirect that writes nothing"

      it "keeps a signed-in visitor signed in" do
        sign_in user
        get :show, params: request_params
        expect(controller.current_user).to eq(user)
      end
    end

    describe "when the sequence is private" do
      let(:sequence) do
        FactoryBot.create(:sequence, publication_status: 'private', project: project, user: user).tap do |s|
          2.times { s.activities << FactoryBot.create(:public_activity) }
        end
      end

      it "refuses an anonymous visitor without writing runs" do
        expect { get :show, params: { id: sequence.id } }.not_to change { written_rows }
        expect(response).to have_http_status(:forbidden)
      end

      it "refuses a visitor with portal sign-in parameters without starting a portal sign-in" do
        params = { id: sequence.id, domain: Concord::AuthPortal.all.values.first.url, domain_uid: "42" }
        expect { get :show, params: params }.not_to change { written_rows }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
```

Notes for the tests:
- `domain` must be a configured portal URL, or `portal_login` raises "Can't find a portal" instead of redirecting to OAuth; `Concord::AuthPortal.all.values.first.url` is the test environment's (`http://foo.org`).
- The rows are counted, not mocked, so a test fails on any path that writes, including one added later.
- Mutations (R9): restoring the run filter fails 8 of the 9 examples (all but "keeps a signed-in visitor signed in"); removing `skip_before_action :portal_login` fails the three `domain` examples (OAuth redirect, visitor signed out).

---

### Stop the activity redirect writing runs and signing visitors in

**Summary**: `LightweightActivitiesController#show` stops running the run filter, `set_sequence`, `enable_js_logger` and `portal_login`. `show` already builds its redirect from `params` alone, so it needs no other change. New specs count rows for every request shape in R1. Covers R1 to R6 and R9 for activities.

**Files affected**:
- `app/controllers/lightweight_activities_controller.rb`: the runtime filters at the top.
- `spec/controllers/lightweight_activity_controller_spec.rb`: a new block inside `describe '#show'`.

**Estimated diff size**: ~75 lines (3 added and 3 changed in the controller; 67 added in the spec).

```ruby
# before
  before_action :set_run_key_from_portal_launchable, only: [:summary, :show, :preview, :resubmit_answers, :single_page]
  before_action :set_sequence, only: [:summary, :show, :single_page, :preview]

  before_action :enable_js_logger, only: [:summary, :show, :preview, :single_page]

# after
  before_action :set_run_key_from_portal_launchable, only: [:summary, :preview, :resubmit_answers, :single_page]
  before_action :set_sequence, only: [:summary, :single_page, :preview]
  # show only redirects to the Activity Player, which receives no LARA identity,
  # so signing the visitor in through the portal would only create an unused user.
  skip_before_action :portal_login, only: [:show]

  before_action :enable_js_logger, only: [:summary, :preview, :single_page]
```

`set_run_key_from_portal_launchable` is left as it is here; with `show` gone from its list, its `portal_launchable` result is always false, and the cleanup step below removes it. The four existing `#show` examples (404 for a missing activity, the activity and sequence redirects, and the run key passed on) stay and pass unchanged. Without the run filter, a portal launch through `show` no longer creates a portal run, so `Run#update_activity_portal_run_count` no longer bumps the activity's `portal_run_count` (R4); no spec covers that count, and none is added.

Spec, appended inside `describe '#show'` after "redirects to AP with a run key if given one" (the file's `act` is a public activity, `user` a plain user):

```ruby
    describe "writing nothing on the way to the Activity Player" do
      let(:sequence_with_activities) do
        FactoryBot.create(:sequence, publication_status: 'public').tap do |s|
          3.times { s.activities << FactoryBot.create(:public_activity) }
        end
      end

      def written_rows
        [SequenceRun.count, Run.count, CollaborationRun.count, User.count]
      end

      def expect_redirect_without_writes(params)
        expect { get :show, params: params }.not_to change { written_rows }
        expect(response.location).to start_with(ENV['ACTIVITY_PLAYER_URL'].chomp('/'))
      end

      before(:each) do
        act
        sequence_with_activities
      end

      it "when anonymous" do
        expect_redirect_without_writes(id: act.id)
      end

      it "when signed in" do
        sign_in user
        expect_redirect_without_writes(id: act.id)
      end

      it "when opened inside a sequence" do
        expect_redirect_without_writes(sequence_id: sequence_with_activities.id, id: sequence_with_activities.activities[0].id)
      end

      it "with a run key that matches no run" do
        expect_redirect_without_writes(id: act.id, run_key: UUIDTools::UUID.random_create.to_s)
      end

      it "with portal parameters" do
        sign_in user
        expect_redirect_without_writes(id: act.id, returnUrl: "http://portal.example/return", externalId: "1")
      end

      it "with a collaborators_data_url" do
        expect_redirect_without_writes(id: act.id, collaborators_data_url: "http://portal.example/collaborations/1")
      end

      it "with portal sign-in parameters, keeping a signed-in visitor signed in" do
        sign_in user
        expect_redirect_without_writes(id: act.id, domain: Concord::AuthPortal.all.values.first.url, domain_uid: "42")
        expect(controller.current_user).to eq(user)
      end

      it "refuses a private activity opened through a portal sign-in link, without writing or signing in" do
        private_activity = FactoryBot.create(:activity, publication_status: 'private')
        params = { id: private_activity.id, domain: Concord::AuthPortal.all.values.first.url, domain_uid: "42" }
        expect { get :show, params: params }.not_to change { written_rows }
        expect(response).to have_http_status(:forbidden)
      end

      it "refuses an activity the path's sequence does not contain" do
        expect {
          get :show, params: { sequence_id: sequence_with_activities.id, id: act.id }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
```

The last example covers R6: with `set_sequence` gone from `show`, `set_activity` is the only filter that checks the activity belongs to the path's sequence, and it fails if `set_activity` falls back to `LightweightActivity.find`. The private activity is built here rather than taken from the file's `private_act`, which uses the `:activity` factory's default `hidden` status and so is readable by anyone.

Mutations (R9): restoring the run filter on `show` fails the 8 write-counting examples (the private one too, because the filter writes before `authorize!`); removing `skip_before_action :portal_login` fails the two `domain` examples (the private one gets the OAuth redirect instead of 403).

---

### Delete the sequence page that show no longer renders

**Summary**: Delete the view `show` stopped rendering, its view spec, the layout it was last rendered in, the helper and model method and JavaScript that only that view used, and a feature file that asserts the removed behavior and never runs. Covers R7.

**Files affected**:
- `app/views/sequences/show.html.haml`: delete (60 lines). Nothing renders it, and after the previous step nothing sets `@sequence_run`, so rendering it would raise on its `@sequence_run.run_for_activity` call.
- `spec/views/sequences/show.html.haml_spec.rb`: delete (23 lines).
- `app/assets/javascripts/activity-box-click.js`: delete (9 lines). It binds `.sequence-page .activities .activity`, markup only the deleted view produces, and its comment names that view.
- `app/assets/javascripts/runtime.js`: remove the line `//= require activity-box-click`. Sprockets raises `FileNotFound` for a `require` whose file is gone, so this line and the file go in the same commit.
- `spec/features/author_edits_sequence.rb`: delete (72 lines). It expects `visit sequence_path(...)` to create a sequence run; RSpec never loads it (no `_spec.rb` suffix).
- `app/views/layouts/sequence_run.html.erb`: delete (106 lines). No controller names it; the last `render layout: "sequence_run"` went when `show` began redirecting, in 2022. Its partials and logo helpers stay, used by the `runtime` and `print_blank` layouts.
- `app/helpers/lightweight_activity_helper.rb`: delete `complete_badge_for` (8 lines). Only the deleted view calls it.
- `app/models/sequence.rb`: delete `time_to_complete` (6 lines), and `spec/models/sequence_spec.rb`: delete its example "calculates a cumulative time-to-complete" (6 lines). Only the deleted view calls it; `ApplicationHelper#time_to_complete` and the activity column stay, for `lightweight_activities/show`.

**Estimated diff size**: ~290 lines, all deletions.

The `.sequence-page` and `.activity-bg` rules in `activity-sequences.scss`, `mw-runtime-base.scss` and `partials/_cc-theme-template.scss` stay: they are mixed into stylesheets other runtime pages use, and removing them is the legacy-runtime cleanup that requirements.md puts out of scope.

---

### Delete the sequence branch of collaboration setup

**Summary**: With `find_or_create_sequence_run` gone, nothing passes a `Sequence` to `CreateCollaboration` and nothing calls `SequenceRun#disable_collaboration`. Delete both, and the spec block for the sequence branch. That also leaves `SequenceRun.lookup_or_create` with one caller, `Run.for_user_activity_and_sequence`, which passes an empty `RemotePortal.new({})`, so its `portal` argument goes too. Covers R8.

**Files affected**:
- `app/services/create_collaboration.rb`: drop the sequence branch (2 added, 14 removed).
- `app/models/sequence_run.rb`: delete `disable_collaboration` (8 lines); `lookup_or_create(sequence, user)` without its `portal` argument, its portal-only `raise` and its `update_platform_info` call; delete `include WithPlatformInfo` and its comment, which only that call used (3 added, 22 removed in all).
- `app/models/run.rb`: `Run.for_user_activity_and_sequence` calls `SequenceRun.lookup_or_create(Sequence.find(seq_id), user)` (1 line).
- `spec/models/sequence_run_spec.rb`: rewrite the `lookup_or_create` block for the two-argument call (17 added, 31 removed).
- `spec/services/create_collaboration_spec.rb`: delete the `describe "when a sequence is provided as a material"` block (34 lines), and add "should return the owner's run" to the activity block, since `call` now returns `@owners_run` alone and nothing else checks what it returns (7 lines).

**Estimated diff size**: ~130 lines (28 added, 100 removed).

`CreateCollaboration`, the lines that change (the `material` argument, its `is_a?(LightweightActivity)` check and `add_activity_run ... if @activity` stay as they are):

```ruby
# before
  attr_reader :collaboration_run, :owners_run, :owners_sequence_run
  ...
    @activity = material.is_a?(LightweightActivity) ? material : nil
    @sequence = material.is_a?(Sequence) ? material : nil
    ...
    @owners_run = nil
    @owners_sequence_run = nil
  end

  # Setups collaboration and returns run or sequence run (depending on provided material type).
  def call
    ...
    # Return run or sequence run that belongs to the collaboration owner.
    @owners_sequence_run || @owners_run
  end
  ...
      add_activity_run(user, portal_endpoint) if @activity
      add_sequence_runs(user, portal_endpoint) if @sequence
  ...
  def add_sequence_runs(user, portal_endpoint)
    ...
  end

# after
  attr_reader :collaboration_run, :owners_run
  ...
    @activity = material.is_a?(LightweightActivity) ? material : nil
    ...
    @owners_run = nil
  end

  def call
    ...
    @owners_run
  end
  ...
      add_activity_run(user, portal_endpoint) if @activity
  ...
  (add_sequence_runs deleted)
```

The two comments that described the sequence-or-activity return are deleted, not rewritten.

`SequenceRun.lookup_or_create`, `make_or_update_runs` and `run_for_activity` stay: `Run.for_user_activity_and_sequence` still creates sequence runs for an activity opened inside a sequence. With an empty portal, `platform_info` is `{}`, so `update_platform_info` changed nothing, and the `raise` needed a valid portal. `lookup_or_create` keeps matching on `remote_endpoint: nil, remote_id: nil`, so a signed-in user is never handed a sequence run that was launched from a portal:

```ruby
  def self.lookup_or_create(sequence, user)
    conditions = {
      remote_endpoint: nil,
      remote_id:       nil,
      user_id:         user ? user.id : nil,
      sequence_id:     sequence.id
    }
    ... (lookup for a signed-in user, create!, make_or_update_runs: unchanged)
  end
```

The `lookup_or_create` spec block, after: an existing run built without portal fields (the file's shared `existing_seq_run` keeps its portal fields for the other blocks, so the block defines its own), and these examples: the same user gets the existing run; another sequence or another user gets a new one; a user whose only run of the sequence was launched from a portal gets a new one (fails if the `nil` conditions are dropped); an anonymous visitor gets a new run every time. The two portal examples ("when the portal isn't the same", "when platform info is provided") and the file's top-level `portal` double, which only they used, are deleted.

---

### Delete the portal launch path that only the activity redirect used

**Summary**: Activity `show` was the only action that passed `portal_launchable: true`, so after the second step every `set_run_key` caller refuses portal params before `Run.lookup`, and the portal path behind it is unreachable. Delete the option, the two wrappers that only passed it, the `disable_collaboration` call it guarded with `Run#disable_collaboration` and `CollaborationRun#disable` (whose only other caller, `SequenceRun#disable_collaboration`, went in the previous step), `Run.lookup`'s `portal` argument and branch, and the specs and shared examples that describe portal launches. Covers R8.

**Files affected**:
- `app/controllers/application_controller.rb`: `set_run_key` takes no options.
- `app/controllers/lightweight_activities_controller.rb`, `app/controllers/interactive_pages_controller.rb`: `before_action :set_run_key`; delete `set_run_key_from_portal_launchable` and `set_run_key_to_false`.
- `app/models/run.rb`: `lookup(key, activity, user, seq_id)`; delete `disable_collaboration`.
- `app/models/collaboration_run.rb`: delete `disable` (4 lines).
- `spec/models/run_spec.rb`: drop the `nil` portal argument from five calls, drop `portal` from the label `describe "self.lookup(key,activity,user=nil,portal,seq_id)"`, and delete the "with a remote endpoint" example.
- `spec/support/shared_examples/runnable_resource.rb`: delete `"runnable launched with portal parameters"` and `"runnable resource launchable by the portal"`, which no spec includes, and the unused `portal_launchable` block parameter of `"runnable launched with run_key"`; cut the file header to the three routes that still include these examples, with `Run` as the only run type.

**Estimated diff size**: ~215 lines (13 added; 121 of the removals are the two shared examples).

```ruby
# ApplicationController, before
  def set_run_key(opts)
    ...
    else
      portal = RemotePortal.new(params)
      if portal.valid? && !opts[:portal_launchable]
        raise(ActiveRecord::RecordNotFound)
      end

      # This creates a new key if one didn't exist before
      @run = Run.lookup(params[:run_key], @activity, current_user, portal, params[:sequence_id])
      # If activity is ran with "portal" params, it means that user wants to run it individually.
      # Note that "portal" refers to individual student data endpoint, this name should be updated.
      if portal.valid?
        @run.disable_collaboration
      end
    end

# after
  def set_run_key
    ...
    else
      raise(ActiveRecord::RecordNotFound) if RemotePortal.new(params).valid?

      # This creates a new key if one didn't exist before
      @run = Run.lookup(params[:run_key], @activity, current_user, params[:sequence_id])
    end

# LightweightActivitiesController, first filter
  before_action :set_run_key, only: [:summary, :preview, :resubmit_answers, :single_page]

# InteractivePagesController, second filter
  before_action :set_run_key, only: [:show, :preview]

# Run.lookup, before: the `if portal && portal.valid?` block at the top (for_user_and_portal, or
# RecordNotFound for an anonymous portal launch, or an exception for a portal launch inside a sequence)
  def self.lookup(key, activity, user, portal, seq_id)
# after: that block deleted, the rest unchanged
  def self.lookup(key, activity, user, seq_id)
```

`set_run_key` is `protected` in `ApplicationController`, which `before_action` can call. `Run.for_user_and_portal` stays, because `CreateCollaboration#add_activity_run` calls it. The legacy page views keep refusing portal params with a 404, as the `"runnable resource not launchable by the portal"` examples on `#single_page` and the page controller still check.

---

### Verify after deploy (no commit)

**Summary**: R10's checks, run by whoever deploys LARA 2.22.0.

- Staging (`authoring.lara.staging.concord.org`): read `MAX(id)` of `sequence_runs`, `runs` and `users`; in a private window open `/sequences/<id>`, `/activities/<id>` and `/sequences/<sid>/activities/<id>`, and `/sequences/<id>?domain=https://learn.staging.concord.org/&domain_uid=1` (`domain` is any portal in the staging stack's `CONCORD_CONFIGURED_PORTALS`, such as `learn.staging.concord.org`; `show` no longer reads `domain_uid`); each lands on the Activity Player without passing through `/users/auth/`; read the three values again: unchanged. The database is reachable only inside the VPC, so read them with a one-off ECS task on cluster `staging`, task definition `authoring-lara-staging-App`, command override `["bundle","exec","rails","runner","p [SequenceRun.maximum(:id), Run.maximum(:id), User.maximum(:id)]"]` (the `run-task` call in `.claude/skills/release-lara/SKILL.md`'s migration-status step); the output lands in the `authoring-lara-staging` CloudWatch log group. Staging is shared, so if a value moved, check whether the new rows came from these requests.
- Production, 7 days before and after the release: record `MAX(id)` of each table at each window boundary, and count `user_id IS NULL` rows of `sequence_runs` and `runs` by primary-key range, with `SET SESSION max_execution_time` set first (`runs` has no `created_at` index). For `users`, count new ids in the range that own no activity or sequence. Expected: anonymous `sequence_runs` and `runs` near zero (the remainder is the legacy page views, which render their runs), new unowned `users` about zero.

## Open Questions

### RESOLVED: Judgment call: how to split the commits
**Decision**: one behavior commit per redirect with its tests, then three deletion-only commits, rather than one commit of about 815 lines. Keeping the roughly 630 deleted lines out of the behavior commits keeps those reviews short, and each deletion commit can be checked on its own ("nothing references this any more").

### RESOLVED: Rename `CreateCollaboration`'s third argument
**Decision** (Doug, stage 8): keep `material` and its `is_a?` check and delete only the sequence lines; renaming to `activity` is tidiness R8 does not ask for.

### RESOLVED: Judgment call: test shape for R9
**Decision**: count rows over each request shape, for both controllers, rather than mock `SequenceRun.lookup_or_create` and `CreateCollaboration`; counting catches any future write path, and the mutation notes above show it fails for both regressions R9 names.

### RESOLVED: Drop `SequenceRun.lookup_or_create`'s `portal` argument
**Decision** (Doug): once the sequence filter and `CreateCollaboration`'s sequence branch go, its only caller passes `RemotePortal.new({})`, so the `raise` is unreachable, `remote_endpoint` and `remote_id` are always nil and `update_platform_info({})` does nothing. The collaboration step drops the argument, its branch and `include WithPlatformInfo`, and rewrites the model spec block.

## Self-Review

Verification harness: the `lara-app` image with the worktree mounted, against `mariadb:11.2` (CI's database), `RAILS_ENV=test`, lara-typescript built first. Master's full suite is 1563 examples; with all five steps, 1575 examples and 0 failures (the planned 1573 plus the sequence-membership and owner's-run examples code review added), also in random order (`--order rand:22111`). `Api::V1::InteractivePagesController#get_portal_list` fails when only `spec/models/run_spec.rb` and `spec/controllers` run together, on master too: an existing order dependency that passes in the full suite and alone.

Earlier rounds (roles: commit reviewer, test writer, operator, security engineer, requirements-only reader, implementer, caller-hunting maintainer, release engineer, cross-file consistency reviewer, cold PR reviewer, LARA-222 data steward, test-reliability engineer, Rails-semantics reviewer, observability reviewer) are folded into the steps above: the portal-launch step, the sequence-page step's helper, model method and layout, `CollaborationRun#disable`, the remeasured diff sizes and mutation counts, and the `portal_run_count` note.

Checked, no change needed: Sprockets raises `FileNotFound` if the `activity-box-click` `require` outlives the file; `skip_before_action :portal_login` names a callback the parent defines; `Concord::AuthPortal.all.values.first` is the test environment's `PORTAL`, and `ENV['ACTIVITY_PLAYER_URL']` is set in `config/environments/test.rb`; under the run-filter regression the `collaborators_data_url` examples fail on WebMock's blocked request; the run-key routes still reach `show`; `"runnable launched without run_key"` and `"with run_key"` stay included by `"runnable resource not launchable by the portal"`; `ribbon` and the `COMPLETED` string stay, used by `_show_completion`; the only `NewRelic` call is in `raise_error_if_not_authorized_run`, which neither `show` reaches; sessions are cookie-stored, so no global filter writes on `show`; no migration, rake task, initializer, `lara-typescript` source, doc or `assets:precompile` input uses a deleted method, view or asset (`AddMissingPlatformInfo` calls `Run#update_platform_info`, which stays); `ReportService::RunSender`, `reporting:publish_anonymous_runs` and `ClassInfoImportHelper` read columns directly and no column changes; the Activity Player's `/api/v1/sequences/:id.json` has no `authorize!`; production is MySQL 8, so `max_execution_time` applies; `include ApplicationHelper` in `SequencesController`, `SequenceRun#most_recent_activity`, the `show` branch of `set_layout` and the commented-out `run_complete_sequence_spec.rb` were dead before this change.

### Round 4

Roles: next engineer and spec editor, fresh implementer building each commit in order from this file alone, verifier of the requirements' figures, staging tester. Each commit was built in order from this file alone; the specs it touches pass after each one, the full suite after the fifth is 1573 examples, 0 failures, and the diff sizes match the estimates within a few lines.

- **Fresh implementer**: the portal-launch step did not say to update `run_spec.rb`'s `describe "self.lookup(key,activity,user=nil,portal,seq_id)"` label, which names the deleted argument. Added to that step's file list.
- **Staging tester**: the staging check named no portal URL and no way to read `MAX(id)` on a database reachable only inside the VPC. It now names the staging host, a `domain` value, and the one-off ECS task and log group; the `rails runner` command was run on the local harness.
- **Spec editor**: the Self-Review repeated the step bodies and recorded intermediate counts that later rounds superseded (1574, 1576, 209, 811); compressed to the harness, the final counts, and one "checked, no change needed" list. The mutation notes lost their "run on this exact code" narration. Open Questions compressed to one decision each; the `lookup_or_create` decision moved there from the Self-Review.
- Checked and dropped: the activity spec's portal-params example is signed in only; the anonymous shape is covered for sequences, and on activity `show` it differs only by taking `Run.lookup`'s 404 branch instead of `for_user_and_portal`, so no example is added.
- Checked and dropped: the quoted `lookup_or_create` "after" block omits the `#TODO: add domain` line the prose does not mention; following the quote deletes it, which is harmless.

### Round 5

Roles: rollback reviewer, adversarial reviewer. Rebuilt all five steps (`CollaborationRun#disable` and the `run_spec` label included): 1573 examples, 0 failures.

- **Rollback reviewer**: with all five steps applied, restoring master's `sequences_controller.rb` and its spec (what reverting the sequence step alone does, since no later step touches them) fails both old `GET show` examples with `ArgumentError: wrong number of arguments (given 3, expected 2)` in `SequenceRun.lookup_or_create`. The plan's intro now says to roll back by image or by reverting all five newest first.
- Checked and dropped: on the planned code, throwaway specs sending every R1 parameter at once (signed in, nested, unknown `run_key`, `domain`, `collaborators_data_url`, portal params, `logging`), a `.json` request, and another activity's real run key inside a sequence all wrote nothing and redirected; an activity outside the path's sequence still raises `RecordNotFound`; `Run.lookup` has no caller left passing a portal.
