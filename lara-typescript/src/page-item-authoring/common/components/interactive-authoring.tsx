import * as React from "react";
import { useState } from "react";
import { InteractiveIframe } from "./interactive-iframe";
import { AuthoringApiUrls } from "../types";
import { IInitInteractive, ILinkedInteractive, ISetLinkedInteractives } from "../../../interactive-api-client";

interface Props {
  interactive: {
    url: string;
    aspect_ratio: number;
    aspect_ratio_method: string;
    authored_state: string | object;
    interactive_item_id: string;
    linked_interactives: ILinkedInteractive[];
  };
  onAuthoredStateChange: (authoredState: string | object) => void;
  onLinkedInteractivesChange: (linkedInteractives: ISetLinkedInteractives) => void;
  allowReset: boolean;
  authoringApiUrls: AuthoringApiUrls;
}

export const InteractiveAuthoring: React.FC<Props> = (props) => {
  const {interactive, onAuthoredStateChange, onLinkedInteractivesChange, allowReset, authoringApiUrls} = props;
  const [authoringSupported, setAuthoringSupported] = useState(false);
  const [authoredState, setAuthoredState] = useState<object|null>(
    typeof interactive.authored_state === "string"
      ? JSON.parse(interactive.authored_state || "{}")
      : interactive.authored_state
  );
  const [resetCount, setResetCount] = useState(0);
  const {interactive_item_id: interactiveItemId} = interactive;

  const handleAuthoredStateChange = (newAuthoredState: object) => {
    setAuthoredState(newAuthoredState);
    onAuthoredStateChange(newAuthoredState);
  };

  const handleSupportedFeatures = (info: any) => {
    setAuthoringSupported(!!info.features.authoredState);
  };

  const handleReset = () => {
    setAuthoredState(null);
    setResetCount(resetCount + 1);
  };

  const initMsg: IInitInteractive = {
    version: 1,
    error: null,
    mode: "authoring",
    hostFeatures: {
      modal: {
        version: "1.0.0",
        dialog: false,
        lightbox: true,
        alert: true
      },
      getFirebaseJwt: {
        version: "1.0.0",
      }
    },
    authoredState,
    themeInfo: {            // TODO: add theme colors (future story)
      colors: {
        colorA: "red",
        colorB: "green"
      }
    },
    interactiveItemId,
    linkedInteractives: interactive.linked_interactives
  };

  return (
    <div className="authoring-mw-interactive">
      {allowReset
        ? <div className={`status ${authoringSupported ? "visible" : ""}`}>
            {authoredState
              ? <input type="button" className="reset-btn" value="Reset authored state" onClick={handleReset} />
              : undefined
            }
          </div>
        : undefined
      }
      <InteractiveIframe
        src={interactive.url}
        width="100%"
        initialAuthoredState={authoredState}
        initMsg={initMsg}
        resetCount={resetCount}
        onAuthoredStateChange={handleAuthoredStateChange}
        onLinkedInteractivesChange={onLinkedInteractivesChange}
        onSupportedFeaturesUpdate={handleSupportedFeatures}
        authoredAspectRatioMethod={interactive.aspect_ratio_method}
        authoredAspectRatio={interactive.aspect_ratio}
        authoringApiUrls={authoringApiUrls}
      />
    </div>
  );
};
