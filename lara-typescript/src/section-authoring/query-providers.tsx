
import React from "react";
import {QueryClient, QueryClientProvider } from "react-query";
import { IPage } from "./authoring-types";
import { UsePageAPI } from "./apis/use-page-api-provider";
import { API } from "./apis/mock-page-api";

interface IPageAPIProvider {
  getPages: any;
  createPage: any;
  deletePage: any;
};

// Component using this junk:
const queryClient = new QueryClient();

const Pages = (args: {pageApiProvider: IPageAPIProvider}) => {
  const { pageApiProvider } = args;
  const { queryAll, addMutation, deleteMutation } = UsePageAPI(pageApiProvider);
  const addPage = () => addMutation.mutate();

  const PageDiv = (parms: {page: IPage}) => {
    const {page} = parms;
    return(
      <li key={page.id}>
        {page.id} {page.title}
        <span onClick={() => deleteMutation.mutate(page.id)}>✖</span>
      </li>
    );
  };

  return(
    <div>
      <ul>
        {queryAll.data?.map(p => <PageDiv key={p.id} page={p}/>)}
      </ul>
      <button onClick={addPage}>Add</button>
    </div>
  );
};

export const App = () => {
  return(
    <QueryClientProvider client={queryClient}>
      <Pages pageApiProvider={API} />
    </QueryClientProvider>
  );
};
