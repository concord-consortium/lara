import { set } from "immer/dist/internal";
import { IPage, PageId, SectionId } from "../api-types";
import { findSection, findSectionAddress } from "./finding-utils";

export enum RelativeLocation {
  Before = "before",
  After = "after"
}

export interface ISectionDestination {
  destSectionId?: SectionId;
  destPageId?: PageId;
  relativeLocation: RelativeLocation;
}

export interface IMoveSectionSignature {
  sectionId: SectionId;
  destination: ISectionDestination;
  setPage: (nextPage: IPage) => void;
  pages: IPage[];
}

const error = (msg: string) => {
  // tslint:disable-next-line:no-console
  console.error(msg);
};

export const moveSection = (args: IMoveSectionSignature) => {
  const { sectionId, destination, setPage, pages } = args;
  const { destPageId, destSectionId, relativeLocation } = destination;
  const { pageIndex, sectionIndex } = findSectionAddress(pages, sectionId);

  let destSectionIndex: number|null = null;
  let destPageIndex: number|null = null;

  // The source page and section must exist
  if (pageIndex == null || sectionIndex == null) {
    error(`can't find page and section for: ${sectionId}`);
    return false;
  }

  if (destSectionId) {
    ({
      sectionIndex: destSectionIndex,
      pageIndex: destPageIndex
    } =  findSectionAddress(pages, destSectionId));
  }
  else if (destPageId) {
    destPageIndex = pages.findIndex(p => p.id === destPageId);
  }

  // We must have a destination page:
  if (!(destPageIndex)) {
    error(`can't find destination  ${destination}`);
    return false;
  }

  // If we have a destination section:
  if (destSectionIndex) {
    // Adjust destination index by relative location:
    if (relativeLocation === RelativeLocation.After) {
      destSectionIndex = destSectionIndex + 1;
    }
  }
  // Otherwise we are using the first.
  else {
    destSectionIndex = 0;
  }

  // At this point we should have indexes for everything...
  // 1. remove the item from the array
  // 2. add the item back in its new place
  // 3. update the pages
  const sourcePage = pages[pageIndex];
  const destPage = pages[destPageIndex];
  const realDestSectionIndex = relativeLocation === RelativeLocation.After
    ? destSectionIndex + 1
    : destSectionIndex;
  const nextSourcePagePageSections = [... sourcePage.sections];
  const nextDestPagePageSections = [... destPage.sections];
  const sourceSection = findSection(pages, sectionId);
  if (sourceSection === null) {
    error(`can't find source section ${sectionId}`);
    return false;
  }
  nextSourcePagePageSections.splice(sectionIndex, 1);
  nextDestPagePageSections.splice(realDestSectionIndex, 0, sourceSection);
  setPage({...sourcePage, sections: nextSourcePagePageSections});
  setPage({...destPage, sections: nextDestPagePageSections});
  return true;
};
