# Label which column is primary in authoring

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-220
**Repo**: https://github.com/concord-consortium/lara
**Implementation Spec**: [implementation.md](implementation.md)
**Status**: **In Development**

## Overview

In a two-column section, one column is the "primary" column and the other is the "secondary" column, and that distinction drives several runtime behaviors (which column can stick to the top, which one students can collapse, question numbering order). The LARA section editor never says which is which, so authors have to guess. This story adds a visible Primary/Secondary label to each column in the section editor and makes the Layout dropdown self-explanatory, with no data model or Activity Player changes.

## Project Owner Overview

While investigating AP-129 (two-column sections where an image or interactive did not stay in view while a student scrolled), it became clear that the behavior depends entirely on which of the two columns LARA treats as the "primary" one. That designation is derived automatically from the Layout setting: layouts named `60-40` and `70-30` put the primary column on the left, and `40-60`, `30-70`, `responsive-30-70`, and `responsive-50-50` put it on the right. Nothing in the authoring UI communicates this, so an author picking a layout has no way to know which column they are actually putting content into, or why two visually similar sections behave differently for students.

This story closes that gap with labeling only. Each column in the section editor gets a Primary or Secondary label, and the Layout dropdown stops showing raw values like `60-40` in favor of readable text that says where the primary column lands. Authors get an accurate mental model of a distinction that already exists and already affects their students. There is no change to stored data, no migration, and no change to how any published activity renders, so there is no risk to existing content. A separate, larger question (letting authors pick which column is primary, or giving them an explicit "keep this column in view" control) is deliberately not part of this story.

## Background

### Where "primary" comes from

`primary` and `secondary` are stored per page item (`page_items.column`), not per section. Which rendered column is primary is derived from the section's `layout` string, and the same derivation is duplicated in three places that all agree:

| Source | Location | Rule |
| --- | --- | --- |
| LARA authoring UI | `lara-typescript/src/section-authoring/components/authoring-section.tsx:210` (`columnValueForIndex`) | left column is secondary for `30-70`, `40-60`, `responsive-30-70`, `responsive-50-50`; otherwise left is primary |
| LARA export/ordering | `app/models/interactive_page.rb:122` (`primary_right_layouts`) | `["40-60", "30-70", "responsive-30-70", "responsive-50-50"]` |
| Activity Player | `activity-player/src/components/activity-page/section.tsx:245` (`leftPrimary`) | `layout === "60-40" \|\| layout === "70-30"` |

So the author-visible rule is simply: **primary is on the left for `60-40` and `70-30`, and on the right for `40-60`, `30-70`, `responsive-30-70`, and `responsive-50-50`.**

**The three sources agree only for those eight values.** For a layout string outside the enum they diverge: `columnValueForIndex` and `primary_right_layouts` both fall through to primary-on-left, while the Activity Player's `leftPrimary` is a whitelist of exactly `60-40` and `70-30`, so it puts primary on the right for everything else. That divergence is why this story suppresses the column label for unrecognized layouts rather than deriving one; see the unrecognized-layout decision below.

Note that "primary" is usually but not always the wider column: in `responsive-50-50` the two columns are equal width and the primary is just the right-hand one.

### What primary/secondary actually controls

The designation is not cosmetic. Today it drives:

- **Sticky/pin behavior.** Only the primary column can stick to the top of the viewport while a student scrolls, and only when it is shorter than the window (`activity-player/src/components/activity-page/section.tsx:131`). This is the behavior that produced AP-129.
- **Student collapse.** Only the secondary column can be collapsed by students; that is what the existing "Allow student to hide secondary column" checkbox controls (`secondary_column_collapsible` in `Section#export`, `app/models/section.rb:71`).
- **Display mode.** Stacked/carousel display applies to the secondary column (`secondary_column_display_mode`, currently hard-coded to `"stacked"` at `app/models/section.rb:72`).
- **Question numbering order.** When the primary column is on the right, LARA emits secondary-column items first so numbering follows visual reading order (`app/models/interactive_page.rb:117-131`).
- **Responsive sizing.** In responsive layouts the secondary column is the fixed-width one and the primary flexes.

### What the section editor shows today

`AuthoringSection` renders a teal `sectionMenu` header (drag handle, section name, Layout dropdown, "Allow student to hide secondary column" checkbox, and the Collapse/Move/Copy/Hide/Delete buttons), followed by one or two `SectionColumn` components. The Layout `<select>` is populated straight from the `SectionLayouts` enum, so its option text is the raw stored value (`full-width`, `60-40`, `responsive-30-70`, ...). `SectionColumn` already receives the `column` (`"primary"` / `"secondary"`) and `columnNumber` props but renders no header of any kind: it goes directly to the droppable items container and the "Add Item" button.

### Single-column layouts

`full-width` and `responsive-full-width` render one column. `changeLayout` (`lara-typescript/src/section-authoring/util/change-layout-utils.tsx:25-55`) moves every item into the `secondary` column when switching to a full-width layout, while `columnValueForIndex(0)` reports `PRIMARY` for those layouts. The two disagree, so the stored `column` value is not a reliable thing to surface for single-column sections. Since the primary/secondary distinction has no author-visible meaning when there is only one column, these layouts should not display a column label at all.

## Requirements

### Column labels

