import { IPage, SectionId, SectionColumns, SectionLayouts, ISectionItem } from "../api/api-types";

export interface IChangeLayoutSignature {
  id: SectionId;
  layout: SectionLayouts;
  page: IPage;
}

const error = (msg: string) => {
  // tslint:disable-next-line:no-console
  console.error(msg);
};

export const changeLayout = (args: IChangeLayoutSignature) => {
  const { layout, id, page } = args;
  const section = page?.sections.find(s => s.id === id);

  if (!section) {
    error(`can't find section with ID ${id}.`);
    return undefined;
  }

  const previousLayout = section.layout;
  section.layout = layout;
  if (layout === SectionLayouts.LAYOUT_FULL_WIDTH) {
    // All items get placed in secondary column.
    // Items from the former primary column are listed first.
    const primaryItems = section.items?.filter(i => i.column === SectionColumns.PRIMARY);
    primaryItems?.forEach((item: ISectionItem, index: number) => {
      item.position = index + 1;
    });
    section.items?.forEach((item: ISectionItem, index: number) => {
      if (primaryItems && item.column === SectionColumns.SECONDARY) {
        item.position = item.position ? primaryItems.length + item.position : primaryItems.length + index + 1;
      }
      item.column = SectionColumns.SECONDARY;
    });
    section.items?.sort((a, b) => {
      if (a.position === undefined && b.position === undefined) {
        return 0;
      } else if (a.position === undefined) {
        return 1;
      } else if (b.position === undefined) {
        return -1;
      } else {
        return a.position - b.position;
      }
    });
  } else if (previousLayout === SectionLayouts.LAYOUT_FULL_WIDTH) {
    // All items get placed in secondary column.
    section.items?.forEach((item: ISectionItem) => {
      item.column = SectionColumns.SECONDARY;
    });
  }
  return section;
};
