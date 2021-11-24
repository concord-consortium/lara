import * as React from "react";
import * as ReactDOM from "react-dom";
import { AuthoringSection, ISectionProps } from "./components/authoring-section";
import { IPreviewLinksProps, PreviewLinks } from "./components/preview-links";
import { QueryBoundPage, IQueryBoundPage } from "./components/query-bound-page";

const renderAuthoringSection = (root: HTMLElement, props: ISectionProps) => {
  return ReactDOM.render(<AuthoringSection {...props} />, root);
};

const renderAuthoringPage = (root: HTMLElement, props: IQueryBoundPage) => {
  const App = <QueryBoundPage {...props} />;
  return ReactDOM.render(App, root);
};

const renderPreviewLinks = (root: HTMLElement, props: IPreviewLinksProps) => {
  return ReactDOM.render(<PreviewLinks {...props} />, root);
};

export {
  renderAuthoringSection,
  renderAuthoringPage,
  renderPreviewLinks
};
