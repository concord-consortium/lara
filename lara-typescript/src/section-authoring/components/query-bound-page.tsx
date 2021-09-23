import * as React from "react";
import { QueryClient, QueryClientProvider, useMutation, useQuery, useQueryClient } from "react-query";
import { AuthoringPage, IPageProps } from "./authoring-page";
import { ISectionProps } from "./authoring-section";
import { ISectionItem } from "./section-item-picker";

const APIBase = "/api/v1";

interface ILibraryInteractiveResponse {
  library_interactives: Array<{
    id: string;
    name: string;
    use_count: number;
    date_added: number;
  }>;
}

interface IQueryBoundPage extends IPageProps {
  host?: string;
}

export interface ICreatePageItem {
  section_id: string;
  embeddable: string;
  position?: number;
}

export const QueryBoundPage = (props: IQueryBoundPage) => {
  const queryClient = useQueryClient();
  const host = props.host || window.location.origin;
  const prefix = `${host}/${APIBase}`;
  const { id } = props;
  const pageSectionsUrl = `${prefix}/get_page_sections/${id}.json`;
  const updatePageSectionsURL = `${prefix}/set_page_sections/${id}.json`;
  const createPageSectionUrl = `${prefix}/create_page_section/${id}.json`;
  const updateSectionUrl = `${prefix}/update_page_section/${id}.json`;
  const createPageItemUrl = `${prefix}/create_page_item/${id}.json`;
  const libraryInteractivesUrl = `${prefix}/get_library_interactives_list.json`;
  const updatePageQueryData = (response: any, variables: any) => {
    queryClient.setQueryData("authoringPage", response);
  };

  const updateSections = (nextPage: IPageProps) => {
    return fetch(updatePageSectionsURL, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(nextPage),
      credentials: "include"
    }).then(res => {
      return res.json();
    });
  };

  const createSection = () => {
    return fetch(createPageSectionUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id }),
      credentials: "include"
    }).then(res => {
      return res.json();
    });
  };

  const createPageItem = (newPageItem: ICreatePageItem) => {
    return fetch(createPageItemUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({page_item: newPageItem}),
      credentials: "include"
    }).then(res => {
      return res.json();
    });
  };

  const _changeSection = (changes: { section: Partial<ISectionProps> }) => {
    const updateSectionData = { id, section: { ...changes.section } };
    return fetch(updateSectionUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updateSectionData),
      credentials: "include"
    }).then(res => {
      return res.json();
    });
  };

  const updatePageSectionsMutation = useMutation(updateSections, {
    onSuccess: updatePageQueryData
  });

  const createSectionMutation = useMutation(createSection, {
    onSuccess: updatePageQueryData
  });

  const createPageItemMutation = useMutation(createPageItem, {
    onSuccess: updatePageQueryData
  });

  const changeSectionMutation = useMutation(_changeSection);

  const authoringQuery = useQuery("authoringPage", () =>
    fetch(pageSectionsUrl, { credentials: "include" })
      .then(res => res.json())
  );

  const libraryInteractiveQuery = useQuery("libraryInteractives", () => {
    return fetch(libraryInteractivesUrl, { credentials: "include" })
      .then(res => res.json())
      .then((json: ILibraryInteractiveResponse) => {
        const result = {
          allSectionItems: json.library_interactives.map(li => ({
            id: li.id,
            name: li.name,
            useCount: li.use_count,
            dateAdded: li.date_added
          }))
        };
        result.allSectionItems.push({
          id: "MwInteractive",
          name: "Interactive IFrame",
          useCount: 0,
          dateAdded: 0
        });
        return result;
      });
  });

  const isLoading = authoringQuery.isLoading || libraryInteractiveQuery.isLoading;
  const error = authoringQuery.error || libraryInteractiveQuery.error;
  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Something went wrong: ${error}</div>;

  const { sections } = authoringQuery.data;
  const { allSectionItems } = libraryInteractiveQuery.data!;

  const setSections = updatePageSectionsMutation.mutate;
  const addSection = createSectionMutation.mutate as () => void;
  const changeSection = changeSectionMutation.mutate;
  const addPageItem = createPageItemMutation.mutate;
  return <AuthoringPage {...{ id, sections, setSections, addSection, changeSection, allSectionItems, addPageItem }} />;
};
