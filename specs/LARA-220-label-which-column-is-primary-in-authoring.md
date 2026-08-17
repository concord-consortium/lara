# Label which column is primary in authoring

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-220

**Status**: **Closed**

## Overview

In a two-column section, one column is the "primary" column and the other is the "secondary" column, and that distinction drives several runtime behaviors (which column can stick to the top, which one students can collapse, question numbering order). The LARA section editor never says which is which, so authors have to guess. This story adds a visible Primary/Secondary label to each column in the section editor and makes the Layout dropdown self-explanatory, with no data model or Activity Player changes.

The author-visible rule is: **primary is on the left for `60-40` and `70-30`, and on the right for `40-60`, `30-70`, `responsive-30-70`, and `responsive-50-50`.** Note that "primary" is usually but not always the wider column: in `responsive-50-50` the columns are equal width and the primary is simply the right-hand one.

## Requirements

### Column labels

- In a two-column layout, each column in the section editor displays a visible label whose text content is exactly `Primary column` or `Secondary column`.
- The label is styled **12px, bold, uppercase, `--dark-teal`**. The DOM text node stays sentence case and CSS applies `text-transform: uppercase`, so the label renders as `PRIMARY COLUMN` while its text content, and therefore its accessible name, remains `Primary column`. Both the visible text and the accessible name derive from one string, which is why the Accessibility requirements mandate `aria-labelledby` over `aria-label`.
- The label reflects the same primary/secondary derivation the Activity Player uses.
- The label renders in a header row inside the column's grid container, positioned *before* the `<Droppable>` so it sits outside the drag-and-drop subtree.
- The header row spans the full width of the column's grid row via the existing `full-row` class (`grid-column: span 10`). `.edit-page-grid-container` is a ten-track grid and that rule applies to the column container as well as the section container, so a header without an explicit span auto-places into track 1 of 10 and wraps to two lines in every layout except `responsive-50-50`.
- Changing the Layout dropdown updates the labels immediately, without a page reload.
- In single-column layouts (`full-width`, `responsive-full-width`) no column label is shown, and the column renders no header row.
- **When the stored layout is not one of the eight known values, no column label is shown**, even though two columns render. An empty-string layout falls in this bucket.
- Labels are read-only. They report the derivation; they are not a control.
- Adding the header must not change the drop-zone geometry. The column container needs `grid-template-rows: min-content 1fr` (**not** `align-content: start`, which shrinks the shorter column's drop target by roughly 39%).

### Layout dropdown

- Each option displays the raw stored token followed by a parenthetical hint. For two-column layouts the hint states which side the primary column is on; for the two single-column layouts it reads `(single column)`.
- The stored `section.layout` value is unchanged: only the option's display text changes, never its `value`.
- **The dropdown gains no fallback option for unrecognized stored layouts.** Its behavior for such a layout is unchanged from today: it displays `full-width`.
- The component must not normalize an unrecognized or empty layout to `"full-width"`. Rewriting the `layout` value itself would collapse a section that renders two columns down to one, because the two-column guard is `layout !== "full-width" && layout !== "responsive-full-width"`, which an empty string passes.

### Duplicate element IDs (pre-existing bug, fixed here)

- `section_layout` and `toggle-secondary-column` must be unique per section, derived from the section ID.
- Clicking a section's "Allow student to hide secondary column" label must toggle *that* section's checkbox, and its "Layout:" label must focus *that* section's dropdown. Before this fix both resolved to the first section on the page.
- Any ID introduced by the new column header must be unique per **column**, derived from the section ID and the column number. Per-section uniqueness is not sufficient, since a section renders two headers.

### Non-regression

- No change to the section data model, the authoring API payloads, `Section#export`, or the exported activity JSON.
- No migration, and no change in how any existing published activity renders in the Activity Player.
- The "Allow student to hide secondary column" checkbox keeps its current wording, position, behavior, and disabled-for-full-width logic. Only its `id` changes.
- Drag and drop within a column is unaffected.

### Accessibility

- In a two-column layout **with a recognized layout**, each column container carries `role="group"` and `aria-labelledby` pointing at the ID of its own header label.
  - The ID must be unique per column. An ID that is merely unique per section gives both columns the accessible name of the first header, so no column is announced as Secondary.
  - Use `aria-labelledby` rather than `aria-label`, so the visible and announced labels cannot drift apart in a later edit.
  - Use `role="group"`, not `role="region"`. A region is a landmark, and two landmarks per section across every section on a page would swamp the landmark list.
  - The header itself is a plain `<div>`. Do **not** use a heading, and do **not** use `<header>`: a `<header>` element is a `banner` landmark unless it descends from `article`, `aside`, `main`, `nav`, or `section`, and `role="group"` on the parent does not exempt it. `<h4>` would sit at the same outline level as the section item titles nested inside the column, and `<h3>` collides with the section name.
  - A visible text node above a plain `<div>` is **not** sufficient: it produces loose `generic` text with no association to the column's contents.
  - Single-column layouts render no header and therefore no group. **Unrecognized layouts likewise render no header and therefore no group**, even though they render two columns. The `role` and `aria-labelledby` must be tied to whether the header actually rendered, not to whether the layout is two-column.
- The column label uses **`--dark-teal` `#016082`** on the column grid's `--ltr-teal` `#cdebf2` background, measured at **5.59:1**, passing WCAG AA. Do **not** use `--teal` `#0592af`, which measures 2.92:1 and fails at any text size. The label is 12px bold, below the WCAG large-text threshold, so 4.5:1 applies rather than 3:1.
- The page emits no duplicate element IDs for section controls.

### Testing

- Component tests cover the label text for all eight layouts, the absence of labels on single-column layouts, the absence of labels for an unrecognized layout and for an empty-string layout (in both cases asserting that two columns still render, so the test cannot pass merely because nothing rendered), and live updates when the dropdown changes. Assert **by accessible role and name**, not by text content, so the test fails if the `aria-labelledby` association is dropped.
- Unit tests cover the layout-to-display-text map and the layout-to-primary-side helper.
- A regression test covers the duplicate-ID fix.
- **Manual check, not automated**: view a section at a 1200px viewport and confirm the header's two-line wrap matches the accepted behavior.

## Technical Notes

### Where "primary" comes from

`primary` and `secondary` are stored per page item (`page_items.column`), not per section. Which rendered column is primary is derived from the section's `layout` string, and the derivation is duplicated in three places: `columnValueForIndex` in the LARA authoring UI, `primary_right_layouts` in `app/models/interactive_page.rb`, and `leftPrimary` in the Activity Player's `section.tsx`.

**The three sources agree only for the eight enum values.** For a layout string outside the enum they diverge: LARA's authoring UI and Ruby export both fall through to primary-on-left, while the Activity Player's `leftPrimary` is a whitelist of exactly `60-40` and `70-30`, so it puts primary on the right for everything else. That divergence is why the column label is suppressed for unrecognized layouts rather than derived.

### What primary/secondary actually controls

Sticky/pin behavior (only the primary column can stick, and only when shorter than the window), student collapse (only the secondary column is collapsible), display mode (stacked/carousel applies to the secondary column), question numbering order (when primary is on the right, LARA emits secondary-column items first so numbering follows visual reading order), and responsive sizing (the secondary column is the fixed-width one).

### Pure helpers belong in util/

Both pure pieces live in `section-authoring/util/`, the established home for section and layout logic, with a co-located `.spec.ts`. Do **not** put author-facing display strings in `api/api-types.ts`, which is a types-and-enums module.

Type the helper's layout parameter as `string` rather than `SectionLayouts`. A helper typed to the closed enum makes the unrecognized-layout branch dead code by construction and its unit test unwritable without a cast. Precedent exists in the same file: `classNameForItem` is typed `SectionLayouts` yet guards at runtime against values outside it.

The extracted helper serves two callers with different needs. `AuthoringSection` still needs a `SectionColumns` value for `getColumnItems` and `addItem` on every layout, including unrecognized ones, so the existing primary-on-left fallback must be preserved there. The **label** must not use that fallback. Keeping the two concerns separate avoids silently repartitioning existing items.

### SectionColumn needs a new prop

Neither existing prop can express "no label": `column` is `PRIMARY` for both single-column layouts, and `className` is overloaded (`section-responsive-fluid` means both "the only column of a responsive full-width section" and "the right column of a responsive 30-70 section"). **Do not key any behavior off these class names.**

### Narrow-viewport effect on the section header

The parentheticals widen the dropdown from 164px to 258px. **Nothing is clipped** (`scrollWidth === clientWidth` at every width down to 1000px); the degradation is wrapping. The change moves the wrap threshold from roughly 1140px to roughly 1210px, so in that ~70px band the header grows from 40px to 57px: the checkbox label wraps and DELETE drops onto its own line. Above ~1220px there is no difference; below ~1140px the header already wraps today. This is an accepted cosmetic consequence, not a defect.

### Other notes

- `.teal-label` is an orphan: defined once and referenced nowhere. The live precedent for structural chrome is `.sectionItemMenu` (12px uppercase). Sentence case is reserved for form-control labels.
- `Section::LAYOUT_OPTIONS` in `app/models/section.rb` is stale (it predates the responsive layouts) but is consumed only by the legacy Rails-rendered runtime, not the React editor.
- `AuthoringSection` needs **no hand-written mocks**: `APIContainer` falls back to `mock-api-provider` whenever no `host` prop is given, so wrapping the component is the entire harness.
- The `data-testid` values passed to `SectionColumn` never reached the DOM, because the component destructures only its declared props.
- No i18n infrastructure exists in `lara-typescript`, so hardcoded English strings are consistent with the codebase.

## Out of Scope

- Letting authors choose which column is primary (unbundling "primary" from the layout). Needs a new section field, a migration, authoring API and export changes, and Activity Player changes in roughly half a dozen places.
- An explicit per-section "stick to top" control (Auto / Primary / Secondary / None).
- Any change to the Activity Player, including the AP-129 sticky-column fix.
- Anything to do with Storybook: adding or updating stories, fixing the swapped single-column stories, or retiring the now-unused Storybook setup and its deploy workflow.
- Changing the sticky, collapse, carousel, question-numbering, or responsive-sizing behaviors themselves.
- Updating the stale `Section::LAYOUT_OPTIONS` constant.
- Renaming the "primary"/"secondary" values stored in `page_items.column`.
- The legacy Rails-rendered section authoring UI, if any remains.
- Any in-editor explanation of what primary/secondary controls: no tooltip, info popover, or help text.
- Updating the authoring help doc. A follow-up task, not a code change.
- Converting the `can_collapse_small` checkbox from `defaultChecked` to a controlled input.
- Converting the layout `<select>` from `defaultValue` to a controlled input. The `<select>` is uncontrolled while the columns derive from `layout` state, so a prop change without a remount would leave the dropdown showing the old layout. No reachable path was found in the current app: `mutationsOpts` supplies only `onSuccess`, so a failed mutation neither refetches nor rolls back, and section move and copy change the React `key`, forcing a remount.
- Fixing the Activity Player's dead `responsive-2-column` branch.
- Making the dead `data-testid` props on `SectionColumn` actually render, except where the new tests need them.

## Not Yet Implemented

- **Authoring help-doc note describing what primary/secondary controls** — deferred as a non-code follow-up. Split deliberately: write now only the facts that are safe regardless of AP-129 (what primary and secondary are, which layouts put primary on which side, that only the secondary column can be collapsed or use carousel mode, that question numbering follows visual reading order). Add the sticky paragraph as a separate edit once AP-129's PR #582 merges and the rule settles. No ticket filed.
- **In-editor tooltip or info popover explaining what primary/secondary controls** — deferred to a future story. Not blocked by tooling (`react-tooltip` 4.5.1 is already installed and sets `aria-describedby`), but any honest explanation is conditional and multi-clause, and AP-129 is scheduled to change the sticky rule.
- **Letting authors choose which column is primary** — the second half of the reporter's original request, explicitly placed out of scope. A Jira search across LARA and AP confirmed no follow-up ticket exists. No tickets were filed.
- **Storybook retirement** — `.github/workflows/deploy-storybook.yml` still builds and deploys `src/stories/` to S3 on every push, so this is live infrastructure rather than dead files. Retiring it means removing the workflow, the stories directory, and the four `@storybook/*` devDependencies together. The swapped single-column stories in `authoring-section.stories.tsx` (a copy/paste bug assigning `FullWidth.args` twice) are left alone as pre-existing.
- **No separate Jira bug for the duplicate-ID defect** — fixed inside this story's PR as a `fix:` commit, per team practice. The PR description carries the callout so QA tests it.

## Decisions

### What exactly should each column label say?

**Context**: The ticket says add a "Primary" / "Secondary" label. On its own that is accurate but still jargon: it names the distinction without explaining why an author should care.

**Options considered**:
- A) Bare role: `Primary` and `Secondary`.
- B) Role plus noun: `Primary column` and `Secondary column`.
- C) Role plus consequence: `Primary column (stays in view when scrolling)` and `Secondary column (students can hide)`.
- D) Role plus an info icon opening short help text.

