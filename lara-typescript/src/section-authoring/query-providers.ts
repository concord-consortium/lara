
import {useMutation, useQuery, useQueryClient} from "react-query";


import { useState } from "react";

type SectionId = string;
type PageId = string;
type ItemId = string;

type RelativePosition = "before" | "after";

interface IHasStringId {
  id: string;
}

const insertAt = <T extends IHasStringId>(thing: T, targetId: string, position: RelativePosition, collection: T[]) => {
  let index = collection.findIndex(i => i.id === targetId);
  if (position === "after") index++;
  return [...collection.slice(0, index), thing, ...collection.slice(index)];
};

const removeFrom = <T extends IHasStringId>(targetId: string, collection: T[]) => {
  return collection.filter(i => i.id !== targetId);
};

export interface ISectionItem {
  id: ItemId;
  title?: string;
}

export interface ISection {
  id: SectionId;
  items: ISectionItem[];
  title?: string;
}

export interface IPage {
  id: PageId;
  sections: ISection[];
  title?: string;
}

export type IPageList = IPage[];

export interface IPageAuthoringAPI {
  // Simplified page API:
  getPages: () => QueryObserverIdleResult<IPageList, Error>;
  getPage: (id: PageId) => IPage|null;
  createPage: () => IPage;
  deletePage: (id: PageId) => IPageList;
  // copyPage: (id: PageId) => IPageList;
  // updatePage: (id: PageId, changes: Partial<IPage>) => IPageList;
  // movePage: (id: PageId, dest: IPageDestination) => IPageList;
  // pages: IPageList;
}

export const UseOfflinePageAPIQueries = (): IPageAuthoringAPI => {
  let pages: IPageList = [];
  let counter: 0;
  const pagesCacheKey = "pages";
  const queryClient = useQueryClient();
  const nextId = () => `${counter++}`;
  const createPage = () => {
    return {
      id: nextId(),
      title: `Page ${counter}`,
      sections: []
    };
  };

  const getPage = (id: PageId) => {
    return pages.find(p => p.id === id) || null;
  };

  const deletePage = (id: PageId) => {
    pages = pages.filter(p => p.id !== id);
    queryClient.invalidateQueries(pagesCacheKey);
    return Promise.resolve(pages);
  };

  const getPages = () => {
    return Promise.resolve(pages);
  };

  // Return the interface
  return {
    getPages: useQuery<IPageList, Error>("pages", getPages),
    getPage: (id: PageId) => useQuery([pagesCacheKey,id], getPage(id)),
    createPage,
    deletePage
  };
}

export const OfflineQueryProvider = {}