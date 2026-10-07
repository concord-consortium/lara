# Question Gating: Authored Setting and Unlock Message

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-226
**Repo**: https://github.com/concord-consortium/lara
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

Authors can mark an interactive so that the questions after it on its Activity Player page, or only those in its own section, start disabled until that interactive unlocks them. This story adds the LARA side: the per-item authoring setting and banner text, their place in the activity JSON, and a new interactive-to-host `unlockQuestions` message in the interactive API, released as `lara-interactive-api` 1.15.0 and `interactive-api-host` 0.14.0.

## Project Owner Overview

Hazbot pages need students to run the Wildfire model before answering the questions about it. The feature is generic: any interactive that saves student work can hold back the questions below it, and the interactive itself decides when the student has done enough. The Activity Player side was built first as a demo (AP-76, activity-player PR #591) using a URL parameter and saved state as stand-ins; this story supplies the real authored setting and the real message, so that a later AP-76 pull request and Wildfire (WM-66) can code against them.

Authors get a "Question Gating" choice (nothing, every question after the item on the page, or only those after it in its section) and two optional banner texts on an interactive's Advanced Options tab. Students see no change until the Activity Player reads the setting, so the authoring setting must not reach production LARA until that Activity Player release is out.

## Background

The cross-repo plan lives in the global oob note `disabled-question-sets/README.md`. The Activity Player decisions are recorded in the closed spec `specs/AP-76-disabled-questions-demo.md` in activity-player. The decisions this story must follow, settled there and in the story brief:

- The setting is an optional per-item string enum, `question_gating`, with `"none"` (the default, and the meaning of a missing field), `"disable_following_on_page"` and `"disable_following_in_section"` (only the questions after the item in its own section; added after PI feedback on the demo, activity-player `9bce645`). Later behaviors become new values, not new fields. The Activity Player treats a missing field, `null`, and any unknown value as `"none"`.
- Only interactives that save learner state can gate. The Activity Player ignores the setting on anything else.
- Locked and unlocked banner text are authored per item; the Activity Player supplies defaults when they are empty. There is no authored image.
- The unlock is a new typed runtime message with an `IHostFeatures` flag. The host only learns "unlocked" and whether that unlock was restored from saved state; the rule belongs to the interactive, which sends the message at startup from saved state as well as after the triggering event, so the host never persists unlock state.
- `customMessage` and an extended `navigation` message were considered and rejected.
- PI review approved the banner's position and wording, and set Wildfire's unlock rule ("ran the model and clicked Hazbot at least once"); the rule is WM-66's and never appears in the payload. The banner's styling (light blue while locked, green once unlocked) is settled and Activity Player-only.

In LARA, per-item settings such as `is_half_width` and `hide_question_number` are columns on the embeddable tables (`mw_interactives`, `managed_interactives`), authored in the React forms under `lara-typescript/src/page-item-authoring/`, saved through `Api::V1::InteractivePagesController#update_page_item`, and exported by each model's `export`. The activity JSON the Activity Player loads (`/api/v1/activities/:id.json`) is `LightweightActivity#export`, which reaches each item through `Section#export`, `PageItem#export` and `LaraSerializationHelper#export`; the item's fields sit on the embeddable object beside `type`, `ref_id`, `column` and `position`. LARA-190 (`8f960fd9`, interactive state history) added a per-item setting the same way and is the template for this one.

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

- **R6.** The Advanced Options tab of both interactive edit forms shows a "Question gating" select whenever the item saves learner state: for an iframe interactive, while "Enable save state" is checked (it appears and disappears with that checkbox, like the other state options); for a library interactive, when its library interactive enables learner state. Otherwise the select and texts are not shown, and the saved values are left as they are.
- **R7.** The control sits in a fieldset with the legend "Question Gating". The select is labeled "Locked until this interactive unlocks them" and has three options, in this order: "No questions" (`"none"`), "All questions after this on the page" (`"disable_following_on_page"`) and "Only questions after this in this section" (`"disable_following_in_section"`). The note under the select changes with the selected option and always says the interactive must support unlocking questions. For "No questions" it says nothing is locked. For each locking value it says which questions start locked in the Activity Player (for the page value, every question after the item including later sections; for the section value, only those in its section, with later sections open), and that in a two-column section every question in the other column counts as after this interactive, so a question meant to stay open belongs in a separate section.
- **R8.** While the select is on either locking value, two single-line text fields follow it: "Locked banner text" and "Unlocked banner text", each noting that leaving it blank uses the Activity Player's default. The fields hide while the select is on "No questions", keeping their saved values. LARA does not repeat the Activity Player's default wording.
- **R9.** The select and fields have visible labels tied to the controls, each note is tied to its control with `aria-describedby` (the existing `Checkbox` gets this for free by putting its note inside the label; a select's note sits outside it), and the conditional fields follow the select in tab order.

### Interactive API

- **R10.** `IRuntimeClientMessage` in `lara-typescript/src/interactive-api-shared/types.ts` gains `"unlockQuestions"`, with payload interface `IUnlockQuestionsMessage { restored?: boolean }`. `restored` is true when the unlock comes from the interactive's saved state at startup rather than from something the student just did; a host shows no "now unlocked" feedback for a restored unlock. The payload carries no rule, count or reason, and later versions may add optional fields.
- **R11.** Two capability flags, one per direction. `IHostFeatures` gains `questionGating?: IHostFeatureSupport`: a host that honors `unlockQuestions` sends `hostFeatures.questionGating = { version: "1.0.0" }` in `initInteractive`. `ISupportedFeatures` gains `questionGating?: boolean`: an interactive that can send `unlockQuestions` declares it in `supportedFeatures`, and a host locks questions only behind a gate whose interactive declared it, treating every other gate as `"none"`, so gating an interactive that cannot unlock never locks questions for good. LARA's own hosts (authoring preview, the legacy runtime) advertise neither and ignore the message.
- **R12.** `interactive-api-client` exports `unlockQuestions(options?: IUnlockQuestionsMessage)`, which posts `unlockQuestions` with the given payload (an empty object when called without one). It is fire-and-forget: no response, no promise, and it does not check `hostFeatures` (a host without support ignores the message). Its doc comment states the contract: declare `questionGating: true` in `setSupportedFeatures`; send the message whenever the interactive's own unlock condition holds, with `restored: true` at startup from saved state and without it after the triggering event; repeats are harmless; unlocking is one-way within a page visit.
- **R13.** The message catalog (section 5, "Interactive → host") of `interactive-api-host/interactive-host-guide.md` lists `unlockQuestions`, saying the host may receive it at startup and more than once, should treat it as idempotent, need not persist it, shows no "now unlocked" feedback when `restored` is true, and locks questions only behind interactives that declared `supportedFeatures.questionGating`. The `supportedFeatures` row names question gating among the capabilities, and the capability-advertising row of section 6 names the `hostFeatures.questionGating` flag.
- **R14.** The testbed example interactive (`example-interactives/src/testbed`) declares `questionGating: true` in its `supportedFeatures` and gets an "Unlock questions" fieldset that shows whether the host advertises `hostFeatures.questionGating`, with a "Restored" checkbox and a button that calls `unlockQuestions()` (passing `restored: true` when checked), so a host can be checked before WM-66 exists.

### Release

- **R15.** `@concord-consortium/lara-interactive-api` 1.15.0 and `@concord-consortium/interactive-api-host` 0.14.0 are published as their own release, nothing else bundled, with each `package.json` and `package-lock.json` in step and tags `interactive-api-client@v1.15.0` and `interactive-api-host@v0.14.0`. Publishing to npm waits for Doug's go-ahead.
- **R16.** Before publishing, the packages are verified against the Activity Player through yalc in a new activity-player worktree, `~/projects/activity-player.worktrees/LARA-226-integration`, branched from `AP-76-disabled-questions-demo`: the testbed's button unlocks the demo's gated questions, for both a page-wide gate and a section-only gate, once that worktree listens for `unlockQuestions` and advertises the flag. None of that worktree's yalc changes or wiring are committed by this story.

### Rollout

- **R17.** The authoring setting may go to staging but not to production LARA until the Activity Player release that reads it (the later AP-76 pull request) is out. The npm release does not depend on the LARA deploy.

## Technical Notes

- **Files.** Models: `app/models/mw_interactive.rb` (`to_hash`, `export`'s `only` list), `app/models/managed_interactive.rb` (`to_hash`, which `export` and `duplicate` use). Controllers: `app/controllers/api/v1/interactive_pages_controller.rb#data_update_params`; the legacy `mw_interactives_controller.rb` and `managed_interactives_controller.rb` permit lists (kept in step as LARA-190 did, though their edit pages are no longer linked from the section editor). Forms: `page-item-authoring/mw-interactives/{index,customize}.tsx`, `page-item-authoring/managed-interactives/{index,customize}.tsx`, `section-authoring/api/api-types.ts`, `section-authoring/api/mock-api-provider.ts`. Protocol: `interactive-api-shared/types.ts`, `interactive-api-client/api.ts`, `interactive-api-host/interactive-host-guide.md`.
- **Form submission.** `ItemEditDialog#handleSubmit` collects every named element of the form, so an unrendered field is simply absent from the update and the model keeps its value. A `<select>`'s `value` is submitted as a string without the boolean conversion checkboxes need.
- **Learner state.** `ManagedInteractive#enable_learner_state` proxies to the library interactive, so an admin can later turn learner state off for every item using it. The stored gating stays and is exported; the Activity Player ignores it on an item that does not save state, so no LARA-side cleanup is needed.
- **Cross-version import.** `ApplicationRecord.new` raises `ActiveModel::UnknownAttributeError` on an unknown key, and `MwInteractive.import` / `ManagedInteractive.import` pass the hash straight through (checked against the dev database with a throwaway `rails runner` script). Once staging runs this code, every activity it exports carries the new keys, so importing a staging export into a production LARA that lacks this code fails until production is deployed.
- **Verified with throwaway code.** Against the dev MySQL 5.6 database, temporarily added columns (`string`, not null, default `"none"`; two nullable `text`) gave every existing row `"none"`, round-tripped through a `to_hash`-built copy, `as_json(only: ...)` export and `MwInteractive.import`, and were removed again; saving an imported `question_gating: nil` with `validate: false` raised `ActiveRecord::NotNullViolation`, hence the import rule in R4. The protocol change (union member, empty payload interface, `IHostFeatures.questionGating`, `unlockQuestions()`) compiled under `tsc`, passed `tslint` (`no-empty-interface` is off), and a jest test saw `post("unlockQuestions", {})`; the code was then reverted. `LaraDuplicationHelper#get_copy` copies through each model's `duplicate`, which builds from `to_hash`.
- **Message timing.** The interactive normally sends `unlockQuestions` after it receives `initInteractive`, which carries its saved state and `hostFeatures`. A post made before the connection opens is not lost: `iframe-phone`'s endpoint queues it until the parent's `hello`. The Activity Player registers its runtime listeners before posting `initInteractive`, as it already does for `navigation`.
- **Release mechanics.** From `lara-typescript/`: `npm run publish:interactive-api-client` and `npm run publish:interactive-api-host` (each runs the full build, which needs `NODE_OPTIONS=--openssl-legacy-provider` on Node 17+), and the `:yalc` variants for local testing. The client's version also appears at runtime through `index.ts` reading `package.json`, so `package.json` stays the single source.
- **What "after" means.** The Activity Player decides reach, not LARA, but authors need it explained (R7). In a full-width section, "after" is the questions below the gate. In a split (two-column) section, it is the questions below the gate in its own column plus every question in the other column, wherever they sit, because the columns are side by side and their relative heights change as the page reflows; a question above the gate in its own column stays open. `"disable_following_on_page"` then continues through the page's later sections, and `"disable_following_in_section"` stops at the end of the gate's section. The Activity Player demo (activity-player `edd170b`) selects the section value with a `:section` suffix on a `ref_id` in `override:disableQuestionsAfter`; demo page 3 ("Model pinned on the right") shows the split-section rule and page 5 ("Section only") the section value.
- **Field names for consumers.** JSON: `question_gating`, `question_gating_locked_text`, `question_gating_unlocked_text` on the embeddable. Message: `unlockQuestions`, payload `IUnlockQuestionsMessage { restored?: boolean }`. Host flag: `hostFeatures.questionGating` (`IHostFeatureSupport`, version `"1.0.0"`). Interactive flag: `supportedFeatures.questionGating` (boolean). Client helper: `unlockQuestions(options?)`.

## Out of Scope

- The Activity Player reading the fields, listening for the message, honoring `restored` and `supportedFeatures.questionGating`, advertising `hostFeatures.questionGating`, and the package bumps (the later AP-76 pull request).
- Wildfire's unlock rule, declaring `supportedFeatures.questionGating` and sending the message (WM-66).
- Gating values beyond these three, including a gate that names some other section: items move and sections are deleted after authoring, so such a reference could not be kept reliable.
- An authored banner image (LARA has no image upload).
- Telling the interactive in `initInteractive` that it is a gate. It sends the message regardless; the host ignores it from items that do not gate.
- Showing the setting in LARA's section-authoring item list or preview.
- Making activity import tolerate unknown fields in general.
- Production deploy of LARA (see R17).

## Open Questions

### RESOLVED: Judgment call: hide or disable the setting on items that do not save learner state?
**Context**: The story leaves this to the spec; the Activity Player ignores the setting on such items either way.
**Options considered**:
- A) Hide it, as the forms already hide "Hide Question Number" and "Save Answer History" when learner state is off.
- B) Show it disabled with an explanation.

**Decision**: A. It matches the existing learner-state options in both forms, and a hidden field is not submitted, so toggling "Enable save state" off and on does not lose the author's settings.

---

### RESOLVED: Judgment call: export the fields always, or only when not the default?
**Context**: An older LARA cannot import JSON carrying unknown keys, so always exporting means a staging export cannot be imported into production until production has this code.
**Options considered**:
- A) Always export all three fields.
- B) Export them only when `question_gating` is not `"none"` or a text is set.

