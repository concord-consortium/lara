import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";

import { IProps, SectionItemPicker } from "../section-authoring/components/section-item-picker";
import { QueryClient, QueryClientProvider } from "react-query";
import { APIContext } from "../section-authoring/api/use-api-provider";
import { API as mockProvider } from "../section-authoring/api/mock-api-provider";
export default {
  title: "Section Item Picker",
  component: SectionItemPicker,
} as ComponentMeta<typeof SectionItemPicker>;

const Template: ComponentStory<typeof SectionItemPicker> = (args: IProps) =>  {
  const queryClient = new QueryClient();
  return (
    <APIContext.Provider value={mockProvider}>
      <QueryClientProvider client={queryClient}>
        <SectionItemPicker {...args} />
      </QueryClientProvider>
    </APIContext.Provider >
  );
};

export const SectionItemPickerStory = Template.bind({});
SectionItemPickerStory.args = { };