- In a two-column layout, each column in the section editor displays a visible label whose text content is exactly `Primary column` or `Secondary column`.
- The label is styled **12px, bold, uppercase, `--dark-teal`**, matching the section editor's existing idiom for structural chrome. The DOM text node stays sentence case and CSS applies `text-transform: uppercase`, so the label renders as `PRIMARY COLUMN` while its text content, and therefore its accessible name, remains `Primary column`. Both the visible text and the accessible name are then derived from one string, which is the same reason the Accessibility section requires `aria-labelledby` over `aria-label`.
- The label reflects the same primary/secondary derivation the Activity Player uses, so the left column is labeled Primary for `60-40` and `70-30`, and the right column is labeled Primary for `40-60`, `30-70`, `responsive-30-70`, and `responsive-50-50`.
- The label renders in a header row inside the column's grid container, positioned *before* the `<Droppable>` so it sits outside the drag-and-drop subtree.
- The header row spans the full width of the column's grid row. `.edit-page-grid-container` is a ten-track grid (`grid-template-columns: repeat(10, 1fr)`, `authoring-section.scss:87-92`) and that rule applies to the column container as well as the section container, so a header without an explicit span auto-places into track 1 of 10 and the label wraps to two lines in every layout except `responsive-50-50`. Use the existing `full-row` class (`grid-column: span 10`, `authoring-section.scss:229`), which is what the sibling `.edit-items-container` already uses for exactly this. See the round 3 finding below for the measurements; note that the `grid-template-rows` requirement above does not substitute for this, since it fixes alignment *between* the two columns rather than the header's width.
- Changing the Layout dropdown updates the labels immediately, without a page reload.
- In single-column layouts (`full-width`, `responsive-full-width`) no column label is shown, and the column renders no header row.
- **When the stored layout is not one of the eight known values, no column label is shown**, even though two columns render. The label is suppressed rather than guessed, reusing the same "no label" path as single-column layouts. See the unrecognized-layout decision below for why the alternative (guessing) would print a label that contradicts what students see. An empty-string layout falls in this bucket: it renders two columns and gets no label (see the layout dropdown requirements).
- Labels are read-only. They report the derivation; they are not a control.
- Adding the header must not change the drop-zone geometry. The column container needs `grid-template-rows: min-content 1fr` (**not** `align-content: start`, which shrinks the shorter column's drop target by roughly 39%); see the placement decision below for the measurements.

### Layout dropdown

- Each option displays the raw stored token followed by a parenthetical hint, per the table in the layout-text decision below. For two-column layouts the hint states which side the primary column is on; for the two single-column layouts it reads `(single column)`.
- The stored `section.layout` value is unchanged: only the option's display text changes, never its `value`.
- **The dropdown gains no fallback option for unrecognized stored layouts.** An earlier version of this spec required one; it was removed after a census of the real data found the case does not occur. See the legacy-layout decision below for the numbers. The dropdown's behavior for such a layout is therefore unchanged from today: it displays `full-width`.
- The component must not normalize an unrecognized or empty layout to `"full-width"`. The dropdown's *selection* already falls back to `full-width` on its own, via react-dom's no-match behavior, and that is fine. Rewriting the `layout` value itself would collapse a section that renders two columns down to one, because the two-column guard is `layout !== "full-width" && layout !== "responsive-full-width"`, which an empty string passes. This story makes no rendering change.
  - Recorded because it is the one live consequence of the nullable column: `sections.layout` has no `null: false` and `Section` has no validation, while `AuthoringSection`'s `layout: initLayout = defaultLayout` default parameter fires only on `undefined`, never on `null`. Measured against the real component, a `null` layout throws (`Cannot read properties of null (reading 'toLowerCase')`) in `sectionClassNames()`, while an empty string does not: `"".toLowerCase()` is fine, the dropdown displays `full-width`, and two columns render. Both counts are zero in production and staging, so this is defensive only.

### Duplicate element IDs (pre-existing bug, fixed here)

- `section_layout` and `toggle-secondary-column` must be unique per section, derived from the section ID.
- Clicking a section's "Allow student to hide secondary column" label must toggle *that* section's checkbox, and its "Layout:" label must focus *that* section's dropdown. Today both resolve to the first section on the page.
- Any ID introduced by the new column header must be unique per **column**, derived from the section ID and the column number. Per-section uniqueness is not sufficient, since a section renders two headers.

### Non-regression

- No change to the section data model, the authoring API payloads, `Section#export`, or the exported activity JSON.
- No migration, and no change in how any existing published activity renders in the Activity Player.
- The "Allow student to hide secondary column" checkbox keeps its current wording, position, behavior, and disabled-for-full-width logic. Only its `id` changes.
- Drag and drop within a column is unaffected.

### Accessibility

- In a two-column layout **with a recognized layout**, each column container carries `role="group"` and `aria-labelledby` pointing at the ID of its own header label, so the column's contents are announced as belonging to a named group.
  - The ID must be unique per column, derived from the section ID and the column number (see the duplicate-ID requirements above); `aria-labelledby` depends on it. An ID that is merely unique per section gives both columns the accessible name of the first header, so no column is announced as Secondary.
  - Use `aria-labelledby` rather than `aria-label`. Both produce an identical accessibility tree, but `aria-labelledby` derives the accessible name from the same DOM node as the visible text, so the visible and announced labels cannot drift apart in a later edit.
  - Use `role="group"`, not `role="region"`. A region is a landmark, and two landmarks per section across every section on a page would swamp the landmark list.
  - The header itself is a plain `<div>`. Do **not** use a heading, and do **not** use `<header>`. An earlier draft offered `<header>` as an alternative; that is wrong and was measured: a `<header>` element is a `banner` landmark unless it descends from `article`, `aside`, `main`, `nav`, or `section`, and `role="group"` on the parent does not exempt it. Rendering the label as `<header>` produced two extra banner landmarks per section in the accessibility tree, which is exactly the landmark pollution that rules out `role="region"` below. (Pre-existing and out of scope: the section menu at `authoring-section.tsx:284` is already a `<header>` in the same position and already produces one spurious banner per section.) The same argument that rules out `role="region"` applies at the same multiplicity: two headings per section on every section of a page would swamp the heading outline. `<h4>` in particular would sit at the same outline level as the section item titles nested inside the column (`section-item.tsx:147`), and `<h3>` collides with the section name (`authoring-section.tsx:79`). `aria-labelledby` produces the required accessible name from a plain element, so nothing is lost by avoiding a heading.
  - A visible text node above a plain `<div>` is **not** sufficient. Verified in the accessibility tree: it produces loose `generic` text with no association to the column's contents, so a screen reader user hears "Primary column" as free-floating text while the items below belong to nothing.
  - Single-column layouts render no header and therefore no group.
  - **Unrecognized layouts likewise render no header and therefore no group**, even though they render two columns. The `role` and `aria-labelledby` must be tied to whether the header actually rendered, not to whether the layout is two-column. A `role="group"` whose `aria-labelledby` points at a nonexistent ID yields a group with no accessible name, which is worse for a screen reader user than a plain unlabeled container.
- The column label uses **`--dark-teal` `#016082`** on the column grid's `--ltr-teal` `#cdebf2` background, measured at **5.59:1**, which passes WCAG AA. Both are existing tokens in `vars.scss`; no palette change is involved.
  - Do **not** use `--teal` `#0592af`, the colour `.teal-label` uses. On `--ltr-teal` it measures **2.92:1 and fails AA at any text size**, so it cannot be rescued by enlarging the label. On `--ltst-teal` `#e2f4f8` it is still only 3.23:1.
  - The label is 12px bold, below the WCAG "large text" threshold (18.66px bold / 24px regular), so the **4.5:1** requirement applies, not 3:1. The uppercase rendering does not change this: `text-transform` does not alter the computed `font-size`.
  - `text-transform: uppercase` is invisible to accessible-name computation, so the label's accessible name is the sentence-case text content. Verified: a group whose label is styled uppercase still matches `getByRole("group", { name: "Primary column" })` and does **not** match `{ name: "PRIMARY COLUMN" }`. This is the intended outcome, but it also means the test suite cannot detect a casing regression, so the casing lives in the Column labels requirements and is checked by review rather than by test.
  - Pre-existing and out of scope: the surrounding chrome is already marginal (white on `--teal` in the section header is 3.66:1, passing only as large text), and hidden sections carry `opacity: .5`, which reduces effective contrast for all text in them including this label.
- The page emits no duplicate element IDs for section controls.

### Testing

- Component tests cover the label text for all eight layouts, the absence of labels on single-column layouts, the absence of labels for an unrecognized layout and for an empty-string layout (in both cases asserting that two columns still render, so the test cannot pass merely because nothing rendered), and live updates when the dropdown changes. Assert **by accessible role and name** (`getByRole("group", { name: "Primary column" })`), not by text content, so the test fails if the `aria-labelledby` association is dropped.
- Unit tests cover the layout-to-display-text map and the layout-to-primary-side helper.
- A regression test covers the duplicate-ID fix.
- No test covers a legacy-layout fallback option, because there is no longer one to test. The unrecognized-layout cases are still covered by the label-suppression tests above.
- **Manual check, not automated**: view a section at a 1200px viewport and confirm the header's two-line wrap matches the accepted behavior described under "Narrow-viewport effect on the section header". This is viewport-dependent, so a jsdom assertion would be meaningless.

## Technical Notes

### Files expected to change

- `lara-typescript/src/section-authoring/components/authoring-section.tsx` — Layout dropdown option text; pass the derived column role down to `SectionColumn`.
- `lara-typescript/src/section-authoring/components/section-column.tsx` — render the column header/label.
- `lara-typescript/src/section-authoring/components/section-column.scss` (and/or `authoring-section.scss`) — styling for the label.
- `lara-typescript/src/section-authoring/util/` — a new module holding both pure helpers (see "Pure helpers belong in util/" below), plus its co-located `.spec.ts`.

### Existing structures to reuse

- `columnValueForIndex(columnNumber)` in `authoring-section.tsx:210` already returns `SectionColumns.PRIMARY` / `SectionColumns.SECONDARY` for a rendered column index, and its result is already passed to `SectionColumn` as the `column` prop.
- **`SectionColumn` needs a new prop for the label; its existing props cannot express the requirement.** The component must be able to render *no* header for single-column layouts, and neither candidate prop can distinguish that case:
  - `column` is `PRIMARY` for both `full-width` and `responsive-full-width`, because `columnValueForIndex(0)` returns `PRIMARY` for them, making them indistinguishable from the primary column of a split layout.
  - `className` is overloaded. `layoutClassNames` maps `LAYOUT_RESPONSIVE_FULL_WIDTH` to `["section-responsive-fluid"]` while `LAYOUT_RESPONSIVE_30_70` maps to `["section-responsive-static", "section-responsive-fluid"]`, so `section-responsive-fluid` means both "the only column of a single-column responsive section" and "the right-hand column of a responsive 30-70 section". **Do not key any behavior off these class names.**

  Pass an explicit prop whose type admits "no label" (for example an optional column-role prop that is left undefined for single-column layouts), so the case is represented directly rather than inferred. `AuthoringSection` already holds `layout` and calls `columnValueForIndex`, so it can supply it without further plumbing.
- The teal design tokens used by the existing section header live in `lara-typescript/src/vars.scss`.
- **`.teal-label` (`authoring-section.scss:171`) is an orphan.** It is defined once and referenced nowhere in the repo, so it is not the house style despite looking like it. Do not adopt it wholesale, and in particular **do not reuse its `--teal` colour**: see the contrast requirement in the Accessibility section.
- The live precedent for a small structural-chrome label in this editor is **`.sectionItemMenu`** (`section-item.scss:14-25`): `font-size: 12px` with `text-transform: uppercase`. The section header's menu buttons are the same idiom at 11.5px uppercase (`authoring-section.scss:388`). Sentence case is reserved for form-control labels, such as `.toggleSecondaryColumnOption` at 14px. A column header is structural chrome, so it follows the uppercase idiom. It takes `font-weight: bold` where `.sectionItemMenu` is `normal`, because it sits on the light `--ltr-teal` column background rather than a solid teal bar and needs the weight to read as a header instead of as content.

### Pure helpers belong in util/

Both pure pieces of this change live in `section-authoring/util/`, which is the established home for section and layout logic (`sections.ts`, `change-layout-utils.tsx`, `move-utils.tsx`). Co-located `.spec.ts` files are the convention there, though coverage is partial: `change-layout-utils`, `move-utils`, and `finding-utils` have one; `sections.ts`, `array-util.ts`, and `accessibility-helper.ts` do not. The new module follows the convention and ships with its spec. Do **not** put author-facing display strings in `api/api-types.ts`, which is a types-and-enums module.

Two helpers go there:

- the layout-to-display-text map, and
- the layout-to-column-role derivation, which must be **extracted from `AuthoringSection`**. `columnValueForIndex` is currently a closure inside the component that captures `layout` from state, so it is neither importable nor unit-testable. Extract it as a pure function of `(layout, columnIndex)` and have `AuthoringSection` call the extracted version.

  Type the helper's layout parameter as `string` rather than `SectionLayouts`. `ISection.layout` is declared `layout?: SectionLayouts` (`api/api-types.ts:220`), a closed enum, so a helper typed to the enum makes the unrecognized-layout branch dead code by construction and the unit test for it unwritable without a cast. The column is unvalidated at the model layer, so values outside the enum remain expressible even though the census found none stored. There is precedent in the file being edited: `classNameForItem` (`authoring-section.tsx:27-35`) is typed `SectionLayouts` yet guards at runtime against values outside it. Tests that render a section with an unrecognized layout need a cast at the call site.

  Note the extracted helper serves two callers with different needs. `AuthoringSection` still needs a `SectionColumns` value for `getColumnItems` and `addItem` on every layout, including unrecognized ones, so the existing fallback behavior must be preserved there. The **label** must not use that fallback: it is suppressed for unrecognized layouts. Keep the two concerns separate rather than changing `columnValueForIndex`'s fallback, which would silently repartition existing items. Without this, the Testing requirement to unit-test "the layout-to-primary-side helper" is unsatisfiable, because no such standalone function exists today.

### Layout display strings

There is no Zeplin design for this work, so the strings were a spec decision; the agreed table is in the layout-text decision below. The set of layouts needing text is the `SectionLayouts` enum in `api/api-types.ts:8-17`:

`full-width`, `60-40`, `40-60`, `70-30`, `30-70`, `responsive-30-70`, `responsive-50-50`, `responsive-full-width`.

### Narrow-viewport effect on the section header

Adding the parentheticals widens the dropdown from 164px to 258px. **Nothing is clipped**: `.menuStart`'s `overflow: hidden` never triggers, and `scrollWidth === clientWidth` at every width measured down to 1000px. The degradation is **wrapping**. The checkbox label wraps to two lines and the `COLLAPSE | MOVE | COPY | HIDE | DELETE` row wraps too, dropping DELETE onto its own line, taking the header from 40px to 57px.

Measured with real viewport resizes and a realistic long section name:

| Viewport | Raw values (today) | With hints |
| --- | --- | --- |
| 1440, 1280, 1240, 1220 | 1 line, 40px | 1 line, 40px (identical) |
| **1200** | **1 line, 40px** | **2 lines, 57px** |
| 1160 | 1 line, 40px | 2 lines, 57px |
| 1120, 1000 | 2 lines, 57px | 2 lines, 57px (identical) |

The change moves the wrap threshold from roughly 1140px to roughly 1210px, about 70px. Above roughly 1220px there is no difference at all; below roughly 1140px the header already wraps today regardless. The affected band is roughly 1140 to 1210px, and the effect is cosmetic: the header gets 17px taller, nothing becomes unreadable. Section-name truncation is unaffected (at 1200px the `h3` truncates identically in both cases).

This is an accepted consequence, not a defect to file. If authors turn out to work commonly in that band, the fix would be to let `.menuStart` wrap deliberately rather than by accident, which is a follow-up.

### Ruby-side layout constants are stale but out of the way

`Section::LAYOUT_OPTIONS` (`app/models/section.rb:21-28`) predates the responsive layouts: it lists a single `responsive` entry and none of `responsive-30-70`, `responsive-50-50`, or `responsive-full-width`. It is only consumed by `Section#css_class_for_item_index`, which serves the legacy Rails-rendered runtime, not the React section editor. The dropdown is built entirely in TypeScript, so this story does not need to touch it.

### Testing

`lara-typescript` runs Jest with `@testing-library/react`. `AuthoringSection` needs **no hand-written mocks**: `APIContainer` falls back to `mock-api-provider` whenever no `host` prop is given, so wrapping the component in `<APIContainer>` is the entire harness. Verified by running a throwaway spec (five probes, 3.7s, no `act()` warnings). See the testing decision below for the exact pattern.

Note that the `data-testid` values passed to `SectionColumn` at `authoring-section.tsx:345` and `:357` never reach the DOM, because `SectionColumn` destructures only its declared props and never spreads the rest.

### Pre-implementation verification

A throwaway prototype of the whole change (full-row header before the `<Droppable>`, `role="group"` plus
`aria-labelledby` on the column container, `grid-template-rows: min-content 1fr` scoped to a
header-bearing class) was built against the real components, measured, and then reverted. It settled the
one requirement that had no evidence behind it and confirmed the styling requirements in the live editor.

- **Drag and drop is unaffected, measured rather than argued.** Driving react-beautiful-dnd's own keyboard
  sensor on a `60-40` section at 1400px: lift, move, and drop all announce correctly ("You have lifted an
  item in position 1" → "moved from position 1 to position 2" → "You have dropped the item"), the
  placeholder appears on lift and is cleaned up on drop, and the geometry is stable **during** the drag,
  not merely at rest: header 25px at offset 0, drop zone at offset 25 with height 282px, identical before,
  during, and after in both columns. This retires the last unverified non-regression requirement.
- **The styling requirements hold in the live component.** Computed colour `rgb(1, 96, 130)` (`--dark-teal`),
  `font-size: 12px`, `font-weight: 700`, `text-transform: uppercase`. The header spans the full column in
  every layout and stays on one line, including the tightest case: the 305px static column of
  `responsive-30-70`, where the rendered label measures 128px.
- **Suppression works as specified.** A single-column layout renders no header, no `role`, and no
  `aria-labelledby`, and leaves the column's `grid-template-rows` untouched. An unrecognized layout
  (`responsive`) renders two columns with no header, splitting items 2/1 while the dropdown misreports
  `full-width`, exactly as the legacy-layout decision describes.
- **Superseded**: an earlier bullet here recorded that the legacy-layout fallback test was writable in
  jsdom (react-dom renders a matching `disabled` option as the current selection, `selectedIndex: 2`).
  That finding was sound but is now moot: the fallback option was removed after the data census, so
  there is no such test. Retained only so the measurement is not repeated.

Two notes for whoever writes the tests, neither a defect:

- **Storybook cannot demonstrate the unrecognized-layout case through story args.** Storybook 6 replaces an
  out-of-enum `layout` arg with the component's default, so a story declaring `layout: "responsive"` renders
  a single `full-width` column. Only a story that passes the prop directly, bypassing args, reproduces it.
  Storybook is out of scope for this story; this is recorded so the discrepancy is not mistaken for a bug.
- **Playwright's `dragTo` does not reorder a react-beautiful-dnd list.** It reports a drag that ends where it
  started. This is true with and without the header, so it is a synthetic-drag artifact rather than a
  regression signal; use the keyboard sensor for any future browser-level drag check.

### DOM structure of a column

This constrains where the label can go:

```
<DragDropContext>
  <div class="edit-page-grid-container col-N section-40">   <- grid, 10 columns
    <Droppable>
      <div class="edit-items-container full-row" ref={droppableProvided.innerRef}>
        <div class="itemsContainer">        <- flex wrap, holds the Draggables + Add Item
```

The chosen header position is a child of `.edit-page-grid-container` rendered before `<Droppable>`, which keeps it outside the drag-and-drop subtree.

### Measured column widths

At a 1400px viewport, driving the real `#section_layout` change handler:

| Layout | Column widths (px) |
| --- | --- |
| `60-40` | 788 / 528 |
| `70-30` | 922 / 394 |
| `30-70` | 384 / 932 |
| `40-60` | 518 / 798 |
| `responsive-30-70` | 305 / 1011 |
| `responsive-50-50` | 653 / 663 |
| `full-width` | 1326 |

### Related work

- **AP-129** covers the Activity Player sticky-column fix: allowing the secondary column to stick when it is the one that fits on screen. It lives on branch `AP-129-sticky-column-fix` as **PR #582, open but still a draft**. Not merged, so as of this writing the primary column is still the only one that can stick. Nothing in this story depends on its outcome.
- The larger follow-ups discussed on the ticket, letting authors choose which column is primary, or adding an explicit per-section "stick to top" control, are explicitly not part of this story.

## Out of Scope

- Letting authors choose which column is primary (unbundling "primary" from the layout). This needs a new section field, a migration, authoring API and export changes, and Activity Player changes in roughly half a dozen places.
- An explicit per-section "stick to top" control (Auto / Primary / Secondary / None).
- Any change to the Activity Player, including the AP-129 sticky-column fix.
- Anything to do with Storybook: adding or updating stories, fixing the swapped single-column stories in `src/stories/authoring-section.stories.tsx`, or retiring the now-unused Storybook setup and its deploy workflow.
- Changing the sticky, collapse, carousel, question-numbering, or responsive-sizing behaviors themselves.
- Updating the stale `Section::LAYOUT_OPTIONS` constant in `app/models/section.rb`.
- Renaming the "primary"/"secondary" values stored in `page_items.column`.
- The legacy Rails-rendered section authoring UI, if any remains.
- Any in-editor explanation of what primary/secondary controls: no tooltip, info popover, or help text. Deferred to a later story once the sticky rule settles.
- Updating the authoring help doc. That is a follow-up task, not a code change, and is tracked separately.
- Converting the `can_collapse_small` checkbox from `defaultChecked` to a controlled input.
- Converting the layout `<select>` from `defaultValue` to a controlled input. Same call as the checkbox above, made deliberately. The `<select>` is uncontrolled while the columns derive from `layout` state, which a `useEffect` resyncs from the prop (`authoring-section.tsx:142`), so a prop change without a remount leaves the dropdown showing the old layout while the columns, and after this story the labels, show the new one. No reachable path was found in the current app: `mutationsOpts` supplies only `onSuccess` (`use-api-provider.ts:110`), so a failed mutation neither refetches nor rolls back, and section move and copy change the React `key` (`section-${id}-${index}`, `authoring-page.tsx:186`), forcing a remount. The remaining paths are out-of-band, such as a second browser tab or server-side normalization of the layout string. Recorded so this is not re-derived later.
- Fixing the Activity Player's dead `responsive-2-column` branch at `section.tsx:216`.
- Making the dead `data-testid` props on `SectionColumn` actually render, except where the new tests need them.

## Open Questions

### RESOLVED: What exactly should each column label say?

**Context**: The ticket says add a "Primary" / "Secondary" label. On its own that is accurate but still jargon: it names the distinction without explaining why an author should care. The whole reason this story exists is that Jie could not tell which column would stick to the top. A bare "Secondary" label tells an author which bucket they are in but not what follows from it.

**Options considered**:
- A) Bare role: `Primary` and `Secondary`.
- B) Role plus noun: `Primary column` and `Secondary column`.
- C) Role plus consequence: `Primary column (stays in view when scrolling)` and `Secondary column (students can hide)`. Most informative, but the parentheticals are conditional (sticking only happens when the column fits on screen; hiding only when the checkbox is on), so they risk over-promising.
- D) Role plus an info icon that opens short help text listing what primary/secondary controls.

