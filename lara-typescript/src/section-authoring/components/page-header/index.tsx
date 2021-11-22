import * as React from "react";
import * as ReactDOM from "react-dom";
import { PageHeader, IPageHeaderProps } from "./components/page-header";

const renderPageHeader = (root: HTMLElement, props: IPageHeaderProps) => {
  return ReactDOM.render(<PageHeader {...props} />, root);
};

export {
  renderPageHeader
};
