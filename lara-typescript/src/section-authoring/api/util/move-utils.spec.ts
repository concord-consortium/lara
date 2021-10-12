import { IPage, ISection, ISectionItem } from "../api-types";
import { findSectionAddress, findSection, findSectionByAddress } from "./finding-utils";
import { moveSection, ISectionDestination, RelativeLocation } from "./move-utils";
import { makePages } from "./spec-helper";

describe("moveSection", () => {

  describe("Failing scenarios" , () => {
    it ("it can't move a section to after a bogus section name", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.After,
        destSectionId: "bogus" // not specifying a page...
      };
      const setPage = (nextPage: IPage) => null;
      const sectionId = "section0";

      // Move failed:
      expect(moveSection({ destination, pages, sectionId, setPage })).toBeFalsy();
    });

    it ("it can't move non-existent sections", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.After,
        destSectionId: "section3" // not specifying a page...
      };
      const setPage = (nextPage: IPage)  => null;
      const sectionId = "bogus";

      // Move failed:
      expect(moveSection({ destination, pages, sectionId, setPage })).toBeFalsy();
    });
  });

  it ("it can move a section to after section3", () => {
    const pages = makePages(3);
    const destination: ISectionDestination = {
      relativeLocation: RelativeLocation.After,
      destSectionId: "section3" // not specifying a page...
    };
    const setPage = (nextPage: IPage) => {
      const page = pages.find(p => p.id === nextPage.id);
      if (page) {
        page.sections = nextPage.sections;
      }
    };
    const sectionId = "section0";

    // Move was successful:
    expect(moveSection({ destination, pages, sectionId, setPage })).toBeTruthy();
    // first page lost "section0":
    expect(pages[0].sections.map(s => s.id)).toEqual(["section1", "section2"]);
    // "section0" shows up after "section3"
    expect(pages[1].sections.map(s => s.id)).toEqual(["section3", "section0", "section4", "section5"]);
  });

  it ("can move a section to before section3", () => {
    const pages = makePages(3);
    const destination: ISectionDestination = {
      relativeLocation: RelativeLocation.Before,
      destSectionId: "section3"
    };
    const setPage = (nextPage: IPage) => {
      const page = pages.find(p => p.id === nextPage.id);
      if (page) {
        page.sections = nextPage.sections;
      }
    };
    const sectionId = "section0";

    // Move was successful:
    expect(moveSection({ destination, pages, sectionId, setPage })).toBeTruthy();
    // first page lost "section0":
    expect(pages[0].sections.map(s => s.id)).toEqual(["section1", "section2"]);
    // "section0" shows up after "section3"
    expect(pages[1].sections.map(s => s.id)).toEqual(["section0", "section3", "section4", "section5"]);
  });
});
