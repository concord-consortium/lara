import { IPage, ISection, ISectionItem } from "../api-types";
import { findSectionAddress, findSection, findSectionByAddress, ISectionAddress, findPage } from "./finding-utils";
import { makePages } from "./spec-helper";

const samplePages = makePages(3);

describe("findSectionAddress", () => {
  it ("finds sections that exist, and returns index", () => {
    expect(findSectionAddress(samplePages, "section0")).toEqual({pageIndex: 0, sectionIndex: 0});
    expect(findSectionAddress(samplePages, "section1")).toEqual({pageIndex: 0, sectionIndex: 1});
    expect(findSectionAddress(samplePages, "section2")).toEqual({pageIndex: 0, sectionIndex: 2});
    expect(findSectionAddress(samplePages, "section3")).toEqual({pageIndex: 1, sectionIndex: 0});
    expect(findSectionAddress(samplePages, "section8")).toEqual({pageIndex: 2, sectionIndex: 2});
  });

  it ("returns null for sections that can't be found", () => {
    const nullResults = {pageIndex: null, sectionIndex: null};
    expect(findSectionAddress(samplePages, "section9")).toEqual(nullResults);
    expect(findSectionAddress(samplePages, "Vorgon poetry")).toEqual(nullResults);
  });

});

describe("findSection", () => {
  it("finds sections that exist", () => {
    expect(findSection(samplePages, "section1")).not.toBeNull();
  });
  it("returns a whole ISection", () => {
    expect(findSection(samplePages, "section1")?.items).toHaveLength(3);
  });
  it("returns null when there is no such section", () => {
    expect(findSection(samplePages, "Vorgon poetry")).toBeNull();
  });
});

describe("findPage", () => {
  it("finds sections that exist", () => {
    expect(findPage(samplePages, "page1")).not.toBeNull();
  });
  it("returns a whole ISection", () => {
    expect(findPage(samplePages, "page1")?.sections).toHaveLength(3);
  });
  it("returns null when there is no such section", () => {
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

  it("should return null when the any index is null", () => {
    let address: ISectionAddress = { pageIndex: null, sectionIndex: 0 };
    let section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
    address = { pageIndex: 0, sectionIndex: null };
    section = findSectionByAddress(samplePages, address);
    expect(section).toBeNull();
  });
});

