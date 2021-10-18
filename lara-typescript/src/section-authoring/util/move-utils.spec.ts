import { IPage, ISection, ISectionItem } from "../api/api-types";
import { findSectionAddress, findSection, findSectionByAddress } from "./finding-utils";
import { moveSection, ISectionDestination, RelativeLocation } from "./move-utils";
import { makePages } from "./spec-helper";

describe("moveSection", () => {

  describe("Failing scenarios" , () => {
    it ("it can't move non-existent sections", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.After,
        destSectionId: "section3" // not specifying a page...
      };
      const sectionId = "bogus";

      // Move failed:
      expect(moveSection({ destination, pages, sectionId })).toEqual([]);
    });
  });

  describe("moving sections in the same page", () => {

    it ("it can move a section to the end of the page with a bogus section name", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.After,
        destPageId: pages[0].id,
        destSectionId: "bogus" // not specifying a page...
      };
      const sectionId = "section0";

      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section2", "section0" ]);
    });

    it("can move a section ahead within the same page", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section0" // not specifying a page...
      };

      const sectionId = "section1";
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section0", "section2"]);
    });

    it("can move a section ahead within the same page", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section0" // not specifying a page...
      };

      const sectionId = "section2";
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section2", "section0", "section1"]);

    });

    it("can move a section back within the same page", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.After,
        destSectionId: "section1" // not specifying a page...
      };
      const sectionId = "section2";
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section0", "section1", "section2"]);
      // "section0" shows up after "section3"
    });
  });

  describe("moving to other pages", () => {
    it ("can move a section to after section3", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.After,
        destPageId: "page1",
        destSectionId: "section3" // not specifying a page...
      };

      const sectionId = "section1";
      expect(moveSection({ destination, pages, sectionId })).toBeTruthy();
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(2);

      // first page lost "section0":
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section0", "section2"]);
      // "section0" shows up after "section3"
      expect(changedPages[1].sections.map(s => s.id)).toEqual(["section3", "section1", "section4", "section5"]);
    });

    it ("can move a section to before section3", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.Before,
        destPageId: "page1",
        destSectionId: "section3"
      };
      const sectionId = "section0";
      expect(moveSection({ destination, pages, sectionId })).toBeTruthy();
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(2);

      // first page lost "section0":
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section2"]);
      // "section0" shows up after "section3"
      expect(changedPages[1].sections.map(s => s.id)).toEqual(["section0", "section3", "section4", "section5"]);
    });
  });

  // TODO:  Tests asserting position of Sections.
});
