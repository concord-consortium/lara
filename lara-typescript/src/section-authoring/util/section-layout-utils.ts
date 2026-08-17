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
