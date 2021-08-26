import * as React from "react";
import { QueryClient, QueryClientProvider, useMutation, useQuery, useQueryClient } from "react-query";
import { AuthoringPage, IPageProps } from "./authoring-page";
import { ISectionProps } from "./authoring-section";

interface APIPageResponse extends IPageProps {
  success: boolean;
}

const APIBase = "/api/v1";

interface IQueryBoundPage extends IPageProps {
  host?: string;
}

export const QueryBoundPage = (props: IQueryBoundPage) => {
  const queryClient = useQueryClient();
  const host = props.host || "";
  const prefix = `${host}/${APIBase}`;
  const {id} = props;
  const pageSectionsUrl = `${prefix}/get_page_sections/${id}.json`;
  const updatePageSectionsURL = `${prefix}/set_page_sections/${id}.json`;
  const createPageSectionUrl = `${prefix}/create_page_section/${id}.json`;
  const updateSectionUrl = `${prefix}/update_page_section/${id}.json`;
  const updatePageQueryData = (response: any, variables: any) => {
    queryClient.setQueryData("authoringPage", response);
  };

  const updateSections = (nextPage: IPageProps) => {
    return fetch(updatePageSectionsURL, {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(nextPage)
    }).then(res => {
      return res.json();
    });
  };

  const createSection = () => {
    return fetch(createPageSectionUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({id})
    }).then(res => {
      return res.json();
    });
  };

  const _changeSection = (changes: {section: Partial<ISectionProps>}) => {
    const updateSectionData = {id, section: {...changes.section}};
    return fetch(updateSectionUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(updateSectionData)
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

  const changeSectionMutation = useMutation(_changeSection);

  const { isLoading, error, data} = useQuery("authoringPage", () =>
    fetch(pageSectionsUrl)
    .then(res => {
      return res.json();
    })
  );

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Something went wrong: ${error}</div>;
  const {success, sections } = data as APIPageResponse;
  const setSections = updatePageSectionsMutation.mutate;
  const addSection = createSectionMutation.mutate as () => void;
  const changeSection = changeSectionMutation.mutate;
  return <AuthoringPage {...{id, sections, setSections, addSection, changeSection}} />;
};
