import * as React from "react";
import * as ReactDOM from "react-dom";
import { ProjectList } from "./components/project-list";
import { IProjectSettingsFormProps, ProjectSettingsForm } from "./components/project-settings-form";

const renderProjectList = (root: HTMLElement) => {
  return ReactDOM.render(<ProjectList />, root);
};

const renderProjectSettingsForm = (root: HTMLElement, props: IProjectSettingsFormProps) => {
  return ReactDOM.render(<ProjectSettingsForm {...props} />, root);
};

export {
  renderProjectList,
  renderProjectSettingsForm
};