**Decision**: **B** — the labels read `Primary column` and `Secondary column`.

Rationale: option C was rejected on two independent grounds. First, both parentheticals describe *conditional* behavior, so a permanent label stating them would be wrong most of the time: the primary column only stays in view when it is shorter than the browser window (that conditionality is the root cause of AP-129), and students can only hide the secondary column when the "Allow student to hide secondary column" checkbox is enabled, which is off by default. Second, it does not fit. Measured at 14px bold uppercase, `Secondary column (students can hide)` renders at 300px, while the narrowest column in the editor is 305px wide with 20px of internal padding, leaving 285px usable, so it would wrap precisely in the column where the secondary label always lives.

These measurements were taken at 14px, before the label's typography was settled at **12px** bold uppercase (see the Column labels requirements). They therefore overstate every width below, and the fit conclusion holds with more room to spare rather than less. They have not been redone, since nothing turns on the exact figures once the chosen strings clear the constraint at the larger size.

Option A was rejected as ambiguous: `Primary` standing alone above a stack of items reads as a status or a badge on the content rather than as a name for the column. The word "column" costs 64px and removes that reading.

Option D's explanatory half is deferred to the separate question on whether the editor should explain what primary/secondary controls.

**Supporting measurements** (Storybook + Playwright, driving the real `#section_layout` change handler at a 1400px viewport):

| Layout | Column widths (px) |
| --- | --- |
| `60-40` | 788 / 528 |
| `70-30` | 922 / 394 |
| `30-70` | 384 / 932 |
| `40-60` | 518 / 798 |
| `responsive-30-70` | **305** / 1011 |
| `responsive-50-50` | 653 / 663 |
| `full-width` | 1326 |

The secondary column is always the narrower one, or equal in `responsive-50-50`, so a secondary label must fit in 285px of usable space. Rendered label widths at 14px bold uppercase: `Primary` 61px, `Secondary` 84px, `Primary column` 125px, `Secondary column` 148px. The chosen strings fit every layout with room to spare.

---

### RESOLVED: Where in the column should the label appear?

**Context**: `SectionColumn` currently renders no header at all, so there is no existing slot. The choice affects how much vertical space the editor loses per section and how obvious the label is.

**Options considered**:
- A) A thin header bar above each column's items container, styled like a lighter version of the existing teal `sectionMenu`.
- B) A small badge or pill in the top-left corner of the items container, overlapping the existing padding.
- C) Text appended to the section header instead of the columns, for example "Layout: 60-40 (primary on left)" already implies it, so add nothing per-column.
- D) A header bar only when the layout is two-column, collapsing to nothing for full-width (this is what the requirements currently assume, and is compatible with A or B).

**Decision**: **A** — a header row inside the column's grid container, rendered *before* the `<Droppable>` so the label sits outside the drag-and-drop subtree. Option D is folded in: the header renders only for two-column layouts.

Rationale: the label is metadata *about* the column, not content *in* it, so it belongs outside the drop area. Keeping non-draggable nodes out of the Droppable subtree is also the conservative structure. Option B's drag risk is probably low, since react-beautiful-dnd derives ordering from explicit `index` props rather than DOM order, but a low risk that only manifests while dragging is exactly the kind of regression that survives code review and reaches authors.

Option C was rejected as a substitute (though it is being done as well, see the layout dropdown question): it makes the author translate "primary on left" into a column position themselves, which is the same indirection that caused the original confusion.

