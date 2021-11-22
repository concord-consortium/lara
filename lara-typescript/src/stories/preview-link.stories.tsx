import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { PreviewLinks, IPreviewLinksProps } from "../section-authoring/components/preview-links";

export default {
  title: "Preview Links",
  component: PreviewLinks,
} as ComponentMeta<typeof PreviewLinks>;

const Template: ComponentStory<typeof PreviewLinks> = (args: IPreviewLinksProps) =>  {
  return (<PreviewLinks {...args} />);
};

export const PageHeaderStory = Template.bind({});

PageHeaderStory.args = {
  "Select an option...": "",
  "Fake Activity Player": "https://activity-player.concord.org/branch/master",
  "Fake Activity Player Teachers": "https://activity-player.concord.org/branch/master"
};
