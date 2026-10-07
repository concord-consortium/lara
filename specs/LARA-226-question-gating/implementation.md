# Implementation Plan: Question Gating: Authored Setting and Unlock Message

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-226
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

### Add the `unlockQuestions` message to the interactive API

**Summary**: The protocol half (R10 to R14), independent of the Rails and authoring work so it can be reviewed and yalc-tested first.

**Files affected**:
- `lara-typescript/src/interactive-api-shared/types.ts`: message name, payload interface, both capability flags
- `lara-typescript/src/interactive-api-client/api.ts`: `unlockQuestions()`
- `lara-typescript/src/interactive-api-client/api.spec.ts`: test
- `lara-typescript/src/interactive-api-host/interactive-host-guide.md`: catalog rows and flag
- `lara-typescript/src/example-interactives/src/testbed/app.tsx`: declare `questionGating`
- `lara-typescript/src/example-interactives/src/testbed/runtime.tsx`: "Unlock questions" fieldset

**Estimated diff size**: ~90 lines

`types.ts`:

```ts
export interface IHostFeatures extends Record<string, IHostFeatureSupport | string | undefined> {
  modal?: IHostModalSupport;
  getFirebaseJwt?: IHostFeatureSupport;
  // Set by hosts that honor the "unlockQuestions" message.
  questionGating?: IHostFeatureSupport;
  domain?: string;
}
```

In `ISupportedFeatures`, after `focusProtocol`:

```ts
  // When true, the interactive sends "unlockQuestions". Hosts lock questions only behind
  // interactives that declare it.
  questionGating?: boolean;
```

Append `"unlockQuestions"` to `IRuntimeClientMessage` after `"focusExit"`. Beside `INavigationOptions`:

```ts
// Sent by an interactive whose own condition for unlocking the questions it gates is met, both at
// startup from saved state and after the triggering event. The rule for unlocking belongs to the
// interactive, never to this payload.
export interface IUnlockQuestionsMessage {
  // True when the unlock comes from saved state at startup rather than from something the student
  // just did, so the host shows no "now unlocked" feedback.
  restored?: boolean;
}
```

`api.ts`, next to `setNavigation` (import `IUnlockQuestionsMessage` from `./types`):

```ts
/**
 * Tells the host that the questions this interactive gates can be unlocked. Declare
 * `questionGating: true` in `setSupportedFeatures`, then send this whenever the interactive's own
 * unlock condition holds: with `restored: true` at startup from saved state, and without it after
 * the triggering event. Repeats are harmless and unlocking is one-way for the page visit. Hosts that
 * do not set `hostFeatures.questionGating` ignore it.
 */
export const unlockQuestions = (options: IUnlockQuestionsMessage = {}) => {
  getClient().post("unlockQuestions", options);
};
```

`api.spec.ts`, after the `setNavigation` test:

```ts
it("supports unlockQuestions", () => {
  api.unlockQuestions();
  api.unlockQuestions({ restored: true });
  expect(mockedPhone.messages).toEqual([
    { type: "unlockQuestions", content: {} },
    { type: "unlockQuestions", content: { restored: true } }
  ]);
});
```

Host guide, section 5 "Interactive → host" table: the `supportedFeatures` row's list gains "question gating", and after `navigation`:

```
| `unlockQuestions` | The questions this interactive gates can be unlocked. May arrive at startup and more than once; treat it as idempotent and do not persist it. `restored: true` means the unlock came from saved state, so show no "now unlocked" feedback. Lock questions only behind interactives whose `supportedFeatures` declared `questionGating`, and advertise support with `hostFeatures.questionGating`. |
```

Section 6, the capability-advertising row's example list becomes `` (e.g. `modal`, `getFirebaseJwt`, `questionGating`) ``.

Testbed: `app.tsx` adds `questionGating: true` to its `setSupportedFeatures` call. `runtime.tsx` imports `unlockQuestions` with the other client imports, keeps a `restored` boolean in state, and adds after the Snapshot API fieldset:

