# Question Gating: Authored Setting and Unlock Message

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-226

**Status**: **Closed**

## Overview

Authors can mark an interactive so that the questions after it on its Activity Player page, or only those in its own section, start disabled until that interactive unlocks them. This story adds the LARA side: the per-item authoring setting and banner text, their place in the activity JSON, and a new interactive-to-host `unlockQuestions` message in the interactive API, released as `lara-interactive-api` 1.15.0 and `interactive-api-host` 0.14.0.

Hazbot pages need students to run the Wildfire model before answering the questions about it. The feature is generic: any interactive that saves student work can hold back the questions below it, and the interactive itself decides when the student has done enough. The Activity Player side was built first as a demo (AP-76, activity-player PR #591) using a URL parameter and saved state as stand-ins; this story supplies the real authored setting and the real message, so that a later AP-76 pull request and Wildfire (WM-66) can code against them. Students see no change until the Activity Player reads the setting.

## Requirements

### Authored setting and JSON contract

- **R1.** `MwInteractive` and `ManagedInteractive` each store three new per-item fields:

  | Field | Type | Values |
  |---|---|---|
  | `question_gating` | string, never null | `"none"` (default), `"disable_following_on_page"` or `"disable_following_in_section"` |
  | `question_gating_locked_text` | string or null | banner text while the questions are locked; null when blank |
  | `question_gating_unlocked_text` | string or null | banner text after the item unlocks them; null when blank |

  Every existing item reads as `"none"` with both texts null.
- **R2.** Saving rejects a `question_gating` value outside the list. A blank or whitespace-only banner text is saved as null, so the JSON has one "empty" shape.
- **R3.** The activity JSON (and the sequence JSON, which embeds the same activity export) includes all three fields on every `MwInteractive` and `ManagedInteractive` embeddable, whatever the item's learner-state setting. The shape the Activity Player and Wildfire code against:

  ```json
  {
    "type": "ManagedInteractive",
    "ref_id": "693-ManagedInteractive",
    "name": "Wildfire Explorer",
    "is_hidden": false,
    "is_half_width": false,
    "question_gating": "disable_following_on_page",
    "question_gating_locked_text": "Run the Wildfire Explorer and Hazbot Analysis, then answer these questions!",
    "question_gating_unlocked_text": null,
    "column": "primary",
    "position": 2
  }
  ```

  (Other fields omitted.) Consumers treat a missing field, `null`, and an unknown `question_gating` value as `"none"`, and a missing, `null` or empty text as "use the default".
- **R4.** The fields survive every copy path: duplicating an item, page, activity or sequence, and export followed by import. Importing JSON without the fields (any older export) gives `"none"` and null texts. Importing `question_gating` as `null` or as a value this LARA does not know stores `"none"`, since import saves with validation off and a null would violate the column.
- **R5.** The section-authoring API (`update_page_item`) accepts the three fields, and the item JSON it returns includes them, so the edit form opens with the saved values.

### Authoring form

- **R6.** The Advanced Options tab of both interactive edit forms shows a "Question gating" select whenever the item saves learner state: for an iframe interactive, while "Enable save state" is checked (it appears and disappears with that checkbox, like the other state options); for a library interactive, when its library interactive enables learner state, whether or not the library interactive is customizable. Otherwise the select and texts are not shown, and the saved values are left as they are.
- **R7.** The control sits in a fieldset with the legend "Question Gating". The select is labeled "Locked until this interactive unlocks them" and has three options, in this order: "No questions" (`"none"`), "All questions after this on the page" (`"disable_following_on_page"`) and "Only questions after this in this section" (`"disable_following_in_section"`). The note under the select changes with the selected option and always says the interactive must support unlocking questions. For "No questions" it says nothing is locked. For each locking value it says which questions start locked in the Activity Player (for the page value, every question after the item including later sections; for the section value, only those in its section, with later sections open), and that in a two-column section every question in the other column counts as after this interactive, so a question meant to stay open belongs in a separate section.
- **R8.** While the select is on either locking value, two single-line text fields follow it: "Locked banner text" and "Unlocked banner text", each noting that leaving it blank uses the Activity Player's default. The fields hide while the select is on "No questions", keeping their saved values. LARA does not repeat the Activity Player's default wording.
- **R9.** The select and fields have visible labels tied to the controls, each note is tied to its control with `aria-describedby`, and the conditional fields follow the select in tab order.

### Interactive API

- **R10.** `IRuntimeClientMessage` gains `"unlockQuestions"`, with payload interface `IUnlockQuestionsMessage { restored?: boolean }`. `restored` is true when the unlock comes from the interactive's saved state at startup rather than from something the student just did; a host shows no "now unlocked" feedback for a restored unlock. The payload carries no rule, count or reason, and later versions may add optional fields.
- **R11.** Two capability flags, one per direction. `IHostFeatures` gains `questionGating?: IHostFeatureSupport`: a host that honors `unlockQuestions` sends `hostFeatures.questionGating = { version: "1.0.0" }` in `initInteractive`. `ISupportedFeatures` gains `questionGating?: boolean`: an interactive that can send `unlockQuestions` declares it in `supportedFeatures`, and a host locks questions only behind a gate whose interactive declared it, treating every other gate as `"none"`, so gating an interactive that cannot unlock never locks questions for good. LARA's own hosts (authoring preview, the legacy runtime) advertise neither and ignore the message.
- **R12.** `interactive-api-client` exports `unlockQuestions(options?: IUnlockQuestionsMessage)`, which posts `unlockQuestions` with the given payload (an empty object when called without one). It is fire-and-forget and does not check `hostFeatures`. Its doc comment states the contract: declare `questionGating: true` in `setSupportedFeatures`; send the message whenever the interactive's own unlock condition holds, with `restored: true` at startup from saved state and without it after the triggering event; repeats are harmless; unlocking is one-way within a page visit.
- **R13.** The message catalog (section 5, "Interactive → host") of `interactive-api-host/interactive-host-guide.md` lists `unlockQuestions`, saying the host may receive it at startup and more than once, should treat it as idempotent, need not persist it, shows no "now unlocked" feedback when `restored` is true, and locks questions only behind interactives that declared `supportedFeatures.questionGating`. The `supportedFeatures` row names question gating among the capabilities, and the capability-advertising row of section 6 names the `hostFeatures.questionGating` flag.
- **R14.** The testbed example interactive declares `questionGating: true` in its `supportedFeatures` and gets an "Unlock questions" fieldset that shows whether the host advertises `hostFeatures.questionGating`, with a "Restored" checkbox and a button that calls `unlockQuestions()` (passing `restored: true` when checked).

### Release

- **R15.** `@concord-consortium/lara-interactive-api` 1.15.0 and `@concord-consortium/interactive-api-host` 0.14.0 are published as their own release, nothing else bundled, with each `package.json` and `package-lock.json` in step. First `1.15.0-pre.0` and `0.14.0-pre.0` go out on the `beta` tag, so WM-66 can pin the client and be reviewed alongside this story (a later `-pre.N` if review changes the code), then the final versions from the same code. Only the final versions are tagged, as `interactive-api-client@v1.15.0` and `interactive-api-host@v0.14.0`; prereleases are for development and get no git tag. Doug publishes from a terminal, since npm login uses browser auth. *(partial: `1.15.0-pre.0` and `0.14.0-pre.0` were published on `beta` on 2026-10-07 from commit `3c866927`; the final versions wait on WM-66 review, see Not Yet Implemented.)*
- **R16.** Before publishing, the packages are verified against the Activity Player through yalc in a throwaway activity-player worktree branched from `AP-76-disabled-questions-demo`: the testbed's button unlocks the demo's gated questions, for both a page-wide gate and a section-only gate. None of that worktree's yalc changes or wiring are committed by this story. *(Done, and extended: the same worktree, changed to read the authored fields and follow the protocol, also ran an end-to-end check against the WM-66 Wildfire build, including AP-145's re-init fix for Wildfire's top-bar reload.)*

### Rollout

- **R17.** The authoring setting may go to staging but not to production LARA until the Activity Player release that reads it (the later AP-76 pull request) is out. The npm release does not depend on the LARA deploy. *(Open at close: production deploy waits on the AP-76 release.)*

## Technical Notes

- **Files.** Models: `app/models/question_gating.rb` (the shared concern: `VALUES`, `FIELDS`, validation, `before_save` normalization, `question_gating_hash`), included by `mw_interactive.rb` and `managed_interactive.rb`, whose `to_hash` merges the fields (carrying them into `duplicate`, the authoring and edit JSON and `ManagedInteractive#export`) and `MwInteractive#export`'s `only` list. Controllers: `api/v1/interactive_pages_controller.rb#data_update_params` and the legacy `mw_interactives_controller.rb` / `managed_interactives_controller.rb` permit lists. Forms: the shared `page-item-authoring/common/components/question-gating-options.tsx`, rendered by both customize forms, with spacing in `section-authoring/components/item-edit-dialog.scss`. Protocol: `interactive-api-shared/types.ts`, `interactive-api-client/api.ts`, `interactive-api-host/interactive-host-guide.md`.
- **Form submission.** `ItemEditDialog#handleSubmit` collects every named element of the form, so an unrendered field is simply absent from the update and the model keeps its value. A `<select>`'s `value` is submitted as a string without the boolean conversion checkboxes need. The form is hand-written React, not react-jsonschema-form.
- **Learner state.** `ManagedInteractive#enable_learner_state` proxies to the library interactive, so an admin can later turn learner state off for every item using it. The stored gating stays and is exported; the Activity Player ignores it on an item that does not save state, so no LARA-side cleanup is needed.
- **Cross-version import.** `ApplicationRecord.new` raises `ActiveModel::UnknownAttributeError` on an unknown key, and both models' `import` pass the hash straight through. Once staging runs this code, every activity it exports carries the new keys, so importing a staging export into a production LARA that lacks this code fails until production is deployed.
- **Import normalization.** Saving an imported `question_gating: nil` with `validate: false` raises `ActiveRecord::NotNullViolation` without the `before_save`, hence the import rule in R4.
- **Message timing.** The interactive normally sends `unlockQuestions` after it receives `initInteractive`. A post made before the connection opens is not lost: `iframe-phone`'s endpoint queues it until the parent's `hello`. In the end-to-end check, Wildfire's restored unlock arrived about 3 ms after its `supportedFeatures` declaration, so a host that switches to locked on the declaration shows the locked state for a frame; holding the loading state while the gate has saved state avoids that.
- **Release mechanics.** From `lara-typescript/`, `npm run build` produces both `dist` packages, which are published with `npm publish --tag beta --access public` for a prerelease (or the `publish:*` scripts, which rebuild first). The build needs `NODE_OPTIONS=--openssl-legacy-provider` on Node 17+. A consumer must pin a prerelease exactly, since a `^` range does not match one. The client's version also appears at runtime through `index.ts` reading `package.json`, so `package.json` stays the single source.
- **What "after" means.** The Activity Player decides reach, not LARA. In a full-width section, "after" is the questions below the gate. In a split (two-column) section, it is the questions below the gate in its own column plus every question in the other column, because the columns sit side by side and their relative heights change as the page reflows; a question above the gate in its own column stays open. `"disable_following_on_page"` continues through the page's later sections, and `"disable_following_in_section"` stops at the end of the gate's section.
- **Field names for consumers.** JSON: `question_gating`, `question_gating_locked_text`, `question_gating_unlocked_text` on the embeddable. Message: `unlockQuestions`, payload `IUnlockQuestionsMessage { restored?: boolean }`. Host flag: `hostFeatures.questionGating` (`IHostFeatureSupport`, version `"1.0.0"`). Interactive flag: `supportedFeatures.questionGating` (boolean). Client helper: `unlockQuestions(options?)`.
- **Merge note for the Activity Player.** AP-145 (re-init a self-reloading interactive with its latest state) and the later AP-76 pull request both edit the start of `IframeRuntime` in `iframe-runtime.tsx`, so whichever merges second needs a small manual merge there.

## Out of Scope

- The Activity Player reading the fields, listening for the message, honoring `restored` and `supportedFeatures.questionGating`, advertising `hostFeatures.questionGating`, and the package bumps (the later AP-76 pull request).
- Wildfire's unlock rule, declaring `supportedFeatures.questionGating` and sending the message (WM-66).
- Gating values beyond these three, including a gate that names some other section: items move and sections are deleted after authoring, so such a reference could not be kept reliable.
- An authored banner image (LARA has no image upload).
- Telling the interactive in `initInteractive` that it is a gate. It sends the message regardless; the host ignores it from items that do not gate.
- Showing the setting in LARA's section-authoring item list or preview.
- Making activity import tolerate unknown fields in general.
- Production deploy of LARA (see R17).

## Not Yet Implemented

- The final `lara-interactive-api` 1.15.0 and `interactive-api-host` 0.14.0 releases: the version bump, publish and the `interactive-api-client@v1.15.0` / `interactive-api-host@v0.14.0` tags. They wait until WM-66 has been reviewed against `1.15.0-pre.0`; if review changes the protocol, a `-pre.1` comes first (R15).

## Decisions

### Hide or disable the setting on items that do not save learner state?
**Context**: The story left this to the spec; the Activity Player ignores the setting on such items either way.
**Options considered**:
- A) Hide it, as the forms already hide "Hide Question Number" and "Save Answer History" when learner state is off.
- B) Show it disabled with an explanation.