**Decision**: A. One fixed shape is easier for the Activity Player, Wildfire and the report tools to rely on and to test, matches how every other per-item column exports, and the window is short: production follows the AP-76 release. Recorded under Technical Notes so the deploy owner knows.

---

### RESOLVED: Judgment call: add a sender to the testbed example interactive?
**Context**: Nothing sends `unlockQuestions` until WM-66, so the client helper and the Activity Player wiring cannot be exercised end to end without one.
**Options considered**:
- A) Add an "Unlock questions" button to the testbed (R14).
- B) Test with a throwaway page only.

**Decision**: A. The testbed exists to exercise host features, is deployed with the example interactives, and gives the later AP-76 pull request a sender for its sample activity before Wildfire ships.

---

### RESOLVED: Low confidence: should 1.15.0 / 0.14.0 go to the `beta` tag as `-pre.0` first?
**Context**: LARA-223 published `0.13.0-pre.0` to `beta` for AP-143 to verify before the final version. Here the yalc check (R16) covers the Activity Player before anything is published, and WM-66 needs a stable client.
**Options considered**:
- A) Publish the final versions directly after the yalc check.
- B) Publish `-pre.0` on `beta` first, then the final versions.

**Decision**: A. The beta round in LARA-223 existed so AP-143 could test a published build over a long session; here the yalc check exercises the same built `dist/` packages in the Activity Player before anything is published, and WM-66 and the AP-76 pull request pin exact versions, so a pre-release would only add a second bump for them. Publishing still waits for Doug's go-ahead, who can ask for a beta then.