**Decision**: **B** — the labels read `Primary column` and `Secondary column`.

Option C was rejected on two independent grounds. Both parentheticals describe *conditional* behavior, so a permanent label stating them would be wrong most of the time: the primary column only stays in view when it is shorter than the browser window (that conditionality is the root cause of AP-129), and students can only hide the secondary column when the checkbox is enabled, which is off by default. It also does not fit: at 14px bold uppercase, `Secondary column (students can hide)` renders at 300px, while the narrowest column is 305px wide with 20px of internal padding. Option A was rejected as ambiguous: `Primary` standing alone above a stack of items reads as a badge on the content rather than a name for the column. Option D's explanatory half was deferred.

---

### Where in the column should the label appear?

**Context**: `SectionColumn` renders no header at all, so there is no existing slot.

**Options considered**:
- A) A thin header bar above each column's items container.
- B) A badge or pill in the top-left corner of the items container, overlapping existing padding.
- C) Nothing per-column; rely on the section header's layout text alone.
- D) A header bar only when the layout is two-column.

**Decision**: **A**, with **D** folded in — a header row inside the column's grid container, rendered *before* the `<Droppable>`, and only for two-column layouts.

The label is metadata *about* the column, not content *in* it, so it belongs outside the drop area. Option B's drag risk is probably low, since react-beautiful-dnd derives ordering from explicit `index` props rather than DOM order, but a low risk that only manifests while dragging is exactly the kind of regression that survives code review. Option C was rejected as a substitute (though it is being done as well): it makes the author translate "primary on left" into a column position themselves, which is the indirection that caused the original confusion.