```tsx
<fieldset>
  <legend>Question Gating</legend>
  <div>Host support: {initMessage.hostFeatures.questionGating
    ? `yes (version ${initMessage.hostFeatures.questionGating.version})` : "no"}</div>
  <label>
    <input type="checkbox" checked={restored} onChange={handleRestoredChange} /> Restored
  </label>
  <div><button onClick={handleUnlockQuestions}>Unlock questions</button></div>
</fieldset>
```

`handleRestoredChange` sets `restored` from the checkbox, and `handleUnlockQuestions` calls `unlockQuestions(restored ? { restored: true } : {})`. Both are named handlers because tslint's `jsx-no-lambda` rejects inline arrow functions, and the button cannot take `onClick={unlockQuestions}` directly, which would post the click event as the payload.

---

### Store and export question gating on interactives

**Summary**: The data half (R1 to R5): columns, validation and normalization, `to_hash` and `export`, and the permit lists, so the API and the activity JSON carry the fields before any form shows them.

**Files affected**:
- `db/migrate/<timestamp>_add_question_gating_to_interactives.rb`: new
- `db/schema.rb`: the six new columns only
- `app/models/question_gating.rb`: new concern
- `app/models/mw_interactive.rb`, `app/models/managed_interactive.rb`: include the concern, `to_hash`, MW `export`
- `app/controllers/api/v1/interactive_pages_controller.rb`: `data_update_params`
- `app/controllers/mw_interactives_controller.rb`, `app/controllers/managed_interactives_controller.rb`: permit lists
- `spec/support/shared_examples/question_gating.rb`: new, the `question gating` examples both model specs include
- `spec/models/mw_interactive_spec.rb`, `spec/models/managed_interactive_spec.rb`, `spec/controllers/api/v1/interactive_pages_controller_spec.rb`: tests

**Estimated diff size**: ~220 lines

Migration:

```ruby
class AddQuestionGatingToInteractives < ActiveRecord::Migration[8.0]
  def change
    [:mw_interactives, :managed_interactives].each do |table|
      add_column table, :question_gating, :string, null: false, default: "none"
      add_column table, :question_gating_locked_text, :text
      add_column table, :question_gating_unlocked_text, :text
    end
  end
end
```

Run it in the dev container (`docker compose run --rm app bundle exec rails db:migrate`) and keep only the six column lines and the schema version in the `db/schema.rb` diff; LARA-190's regeneration rewrote 159 unrelated lines.

`app/models/question_gating.rb`:

```ruby
# Per-item "questions after this item start locked" setting (page-wide or the item's own section), read by
# the Activity Player from the activity export. Consumers treat a missing, null or unknown value as "none".
module QuestionGating
  extend ActiveSupport::Concern

  NONE = "none"
  VALUES = [NONE, "disable_following_on_page", "disable_following_in_section"].freeze
  TEXT_FIELDS = [:question_gating_locked_text, :question_gating_unlocked_text].freeze
  FIELDS = [:question_gating, *TEXT_FIELDS].freeze

  included do
    validates :question_gating, inclusion: { in: VALUES }
    # before_save, not before_validation: import saves with validate: false.
    before_save :normalize_question_gating
  end

  def question_gating_hash
    FIELDS.index_with { |field| self[field] }
  end

  private

  def normalize_question_gating
    self.question_gating = NONE unless VALUES.include?(question_gating)
    TEXT_FIELDS.each { |field| self[field] = nil if self[field].blank? }
  end
end
```

Models: `include QuestionGating` beside `include BaseInteractive`. `to_hash` in both ends with `}.merge(question_gating_hash)`, which carries the fields into `duplicate`, `to_authoring_hash`, the edit JSON (`embeddable_to_edit_hash`) and `ManagedInteractive#export`. `MwInteractive#export` adds `*QuestionGating::FIELDS` to its `only:` list. Imports need nothing new: `import` builds with `new`, and `before_save` maps a missing, null or unknown value to `"none"`.

Controllers: add `:question_gating, :question_gating_locked_text, :question_gating_unlocked_text` to `data_update_params` and to both legacy permit lists.

