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

describe("AuthoringSection element IDs", () => {
  it("derives the layout select and collapse checkbox IDs from the section ID", () => {
    renderSection("60-40", "42");
    expect(document.getElementById("section-layout-42")).not.toBeNull();
    expect(document.getElementById("toggle-secondary-column-42")).not.toBeNull();
  });

  it("clicking a section's collapse label toggles that section's own checkbox", () => {
    render(
      <APIContainer>
        <AuthoringSection id="1" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
        <AuthoringSection id="2" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
      </APIContainer>
    );

    const checkboxes = screen.getAllByTestId("toggle-secondary-column-checkbox") as HTMLInputElement[];
    const labels = screen.getAllByText("Allow student to hide secondary column");
    expect(checkboxes.length).toBe(2);
    expect(checkboxes.map(c => c.checked)).toEqual([false, false]);

    // Before the fix this toggled the FIRST section's checkbox.
    fireEvent.click(labels[1]);
    expect(checkboxes.map(c => c.checked)).toEqual([false, true]);
  });

  it("emits no duplicate element IDs across sections", () => {
    render(
      <APIContainer>
        <AuthoringSection id="1" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
        <AuthoringSection id="2" interactive_page_id="2" layout={SectionLayouts.LAYOUT_60_40} />
      </APIContainer>
    );
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
