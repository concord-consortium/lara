import * as React from "react";
import { useContext } from "react";
import { moveSection  as _moveSection, ISectionDestination} from "../util/move-utils";

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
const LIBRARY_INTERACTIVES_TYPES_KEY = "LibraryInteractiveTypes";

// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
export const APIContext  = React.createContext<IAuthoringAPIProvider>(DEFAULT_API);

export const usePageAPI = () => {

  const { userInterface, actions } = useContext(UserInterfaceContext);
  const provider: IAuthoringAPIProvider = useContext(APIContext);
  const client = useQueryClient(); // Get the context from our container.

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
  const getPages = useQuery<IPage[], Error>(PAGES_CACHE_KEY, provider.getPages);
  const addPageMutation = useMutation<IPage, Error>(provider.createPage, mutationsOpts);
  const deletePageMutation = useMutation<IPage[], Error, string>(provider.deletePage, mutationsOpts);

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
    if (getPages.data) {
      const page = getPages.data[userInterface.currentPageIndex];
      _updatePageItem.mutate({pageId: page.id, sectionItem});
    }
  };

  const deletePageItemMutation = useMutation
    <IPage, Error, {pageId: string, pageItemId: ItemId}>
    (provider.deletePageItem, mutationsOpts);

  const deletePageItem = (pageItemId: ItemId) => {
    if (getPages.data) {
      const page = getPages.data[userInterface.currentPageIndex];
      deletePageItemMutation.mutate({pageId: page.id, pageItemId});
    }
  };

  const getAllEmbeddables = useQuery
    <{allEmbeddables: ISectionItemType[]}, Error>
    (SECTION_ITEM_TYPES_KEY, provider.getAllEmbeddables);

  const useLibraryInteractives = useQuery
    <{libraryInteractives: ILibraryInteractive[]}, Error>
    (LIBRARY_INTERACTIVES_TYPES_KEY, provider.useLibraryInteractives);

  const getPage =  () => {
    if (getPages.data) {
      return getPages.data[userInterface.currentPageIndex];
    }
    return null;
  };

  const getSections = () => {
    const page = getPage();
    if (!page) return [];
    return page.sections;
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
    const sectionItems: ISectionItem[][] = getSections().map(s => translateItems(s.items) || []) || [];
    return [].concat.apply([], sectionItems) as ISectionItem[];
  };

  // After we move or delete a section item, we call updateSectionItems
  const updateSectionItems = (args: {sectionId: string, newItems: ISectionItem[], column?: SectionColumns}) => {
    const { sectionId, newItems, column } = args;
    if (getPages.data) {
      const page = getPages.data[userInterface.currentPageIndex];
      const section = page.sections.find(i => i.id === sectionId);
      if (section === undefined) return;
      if (column && section.items) {
        const unalteredItems = section.items.filter(i => i.column !== column);
        section.items = unalteredItems.concat(newItems);
      } else {
        section.items = newItems;
      }
      updateSection.mutate({pageId: page.id, changes: {section}});
    }
  };

  const currentPage = getPage();

  const moveSection = (sectionId: string, destination: ISectionDestination) => {
    if (currentPage) {
      const changes = _moveSection({sectionId, destination, pages: getPages.data || []});
      if (changes) {
        updateSectionsMutation.mutate({...changes[0]});
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
  const moveItem = (
    itemId: string,
    selectedSectionId: string,
    selectedColumn: SectionColumns,
    selectedPosition: string,
    selectedOtherItemId: string
    ) => {
    const items = getItems();
    const itemIndex = items.findIndex(i => i.id === itemId);
    const item = items[itemIndex];
    const otherItemIndex = items.findIndex(i => (i.id === selectedOtherItemId));
    const otherItem = items[otherItemIndex];
    const targetSection = getSection(selectedSectionId);
    item.column = selectedColumn;
    item.position = otherItem && otherItem.position
                      ? selectedPosition === "after"
                        ? otherItem.position + 1
                        : otherItem.position
                      : 1;
    const newIndex = otherItemIndex
                       ? selectedPosition === "after"
                         ? otherItemIndex + 1
                         : otherItemIndex
                       : 0;
    const updatedItems = targetSection?.items;
    updatedItems?.splice(itemIndex, 1);
    updatedItems?.splice(newIndex, 0, item);
    let sectionItemsCount = 0;
    updatedItems?.forEach((i, index) => {
      sectionItemsCount++;
      if (index > newIndex) {
        updatedItems[index].position = sectionItemsCount;
      }
    });
    // setItems(updatedItems);
    if (targetSection) {
      targetSection.items = updatedItems;
      if (updateSectionItems && updatedItems) {
        updateSectionItems({sectionId: selectedSectionId, newItems: updatedItems});
      }
    }
  };

  let addSection, changeSection, addPageItem = (a: any) => {
    // tslint:disable-next-line
    console.error("no page specified, cant invoke method.");
  };

  if (currentPage) {
    addSection = () => addSectionMutation.mutate(currentPage.id);

    changeSection = (changes: { section: Partial<ISection>, sectionID: string}) =>
      updateSection.mutate({pageId: currentPage.id, changes});

    addPageItem = (pageItem: ICreatePageItem) =>
      createPageItem.mutate({pageId: currentPage.id, newPageItem: pageItem});
    }

  return {
    getPages, addPageMutation, deletePageMutation,
    addSectionMutation, addSection, changeSection, updateSection, getSections,
    moveSection, updateSections, copySection,
    addPageItem, createPageItem, updatePageItem, deletePageItem, updateSectionItems, moveItem, getItems,
    getAllEmbeddables, useLibraryInteractives, currentPage, deleteSectionFunction,
    pathToTinyMCE: provider.pathToTinyMCE, pathToTinyMCECSS: provider.pathToTinyMCECSS
  };
};
