import { IPage, ISection, PageId, SectionId, ItemId, ISectionItem} from "../api/api-types";
import { findSection, findItemAddress, IAddressQuery, findItemByAddress, findSectionByAddress } from "./finding-utils";

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

export interface IItemDestination extends ISectionDestination {
  destSectionId: SectionId;
  destItemId?: ItemId;
}

export interface IMoveItemSignature {
  itemId: ItemId;
  destination: IItemDestination;
  pages: IPage[];
}

const updatePositions = (items: Array<{position?: number}>) => {
  items.forEach ( (item, index) => {
    item.position = index + 1;
  });
};

const setSectionPositions = (page: IPage)  => {
  updatePositions(page.sections);
  for (const section of page.sections) {
    updatePositions(section.items!);
  }
  return page;
};

const error = (msg: string) => {
  // tslint:disable-next-line:no-console
  console.error(msg);
  return [] as IPage[];
};

export const moveSection = (args: IMoveSectionSignature): IPage[] => {
  const { sectionId, destination,  pages } = args;
  const { relativeLocation } = destination;
  const sourceAddress = findItemAddress({ pages, sectionId});
  const destAddress = findItemAddress({pages, pageId: destination.destPageId, sectionId: destination.destSectionId});

  // The source section has to exist:
  const sourceSection = findSection(pages, sectionId);
  if (sourceSection == null) {
    return error(`can't find source section ${sectionId}`);
  }

  // The source page and section must exist
  if (sourceAddress.pageIndex == null || sourceAddress.sectionIndex == null) {
    return error(`can't find page and section for: ${sectionId}`);
  }

  // We must have a destination page:
  if (destAddress.pageIndex === null) {
    return error(`can't find destination ${destination}`);
  }

  // If no section is specified, insert it at the end
  if (destAddress.sectionIndex == null) {
    destAddress.sectionIndex = (pages[destAddress.pageIndex].sections.length) || 0;
  }
  // Otherwise, optionally add one to the index if we are inserting after.
  else {
    // Adjust destination index by relative location:
    if (relativeLocation === RelativeLocation.After) {
      destAddress.sectionIndex = destAddress.sectionIndex + 1;
    }
  }

  // At this point we should have indexes for everything...
  // 1. remove the item from the array
  // 2. add the item back in its new place
  // 3. update the pages
  const sourcePage = pages[sourceAddress.pageIndex];
  const destPage = pages[destAddress.pageIndex];

  // Remove the sourceSection from the sourcePage
  const nextSourcePage = {
    ... sourcePage,
    sections: sourcePage.sections.filter(s => s.id !== sourceSection.id)
  };

  // If we are adding the section to the same page we are removing it from:
  if (sourceAddress.pageIndex === destAddress.pageIndex) {
    nextSourcePage.sections.splice(destAddress.sectionIndex, 0, sourceSection);
    return [ setSectionPositions(nextSourcePage) ];
  }

  // ensure the destination page has sections...
  const nextDestPage = { ... destPage, sections: [...destPage.sections || []] };

  nextDestPage.sections.splice(destAddress.sectionIndex, 0, sourceSection);
  return [setSectionPositions(nextSourcePage), setSectionPositions(nextDestPage)];
};

export const moveItem = (args: IMoveItemSignature): ISection[] => {
  const { itemId, destination,  pages } = args;
  const { relativeLocation } = destination;
  const sourceAddress = findItemAddress({ pages, itemId});
  const destAddress = findItemAddress({pages,
    pageId: destination.destPageId,
    sectionId: destination.destSectionId,
    itemId: destination.destItemId
  });

  // The source item has to exist:
  const sourceItem = findItemByAddress(pages, sourceAddress);
  if (sourceItem == null || sourceAddress.pageIndex == null) {
    return error(`can't find itemId ${itemId}`);
  }

  // We must have a destination section:
  if (destAddress.sectionIndex == null || destAddress.pageIndex == null) {
    return error(`can't find destination ${destination}`);
  }

  // If no item is specified, insert at the end of the section
  if (destAddress.itemIndex == null) {
    destAddress.itemIndex = (
      pages[destAddress.pageIndex]
      .sections[destAddress.sectionIndex]
      .items!.length) || 0;
  }
  // Otherwise, optionally add one if we are inserting after.
  else {
    // Adjust destination index by relative location:
    if (relativeLocation === RelativeLocation.After) {
      destAddress.itemIndex = destAddress.itemIndex + 1;
    }
  }

  // At this point we should have indexes for everything...
  // 1. remove the item from the source section items
  // 2. add the item back into the dest section items
  // 3. update the sections and pages
  const sourcePage = pages[sourceAddress.pageIndex];
  const destPage = pages[destAddress.pageIndex];
  const sourceSection = findSectionByAddress(pages, sourceAddress);
  const destSection = findSectionByAddress(pages, destAddress);
  if (destSection == null || sourceSection == null) {
    return error("Destination or source section missing ...");
  }

  // Remove the sourceItem from the sourceSection
  sourceSection.items = sourceSection.items?.filter(s => s.id !== sourceItem.id) || [];

  // Here we add the item back to the same section we removed it from:
  if (
      (sourceAddress.pageIndex === destAddress.pageIndex) &&
      (sourceAddress.sectionIndex === destAddress.sectionIndex)
   ) {
    sourceSection.items.splice(destAddress.itemIndex, 0, sourceItem);
    updatePositions(sourceSection.items);
    // Just return the one page that changed:
    return [ sourceSection ];
  }

  destSection.items!.splice(destAddress.itemIndex, 0, sourceItem);
  updatePositions(destSection?.items || []);
  return [sourceSection, destSection];
};
