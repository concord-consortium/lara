import * as React from "react";
import { useQueryClient } from "react-query";
import { APIContainer } from "../api/api-container";
import { AuthoringPage, IPageProps } from "./authoring-page";
import { ISectionProps } from "./authoring-section";
import { ICreatePageItem, ILibraryInteractiveResponse, IPage, ISection} from "../api/api-types";
import { usePageAPI } from "../api/use-api-provider";

const APIBase = "/api/v1";
interface IQueryBoundPage extends IPageProps {
  host?: string;
  activityId?: string;
}

export const QueryBoundPage = (props: IQueryBoundPage) => {
  const host = props.host || "https://app.lara.docker";
  const activityId = props.activityId || "55";
  const api = usePageAPI();
  const {getPages, getAllEmbeddables} = api;
  const isLoading = getPages.isLoading || getAllEmbeddables.isLoading;
  const error = getPages.error || getAllEmbeddables.error;

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Something went wrong: ${error}</div>;
  // If we got to here we have pages and embeddables:
  const pages = getPages.data!;
  // TODO: We should change the return type of getAllEmbeddables
  const allEmbeddables = getAllEmbeddables.data!.allEmbeddables;

  const page = pages[0];
  const sections = page.sections; // Do we need this?
  const setSections = api.updateSections.mutate;
  const addSection = () => api.addSectionMutation.mutate(page.id);
  const changeSection = (changes: {
      section: Partial<ISection>,
      sectionID: string}) => {
        return api.updateSection.mutate({pageId: page.id, changes});
  };
  const addPageItem = (newPageItem: ICreatePageItem) => api.createPageItem.mutate({pageId: page.id, newPageItem});

  const isCompletion = false;

  return (
      <APIContainer activityId={activityId} host={host}>
        <AuthoringPage {...
          {
            id: page.id, sections, setSections, addSection, changeSection,
            allEmbeddables, addPageItem, isCompletion
          }
        }/>
      </APIContainer>
    );
};
