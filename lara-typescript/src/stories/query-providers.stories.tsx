import React from "react";
import { ComponentMeta } from "@storybook/react";

import { App } from "../section-authoring/query-providers-test-component";
import { getLaraPageAPI } from "../section-authoring/api/lara-api-provider";
import { API as mockProvider } from "../section-authoring/api/mock-api-provider";
import { APIContext } from "../section-authoring/api/use-api-provider";
import { IPageProps, AuthoringPage} from "../section-authoring/components/authoring-page";
import { usePageAPI } from "../section-authoring/api/use-api-provider";
import { QueryClient } from "react-query";

export default {
  title: "Query Providers Test",
  component: App,
} as ComponentMeta<typeof App>;

// TODO Parameterize host and PageID
export const FakeAPI = () => {
  return(
  <APIContext.Provider value={mockProvider}>
    <App/>
  </APIContext.Provider>
  );
};

export const LocalHostAPI = () => {
  const LocalLaraAPI = getLaraPageAPI("https://app.lara.docker/", "55");
  return(
    <APIContext.Provider value={LocalLaraAPI}>
      <App/>
    </APIContext.Provider>
  );
};

export const AuthoringPageWithAPIProvider = () => {
  const LocalLaraAPI = getLaraPageAPI("https://app.lara.docker/", "55");
  const queryClient = new QueryClient();
  const Wrapper = () => {
    const api = usePageAPI();
    const addSection = () => api.addSectionMutation.mutate();
    const pages = api.getPages.data;
    if (pages) {
      const page = pages[0];
      return (
        <AuthoringPage
        sections= { page?.sections}
        addSection={ addSection }
        setSections={setSections}
        id={pageId}
        changeSection={changeSection}
        />
      )
    }
    else {
      return (
        <div>loading ...</div>
      )
    }
  }

  const page = getPages;.data?.[0];
  return (
    <APIContext.Provider value={mockProvider}>
      <Wrapper />
    </APIContext.Provider>
  );
};

AuthoringPageWithAPIProvider.title = "★ AuthoringPage with API hooks ...";