import * as React from "react";
import { useContext } from "react";
import {useMutation, useQuery, useQueryClient} from "react-query";
import { IAuthoringApi, IPage } from "./api-types";
import { API as DEFAULT_API } from "./mock-api-provider";

const PAGES_CACHE_KEY = "pages";

// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
//
export const APIContext  = React.createContext<IAuthoringApi>(DEFAULT_API);

export const usePageAPI = () => {
  const provider = useContext(APIContext);
  const client = useQueryClient(); // Get the context from our container.
  const mutationsOpts = {
    onSuccess: () => client.invalidateQueries(PAGES_CACHE_KEY)
  };


  const getPages = useQuery<IPage[], Error>(PAGES_CACHE_KEY, provider.getPages);
  const addPageMutation = useMutation<IPage, Error>(provider.createPage, mutationsOpts);
  const deletePageMutation = useMutation<IPage[], Error, string>(provider.deletePage, mutationsOpts);

  const addSectionMutation = useMutation<IPage, Error, string>(provider.createSection, mutationsOpts);

  // const updateSection = useMutation<IPage, Error, IPage>(provider.updateSection, mutationsOpts);




  return {getPages, addPageMutation, deletePageMutation, addSectionMutation};
};
