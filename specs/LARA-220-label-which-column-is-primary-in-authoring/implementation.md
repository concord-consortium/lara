# Implementation Plan: Label which column is primary in authoring

**Jira**: https://concord-consortium.atlassian.net/browse/LARA-220
**Requirements Spec**: [requirements.md](requirements.md)
**Status**: **In Development**

## Implementation Plan

Four commits, in order. Each is independently reviewable and leaves the app working. The first is
a pure refactor with no author-visible change; the remaining three each land one author-visible
behavior plus its tests.

All work is inside `lara-typescript/src/section-authoring/`. No Ruby, no migration, no Activity
Player change. Remember that `lara-typescript` must be rebuilt (`NODE_OPTIONS=--openssl-legacy-provider
npm run build:webpack`) before running the Rails app locally; CI does this itself.

---

### Extract the layout derivations into a testable util module

**Summary**: `columnValueForIndex` is currently a closure inside `AuthoringSection` that captures
`layout` from state, so it is neither importable nor unit-testable, and the Testing requirement asks
for unit tests of a "layout-to-primary-side helper" that does not yet exist. This step creates
`util/section-layout-utils.ts` holding every pure piece of this story (the layout-to-display-text map,
the layout-to-column-role derivations, and the two label strings), and rewires `AuthoringSection` to
call the extracted version. Nothing renders differently: this commit is a pure refactor whose diff can
be reviewed for behavioral equivalence on its own, before any of the visible changes land on top of it.

**Files affected**:
- `lara-typescript/src/section-authoring/util/section-layout-utils.ts` — new module
- `lara-typescript/src/section-authoring/util/section-layout-utils.spec.ts` — new unit spec
- `lara-typescript/src/section-authoring/components/authoring-section.tsx` — delete the local closure, call the extracted helper

**Estimated diff size**: ~230 lines

#### New file: `util/section-layout-utils.ts`

Note the `string` parameter types. `ISection.layout` is declared `layout?: SectionLayouts`
(`api/api-types.ts:220`), a closed enum, but unrecognized values genuinely occur at runtime, and those
are the cases these helpers exist to handle. Typing the parameters to the enum would make the
unrecognized branches dead by construction and their unit tests unwritable without a cast.
`classNameForItem` (`authoring-section.tsx:27-35`) already guards the same way against a value its own
signature says is always valid.

```ts
import { SectionColumns, SectionLayouts } from "../api/api-types";

/**
 * Layouts that render a single column. The primary/secondary distinction has no
 * author-visible meaning when there is only one column, so these carry no column label.
 */
const singleColumnLayouts: string[] = [
  SectionLayouts.LAYOUT_FULL_WIDTH,
  SectionLayouts.LAYOUT_RESPONSIVE_FULL_WIDTH
];

/**
 * Layouts that render the primary column on the right. Mirrors `primary_right_layouts`
 * in app/models/interactive_page.rb and `leftPrimary` in the Activity Player's section.tsx.
 */
const primaryRightLayouts: string[] = [
  SectionLayouts.LAYOUT_40_60,
  SectionLayouts.LAYOUT_30_70,
  SectionLayouts.LAYOUT_RESPONSIVE_30_70,
  SectionLayouts.LAYOUT_RESPONSIVE_50_50
];

const knownLayouts: string[] = Object.values(SectionLayouts);

/**
 * Display text for the Layout dropdown. The stored token is kept verbatim, because it is
 * the value authors see in the help doc and in years of support conversations; the
 * parenthetical says where the primary column lands. Unknown layouts fall back to the raw
 * stored string.
 */
const layoutDisplayText: {[layout: string]: string} = {
  [SectionLayouts.LAYOUT_FULL_WIDTH]: "full-width (single column)",
  [SectionLayouts.LAYOUT_60_40]: "60-40 (primary on left)",
  [SectionLayouts.LAYOUT_40_60]: "40-60 (primary on right)",
  [SectionLayouts.LAYOUT_70_30]: "70-30 (primary on left)",
  [SectionLayouts.LAYOUT_30_70]: "30-70 (primary on right)",
  [SectionLayouts.LAYOUT_RESPONSIVE_30_70]: "responsive-30-70 (primary on right)",
  [SectionLayouts.LAYOUT_RESPONSIVE_50_50]: "responsive-50-50 (primary on right)",
  [SectionLayouts.LAYOUT_RESPONSIVE_FULL_WIDTH]: "responsive-full-width (single column)"
};

/**
 * Column label text. Sentence case in the DOM; the CSS uppercases it, which leaves the
 * accessible name as written here.
 */
const columnLabelText = {
  [SectionColumns.PRIMARY]: "Primary column",
  [SectionColumns.SECONDARY]: "Secondary column"
};

export const isKnownLayout = (layout: string) => knownLayouts.indexOf(layout) !== -1;

export const isSingleColumnLayout = (layout: string) => singleColumnLayouts.indexOf(layout) !== -1;

export const displayTextForLayout = (layout: string) => layoutDisplayText[layout] || layout;

export const labelForColumn = (column: SectionColumns) => columnLabelText[column];

/**
 * Which stored `column` value a rendered column index holds. For a layout outside the enum
 * this reports primary-on-left, which is what partitions the section's existing items today.
 * Changing that fallback would silently move author content between columns, so it stays.
 */
export const columnValueForIndex = (layout: string, columnIndex: number): SectionColumns => {
  if (isSingleColumnLayout(layout)) {
    return SectionColumns.PRIMARY;
  }
  if (primaryRightLayouts.indexOf(layout) !== -1) {
    return columnIndex === 0 ? SectionColumns.SECONDARY : SectionColumns.PRIMARY;
  }
  return columnIndex === 0 ? SectionColumns.PRIMARY : SectionColumns.SECONDARY;
};

/**
 * Which column role to LABEL a rendered column with, or undefined when no label should be
 * shown. Deliberately does NOT inherit columnValueForIndex's fallback: an unrecognized
 * layout renders two columns, but LARA's own Ruby export and the Activity Player disagree
 * about which of them is primary, so a label there would risk saying the opposite of what
 * students see. Single-column layouts return undefined for the same "no label" reason.
 */
export const columnLabelRoleForIndex =
  (layout: string, columnIndex: number): SectionColumns | undefined => {
    if (!isKnownLayout(layout) || isSingleColumnLayout(layout)) {
      return undefined;
    }
    return columnValueForIndex(layout, columnIndex);
  };
```

