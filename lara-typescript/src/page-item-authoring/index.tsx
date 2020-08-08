import * as React from "react";
import * as ReactDOM from "react-dom";
import ResizeObserver from "resize-observer-polyfill";
import { SlateContainer, slateToHtml, htmlToSlate, serializeValue } from "@concord-consortium/slate-editor";

import { ManagedInteractiveAuthoring, IManagedInteractive } from "./managed-interactives";
import { ILibraryInteractive } from "./common/hooks/use-library-interactives";
import { MWInteractiveAuthoring, IMWInteractive } from "./mw-interactives";
import { InteractiveAuthoringPreview, IPreviewInteractive, IPreviewUser } from "./common/components/interactive-authoring-preview";
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
  user: IPreviewUser;
}
const renderInteractiveAuthoringPreview = (root: HTMLElement, props: IInteractiveAuthoringPreviewProps) => {
  return ReactDOM.render(
    <InteractiveAuthoringPreview
      interactive={props.interactive}
      user={props.user}
    />, root);
};

interface ISlateContainerProps {
  className?: string;
  editorClassName?: string;
  toolbar?: any; // TODO: Fix Slate repo to export types
}

const renderSlateContainer = (root: HTMLElement, props: ISlateContainerProps) => {
  return ReactDOM.render(
    <SlateContainer
      {...props}
    />, root);
};

export {
  ManagedInteractiveAuthoring,
  renderManagedInteractiveAuthoring,

  MWInteractiveAuthoring,
  renderMWInteractiveAuthoring,

  InteractiveAuthoringPreview,
  renderInteractiveAuthoringPreview,

  ResizeObserver,

  SlateContainer,
  renderSlateContainer,
  slateToHtml,
  htmlToSlate,
  serializeValue
};
