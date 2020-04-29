import * as React from "react";
import * as ReactDOM from "react-dom";

import { App } from "./app";

export const renderApp = (root: HTMLElement) => {
  ReactDOM.render(<App />, root);
};