**Required CSS, and the trap**: naively inserting a header row misaligns the columns, because `.edit-page-grid-container` leaves `align-content` at its default and the shorter column's leftover height is distributed into its auto-sized rows. The obvious fix, `align-content: start`, realigns the headers but silently shrinks the drop zone by ~39%, because the shorter column's `.edit-items-container` stretches to fill the column and that stretch is what makes the empty area a valid drop target. Use `grid-template-rows: min-content 1fr`, scoped to columns that render a header.

---

### What is the exact display text for each of the eight layout options?

**Context**: The ticket suggests "60-40 (primary on left)". That works for the four fixed splits but needs decisions for the responsive and full-width ones. `responsive-50-50` is a special case: its columns are equal width, so nothing in the name hints that primary is the right one.

**Options considered**:
- A) Keep the raw token and append the hint.
- B) Fully humanize (`Full width`, `60/40 (primary on left)`, ...).
- C) Humanize and mark the single-column cases explicitly.

**Decision**: **A, amended to take C's single-column annotation.**

| Stored value (unchanged) | Display text |
| --- | --- |
| `full-width` | `full-width (single column)` |
| `60-40` | `60-40 (primary on left)` |
| `40-60` | `40-60 (primary on right)` |
| `70-30` | `70-30 (primary on left)` |
| `30-70` | `30-70 (primary on right)` |
| `responsive-30-70` | `responsive-30-70 (primary on right)` |
| `responsive-50-50` | `responsive-50-50 (primary on right)` |
| `responsive-full-width` | `responsive-full-width (single column)` |

