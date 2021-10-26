import { IPage, ISection, ISectionItem } from "../api/api-types";
import { findSection, findSectionByAddress,
  ISectionAddress, findPage, findItemAddress } from "./finding-utils";
import { makePages } from "./spec-helper";

const samplePages = makePages(3);

const nullResults = { pageIndex: null, sectionIndex: null, itemIndex: null, column: null };

describe("get a Sections nested address", () => {
  it ("finds sections that exist, and returns nested index", () => {
    expect(findItemAddress({pages: samplePages, sectionId: "section0"}))
      .toMatchObject({pageIndex: 0, sectionIndex: 0});

    expect(findItemAddress({pages: samplePages, sectionId: "section1"}))
      .toMatchObject({pageIndex: 0, sectionIndex: 1});
    expect(findItemAddress({pages: samplePages, sectionId: "section2"}))
      .toMatchObject({pageIndex: 0, sectionIndex: 2});
    expect(findItemAddress({pages: samplePages, sectionId: "section3"}))
      .toMatchObject({pageIndex: 1, sectionIndex: 0});
    expect(findItemAddress({pages: samplePages, sectionId: "section8"}))
      .toMatchObject({pageIndex: 2, sectionIndex: 2});
  });

  it ("returns null for sections that can't be found", () => {
    expect(findItemAddress({pages: samplePages, sectionId: "Vorgon poetry"}))
      .toEqual(nullResults);
  });

  describe("get an items nested address", () => {
    it("finds the nested index for items that exist", () => {
      expect(findItemAddress({pages: samplePages, itemId: "item1"}))
        .toMatchObject({pageIndex: 0, sectionIndex: 0});
      expect(findItemAddress({pages: samplePages, itemId: "item3"}))
        .toMatchObject({pageIndex: 0, sectionIndex: 1});
      expect(findItemAddress({pages: samplePages, itemId: "item9"}))
        .toMatchObject({pageIndex: 1, sectionIndex: 0});
    });
    it("finds the nested index for items that exist", () => {
      expect(findItemAddress({pages: samplePages, itemId: "item1"}))
        .toMatchObject({pageIndex: 0, sectionIndex: 0});
      expect(findItemAddress({pages: samplePages, itemId: "item3"}))
        .toMatchObject({pageIndex: 0, sectionIndex: 1});
      expect(findItemAddress({pages: samplePages, itemId: "item9"}))
        .toMatchObject({pageIndex: 1, sectionIndex: 0});
    });

    it("returns null index for items that do not exist", () => {
      expect(findItemAddress({pages: samplePages, itemId: "Vorgon poetry"}))
        .toEqual(nullResults);
    });
  });

});

describe("findSection", () => {
  it("finds sections that exist", () => {
    expect(findSection(samplePages, "section1")).not.toBeNull();
  });
  it("returns all the items in the section", () => {
    expect(findSection(samplePages, "section1")?.items).toHaveLength(3);
  });
  it("returns null when there is no such section", () => {
    expect(findSection(samplePages, "Vorgon poetry")).toBeNull();
  });
});

describe("findPage", () => {
  it("finds pages that exist", () => {
    expect(findPage(samplePages, "page1")).not.toBeNull();
  });
  it("returns all the sections in the page", () => {
    expect(findPage(samplePages, "page1")?.sections).toHaveLength(3);
  });
  it("returns null when there is no such page", () => {
    expect(findPage(samplePages, "Vorgon poetry")).toBeNull();
  });
});

describe("findSectionByAddress", () => {
  it("should return the section when it exists", () => {
    const address = { pageIndex: 0, sectionIndex: 0 };
    const section = findSectionByAddress(samplePages, address);
    expect(section).not.toBeNull();
    expect(section?.id).toEqual("section0");
  });

  it("should return null when the pageIndex is outside the range", () => {
    const address = { pageIndex: 5, sectionIndex: 0 };
    const section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
  });

  it("should return null when the sectionIndex is outside the range", () => {
    const address = { pageIndex: 0, sectionIndex: 5 };
    const section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
  });

  it("should return null when any index is null", () => {
    let address: ISectionAddress = { pageIndex: null, sectionIndex: 0 };
    let section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
    address = { pageIndex: 0, sectionIndex: null };
    section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
  });
});
