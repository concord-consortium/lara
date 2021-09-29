import * as React from "react";
import { useContext } from "react";
import {useMutation, useQuery, useQueryClient} from "react-query";
import { IAuthoringAPIProvider, IPage, ISection, ISectionItemType } from "./api-types";
import { API as DEFAULT_API } from "./mock-api-provider";

const PAGES_CACHE_KEY = "pages";
const SECTION_ITEM_TYPES_KEY = "SectionItemTypes";
// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
//
export const APIContext  = React.createContext<IAuthoringAPIProvider>(DEFAULT_API);

export const usePageAPI = () => {
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

  const getAllEmbeddables = useQuery
    <{allEmbeddables: ISectionItemType[]}, Error>
    (SECTION_ITEM_TYPES_KEY, provider.getAllEmbeddables);

  return {
    getPages, addPageMutation, deletePageMutation,
    addSectionMutation, updateSection, updateSections,
    getAllEmbeddables
  };
};
