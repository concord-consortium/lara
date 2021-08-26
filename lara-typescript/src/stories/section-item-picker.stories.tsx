import React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";

import { IProps, SectionItemPicker } from "../section-authoring/components/section-item-picker";

export default {
  title: "Section Item Picker",
  component: SectionItemPicker,
} as ComponentMeta<typeof SectionItemPicker>;

const Template: ComponentStory<typeof SectionItemPicker> = (args: IProps) => <SectionItemPicker {...args} />;

export const SectionItemPickerStory = Template.bind({});
SectionItemPickerStory.args = {
  quickAddItems: [
    {name: 'Multiple Choice'},
    {name: 'Text Box'},
    {name: 'Open Response'},
    {name: 'iFrame Interactive'}
  ],
  availableItemTypes: []
};
