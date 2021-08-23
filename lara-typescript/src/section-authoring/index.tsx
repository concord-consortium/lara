import * as React from "react";
import * as ReactDOM from "react-dom";
import { AuthoringSection, ISectionProps } from "./components/authoring-section";

const renderAuthoringSection = (root: HTMLElement, props: ISectionProps) => {
  return ReactDOM.render(<AuthoringSection {...props} />, root);
};

export {
  renderAuthoringSection
};
