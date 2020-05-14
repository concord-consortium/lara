import * as React from "react";
import { useRef, useState } from "react";

import { InteractiveIframe } from "./interactive-iframe";

export interface IPreviewInteractive {
  url: string;
  aspect_ratio_method: string;
  authored_state: string | object;
}

interface Props {
  interactive: IPreviewInteractive;
}

export const InteractiveAuthoringPreview: React.FC<Props> = ({interactive}) => {
  const iframe = useRef<HTMLIFrameElement|null>(null);
  const [authoredState, setAuthoredState] = useState<object|null>(
    typeof interactive.authored_state === "string"
      ? JSON.parse(interactive.authored_state || "{}")
      : interactive.authored_state
  );

  const handleHeightChange = (newHeight: number | string) => {
    if (iframe.current) {
      iframe.current.style.height = `${newHeight}px`;
    }
  };

  const handleSupportedFeatures = (info: any) => {
    if (info.features.aspectRatio) {
      if (interactive.aspect_ratio_method === "DEFAULT") {
        if (iframe.current) {
          iframe.current.style.height = `${Math.round(iframe.current.offsetWidth / info.features.aspectRatio)}px`;
        }
      }
    }
  };

  const handleSetIframeRef = (current: HTMLIFrameElement) => iframe.current = current;

  const initMsg = {
    version: 1,
    error: null,
    mode: "runtime",
    authoredState
  };

  return (
    <div className="authoring-interactive-preview">
      <InteractiveIframe
        src={interactive.url || ""}
        width="100%"
        height="100%"
        initialAuthoredState={authoredState}
        initMsg={initMsg}
        onSupportedFeaturesUpdate={handleSupportedFeatures}
        onHeightChange={handleHeightChange}
        onSetIFrameRef={handleSetIframeRef}
      />
    </div>
  );
};