The raw token is kept verbatim because these are the stored values, they appear in the authoring help doc and in years of support conversations, and an author searching for "60-40" should find a match. The single-column annotation is borrowed from C because `responsive-full-width` is genuinely opaque, and that is exactly the fact the column labels cannot communicate, since by design they are absent there.

**"(primary on right)" needs no qualifier for the responsive layouts.** They never stack at narrow viewports: `.section.responsive` is `display: flex` with direction set from React as `singleColumn ? "column" : "row"`, and neither responsive two-column layout is ever `singleColumn`. "Responsive" in these names means fixed-plus-fluid rather than percentage-based, not that they reflow.

---

### What should the dropdown show when the stored layout is not one of the eight known values?

**Context**: When the stored layout is outside the option list, the dropdown displays **`full-width`** while the section renders two columns, so the author is shown the opposite of the truth. This is pre-existing behavior. An earlier draft recorded the symptom as a *blank* dropdown, which was measured by assigning `select.value` directly; React never does that. `react-dom` 16's `updateOptions` falls back to the first non-disabled option, so `defaultValue` with no match yields `selectedIndex: 0`.

**Options considered**:
- A) Add a disabled `<option>` carrying the raw stored value.
- B) No fallback option; leave the dropdown as it is.

**Decision**: **B — no fallback option.**