#### New file: `util/section-layout-utils.spec.ts`

```ts
import { SectionColumns, SectionLayouts } from "../api/api-types";
import {
  columnLabelRoleForIndex,
  columnValueForIndex,
  displayTextForLayout,
  isKnownLayout,
  isSingleColumnLayout,
  labelForColumn
} from "./section-layout-utils";

const { PRIMARY, SECONDARY } = SectionColumns;

describe("displayTextForLayout", () => {
  const cases: Array<[string, string]> = [
    ["full-width", "full-width (single column)"],
    ["60-40", "60-40 (primary on left)"],
    ["40-60", "40-60 (primary on right)"],
    ["70-30", "70-30 (primary on left)"],
    ["30-70", "30-70 (primary on right)"],
    ["responsive-30-70", "responsive-30-70 (primary on right)"],
    ["responsive-50-50", "responsive-50-50 (primary on right)"],
    ["responsive-full-width", "responsive-full-width (single column)"]
  ];

  cases.forEach(([layout, expected]) => {
    it(`renders ${layout} as "${expected}"`, () => {
      expect(displayTextForLayout(layout)).toBe(expected);
    });
  });

  it("covers every layout in the enum", () => {
    Object.values(SectionLayouts).forEach(layout => {
      expect(displayTextForLayout(layout)).not.toBe(layout);
    });
    expect(cases.length).toBe(Object.values(SectionLayouts).length);
  });

  it("falls back to the raw value for an unrecognized layout", () => {
    expect(displayTextForLayout("responsive")).toBe("responsive");
    expect(displayTextForLayout("")).toBe("");
  });
});

describe("isKnownLayout / isSingleColumnLayout", () => {
  it("recognizes the eight enum values and nothing else", () => {
    Object.values(SectionLayouts).forEach(layout => expect(isKnownLayout(layout)).toBe(true));
    expect(isKnownLayout("responsive")).toBe(false);
    expect(isKnownLayout("")).toBe(false);
  });

  it("identifies the two single-column layouts", () => {
    expect(isSingleColumnLayout("full-width")).toBe(true);
    expect(isSingleColumnLayout("responsive-full-width")).toBe(true);
    expect(isSingleColumnLayout("60-40")).toBe(false);
    expect(isSingleColumnLayout("responsive")).toBe(false);
  });
});

describe("columnValueForIndex", () => {
  const cases: Array<[string, SectionColumns, SectionColumns]> = [
    ["full-width", PRIMARY, PRIMARY],
    ["responsive-full-width", PRIMARY, PRIMARY],
    ["60-40", PRIMARY, SECONDARY],
    ["70-30", PRIMARY, SECONDARY],
    ["40-60", SECONDARY, PRIMARY],
    ["30-70", SECONDARY, PRIMARY],
    ["responsive-30-70", SECONDARY, PRIMARY],
    ["responsive-50-50", SECONDARY, PRIMARY]
  ];

  cases.forEach(([layout, first, second]) => {
    it(`maps ${layout} to ${first} / ${second}`, () => {
      expect(columnValueForIndex(layout, 0)).toBe(first);
      expect(columnValueForIndex(layout, 1)).toBe(second);
    });
  });

  it("preserves the primary-on-left fallback for an unrecognized layout, which partitions items", () => {
    expect(columnValueForIndex("responsive", 0)).toBe(PRIMARY);
    expect(columnValueForIndex("responsive", 1)).toBe(SECONDARY);
  });
});

describe("columnLabelRoleForIndex", () => {
  it("labels the left column primary for 60-40 and 70-30", () => {
    ["60-40", "70-30"].forEach(layout => {
      expect(columnLabelRoleForIndex(layout, 0)).toBe(PRIMARY);
      expect(columnLabelRoleForIndex(layout, 1)).toBe(SECONDARY);
    });
  });

  it("labels the right column primary for the four primary-right layouts", () => {
    ["40-60", "30-70", "responsive-30-70", "responsive-50-50"].forEach(layout => {
      expect(columnLabelRoleForIndex(layout, 0)).toBe(SECONDARY);
      expect(columnLabelRoleForIndex(layout, 1)).toBe(PRIMARY);
    });
  });

  it("returns undefined for single-column layouts", () => {
    expect(columnLabelRoleForIndex("full-width", 0)).toBeUndefined();
    expect(columnLabelRoleForIndex("responsive-full-width", 0)).toBeUndefined();
  });

  it("returns undefined for unrecognized and empty layouts, unlike columnValueForIndex", () => {
    expect(columnLabelRoleForIndex("responsive", 0)).toBeUndefined();
    expect(columnLabelRoleForIndex("responsive", 1)).toBeUndefined();
    expect(columnLabelRoleForIndex("", 0)).toBeUndefined();
  });
});

describe("labelForColumn", () => {
  it("uses sentence case, so the accessible name is not shouted", () => {
    expect(labelForColumn(PRIMARY)).toBe("Primary column");
    expect(labelForColumn(SECONDARY)).toBe("Secondary column");
  });
});
```

#### `components/authoring-section.tsx`

Add the import (the file already imports from `../util/change-layout-utils` and `../util/sections`):

```tsx
import { columnValueForIndex } from "../util/section-layout-utils";
```

Delete the local closure at `:210-236` in full (the declaration through its closing `};`, stopping
before `const addItem`):

```tsx
// BEFORE — delete all of this
const columnValueForIndex = (columnNumber: number): SectionColumns => {
  // if our layout is full-width we are SectionColumns.primary
  // ... 20 more lines ...
  return SectionColumns.SECONDARY;
};
```

