import * as React from "react";
import { ComponentStory, ComponentMeta } from "@storybook/react";
import { IPageHeaderProps, PageHeader } from "../section-authoring/components/page-header/components/page-header";
import { QueryClient, QueryClientProvider } from "react-query";
import { APIContext } from "../section-authoring/hooks/use-api-provider";
import { API as mockProvider } from "../section-authoring/api/mock-api-provider";
export default {
  title: "Page Header",
  component: PageHeader,
} as ComponentMeta<typeof PageHeader>;

const Template: ComponentStory<typeof PageHeader> = (args: IPageHeaderProps) =>  {
  const queryClient = new QueryClient();
  return (
    <APIContext.Provider value={mockProvider}>
      <QueryClientProvider client={queryClient}>
        <PageHeader {...args} />
      </QueryClientProvider>
    </APIContext.Provider >
  );
};

export const PageHeaderStory = Template.bind({});
PageHeaderStory.args = {
  user: {
    api_key: "abc123",
    created_at: "2021-11-19 12:24PM",
    email: "lara.author@concord.org",
    first_name: "Lara",
    id: 1,
    is_admin: false,
    is_author: true,
    last_name: "Jones",
    updated_at: "2021-11-19 12:24PM"
  },
  logOutURL: "#",
  host: "https://app.lara.docker/"
};
