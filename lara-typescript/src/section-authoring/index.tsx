import * as React from "react";
import * as ReactDOM from "react-dom";
import { QueryClient, QueryClientProvider } from "react-query";
import { AuthoringSection, ISectionProps } from "./components/authoring-section";
import { IPageProps } from "./components/authoring-page";
import { QueryBoundPage } from "./components/query-bound-page";
const renderAuthoringSection = (root: HTMLElement, props: ISectionProps) => {
  return ReactDOM.render(<AuthoringSection {...props} />, root);
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
