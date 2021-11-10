import * as React from "react";
import { useRef, useState } from "react";

import { InteractiveIframe } from "./interactive-iframe";
import { IInitInteractive } from "../../../interactive-api-client";

export interface IPreviewInteractive {
  id: string;
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
  user: IPreviewUser;
}

export const InteractiveAuthoringPreview: React.FC<Props> = ({interactive, user}) => {
  const iframe = useRef<HTMLIFrameElement|null>(null);
  const [authoredState, setAuthoredState] = useState<object|null>(
    typeof interactive.authored_state === "string"
      ? JSON.parse(interactive.authored_state || "{}")
      : interactive.authored_state
  );
  const linkedInteractives = typeof interactive.linked_interactives === "string"
    ? JSON.parse(interactive.linked_interactives || "{}")
    : interactive.linked_interactives;

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
      id: interactive.id,
      name: interactive.name
    },
    authInfo: {
      provider: user.authProvider as any,
      loggedIn: user.loggedIn,
      email: user.email as any
    },
    linkedInteractives,
    themeInfo: {            // TODO: add theme colors (future story)
      colors: {
        colorA: "red",
        colorB: "green"
      }
    }
  };

  return (
    <div className="authoring-interactive-preview">
      <InteractiveIframe
        src={interactive.url || ""}
        width="100%"
        initialAuthoredState={authoredState}
        initMsg={initMsg}
        authoredAspectRatioMethod={interactive.aspect_ratio_method}
        authoredAspectRatio={interactive.aspect_ratio}
      />
    </div>
  );
};
