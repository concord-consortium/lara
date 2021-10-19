import { IPage, SectionId, ISection, PageId } from "../api/api-types";

export interface ISectionAddress {
  pageIndex: number|null;
  sectionIndex: number|null;
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

export const findSectionByAddress = (pages: IPage[], address: ISectionAddress) => {
  const { pageIndex, sectionIndex } = address;
  if (pageIndex != null && sectionIndex != null) {
    return pages[pageIndex]?.sections[sectionIndex] || null;
  }
  return null;
};

// memoize me, invalidate on pages[]
export const findSectionAddress = (pages: IPage[], sectionId: SectionId): ISectionAddress => {
  for (let pageIndex = 0; pageIndex < pages.length; ++pageIndex) {
    const page = pages[pageIndex];
    const sections = page?.sections;
    for (let sectionIndex = 0; sectionIndex < sections?.length; ++sectionIndex) {
      const section = page.sections[sectionIndex];
      if (section.id === sectionId) {
        return({pageIndex, sectionIndex});
      }
    }
  }
  return {pageIndex: null, sectionIndex: null};
};