**Required CSS, and a trap to avoid**: naively inserting a header row misaligns the two columns. `.edit-page-grid-container` sets `grid-auto-rows: minmax(20px, auto)` and leaves `align-content` at its default, so in the shorter column the leftover height is distributed into the auto-sized rows: the header inflates from 24px to 75px and pushes that column's content box 51px below the other one.

The obvious fix, `align-content: start`, realigns the headers but silently shrinks the drop zone, because today the shorter column's `.edit-items-container` stretches to fill the column and that is what makes the whole empty area a valid drop target. Measured drop-zone heights for a section with two items on the left and one on the right:

| | primary drop zone | secondary drop zone |
| --- | --- | --- |
| today (no header) | 262px | 262px |
| header + `align-content: start` | 262px | **160px** (39% smaller drop target) |
| header + `grid-template-rows: min-content 1fr` | 262px | 262px |

**Use `grid-template-rows: min-content 1fr` on the column container**, scoped so it applies only to columns that render a header. That reproduces today's geometry exactly: both headers 24px tall at the same offset, both drop zones starting at the same offset with unchanged height. Verified in the live component via Playwright.

**Cost**: +24px of height per two-column section. Full-width sections are unaffected because they render no header. This figure assumes the header spans the full column grid row; a header confined to one of the column's ten grid tracks wraps to two lines and costs roughly 38px instead. See the Column labels requirements.

---

### RESOLVED: What is the exact display text for each of the eight layout options?

**Context**: The ticket suggests "60-40 (primary on left)". That pattern works for the four fixed split layouts but needs decisions for the responsive ones and the full-width ones. `responsive-50-50` is a special case: its columns are equal width, so nothing about the name hints that the primary is the right one.

**Options considered**:
- A) Keep the raw token and append the hint, capitalizing nothing.
- B) Fully humanize: `Full width`, `60/40 (primary on left)`, ..., `Responsive 50/50 (primary on right)`, `Responsive full width`. Friendlier, but authors who know the old values lose the exact string.
- C) Humanize and mark the single-column cases explicitly: as B, but `Full width (single column)` and `Responsive full width (single column)`.

**Decision**: **A, amended to take C's single-column annotation.** The option text is:

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

Rationale: the raw token is kept verbatim rather than humanized to `60/40`, because these tokens are the stored values, they appear in the existing authoring help doc and in years of support conversations, and an author who searches for "60-40" should find a match. Humanizing buys polish at the cost of recognizability, and the ticket specifies this format. The single-column annotation is borrowed from option C because `responsive-full-width` is genuinely opaque, and a new author has no way to know from the name that these layouts have no second column, which is exactly the fact the column labels cannot communicate, since by design they are absent there.

**"(primary on right)" needs no qualifier for the responsive layouts.** The responsive layouts never stack at narrow viewports, so "right" does not silently become "bottom": `.section.responsive` in the Activity Player is `display: flex` with its direction set from React as `singleColumn ? "column" : "row"`, and neither `responsive-30-70` nor `responsive-50-50` is ever `singleColumn`. There is no media query and no `flex-wrap` on the section. "Responsive" in these names means the columns are fixed-plus-fluid rather than percentage-based, not that they reflow.

**Measured width impact** (real select element): raw values 164px, option A 251px, option B 254px, option C 262px. The spread between the three candidate sets is noise. All of them add roughly 90 to 100px, which moves the point at which the section header runs out of horizontal slack from about 1000px of viewport width to about 1100px. Below that, the existing `overflow: hidden` on `.menuStart` clips the checkbox label. Acceptable for a desktop authoring tool, but it is a real narrowing and should be eyeballed on a small laptop before merge.

---

### RESOLVED: What should the dropdown show when the stored layout is not one of the eight known values?

**Context**: Discovered while investigating the option text. When the stored layout is outside the option list (for example `responsive`, which still exists in `Section::LAYOUT_OPTIONS` and which the Activity Player still handles at `section.tsx:224`), the dropdown displays **`full-width`** while the section renders two columns. The author is shown the opposite of the truth. This is pre-existing behavior, not something this story introduces.

An earlier draft of this spec recorded the symptom as a *blank* dropdown (`selectedIndex: -1`, `value: ""`). That was measured by assigning `select.value` directly, which is not what React does. Re-measured three ways:

| How the value is set | selectedIndex | value | displayed |
| --- | --- | --- | --- |
| React `defaultValue`, no matching option | `0` | `full-width` | `full-width (single column)` |
| direct `select.value = "responsive"` | `-1` | `""` | (blank) |

Rendering the real component with `layout="responsive"` confirms the first row: `selectedIndex: 0`, `value: "full-width"`, and two columns (`col-1 section-full-width`, `col-2 section-full-width`). The mechanism is in `react-dom` 16's `updateOptions`, which sets `option.selected` per option and, when nothing matches, falls back to the first **non-disabled** option.

This makes the defect worse than a blank control. It also matters for QA: testing for a blank dropdown will not find it.

The mechanisms that could produce such a row are real. `Section#layout` has no model validation, `sections_controller` permits the raw string, and `interactive_page.rb:383` maps the legacy `responsive-2-columns` value on **import**, so legacy strings could re-enter the system even though `db/migrate/20251209102615_rename_responsive_2_columns_to_responsive_30_70.rb` cleaned the existing rows. Git history also shows `"responsive"` (and before it, capital-R `"Responsive"`) was once a selectable option in this very dropdown, removed by PR #875 with no accompanying migration. (Separately, the Activity Player checks for `responsive-2-column`, singular, at `section.tsx:216`, matching neither the old nor the new value. That appears to be a typo'd dead branch in AP; it is noted here only as evidence that these strings drift, and it is out of scope.)

**Decision**: **No fallback option.** The dropdown is left as it is for unrecognized layouts.

This reverses an earlier decision in this spec, which required an additional disabled `<option>` carrying the raw stored value. It was reversed on evidence: a census of `sections.layout` across **both** deployed environments found **zero** unrecognized values.

| | total sections | NULL layout | unrecognized |
| --- | --- | --- | --- |
| production | 281,699 | 0 | **0** |
| staging | 5,045 | 0 | **0** |

Full production distribution: `full-width` 270,568, `40-60` 5,074, `60-40` 2,560, `responsive-30-70` 1,996, `responsive-full-width` 628, `70-30` 533, `30-70` 254, `responsive-50-50` 86. Staging matches in shape. Every one of the 286,744 sections holds one of the eight enum values: no `responsive`, no `Responsive`, no `responsive-2-columns`, no NULL, no empty string.

Measured 2026-08-06 via `rails runner` on the production and staging ECS App containers. The script and the census are kept as repo oob files at `ops/lara-rails-console.sh` and `ops/layout-census.rb`; re-run them if this needs revisiting.

Re-run against both environments after the specs were written: production had drifted to 281,700 sections (one section added, and one moved from `30-70` to `responsive-30-70`) and staging was unchanged at 5,045. **Both still report 0 NULL and 0 unrecognized**, so the reversal stands. The table above is left at its original figures rather than chased, since the totals move daily and only the two zeroes are load-bearing. Worth re-running once more if this story sits unmerged for a long stretch, because the guard test in the implementation plan (`expect(select.value).toBe("full-width")`) pins today's behavior on these zeroes.

So the requirement carried real cost (a derived flag, an extra option, a byte-for-byte `value` rule, two tests, and an open question about where to place the option) for a case that has never occurred. The reachability argument above is sound in principle and was worth checking; it simply turns out to describe a path nothing has taken.

**What is kept**: the one-line `!isKnownLayout(layout)` guard in `columnLabelRoleForIndex`, which suppresses the column label for an unrecognized layout. It costs a single condition, it makes the helper total over its `string` parameter, and the "no label" path it reuses has to exist regardless for the 271,196 single-column sections. See the label-suppression decision below.

---

### RESOLVED: What do the column labels show when the stored layout is unrecognized?

**Context**: An unrecognized layout renders **two** columns, so the labels would render. The guard at `authoring-section.tsx:355` is `layout !== "full-width" && layout !== "responsive-full-width"`, which a value like `responsive` passes. Verified by rendering the real component with `layout="responsive"`: two columns, classed `col-1 section-full-width` and `col-2 section-full-width`.

The derivation currently in the component would label them **backwards** relative to what students see:

| Source | Rule for an unrecognized layout | Result |
| --- | --- | --- |
| `columnValueForIndex` (`authoring-section.tsx:210`) | falls through to `else`, index 0 → `PRIMARY` | primary on **left** |
| `primary_right_layouts` (`interactive_page.rb:122`) | not in the list | primary on **left** |
| `leftPrimary` (`activity-player/.../section.tsx:245`) | whitelist of `60-40`, `70-30` only | primary on **right** |

`responsive` is not a dead branch in the Activity Player: it is handled explicitly in `responsiveSection` and in both the primary and secondary embeddable filters, so such a section really does render with primary on the right.

**Options considered**:
- A) Suppress the label. Render the two columns with no header, as single-column layouts do.
- B) Follow the Activity Player's rule, so the label matches what students see.
- C) Follow the existing `columnValueForIndex` fallback, i.e. label primary-on-left.

**Decision**: **A** — no column label is shown for an unrecognized layout.

Rationale: C would print a label that says the opposite of what students see, which is worse than the status quo of no label at all and is the exact failure this story exists to eliminate. B is defensible but requires this story to commit to a primary/secondary rule for legacy layouts that LARA's own Ruby export and the Activity Player currently disagree about, and getting that rule right is a question about question numbering and export ordering, not about labeling. Silence is the honest answer.

Note this decision survived the census that killed the dropdown's fallback option, and for a different reason: suppression costs one condition in a helper that already needs a "no label" path for single-column layouts, whereas the fallback option was a standalone feature. Zero such sections exist today, so this guard is defensive rather than load-bearing.

A also costs nothing to implement. The `SectionColumn` prop this story introduces already has to admit "no label" for the two single-column layouts, so the unrecognized case reuses that same path rather than adding a branch.

---

---

### RESOLVED: Should the editor explain what primary/secondary controls, beyond the label itself?

**Context**: The label answers "which column is primary". It does not answer "so what". Primary/secondary currently controls five distinct behaviors (sticky, collapsible, display mode, question numbering, responsive sizing), and an author who understands only the sticky one will still be surprised by the others.

**Options considered**:
- A) No explanation. Label only. Smallest change, and the label alone already fixes the reported confusion.
- B) A short tooltip or info popover on the label listing what primary/secondary affects.
- C) A one-line help text under the Layout dropdown, for example "The primary column is the one that can stay in view while students scroll."
- D) Documentation only: no UI text, add a note to the authoring docs.

**Decision**: **A** for this story, with **D** as a non-code follow-up.

Rationale: the reported problem was "there is no clear indication of which column is the primary column in authoring", and the column labels plus the dropdown text answer that completely. Teaching authors what "primary" *means* is a larger, separate problem, and the section editor is not the right surface for it.

