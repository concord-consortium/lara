import { IPage, ISection, ISectionItem } from "../api-types";
import { findSectionAddress, findSection, findSectionByAddress } from "./finding-utils";
import { moveSection, ISectionDestination, RelativeLocation } from "./move-utils";
import { makePages } from "./spec-helper";

const samplePages = makePages(3);

describe("moveSection", () => {
  it ("it behaves", () => {
    const setPage = (nextPage: IPage) => { console.log(nextPage.id); };
    const destination: ISectionDestination = {
      relativeLocation: RelativeLocation.After,
      destSectionId: "section3" // not specifying a page...
    };
    const sectionId = "section0";
    const subject = moveSection({destination, pages: samplePages, sectionId, setPage});
    expect(1).toEql(1);
  });
});
