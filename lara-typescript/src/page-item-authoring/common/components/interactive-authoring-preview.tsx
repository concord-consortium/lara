import * as React from "react";
import { useEffect, useRef, useState } from "react";
import { InteractiveIframe } from "./interactive-iframe";
import { IInitInteractive } from "../../../interactive-api-client";

export interface IPreviewInteractive {
  id: number;
  name: string;
  url: string;
  aspect_ratio: number;
  aspect_ratio_method: string;
  authored_state: string | object;
  linked_interactives: string | object;
}

export interface IPreviewUser {
  loggedIn: boolean;
  authProvider: string | null;
  email: string | null;
}

interface Props {
  interactive: IPreviewInteractive;
  user?: IPreviewUser;
}

export const InteractiveAuthoringPreview: React.FC<Props> = ({interactive, user}) => {
  const authoredState = typeof interactive.authored_state === "string"
    ? interactive.authored_state
    : JSON.stringify(interactive.authored_state || "{}");
  const [prevAuthoredState, setPrevAuthoredState] = useState<string|null>(authoredState);
  const linkedInteractives = typeof interactive.linked_interactives === "string"
    ? JSON.parse(interactive.linked_interactives || "[]")
    : interactive.linked_interactives;

  const resetCount = useRef(0);

  useEffect(() => {
    if (authoredState !== prevAuthoredState) {
      // re-render preview to show changes
      setPrevAuthoredState(authoredState);
      resetCount.current = resetCount.current + 1;
    }
  }, [interactive]);

  const initMsg: IInitInteractive = {
    version: 1,
    error: null,
    mode: "runtime",
    hostFeatures: {
      modal: {
        version: "1.0.0",
      }
    },
    authoredState,
    interactiveState: null,
    globalInteractiveState: null,
    interactiveStateUrl: "",
    collaboratorUrls: null,
    classInfoUrl: "",
    interactive: {
      id: interactive.id?.toString(),
      name: interactive.name
    },
    authInfo: {
      provider: user!.authProvider as any,
      loggedIn: user!.loggedIn,
      email: user!.email as any
    },
    linkedInteractives,
    themeInfo: {            // TODO: add theme colors (future story)
      colors: {
        colorA: "red",
        colorB: "green"
      }
    },
    attachments: {}
  };

  return (
    <div className="authoring-interactive-preview">
      { interactive &&
        <InteractiveIframe
          src={interactive.url}
          width="100%"
          initialAuthoredState={authoredState ? JSON.parse(authoredState) : null}
          initMsg={initMsg}
          authoredAspectRatioMethod={interactive.aspect_ratio_method}
          authoredAspectRatio={interactive.aspect_ratio}
          resetCount={resetCount.current}
        />
      }
    </div>
  );
};

InteractiveAuthoringPreview.defaultProps = {
  user: {
    authProvider: null,
    loggedIn: false,
    email: "anonymous@concord.org"
  }
};
