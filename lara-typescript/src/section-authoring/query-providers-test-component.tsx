
import * as React from "react";
import { IPage } from "./api/api-types";
import { usePageAPI } from "./api/use-api-provider";

// This is a simple DEMO Pages Component to exercise the query providers.
export const PagesDemo = () => {
  const { getPages, addPageMutation, deletePageMutation } = usePageAPI();
  const addPage = () => addPageMutation.mutate();

  const PageDiv = (params: {page: IPage}) => {
    const {page} = params;
    const deleteAction = () => deletePageMutation.mutate(page.id);
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
        { getPages.data?.map(p => <PageDiv key={p.id} page={p}/>) }
      </ul>
      <button onClick={addPage}>Add</button>
    </div>
  );
};
