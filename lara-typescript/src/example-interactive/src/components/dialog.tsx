import * as React from "react";
import { IDialogInitInteractive } from "../../../interactive-api-client";

interface Props {
  initMessage: IDialogInitInteractive;
}

export const DialogComponent: React.FC<Props> = ({initMessage}) => {
  return (
    <div className="padded">
      <fieldset>
        <legend>Dialog Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>
    </div>
  );
};