and update its four call sites, which currently pass only the index, so they pass `layout` first:
`columnValueForIndex(0)` becomes `columnValueForIndex(layout, 0)`, and likewise for index 1.
Concretely, the two `<SectionColumn>` blocks become:

```tsx
{<SectionColumn
  addItem={addItem}
  addPageItem={addPageItem}
  className={classNameForItem(layout, 0)}
  column={columnValueForIndex(layout, 0)}
  columnNumber={1}
  items={getColumnItems(columnValueForIndex(layout, 0))}
  sectionId={id}
/>
}
{(layout !== "full-width" && layout !== "responsive-full-width") &&
  <SectionColumn
    addItem={addItem}
    addPageItem={addPageItem}
    className={classNameForItem(layout, 1)}
    column={columnValueForIndex(layout, 1)}
    columnNumber={2}
    items={getColumnItems(columnValueForIndex(layout, 1))}
    sectionId={id}
  />
}
```

The dead `data-testid` props are dropped here (they never reached the DOM, because `SectionColumn`
destructures only its declared props) and nothing replaces them: the tests identify columns by
accessible role and by the `.col-N` class instead. See the testid decision under Open Questions.
`SectionColumns` is still used by `addItem` and `getColumnItems`, so its import stays.

---

### Make the section header's element IDs unique per section

**Summary**: `id="section_layout"` and `id="toggle-secondary-column"` are hardcoded, so every section
on the page emits the same two IDs. Because each `<label>` carries `htmlFor` (which wins over
wrapping), clicking "Allow student to hide secondary column" on any section below the first toggles
**section 1's** checkbox and fires section 1's save. This is a pre-existing defect, fixed here because
the new column header needs the unique-ID-per-element pattern anyway and this is the file that
establishes it. This step also creates the component spec file the later steps extend.

A repo-wide search confirms nothing else references these IDs: the only other hits are an unrelated
Ruby local variable in `db/migrate/20220628163733_convert_activities_to_new_sections_schema.rb`. No
CSS rule, no feature spec, no other consumer.

**Call this defect out explicitly in the PR description**, so QA tests it rather than discovering it
inside a labeling story. No separate Jira bug is filed; see the commit-structure decision under Open
Questions for why.

**Files affected**:
- `lara-typescript/src/section-authoring/components/authoring-section.tsx` — derive both IDs from the section ID
- `lara-typescript/src/section-authoring/components/authoring-section.spec.tsx` — new component spec

**Estimated diff size**: ~70 lines

#### `components/authoring-section.tsx`

Add near the other derived values, just above the `return`:

```tsx
const layoutSelectId = `section-layout-${id}`;
const toggleSecondaryColumnId = `toggle-secondary-column-${id}`;
```

Then:

```tsx
// BEFORE
<label htmlFor="section_layout">Layout: </label>
<select
  id="section_layout"
  ...

// AFTER
<label htmlFor={layoutSelectId}>Layout: </label>
<select
  id={layoutSelectId}
  ...
```

```tsx
// BEFORE
<label className={toggleSecondaryColumnOptionClass} htmlFor="toggle-secondary-column">
  <input
    data-testid="toggle-secondary-column-checkbox"
    ...
    id="toggle-secondary-column"

// AFTER
<label className={toggleSecondaryColumnOptionClass} htmlFor={toggleSecondaryColumnId}>
  <input
    data-testid="toggle-secondary-column-checkbox"
    ...
    id={toggleSecondaryColumnId}
```

The `name` attributes (`section[layout]`, `can_collapse_small`) are unchanged: they are not IDs, they
are not used for label association, and nothing keys off them here.

#### New file: `components/authoring-section.spec.tsx`

This is the first component test in `section-authoring`. No hand-written mocks are needed:
`APIContainer` falls back to `mock-api-provider` whenever no `host` prop is given, so wrapping the
component is the entire harness.

```tsx
import * as React from "react";
import { fireEvent, render, screen } from "@testing-library/react";
import { AuthoringSection } from "./authoring-section";
import { APIContainer } from "../containers/api-container";
import { SectionLayouts } from "../api/api-types";

// Some tests render layouts outside the SectionLayouts enum. Those values do occur at
// runtime (legacy `responsive`, imported values, a nullable column with no model
// validation), so the cast is deliberate.
const asLayout = (layout: string) => layout as SectionLayouts;

const renderSection = (layout: string, id = "1") =>
  render(
    <APIContainer>
      <AuthoringSection id={id} interactive_page_id="2" layout={asLayout(layout)} />
    </APIContainer>
  );

const renderTwoSections = () =>
  render(
    <APIContainer>
      <AuthoringSection id="1" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
      <AuthoringSection id="2" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
    </APIContainer>
  );

describe("AuthoringSection element IDs", () => {
  it("derives the layout select and collapse checkbox IDs from the section ID", () => {
    renderSection("60-40", "42");
    expect(document.getElementById("section-layout-42")).not.toBeNull();
    expect(document.getElementById("toggle-secondary-column-42")).not.toBeNull();
  });

  it("clicking a section's collapse label toggles that section's own checkbox", () => {
    renderTwoSections();

    const checkboxes = screen.getAllByTestId("toggle-secondary-column-checkbox") as HTMLInputElement[];
    const labels = screen.getAllByText("Allow student to hide secondary column");
    expect(checkboxes.length).toBe(2);
    expect(checkboxes.map(c => c.checked)).toEqual([false, false]);

    // Before the fix this toggled the FIRST section's checkbox.
    fireEvent.click(labels[1]);
    expect(checkboxes.map(c => c.checked)).toEqual([false, true]);
  });

  it("associates each section's Layout label with that section's own dropdown", () => {
    renderTwoSections();

    const labels = screen.getAllByText("Layout:") as HTMLLabelElement[];
    const selects = screen.getAllByRole("combobox") as HTMLSelectElement[];
    expect(labels.length).toBe(2);
    // Before the fix both labels resolved to the FIRST section's dropdown.
    labels.forEach((label, index) => expect(label.control).toBe(selects[index]));
  });

  it("emits no duplicate element IDs across sections", () => {
    renderTwoSections();
    const ids = Array.from(document.querySelectorAll("[id]")).map(e => e.id);
    expect(ids.filter((v, i) => ids.indexOf(v) !== i)).toEqual([]);
  });
});
```

