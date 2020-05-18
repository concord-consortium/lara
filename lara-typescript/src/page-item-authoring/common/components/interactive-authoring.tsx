import * as React from "react";
import { useRef, useState } from "react";

import { InteractiveIframe } from "./interactive-iframe";

interface Props {
  interactive: {
    url: string;
    aspect_ratio: number;
    aspect_ratio_method: string;
    authored_state: string | object;
  };
  onAuthoredStateChange: (authoredState: string | object) => void;
  allowReset: boolean;
}

export const InteractiveAuthoring: React.FC<Props> = ({interactive, onAuthoredStateChange, allowReset}) => {
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

  const handleHeightChange = (newHeight: number | string) => {
    if (iframe.current) {
      iframe.current.style.height = `${newHeight}px`;
    }
  };

  const handleSupportedFeatures = (info: any) => {
    setAuthoringSupported(!!info.features.authoredState);
    if (info.features.aspectRatio) {
      if (interactive.aspect_ratio_method === "DEFAULT") {
        if (iframe.current) {
          iframe.current.style.height = `${Math.round(iframe.current.offsetWidth / info.features.aspectRatio)}px`;
        }
      }
    }
  };

  const handleReset = () => {
    setAuthoredState(null);
    setResetCount(resetCount + 1);
  };

  const handleSetIframeRef = (current: HTMLIFrameElement) => iframe.current = current;

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
        height="100%"
        initialAuthoredState={authoredState}
        initMsg={initMsg}
        resetCount={resetCount}
        aspectRatio={interactive.aspect_ratio}
        aspectRatioMethod={interactive.aspect_ratio_method}
        onAuthoredStateChange={handleAuthoredStateChange}
        onSupportedFeaturesUpdate={handleSupportedFeatures}
        onHeightChange={handleHeightChange}
        onSetIFrameRef={handleSetIframeRef}
      />
    </div>
  );
};
