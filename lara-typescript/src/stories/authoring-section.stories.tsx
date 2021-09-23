import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { AuthoringSection, ISectionProps } from "../section-authoring/components/authoring-section";
import { SectionLayouts } from "../section-authoring/api/api-types";

export default {
  title: "Authoring Section",
  component: AuthoringSection,
  argTypes: {
    backgroundColor: { control: "color" },
  },
} as ComponentMeta<typeof AuthoringSection>;

const Template: ComponentStory<typeof AuthoringSection> = (args: ISectionProps) => <AuthoringSection {...args} />;

export const _30_70 = Template.bind({});
_30_70.args  = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_30_70
} as ISectionProps;

export const _40_60 = Template.bind({});
_40_60.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_40_60
};

export const _60_40 = Template.bind({});
_60_40.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_60_40
};

export const _70_30 = Template.bind({});
_70_30.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_70_30
};

export const FullWidth = Template.bind({});
FullWidth.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_FULL_WIDTH
};