This reverses an earlier decision in the spec, on evidence. A census of `sections.layout` across both deployed environments found **zero** unrecognized values:

| | total sections | NULL layout | unrecognized |
| --- | --- | --- | --- |
| production | 281,699 | 0 | **0** |
| staging | 5,045 | 0 | **0** |

Every one of the 286,744 sections holds one of the eight enum values: no `responsive`, no `responsive-2-columns`, no NULL, no empty string. The requirement carried real cost (a derived flag, an extra option, a byte-for-byte `value` rule, two tests, and an open question about placement) for a case that has never occurred. The reachability argument (no model validation, permitted raw string, legacy import mapping, and `responsive` having once been a selectable option) is sound in principle and was worth checking; it simply describes a path nothing has taken.

**What is kept**: the one-line `!isKnownLayout(layout)` guard that suppresses the *column label* for an unrecognized layout, since the "no label" path has to exist regardless for single-column sections.

---

### What do the column labels show when the stored layout is unrecognized?

**Context**: An unrecognized layout renders **two** columns, since the guard is `layout !== "full-width" && layout !== "responsive-full-width"`. The existing derivation would label them **backwards** relative to what students see: LARA's `columnValueForIndex` and Ruby's `primary_right_layouts` both say primary-on-left, while the Activity Player's `leftPrimary` whitelist says primary-on-right. `responsive` is not a dead branch in the Activity Player.

**Options considered**:
- A) Suppress the label, as single-column layouts do.
- B) Follow the Activity Player's rule, so the label matches what students see.
- C) Follow the existing `columnValueForIndex` fallback (primary-on-left).

**Decision**: **A** — no column label for an unrecognized layout.

C would print a label saying the opposite of what students see, which is worse than no label and is the exact failure this story exists to eliminate. B is defensible but requires committing to a primary/secondary rule for legacy layouts that LARA's own export and the Activity Player disagree about, and getting that right is a question about question numbering and export ordering, not labeling. Silence is the honest answer. A also costs nothing: the new prop already has to admit "no label" for single-column layouts.

---

### Should the editor explain what primary/secondary controls, beyond the label itself?

**Context**: The label answers "which column is primary", not "so what". Primary/secondary controls five distinct behaviors.

**Options considered**:
- A) No explanation. Label only.
- B) A tooltip or info popover listing what primary/secondary affects.
- C) A one-line help text under the Layout dropdown.
- D) Documentation only.

**Decision**: **A** for this story, with **D** as a non-code follow-up.

The reported problem was "there is no clear indication of which column is the primary column", and the labels plus dropdown text answer that completely. The strongest argument against building the tooltip now is the content rather than the mechanism: any honest explanation is conditional and multi-clause, and AP-129 is scheduled to change the rule, so a permanent tooltip would ship text already queued for rewrite. Option C was rejected on evidence: the section header repeats per section, so its sentence would repeat verbatim under every section (seven times on a 7-section page), reading as wallpaper almost immediately, and costing ~19px per section on top of the header.

