import * as React from "react";
import * as ReactDOM from "react-dom";
import ResizeObserver from "resize-observer-polyfill";

import { ManagedInteractiveAuthoring, IManagedInteractive } from "./managed-interactives";
import { ILibraryInteractive } from "./common/hooks/use-library-interactives";
import { MWInteractiveAuthoring, IMWInteractive } from "./mw-interactives";
import { InteractiveAuthoringPreview, IPreviewInteractive } from "./common/components/interactive-authoring-preview";
import { AuthoringApiUrls } from "./common/types";

interface IRenderManagedInteractiveAuthoringProps {
  managedInteractive: IManagedInteractive;
  libraryInteractive?: ILibraryInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
}
const renderManagedInteractiveAuthoring = (root: HTMLElement, props: IRenderManagedInteractiveAuthoringProps) => {
  return ReactDOM.render(
    <ManagedInteractiveAuthoring
      managedInteractive={props.managedInteractive}
      libraryInteractive={props.libraryInteractive}
      defaultClickToPlayPrompt={props.defaultClickToPlayPrompt}
      authoringApiUrls={props.authoringApiUrls}
    />, root);
};

interface IRenderMWInteractiveAuthoringProps {
  interactive: IMWInteractive;
  defaultClickToPlayPrompt: string;
  authoringApiUrls: AuthoringApiUrls;
}
const renderMWInteractiveAuthoring = (root: HTMLElement, props: IRenderMWInteractiveAuthoringProps) => {
  return ReactDOM.render(
    <MWInteractiveAuthoring
      interactive={props.interactive}
      defaultClickToPlayPrompt={props.defaultClickToPlayPrompt}
      authoringApiUrls={props.authoringApiUrls}
    />, root);
};

interface IInteractiveAuthoringPreviewProps {
  interactive: IPreviewInteractive;
}
const renderInteractiveAuthoringPreview = (root: HTMLElement, props: IInteractiveAuthoringPreviewProps) => {
  return ReactDOM.render(
    <InteractiveAuthoringPreview
      interactive={props.interactive}
    />, root);
};

export {
  ManagedInteractiveAuthoring,
  renderManagedInteractiveAuthoring,

  MWInteractiveAuthoring,
  renderMWInteractiveAuthoring,

  InteractiveAuthoringPreview,
  renderInteractiveAuthoringPreview,

  ResizeObserver
};
