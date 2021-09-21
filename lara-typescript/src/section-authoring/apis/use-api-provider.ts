import * as React from "react";
import { useContext } from "react";
import {useMutation, useQuery, useQueryClient} from "react-query";
import { IPage } from "../authoring-types";
import { API as DEFAULT_API } from "./mock-api";

const PAGES_CACHE_KEY = "pages";

// Use this in a parent component to setup API context:
// <APIProviderContext.Provider value={someAPIProvider} />
//
export const APIContext = React.createContext(DEFAULT_API);

export const usePageAPI = () => {
  const provider = useContext(APIContext);
  const client = useQueryClient(); // Get the context from our container.
  const addMutationOpts = {
    onSuccess: () => client.invalidateQueries(PAGES_CACHE_KEY)
  };

  const deleteMutationOpts = {
    onSuccess: () => client.invalidateQueries(PAGES_CACHE_KEY)
  };

  const queryAll = useQuery<IPage[], Error>(PAGES_CACHE_KEY, provider.getPages);
  const addMutation = useMutation<IPage, Error>(provider.createPage, addMutationOpts);
  const deleteMutation = useMutation<IPage[], Error, string>(provider.deletePage, deleteMutationOpts);

  return {queryAll, addMutation, deleteMutation };
};
