import * as React from "react";
import { useRef, useState } from "react";

import { InteractiveIframe } from "./interactive-iframe";

export interface IPreviewInteractive {
  url: string;
  aspect_ratio: number;
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

  // FIXME: The default height here should be based on the aspect ratio setting
  // and the width of the iframe. That computation at runtime is currently handled
  // by the setSize method in interactives-sizing.js
  // That code can't be used here, because the jQuery changes to the iframe
  // conflict with the React management of the iframe element.
  // We could duplicate the sizing code here, or abstract it so it can be
  // shared by both the runtime and authoring.
  // The best solution would be to move the runtime iframe rendering into React
  // so both authoring and runtime use the interactiveIframe component
  const [height, setHeight] = useState<number|string>(300);

  const handleHeightChange = (newHeight: number | string) => {
    setHeight(newHeight);
  };

  const handleSupportedFeatures = (info: any) => {
    if (info.features.aspectRatio) {
      if (interactive.aspect_ratio_method === "DEFAULT") {
        if (iframe.current) {
          const newHeight = Math.round(iframe.current.offsetWidth / info.features.aspectRatio);
          setHeight(newHeight);
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
        height={height}
        initialAuthoredState={authoredState}
        initMsg={initMsg}
        aspectRatio={interactive.aspect_ratio}
        aspectRatioMethod={interactive.aspect_ratio_method}
        onSupportedFeaturesUpdate={handleSupportedFeatures}
        onHeightChange={handleHeightChange}
        onSetIFrameRef={handleSetIframeRef}
      />
    </div>
  );
};