The Layout-label test covers the second half of the duplicate-ID requirement, which the click test cannot
reach: jsdom's label activation behavior forwards a click to the labeled control, which toggles a
checkbox but does nothing observable to a `<select>`. `HTMLLabelElement.control` asserts the association
itself, which is what the requirement is about, and it fails when the select's ID is reverted to the
hardcoded value.

`within` is deliberately **not** imported here. It is only needed by the last step's "Add Item inside
the labeled group" test, and `npm run lint:unused` runs `tsc --noUnusedLocals`, which fails on an
import added ahead of its use. Add it to the import list in that step.

---

### Give the Layout dropdown readable option text

**Summary**: the dropdown's options are currently the raw stored values, so an author choosing a
layout has no way to know which side the primary column lands on. Each option gains a parenthetical
hint, while its `value` stays byte-identical to the stored token.

An earlier version of this step also added a disabled fallback option for stored layouts outside the
enum. That was **removed** after a census of both deployed environments found zero such rows; see the
legacy-layout decision in the requirements spec. Nothing about the unrecognized case is handled here
any more, and the dropdown's behavior for one is unchanged from today.

**Files affected**:
- `lara-typescript/src/section-authoring/components/authoring-section.tsx` — option text
- `lara-typescript/src/section-authoring/components/authoring-section.spec.tsx` — tests

**Estimated diff size**: ~35 lines

#### `components/authoring-section.tsx`

Extend the import:

```tsx
import { columnValueForIndex, displayTextForLayout } from "../util/section-layout-utils";
```

```tsx
// BEFORE
{
  Object.values(SectionLayouts).map( (l) => {
    return (
      <option key={l} value={l}>{l}</option>
    );
  })
}

// AFTER
{
  Object.values(SectionLayouts).map( (l) => {
    return (
      <option key={l} value={l}>{displayTextForLayout(l)}</option>
    );
  })
}
```

That is the whole change to the control: the option list is still the eight enum values in their
existing order, with only the rendered text differing. `value={l}` is untouched, so nothing about what
gets stored changes.

#### `components/authoring-section.spec.tsx` — append

```tsx
describe("AuthoringSection layout dropdown", () => {
  it("shows each layout's stored token plus a hint about where the primary column lands", () => {
    renderSection("60-40");
    const options = screen.getAllByRole("option") as HTMLOptionElement[];
    expect(options.map(o => o.text)).toEqual([
      "full-width (single column)",
      "60-40 (primary on left)",
      "40-60 (primary on right)",
      "70-30 (primary on left)",
      "30-70 (primary on right)",
      "responsive-30-70 (primary on right)",
      "responsive-50-50 (primary on right)",
      "responsive-full-width (single column)"
    ]);
  });

  it("leaves the stored values untouched", () => {
    renderSection("60-40");
    const options = screen.getAllByRole("option") as HTMLOptionElement[];
    expect(options.map(o => o.value)).toEqual(Object.values(SectionLayouts));
  });

  it("adds no option for an unrecognized stored layout", () => {
    renderSection("responsive");
    const select = screen.getByRole("combobox") as HTMLSelectElement;
    // The option list is exactly the enum. react-dom finds no match and selects the first
    // option, so the control reads `full-width`. Zero such rows exist in production or
    // staging, so no fallback option is offered for them.
    expect(select.options.length).toBe(Object.values(SectionLayouts).length);
    expect(select.value).toBe("full-width");
  });
});
```

Note the last test pins *current* behavior rather than new behavior. It is worth keeping as a guard:
it is the assertion that would fail if someone later reintroduced a fallback option without revisiting
the census, and it documents that `full-width` here is a decision rather than an oversight.

---

### Label each column in the section editor

