import * as React from "react";
import { useContext } from "react";
import {
  moveSection  as _moveSection,
  moveItem  as _moveItem,
  ISectionDestination,
  IItemDestination
} from "../util/move-utils";

import {useMutation, useQuery, useQueryClient} from "react-query";
import {
    IAuthoringAPIProvider, ICreatePageItem, IPage, ISection, ISectionItem,
    ISectionItemType, ItemId, PageId, SectionColumns, SectionId, ILibraryInteractive
} from "../api/api-types";
import { API as DEFAULT_API } from "../api/mock-api-provider";
import { UserInterfaceContext  } from "../containers/user-interface-provider";
import { snakeToCamelCaseKeys } from "../../shared/convert-keys";

const PAGES_CACHE_KEY = "pages";
const SECTION_ITEM_TYPES_KEY = "SectionItemTypes";
const LIBRARY_INTERACTIVES_KEY = "LibraryInteractives";

// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
export const APIContext  = React.createContext<IAuthoringAPIProvider>(DEFAULT_API);

export const usePageAPI = () => {

  const { userInterface, actions } = useContext(UserInterfaceContext);
  const provider: IAuthoringAPIProvider = useContext(APIContext);
  const client = useQueryClient(); // Get the context from our container.

  const getPages = useQuery<IPage[], Error>(PAGES_CACHE_KEY, provider.getPages);

  const getPageIdFromLocation = () => {
    const pageIdRegex = /pages\/(\d+)\/edit/;
    const currentLoc = window.location.toString();
    const matchData = currentLoc.match(pageIdRegex);
    if (matchData && matchData[1]) {
      return matchData[1];
    }
    return null;
  };

  const getPage =  () => {
    const pages = getPages.data;
    if (pages && pages.length > -1) {
      if (userInterface.currentPageId == null) {
        // Look for the pageId in the URL in the address bar
        // if its not there, fallback to the first page
        const fromLocation = getPageIdFromLocation();
        const pageId = fromLocation ? fromLocation :  getPages.data[0].id;
        actions.setCurrentPageId(pageId);
      }
      return getPages.data.find( (p: IPage) => p.id === userInterface.currentPageId);
    }
    return null;
  };

  const currentPage = getPage();
  const mutationsOpts = {
    onSuccess: () => client.invalidateQueries(PAGES_CACHE_KEY)
  };

  const addPageItemMutationsOpts = {
    onSuccess: (sectionItem: ISectionItem) => {
      client.invalidateQueries(PAGES_CACHE_KEY);
      actions.setEditingItemId(sectionItem.id);
    }
  };

  // Pages:
  const createPageMutation = useMutation<IPage, Error, PageId>(provider.createPage, mutationsOpts);
  const deletePageMutation = useMutation<IPage[], Error, PageId>(provider.deletePage, mutationsOpts);
  const copyPageMutation = useMutation<IPage, Error, {pageId: PageId, destIndex: number}>
    (provider.copyPage, mutationsOpts);

  // Section Mutations:
  const addSectionMutation = useMutation<IPage, Error, string>(provider.createSection, mutationsOpts);
  const updateSection = useMutation<IPage, Error, {pageId: string, changes: {section: Partial<ISection> }}>
    (provider.updateSection, mutationsOpts);
  const updateSectionsMutation = useMutation<IPage, Error, IPage>(provider.updateSections, mutationsOpts);
  const copySectionMutation =
    useMutation<IPage, Error, {pageId: PageId, sectionId: SectionId}>(provider.copySection, mutationsOpts);

  const updateSections = (nextPage: IPage) => updateSectionsMutation.mutate(nextPage);

  const createPageItem = useMutation
    <ISectionItem, Error, {pageId: string, newPageItem: ICreatePageItem}>
    (provider.createPageItem, addPageItemMutationsOpts);

  const _updatePageItem = useMutation
    <ISectionItem, Error, {pageId: string, sectionItem: ISectionItem}>
    (provider.updatePageItem, mutationsOpts);

  const updatePageItem = (sectionItem: ISectionItem) => {
    if (getPages.data && userInterface.currentPageId) {
      _updatePageItem.mutate({pageId: userInterface.currentPageId, sectionItem});
    }
  };

  const deletePageItemMutation = useMutation
    <IPage, Error, {pageId: string, pageItemId: ItemId}>
    (provider.deletePageItem, mutationsOpts);

  const deletePageItem = (pageItemId: ItemId) => {
    if (getPages.data && userInterface.currentPageId) {
      deletePageItemMutation.mutate({pageId: userInterface.currentPageId, pageItemId});
    }
  };

  const copyPageItemMutation = useMutation
    <ISectionItem, Error, {pageId: PageId, sectionItemId: SectionId}>(provider.copyPageItem, mutationsOpts);

  const copyPageItem = (sectionItemId: ItemId) => {
    if (getPages.data && userInterface.currentPageId) {
      copyPageItemMutation.mutate({pageId: userInterface.currentPageId, sectionItemId});
    }
  };

  const getAllEmbeddables = useQuery
    <{allEmbeddables: ISectionItemType[]}, Error>
    (SECTION_ITEM_TYPES_KEY, provider.getAllEmbeddables);

  const getLibraryInteractives = useQuery
    <{libraryInteractives: ILibraryInteractive[]}, Error>
    (LIBRARY_INTERACTIVES_KEY, provider.getLibraryInteractives);

  const getSections = () => {
    if (!currentPage) return [];
    return currentPage.sections;
  };

  const getSection = (id: SectionId) => {
    return getSections().find(s => s.id === id);
  };

  const translateItems = (items: ISectionItem[] | undefined) => {
    items?.forEach((item: ISectionItem) => {
      const itemData = item.data;
      const translatedData = snakeToCamelCaseKeys(itemData);
      item.data = translatedData;
    });
    return items;
  };

  const getItems = () => {
    const sectionItems: ISectionItem[][] = getSections().map((s) => translateItems(s.items) || []) || [];
    return [].concat.apply([], sectionItems) as ISectionItem[];
  };

  // After we move or delete a section item, we call updateSectionItems
  const updateSectionItems = (args: {sectionId: string, newItems: ISectionItem[], column?: SectionColumns}) => {
    const { sectionId, newItems, column } = args;

    if (currentPage) {
      const section = currentPage.sections.find( (i: ISection) => i.id === sectionId);
      if (section === undefined) return;
      if (column && section.items) {
        const unalteredItems = section.items.filter(i => i.column !== column);
        section.items = unalteredItems.concat(newItems);
      } else {
        section.items = newItems;
      }
      updateSection.mutate({pageId: currentPage.id, changes: {section}});
    }
  };

  const moveSection = (sectionId: string, destination: ISectionDestination) => {
    if (currentPage) {
      const changes = _moveSection({sectionId, destination, pages: getPages.data || []});
      if (changes) {
        for (const change of changes) {
          updateSectionsMutation.mutate(change);
        }
      }
    }
    else {
      // tslint:disable-next-line
      console.error("no page specified, cant invoke method.");
    }
  };

  const copySection = (sectionId: SectionId) => {
    if (currentPage) {
      const pageId = currentPage.id;
      copySectionMutation.mutate({pageId, sectionId});
    }
  };

  const deleteSectionFunction = (sectionId: SectionId) => {
    if (currentPage) {
      const nextSections: ISection[] = [];
      currentPage.sections.forEach(s => {
        if (s.id !== sectionId) {
          nextSections.push(s);
        }
      });
      const update = { ...currentPage, sections: nextSections };
      updateSections(update);
    }
  };

  const moveItem = (itemId: string, destination: IItemDestination) => {
    if (currentPage) {
      const updatedSections = _moveItem({itemId, destination, pages: getPages.data || []});
      for (const updatedSection of updatedSections) {
        if (updatedSection.items) {
          const changes = {section: updatedSection, sectionId: updatedSection.id};
          updateSection.mutate({pageId: currentPage.id, changes});
          updateSectionItems({sectionId: updatedSection.id, newItems: updatedSection.items});
        }
      }
    }
    else {
      // tslint:disable-next-line
      console.error("no page specified, cant invoke method.");
    }
  };

  let addSection, changeSection, addPageItem  = (a: any) => {
    // tslint:disable-next-line
    console.error("no page specified, cant invoke method.");
  };

  let addPage = () => {
    // tslint:disable-next-line
    console.error("no page specified, cant invoke method.");
  };

  let copyPage = ((destIndex: number) => {
    // tslint:disable-next-line
    console.error("no page specified, cant invoke method.");
  });

  if (currentPage) {
    addSection = () => addSectionMutation.mutate(currentPage.id);

    changeSection = (changes: { section: Partial<ISection>, sectionID: string}) =>
      updateSection.mutate({pageId: currentPage.id, changes});

    addPageItem = (pageItem: ICreatePageItem) =>
      createPageItem.mutate({pageId: currentPage.id, newPageItem: pageItem});

    addPage = () => createPageMutation.mutate(currentPage.id);
    copyPage = (destIndex: number) => copyPageMutation.mutate({pageId: currentPage.id, destIndex});
  }

  return {
    getPages, addPage, deletePageMutation, copyPage,
    addSectionMutation, addSection, changeSection, updateSection, getSections,
    moveSection, updateSections, copySection,
    addPageItem, createPageItem, updatePageItem, deletePageItem, copyPageItem,
    updateSectionItems, moveItem, getItems,
    getAllEmbeddables, getLibraryInteractives, currentPage, deleteSectionFunction,
    pathToTinyMCE: provider.pathToTinyMCE, pathToTinyMCECSS: provider.pathToTinyMCECSS
  };
};
