import * as React from "react";
import { fireEvent, render, screen, within } from "@testing-library/react";
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
