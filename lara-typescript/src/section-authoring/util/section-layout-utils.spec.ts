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
