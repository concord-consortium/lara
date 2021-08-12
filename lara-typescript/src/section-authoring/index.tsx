import * as React from "react";
import * as ReactDOM from "react-dom";
import { AuthoringSection, SectionProps } from "./components/authoring-section";

const renderAuthoringSection = (root: HTMLElement, props: SectionProps) => {
  return ReactDOM.render(<AuthoringSection {...props} />, root);
};

export {
  renderAuthoringSection
};