Tests:
- Both model specs: the `#to_hash` expected hashes gain the three fields, and both include `it_behaves_like "a question gating interactive"` from the shared examples, in which `#duplicate` copies a gated item with both texts; `#export` includes the fields (MW gets an `#export` example, it has none); a new `question gating` block checks the default `"none"` on a new record, that `save` fails on `"sometimes"`, that blank and whitespace texts save as `nil` while `"Locked!"` is kept, and that `import` of a hash with `question_gating: nil` and with `"disable_following_in_activity"` (a value this LARA does not know) each saves `"none"` (without the `before_save` the first raises `NotNullViolation` and the second stores the unknown value). An import without the key gets `"none"` from the column default, which the new-record default example already covers.
- `LaraSerializationHelper` round trip, in the shared examples so both models run it: export a gated item through the helper and import it, asserting all three fields survive.
- Controller spec: an `update_page_item` example for an `MwInteractive` sets `question_gating` and a locked text, and asserts the stored values and the returned `data`.

---

### Author question gating in the interactive edit forms

**Summary**: The authoring half (R6 to R9): one shared component rendered in both Advanced Options tabs.

**Files affected**:
- `lara-typescript/src/page-item-authoring/common/components/question-gating-options.tsx`: new
- `lara-typescript/src/page-item-authoring/common/components/question-gating-options.spec.tsx`: new
- `lara-typescript/src/section-authoring/components/item-edit-dialog.scss`: `.question-gating-text` spacing
- `lara-typescript/src/page-item-authoring/mw-interactives/customize.tsx`: render inside `renderInteractiveStateOptions`
- `lara-typescript/src/page-item-authoring/managed-interactives/customize.tsx`: render when `libraryInteractive.enable_learner_state`
- `lara-typescript/src/page-item-authoring/mw-interactives/customize.spec.tsx`, `managed-interactives/customize.spec.tsx`: new, when each form shows the setting
- `lara-typescript/src/page-item-authoring/mw-interactives/index.tsx`, `managed-interactives/index.tsx`: interface fields
- `lara-typescript/src/section-authoring/api/mock-api-provider.ts`: mock item data
- `spec/models/question_gating_options_agreement_spec.rb`: new

**Estimated diff size**: ~200 lines

The component:

```tsx
import * as React from "react";
import { useState } from "react";

export type QuestionGating = "none" | "disable_following_on_page" | "disable_following_in_section";

export const QUESTION_GATING_OPTIONS: Array<{ value: QuestionGating, label: string }> = [
  { value: "none", label: "None" },
  { value: "disable_following_on_page", label: "All questions after this on the page" },
  { value: "disable_following_in_section", label: "Only questions after this in this section" }
];

interface Props {
  questionGating?: string | null;
  lockedText?: string | null;
  unlockedText?: string | null;
}

export const QuestionGatingOptions: React.FC<Props> = ({ questionGating, lockedText, unlockedText }) => {
  const [gating, setGating] = useState(questionGating || "none");
  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => setGating(e.target.value);

  return (
    <fieldset>
      <legend>Question Gating</legend>
      <label htmlFor="question_gating">Locked until this interactive unlocks them</label>
      <select id="question_gating" name="question_gating" value={gating} onChange={handleChange}
        aria-describedby="question_gating_note">
        {QUESTION_GATING_OPTIONS.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
      <div id="question_gating_note" className="inputNote">
        In the Activity Player, the chosen questions start locked until this interactive unlocks them.
        In a two-column section, every question in the other column counts as after this interactive,
        so put a question that should stay open in a separate section. The interactive must support
        unlocking questions.
      </div>
      {gating !== "none" && <>
        <div className="question-gating-text">
          <label htmlFor="question_gating_locked_text">Locked banner text</label>
          <input type="text" id="question_gating_locked_text" name="question_gating_locked_text"
            defaultValue={lockedText || ""} aria-describedby="question_gating_text_note" />
        </div>
        <div className="question-gating-text">
          <label htmlFor="question_gating_unlocked_text">Unlocked banner text</label>
          <input type="text" id="question_gating_unlocked_text" name="question_gating_unlocked_text"
            defaultValue={unlockedText || ""} aria-describedby="question_gating_text_note" />
        </div>
        <div id="question_gating_text_note" className="inputNote">
          Leave a banner text blank to use the Activity Player's default.
        </div>
      </>}
    </fieldset>
  );
};
```