**Decision**: A. It matches the existing learner-state options in both forms, and a hidden field is not submitted, so toggling "Enable save state" off and on does not lose the author's settings.

---

### Export the fields always, or only when not the default?
**Context**: An older LARA cannot import JSON carrying unknown keys, so always exporting means a staging export cannot be imported into production until production has this code.
**Options considered**:
- A) Always export all three fields.
- B) Export them only when `question_gating` is not `"none"` or a text is set.

**Decision**: A. One fixed shape is easier for the Activity Player, Wildfire and the report tools to rely on and to test, matches how every other per-item column exports, and the window is short: production follows the AP-76 release.

---

### Add a sender to the testbed example interactive?
**Context**: Nothing sends `unlockQuestions` until WM-66, so the client helper and the Activity Player wiring could not be exercised end to end without one.
**Options considered**:
- A) Add an "Unlock questions" button to the testbed (R14).
- B) Test with a throwaway page only.

**Decision**: A. The testbed exists to exercise host features, is deployed with the example interactives, and gives the later AP-76 pull request a sender for its sample activity before Wildfire ships.

---

### Should 1.15.0 / 0.14.0 go to the `beta` tag as `-pre.0` first?
**Context**: LARA-223 published `0.13.0-pre.0` to `beta` for AP-143 to verify before the final version.
**Options considered**:
- A) Publish the final versions directly after the yalc check.
- B) Publish `-pre.0` on `beta` first, then the final versions.

