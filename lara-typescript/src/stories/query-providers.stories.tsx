import React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";

import { App } from "../section-authoring/query-providers-test-component";
import { getLaraPageAPI } from "../section-authoring/apis/lara-page-api";
import { API as mockProvider } from "../section-authoring/apis/mock-page-api";
import { APIContext } from "../section-authoring/apis/use-page-api-provider";
export default {
  title: "Query Providers Test",
  component: App,
} as ComponentMeta<typeof App>;


const LocalLaraAPI = getLaraPageAPI("https://app.lara.docker/", "701");

// TODO Parameterize host and PageID
export const FakeAPI = () => {
  return(
  <APIContext.Provider value={mockProvider}>
    <App/>
  </APIContext.Provider>
  );
};

export const LocalHostAPI = () => {
  return(
    <APIContext.Provider value={LocalLaraAPI}>
      <App/>
    </APIContext.Provider>
  );
};