Each banner text field sits in a `.question-gating-text` wrapper, which `item-edit-dialog.scss` gives a 15px top margin so the fields are spaced like the rest of the dialog.

Wiring: both interfaces gain `question_gating?: string; question_gating_locked_text?: string | null; question_gating_unlocked_text?: string | null;`. Each customize form renders `<QuestionGatingOptions questionGating={...} lockedText={...} unlockedText={...} />` from its interactive prop: in the MW form as the last element of `renderInteractiveStateOptions` (so it follows "Enable save state"), in the managed form through a `renderQuestionGatingOptions()` helper that renders it only when `libraryInteractive.enable_learner_state`, placed after "Save Answer History" and also in the early return for a non-customizable library interactive (after "Link Saved Work From"), since gating is a per-item setting rather than one of the inherited options that branch shows read-only. `ItemEditDialog#handleSubmit` needs no change: the select's value goes through its `default` branch as a string, and unrendered fields are absent from the update. `mock-api-provider.ts` gives its interactive items `question_gating: "none"`.

`question-gating-options.spec.tsx` (React Testing Library inside a `<form>`, reading `form.elements`):
- `null` gating shows "None" and submits only `question_gating=none`, with no text inputs.
- Changing the select to each locking value shows both inputs prefilled from the props, and the form submits all three fields; changing back to "None" removes the texts from the submission.
- The select is found by its label and has `aria-describedby="question_gating_note"`, and that element exists and mentions the other column.

The customize specs check that the MW form shows the select, with its saved value, only while "Enable save state" is checked and that it appears and disappears with the checkbox, and that the managed form shows it only when the library interactive enables learner state, for customizable and non-customizable library interactives alike.

`question_gating_options_agreement_spec.rb` reads `question-gating-options.tsx`, collects the `value: "..."` entries of `QUESTION_GATING_OPTIONS`, and expects them to equal `QuestionGating::VALUES`, so the two lists cannot drift.

---

### Release lara-interactive-api 1.15.0 and interactive-api-host 0.14.0

**Summary**: R15 and R16. The version bump is its own commit; publishing happens after the Activity Player check and Doug's go-ahead.

**Files affected**:
- `lara-typescript/src/interactive-api-client/package.json`, `package-lock.json`: `1.14.0` to `1.15.0`
- `lara-typescript/src/interactive-api-host/package.json`, `package-lock.json`: `0.13.0` to `0.14.0`

**Estimated diff size**: ~8 lines

Before the bump commit, check against the Activity Player (nothing from this is committed to either repo):

```bash
git -C ~/projects/activity-player worktree add ~/projects/activity-player.worktrees/LARA-226-integration \
  -b LARA-226-integration AP-76-disabled-questions-demo
cd ~/projects/activity-player.worktrees/LARA-226-integration && source ~/.nvm/nvm.sh && nvm use && npm install
# from lara-typescript/, after each LARA change:
NODE_OPTIONS=--openssl-legacy-provider npm run publish:interactive-api-client:yalc
NODE_OPTIONS=--openssl-legacy-provider npm run publish:interactive-api-host:yalc
# in the worktree:
npx yalc add @concord-consortium/lara-interactive-api @concord-consortium/interactive-api-host
```

In the worktree, add a throwaway `addListener("unlockQuestions", ...)` beside the `navigation` listener in `iframe-runtime.tsx` that unlocks the gate through the demo's provider (with no unlocked banner when `restored` is true), and `questionGating: { version: "1.0.0" }` in `hostFeatures`. No built-in sample embeds the testbed, so in the worktree point the gating `MwInteractive` on page 1 and on page 5 ("Section only") of `src/data/version-2/sample-new-sections-disabled-questions.json` at `http://localhost:8888/testbed/index.html` (served by `npm run example-interactives` from `lara-typescript/`). The testbed never saves state, so the demo's saved-state stand-in cannot unlock it and only the message can. Run the dev server on port 8081 and open `?activity=sample-disabled-questions&preview&override:disableQuestionsAfter=<page 1 ref_id>,<page 5 ref_id>:section`: the testbed shows "Host support: yes (version 1.0.0)", and its button unlocks the questions below on page 1 and the rest of the gate's section on page 5; with "Restored" checked the questions unlock without the unlocked banner. Then confirm `tsc` in the worktree resolves `unlockQuestions`, `IUnlockQuestionsMessage`, `IHostFeatures.questionGating` and `ISupportedFeatures.questionGating` from the yalc packages. Ask Doug before removing the worktree.