**Decision**: B (Doug Martin, 2026-10-07). A was chosen first, since the yalc check exercises the built packages before anything is published. B replaced it once WM-66 was built: a branch linked to yalc cannot be pushed, built in CI or reviewed, and a protocol change found in review then costs a `-pre.N` instead of another public minor version. Prereleases get no git tag.

---

### The authoring labels
**Context**: The wording the author sees is LARA-only, so it can change without touching the JSON contract.
**Options considered**:
- A) One long option label per value, such as "Disable the questions after this item on its page until this interactive unlocks them".
- B) A select label carrying the shared phrase, with short option labels.

**Decision**: B. The select reads "Locked until this interactive unlocks them: No questions / All questions after this on the page / Only questions after this in this section", the option wording suggested in PI feedback (Trudi Lord, 2026-10-07) except that Doug Martin changed "None" to "No questions" after seeing the form, so every option names which questions are locked. After seeing the form, the single shared note was also replaced by a hint per option (R7), since one note could not describe "No questions" or tell the two locking values apart, and the notes take the same style as the other explanatory text on the tab.

---

### Which reach values does the setting offer?
**Context**: The AP-76 demo first offered only the page-wide value; PI review asked for a way to lock only part of a page.
**Options considered**:
- A) Page only.
- B) Page, or the gate's own section.
- C) Page, or any section the author picks.

