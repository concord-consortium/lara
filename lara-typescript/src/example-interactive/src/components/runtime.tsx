import * as React from "react";
import { IRuntimeInitInteractive } from "../../../interactive-api-client";

interface Props {
  initMessage: IRuntimeInitInteractive;
}

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  return (
    <div className="padded">
      <fieldset>
        <legend>Runtime Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
