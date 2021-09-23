
import * as React from "react";
import {QueryClient, QueryClientProvider } from "react-query";
import { IPage } from "./api-types";
import { usePageAPI } from "./apis/use-api-provider";

const queryClient = new QueryClient();

// This is a simple DEMO Pages Component to exercise the query providers.
const Pages = () => {
  const { queryAll, addMutation, deleteMutation } = usePageAPI();
  const addPage = () => addMutation.mutate();

  const PageDiv = (params: {page: IPage}) => {
    const {page} = params;
    const deleteAction = () => deleteMutation.mutate(page.id);
    return(
      <li key={page.id}>
        {page.id} {page.title}
        <span onClick={deleteAction}> ✖ </span>
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
      <Pages />
    </QueryClientProvider>
  );
};