**Summary**: each column of a two-column section gets a `PRIMARY COLUMN` / `SECONDARY COLUMN` header
that is also the column's accessible name, so an author can see which column is which without
inferring it from the layout token. `SectionColumn` gains an explicit `columnRole` prop whose type
admits "no label"; neither of its existing props can express that, because `column` is `PRIMARY` for
both single-column layouts and `className` is overloaded (`section-responsive-fluid` means both "the
only column of a responsive full-width section" and "the right column of a responsive 30-70 section").

**Files affected**:
- `lara-typescript/src/section-authoring/components/section-column.tsx` — new prop, header markup, group semantics
- `lara-typescript/src/section-authoring/components/section-column.scss` — header styling and the grid-row fix
- `lara-typescript/src/section-authoring/components/authoring-section.tsx` — pass `columnRole`
- `lara-typescript/src/section-authoring/components/authoring-section.spec.tsx` — tests

**Estimated diff size**: ~135 lines

#### `components/section-column.tsx`

Import the label helper:

```tsx
import { labelForColumn } from "../util/section-layout-utils";
```

Add the prop to `ISectionColumnProps`, after `columnNumber`:

```tsx
  /**
   * Which column role to label this column with, or undefined to render no header:
   * single-column layouts, where the distinction has no author-visible meaning, and
   * unrecognized layouts, where LARA and the Activity Player disagree about which column
   * is primary. Undefined must suppress the header, the role, and the aria-labelledby
   * together: a group whose aria-labelledby points at a missing ID has no accessible name,
   * which is worse than a plain container.
   */
  columnRole?: SectionColumns;
```

Add `columnRole` to the destructuring list (between `columnNumber` and `items`), then derive the ID
and rewrite the container:

```tsx
  // Unique per COLUMN, not per section: a section renders two headers, and an ID that is
  // merely unique per section gives both columns the accessible name of the first one, so no
  // column is announced as Secondary.
  const columnHeaderId = `section-${sectionId}-column-${columnNumber}-label`;
```

```tsx
// BEFORE
<div className={`edit-page-grid-container col-${columnNumber} ${className}`}>
  <Droppable droppableId={`droppableCol${columnNumber}`}>

// AFTER
<div
  className={`edit-page-grid-container col-${columnNumber} ${className}${columnRole ? " hasColumnHeader" : ""}`}
  role={columnRole ? "group" : undefined}
  aria-labelledby={columnRole ? columnHeaderId : undefined}
>
  { columnRole &&
    <div className="columnHeader full-row" id={columnHeaderId}>
      {labelForColumn(columnRole)}
    </div>
  }
  <Droppable droppableId={`droppableCol${columnNumber}`}>
```

Four things are load-bearing here and each was measured against the real component:

- **The header is a `<div>`, not a `<header>` and not a heading.** A `<header>` element becomes a
  `banner` landmark unless it descends from `article`, `aside`, `main`, `nav`, or `section`, and
  `role="group"` on the parent does not exempt it; using one produced an extra banner landmark per
  column. A heading is ruled out for the matching reason: `<h4>` would sit at the same outline level
  as the section item titles nested inside the column, and `<h3>` collides with the section name.
- **`full-row`** (`grid-column: span 10`, `authoring-section.scss:229`) is required. The column
  container is itself a ten-track grid, so a header without it auto-places into track 1 of 10 and
  wraps to two lines in every layout except `responsive-50-50`. It is the same class the sibling
  `.edit-items-container` already uses, so this is not a new cross-file coupling.
- **`role="group"`, not `role="region"`.** A region is a landmark, and two per section on every
  section of a page would swamp the landmark list.
- **The header sits before the `<Droppable>`**, outside the drag-and-drop subtree, because it is
  metadata about the column rather than content in it.

#### `components/section-column.scss`

Add above `.itemsContainer`. `--dark-teal` and the surrounding tokens come from the `@import
"../../vars.scss"` already at the top of the file.

```scss
// Scoped to columns that actually render a header. Without this, the shorter column's
// leftover height is distributed into its auto-sized rows, inflating its header from ~25px
// to ~79px and pushing its content 51px below the other column's. The obvious alternative,
// `align-content: start`, realigns the headers but shrinks the shorter column's drop target
// by ~40%, because today that column's .edit-items-container stretches to fill the column and
// that stretch is what makes the whole empty area a valid drop zone.
.edit-page-grid-container.hasColumnHeader {
  grid-template-rows: min-content 1fr;
}

// Structural chrome, so it follows the uppercase idiom of .sectionItemMenu (12px uppercase)
// rather than the sentence case used for form-control labels. Bold because it sits on the
// light --ltr-teal column background rather than a solid teal bar. --dark-teal on --ltr-teal
// measures 5.59:1 and passes AA; --teal (what the orphaned .teal-label uses) is 2.92:1 and
// fails at any size.
.columnHeader {
  color: var(--dark-teal);
  font-size: 12px;
  font-weight: bold;
  padding: 6px 10px 4px;
  text-transform: uppercase;
}
```

Measured with this rule in the live editor at a 1400px viewport: the header is 25px tall and spans the
full column in every two-column layout, both columns' drop zones start at the same 25px offset with
their height unchanged from today (282px each in a `60-40` section holding two items on the left and
one on the right), and the label stays on one line even in the narrowest column in the editor (the
305px static column of `responsive-30-70`, where the label renders 128px wide). The horizontal
padding matches `.itemsContainer`'s 10px, so the label aligns with the item cards below it.

#### `components/authoring-section.tsx`

Extend the import and pass the prop:

```tsx
import {
  columnLabelRoleForIndex,
  columnValueForIndex,
  displayTextForLayout
} from "../util/section-layout-utils";
```

(`isKnownLayout` stays exported and unit-tested, but `AuthoringSection` no longer imports it: its only
consumer is `columnLabelRoleForIndex` inside the util module.)

```tsx
// first column
columnNumber={1}
columnRole={columnLabelRoleForIndex(layout, 0)}

// second column
columnNumber={2}
columnRole={columnLabelRoleForIndex(layout, 1)}
```

#### `components/authoring-section.spec.tsx` — append

Extend the import line added in the earlier step to bring in `within`, which the last test needs:

```tsx
import { fireEvent, render, screen, within } from "@testing-library/react";
```

Assertions are by accessible role and name rather than by text, so a dropped `aria-labelledby`
fails the test rather than passing on a stray text node.

```tsx
// labelsInOrder reads the accessible name of each labeled group in DOM order, which is visual
// order: nothing in the SCSS uses `order` or `direction`, so grid places col-1 left and col-2
// right in every layout. Asserting the ORDER states the actual requirement, which is which
// SIDE the primary column is on.
const labelsInOrder = () =>
  screen.queryAllByRole("group").map(g =>
    document.getElementById(g.getAttribute("aria-labelledby") as string)?.textContent);

// renderedColumns counts the column containers. The section container carries the same
// `edit-page-grid-container` class, so the `col-` filter is what separates them:
//   [0] edit-page-grid-container sectionContainer section-60-40
//   [1] edit-page-grid-container col-1 section-60 hasColumnHeader
//   [2] edit-page-grid-container col-2 section-40 hasColumnHeader
// `.col-N` is a load-bearing SCSS selector (section-item.scss, authoring-section.scss), not
// incidental markup, so it will not quietly rot.
const renderedColumns = (container: HTMLElement) =>
  container.querySelectorAll(".edit-page-grid-container[class*='col-']");

describe("AuthoringSection column labels", () => {
  ["60-40", "70-30"].forEach(layout => {
    it(`labels the left column primary for ${layout}`, () => {
      renderSection(layout);
      expect(labelsInOrder()).toEqual(["Primary column", "Secondary column"]);
    });
  });

  ["40-60", "30-70", "responsive-30-70", "responsive-50-50"].forEach(layout => {
    it(`labels the right column primary for ${layout}`, () => {
      renderSection(layout);
      expect(labelsInOrder()).toEqual(["Secondary column", "Primary column"]);
    });
  });

  ["full-width", "responsive-full-width"].forEach(layout => {
    it(`renders one column and no label for ${layout}`, () => {
      const { container } = renderSection(layout);
      expect(renderedColumns(container).length).toBe(1);
      expect(screen.queryAllByRole("group")).toEqual([]);
    });
  });

  ["responsive", ""].forEach(layout => {
    it(`renders two columns but no label for the unrecognized layout "${layout}"`, () => {
      const { container } = renderSection(layout);
      // The column count matters: without it the test would pass if nothing rendered at all.
      expect(renderedColumns(container).length).toBe(2);
      expect(screen.queryAllByRole("group")).toEqual([]);
      expect(screen.queryByText("Primary column")).toBeNull();
    });
  });

  it("updates the labels when the layout changes, with no reload", () => {
    renderSection("60-40");
    expect(labelsInOrder()).toEqual(["Primary column", "Secondary column"]);

    fireEvent.change(screen.getByRole("combobox"), { target: { value: "30-70" } });
    // The primary column has moved to the right.
    expect(labelsInOrder()).toEqual(["Secondary column", "Primary column"]);

    fireEvent.change(screen.getByRole("combobox"), { target: { value: "full-width" } });
    expect(labelsInOrder()).toEqual([]);
  });

  it("gives each column its own header ID, so both columns get their own accessible name", () => {
    renderSection("60-40", "42");
    expect(document.getElementById("section-42-column-1-label")?.textContent).toBe("Primary column");
    expect(document.getElementById("section-42-column-2-label")?.textContent).toBe("Secondary column");
    // The per-column ID is what makes these two distinct names resolvable. A per-SECTION ID
    // would give both groups the first header's name.
    expect(screen.getByRole("group", { name: "Primary column" })).not.toBeNull();
    expect(screen.getByRole("group", { name: "Secondary column" })).not.toBeNull();
  });

  it("marks labeled columns with hasColumnHeader, which is what aligns the two drop zones", () => {
    const twoColumn = renderSection("60-40").container;
    expect(Array.from(renderedColumns(twoColumn)).map(c => c.classList.contains("hasColumnHeader")))
      .toEqual([true, true]);

    ["full-width", "responsive"].forEach(layout => {
      const { container } = renderSection(layout);
      Array.from(renderedColumns(container)).forEach(c => {
        expect(c.classList.contains("hasColumnHeader")).toBe(false);
      });
    });
  });

  it("keeps the Add Item control inside the labeled group", () => {
    renderSection("60-40");
    const primary = screen.getByRole("group", { name: "Primary column" });
    expect(within(primary).getByTestId("add-item-button")).not.toBeNull();
  });
});
```

`hasColumnHeader` is asserted even though the `grid-template-rows` rule it triggers does not exist in
jsdom. The class is plain markup, and it is the sole hook for that rule, so dropping it would misalign
the shorter column's content with a green suite otherwise. The test isolates cleanly: removing the class
fails it and nothing else.

Note what these tests deliberately do **not** cover. `text-transform` is invisible to accessible-name
computation, so `getByRole("group", { name: "Primary column" })` matches an uppercase-styled label and
does not match `"PRIMARY COLUMN"`. The casing is therefore a review item, not a test item, as is the
`--dark-teal` colour and the `grid-template-rows` geometry, none of which exist in jsdom (`.scss`
imports are mapped to `identity-obj-proxy`).

---

## Verification

### Automated

```bash
cd lara-typescript
npm run lint                 # local only: CI does not run tslint
npx jest src/section-authoring
```

Both were run against a full build of this plan: 81 tests across 5 suites pass, and lint is clean under
both `tslint.json` and `tslint-build.json`. Do **not** use `npm run lint:unused` as a gate; it reports
91 pre-existing errors on master. See the Self-Review for both points.

### Manual, before merge

- **Narrow-viewport check at 1200px.** The wider dropdown moves the section header's wrap threshold
  from roughly 1140px to roughly 1210px, so in that ~70px band the header grows from 40px to 57px:
  the checkbox label wraps and DELETE drops onto its own line. Nothing is clipped
  (`scrollWidth === clientWidth` at every width down to 1000px). Confirm this matches the accepted
  behavior described in the requirements; it is viewport-dependent, so a jsdom assertion would be
  meaningless.
- **Drag and drop in the real editor.** Reorder items within each column of a two-column section and
  confirm the drop zone still covers the column's full empty area. This was verified against the
  prototype using react-beautiful-dnd's keyboard sensor, with geometry stable during the drag; a
  mouse pass in the real app is still worth doing. Note that Playwright's `dragTo` cannot reorder an
  rbd list (it reports a drag that ends where it started, with or without the header), so use the
  keyboard sensor or real mouse steps for any browser-level check.
- **A section with an empty second column**, which is the extreme case for the drop-zone stretch that
  `grid-template-rows: min-content 1fr` exists to preserve.

### Out of scope reminders for the implementer

Leave `src/stories/authoring-section.stories.tsx` alone, including its swapped single-column stories.
Do not convert the layout `<select>` or the `can_collapse_small` checkbox to controlled inputs. Do not
touch `Section::LAYOUT_OPTIONS`. Note that Storybook 6 replaces an out-of-enum `layout` arg with the
component default, so the unrecognized-layout case cannot be demonstrated through story args anyway.

## Open Questions

### RESOLVED: Four commits or one?

**Context**: The plan splits into four commits totaling roughly 500 lines: a pure refactor, the
duplicate-ID fix, the dropdown text, and the column labels. Each is independently reviewable, and the
refactor commit in particular is much easier to check for behavioral equivalence on its own than
buried inside the labeling diff. But four commits for a story this small may be more ceremony than
the team wants, and the duplicate-ID fix is arguably a separate concern from labeling.

**Options considered**:
- A) Four commits in one PR, as planned.
- B) Four commits, with the duplicate-ID fix split into its own PR against its own Jira bug.
- C) One squashed commit.