The strongest argument against building the tooltip now is the content rather than the mechanism. Any honest explanation is conditional and multi-clause: the primary column stays in view while students scroll, *but only when it is shorter than the browser window*, and that rule is precisely what AP-129 changes. Committing that to a permanent tooltip while AP-129 is unmerged means shipping text that is already scheduled for rewrite. A help doc absorbs a multi-paragraph, evolving explanation far better than a 15px info circle.

Option C was rejected on evidence: the section header repeats per section, so its sentence repeats verbatim under every section on the page (three times on a 3-section page, seven on a 7-section page). A prototype of a realistic 3-section page showed it reading as wallpaper almost immediately, and it costs about 19px per section on top of the 24px the column header already adds.

Option B remains viable for a future story and is not blocked by tooling: `react-tooltip` 4.5.1 is already installed, sets `aria-describedby` on the target, and binds a `focus` handler, so it can meet the keyboard requirement provided the trigger is a real focusable `<button>` rather than a `<div>`, which is the same pattern the Activity Player uses for its collapsible column header.

**Follow-up (not code)**: add a note to the authoring help doc, currently linked from the page header menu at `section-authoring/components/page-header/components/page-header-menu.tsx:75`, describing what primary/secondary controls. Revisit an in-UI tooltip once the sticky behavior has settled.

---

### RESOLVED: Should the label mention sticky behavior before the AP-129 fix ships?

**Context**: If the labels or help text say the primary column "stays in view while scrolling", that is only true today when the primary column is shorter than the browser window, and it will become less true in a different way once the AP-129 fix lets the secondary column stick as well. Wording that describes current behavior may need editing shortly after.

**Options considered**:
- A) Describe only the stable facts (which column is primary), and say nothing about sticking. Immune to the AP-129 outcome.
- B) Describe sticking as it works today, accepting a follow-up edit when AP-129 merges.
- C) Hold the sticky-related wording until AP-129 merges, ship the labels now, and add wording in a follow-up.

**Decision**: **A for the UI, C for the help doc.**

The UI half is already settled by the earlier decisions: with the labels reading `Primary column` / `Secondary column` and no in-editor explanation, nothing this story ships describes sticking, so it is immune to whatever AP-129 lands as.

The evidence reinforces that. AP-129's fix lives on branch `AP-129-sticky-column-fix` as **PR #582, open but still a draft** with reviews in progress, so the rule is actively in flux. Reading the branch diff rather than the ticket prose, the new `getPinnedColumn` helper keeps the primary column's existing rule (it sticks whenever its content fits the window) and makes the secondary column eligible only when *all* of the following hold: the primary column cannot stick, the secondary fits in the window, the secondary is shorter than the primary, and `secondaryPinnable`, which is `secondaryEmbeddables.length > 0 && !isSecondaryCollapsed`. That last input is student-controlled at runtime and therefore not knowable at authoring time at all. The post-fix rule is *more* conditional than today's, and none of it compresses into a label or tooltip line without lying.

For the help-doc note from the previous question, split it. Write the note now covering only the facts that are safe regardless of AP-129: what primary and secondary are, which layouts put the primary on which side, that only the secondary column can be collapsed by students or use carousel mode, and that question numbering follows visual reading order. Add the sticky paragraph as a separate edit once PR #582 merges and the rule is settled. Documenting a rule that is currently in draft review would mean writing it twice, and the intermediate version would actively mislead any author who read it during the gap.

---

### RESOLVED: Does anything need to change about the "Allow student to hide secondary column" checkbox?

**Context**: That checkbox is the only place the authoring UI currently uses the word "secondary". Once columns are labeled, the checkbox and the label reinforce each other, which is good. But the checkbox stays enabled and visible for every two-column layout regardless of whether the secondary column has any content, and it sits in the section header rather than next to the column it affects.

**Options considered**:
- A) Leave it exactly as is. It is out of scope and it already reads correctly once the columns are labeled.
- B) Move it next to the secondary column's new label, so the control sits with the thing it controls.
- C) Leave it in place but keep its wording in sync with whatever wording the column labels use.

**Decision**: **A**, plus fix the duplicate-ID defect described below as part of this story.

Leave the checkbox where it is and leave its wording alone. It is a section-level setting stored as `can_collapse_small` on the section, so moving it into the secondary column's header (option B) would misrepresent it as column-scoped, and it would jump sides whenever the layout flips, which is disorienting. Option C is already satisfied: the checkbox says "secondary column" and the new label says "Secondary column", so there is nothing to sync.

---

### RESOLVED: Duplicate element IDs across sections break label association (pre-existing bug)

**Context**: Discovered while evaluating the checkbox. `AuthoringSection` hardcodes `id="toggle-secondary-column"` (`authoring-section.tsx:315`) and `id="section_layout"` (`authoring-section.tsx:297`), but a page renders one `AuthoringSection` per section, so those IDs are duplicated across every section on the page.

Reproduced on a 3-section page by clicking the **third** section's checkbox label:

```
duplicate ids:  toggle-secondary-column x3,  section_layout x3
clicked label in Section 3
checked before: [false, false, false]
checked after:  [true,  false, false]   <- Section 1 toggled
Section 3's "Layout:" label resolves to Section 1's <select>
```

The `<label>` both wraps the input *and* carries `htmlFor`, and `htmlFor` wins, so it resolves to the first matching ID in the document. Clicking the words "Allow student to hide secondary column" on any section below the first toggles section 1's checkbox, which in the real app fires section 1's `onChange` and saves the wrong section. Clicking the checkbox square itself works correctly; only the label text misroutes. The same defect makes every "Layout:" label point at the first section's dropdown. The page also emits duplicate IDs, which is invalid HTML and gives screen reader users the same broken association.

**Decision**: Fix it in this story. It is roughly four lines, deriving both IDs from the section ID the component already has, in a file this story is already changing, and the new column header needs the unique-ID-per-column pattern regardless if it is to be associated with its column for assistive tech. Call it out explicitly in the PR description so QA tests it.

No separate Jira bug is filed. An earlier draft called for one; it was dropped after checking what the team actually does. Drive-by fixes ride along in a story's PR as plain `chore:`/`fix:` commits without tickets, and LARA's Bug tickets are reported production failures rather than internal finds. A ticket opened and closed inside a single PR has no lifecycle, and the PR description already carries the callout QA works from. See the commit-structure decision in the implementation spec.

**Related, not being fixed**: the checkbox uses `defaultChecked` (uncontrolled) with no `useEffect` to resync, unlike `layout`, which has one at `authoring-section.tsx:142`. Low impact in practice, since the paths that change `can_collapse_small` remount the component.

---

### RESOLVED: Is a component test expected for this change, or is manual verification enough?

**Context as originally written**: "The change is presentational. `AuthoringSection` has never had a component test, so the first one carries the cost of standing up `usePageAPI` and `UserInterfaceContext` mocks. That setup may exceed the size of the feature itself."

**That premise was wrong, and was disproved by writing the test.** `APIContainer` falls back to `mock-api-provider` whenever no `host` prop is given, so the entire harness is:

```tsx
const renderSection = (layout: SectionLayouts) =>
  render(
    <APIContainer>
      <AuthoringSection id="1" interactive_page_id="2" layout={layout} />
    </APIContainer>
  );
```

Zero hand-written mocks, no `jest-fetch-mock`, no provider wiring. A throwaway spec with five probes passed in 3.7s with no `act()` warnings, including the interactive case that matters most: a real `fireEvent.change` on the layout dropdown, asserting the columns re-render. Flipping `60-40` to `30-70` to `full-width` took the rendered columns from `col-1 section-60 / col-2 section-40` to `col-1 section-30 / col-2 section-70` to a single `col-1 section-full-width`. That is exactly the path the labels must track, so "changing the Layout dropdown updates the labels immediately" is directly testable.

**Options considered**:
- A) Add a component test covering label text per layout and dropdown option text.
- B) Unit-test only the pure pieces and verify rendering manually.
- C) Manual verification only, plus a Storybook story showing all eight layouts.

**Decision**: **A**, plus B's pure-helper tests. B was only ever a hedge against a setup cost that does not exist.

**C's Storybook story was dropped.** The team no longer uses Storybook, so a ninth story would add maintenance to a surface nobody reads. The component tests below cover all eight layouts by accessible role and name, which is stronger verification than a story a human has to eyeball. Note that `.github/workflows/deploy-storybook.yml` still builds and deploys `src/stories/` to S3 on every push, and the existing `authoring-section.stories.tsx` still renders seven of the eight layouts; retiring that workflow, the stories directory, and the `@storybook/*` devDependencies is a real cleanup but an unrelated one, and is deliberately not bundled into this story. Implementers should leave the stories file alone.

Test coverage to write:
- Component test: the per-layout label mapping across all eight layouts, including the counterintuitive `responsive-50-50` where the primary is on the right despite equal column widths; that no label renders for the two single-column layouts; that no label renders for an unrecognized layout even though two columns do; and that labels update live when the dropdown changes.
- Unit tests: the layout-to-display-text map and the layout-to-primary-side helper are trivially table-testable.
- Regression test for the duplicate-ID bug: render two sections, click the second one's checkbox label, assert the *second* one's checkbox toggled.

**Incidental find**: the `data-testid={`section-column-${layout}-1`}` props at `authoring-section.tsx:345` and `:357` never reach the DOM. The probe found 0 matching elements alongside 2 column divs, because `SectionColumn` destructures only its declared props and never spreads the rest. Those testids are dead today. If the implementation wants to target columns by testid, `SectionColumn` must actually render one.

## Self-Review — Round 3

Role: **Fresh Implementer**, reading the spec cold and attempting to build from it without the
context that produced it. Every finding below was verified against the current code before being
written down: CSS geometry was measured in Chromium against the real compiled `authoring-section.scss`
and `section-column.scss`, and DOM/accessibility behavior was measured with throwaway Jest specs
against the real components. Two candidate findings were killed by verification and are recorded at
the end, along with the Round 2 claims that were re-measured and held up.

### RESOLVED: The column header must span the column's grid row, and the spec never says so
**Resolution**: A requirement was added under Column labels stating that the header row spans the full column grid row, naming `full-row` as the existing mechanism and noting that the `grid-template-rows` requirement does not substitute for it. The placement decision's "+24px per two-column section" cost was annotated to say the figure assumes a full-row header.

The spec pins down the header's position (child of `.edit-page-grid-container`, before the
`<Droppable>`), its typography, its colour, its role, and the `grid-template-rows` fix, but it never
says the header must span the full width of the column. It has to. `.edit-page-grid-container` is
`grid-template-columns: repeat(10, 1fr)` (`authoring-section.scss:87-92`), and that rule applies to
the **column** container as well as the section container, because both carry the class. The sibling
`.edit-items-container` already opts out via `full-row` (`grid-column: span 10`,
`authoring-section.scss:229`). A plain `<div>` header does not, so it auto-places into grid track 1
of 10.

