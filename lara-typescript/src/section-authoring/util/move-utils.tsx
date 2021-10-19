import { IPage, ISection, PageId, SectionId } from "../api/api-types";
import { findSection, findSectionAddress } from "./finding-utils";

export enum RelativeLocation {
  Before = "before",
  After = "after"
}

export interface ISectionDestination {
  destSectionId?: SectionId;
  destPageId: PageId;
  relativeLocation: RelativeLocation;
}

export interface IMoveSectionSignature {
  sectionId: SectionId;
  destination: ISectionDestination;
  pages: IPage[];
}

const setSectionPositions = (page: IPage)  => {
  page.sections = page.sections.map( (s, i) => ({ ...s, position: i}) );
  return page;
};

export const moveSection = (args: IMoveSectionSignature): IPage[] => {
  const { sectionId, destination,  pages } = args;
  const { destPageId, destSectionId, relativeLocation } = destination;
  const { pageIndex, sectionIndex } = findSectionAddress(pages, sectionId);

  const error = (msg: string) => {
    // tslint:disable-next-line:no-console
    console.error(msg);
    return [] as IPage[];
  };

  let destSectionIndex: number|null = null;
  let destPageIndex: number|null = null;

  // The source page and section must exist
  if (pageIndex == null || sectionIndex == null) {
    return error(`can't find page and section for: ${sectionId}`);
  }

  if (destSectionId) {
    ({
      sectionIndex: destSectionIndex,
      pageIndex: destPageIndex
    } = findSectionAddress(pages, destSectionId));
  }

  destPageIndex = pages.findIndex(p => p.id === destPageId);
  // We must have a destination page:
  if ((destPageIndex === null) || (destPageIndex === -1)) {
    return error(`can't find destination ${destination}`);
  }

  // If no section is specified, insert at the start.
  if ((destSectionIndex == null) || (destSectionIndex === -1)) {
    destSectionIndex = (pages.find(p => p.id === destPageId)?.sections.length) || 0;
  }
  else {
    // Adjust destination index by relative location:
    if (relativeLocation === RelativeLocation.After) {
      destSectionIndex = destSectionIndex + 1;
    }
  }

  // At this point we should have indexes for everything...
  // 1. remove the item from the array
  // 2. add the item back in its new place
  // 3. update the pages
  const sourcePage = pages[pageIndex];
  const destPage = pages[destPageIndex];

  const sourceSection = findSection(pages, sectionId);
  if (sourceSection == null) {
    return error(`can't find source section ${sectionId}`);
  }
  // Remove the sourceSection from the sourcePage
  const nextSourcePage = {
    ... sourcePage,
    sections: sourcePage.sections.filter(s => s.id !== sourceSection.id)
  };
  if (pageIndex === destPageIndex) {
    nextSourcePage.sections.splice(destSectionIndex, 0, sourceSection);
    return [ setSectionPositions(nextSourcePage) ];
  }

  const nextDestPage = {
    ... destPage,
    sections: [...destPage.sections || []]
  };
  nextDestPage.sections.splice(destSectionIndex, 0, sourceSection);
  return [setSectionPositions(nextSourcePage), setSectionPositions(nextDestPage)];
};
