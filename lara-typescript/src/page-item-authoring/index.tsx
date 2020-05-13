import * as React from "react";
import * as ReactDOM from "react-dom";

import { ManagedInteractiveAuthoring, IManagedInteractive } from "./managed-interactives";
import { ILibraryInteractive } from "./common/hooks/use-library-interactives";
import { MWInteractiveAuthoring, IMWInteractive } from "./mw-interactives";

interface IRenderManagedInteractiveAuthoringProps {
  managedInteractive: IManagedInteractive;
  libraryInteractive?: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
}
const renderManagedInteractiveAuthoring = (root: HTMLElement, props: IRenderManagedInteractiveAuthoringProps) => {
  return ReactDOM.render(
    <ManagedInteractiveAuthoring
      managedInteractive={props.managedInteractive}
      libraryInteractive={props.libraryInteractive}
      defaultClickToPlayPrompt={props.defaultClickToPlayPrompt}
    />, root);
};

interface IRenderMWInteractiveAuthoringProps {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
}
const renderMWInteractiveAuthoring = (root: HTMLElement, props: IRenderMWInteractiveAuthoringProps) => {
  return ReactDOM.render(
    <MWInteractiveAuthoring
      interactive={props.interactive}
      defaultClickToPlayPrompt={props.defaultClickToPlayPrompt}
    />, root);
};

export {
  ManagedInteractiveAuthoring,
  renderManagedInteractiveAuthoring,

  MWInteractiveAuthoring,
  renderMWInteractiveAuthoring
};

(window as any).LARA.PageItemAuthoring = {
  renderManagedInteractiveAuthoring,
  renderMWInteractiveAuthoring
};