**Evidence.** Measured in Chromium at a 1400px viewport with the real compiled CSS, a 12px bold
uppercase label, and the `grid-template-rows: min-content 1fr` fix already applied:

| Layout | Column | Header width, plain `<div>` | Header height | Header width, with `full-row` | Header height |
| --- | --- | --- | --- | --- | --- |
| `60-40` | secondary (541px) | 95px | **38px (2 lines)** | 541px | 23px (1 line) |
| `70-30` | secondary (403px) | 95px | **38px** | 403px | 23px |
| `30-70` | primary (393px) | 77px | **38px** | 393px | 23px |
| `responsive-30-70` | static (305px) | 77px | **38px** | 305px | 23px |
| `responsive-50-50` | both (669/679px) | 335px / 340px | 23px | 669px / 679px | 23px |

The label wraps to `PRIMARY` / `COLUMN` on two lines in every layout except `responsive-50-50`, which
escapes only because that column container redefines its own grid as two tracks rather than ten, so
half a column happens to be wide enough. The narrow-track placement also distorts the column's track
sizing (in `60-40`'s secondary column, track 1 grows from 54.1px to 95.4px and the other nine shrink
to 49.5px), because an `fr` track's automatic minimum is the item's min-content width.

**Why it matters.** This is not a cosmetic near-miss, it is the spec's own stated cost being wrong.
"Cost: +24px of height per two-column section" and "both headers 24px tall at the same offset" hold
only with a full-row header; without it the header is 38px and the label reads as a wrapped badge
floating over the top-left corner rather than as a column header. The
`grid-template-rows: min-content 1fr` requirement does **not** rescue this: it fixes vertical
alignment between the two columns, which is a different failure, and both of my measurements above
already had it applied. A reviewer checking the spec's acceptance criteria would find every stated
criterion satisfied.

Suggested resolution: state in the Column labels requirements that the header row spans the full
column grid row, and name `full-row` as the existing mechanism, since it is the class the sibling
`.edit-items-container` already uses for exactly this.

---

