import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { AuthoringSection, ISectionProps } from "../section-authoring/components/authoring-section";
import { SectionLayouts } from "../section-authoring/api/api-types";

export default {
  title: "Section Items Are Draggable",
  component: AuthoringSection,
  argTypes: {
    backgroundColor: { control: "color" },
  },
} as ComponentMeta<typeof AuthoringSection>;

const Template: ComponentStory<typeof AuthoringSection> = (args: ISectionProps) => <AuthoringSection {...args} />;

export const FullWidth = Template.bind({});
FullWidth.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_FULL_WIDTH
};

export const _40_60 = Template.bind({});
_40_60.args = {
  id: "1",
  interactive_page_id: "2",
  layout: SectionLayouts.LAYOUT_40_60
};