**Decision**: B (Doug Martin, with Trudi Lord agreeing, 2026-10-07). C would store a reference to another section, which breaks when items move or sections are deleted after authoring.

---

### How does the host tell a restored unlock from a new one?
**Context**: The AP-76 spec requires that a gate already unlocked when the page loads shows no banner and never shows the locked state. With the real message, a returning student's interactive sends `unlockQuestions` from saved state only after loading, so without help from the protocol the host would show the locked state, then "now unlocked", on every visit.
**Options considered**:
- A) Add `restored?: boolean` to `IUnlockQuestionsMessage`, set when the unlock comes from saved state at startup; the host shows no banner for it.
- B) Keep the payload empty and infer it in the Activity Player from timing or a saved-state hint.
- C) Accept the banner on return visits.

**Decision**: A (Doug Martin, 2026-10-07). It describes the moment, not the rule, so it keeps the rule out of the payload; B relies on timing, and C undoes a decision made for students.

---

### What stops a gate that cannot unlock from locking questions for good?
**Context**: An author could gate an interactive that predates WM-66, or any interactive that never calls `unlockQuestions()`, locking every question after it for every student.
**Options considered**:
- A) Add `ISupportedFeatures.questionGating?: boolean`; the host locks only behind a gate that declared it and treats every other gate as `"none"`.
- B) Leave it to authors and the form's note.

