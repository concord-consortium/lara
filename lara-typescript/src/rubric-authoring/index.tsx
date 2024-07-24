import * as React from "react";
import * as ReactDOM from "react-dom";

import { RubricForm, IRubricFormProps } from "./rubric-form";

const renderRubricForm = (root: HTMLElement, props: IRubricFormProps) => {
  return ReactDOM.render(<RubricForm {...props} />, root);
};

export {
  renderRubricForm
};
