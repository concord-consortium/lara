import React from "react";
import { ComponentMeta } from "@storybook/react";
import { PagesDemo } from "../section-authoring/query-providers-test-component";
import { AuthoringPageUsingAPI} from "../section-authoring/components/authoring-page";
import { APIContainer } from "../section-authoring/api/api-container";

export default {
  title: "Query Providers Test",
  component: PagesDemo,
} as ComponentMeta<typeof PagesDemo>;

export const FakeAPI = () => {
  return(
    <APIContainer>
      <PagesDemo/>
    </APIContainer>
  );
};

export const LocalHostAPI = () => {
  return(
    <APIContainer activityId="55" host="https://app.lara.docker">
      <PagesDemo/>
    </APIContainer>
  );
};

export const AuthoringPageWithAPIProvider = () => {
  return (
    <APIContainer activityId="55" host="https://app.lara.docker">
        <AuthoringPageUsingAPI />
    </APIContainer>
  );
};

export const AuthoringPageWithMockProvider = () => {
  return (
    <APIContainer>
        <AuthoringPageUsingAPI />
    </APIContainer>
  );
};