Then bump both packages (`npm version --no-git-tag-version 1.15.0` in the client folder and `0.14.0` in the host folder, which updates each lock file), commit, and on Doug's go-ahead publish from `lara-typescript/` with `npm run publish:interactive-api-client` and `npm run publish:interactive-api-host`, and tag `interactive-api-client@v1.15.0` and `interactive-api-host@v0.14.0`.

## Open Questions

### RESOLVED: Judgment call: one shared component or a copy per form?
**Options considered**:
- A) One `QuestionGatingOptions` component used by both customize forms.
- B) Inline markup in each form, as the existing learner-state options are written.

**Decision**: A. The two forms would otherwise carry identical markup, labels and option lists, which is the duplication reviewers flag; the existing options differ per form (inherit/customize radios), this one does not.

---

### RESOLVED: Judgment call: how the Ruby and TypeScript value lists stay in agreement
**Context**: The allowed values must appear in Ruby (validation) and TypeScript (the select); there is no shared source across the two.
**Options considered**:
- A) An rspec that reads the TS options and compares them with `QuestionGating::VALUES`.
- B) Send the allowed values from Rails in the edit JSON.
- C) Accept two lists.

**Decision**: A. One small test asserts the agreement; B adds an API field for a list that changes once a year.

---

### RESOLVED: Judgment call: normalize in `before_save` rather than reject at import
**Options considered**:
- A) `before_save` maps a missing, null or unknown `question_gating` to `"none"` and blank texts to `nil`; validation still rejects an unknown value on ordinary saves.
- B) Validation only.

**Decision**: A. Import saves with `validate: false`, so validation alone lets a null reach the not-null column (verified against the dev database) and an unknown value into the database; normalizing at the point of save keeps the bad state from existing.

## Self-Review

Roles: commit reviewer, test writer, Rails engineer, interactive developer, operator. Claims about the proposed code were checked by building it as throwaway code: the concern with temporary columns in the dev database (validation rejects `"sometimes"`; `before_save` maps an imported `nil` and an unknown value to `"none"` and a whitespace text to `nil`; a `LaraSerializationHelper` export and import and a `to_hash` copy keep all three fields), the component under React Testing Library, and the protocol change under `tsc`, `tslint` and jest. All of it was removed afterwards.

### Test writer

#### RESOLVED: One planned import example could not fail
The plan listed "import without the key saves `"none"`" among the examples that fail without the `before_save`. It does not: the column default supplies `"none"` for an absent key whatever the model does. Fixed in place: the example is dropped from that list, and the default is covered by the new-record example, which fails if the migration default is removed.

---

### Commit reviewer

#### RESOLVED: The Activity Player check had no page with the testbed as its gate
The release step asked for a sample page gated by the testbed, but no Activity Player sample embeds it, and a gate that saves state would let the demo's saved-state stand-in unlock without the message. Fixed in place: the step names the demo sample to repoint in the throwaway worktree, and why the testbed proves the message path.

---

### Interactive developer

#### RESOLVED: Sending before the connection opens
A Wildfire developer might call `unlockQuestions()` before `initInteractive` arrives. `iframe-phone`'s endpoint queues posts in `postMessageQueue` until the parent's `hello`, so the message is not lost. Recorded in the requirements' "Message timing" note; no plan change.

---

### Operator

Checked with no finding: the migration is reversible through `change`; adding a defaulted not-null column copies the table on older MySQL but `mw_interactives` and `managed_interactives` are small; `npm version --no-git-tag-version` in each package folder changes only the version line of its `lockfileVersion: 1` lock file (run against copies with npm 10.9.2), matching the LARA-223 bump.
