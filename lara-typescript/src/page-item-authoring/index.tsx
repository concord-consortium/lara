import * as React from "react";
import * as ReactDOM from "react-dom";

import { ManagedInteractiveAdmin, ILibraryInteractive } from "./managed-interactives-authoring";

// by default it is set to render within the managed interactive popup but this can be changed by
// specifing a different id and name that matches the form that it is enclosed within
interface IRenderManagedInteractiveProps {
  selectLegend?: string;
  selectId?: string;
  selectName?: string;
  libraryInteractive?: ILibraryInteractive;
}
const renderManagedInteractiveAdmin = (root: HTMLElement, props?: IRenderManagedInteractiveProps) => {
  return ReactDOM.render(
    <ManagedInteractiveAdmin
      selectLegend={props ? props.selectLegend : undefined}
      selectId={props ? props.selectId : undefined}
      selectName={props ? props.selectName : undefined}
      libraryInteractive={props ? props.libraryInteractive : undefined}
    />, root);
};

export {
  ManagedInteractiveAdmin,
  renderManagedInteractiveAdmin,
};

(window as any).LARA.PageItemAdmin = {
  renderManagedInteractiveAdmin
};
