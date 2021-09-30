import React from "react";
import { ComponentMeta } from "@storybook/react";
import { App } from "../section-authoring/query-providers-test-component";
import { AuthoringPage} from "../section-authoring/components/authoring-page";
import { usePageAPI } from "../section-authoring/api/use-api-provider";
import { ISection } from "../section-authoring/api/api-types";
import { APIContainer } from "../section-authoring/api/api-container";

export default {
  title: "Query Providers Test",
  component: App,
} as ComponentMeta<typeof App>;

export const FakeAPI = () => {
  return(
    <APIContainer>
      <App/>
    </APIContainer>
  );
};

export const LocalHostAPI = () => {
  return(
    <APIContainer activityId="55" host="https://app.lara.docker">
      <App/>
    </APIContainer>
  );
};

export const AuthoringPageWithAPIProvider = () => {
  const Content = () => {
    const api = usePageAPI();
    const pages = api.getPages.data;
    if (pages) {
      const p = pages[0];
      const addSection = () => api.addSectionMutation.mutate(p.id);
      const setSections = (pageData: {id: string, sections: ISection[]}) => api.updateSections.mutate(p);
      const changeSection = (changes: {
        section: Partial<ISection>,
        sectionID: string}) => api.updateSection.mutate({pageId: p.id, changes});
      return (
        <AuthoringPage
          sections={p?.sections}
          addSection={addSection }
          setSections={setSections}
          id={p.id}
          changeSection={changeSection}
        />
      );
    }
    else {
      return (
        <div>loading ...</div>
      );
    }
  };

  return (
    <APIContainer activityId="55" host="https://app.lara.docker">
        <Content />
    </APIContainer>
  );
};
