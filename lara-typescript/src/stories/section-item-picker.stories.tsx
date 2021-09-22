import * as React from "react";
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
    {name: "Multiple Choice", use_count: 300, date_added: "1630440493"},
    {name: "Text Box", use_count: 500, date_added: "1630440491"},
    {name: "Open Response", use_count: 400, date_added: "1630440492"},
    {name: "iFrame Interactive", use_count: 200, date_added: "1630440494"}
  ],
  allItems: [
    {name: "Carousel", use_count: 1, date_added: "1630440496"},
    {name: "CODAP", use_count: 5, date_added: "1630440497"},
    {name: "Drag & Drop", use_count: 5, date_added: "1630440498"},
    {name: "Fill in the Blank", use_count: 8, date_added: "1630440495"},
    {name: "iFrame Interactive", use_count: 200, date_added: "1630440494"},
    {name: "Multiple Choice", use_count: 300, date_added: "1630440493"},
    {name: "Open Response", use_count: 400, date_added: "1630440492"},
    {name: "SageModeler", use_count: 3, date_added: "1630440499"},
    {name: "Teacher Edition Window Shade", use_count: 4, date_added: "1630440490"},
    {name: "Text Box", use_count: 500, date_added: "1630440491"}
  ]
};
