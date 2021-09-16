
import React from "react";
import {Query, QueryClient, QueryClientProvider, QueryClientProviderProps, useMutation, useQuery, useQueryClient} from "react-query";


type SectionId = string;
type PageId = string;
type ItemId = string;

type RelativePosition = "before" | "after";

interface IHasStringId {
  id: string;
}

const insertAt = <T extends IHasStringId>(thing: T, targetId: string, position: RelativePosition, collection: T[]) => {
  let index = collection.findIndex(i => i.id === targetId);
  if (position === "after") index++;
  return [...collection.slice(0, index), thing, ...collection.slice(index)];
};

const removeFrom = <T extends IHasStringId>(targetId: string, collection: T[]) => {
  return collection.filter(i => i.id !== targetId);
};

export interface ISectionItem {
  id: ItemId;
  title?: string;
}

export interface ISection {
  id: SectionId;
  items: ISectionItem[];
  title?: string;
}

export interface IPage {
  id: PageId;
  sections: ISection[];
  title?: string;
}

export type IPageList = IPage[];

export type APIPagesGetF = () => Promise<IPageList>;
export type APIPageGetF = (id: PageId) => Promise<IPage | null>;
export type APIPageCreateF = () => Promise<IPage>;
export type APIPageDeleteF = (id: PageId) => Promise<IPageList>;

let pages: IPageList = [];
let counter = 0;

const getPages: APIPagesGetF = () => {
  return Promise.resolve(pages);
};

const getPage: APIPageGetF = (id: PageId) => {
  return Promise.resolve(pages.find(p => p.id === id) || null);
};

const createPage = () => {
  console.log(counter);
  const newPage: IPage = {
    id: `${++counter}`,
    title: `Page ${counter}`,
    sections: []
  };
  pages.push(newPage);
  return Promise.resolve(newPage);
};

const deletePage = (id: PageId) => {
  pages = pages.filter(p => p.id !== id);
  return Promise.resolve(pages);
};

// Component using this junk:
const queryClient = new QueryClient();

const Pages = () => {
  const client = useQueryClient();
  const addMutationOpts = {
    onSuccess: () => client.invalidateQueries("pages")
  };
  const deleteMutationOpts = {
    onSuccess: () => client.invalidateQueries("pages")
  };
  const queryPages = useQuery<IPageList, Error>("pages", getPages);
  const addMutation = useMutation<IPage, Error>(createPage, addMutationOpts);
  const deleteMutation = useMutation<IPageList, Error, string>(deletePage, deleteMutationOpts);
  const addPage = () => addMutation.mutate();
  const PageDiv = (args: {page: IPage}) => {
    const {page} = args;
    return(
      <li key={page.id}>
        {page.id} {page.title}
        <span onClick={() => deleteMutation.mutate(page.id)}>✖</span>
      </li>
    )
  }
  return(
    <div>
      <ul>
        {queryPages.data?.map(p => <PageDiv key={p.id} page={p}/>)}
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