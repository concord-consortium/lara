import React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { IPageNavMenuProps, PageNavMenu } from "../page-nav-menu/components/page-nav-menu";

export default {
  title: "Page Nav Menu",
  component: PageNavMenu,
} as ComponentMeta<typeof PageNavMenu>;

const Template: ComponentStory<typeof PageNavMenu> = (args: IPageNavMenuProps) => <PageNavMenu {...args} />;

export const PageNavMenuStory = Template.bind({});
PageNavMenuStory.args = {
  pages: [
    { id: "1", title: "Page 1", sections: [] },
    { id: "2", title: "Page 2", sections: [] },
    { id: "3", title: "Page 3", sections: [] },
  ],
  currentPage: 1
};
