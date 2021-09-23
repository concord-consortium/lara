
import {
  IPageList, IPage, PageId,
  APIPageGetF, APIPagesGetF, IAuthoringApi, ISection, ICreatePageItem, ISectionItem
} from "./api-types";

let pageCounter = 0;
let sectionCounter = 0;
let itemCounter = 0;

let pages: IPageList = [
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
    section_col: 0,
    position: 0
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

const updateSection = (pageId: PageId, changes: { section: Partial<ISection> }) => {
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

const createPageItem = (pageId: PageId, newPageItem: ICreatePageItem) => {
  const sectionId = newPageItem.section_id;
  const {embeddable, position} = newPageItem;
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

export const API: IAuthoringApi = {
  getPages, getPage, createPage, deletePage,
  createSection, updateSections, createPageItem, updateSection
};
