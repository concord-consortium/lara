
import {
  IPageList, IPage, PageId,
  APIPageGetF, APIPagesGetF
} from "../authoring-types";

let pages: IPageList = [];
let counter = 0;

export const getPages: APIPagesGetF = () => {
  return Promise.resolve(pages);
};

export const getPage: APIPageGetF = (id: PageId) => {
  return Promise.resolve(pages.find(p => p.id === id) || null);
};

export const createPage = () => {
  const newPage: IPage = {
    id: `${++counter}`,
    title: `Page ${counter}`,
    sections: []
  };
  pages.push(newPage);
  return Promise.resolve(newPage);
};

export const deletePage = (id: PageId) => {
  pages = pages.filter(p => p.id !== id);
  return Promise.resolve(pages);
};

export const API = {getPages, getPage, createPage, deletePage};