### RESOLVED: The column-header ID uniqueness rule is stated as "per section", which reproduces the duplicate-ID defect this story fixes
**Resolution**: Both requirements now state that the header ID must be unique per **column**, derived from the section ID and the column number, and the Accessibility bullet records what a per-section ID actually produces (both columns take the first header's accessible name, so no column is announced as Secondary).

Two requirements govern the new header's ID, and both state the wrong rule. Under Duplicate element
IDs: "Any ID introduced by the new column header must follow the same **per-section** uniqueness
rule." Under Accessibility: "The ID must be **unique per section**." A section renders two column
headers, so an ID that is merely unique per section is duplicated within the section.

**Evidence.** Rendering two `role="group"` columns whose `aria-labelledby` both point at
`column-label-42`:

```
duplicate ids in DOM:                    2
groups matching name "Primary column":   2
groups matching name "Secondary column": 0
```

Both columns take the accessible name of the **first** header, so a screen reader user hears
"Primary column" twice and never hears "Secondary column" at all. With per-column IDs
(`column-label-42-1` / `-2`) the same probe returns 1 and 1.

**Why it matters.** The spec's own non-regression requirement is "The page emits no duplicate element
IDs for section controls", and this story exists partly to fix exactly this class of defect
(`section_layout` and `toggle-secondary-column`, which I reproduced: rendering two sections yields
`section_layout, toggle-secondary-column, section_layout, toggle-secondary-column`). Shipping the fix
while reintroducing the same bug in the new markup would be a poor outcome for a story whose whole
subject is labeling.

Mitigating: the specified test `getByRole("group", { name: "Primary column" })` would throw on two
matches, so a correctly written test does catch this. The defect is in the requirement's wording, not
in the test plan, and it is one word to fix.

Suggested resolution: change both requirements to say the ID must be unique per **column**, derived
from the section ID and the column number.

---

### RESOLVED: The header's element type is unspecified, and the obvious choice collides with the existing heading outline
**Resolution**: The Accessibility section now requires a plain non-heading element and rules out headings explicitly, carrying the outline-collision evidence (`<h4>` collides with the section item titles nested inside the column, `<h3>` with the section name) and extending the existing anti-landmark-pollution argument to headings.

The spec specifies the header's position, width behavior (per the finding above), size, weight,
casing, colour, role, and accessible name, but not what element it is. An implementer reaching for
semantics will pick a heading, and the section editor already has a heading outline that a column
header does not slot into cleanly.

**Evidence.** The existing headings in `section-authoring`: `<h1>` page nav
(`authoring-page.tsx:241,248`), `<h2>` page title (`authoring-page.tsx:150`), `<h3>` section name
(`authoring-section.tsx:79`), `<h4>` **section item title** (`section-item.tsx:147`). The section
items are rendered *inside* the column, so an `<h4>` column header would sit at the same outline level
as the item headings nested within it, and an `<h3>` would collide with the section name.

**Why it matters.** The spec reasons carefully about the analogous pollution question one level up,
rejecting `role="region"` because "two landmarks per section across every section on a page would
swamp the landmark list". The identical argument applies to headings: two per section on every
section of a page. The decision was made for landmarks and left open for headings, and
`aria-labelledby` produces the required accessible name from a plain `<div>` just as well as from a
heading, so nothing about the stated accessibility requirement forces the choice either way.

Suggested resolution: state the element explicitly. A non-heading element (`<div>`, or `<header>` if
an element name is wanted) is the lower-risk default and is consistent with the landmark reasoning.

---

### RESOLVED: The legacy-layout requirements describe states the type system forbids, and the new helper's parameter type is unspecified
**Resolution**: Technical Notes now types the extracted helper's layout parameter as `string`, records why (an enum-typed parameter makes the unrecognized-layout branch dead by construction), cites the `classNameForItem` precedent for runtime-guarding a value the type forbids, and notes that tests for the unrecognized cases need a cast at the call site.

`ISection.layout` is typed `layout?: SectionLayouts` (`api/api-types.ts:220`), a closed eight-value
enum. Several requirements are about values outside it: the fallback `<option>` for an unrecognized
stored layout, label suppression for an unrecognized layout, and the null/empty-string rule. Under
the declared types, none of those states exist. Technical Notes names the extracted helper's
signature as "a pure function of `(layout, columnIndex)`" without saying what `layout`'s type is; if
it is typed `SectionLayouts`, the unrecognized branch is dead code by construction, and the unit test
the Testing section requires cannot be written without a cast.

**Evidence.** My probe had to type the prop `any` to render `<AuthoringSection layout="responsive" />`
at all. There is a precedent for the runtime-guard-despite-the-type pattern in the same file:
`classNameForItem(_layout: SectionLayouts, ...)` (`authoring-section.tsx:27-35`) checks
`Object.keys(layoutClassNames).indexOf(_layout) !== -1` against a value its own signature says is
always valid.

**Honest severity: low.** An implementer hits this in the first minute and resolves it with a widened
parameter type or a cast, and the precedent is sitting in the file they are already editing. Raised
only because this spec is otherwise precise enough that an implementer will reasonably expect the
type question to have been settled, and because a helper typed to the enum quietly makes two of the
story's requirements unreachable rather than failing loudly.

Suggested resolution: one line in Technical Notes typing the helper's layout parameter as `string`
(or `SectionLayouts | string`), and noting that the tests for the unrecognized cases require a cast
at the call site.

---

### Verified this round, no change needed

Re-measured against the current code and confirmed accurate:

- **The `grid-template-rows: min-content 1fr` decision is correct and generalizes**, independently
  re-measured with real compiled CSS across `60-40`, `responsive-30-70`, and `responsive-50-50`.
  Baseline drop zones 280px/280px at offset 0; naive header 280/**224** with the shorter column's
  header inflating from 23px to **79px** (the spec says 24px to 75px, the same mechanism);
  `align-content: start` 280/**168**, a 40% shrink (the spec says 39%); `min-content 1fr` 280/280 at
  offsets 23/23, exactly reproducing baseline geometry.
- **The label's contrast basis is right.** `.edit-page-grid-container { background: var(--ltr-teal) }`
  (`authoring-section.scss:88`) applies to the column container, so a header placed there does sit on
  `#cdebf2`, which is the background the 5.59:1 figure was computed against.
- **The duplicate-ID defect reproduces**, and **an unrecognized layout renders two columns**, both as
  described.
- **No component tests exist anywhere in `section-authoring`** (only `finding-utils`,
  `change-layout-utils`, and `move-utils` specs in `util/`), so the new component test really is the
  first one, and the `<APIContainer>`-only harness works as Round 2 recorded.

Two candidate findings were **killed by verification** and are recorded so they are not re-raised:

- *"Renaming `section_layout` and `toggle-secondary-column` may break external references."* It does
  not. A repo-wide search finds those IDs only in `authoring-section.tsx` and in this spec. The
  `section_layout` hits in `db/migrate/20220628163733_convert_activities_to_new_sections_schema.rb`
  are an unrelated Ruby local variable. There is no CSS rule, no feature spec, and no other consumer.
- *"Writing the `grid-template-rows` rule unscoped, against `.edit-page-grid-container`, would damage
  the section container, which shares that class."* It does not, measured: section height, menu
  height, and both column heights and offsets are identical scoped and unscoped. The spec's
  instruction to scope the rule is still the right call defensively, but nothing breaks if an
  implementer misses it, so it is not a trap worth flagging.

### Round 3, second pass

Re-reviewed after applying the four resolutions above. **No new issues.** The resolutions were
re-measured together rather than individually, including the case none of the earlier rounds covered:
a two-column section where one column is **empty**, which is the extreme case for the drop-zone
stretch that `grid-template-rows: min-content 1fr` exists to preserve. With a `full-row` header and
the scoped row fix, `60-40`, `30-70`, `responsive-30-70`, and `responsive-50-50` all reproduce
baseline geometry exactly whether the second column holds one item or none: header 23px, both drop
zones starting at offset 23 with the unchanged 280px height.

Two things worth noting for the implementer, neither of which is a defect:

- `full-row` is defined in `authoring-section.scss` while the header will be written in
  `section-column.tsx`. That cross-file dependency already exists (`section-column.tsx:122,127` uses
  `edit-page-grid-container` and `full-row`, both defined in `authoring-section.scss`), so the new
  header follows the file's existing pattern rather than introducing a new coupling.
- Typing the extracted helper's layout parameter as `string` does not disturb the `AuthoringSection`
  caller, which passes a `SectionLayouts` value.

The remaining unverified claim in the spec is still the manual 1200px narrow-viewport check, which is
viewport-dependent and deliberately not automated.

---

## Self-Review — Round 2

Roles: Frontend/React Engineer, Product Manager, Technical Writer, plus a re-check by Senior
Engineer, QA Engineer, and WCAG Accessibility Expert. Every finding below was verified against
the current code before being written down; see each finding's evidence block. Claims that were
re-tested and held up are listed under "Verified, no change needed" at the end of this round.

### Senior Engineer (re-check)

#### RESOLVED: The "completely blank dropdown" premise is wrong; today it displays `full-width`
**Resolution**: The Layout dropdown requirement and the legacy-layout decision now describe the measured behavior (the dropdown displays `full-width` while two columns render) and carry the re-measurement table. The QA consequence (testing for a blank dropdown will not find this) is called out in the decision.

**Partly superseded.** This finding's correction of the symptom stands. Its second-order consequence, the byte-for-byte `value` requirement on the fallback option, is moot: the fallback option itself was later removed after a census found zero unrecognized layouts in production or staging. See the legacy-layout decision above.

The Layout dropdown requirements and the legacy-layout decision both assert that a section with
an unrecognized stored layout renders a **completely blank** dropdown (`selectedIndex: -1`,
`value: ""`), and that "React's `defaultValue` behaves identically". React's `defaultValue` does
**not** behave identically, and the real behavior is worse than blank.

**Evidence.**

1. Real component, jsdom, `<AuthoringSection layout="responsive" />`:
   `select selectedIndex: 0  value: "full-width"`, and two columns render
   (`col-1 section-full-width`, `col-2 section-full-width`).
2. Chromium, replicating React's algorithm on a real `<select>`:

   | Case | selectedIndex | value | displayed |
   | --- | --- | --- | --- |
   | React `defaultValue` path, no matching option | `0` | `full-width` | `full-width (single column)` |
   | direct `select.value = "responsive"` | `-1` | `""` | (blank) |

   The blank result comes only from assigning `select.value` directly, which is what the original
   measurement must have done. React never does that.
3. `react-dom` 16 `updateOptions` (`node_modules/react-dom/cjs/react-dom.development.js:2210-2235`)
   is explicit: it sets `option.selected` per option, and when nothing matches it falls back to
   `defaultSelected`, which is seeded as **the first non-disabled option**.

**Why it matters.** The defect is not a blank control the author can see is empty. The dropdown
silently claims the section is `full-width` while two columns render, so the author is told the
opposite of the truth. QA testing for "blank dropdown" would not find it. This strengthens the
case for the fallback option rather than weakening it, but the spec's description of today's
behavior has to be corrected or QA will chase the wrong symptom.

**Second-order consequence for the fix.** Because React's no-match fallback is "first non-disabled
option", the fallback option must carry the stored string byte-for-byte as its `value`. Any
mismatch (case, whitespace) fails silently back to `full-width` instead of surfacing an error.
Worth stating, since the requirement adds a `disabled` option and disabled options are exactly the
ones React skips when choosing its fallback.

Suggested resolution: rewrite the two affected passages to describe the measured behavior, and add
the byte-for-byte `value` requirement.

---

#### RESOLVED: Column labels would be actively wrong for an unrecognized layout, and the spec does not cover it
**Resolution**: Labels are now suppressed for unrecognized layouts, reusing the same "no label" path as single-column layouts. Added: a requirement under Column labels, a new decision record ("What do the column labels show when the stored layout is unrecognized?") weighing suppress vs. follow-the-Activity-Player vs. keep-the-existing-fallback, a Background qualification that the three derivations agree only for the eight known values, a Technical Notes note that the extracted helper must preserve `columnValueForIndex`'s fallback for item partitioning while the label does not use it, and a component test that asserts two columns render but carry no label.

The spec decides what the *dropdown* shows for an unrecognized layout but says nothing about what
the *column labels* show. The existing derivation would label them backwards relative to the
Activity Player, which is the exact failure this story exists to prevent.

**Evidence.**

- An unrecognized layout renders **two** columns: the guard is
  `layout !== "full-width" && layout !== "responsive-full-width"` (`authoring-section.tsx:355`), so
  `"responsive"` passes it. Confirmed by rendering the real component: two columns,
  `col-1 section-full-width` / `col-2 section-full-width`.
- `columnValueForIndex` (`authoring-section.tsx:210-236`) falls through to its `else` branch for any
  layout outside the two full-width values and the four primary-right values, and that branch
  returns `PRIMARY` for index 0. So the **left** column would be labeled `Primary column`.
- The Activity Player computes `leftPrimary = layout === "60-40" || layout === "70-30"`
  (`section.tsx:245`), which is `false` for any other value, so it renders the **left** column as
  secondary and the right as primary. `"responsive"` is not dead there: it is handled explicitly in
  `responsiveSection` and in both embeddable filters (`section.tsx:239-243`).

So for a legacy `responsive` section, LARA would print `Primary column` over the column the
Activity Player renders as secondary.

**Reachability.** `Section#layout` has no model validation, `Section::LAYOUT_RESPONSIVE = "responsive"`
still exists in the model, and `interactive_page.rb:383` maps `responsive-2-columns` on import, so
unrecognized strings can re-enter the system. The spec already accepts this premise; it is the same
premise the dropdown-fallback decision rests on.

**Knock-on correction.** The Background table asserts that all three derivations "all agree". They
agree only for the eight known values. For unrecognized values the Ruby helper
(`primary_right_layouts`, `interactive_page.rb:122`) and the LARA authoring UI say primary-left
while the Activity Player says primary-right.

Suggested resolution: state what the label does for an unrecognized layout (suppress it, or follow
the Activity Player's rule), and qualify the Background table.

---

#### RESOLVED: The layout `<select>` is uncontrolled, so it can disagree with the labels
**Resolution**: recorded as a deliberate Out of Scope entry alongside the analogous `defaultChecked` decision, carrying the reachability analysis so it is not re-derived later. No code change; no reachable path was demonstrated.

`AuthoringSection` renders the dropdown with `defaultValue={layout}` (`authoring-section.tsx:300`)
while the columns derive from the `layout` **state**, which a `useEffect` resyncs from the prop
(`:142`). The DOM `<select>` is never resynced, so the two author-facing indicators this story adds
can contradict each other.

**Evidence.** Re-rendering the real component with a changed `layout` prop:

| prop after rerender | select shows | columns re-derive as |
| --- | --- | --- |
| `30-70` | `60-40` (selectedIndex 1) | 30-70 |
| `responsive` | `60-40` (selectedIndex 1) | responsive |

**Honest severity.** I could not find a reachable user path in the current app. `mutationsOpts`
supplies only `onSuccess` (`use-api-provider.ts:110-116`), so a failed mutation neither refetches nor
rolls back; and section move/copy changes the React `key` (`section-${id}-${index}`,
`authoring-page.tsx:186`), which forces a remount. The remaining paths are out-of-band (a second
tab, or server-side normalization of the layout string). This is a latent inconsistency, not a
demonstrated bug.

Raised only because the spec makes the explicit call for the analogous `defaultChecked` case
("Converting the `can_collapse_small` checkbox from `defaultChecked` to a controlled input" is in
Out of Scope) and is silent about `defaultValue` on the select, even though this story adds a second
primary/secondary indicator to that same header. Suggested resolution: add a one-line Out of Scope
entry (or a Technical Notes note) making the same call deliberately.

---

### Frontend / React Engineer

#### RESOLVED (superseded): The Storybook story file already exists, is missing from "Files expected to change", and its two single-column stories are swapped
**Resolution**: superseded by a scope decision rather than fixed. The team no longer uses Storybook, so the Storybook requirement was **removed** from the spec instead of corrected: dropped from Testing, dropped from the test-coverage decision (with the reasoning recorded there), and Storybook work of every kind added to Out of Scope. The swapped-stories bug is left alone. It is pre-existing, it builds cleanly, and it only misleads someone reading the deployed Storybook.

Recorded for whoever picks up the cleanup: `.github/workflows/deploy-storybook.yml` still builds and deploys `src/stories/` to S3 **on every push**, so this is live infrastructure rather than dead files, and retiring it means removing the workflow, the stories directory, and the four `@storybook/*` devDependencies together. That is unrelated to labeling columns and was deliberately not bundled here.

The original finding follows.

The Testing requirement, "A Storybook story shows all eight layouts", reads as new work. The file
already exists at `src/stories/authoring-section.stories.tsx` with eight exports, and it is absent
from the "Files expected to change" list.

It also carries a copy/paste bug in its last block:

```tsx
export const ResponsiveFullWidth = Template.bind({});
FullWidth.args = {                                  // <- assigns to FullWidth, not ResponsiveFullWidth
  id: "1", interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_RESPONSIVE_FULL_WIDTH
};
```

`ResponsiveFullWidth` therefore gets no args (falling back to `defaultLayout`), while `FullWidth`'s
args are overwritten. Verified live in Storybook:

| Story ID | Renders |
| --- | --- |
| `authoring-section--full-width` | `section-responsive-full-width` |
| `authoring-section--responsive-full-width` | `section-full-width` |

The two stories are swapped, and they are precisely the pair whose job under this story is to
demonstrate that **no column label renders**. A reviewer checking "full-width shows no label" would
be looking at the responsive-full-width story and vice versa.

Suggested resolution: add the stories file to "Files expected to change" and note that the fix is an
edit to existing stories plus this args bug, not a new file.

---

### Technical Writer (with QA Engineer)

#### RESOLVED: The label's typography is unspecified, two sections assume different values, and the specified tests cannot catch the disagreement
**Resolution**: The label is now specified in Requirements as **12px, bold, uppercase, `--dark-teal`**, with the DOM text node kept in sentence case so the accessible name stays `Primary column`. Settled by looking at what the codebase actually does rather than at `.teal-label`, which turned out to be **defined once and referenced nowhere in the repo**. The live precedent is `.sectionItemMenu` (12px uppercase) and the section header's menu buttons (11.5px uppercase); sentence case is reserved for form-control labels like the checkbox at 14px. Technical Notes now records that `.teal-label` is an orphan and points at the real precedent. The layout-text decision's 14px measurements are annotated as pre-dating the 12px decision and therefore conservative. The Accessibility section notes that `text-transform` changes neither the computed font-size nor the accessible name, so casing is a review item rather than a test item.

The requirement says each column "displays a visible label reading exactly `Primary column` or
`Secondary column`". Nothing in Requirements pins down size, weight, or casing, and two other
sections assume different values:

- the layout-text decision measured fit "against the existing `.teal-label` style (14px, bold,
  **uppercase**)";
- the Accessibility section states "The label is **12px** bold".

`.teal-label` (`authoring-section.scss:171-175`) is `{ color: var(--teal); font-weight: bold;
text-transform: uppercase; }`. An implementer following the house label style ships a label that
visibly reads `PRIMARY COLUMN`, contradicting "reads exactly `Primary column`".

**Evidence that the tests cannot catch this.** `text-transform` does not affect accessible-name
computation, so the required assertion passes for an uppercase-styled label:

```
uppercase label matches name 'Primary column': true
uppercase label matches name 'PRIMARY COLUMN':  false
```

The size discrepancy is harmless for contrast (12px and 14px bold are both below the 18.66px bold
large-text threshold, so 4.5:1 applies either way), but the casing question is a visible product
decision that currently has no home in the spec.

Suggested resolution: state the label's size, weight, and casing in Requirements, and say explicitly
whether it reuses `.teal-label`'s uppercase treatment (with `--dark-teal` substituted for `--teal`).

---

### Verified this round, no change needed

Re-tested against the current code and confirmed accurate:

- **The `grid-template-rows: min-content 1fr` decision generalizes.** Measured in the live component
  across all six two-column layouts, including `responsive-50-50` and `responsive-30-70`, whose
  column containers redefine `grid-template-columns`. Consistent across every layout: baseline
  282px/282px at offset 0; naive header 282/226 at offsets 23/79; `align-content: start` 282/**170**
  (a 40% shrink, matching the spec's 39%); `min-content 1fr` 282/282 at 23/23, exactly reproducing
  baseline geometry.
- **The accessibility mechanism works as specified.** `getByRole("group", { name: "Primary column" })`
  resolves through `aria-labelledby` in jsdom and returns the group containing the column's controls;
  the rejected bare-text-above-a-div alternative yields `null` for the same query.
- **The duplicate-ID bug reproduces exactly as the regression test describes.** Two sections rendered,
  clicking the second label toggles the first checkbox (`[false,false]` → `[true,false]`), and
  `label.control.id` resolves to `toggle-secondary-column` on the first section.
- **The contrast figures are exact.** `#016082` on `#cdebf2` = 5.59:1; `#0592af` on `#cdebf2` = 2.92:1.
- **A `disabled` option can be the rendered selection**, so the disabled-fallback requirement is
  implementable: Chromium reports `selectedIndex: 2` for a selected disabled option, and react-dom's
  matching branch does not check `disabled`.
- **The responsive layouts never stack.** The only `@media` rule in the Activity Player's
  `section.scss` is `(forced-colors: active)`, and `.section.responsive` has no `flex-wrap`.
- **`data-testid` on `SectionColumn` never reaches the DOM** (0 matching elements alongside 2 columns).
- **`changeLayout` moves every item into `secondary` for both full-width layouts**, as described.
- **No i18n infrastructure exists in `lara-typescript`**, so hardcoded English label strings are
  consistent with the codebase and need no translation plumbing.

Minor accuracy nit, **since fixed**: Technical Notes claimed `sections.ts`, `change-layout-utils.tsx`,
and `move-utils.tsx` were "each already paired with a co-located `.spec.ts`". Co-location is the
convention in `util/`, but coverage is partial: `change-layout-utils`, `move-utils`, and
`finding-utils` have specs; `sections.ts`, `array-util.ts`, and `accessibility-helper.ts` do not.
Technical Notes now says so, and still requires the new module to ship with its spec.

---

### Round 2, second pass

Re-reviewed after applying the five resolutions above. One gap, introduced by the Issue 2 fix
itself:

#### RESOLVED: Suppressing the label for unrecognized layouts left the `role="group"` requirement dangling
**Resolution**: The accessibility requirement was scoped to two-column layouts *with a recognized
layout*, and a bullet was added requiring the `role` and `aria-labelledby` to be tied to whether the
header actually rendered rather than to whether the layout is two-column.

Suppressing the label for unrecognized layouts created a case the accessibility requirement did not
anticipate: a two-column layout with no header. Read literally, the original wording still demanded
`role="group"` with `aria-labelledby` on both columns, so an implementer would have emitted a group
whose `aria-labelledby` pointed at an ID that was never rendered. That produces a group with no
accessible name, which is worse for a screen reader user than a plain unlabeled container.

No other new issues found. The remaining unverified claim in the spec is the manual 1200px
narrow-viewport check, which is viewport-dependent and deliberately not automated.

---

## Self-Review

### Senior Engineer

#### RESOLVED: "No new plumbing is strictly required" is wrong; SectionColumn cannot detect single-column layouts
**Resolution**: Technical Notes now states that `SectionColumn` requires a new explicit prop whose type admits "no label", documents why both `column` and `className` are unusable for this, and warns against keying behavior off the overloaded `section-responsive-fluid` class name.

Technical Notes claims the label can be derived from the `column` prop `SectionColumn` already receives. It cannot. Two of its current props are ambiguous for exactly the case the requirements care about: `columnValueForIndex(0)` returns `PRIMARY` for both full-width layouts, so `column` cannot distinguish them, and `className` cannot either, because `layoutClassNames` maps `LAYOUT_RESPONSIVE_FULL_WIDTH` to `["section-responsive-fluid"]` while `LAYOUT_RESPONSIVE_30_70` maps to `["section-responsive-static", "section-responsive-fluid"]`. The string `section-responsive-fluid` therefore means both "the only column of a single-column responsive section" and "the right-hand column of a responsive 30-70 section". A new explicit prop is required.

#### RESOLVED: Fallback dropdown option is undefined for a null or empty layout
**Resolution (later superseded)**: The layout dropdown requirements stated that null, undefined, and empty-string layouts are treated as the default and produce no fallback option, and that the fallback applies only to a non-empty unrecognized string. The fallback option was subsequently removed altogether after a data census; what survives from this finding is the requirement that the component must not normalize an empty layout to `full-width`, since doing so would collapse two rendered columns to one. Severity downgraded from defect to specification gap during review, since `sectionClassNames()` would throw on a null layout before the dropdown was reached, implying no such rows exist.

The requirement covers a stored layout that is "not one of the eight known values", but `sections.layout` is nullable in the schema and `AuthoringSection`'s `layout: initLayout = defaultLayout` default only fires on `undefined`, not `null`. Note `sectionClassNames()` calls `layout.toLowerCase()` unguarded, so a genuinely null layout would already throw today, which suggests such rows do not exist in practice, but the spec should say what the fallback does with a null or empty string rather than leaving it to the implementer.

#### RESOLVED: The home for the display-text map is left unspecified
**Resolution**: Technical Notes now names `section-authoring/util/` as the home for both pure helpers and explicitly rules out `api/api-types.ts`. Finding grew during review: the Testing requirement already called for unit tests of a "layout-to-primary-side helper" that does not exist, since `columnValueForIndex` is a closure inside `AuthoringSection`. The spec now requires extracting it as a pure function of `(layout, columnIndex)`.

Technical Notes says "possibly `api-types.ts`". That module is types plus enums; putting author-facing display strings there mixes concerns. The spec should either name a module or state the criterion.

---

### QA Engineer

#### RESOLVED: Not specified whether the legacy fallback option is selectable
**Resolution (later superseded)**: The fallback option was specified as `disabled`, making it visible but not choosable, so switching away from a legacy layout would be one-way, and a matching test was added. Moot as of the data census: there is no fallback option. See the legacy-layout decision above.

If a section carries an unknown layout, the dropdown gains an option showing the raw value. Nothing says whether an author can re-select it after switching away, which would write an unknown value back deliberately. It should almost certainly be disabled, but the spec must say so or QA cannot test it.

#### RESOLVED: The narrow-viewport regression the spec identifies has no acceptance criterion
The original finding, and the Technical Notes paragraph it referred to, were **wrong on both the mechanism and the numbers**. They claimed `.menuStart`'s `overflow: hidden` clips the checkbox label below roughly 1100px. Re-measured with real viewport resizes rather than a CSS body-width hack: nothing is ever clipped (`scrollWidth === clientWidth` at every width down to 1000px), the degradation is wrapping, and the affected band is roughly 1140 to 1210px rather than "below 1100".

**Resolution**: Technical Notes now carries the measured table under "Narrow-viewport effect on the section header", and Testing gained a manual verification step at 1200px. The effect is recorded as an accepted cosmetic consequence (17px taller header in a ~70px band of viewport widths) rather than a defect.

---

### WCAG Accessibility Expert

#### RESOLVED: The obvious label color fails AA, and the requirement does not name a color
**Resolution**: the Accessibility section now specifies `--dark-teal` `#016082` on `--ltr-teal` `#cdebf2` at 5.59:1, explicitly rules out `--teal` (2.92:1, fails at any size), and records that the 12px bold label falls under the 4.5:1 threshold rather than 3:1. Both colours are existing `vars.scss` tokens, so no palette change is involved. Technical Notes was updated to warn against reusing `.teal-label`'s colour. Note that all prototype screenshots in this spec used the failing `--teal`.

"Label text meets WCAG AA contrast against its background" is stated without specifying colors, and the natural choice fails. Measured ratios: `--teal` `#0592af` on `--ltr-teal` `#cdebf2`, which is the section background the chosen placement puts the label on, is **2.92:1 and fails AA at any text size**. That is the exact combination used in the prototypes. `--dark-teal` `#016082` on the same background is 5.59:1 and passes; `--dark-gray` `#3f3f3f` is 8.41:1. For reference the existing `.teal-label` and `sectionMenu` styles are themselves marginal (white on `--teal` is 3.66:1, passing only as large/bold text), so matching existing styling would inherit a defect.

#### RESOLVED: "Exposed to screen readers as part of the column's accessible structure" is not implementable or testable
**Resolution**: the Accessibility section now requires `role="group"` plus `aria-labelledby` on the column container, and the Testing section requires assertions by accessible role and name. Verified against the real accessibility tree: a bare text node above a `<div>` yields loose `generic` text with no association, while `role="group"` + `aria-labelledby` yields `group "Primary column"` containing the column's controls. `aria-labelledby` was chosen over `aria-label` so the visible and announced labels cannot diverge, and `group` over `region` to avoid landmark pollution.

The requirement names no mechanism. A visible text node above a `<div>` gives a screen reader user no association between the label and the column's contents; they would hear "Primary column" as loose text while arrowing through. The spec should require a concrete association, for example `role="group"` with `aria-labelledby` pointing at the header's per-section unique ID, and the test should assert the accessible name.

---

### Education Material Developer

#### RESOLVED (declined): The story satisfies half of the author's stated request, and the other half has nowhere to go
Jie's comment made two asks: "there is no clear indication of which column is the primary column in authoring" and "as an author, I would want to choose which column should be the primary column." This story fully addresses the first and explicitly places the second out of scope. A Jira search across LARA and AP for "primary column", "stick to top", and "sticky column" returned only LARA-220 and AP-129, confirming no follow-up ticket exists for the second ask.

**Resolution: declined by decision.** This spec covers adding the labels only. A Follow-ups section was proposed and rejected as scope creep; tracking the deferred work is a Jira concern, not this document's. The existing Out of Scope entries already record what is deferred and why, which is sufficient for a spec. No tickets were filed.
