# Multiple-answers field + gate authored_state to MC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop emitting `authored_state` to the Firestore report-service structure document for every interactive (it trips Firestore's nested-array constraint and dominates document size). Keep it only for MC, and surface the one field portal-report actually needs (`multiple_answers`) as a first-class structure-doc property. Also improve failure logging on `SendToReportServiceJob` and add a backlog-clearing rake task.

**Architecture:** Three small Ruby edits (`SendToReportServiceJob`, `BaseInteractive#report_service_hash`, `Embeddable::MultipleChoice#report_service_hash`), one new rake task in `lib/tasks/reporting.rake`, and matching RSpec coverage in existing spec files. No new files except possibly a spec for the new rake task (the existing `spec/libs/tasks/reporting_rake_spec.rb` is the right place).

**Tech Stack:** Ruby on Rails (Ruby 3.3.7), RSpec, FactoryBot, Delayed::Job, HTTParty.

**Environment:** Plan is intended to be executed in a GitHub Codespace (local Apple Silicon docker for LARA is unreliable per [README.md:111-112](../../../README.md#L111-L112)). All commands assume the Codespace's Rails container is up and `bundle exec rspec` works.

**Reference spec:** [2026-05-22-multiple-answers-field-design.md](../specs/2026-05-22-multiple-answers-field-design.md)

---

## Task 0: Pre-flight — confirm test setup works

**Files:** none (verification only)

- [ ] **Step 1: Run the existing job spec to confirm RSpec is wired up**

Run: `bundle exec rspec spec/models/send_to_report_service_job_spec.rb`
Expected: all examples pass (the file has ~10 examples as of writing).

- [ ] **Step 2: Run the existing shared-examples for base interactive (via managed_interactive_spec)**

Run: `bundle exec rspec spec/models/managed_interactive_spec.rb`
Expected: all examples pass.

If either of those fails on `main`, stop and debug the test environment before continuing. The remaining tasks assume green baseline.

---

## Task 1: Capture HTTP status + body in `SendToReportServiceJob` failures

**Files:**
- Modify: `app/models/send_to_report_service_job.rb` (current lines 35-46 — the `if result["success"] / else / raise` block)
- Test: `spec/models/send_to_report_service_job_spec.rb` (current line 82-87 — the `"when the server returns an error"` describe)

**Why first:** smallest change, gives us better logs while developing the rest, and the spec changes here are isolated to the existing failure example.

- [ ] **Step 1: Write the failing test**

Edit `spec/models/send_to_report_service_job_spec.rb`. Replace the existing `report_service_response` let inside `describe "when the server returns an error"` so the double also exposes `code` and `body`, and add an assertion on the exception message:

```ruby
    describe "when the server returns an error"  do
      let(:report_service_response) do
        double("HTTPartyResponse").tap do |r|
          allow(r).to receive(:[]).with("success").and_return(false)
          allow(r).to receive(:code).and_return(500)
          allow(r).to receive(:body).and_return('{"success":false,"error":{"details":"Property array contains an invalid nested entity."}}')
        end
      end

      it "the job should throw an exception to retry the job" do
        expect(sender).not_to receive(:update_column)
        expect { job.perform }.to raise_exception(SendToReportServiceJob::FailedToSendToReportService)
      end

      it "the exception message includes HTTP status and a body excerpt" do
        expect { job.perform }.to raise_exception(SendToReportServiceJob::FailedToSendToReportService) { |e|
          expect(e.message).to include("500")
          expect(e.message).to include("Property array contains an invalid nested entity")
        }
      end
    end
```

- [ ] **Step 2: Run the new test to verify it fails**

Run: `bundle exec rspec spec/models/send_to_report_service_job_spec.rb -e "exception message"`
Expected: FAIL — the current exception message is the literal string `"Failed to send"`, with no `500` or details substring.

- [ ] **Step 3: Implement the change**

Edit `app/models/send_to_report_service_job.rb`. Replace the `else / raise` branch (around line 42-46) so the message includes status and a truncated body:

```ruby
    result = resource_sender.send()

    if result["success"]
      publishable.update_column(:last_report_service_hash, resource_sender.payload_hash)
    else
      code = result.respond_to?(:code) ? result.code : nil
      body_excerpt = (result.respond_to?(:body) ? result.body.to_s : result.to_s)[0, 500]
      raise FailedToSendToReportService.new("Failed to send: HTTP #{code.inspect} body=#{body_excerpt}")
    end
```

`respond_to?` guards keep the existing test doubles that don't stub `code`/`body` from blowing up.

- [ ] **Step 4: Run the test to verify it passes**

Run: `bundle exec rspec spec/models/send_to_report_service_job_spec.rb`
Expected: PASS (all examples, including both error-case examples).

- [ ] **Step 5: Commit**

```bash
git add app/models/send_to_report_service_job.rb spec/models/send_to_report_service_job_spec.rb
git commit -m "feat(report-service): include HTTP status and body in failed publish exception"
```

---

## Task 2: Add `multiple_answers` to `Embeddable::MultipleChoice#report_service_hash`

**Files:**
- Modify: `app/models/embeddable/multiple_choice.rb` (the `report_service_hash` method, current lines 115-128)
- Test: `spec/models/embeddable/multiple_choice_spec.rb` (add a new `describe '#report_service_hash'` block; the file does not currently test this method)

- [ ] **Step 1: Write the failing tests**

Append the following describe block at the end of `spec/models/embeddable/multiple_choice_spec.rb` (inside `describe Embeddable::MultipleChoice do`, before the final `end`):

```ruby
  describe '#report_service_hash' do
    let(:multichoice) { FactoryBot.create(:multiple_choice) }

    it 'emits multiple_answers when multi_answer is true' do
      multichoice.update!(multi_answer: true)
      expect(multichoice.report_service_hash).to include(multiple_answers: true)
    end

    it 'emits multiple_answers when multi_answer is false' do
      multichoice.update!(multi_answer: false)
      expect(multichoice.report_service_hash).to include(multiple_answers: false)
    end

    it 'omits multiple_answers when multi_answer is nil' do
      multichoice.update_column(:multi_answer, nil)
      expect(multichoice.report_service_hash).not_to have_key(:multiple_answers)
    end
  end
```

`update_column` is used in the nil case to bypass any default-value assignment that `update!` would apply.

- [ ] **Step 2: Run the new tests to verify they fail**

Run: `bundle exec rspec spec/models/embeddable/multiple_choice_spec.rb -e "report_service_hash"`
Expected: 3 examples fail — the hash currently has no `multiple_answers` key.

- [ ] **Step 3: Implement the change**

Edit `app/models/embeddable/multiple_choice.rb`, modifying the `report_service_hash` method. Build the literal hash as before, then conditionally add `multiple_answers`:

```ruby
    def report_service_hash
      result = {
        type: 'multiple_choice',
        id: embeddable_id,
        prompt: prompt,
        choices: choices.map { |choice| {
          id: choice.id,
          content: choice.choice,
          correct: choice.is_correct
        }},
        question_number: index_in_activity,
        required: is_prediction
      }
      result[:multiple_answers] = multi_answer unless multi_answer.nil?
      result
    end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bundle exec rspec spec/models/embeddable/multiple_choice_spec.rb`
Expected: PASS (all examples in the file).

- [ ] **Step 5: Commit**

```bash
git add app/models/embeddable/multiple_choice.rb spec/models/embeddable/multiple_choice_spec.rb
git commit -m "feat(report-service): add multiple_answers to legacy MC report_service_hash"
```

---

## Task 3: Gate `authored_state` to MC in `BaseInteractive`, add `multiple_answers`

**Files:**
- Modify: `app/models/base_interactive.rb` (the `report_service_hash` method, current lines 65-111)
- Test: `spec/support/shared_examples/base_interactive.rb` (extend the existing `#report_service_hash` describe block, current lines 101-187)

**Note:** The shared example is included by both `ManagedInteractive` and `MwInteractive`, so a single edit covers both interactive subclasses.

- [ ] **Step 1: Write the failing tests**

Edit `spec/support/shared_examples/base_interactive.rb`. Make three additions:

(a) In the **default** (`'returns properties supported by Report Service'`) example (around line 102), assert that `authored_state` is **not** present:

```ruby
    it 'returns properties supported by Report Service' do
      expect(interactive.report_service_hash).to include(
        type: 'iframe_interactive',
        id: interactive.embeddable_id,
        name: interactive.name,
        url: interactive.url,
        width: interactive.native_width,
        height: interactive.native_height,
        display_in_iframe: interactive.reportable_in_iframe?,
        question_number: interactive.index_in_activity,
        report_item_url: interactive.report_item_url
      )
      expect(interactive.report_service_hash).not_to have_key(:authored_state)
    end
```

(b) In each of the **open_response** and **image_question** describes (around lines 117-160), add a `not_to have_key(:authored_state)` assertion after the existing `include(...)` check:

```ruby
      it 'returns properties supported by Report Service' do
        expect(interactive.report_service_hash).to include(
          # ... existing assertions unchanged ...
        )
        expect(interactive.report_service_hash).not_to have_key(:authored_state)
      end
```

(c) Extend the **multiple_choice** describe (around lines 162-186) with three new examples plus an assertion that `authored_state` IS still present:

```ruby
    describe "when interactive pretends to be multiple choice question" do
      let (:authored_state) do JSON({
        questionType: "multiple_choice", prompt: "Test prompt", required: true,
        choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}]
      }) end
      let (:interactive) { FactoryBot.create(model_factory, authored_state: authored_state) }

      it 'returns properties supported by Report Service' do
        expect(interactive.report_service_hash).to include(
          type: 'multiple_choice',
          id: interactive.embeddable_id,
          prompt: "Test prompt",
          required: true,
          choices: [{id: "1", content: "Choice A", correct: true}, {id: "2", content: "Choice B", correct: false}],
          question_number: interactive.index_in_activity,
          name: interactive.name,
          url: interactive.url,
          width: interactive.native_width,
          height: interactive.native_height,
          display_in_iframe: interactive.reportable_in_iframe?
        )
      end

      it 'still emits authored_state for backward compatibility' do
        expect(interactive.report_service_hash).to have_key(:authored_state)
      end

      describe "and multipleAnswers is set to true in metadata" do
        let (:authored_state) do JSON({
          questionType: "multiple_choice", prompt: "Test prompt", required: true,
          multipleAnswers: true,
          choices: [{id: "1", content: "Choice A", correct: true}]
        }) end
        it 'emits multiple_answers: true' do
          expect(interactive.report_service_hash).to include(multiple_answers: true)
        end
      end

      describe "and multipleAnswers is set to false in metadata" do
        let (:authored_state) do JSON({
          questionType: "multiple_choice", prompt: "Test prompt", required: true,
          multipleAnswers: false,
          choices: [{id: "1", content: "Choice A", correct: true}]
        }) end
        it 'emits multiple_answers: false' do
          expect(interactive.report_service_hash).to include(multiple_answers: false)
        end
      end

      describe "and multipleAnswers is absent from metadata" do
        it 'omits multiple_answers entirely' do
          expect(interactive.report_service_hash).not_to have_key(:multiple_answers)
        end
      end
    end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bundle exec rspec spec/models/managed_interactive_spec.rb spec/models/mw_interactive_spec.rb`
Expected: multiple failures — `authored_state` is currently emitted for all types, and `multiple_answers` is not emitted at all.

- [ ] **Step 3: Implement the change**

Edit `app/models/base_interactive.rb`, modifying the `report_service_hash` method. Remove `authored_state` from the unconditional `result` hash and move it into the MC-only branch, alongside the new `multiple_answers` emission:

```ruby
  def report_service_hash
    # Expected metadata format can be checked in lara-typescript/interactive-api-client/metadata-types.ts:
    # IAuthoring<...>Metadata interfaces.
    # Metadata is simply provided as a part of authored state. It's optional and everything should work if there's
    # no metadata defined or authored state is empty.
    metadata = parsed_authored_state

    type = metadata[:questionType] || "iframe_interactive"

    result = {
      type: type,
      sub_type: metadata[:questionSubType],
      required: metadata[:required],
      prompt: metadata[:prompt],
      id: embeddable_id,
      name: name,
      url: url,
      display_in_iframe: reportable_in_iframe?,
      width: native_width,
      height: native_height,
      question_number: index_in_activity,
      report_item_url: report_item_url
    }

    if type === "multiple_choice"
      result.merge!({
        choices: (metadata[:choices] || []).map { |c| (c || {}).symbolize_keys.slice(:id, :content, :correct) },
        # Kept for backward compatibility with portal-report's old reader. Will be removed in a follow-up
        # once portal-report's new reader using top-level multiple_answers has rolled out.
        authored_state: metadata
      })
      result[:multiple_answers] = metadata[:multipleAnswers] if metadata.key?(:multipleAnswers)
    elsif type === "image_question"
      result.merge!({
        drawing_prompt: metadata[:answerPrompt]
      })
    end

    result
  end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bundle exec rspec spec/models/managed_interactive_spec.rb spec/models/mw_interactive_spec.rb`
Expected: PASS for all examples in both files.

- [ ] **Step 5: Commit**

```bash
git add app/models/base_interactive.rb spec/support/shared_examples/base_interactive.rb
git commit -m "feat(report-service): gate authored_state to MC, surface multiple_answers"
```

---

## Task 4: Add `reporting:republish_to_report_service` rake task

**Files:**
- Modify: `lib/tasks/reporting.rake` (append a new task inside the existing `namespace :reporting do` block)
- Test: `spec/libs/tasks/reporting_rake_spec.rb` (append a new describe; existing tests use the `"rake"` shared context)

- [ ] **Step 1: Write the failing test**

Append to `spec/libs/tasks/reporting_rake_spec.rb`:

```ruby
describe "reporting:republish_to_report_service" do
  include_context "rake"

  let!(:portal_published_activity)     { LightweightActivity.create!(name: "pp",  publication_hash: "abc") }
  let!(:never_portal_published_act)    { LightweightActivity.create!(name: "npp", publication_hash: nil) }
  let!(:portal_published_sequence)     { Sequence.create!(title: "pps", publication_hash: "def") }
  let!(:never_portal_published_seq)    { Sequence.create!(title: "npps", publication_hash: nil) }

  before(:each) do
    allow(ReportService).to receive(:configured?).and_return(true)
  end

  it "enqueues SendToReportServiceJob for each portal-published activity and sequence" do
    expect(Delayed::Job).to receive(:enqueue) do |job, *_args|
      expect(job).to be_a(SendToReportServiceJob)
      expect([
        ["LightweightActivity", portal_published_activity.id],
        ["Sequence",            portal_published_sequence.id]
      ]).to include([job.publishable_type, job.publishable_id])
    end.twice
    subject.invoke
  end

  it "does not enqueue for activities or sequences without a publication_hash" do
    enqueued_ids = []
    allow(Delayed::Job).to receive(:enqueue) do |job, *_args|
      enqueued_ids << [job.publishable_type, job.publishable_id]
    end
    subject.invoke
    expect(enqueued_ids).not_to include(["LightweightActivity", never_portal_published_act.id])
    expect(enqueued_ids).not_to include(["Sequence",            never_portal_published_seq.id])
  end
end
```

- [ ] **Step 2: Run the new tests to verify they fail**

Run: `bundle exec rspec spec/libs/tasks/reporting_rake_spec.rb -e "republish_to_report_service"`
Expected: FAIL — the task does not exist yet, so `subject` lookup raises.

- [ ] **Step 3: Implement the task**

Edit `lib/tasks/reporting.rake`. Inside the existing `namespace :reporting do ... end` (after the `publish_anonymous_runs` task is fine), add:

```ruby
  desc "Enqueue SendToReportServiceJob for every Publishable with a publication_hash (clears backlog of failed/missing report-service publishes)"
  task republish_to_report_service: :environment do
    return unless ReportService.configured?

    [LightweightActivity, Sequence].each do |klass|
      scope = klass.where("publication_hash IS NOT NULL")
      total = scope.count
      puts "==> Enqueueing #{total} #{klass.name} jobs..."
      enqueued = 0
      scope.find_each(batch_size: 100) do |publishable|
        job = SendToReportServiceJob.new(klass.name, publishable.id, Time.now)
        Delayed::Job.enqueue(job, 0, 5.seconds.from_now)
        enqueued += 1
        putc "." if enqueued % 50 == 0
      end
      puts
      puts "    enqueued: #{enqueued}/#{total}"
    end
  end
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bundle exec rspec spec/libs/tasks/reporting_rake_spec.rb`
Expected: PASS (all examples, including the two new ones).

- [ ] **Step 5: Commit**

```bash
git add lib/tasks/reporting.rake spec/libs/tasks/reporting_rake_spec.rb
git commit -m "feat(report-service): add reporting:republish_to_report_service rake task"
```

---

## Task 5: Full-suite verification

**Files:** none

- [ ] **Step 1: Run the model specs touched by this change as a group**

Run: `bundle exec rspec spec/models/send_to_report_service_job_spec.rb spec/models/managed_interactive_spec.rb spec/models/mw_interactive_spec.rb spec/models/embeddable/multiple_choice_spec.rb spec/libs/tasks/reporting_rake_spec.rb`
Expected: all green.

- [ ] **Step 2: Run the full RSpec suite**

Run: `bundle exec rspec`
Expected: green (no regressions in unrelated files).

If anything fails outside the five touched files, investigate before continuing. Likely regression vector: another spec asserts on the presence of `authored_state` in a structure-doc-style hash. Most such tests will be in `spec/models/lightweight_activity_spec.rb` or `spec/models/sequence_spec.rb`, which call `serialize_for_report_service`. If found, update those tests to reflect the new contract (no `authored_state` for non-MC types).

- [ ] **Step 3: Manual smoke check via rails console**

If a Codespace Rails container is running, open a console and verify the new shape on a managed interactive that has authored state:

Run: `bundle exec rails console`
Then in the console:
```ruby
mi = ManagedInteractive.where.not(authored_state: nil).first
mi.report_service_hash.keys
# Expect: no :authored_state if the question isn't MC; :authored_state and possibly :multiple_answers if it is.
```

Exit the console.

- [ ] **Step 4: PR**

When all of the above is clean, open the PR using `gh pr create`. Description should reference the spec file (linked) and call out:

- The behavioral change for non-MC interactives (no more `authored_state` in the structure doc).
- The backward-compat retention of `authored_state` on MC (will be removed in a follow-up after portal-report's reader is fully rolled out).
- The new rake task and its filter (`publication_hash IS NOT NULL`).
- The improved failure logging in `SendToReportServiceJob`.