---

### Should the label mention sticky behavior before the AP-129 fix ships?

**Context**: Wording that describes current sticky behavior may need editing shortly after AP-129 merges.

**Options considered**:
- A) Describe only the stable facts; say nothing about sticking.
- B) Describe sticking as it works today, accepting a follow-up edit.
- C) Hold sticky wording until AP-129 merges.

**Decision**: **A for the UI, C for the help doc.**

The UI half is already settled by the earlier decisions: nothing this story ships describes sticking, so it is immune to whatever AP-129 lands as. Reading AP-129's branch diff rather than the ticket prose, the new `getPinnedColumn` helper makes the secondary column eligible only when the primary cannot stick, the secondary fits the window, the secondary is shorter than the primary, and `secondaryPinnable` holds, which depends on `!isSecondaryCollapsed` and is therefore student-controlled at runtime and not knowable at authoring time. The post-fix rule is *more* conditional than today's and does not compress into a label line without lying.

---

### Does anything need to change about the "Allow student to hide secondary column" checkbox?

**Context**: That checkbox is the only place the authoring UI currently uses the word "secondary".

**Options considered**:
- A) Leave it exactly as is.
- B) Move it next to the secondary column's new label.
- C) Keep its wording in sync with the column labels.

**Decision**: **A**, plus fix the duplicate-ID defect.

It is a section-level setting stored as `can_collapse_small`, so moving it into the secondary column's header would misrepresent it as column-scoped, and it would jump sides whenever the layout flips. Option C is already satisfied: the checkbox says "secondary column" and the new label says "Secondary column".

---

### Duplicate element IDs across sections break label association (pre-existing bug)

**Context**: `AuthoringSection` hardcoded `id="toggle-secondary-column"` and `id="section_layout"`, but a page renders one `AuthoringSection` per section. The `<label>` both wraps the input *and* carries `htmlFor`, and `htmlFor` wins, so it resolves to the first matching ID in the document. Reproduced on a 3-section page: clicking the third section's checkbox label toggled section 1's checkbox and fired section 1's save. Clicking the checkbox square itself worked; only the label text misrouted.

**Decision**: **Fix it in this story.** Roughly four lines, deriving both IDs from the section ID the component already has, in a file this story is already changing, and the new column header needs the unique-ID-per-element pattern regardless.

No separate Jira bug is filed. An earlier draft called for one; it was dropped after checking team practice: drive-by fixes ride along in a story's PR as plain `chore:`/`fix:` commits without tickets, and LARA's Bug tickets are reported production failures rather than internal finds. A ticket opened and closed inside a single PR has no lifecycle. The PR description carries the callout QA works from.

**Verified not to break anything**: a repo-wide search finds those IDs only in `authoring-section.tsx`. The `section_layout` hits in the 2022 sections-schema migration are an unrelated Ruby local variable. No CSS rule, no feature spec, no other consumer.

---

### Is a component test expected for this change, or is manual verification enough?

**Context as originally written**: the change is presentational, and `AuthoringSection` has never had a component test, so the first one carries the cost of standing up `usePageAPI` and `UserInterfaceContext` mocks.

**That premise was wrong, and was disproved by writing the test.** `APIContainer` falls back to `mock-api-provider` whenever no `host` prop is given, so wrapping the component in `<APIContainer>` is the entire harness: zero hand-written mocks, no `jest-fetch-mock`, no provider wiring. A throwaway spec with five probes passed in 3.7s with no `act()` warnings.

**Options considered**:
- A) Component test covering label text per layout and dropdown option text.
- B) Unit-test only the pure pieces, verify rendering manually.
- C) Manual verification plus a Storybook story showing all eight layouts.

**Decision**: **A**, plus B's pure-helper tests. B was only ever a hedge against a setup cost that does not exist.

**C's Storybook story was dropped**: the team no longer uses Storybook, so a ninth story would add maintenance to a surface nobody reads. Component tests covering all eight layouts by accessible role and name are stronger verification than a story a human has to eyeball.

---

### Self-review resolutions that changed the spec