---

### RESOLVED: The authoring labels
**Context**: The wording the author sees is LARA-only, so it can change without touching the JSON contract.
**Options considered**:
- A) One long option label per value, such as "Disable the questions after this item on its page until this interactive unlocks them".
- B) A select label carrying the shared phrase, with short option labels.

**Decision**: B. The select reads "Locked until this interactive unlocks them: No questions / All questions after this on the page / Only questions after this in this section", the option wording suggested in PI feedback (Trudi Lord, 2026-10-07) except that Doug Martin changed "None" to "No questions" after seeing the form, so every option names which questions are locked, under a "Question Gating" legend, with the explanation in the note (R7).

---

### RESOLVED: Which reach values does the setting offer?
**Context**: The AP-76 demo first offered only the page-wide value; PI review asked for a way to lock only part of a page.
**Options considered**:
- A) Page only.
- B) Page, or the gate's own section.
- C) Page, or any section the author picks.

**Decision**: B (Doug Martin, with Trudi Lord agreeing, 2026-10-07). C would store a reference to another section, which breaks when items move or sections are deleted after authoring.

## Self-Review

Roles: Rails engineer, authoring front-end engineer, interactive developer (Wildfire, the consumer of the client helper), Activity Player host developer, WCAG accessibility expert, release engineer. Each finding below was checked against the code before being written down.

