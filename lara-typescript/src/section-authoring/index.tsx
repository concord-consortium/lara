import * as React from "react";
import * as ReactDOM from "react-dom";
import { QueryClient, QueryClientProvider, useQuery } from "react-query";

import { AuthoringSection, ISectionProps } from "./components/authoring-section";
import { AuthoringPage, IPageProps } from "./components/authoring-page";

const renderAuthoringSection = (root: HTMLElement, props: ISectionProps) => {
  return ReactDOM.render(<AuthoringSection {...props} />, root);
};

interface APIPageResponse extends IPageProps {
  success: boolean;
}

const QueryBoundPage = (props: IPageProps) => {
  const {id} = props;
  const url = `/api/v1/get_page_sections/${id}.json`;
  // tslint:disable-next-line:no-console
  console.log(url);
  const { isLoading, error, data} = useQuery("authoringPage", () =>
    fetch(`/api/v1/get_page_sections/${id}.json`)
    .then(res => {
      const resJson = res.json();
      // tslint:disable-next-line:no-console
      console.log(resJson);
      return resJson;
    })
  );

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Something went wrong: ${error}</div>;
  const {success, sections } = data as APIPageResponse;
  return <AuthoringPage {...{id, sections}}/>;
};

const renderAuthoringPage = (root: HTMLElement, props: IPageProps) => {
  const queryClient = new QueryClient();
  const App =
    <QueryClientProvider client={queryClient}>
      <QueryBoundPage {...props} />
    </QueryClientProvider>;
  return ReactDOM.render(App, root);
};

export {
  renderAuthoringSection,
  renderAuthoringPage
};
