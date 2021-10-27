import { moveSection, ISectionDestination, RelativeLocation, moveItem, IItemDestination } from "./move-utils";
import { makePages } from "./spec-helper";

const verifyPositions = (items: Array<{position?: number, id: string}>): boolean => {
  let counter = 1;
  for (const item of items) {
    if (item.position !== counter++) { return false; }
  }
  return true;
};

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

    it("can move a section back within the same page using After", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.After,
        destSectionId: "section1" // not specifying a page...
      };

      const sectionId = "section0";
      // Assert starting condition:
      expect(pages[0].sections.map(s => s.id)).toEqual(["section0", "section1", "section2"]);
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section2", "section0"]);

    });

    it("can move a section back within the same page using Before", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section1" // without specifying a page...
      };
      const sectionId = "section0";
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section0", "section2"]);
    });
  });

  describe("moving to other pages", () => {
    it ("can move section1 from the first page to after section3 on the second", () => {
      const pages = makePages(3);
      const destination: ISectionDestination = {
        relativeLocation: RelativeLocation.After,
        destPageId: "page1",
        destSectionId: "section3" // not specifying a page...
      };

      const sectionId = "section1";
      // Assert starting condition:
      expect(pages[0].sections.map(s => s.id)).toEqual(["section0", "section1", "section2"]);
      expect(pages[1].sections.map(s => s.id)).toEqual(["section3", "section4", "section5"]);

      expect(moveSection({ destination, pages, sectionId })).toBeTruthy();
      const changedPages = moveSection({ destination, pages, sectionId });
      expect(changedPages.length).toEqual(2);
      // first page lost "section1":
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section0", "section2"]);
      // "section1" shows up on second page:
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

      // first page no longer has a "section0":
      expect(changedPages[0].sections.map(s => s.id)).toEqual(["section1", "section2"]);
      // "section0" shows up in the second page now.
      expect(changedPages[1].sections.map(s => s.id)).toEqual(["section0", "section3", "section4", "section5"]);
    });
  });

  // TODO:  Tests asserting position of Sections.
});

describe("moveItem", () => {

  describe("Failing scenarios" , () => {
    it ("it can't move non-existent item", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.After,
        destSectionId: "section3"
      };
      const itemId = "bogus";

      // Move failed:
      expect(moveItem({ destination, pages, itemId })).toEqual([]);
    });
  });

  describe("moving items within the same section", () => {

    it ("it can move the first item in the section to the end of the section", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: "page0",
        relativeLocation: RelativeLocation.After,
        destSectionId: "section0",
        destItemId: "item2"
      };
      const itemId = "item0";

      const changedPages = moveItem({ destination, pages, itemId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections[0].items!.map(i => i.id)).toEqual(["item1", "item2", "item0" ]);
    });

    it("can move an item forward from one page to another", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: pages[0].id,
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section0",
        destItemId: "item0"
      };
      const itemId = "item9";
      const changedPages = moveItem({ destination, pages, itemId });
      expect(changedPages.length).toEqual(2);
      expect(changedPages[1].sections[0].items!.map(i => i.id)).toEqual(["item9", "item0", "item1", "item2" ]);
    });

    it("can move an item backward from one page to another, not specifying item destination", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: "page1",
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section3",
      };
      const itemId = "item0";
      const changedPages = moveItem({ destination, pages, itemId });
      expect(changedPages.length).toEqual(2);
      expect(changedPages[1].sections[0].items!.map(i => i.id)).toEqual(["item9", "item10", "item11", "item0" ]);
    });

    it("can move an item backward from the first section to the last not specifying item destination", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: "page2",
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section8",
      };
      const itemId = "item0";
      const changedPages = moveItem({ destination, pages, itemId });
      expect(changedPages.length).toEqual(2);
      expect(changedPages[1].sections[2].items!.map(i => i.id)).toEqual(["item24", "item25", "item26", "item0" ]);
    });

    it("can move an item backward from the first section on a page the last not specifying item destination", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: "page0",
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section2",
      };
      const itemId = "item0";
      const changedPages = moveItem({ destination, pages, itemId });
      expect(changedPages.length).toEqual(1);
      expect(changedPages[0].sections[2].items!.map(i => i.id)).toEqual(["item6", "item7", "item8", "item0" ]);
    });

    it("will update the position attributes of the sections and items that moved", () => {
      const pages = makePages(3);
      const destination: IItemDestination = {
        destPageId: "page0",
        relativeLocation: RelativeLocation.Before,
        destSectionId: "section2",
      };
      const itemId = "item0";
      const changedPages = moveItem({ destination, pages, itemId });
      for (const page of changedPages) {
        verifyPositions(page.sections);
        for (const section of page.sections) {
          verifyPositions(section.items!);
        }
      }
    });
  });
});