### WCAG Accessibility Expert

#### RESOLVED: The select's note was not tied to the control
`Checkbox` (`page-item-authoring/common/components/checkbox.tsx`) renders its `inputNote` inside the `<label>`, so a screen reader reads it with the control. A select's note sits outside its label, so following that pattern would leave the note unannounced. Fixed in R9: notes are tied with `aria-describedby`.

---

### Activity Player host developer

#### RESOLVED: The catalog row did not tell hosts the message repeats
R12 tells interactives to send `unlockQuestions` at startup and again after the triggering event, but R13 only asked for a catalog row. A host author reading the guide alone could treat a second unlock as an error or persist it. Fixed in R13: the row says it can arrive at startup and repeatedly, is idempotent, and is not persisted.

---

#### RESOLVED: The host cannot tell a restored unlock from a new one
The AP-76 spec requires that a gate already unlocked when the page loads shows no banner and never shows the locked state, and that the questions stay "disabled but not grayed" while the gate's state is loading (AP-76 requirements, Banner and Unlocking sections). The demo can do that because it reads the gate's saved state from Firestore. With the real message, a returning student's interactive sends `unlockQuestions` from its saved state only after it has loaded and received `initInteractive`, and a gate that is still locked sends nothing at all. So the host cannot tell "unlocked from saved state at startup" from "the student just unlocked it", and cannot tell "still loading" from "locked". Without help from the protocol, a returning student sees the locked state, then "The questions are now unlocked!" on every visit. This changes the message contract the Activity Player and WM-66 code against, so it is not fixed in place.

