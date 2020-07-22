import * as React from "react";
import { useRef, useState } from "react";

import { InteractiveIframe } from "./interactive-iframe";
import { AuthoringApiUrls } from "../types";

interface Props {
  interactive: {
    url: string;
    aspect_ratio: number;
    aspect_ratio_method: string;
    authored_state: string | object;
  };
  onAuthoredStateChange: (authoredState: string | object) => void;
  allowReset: boolean;
  authoringApiUrls: AuthoringApiUrls;
}

export const InteractiveAuthoring: React.FC<Props> = (props) => {
  const {interactive, onAuthoredStateChange, allowReset, authoringApiUrls} = props;
  const iframe = useRef<HTMLIFrameElement|null>(null);
  const [authoringSupported, setAuthoringSupported] = useState(false);
  const [authoredState, setAuthoredState] = useState<object|null>(
    typeof interactive.authored_state === "string"
      ? JSON.parse(interactive.authored_state || "{}")
      : interactive.authored_state
  );
  const [resetCount, setResetCount] = useState(0);

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

  const initMsg = {
    version: 1,
    error: null,
    mode: "authoring",
    authoredState
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
        onSupportedFeaturesUpdate={handleSupportedFeatures}
        authoredAspectRatioMethod={interactive.aspect_ratio_method}
        authoredAspectRatio={interactive.aspect_ratio}
        authoringApiUrls={authoringApiUrls}
      />
    </div>
  );
};
