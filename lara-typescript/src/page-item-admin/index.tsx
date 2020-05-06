import * as React from "react";
import * as ReactDOM from "react-dom";

import { ManagedInteractiveAdmin } from "./managed-interactives-admin";

const renderManagedInteractiveAdmin = (root: HTMLElement) => ReactDOM.render(<ManagedInteractiveAdmin />, root);

export {
  ManagedInteractiveAdmin,
  renderManagedInteractiveAdmin,
};

(window as any).LARA.PageItemAdmin = {
  renderManagedInteractiveAdmin
};
