import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { IPageNavMenuProps, PageNavMenu } from "../section-authoring/components/page-nav-menu/page-nav-menu";
import { APIContainer } from "../section-authoring/containers/api-container";
import { PageNavContainer } from "../section-authoring/containers/page-nav-container";

export default {
  title: "Page Nav Menu",
  component: PageNavMenu,
} as ComponentMeta<typeof PageNavMenu>;

const Template: ComponentStory<typeof PageNavMenu> = (args: IPageNavMenuProps) => <PageNavMenu {...args} />;

const ContainerTemplate: ComponentStory<typeof PageNavMenu> = () => (
  <APIContainer>
    <PageNavContainer />
  </APIContainer>
);

export const PageNavMenuStory = Template.bind({});
PageNavMenuStory.args = {
  pages: [
    { id: "1", title: "Page 1", sections: [], isCompletion: false },
    { id: "2", title: "Page 2", sections: [], isCompletion: false },
    { id: "3", title: "Page 3", sections: [], isCompletion: true },
  ],
  currentPageId: 1,
  copyingPage: false
};

export const PageNavInContainer = ContainerTemplate.bind({});
