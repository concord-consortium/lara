import React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";

import { AuthoringSection } from "../section-authoring/components/authoring-section";

export default {
  title: "Authoring Section",
  component: AuthoringSection,
  argTypes: {
    backgroundColor: { control: "color" },
  },
} as ComponentMeta<typeof AuthoringSection>;

const Template: ComponentStory<typeof AuthoringSection> = (args) => <AuthoringSection {...args} />;

export const Primary = Template.bind({});
Primary.args = {
  primary: true,
  label: "Button",
};

export const Secondary = Template.bind({});
Secondary.args = {
  label: "Button",
};

export const Large = Template.bind({});
Large.args = {
  size: "large",
  label: "Button",
};

export const Small = Template.bind({});
Small.args = {
  size: "small",
  label: "Button",
};
