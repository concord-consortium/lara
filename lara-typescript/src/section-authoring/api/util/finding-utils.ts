import { IPage, SectionId, ISection, PageId } from "../api-types";

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
  if (pageIndex !== null && sectionIndex !== null) {
    return pages[pageIndex]?.sections[sectionIndex] || null;
  }
  return null;
};

// memoize me, invalidate on pages[]
export const findSectionAddress = (pages: IPage[], sectionId: SectionId): ISectionAddress => {
  let pageIndex = 0;
  let sectionIndex = 0;
  let page: IPage|null = null;
  let section: ISection | null = null;
  let sections: ISection[] = [];
  while (pageIndex < pages.length) {
    sectionIndex = 0;
    page = pages[pageIndex];
    sections = page.sections;
    while (sectionIndex < sections.length) {
      section = page.sections[sectionIndex];
      if (section.id === sectionId) {
        return( {pageIndex, sectionIndex});
      }
      sectionIndex++;
    }
    pageIndex++;
  }
  return {pageIndex: null, sectionIndex: null};
};
