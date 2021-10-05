
import {
  IPage, PageId,
  APIPageGetF, APIPagesGetF,
  IAuthoringAPIProvider, ISection, ICreatePageItem, ISectionItem, SectionColumns,
  ISectionItemType, APIPageItemDeleteF, ItemId
} from "./api-types";

let pageCounter = 0;
let sectionCounter = 0;
let itemCounter = 0;

let pages: IPage[] = [
  {
    id: `${++pageCounter}`,
    title: `Page ${pageCounter}`,
    sections: []
  }
];

const makeNewSection = (): ISection => {
  const section: ISection = {
    id: `${++sectionCounter}`,
    items: []
  };
  return section;
};

const makeNewPageItem = (attributes: Partial<ISectionItem>): ISectionItem => {
  const newItem: ISectionItem = {
    id: `${++itemCounter}`,
    embeddable: attributes.embeddable,
    title: `embeddable-${itemCounter}`,
    column: attributes.column || SectionColumns.PRIMARY,
    position: attributes.position || 1
  };
  return newItem;
};

export const getPages: APIPagesGetF = () => {
  return Promise.resolve(pages);
};

export const getPage: APIPageGetF = (id: PageId) => {
  return Promise.resolve(pages.find(p => p.id === id) || null);
};

export const createPage = () => {
  const newPage: IPage = {
    id: `${++pageCounter}`,
    title: `Page ${pageCounter}`,
    sections: []
  };
  pages.push(newPage);
  return Promise.resolve(newPage);
};

export const deletePage = (id: PageId) => {
  pages = pages.filter(p => p.id !== id);
  return Promise.resolve(pages);
};

export const updatePage = (id: PageId, changes: Partial<IPage>) => {
  const indx = pages.findIndex(p => p.id === id);
  if (indx > -1) {
    pages[indx] = {... pages[indx], ...changes };
  }
  return Promise.resolve(pages[indx]);
};

const createSection = (id: PageId) => {
  const page = pages.find(p => p.id === id);
  if (page) {
    page.sections.push(makeNewSection());
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${id}`);
};

const updateSections = (nextPage: IPage) => {
  const existingPage = pages.find(p => p.id === nextPage.id);
  if (existingPage) {
    updatePage(nextPage.id, nextPage);
  }
  return Promise.resolve(nextPage);
};

const updateSection = (args: {pageId: PageId, changes: { section: Partial<ISection> }}) => {
  const {pageId, changes} = args;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    const section  = page.sections.find(s => s.id === changes.section.id);
    if (section) {
      Object.assign(section, changes.section);

    }
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const createPageItem = (args: {pageId: PageId, newPageItem: ICreatePageItem}) => {
  const {newPageItem, pageId} = args;
  const sectionId = newPageItem.section_id;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    const section = page.sections.find(s => s.id === sectionId);
    if (section) {
      section.items?.push(makeNewPageItem(newPageItem));
      return Promise.resolve(page);
    }
    return Promise.reject(`cant find section ${sectionId}`);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const deletePageItem: APIPageItemDeleteF = (args: {pageId: PageId, pageItemId: ItemId}) => {
  const { pageId, pageItemId } = args;
  const page = pages.find(p => p.id === pageId);
  if (page) {
    let replaceMentSection: ISection | null = null;
    page?.sections.forEach(s => {
      s.items?.forEach(i => {
        if (i.id === pageItemId) {
          replaceMentSection = s;
        }
      });
    });

    if (replaceMentSection) {
      (replaceMentSection as ISection).items = (replaceMentSection as ISection).items?.filter(i => i.id !== pageItemId);
    }
    return Promise.resolve(page);
  }
  return Promise.reject(`cant find page ${pageId}`);
};

const getAllEmbeddables = () => {
  const allEmbeddables: ISectionItemType[] = [
    {id: "1", name: "Carousel", useCount: 1, dateAdded: 1630440496},
    {id: "2", name: "CODAP", useCount: 5, dateAdded: 1630440497},
    {id: "3", name: "Drag & Drop", useCount: 5, dateAdded: 1630440498},
    {id: "4", name: "Fill in the Blank", useCount: 8, dateAdded: 1630440495},
    {id: "5", name: "iFrame Interactive", useCount: 200, dateAdded: 1630440494, isQuickAddItem: true},
    {id: "6", name: "Multiple Choice", useCount: 300, dateAdded: 1630440493},
    {id: "7", name: "Open Response", useCount: 400, dateAdded: 1630440492, isQuickAddItem: true},
    {id: "8", name: "SageModeler", useCount: 3, dateAdded: 1630440499},
    {id: "9", name: "Teacher Edition Window Shade", useCount: 4, dateAdded: 1630440490},
    {id: "10", name: "Text Box", useCount: 500, dateAdded: 1630440491, isQuickAddItem: true}
  ];
  return Promise.resolve({allEmbeddables});
};

export const API: IAuthoringAPIProvider = {
  getPages, getPage, createPage, deletePage,
  createSection, updateSections, updateSection,
  createPageItem, deletePageItem,
  getAllEmbeddables
};
