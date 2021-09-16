import {useMutation, useQuery, useQueryClient} from "react-query";
import { IPage } from "../authoring-types";

export interface IPageAPIProvider {
  getPages: any;
  createPage: any;
  deletePage: any;
};

export const UsePageAPI = (provider: IPageAPIProvider) => {
  const client = useQueryClient(); // Get the context from our container.
  const addMutationOpts = {
    onSuccess: () => client.invalidateQueries("pages")
  };

  const deleteMutationOpts = {
    onSuccess: () => client.invalidateQueries("pages")
  };

  const queryAll = useQuery<IPage[], Error>("pages", provider.getPages);
  const addMutation = useMutation<IPage, Error>(provider.createPage, addMutationOpts);
  const deleteMutation = useMutation<IPage[], Error, string>(provider.deletePage, deleteMutationOpts);

  return {queryAll, addMutation, deleteMutation };
};
