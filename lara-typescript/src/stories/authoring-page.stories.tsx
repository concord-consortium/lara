import * as React from "react";
import { APIContainer } from "../section-authoring/containers/api-container";
import { ComponentMeta, ComponentStory } from "@storybook/react";
import { AuthoringPage, AuthoringPageUsingAPI } from "../section-authoring/components/authoring-page";

export default {
  title: "Authoring Page Stories",
  component: APIContainer,
} as ComponentMeta<typeof APIContainer>;

interface IAPIProps {
  activityId: string;
  host: string;
}

const Template: ComponentStory<typeof APIContainer> = (args: IAPIProps) =>  {
  const APIContainerArgs = {
    activityId: args.activityId,
    host: args.host
  };
  return(
    <APIContainer {...APIContainerArgs} >
      <AuthoringPageUsingAPI />
    </APIContainer>
  );
};

export const WithLaraProvider = Template.bind({
  args: {
    activityId: 55,
    host: "https://app.lara.docker/"
  }
});

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