Suggested resolution, any of:
- A) Add an optional field to `IUnlockQuestionsMessage`, such as `restored?: boolean`, which interactives set when the unlock comes from saved state at startup; the host shows no banner for a restored unlock. It describes the moment, not the rule, so it does not break the "no rule in the payload" decision.
- B) Keep the payload empty and leave it to the Activity Player, for example treating an unlock that arrives before the gate's first `interactiveState` save of the visit as restored, or keeping the saved-state check as a "load hint" beside the message.
- C) Accept the banner on return visits and update the AP-76 decision.

Recommendation: A, together with A of the next finding. The Activity Player still has the gate's saved-state watch from the demo, so "no saved state" can show locked at once, while "has saved state" holds the not-grayed loading state until either a restored unlock or the gate's `supportedFeatures` arrives without one. B relies on timing, and C undoes a decision made for students.

**Decision**: A (Doug Martin, 2026-10-07): `IUnlockQuestionsMessage` gains `restored?: boolean` (R10, R12, R13).

---

### Interactive developer / Education Material Developer

#### RESOLVED: Gating an interactive that never sends the message locks the questions for good
Nothing in the protocol tells the host whether the gating interactive can unlock. An author who gates an interactive that predates WM-66 (the AP-76 spec notes that `wildfire.concord.org/index.html` serves `v1.6.0`), or any interactive that does not use `unlockQuestions()`, locks every question after it for every student, with no way out short of editing the activity. R7's note is the only safeguard. The protocol already has a pattern for this direction: interactives declare capabilities in `supportedFeatures` (`ISupportedFeatures.focusProtocol`, which the Activity Player reads in its `supportedFeatures` listener in `iframe-runtime.tsx`). Adding a capability changes the contract the other stories consume, so it is left open.

Suggested resolution, any of:
- A) Add `ISupportedFeatures.questionGating?: boolean`; the host locks questions only behind a gate whose interactive declared it, and treats every other gate as `"none"` (with the loading caveat that `supportedFeatures` arrives after the interactive loads, which ties into the finding above).
- B) Leave it to authors and the R7 note.

Recommendation: A. It costs one optional boolean, follows the `focusProtocol` precedent, and turns the worst authoring mistake (permanently locked questions) into a no-op.

**Decision**: A (Doug Martin, 2026-10-07): `ISupportedFeatures.questionGating?: boolean` (R11 to R14).
