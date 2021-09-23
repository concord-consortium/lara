import React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";

import { App } from "../section-authoring/query-providers-test-component";
import { getLaraPageAPI } from "../section-authoring/apis/lara-api";
import { API as mockProvider } from "../section-authoring/apis/mock-api";
import { APIContext } from "../section-authoring/apis/use-api-provider";
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