**Decision**: **A** — four commits in one PR, with the duplicate-ID fix included.

Rationale, measured against the repo rather than argued from principle. LARA merges with **merge
commits**, not squashes (all 25 most recent merges on master are `Merge pull request #NNNN`), so
intra-PR commits land in master's history permanently and are what `git blame` lands on. Multi-commit
PRs are the norm: commit counts for the last 25 merged PRs run 3, 42, 9, 12, 1, 3, 1, 4, 1, 2, 6, 3,
1, 3, 1, 1, 1, 1, 15, 3, 1, 163, 1, 2, with a median around 3. Those commits are meaningful units
carrying conventional-commit prefixes (`feat(report-service):`, `fix(base-interactive):`,
`chore(db):`), not WIP noise. There is no PR template and no CONTRIBUTING file, so there is no written
rule either way; four commits simply matches what the repo does.

Option B was rejected on file overlap. `authoring-section.tsx` is touched by all four commits and
`authoring-section.spec.tsx` is created by the second and extended by the third and fourth, so a
separate PR for the ID fix would serialize the two and force a rebase through conflicts in both files,
without making either reviewable in parallel. Option C was rejected because the refactor commit's
whole value is that its behavioral equivalence can be checked on its own, before 300 lines of new
behavior land on top of it; squashing moves that burden onto whoever reads the combined diff.