**Decision**: A (Doug Martin, 2026-10-07). It costs one optional boolean, follows the `focusProtocol` precedent, and turns the worst authoring mistake into a no-op.

---

### Tie each note to its control
**Context**: `Checkbox` puts its note inside its `<label>`, so a screen reader reads it with the control; a select's note sits outside its label.
**Options considered**:
- A) Tie each note with `aria-describedby`.
- B) Follow the `Checkbox` pattern.

**Decision**: A (R9); B would leave the select's note unannounced.

---

### Tell hosts that the message repeats
**Context**: Interactives send `unlockQuestions` at startup and again after the triggering event; a host author reading only the guide could treat a second unlock as an error or persist it.

**Decision**: The catalog row says the message can arrive at startup and repeatedly, is idempotent and is not persisted (R13).

---

### One shared component or a copy per form?
**Context**: Both customize forms need the same select, texts, labels and option list.
**Options considered**:
- A) One `QuestionGatingOptions` component used by both customize forms.
- B) Inline markup in each form, as the existing learner-state options are written.

**Decision**: A. The two forms would otherwise carry identical markup; the existing options differ per form (inherit/customize radios), this one does not.

---

### How the Ruby and TypeScript value lists stay in agreement
**Context**: The allowed values must appear in Ruby (validation) and TypeScript (the select); there is no shared source across the two.
**Options considered**:
- A) An rspec that reads the TS options and compares them with `QuestionGating::VALUES`.
- B) Send the allowed values from Rails in the edit JSON.
- C) Accept two lists.

**Decision**: A. One small test asserts the agreement; B adds an API field for a list that changes once a year.

---

### Normalize in `before_save` rather than reject at import
**Context**: Import saves with `validate: false`.
**Options considered**:
- A) `before_save` maps a missing, null or unknown `question_gating` to `"none"` and blank texts to `nil`; validation still rejects an unknown value on ordinary saves.
- B) Validation only.

**Decision**: A. Validation alone lets a null reach the not-null column and an unknown value into the database; normalizing at the point of save keeps the bad state from existing.

---

### Show the setting for a non-customizable library interactive
**Context**: The library interactive form returns early, with read-only values, for a library interactive that does not support customizing its advanced options, which would have hidden the setting even when learner state is on.
**Options considered**:
- A) Render the setting in that branch too, after "Link Saved Work From".
- B) Show it only for customizable library interactives.

**Decision**: A. Gating is a per-item setting rather than one of the inherited options that branch shows read-only, and R6 ties it only to learner state.

---

### An import test that could not fail
**Context**: The plan listed "import without the key saves `"none"`" among the examples that fail without the `before_save`, but the column default supplies `"none"` for an absent key whatever the model does.

**Decision**: The example was dropped from that list, and the default is covered by the new-record example, which fails if the migration default is removed.

---

### Testbed handlers
**Context**: tslint's `jsx-no-lambda` rejects inline arrow functions in JSX attributes, and `onClick={unlockQuestions}` would post the click event as the payload.

**Decision**: The testbed uses named `handleRestoredChange` and `handleUnlockQuestions` handlers.
