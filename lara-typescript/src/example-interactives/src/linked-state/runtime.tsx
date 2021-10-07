import * as React from "react";
import { IRuntimeInitInteractive, useInteractiveState } from "../../../interactive-api-client";

interface Props {
  initMessage: IRuntimeInitInteractive<any, {}>;
}

export const RuntimeComponent: React.FC<Props> = ({initMessage}) => {
  const {interactiveState, setInteractiveState} = useInteractiveState<any>();

  const handleInteractiveStateValueChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
    setInteractiveState(event.target.value);
  };

  return (
    <div className="padded">
      <fieldset>
        <legend>Runtime Init Message</legend>
        <div className="padded monospace pre">{JSON.stringify(initMessage, null, 2)}</div>
      </fieldset>

      <fieldset>
        <legend>Interactive State</legend>
        <textarea
          className="textarea"
          value={interactiveState || ""}
          onChange={handleInteractiveStateValueChange}
        />
      </fieldset>
    </div>
  );
};
