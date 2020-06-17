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

  const initMsg = {
    version: 1,
    error: null,
    mode: "runtime",
    authoredState
  };

  return (
    <div className="authoring-interactive-preview" data-blah="hello">
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
