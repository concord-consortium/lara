import { SectionLayouts, SectionColumns } from "../api/api-types";
import { changeLayout } from "./change-layout-utils";

const setUpFullWidthPage = () => {
  const page = {
    id: "page-1",
    sections: [
      {
        id: "section-1",
        layout: SectionLayouts.LAYOUT_FULL_WIDTH,
        items: [
          {
            id: "item-1",
            column: SectionColumns.PRIMARY,
            position: 1
          },
          {
            id: "item-2",
            column: SectionColumns.PRIMARY,
            position: 2
          },
          {
            id: "item-3",
            column: SectionColumns.PRIMARY,
            position: 3
          }
        ]
      }
    ]
  };
  return page;
};

const setUp4060Page = () => {
  const page = {
    id: "page-1",
    sections: [
      {
        id: "section-1",
        layout: SectionLayouts.LAYOUT_40_60,
        items: [
          {
            id: "item-1",
            column: SectionColumns.SECONDARY,
            position: 1
          },
          {
            id: "item-2",
            column: SectionColumns.SECONDARY,
            position: 2
          },
          {
            id: "item-3",
            column: SectionColumns.PRIMARY,
            position: 1
          }
        ]
      }
    ]
  };
  return page;
};

const setUp2ColumnResponsivePage = () => {
  const page = {
    id: "page-1",
    sections: [
      {
        id: "section-1",
        layout: SectionLayouts.LAYOUT_RESPONSIVE_30_70,
        items: [
          {
            id: "item-1",
            column: SectionColumns.SECONDARY,
            position: 1
          },
          {
            id: "item-2",
            column: SectionColumns.SECONDARY,
            position: 2
          },
          {
            id: "item-3",
            column: SectionColumns.PRIMARY,
            position: 1
          }
        ]
      }
    ]
  };
  return page;
};

describe("changeLayout", () => {

  describe("Failing scenarios" , () => {
    it ("it will fail with a non-existant section", () => {
      const page = setUpFullWidthPage();
      const sectionId = "sectionRed";
      const newLayout = SectionLayouts.LAYOUT_40_60;
      expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeFalsy();
    });
  });

  it ("it will place all items into the secondary column when switching from Full Width layout", () => {
    const page = setUpFullWidthPage();
    const sectionId = "section-1";
    const newLayout = SectionLayouts.LAYOUT_40_60;
    const items = page.sections[0].items;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items.filter(i => i.column === SectionColumns.SECONDARY)).toHaveLength(3);
  });

  it ("it will maintain primary and secondary column values per item when switching from responsive layout to any other non full-width layout", () => {
    const page = setUp2ColumnResponsivePage();
    const sectionId = "section-1";
    const items = page.sections[0].items;
    const newLayout = SectionLayouts.LAYOUT_60_40;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items[0].column).toEqual(SectionColumns.SECONDARY);
    expect(items[1].column).toEqual(SectionColumns.SECONDARY);
    expect(items[2].column).toEqual(SectionColumns.PRIMARY);
  });

  it ("it will maintain primary and secondary column values per item when switching from any non full-width layout to another non full-width layout", () => {
    const page = setUp4060Page();
    const sectionId = "section-1";
    const items = page.sections[0].items;

    let newLayout = SectionLayouts.LAYOUT_60_40;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items[0].column).toEqual(SectionColumns.SECONDARY);
    expect(items[1].column).toEqual(SectionColumns.SECONDARY);
    expect(items[2].column).toEqual(SectionColumns.PRIMARY);

    newLayout = SectionLayouts.LAYOUT_30_70;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items[0].column).toEqual(SectionColumns.SECONDARY);
    expect(items[1].column).toEqual(SectionColumns.SECONDARY);
    expect(items[2].column).toEqual(SectionColumns.PRIMARY);

    newLayout = SectionLayouts.LAYOUT_RESPONSIVE_30_70;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items[0].column).toEqual(SectionColumns.SECONDARY);
    expect(items[1].column).toEqual(SectionColumns.SECONDARY);
    expect(items[2].column).toEqual(SectionColumns.PRIMARY);
  });

  it ("it will move items in the primary column into the secondary column and place them first in the overall order when switching from any non full-width layout to the full-width layout", () => {
    const page = setUp4060Page();
    const sectionId = "section-1";
    const newLayout = SectionLayouts.LAYOUT_FULL_WIDTH;
    const items = page.sections[0].items;
    expect(changeLayout({ id: sectionId, layout: newLayout, page })).toBeTruthy();
    expect(items.filter(i => i.column === SectionColumns.SECONDARY)).toHaveLength(3);
    expect(items[0].id).toEqual("item-3");
    expect(items[1].id).toEqual("item-1");
    expect(items[2].id).toEqual("item-2");
    expect(items[0].position).toEqual(1);
    expect(items[1].position).toEqual(2);
    expect(items[2].position).toEqual(3);
  });
});
