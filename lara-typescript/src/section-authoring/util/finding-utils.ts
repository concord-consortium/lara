import { IPage, SectionId, ISection, PageId, ItemId, SectionColumns} from "../api/api-types";

export interface ISectionAddress {
  pageIndex: number | null;
  sectionIndex: number|null;
}

export interface IItemAddress extends ISectionAddress {
  column: SectionColumns;
  itemIndex: number|null;
}

// memoize me, invalidate on pages[]
export const findPage = (pages: IPage[], pageId: PageId): IPage|null => {
  return pages.find(p => p.id === pageId) || null;
};

// memoize me, invalidate on pages[]
export const findSection = (pages: IPage[], sectionId: SectionId): ISection|null => {
  for (const page of pages) {
    for (const section of page.sections) {
      if (section.id === sectionId) {
        return section;
      }
    }
  }
  return null;
};

export const findItemByAddress = (pages: IPage[], address: IItemAddress) => {
  const { pageIndex, sectionIndex, itemIndex } = address;
  if (pageIndex != null && sectionIndex != null && itemIndex != null) {
    return pages[pageIndex].sections[sectionIndex].items?.[itemIndex] || null;
  }
  return null;
};

export const findSectionByAddress = (pages: IPage[], address: ISectionAddress) => {
  const { pageIndex, sectionIndex } = address;
  if (pageIndex != null && sectionIndex != null) {
    return pages[pageIndex]?.sections[sectionIndex] || null;
  }
  return null;
};

export interface IAddressQuery {
  pages: IPage[];
  itemId?: ItemId;
  sectionId?: SectionId;
  pageId?: PageId;
}

export const findItemAddress = (args: IAddressQuery): IItemAddress => {
  const { pages, itemId, sectionId, pageId } = args;
  let sectionIndex = null;
  let pageIndex = null;
  let itemIndex = null;
  let column = SectionColumns.PRIMARY;

  pageIndex = 0;
  for (const page of pages) {
    sectionIndex = 0;
    for (const section of page.sections || []) {
      itemIndex = 0;
      for (const item of section.items || []) {
        if (item.id === itemId) {
          column = item.column;
          return {pageIndex, sectionIndex, itemIndex, column};
          }
        itemIndex++;
      }
      if (sectionId && section.id === sectionId) {
        return {pageIndex, sectionIndex, itemIndex: null, column};
      }
      sectionIndex++;
    }
    if (pageId && pageId === page.id) {
      return {pageIndex, sectionIndex: null, itemIndex: null, column};
    }
    pageIndex++;
  }
  return {pageIndex: null, sectionIndex: null, itemIndex: null, column};
};