These came out of four rounds of adversarial self-review. Each was verified against the real code before being written down.

- **The column header must span the column's grid row.** The spec pinned down position, typography, colour, role, and the `grid-template-rows` fix, but never said the header must span the full column width. It has to: `.edit-page-grid-container` is `repeat(10, 1fr)` and that applies to the column container too, so a plain `<div>` auto-places into track 1 of 10 and wraps to two lines in every layout except `responsive-50-50`. Resolution: require `full-row`, the class the sibling `.edit-items-container` already uses. The `grid-template-rows` requirement does **not** substitute, since it fixes alignment *between* columns, a different failure.
- **The column-header ID rule was stated as "per section", which would reproduce the very defect this story fixes.** A section renders two headers, so a per-section ID is duplicated within the section, and both columns take the first header's accessible name: measured as 2 groups matching "Primary column" and 0 matching "Secondary column". Resolution: unique per **column**.
- **The header's element type was unspecified, and the obvious choice collides with the existing heading outline.** Existing headings run `<h1>` page nav, `<h2>` page title, `<h3>` section name, `<h4>` section item title, and the items render *inside* the column. Resolution: require a plain non-heading element, extending the same anti-pollution argument already used to reject `role="region"`. (Implementation later confirmed `<header>` is also wrong: it becomes a `banner` landmark.)
- **The new helper's parameter type was unspecified**, and typing it to the closed `SectionLayouts` enum would make the unrecognized-layout branches dead by construction and their unit tests unwritable. Resolution: type it `string`, citing the `classNameForItem` precedent in the same file.
- **The label's typography was unspecified and two sections assumed different values.** Settled by looking at what the codebase actually does rather than at `.teal-label`, which turned out to be defined once and referenced nowhere. Resolution: 12px bold uppercase `--dark-teal`, with the DOM node in sentence case. `text-transform` affects neither computed font-size nor accessible name, so casing is a review item rather than a test item.
- **The obvious label colour fails AA.** `--teal` `#0592af` on `--ltr-teal` `#cdebf2` is **2.92:1 and fails at any text size**, and it was the colour used in every prototype screenshot. Resolution: `--dark-teal` `#016082` at 5.59:1. Both are existing `vars.scss` tokens, so no palette change is involved.
- **"Exposed to screen readers as part of the column's accessible structure" was not implementable or testable.** Resolution: require `role="group"` plus `aria-labelledby`, verified against the real accessibility tree (the rejected bare-text-above-a-div alternative yields loose `generic` text and `null` for the same query).
- **Suppressing the label for unrecognized layouts left the `role="group"` requirement dangling.** Read literally, the original wording still demanded a group on both columns, which would emit a group whose `aria-labelledby` pointed at an ID that was never rendered, producing a group with no accessible name. Resolution: tie `role` and `aria-labelledby` to whether the header actually rendered.
- **`SectionColumn` cannot detect single-column layouts from its existing props**, so "no new plumbing is strictly required" was wrong. Resolution: require a new explicit prop whose type admits "no label", and warn against keying behavior off the overloaded `section-responsive-fluid` class.
- **The display-text map had no specified home.** Resolution: `section-authoring/util/`, explicitly ruling out `api/api-types.ts`. The finding grew during review: the Testing requirement already called for unit tests of a "layout-to-primary-side helper" that did not exist, since `columnValueForIndex` was a closure inside the component.
- **The narrow-viewport finding was wrong on both mechanism and numbers.** It claimed `.menuStart`'s `overflow: hidden` clips the checkbox label below ~1100px. Re-measured with real viewport resizes: nothing is ever clipped, the degradation is wrapping, and the band is ~1140 to 1210px. Resolution: record the measured table and add a manual check at 1200px.
- **The "completely blank dropdown" premise was wrong**; today it displays `full-width` while two columns render, which is worse than blank because QA testing for a blank dropdown would not find it.
- **The uncontrolled layout `<select>` can disagree with the labels.** Measured: re-rendering with a changed `layout` prop leaves the select showing the old value while columns re-derive. No reachable user path was found in the current app. Resolution: recorded as a deliberate Out of Scope entry with the reachability analysis, so it is not re-derived later.
- **Two candidate findings were killed by verification** and are recorded so they are not re-raised: renaming the two IDs breaks no external reference, and writing the `grid-template-rows` rule unscoped does not damage the section container (scoping is still the right call defensively, but nothing breaks if missed).
- **Declined**: the reporter's second ask ("as an author, I would want to choose which column should be the primary column") is explicitly out of scope. A proposed Follow-ups section was rejected as scope creep; the Out of Scope entries already record what is deferred and why.

