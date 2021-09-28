import React from "react";
import { ComponentMeta } from "@storybook/react";

import { App } from "../section-authoring/query-providers-test-component";
import { getLaraAuthoringAPI } from "../section-authoring/api/lara-api-provider";
import { API as mockProvider } from "../section-authoring/api/mock-api-provider";
import { APIContext } from "../section-authoring/api/use-api-provider";
import { IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";
import { usePageAPI } from "../section-authoring/api/use-api-provider";
import { QueryClient, QueryClientProvider } from "react-query";
import { ISection } from "../section-authoring/api/api-types";

export default {
  title: "Query Providers Test",
  component: App,
} as ComponentMeta<typeof App>;

export const FakeAPI = () => {
  return(
  <APIContext.Provider value={mockProvider}>
    <App/>
  </APIContext.Provider>
  );
};

export const LocalHostAPI = () => {
  const LocalLaraAPI = getLaraAuthoringAPI("55", "https://app.lara.docker");
  return(
    <APIContext.Provider value={LocalLaraAPI}>
      <App/>
    </APIContext.Provider>
  );
};

export const AuthoringPageWithAPIProvider = () => {
  const LocalLaraAPI = getLaraAuthoringAPI("55", "https://app.lara.docker");
  const queryClient = new QueryClient();
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
    <APIContext.Provider value={LocalLaraAPI}>
      <QueryClientProvider client={queryClient}>
        <Content />
      </QueryClientProvider>
    </APIContext.Provider>
  );
};
