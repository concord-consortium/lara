import * as React from "react";
import { useContext } from "react";
import { useState } from "react";
import {useMutation, useQuery, useQueryClient} from "react-query";
import { IAuthoringAPIProvider, ICreatePageItem, IPage, ISection, ISectionItem, ISectionItemType, SectionColumns } from "./api-types";
import { API as DEFAULT_API } from "./mock-api-provider";

const PAGES_CACHE_KEY = "pages";
const SECTION_ITEM_TYPES_KEY = "SectionItemTypes";
// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
//
export const APIContext  = React.createContext<IAuthoringAPIProvider>(DEFAULT_API);

export const usePageAPI = () => {
  const [currentPageIndex, setCurrentPageIndex] = useState(0);
  const provider: IAuthoringAPIProvider = useContext(APIContext);
  const client = useQueryClient(); // Get the context from our container.
  const mutationsOpts = {
    onSuccess: () => client.invalidateQueries(PAGES_CACHE_KEY)
  };

  const getPages = useQuery<IPage[], Error>(PAGES_CACHE_KEY, provider.getPages);
  const addPageMutation = useMutation<IPage, Error>(provider.createPage, mutationsOpts);
  const deletePageMutation = useMutation<IPage[], Error, string>(provider.deletePage, mutationsOpts);

  const addSectionMutation = useMutation<IPage, Error, string>(provider.createSection, mutationsOpts);

  const updateSection = useMutation<IPage, Error, {pageId: string, changes: {section: Partial<ISection> }}>
    (provider.updateSection, mutationsOpts);

  const updateSections = useMutation<IPage, Error, IPage>(provider.updateSections, mutationsOpts);
  const createPageItem = useMutation
    <IPage, Error, {pageId: string, newPageItem: ICreatePageItem}>
    (provider.createPageItem, mutationsOpts);

  const getAllEmbeddables = useQuery
    <{allEmbeddables: ISectionItemType[]}, Error>
    (SECTION_ITEM_TYPES_KEY, provider.getAllEmbeddables);

  // const moveItem(oldSectionID, newSectionID) {
  //   updateSectionItems(fromSectionID, {items: [previous value minus moved item]} )
  //   updateSectionItems(roSectionID,   {items: [previous value plus moved item] } )
  // }

  // After we move or delete a section item, we call updateSectionItems
  const updateSectionItems = (args: {sectionId: string, newItems: ISectionItem[], column?: SectionColumns}) => {
    const { sectionId, newItems, column } = args;
    // TODO: Get the correct page
    if (getPages.data) {
      const page = getPages.data[currentPageIndex];
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

  return {
    getPages, addPageMutation, deletePageMutation,
    addSectionMutation, updateSection, updateSections,
    createPageItem,
    getAllEmbeddables, updateSectionItems
  };
};