---

### Four commits or one?

**Context**: The plan splits into roughly 500 lines across a pure refactor, the duplicate-ID fix, the dropdown text, and the column labels.

**Options considered**:
- A) Four commits in one PR.
- B) Four commits, with the duplicate-ID fix split into its own PR against its own Jira bug.
- C) One squashed commit.

**Decision**: **A**, measured against the repo rather than argued from principle.

LARA merges with **merge commits**, not squashes (all 25 most recent merges on master are `Merge pull request #NNNN`), so intra-PR commits land in master's history permanently and are what `git blame` lands on. Multi-commit PRs are the norm: commit counts for the last 25 merged PRs run 3, 42, 9, 12, 1, 3, 1, 4, ... with a median around 3, carrying conventional-commit prefixes rather than WIP noise. There is no PR template and no CONTRIBUTING file, so four commits simply matches what the repo does.

Option B was rejected on file overlap: `authoring-section.tsx` is touched by all four commits and `authoring-section.spec.tsx` is created by the second and extended by the third and fourth, so a separate PR would serialize the two and force a rebase through conflicts in both files. Option C was rejected because the refactor commit's whole value is that its behavioral equivalence can be checked on its own, before 300 lines of new behavior land on top of it.

---

### Should `SectionColumn` render a real `data-testid`?

**Context**: The `data-testid` props passed to `SectionColumn` never reached the DOM, because the component destructures only its declared props. The label tests need some way to identify a column.

**Options considered**:
- A) Drop the dead props, render `section-column-<n>` from inside the component.
- B) Declare a `dataTestId` prop, preserving the `section-column-<layout>-<n>` format.
- C) No testid; identify columns by `.col-1` / `.col-2` class names.
- D) No testid and no class query: assert group order and accessible names via `getAllByRole("group")`.

**Decision**: **C + D — add no testid.** Use D for the label assertions and C for tests that need to count rendered columns. The two dead props are dropped and nothing replaces them.

Rationale, measured rather than argued. **Nothing consumes the dead props**: `section-column` appears only at the two call sites and in two import lines. **Testids in this repo are cypress-facing, not jest-facing**: no spec anywhere in `lara-typescript` uses `ByTestId`, and cypress already selects this exact DOM by class rather than testid, so adding one would be production markup for a consumer that does not exist. **Option A as originally planned ships a latent collision**: rendering two sections gives two matches for `section-column-1` and `getByTestId` throws; it worked in the plan only because the label tests render a single section. **Option C's handle is structural**: `.col-1` / `.col-2` are load-bearing SCSS selectors. **Option D expresses the requirement most directly**: asserting `["Secondary column", "Primary column"]` for `30-70` states which *side* is primary with no coupling to markup at all.

The rewritten test block was run against a prototype before being written down. As a negative control, changing the header ID from per-column to per-section fails 9 of the 13 label assertions, which is stronger coverage than the testid version it replaces.

---

### WITHDRAWN: Where should the legacy fallback option appear in the dropdown?

**Context**: Whether the disabled fallback option should render first or last.

**Decision**: **Withdrawn — there is no fallback option to place.** The question was answered out from under itself by the data census (zero unrecognized values in production and staging), which removed the fallback option entirely.

Recorded so the investigation is not repeated: both placements display the stored value correctly, but they differ on keyboard, and **first** was the better answer. With the option last, the only available move is `ArrowUp`, landing on `responsive-full-width`, while `ArrowDown` is a no-op firing no `change` event. With it first, `ArrowDown` lands on `full-width`, which is both the sane default and the value the control already falls back to. There is no disabled-`<option>` precedent in the codebase; the nearest analogue is a non-disabled placeholder placed first.