**No Jira bug is filed for the duplicate-ID defect.** That was an earlier call, dropped after checking
practice: this team bundles drive-by fixes into a story's PR as plain `chore:`/`fix:` commits without
tickets (`chore(docs): drop stale ghcr.io login instructions from README` and `chore(db): dump schema
for migration` rode along in LARA-212's PR; `chore: add nav guard to mw-interactives` and `chore: add
interactive API publishing documentation` in LARA-195's; `chore: reinstate commented out styles` in
LARA-193's). LARA's 13 Bug tickets are reported production failures such as LARA-212 "MoDa activity
does not publish", not internal finds. A ticket opened and closed inside one PR has no lifecycle. The
PR description carries the callout instead, which is where QA on this team looks.

---

### RESOLVED: Should `SectionColumn` render a real `data-testid`?

**Context**: The `data-testid` props passed to `SectionColumn` at `authoring-section.tsx:345` and
`:357` never reach the DOM, because the component destructures only its declared props and never
spreads the rest. The requirements put fixing that out of scope "except where the new tests need
them". The label tests do need a way to identify a column, so the plan drops the two dead props and
has `SectionColumn` render `data-testid={`section-column-${columnNumber}`}` itself. That changes the
testid format from `section-column-<layout>-<n>` to `section-column-<n>`, which no test currently uses
because the old value never rendered.

**Options considered**:
- A) As planned: drop the dead props, render `section-column-<n>` from inside the component.
- B) Keep the prop-passing shape, declaring a `dataTestId` prop on `SectionColumn` and rendering it,
  preserving the `section-column-<layout>-<n>` format.
- C) Add no testid; identify columns in tests by querying `.col-1` / `.col-2` class names.
- D) Add no testid and no class query: assert group order and accessible names via
  `getAllByRole("group")`. (Emerged from the verification below, after the original three were written.)

**Decision**: **C + D — add no testid.** Use D for the label assertions and C for the tests that need
to count rendered columns. The two dead props are dropped in the first commit and nothing replaces them.

Rationale, measured rather than argued:

**Nothing consumes the dead props.** Searched across every file type in the repo, excluding only
`node_modules`, `.git`, `tmp`, `log`, `dist`, and `coverage`: `section-column` appears only at
`authoring-section.tsx:345,357` and in two `import` lines for the component module. `section_column`
returns nothing. The Rails `spec/` directory references no section-authoring markup at all
(`sectionContainer`, `edit-page-grid`, `section_layout`, `sectionMenu` are all absent from `spec/` and
`app/views/`).

**Testids in this repo are cypress-facing, not jest-facing.** No spec anywhere in `lara-typescript`
uses `ByTestId`; every existing testid exists for the cypress suite, which does run in CI
(`ci.yml:68`, `cypress-io/github-action@v6`). And cypress already selects this exact DOM by class
rather than testid: `cy.get("#sections-container .editPageContainer .edit-page-grid-container.sectionContainer")`,
`cy.get("#sections-container .sectionMenu")`, `cy.get('.sectionItem')`. Adding a testid here would be
production markup added for a consumer that does not exist.

**Option A as originally planned ships a latent collision.** Measured against a prototype, rendering
two sections gives two matches for `section-column-1` and `getByTestId` throws
`Found multiple elements by: [data-testid="section-column-1"]`. It works in the plan only because the
label tests render a single section. Had a testid been wanted, the correct form was the section-scoped
`section-column-${sectionId}-${columnNumber}`, which measured unique (1 and 1) and matches the house
convention visible in `section-item.tsx` (`section-title-${id}`, `section-move-button-${id}`, matched
by cypress with `[data-testid^=…]`).

**Option B preserves an off-convention format.** `section-column-${layout}-${n}` interpolates a mutable
attribute rather than an identity, which is not what any other interpolated testid in the codebase does.

**Option C's handle is structural, not incidental.** `.col-1` / `.col-2` are load-bearing SCSS
selectors (`section-item.scss:133,140,147,159,171,184,191`, `authoring-section.scss:163`), so a test
keyed to them hangs off a selector the stylesheet already depends on. The three
`edit-page-grid-container` elements in a section are cleanly distinguishable:

```
[0] edit-page-grid-container sectionContainer section-60-40
[1] edit-page-grid-container col-1 section-60 hasColumnHeader
[2] edit-page-grid-container col-2 section-40 hasColumnHeader
```

**Option D expresses the requirement most directly.** `getAllByRole("group")` returns groups in DOM
order, and DOM order is visual order here: nothing in the SCSS uses `order` or `direction`, so grid
places `col-1` left and `col-2` right in every layout. Asserting
`["Secondary column", "Primary column"]` for `30-70` states the actual requirement (which *side* is
primary) with no coupling to markup at all.

**The rewritten test block was run against a prototype before being written down.** All 13 assertions
pass. As a negative control, changing the header ID from per-column to per-section (the exact defect
Round 3 of the requirements review caught) fails **9 of the 13**, including all six label tests:
`labelsInOrder()` resolves both groups' `aria-labelledby` to the first header and returns
`["Primary column", "Primary column"]`. That is stronger coverage than the testid version it replaces,
which caught the same defect only incidentally, via `getByRole` throwing on a duplicate match.

---

### WITHDRAWN: Where should the legacy fallback option appear in the dropdown?

**Context**: The plan rendered it last, after the eight known layouts, so the familiar ordering was
undisturbed. Rendering it first would put the current selection at the top of the list. Position has
no effect on which option is selected, since react-dom matches by value and its no-match fallback
picks the first non-disabled option either way.

**Options considered**:
- A) Last, after the known layouts.
- B) First, so the current (disabled) selection heads the list.

**Decision**: **Withdrawn — there is no fallback option to place.**

The question was answered out from under itself. A census of `sections.layout` across both deployed
environments found **zero** unrecognized values (production 281,699 sections, staging 5,045, both with
0 NULL and 0 unrecognized), so the fallback option was dropped entirely. See the legacy-layout
decision in the requirements spec for the numbers and the reversal.

Recorded for whoever revisits this, since the investigation was done and should not be repeated:

- **Both placements display the stored value correctly.** Replicating react-dom's `updateOptions` on a
  real `<select>` in Chromium: last gives `selectedIndex: 8`, first gives `0`, and both render
  `responsive` as the closed selection.
- **They differ on keyboard, and B was the better answer.** With the option **last**, the only
  available move is `ArrowUp`, which lands on `responsive-full-width (single column)`; `ArrowDown` is
  a no-op that fires no `change` event. With it **first**, `ArrowDown` lands on `full-width`, which is
  both the sane default and the value the control already falls back to. So had the option shipped,
  B was the right call.
- **Option A's stated rationale did not survive contact.** The eight known layouts are in identical
  *relative* order either way; only the position of one greyed row changes.
- **There is no disabled-`<option>` precedent in the codebase.** The nearest analogue is a
  non-disabled placeholder placed first (`<option>Select ...</option>`, `section-move-dialog.tsx:75`).

## Self-Review

Method: rather than read the plan, **the whole plan was built exactly as written** and put through the
commands in the Verification section. Every code block in this document was applied to the real
components (the two spec files were extracted from this document verbatim rather than retyped, so what
ran is what is written here), then the result was reverted.

### The plan builds and passes as written

| Check | Result |
| --- | --- |
| `npx jest src/section-authoring` | **81 passed, 5 suites**, no `act()` warnings |
| `npm run lint` (tslint) | clean |
| `npm run lint:build` (stricter config) | clean |
| `npm run build:webpack` | section-authoring compiles; see the caveat below |

The built CSS carries both new rules, with the token resolving:

```css
.edit-page-grid-container.hasColumnHeader { grid-template-rows: min-content 1fr; }
.columnHeader { color: var(--dark-teal); font-size: 12px; font-weight: bold;
                padding: 6px 10px 4px; text-transform: uppercase; }
--dark-teal: #016082
```

No adjustment to any code block was needed to make this work. The one thing the plan leaves implicit is
where `columnHeaderId` is declared in `section-column.tsx`; anywhere before the `return` is fine.

### Findings

**1. CI does not run tslint, so the Verification section overstates what is gated.** CI
(`.github/workflows/ci.yml`) runs `npm run build:webpack` and `npm run test`. It never invokes
`lint`, `lint:build`, or `build` (which is the script that would chain `lint:build`). Running lint
locally is still right, but a lint regression will not be caught by CI, so it is on the author and
reviewer. The Verification section below has been left as-is because the commands are correct; this
note exists so nobody assumes the gate is stronger than it is.

**2. Do not add `npm run lint:unused` to the verification list.** It runs `tsc --noUnusedLocals` and
reports **91 errors on master**, including several in the two files this story edits (`nextId`,
`handleMoveItem`, `handleEditItem` in `authoring-section.tsx`; `ISectionItemProps`, `absorbClickThen`,
`ISection`, `ItemId` in `section-column.tsx`). Measured before and after this change: **91 both times**,
so the story introduces none. But the script cannot be used as a pass/fail gate, and an implementer who
runs it will otherwise think they broke something.

**3. `build:webpack` needs a fresh `npm ci` first, for reasons unrelated to this story.**
`@concord-consortium/accessibility-tools` is declared in `package.json` (`^0.2.0-pre.2`) but may be
absent from `node_modules`, in which case the build fails in `src/example-interactives/` with
`Can't resolve '@concord-consortium/accessibility-tools/hooks'`. Every error is in that directory and
none in `section-authoring`. CI is unaffected because it runs `npm ci`. Noted so the failure is not
mistaken for a regression from this work.

**4. The plan's claim that `SectionColumns` stays imported in `authoring-section.tsx` is correct**,
confirmed by lint rather than by reading: after the closure is deleted the enum is still referenced by
`addItem` and `getColumnItems`, and no unused-import error appears for it.

### Verified, no change needed

- **Dropping the two dead `data-testid` props breaks nothing.** The full suite passes without them, and
  no test in the repo referenced them.
- **The assembled component spec is coherent across the three commits that build it.** Step 2 creates
  the file, steps 3 and 4 append to it, and step 4's instruction to extend the import line with
  `within` is what makes the final import correct. Assembled in that order, the file lints clean.
- **The extracted `columnValueForIndex` is behaviorally identical to the deleted closure**, confirmed
  by its unit spec plus the unchanged behavior of every existing section-authoring test.

### Still not verified by anything automated

Unchanged from the requirements spec: the label's colour, its uppercase casing, and the
`grid-template-rows` geometry do not exist in jsdom (`.scss` is mapped to `identity-obj-proxy`), and
the narrow-viewport header wrap is viewport-dependent. Those remain review-and-eyeball items, and the
Manual section below is the list.
